#!/usr/bin/env bash
# Preview locale del sito, replicando i passi del workflow quartz-deploy.
#
#   .github/scripts/preview.sh            build singola -> <workspace>/quartz/public
#   <workspace>/quartz/public  (output)
#   .github/scripts/preview.sh --serve    dev server con hot-reload su :8080
#
# La workspace (Node portabile + clone Quartz) sta fuori dal repo, di default
# in %LOCALAPPDATA%/ondequadre-preview: D:\archive e' sincronizzato con
# Proton Drive, che vedendo la workspace cancellata/rifatta ad ogni build
# genera copie "# Name clash #" e "# Delete conflict #". Per ricollocarla:
#   ONDEQUADRE_PREVIEW_DIR=/percorso .github/scripts/preview.sh
#
# La prima esecuzione scarica Quartz v4.5.2 e le dipendenze (~1-2 minuti);
# le successive riusano la copia nella workspace.
set -euo pipefail
cd "$(dirname "$0")/../.."

WSROOT="${ONDEQUADRE_PREVIEW_DIR:-${LOCALAPPDATA:-$HOME/AppData/Local}/ondequadre-preview}"
command -v cygpath >/dev/null 2>&1 && WSROOT="$(cygpath -u "$WSROOT")"
QDIR="$WSROOT/quartz"
PORTABLE="$WSROOT/node-v22.14.0-win-x64"
QTAG=v4.5.2

# --- Node >= 22 (richiesto da Quartz) --------------------------------------
node_ok() {
  command -v node >/dev/null 2>&1 &&
    [ "$(node -p 'parseInt(process.versions.node)')" -ge 22 ]
}

if node_ok; then
  :
elif [ -x "$PORTABLE/node.exe" ]; then
  export PATH="$PORTABLE:$PATH"
elif command -v curl >/dev/null 2>&1; then
  echo "Scarico Node 22 portabile in $PORTABLE ..."
  mkdir -p "$WSROOT"
  curl -sL -o "$WSROOT/node.zip" https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip
  python - "$WSROOT/node.zip" "$WSROOT" <<'EOF'
import sys, zipfile
zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])
EOF
  export PATH="$PORTABLE:$PATH"
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
bash .github/scripts/patch-quartz.sh "$QDIR"
cd "$QDIR"

# --- Build / serve ------------------------------------------------------------
if [ "${1:-}" = "--serve" ]; then
  shift
  exec npx quartz build --serve "$@"
else
  npx quartz build "$@"
  echo ""
  echo "Output in $PWD/public  --  per l'hot-reload: .github/scripts/preview.sh --serve"
fi
