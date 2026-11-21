#!/usr/bin/env bash
# Preview locale del sito, replicando i passi del workflow quartz-deploy.
#
#   .github/scripts/preview.sh            build singola -> .preview/quartz/public
#   .preview/quartz/public  (output)
#   .github/scripts/preview.sh --serve    dev server con hot-reload su :8080
#
# La prima esecuzione scarica Quartz v4.5.2 e le dipendenze (~1-2 minuti);
# le successive riusano la copia in .preview/.
set -euo pipefail
cd "$(dirname "$0")/../.."

QDIR=.preview/quartz
PORTABLE=.preview/node-v22.14.0-win-x64
QTAG=v4.5.2

# --- Node >= 22 (richiesto da Quartz) --------------------------------------
node_ok() {
  command -v node >/dev/null 2>&1 &&
    [ "$(node -p 'parseInt(process.versions.node)')" -ge 22 ]
}

if node_ok; then
  :
elif [ -x "$PORTABLE/node.exe" ]; then
  export PATH="$PWD/$PORTABLE:$PATH"
elif command -v curl >/dev/null 2>&1; then
  echo "Scarico Node 22 portabile in $PORTABLE ..."
  mkdir -p .preview "$(dirname "$PORTABLE")"
  curl -sL -o .preview/node.zip https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip
  python -c "import zipfile; zipfile.ZipFile('.preview/node.zip').extractall('.preview')"
  export PATH="$PWD/$PORTABLE:$PATH"
else
  echo "Serve Node >= 22: installalo o prova con curl disponibile." >&2
  exit 1
fi
echo "node: $(node --version), npm: $(npm --version)"

# --- Checkout Quartz (una volta sola) --------------------------------------
if [ ! -d "$QDIR" ]; then
  git clone --depth 1 --branch "$QTAG" https://github.com/jackyzha0/quartz.git "$QDIR"
  (cd "$QDIR" && npm ci)
fi

# --- Content: il vault con le stesse esclusioni del deploy ------------------
rm -rf "$QDIR/content"
python - "$QDIR/content" <<'EOF'
import shutil, sys
shutil.copytree(".", sys.argv[1], ignore=shutil.ignore_patterns(
    ".git", ".github", ".obsidian", ".preview",
    "obsidian-config.md", "how-to.md", "brief.md", "to-do.md"))
EOF

python .github/scripts/generate_index.py "$QDIR/content"

# --- Patch identiche alla CI -------------------------------------------------
cd "$QDIR"
sed -i 's|pageTitle: .*|pageTitle: "Onde Quadre",|' quartz.config.ts
sed -i 's|locale: .*|locale: "it-IT",|' quartz.config.ts
sed -i 's|baseUrl: .*|baseUrl: "maxfarnea.github.io",|' quartz.config.ts
sed -i 's|markdownLinkResolution: "absolute"|markdownLinkResolution: "shortest"|' quartz.config.ts

perl -0pi -e 's#\QComponent.Explorer(),\E#Component.ConditionalRender({ component: Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug !== "index" \&\& !f.slug?.endsWith(".en") }), condition: (page) => !(page.fileData.slug ?? "").endsWith(".en") }), Component.ConditionalRender({ component: Component.RecentNotes({ limit: 6, showTags: false, filter: (f) => f.slug?.endsWith(".en") \&\& f.slug !== "index.en" }), condition: (page) => (page.fileData.slug ?? "").endsWith(".en") }),#g' \
  quartz.layout.ts

# --- Build / serve ------------------------------------------------------------
if [ "${1:-}" = "--serve" ]; then
  shift
  exec npx quartz build --serve "$@"
else
  npx quartz build "$@"
  echo ""
  echo "Output in $PWD/public  --  per l'hot-reload: .github/scripts/preview.sh --serve"
fi
