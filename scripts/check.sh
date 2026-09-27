#!/usr/bin/env bash
# Renders every template (or the ones named) against every sample CV and
# checks the rules in CONTRIBUTING.md. Previews land in previews/<template>/.
#
#   scripts/check.sh                  # all templates
#   scripts/check.sh my-template      # just one
#
# Env: TYPST (default: typst), FONT_PATH (extra fonts dir, e.g. Font Awesome).
set -euo pipefail
cd "$(dirname "$0")/.."

TYPST="${TYPST:-typst}"
FONT_ARGS=()
[ -n "${FONT_PATH:-}" ] && FONT_ARGS=(--font-path "$FONT_PATH")

# Packages a template may import. Anything else fails the check: every
# package runs on IdealJob's servers, so each one gets reviewed first.
ALLOWED_PACKAGES=(
  "@preview/modern-cv:0.10.0"
  "@preview/fontawesome:0.6.0"
)
MAX_PAGES=3
MAX_SECONDS=10

if [ $# -gt 0 ]; then templates=("$@"); else templates=($(ls templates)); fi
samples=($(ls samples/*.json | xargs -n1 basename | sed 's/\.json$//'))
failed=0

fail() { echo "  ✗ $1"; failed=1; }

for t in "${templates[@]}"; do
  dir="templates/$t"
  echo "▸ $t"

  [ -f "$dir/template.typ" ] || { fail "missing $dir/template.typ"; continue; }
  [ -f "$dir/meta.json" ] || fail "missing $dir/meta.json"

  if [ -f "$dir/meta.json" ]; then
    python3 - "$dir/meta.json" "$t" <<'PY' || failed=1
import json, sys
path, slug = sys.argv[1], sys.argv[2]
meta = json.load(open(path))
errors = []
for key in ("id", "name", "author", "version", "description", "paper", "photo"):
    if key not in meta: errors.append(f"meta.json is missing \"{key}\"")
if meta.get("id") != slug: errors.append(f"meta.json id must be \"{slug}\" (the folder name)")
if meta.get("paper") not in ("a4", "us-letter"): errors.append("paper must be \"a4\" or \"us-letter\"")
for e in errors: print(f"  ✗ {e}")
sys.exit(1 if errors else 0)
PY
  fi

  size_kb=$(du -sk "$dir" | cut -f1)
  [ "$size_kb" -gt 2048 ] && fail "folder is ${size_kb} KB (max 2 MB)"

  # Only the library, files inside the template folder and allowed packages.
  while read -r import; do
    case "$import" in
      '"/lib/idealjob.typ"') ;;
      \"@*)
        pkg="${import//\"/}"
        printf '%s\n' "${ALLOWED_PACKAGES[@]}" | grep -qxF "$pkg" || fail "package $pkg isn't on the allow list (see CONTRIBUTING.md)"
        ;;
      \"/*) fail "import $import reaches outside the template folder" ;;
      *) [[ "$import" == *..* ]] && fail "import $import reaches outside the template folder" ;;
    esac
  done < <(grep -ohE '#?(import|include) +"[^"]+"' "$dir"/*.typ | grep -oE '"[^"]+"')

  if grep -nE '(read|json|yaml|toml|csv|xml|cbor|image|plugin)\( *"(/|\.\.)' "$dir"/*.typ | grep -v '"/lib/' ; then
    fail "reads a file outside the template folder (use the cv data instead)"
  fi
  grep -nE 'sys\.inputs' "$dir"/*.typ >/dev/null && fail "reads sys.inputs directly (use load-cv())"
  grep -nE '\bplugin\(' "$dir"/*.typ >/dev/null && fail "WebAssembly plugins aren't allowed"

  mkdir -p "previews/$t"
  rm -f "previews/$t"/*.png
  for s in "${samples[@]}"; do
    start=$(date +%s)
    if ! out=$("$TYPST" compile --root . "${FONT_ARGS[@]}" --input "cv=/samples/$s.json" \
        --ppi 80 "$dir/template.typ" "previews/$t/$s-{p}.png" 2>&1); then
      fail "$s: failed to render"; echo "$out" | sed 's/^/      /'; continue
    fi
    secs=$(( $(date +%s) - start ))
    pages=$(ls "previews/$t/$s"-*.png | wc -l)
    [ "$secs" -gt "$MAX_SECONDS" ] && fail "$s: took ${secs}s (max ${MAX_SECONDS}s)"
    if [ "$s" != "many-roles" ] && [ "$pages" -gt "$MAX_PAGES" ]; then fail "$s: $pages pages (max $MAX_PAGES)"; fi
    echo "  ✓ $s ($pages page$([ "$pages" = 1 ] || echo s), ${secs}s)"
  done
done

exit $failed
