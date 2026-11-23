#!/usr/bin/env bash
# Applica a Quartz le personalizzazioni del sito. Unico punto di verita':
# chiamato sia da .github/scripts/preview.sh sia dal workflow di deploy.
#
#   patch-quartz.sh <dir-di-quartz>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
Q="${1:?usage: patch-quartz.sh <quartz-dir>}"
cd "$Q"

if python3 -c '' 2>/dev/null; then PYBIN=python3; else PYBIN=python; fi

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
# La mappa slug -> etichetta e' cavata dal file dati categories.txt
# (unica fonte, condivisa con generate_index.py)
"$PYBIN" - "$SCRIPT_DIR/categories.txt" quartz/components/CategoriesAndTags.tsx <<'PYEOF'
import re
import sys
from pathlib import Path

entries = []
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if not line or line.startswith("#") or ":" not in line:
        continue
    slug, label = line.split(":", 1)
    entries.append(f'  {slug.strip()}: "{label.strip()}",')

block = "const CATEGORY_LABELS: Record<string, string> = {\n" + "\n".join(entries) + "\n}"
src = Path(sys.argv[2])
txt = src.read_text(encoding="utf-8")
_PAT = r"const CATEGORY_LABELS: Record<string, string> = \{.*?\n\}"
m = re.search(_PAT, txt, flags=re.S)
assert m, "patch-quartz: mappa CATEGORY_LABELS in CategoriesAndTags.tsx non trovata"
src.write_text(txt[:m.start()] + block + txt[m.end():], encoding="utf-8")
print("patch-quartz: categorie caricate da categories.txt")
PYEOF
if ! grep -q 'CategoriesAndTags' quartz/components/index.ts; then
  sed -i 's|import TagList from "./TagList"|import TagList from "./TagList"\nimport CategoriesAndTags from "./CategoriesAndTags"|' quartz/components/index.ts
  sed -i 's|^  TagList,$|  TagList,\n  CategoriesAndTags,|' quartz/components/index.ts
fi
perl -0pi -e 's#  right: \[\],#  right: [Component.CategoriesAndTags()],#g' quartz.layout.ts

# 2. Sidebar: post recenti (senza home e introduzione) al posto dell'albero file
perl -0pi -e 's#\QComponent.Explorer(),\E#Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug !== "index" \&\& f.slug !== "introduzione" }),#g' \
  quartz.layout.ts

# 3. Pagina indice: niente titolo/data/tag al centro (la home e' solo
#    introduzione + separatore + card, generata da generate_index.py)
perl -0pi -e 's#^    Component\.ArticleTitle\(\),\n    Component\.ContentMeta\(\),\n    Component\.TagList\(\),$#    Component.ConditionalRender({ component: Component.ArticleTitle(), condition: (page) => page.fileData.slug !== "index" }),\n    Component.ConditionalRender({ component: Component.ContentMeta(), condition: (page) => page.fileData.slug !== "index" }),\n    Component.ConditionalRender({ component: Component.TagList(), condition: (page) => page.fileData.slug !== "index" }),#m' \
  quartz.layout.ts

# 4. Titolo del sito in testa alla colonna sinistra, su tutte le pagine,
#    con la grafia "| ONDE QUADRE |" (patch di PageTitle.tsx)
if ! grep -q '| ONDE QUADRE |' quartz/components/PageTitle.tsx; then
  perl -0pi -e 's#\Q      <a href={baseDir}>{title}</a>\E#      <a href={baseDir}>| ONDE QUADRE |</a>#' \
  quartz/components/PageTitle.tsx
fi

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

# 7. Tema "midnight" (pages-themes/midnight) ricreato su Quartz, per entrambe
#    le modalità (così la toggle tema non ha più effetto visibile -> la togliamo)
"$PYBIN" - <<'PYEOF'
import re
from pathlib import Path

cfg = Path("quartz.config.ts")
text = cfg.read_text(encoding="utf-8")

palette = """      colors: {
        lightMode: {
          light: "#1c1c1c",
          lightgray: "#3a3a3a",
          gray: "#a8a8a8",
          darkgray: "#f0e7d5",
          dark: "#e8e8e8",
          secondary: "#ffcc00",
          tertiary: "#ffeb9b",
          highlight: "rgba(255, 204, 0, 0.12)",
          textHighlight: "#ffcc0055",
        },
        darkMode: {
          light: "#1c1c1c",
          lightgray: "#3a3a3a",
          gray: "#a8a8a8",
          darkgray: "#f0e7d5",
          dark: "#e8e8e8",
          secondary: "#ffcc00",
          tertiary: "#ffeb9b",
          highlight: "rgba(255, 204, 0, 0.12)",
          textHighlight: "#ffcc0055",
        },
      },"""

typography = """      typography: {
        header: "Open Sans",
        body: "Open Sans",
        code: "JetBrains Mono",
      },"""

new = re.sub(r"colors: \{.*?\n      \},", palette, text, count=1, flags=re.S)
assert new != text, "patch-quartz: blocco colors di quartz.config.ts non trovato"
new = re.sub(r"typography: \{.*?\n      \},", typography, new, count=1, flags=re.S)
assert "JetBrains Mono" in new, "patch-quartz: blocco typography non trovato"
cfg.write_text(new, encoding="utf-8")
print("patch-quartz: tema midnight applicato a quartz.config.ts")
PYEOF
perl -0pi -e 's#^ +\{ Component: Component\.Darkmode\(\) \},\n##mg' quartz.layout.ts

# 8. Stili midnight sullo sfondo, la larghezza colonna, hr e blockquote
if ! grep -q 'Tema midnight' quartz/styles/custom.scss; then
cat >> quartz/styles/custom.scss <<'EOF'

