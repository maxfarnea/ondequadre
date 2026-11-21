#!/usr/bin/env bash
# Applica a Quartz le personalizzazioni del sito. Unico punto di verita':
# chiamato sia da .github/scripts/preview.sh sia dal workflow di deploy.
#
#   patch-quartz.sh <dir-di-quartz>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
Q="${1:?usage: patch-quartz.sh <quartz-dir>}"
cd "$Q"

# --- Configurazione ----------------------------------------------------------
sed -i 's|pageTitle: .*|pageTitle: "Onde Quadre",|' quartz.config.ts
sed -i 's|locale: .*|locale: "it-IT",|' quartz.config.ts
sed -i 's|baseUrl: .*|baseUrl: "maxfarnea.github.io",|' quartz.config.ts
sed -i 's|markdownLinkResolution: "absolute"|markdownLinkResolution: "shortest"|' quartz.config.ts

# --- Layout ------------------------------------------------------------------
# 1. Niente colonna destra (graph, toc, backlinks) in tutti i layout
perl -0pi -e 's#  right: \[\n.*?\n  \],#  right: [],#gs' quartz.layout.ts

# 1b. Componente custom categorie+tag nella colonna destra (già svuotata sopra)
cp -f "$SCRIPT_DIR/quartz-custom/CategoriesAndTags.tsx" quartz/components/CategoriesAndTags.tsx
if ! grep -q 'CategoriesAndTags' quartz/components/index.ts; then
  sed -i 's|import TagList from "./TagList"|import TagList from "./TagList"\nimport CategoriesAndTags from "./CategoriesAndTags"|' quartz/components/index.ts
  sed -i 's|^  TagList,$|  TagList,\n  CategoriesAndTags,|' quartz/components/index.ts
fi
perl -0pi -e 's#  right: \[\],#  right: [Component.CategoriesAndTags()],#g' quartz.layout.ts

# 2. Sidebar: post recenti della lingua della pagina al posto dell'albero file
perl -0pi -e 's#\QComponent.Explorer(),\E#Component.ConditionalRender({ component: Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug !== "index" \&\& f.slug !== "introduzione" \&\& !f.slug?.endsWith(".en") }), condition: (page) => !(page.fileData.slug ?? "").endsWith(".en") }), Component.ConditionalRender({ component: Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug?.endsWith(".en") \&\& f.slug !== "index.en" \&\& f.slug !== "introduzione.en" }), condition: (page) => (page.fileData.slug ?? "").endsWith(".en") }),#g' \
  quartz.layout.ts
# stato preesistente (copie .preview già patchate): aggiunge le esclusioni introduzione
if ! grep -q 'introduzione' quartz.layout.ts; then
  sed -i 's|filter: (f) => f.slug !== "index" |filter: (f) => f.slug !== "index" \&\& f.slug !== "introduzione" |g' quartz.layout.ts
  sed -i 's|filter: (f) => f.slug?.endsWith(".en") \&\& f.slug !== "index.en"|filter: (f) => f.slug?.endsWith(".en") \&\& f.slug !== "index.en" \&\& f.slug !== "introduzione.en"|g' quartz.layout.ts
fi

# 3. Pagina indice: niente data/tag duplicati al centro, il titolo (h1 =ArticleTitle)
#    invece resta: il corpo della home e' generato da generate_index.py senza titolo
perl -0pi -e 's#^    Component\.ConditionalRender\(\{ component: Component\.ArticleTitle\(\), condition: \(page\) => page\.fileData\.slug !== "index" && page\.fileData\.slug !== "index\.en" \}\),$#    Component.ArticleTitle(),#m' \
  quartz.layout.ts
perl -0pi -e 's#^    Component\.ArticleTitle\(\),\n    Component\.ContentMeta\(\),\n    Component\.TagList\(\),$#    Component.ArticleTitle(),\n    Component.ConditionalRender({ component: Component.ContentMeta(), condition: (page) => page.fileData.slug !== "index" \&\& page.fileData.slug !== "index.en" }),\n    Component.ConditionalRender({ component: Component.TagList(), condition: (page) => page.fileData.slug !== "index" \&\& page.fileData.slug !== "index.en" }),#m' \
  quartz.layout.ts

