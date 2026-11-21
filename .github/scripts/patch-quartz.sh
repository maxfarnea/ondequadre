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
perl -0pi -e 's#\QComponent.Explorer(),\E#Component.ConditionalRender({ component: Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug !== "index" \&\& !f.slug?.endsWith(".en") }), condition: (page) => !(page.fileData.slug ?? "").endsWith(".en") }), Component.ConditionalRender({ component: Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug?.endsWith(".en") \&\& f.slug !== "index.en" }), condition: (page) => (page.fileData.slug ?? "").endsWith(".en") }),#g' \
  quartz.layout.ts

# 3. Pagina indice: niente titolo/data/tag duplicati al centro (restano in sidebar)
perl -0pi -e 's#^    Component\.ArticleTitle\(\),\n    Component\.ContentMeta\(\),\n    Component\.TagList\(\),$#    Component.ConditionalRender({ component: Component.ArticleTitle(), condition: (page) => page.fileData.slug !== "index" \&\& page.fileData.slug !== "index.en" }),\n    Component.ConditionalRender({ component: Component.ContentMeta(), condition: (page) => page.fileData.slug !== "index" \&\& page.fileData.slug !== "index.en" }),\n    Component.ConditionalRender({ component: Component.TagList(), condition: (page) => page.fileData.slug !== "index" \&\& page.fileData.slug !== "index.en" }),#m' \
  quartz.layout.ts

# --- Controprove: fallisce loud se una patch non ha preso --------------------
grep -q 'pageTitle: "Onde Quadre"' quartz.config.ts
grep -q 'locale: "it-IT"' quartz.config.ts
! grep -q 'Component.Graph' quartz.layout.ts
! grep -q 'Component.Explorer' quartz.layout.ts
grep -q 'ConditionalRender({ component: Component.ArticleTitle' quartz.layout.ts
[ "$(grep -c 'Component.ArticleTitle' quartz.layout.ts)" -eq 2 ]  # content layout (filtrato) + list layout
[ "$(grep -c 'Component.CategoriesAndTags()' quartz.layout.ts)" -eq 2 ]  # right di entrambi i layout
grep -q 'export { default as CategoriesAndTags' quartz/components/index.ts || grep -q '^  CategoriesAndTags,$' quartz/components/index.ts
echo "patch-quartz: ok ($(basename "$Q"))"