// Tema midnight: sfondo sfumato, colonna stretta, hr tratteggiato, blockquote oro
body {
  background: linear-gradient(#2a2a29, #1c1c1c) fixed;
}

.center > article {
  max-width: 700px;
  margin: 0 auto;
}

hr {
  border: 0;
  height: 3px;
  background: transparent;
  background-image: repeating-linear-gradient(90deg, #434343 0 6px, transparent 6px 12px);
}

blockquote {
  border-left: 3px solid #ffcc00;
  font-style: italic;
}
EOF
fi

# 8b. Regole mobile (guard separato dal tema: su copie gia' patchate il tema
#     c'e' gia' e altrimenti blocco mobile non verrebbe mai aggiunto)
if ! grep -q -e '---- Mobile ----' quartz/styles/custom.scss; then
cat >> quartz/styles/custom.scss <<'EOF'

// ---- Mobile ----
@media all and (max-width: 800px) {
  // 1. Sidebar sinistra: via del tutto. Serve la stessa catena di selettori di base.scss
  //    (.page > #quartz-body .sidebar, con l'id): un ".sidebar.left" semplice
  //    perde su specificita' e il display:flex nativo resta attivo.
  //    La destra (categorie+tag) resta visibile: la grid mobile di Quartz
  //    la mette da sola in fondo alla pagina.
  .page > #quartz-body .sidebar.left {
    display: none !important;
  }

  // 2. Il contenitore grid di Quartz diventa una colonna flex con ordine
  //    esplicito: contenuto, poi sidebar destra (nuvola tag), poi footer del
  //    sito per ultimo. Con display:block l'ordine dipende dal DOM e il
  //    footer rischia di finire in mezzo alla nuvola.
  .page > #quartz-body {
    display: flex;
    flex-direction: column;
    padding: 1rem 0.8rem 0;
  }

  .page > #quartz-body .center {
    order: 1;
  }

  .page > #quartz-body .sidebar.right {
    order: 2;
  }

  // 3. La riga nativa .sidebar.right > * { max-height: 24rem } tronca la
  //    nuvola tag: i tag oltre i 24rem sbordano sotto il box e il footer
  //    (che inizia esattamente dove finisce il box) li copre. Senza limite
  //    il box cresce con il contenuto e il footer sta sotto, davvero.
  .page > #quartz-body .sidebar.right > * {
    max-height: none;
  }

  .page > #quartz-body footer {
    order: 3;
  }

  // 4. Colonna centrale full width
  .page > #quartz-body .center,
  .page > #quartz-body .center > article {
    max-width: 100%;
    padding: 0;
  }

  // 5. Uccide l'overflow orizzontale che rompeva le media query
  html,
  body {
    overflow-x: hidden;
  }

  article {
    min-width: 0;
    overflow-wrap: break-word;
  }

  // 6. Sfondo: il gradient "fixed" perde la copertura su mobile
  body {
    background: #1c1c1c; // tinta piatta, stesso grigio scuro
  }

  // 7. Card: restano una sotto l'altra (come le vedi ora, che ti piacciono)
  //    ma con thumbnail un po' meno monolitiche
  a.post-card .post-card-thumb {
    aspect-ratio: 16 / 9;
    max-height: 240px;
  }

  // 8. Separatore sopra la nuvola categorie/tag: la somma dei margini nativi
  //    (hr 2rem + .categories-and-tags 2rem in cima) distaccava troppo
  //    il blocco Categorie dal separatore, mentre il blocco Tag gli sta
  //    attaccato (hr interno: 1rem). Ristretti per uniformare:
  //    "> hr" tocca solo il separatore di colonna, non quelli nei post.
  .page > #quartz-body .center > hr {
    margin: 1rem auto;
  }

  .page > #quartz-body .sidebar.right > .categories-and-tags {
    margin-top: 0.5rem;
  }
}
EOF
fi

# --- Controprove: fallisce loud se una patch non ha preso --------------------
grep -q 'pageTitle: "Onde Quadre"' quartz.config.ts
grep -q 'locale: "it-IT"' quartz.config.ts
! grep -q 'Component.Graph' quartz.layout.ts
! grep -q 'Component.Explorer' quartz.layout.ts
grep -q 'ConditionalRender({ component: Component.ArticleTitle' quartz.layout.ts
grep -E -q '^ *Component\.PageTitle\(\),' quartz.layout.ts && ! grep -q 'component: Component.PageTitle()' quartz.layout.ts
grep -q '| ONDE QUADRE |' quartz/components/PageTitle.tsx
grep -q 'introduzione' quartz.layout.ts
[ "$(grep -c 'Component.ArticleTitle' quartz.layout.ts)" -eq 2 ]  # content layout (filtrato) + list layout
[ "$(grep -c 'Component.CategoriesAndTags()' quartz.layout.ts)" -eq 2 ]  # right di entrambi i layout
grep -q 'export { default as CategoriesAndTags' quartz/components/index.ts || grep -q '^  CategoriesAndTags,$' quartz/components/index.ts
grep -q 'Chi sono' quartz/components/CategoriesAndTags.tsx
grep -q 'Massimiliano Farnea' quartz/components/Footer.tsx
! grep -q 'Discord Community' quartz.layout.ts
grep -q '#ffcc00' quartz.config.ts
! grep -q 'Component.Darkmode' quartz.layout.ts
grep -q -e '---- Mobile ----' quartz/styles/custom.scss
grep -q -e '.page > #quartz-body .sidebar.left' quartz/styles/custom.scss
grep -q 'max-width: 800px' quartz/styles/custom.scss
echo "patch-quartz: ok ($(basename "$Q"))"