# 4. Titolo del sito: niente in colonna sinistra sulla home (l'ArticleTitle lo
#    gia' centrato; cosi' la sidebar sale verso l'alto)
perl -0pi -e 's#^    Component\.PageTitle\(\),$#    Component.ConditionalRender({ component: Component.PageTitle(), condition: (page) => page.fileData.slug !== "index" \&\& page.fileData.slug !== "index.en" }),#mg' \
  quartz.layout.ts

# 5. Stili per le card della home
if ! grep -q 'post-cards' quartz/styles/custom.scss; then
cat >> quartz/styles/custom.scss <<'EOF'

// Indice della home: card con thumbnail, titolo, data e category
.post-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1.2rem;
  margin: 1.5rem 0;
}

a.post-card {
  display: block;
  border: 1px solid var(--lightgray);
  border-radius: 6px;
  overflow: hidden;
  text-decoration: none;
  color: inherit;

  &:hover {
    border-color: var(--secondary);
    .post-card-title {
      color: var(--secondary);
    }
  }

  .post-card-thumb {
    display: block;
    width: 100%;
    aspect-ratio: 16 / 9;
    object-fit: cover;
  }

  .post-card-nothumb {
    background: var(--lightgray);
    display: flex;
    align-items: center;
    justify-content: center;

    span {
      font-size: 3rem;
      opacity: 0.4;
    }
  }

  .post-card-meta {
    padding: 0.6rem 0.8rem 0.8rem;
  }

  .post-card-title {
    display: block;
    color: var(--dark);
    font-weight: 700;
    font-size: 0.95rem;
    line-height: 1.25;
  }

  .post-card-info {
    display: block;
    margin-top: 0.3rem;
    font-size: 0.8rem;
    opacity: 0.7;
  }
}
EOF
fi

# 6. Footer: anno dinamico + autore invece del credito "Creato con Quartz"
perl -0pi -e 's#\Q        <p>\E\n\Q          {i18n(cfg.locale).components.footer.createdWith}{" "}\E\n\Q          <a href="https://quartz.jzhao.xyz/">Quartz v{version}</a> © {year}\E\n\Q        </p>\E#        <p>\n          © {year} - Massimiliano Farnea (<a href="https://github.com/maxfarnea">maxfarnea</a>)\n        </p>#' \
  quartz/components/Footer.tsx
perl -0pi -e 's#\Q    links: {\E\n\Q      GitHub: "https://github.com/jackyzha0/quartz",\E\n\Q      "Discord Community": "https://discord.gg/cRFFHYye7t",\E\n\Q    },\E#    links: {},#' \
  quartz.layout.ts

# --- Controprove: fallisce loud se una patch non ha preso --------------------
grep -q 'pageTitle: "Onde Quadre"' quartz.config.ts
grep -q 'locale: "it-IT"' quartz.config.ts
! grep -q 'Component.Graph' quartz.layout.ts
! grep -q 'Component.Explorer' quartz.layout.ts
! grep -q 'ConditionalRender({ component: Component.ArticleTitle' quartz.layout.ts
! grep -E -q '^ *Component\.PageTitle\(\),' quartz.layout.ts
grep -q 'introduzione' quartz.layout.ts
[ "$(grep -c 'Component.ArticleTitle' quartz.layout.ts)" -eq 2 ]  # content layout (filtrato) + list layout
[ "$(grep -c 'Component.CategoriesAndTags()' quartz.layout.ts)" -eq 2 ]  # right di entrambi i layout
grep -q 'export { default as CategoriesAndTags' quartz/components/index.ts || grep -q '^  CategoriesAndTags,$' quartz/components/index.ts
grep -q 'Massimiliano Farnea' quartz/components/Footer.tsx
! grep -q 'Discord Community' quartz.layout.ts
echo "patch-quartz: ok ($(basename "$Q"))"
