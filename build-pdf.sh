#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${ROOT_DIR}/tmp"
VER="$(grep -oP 'Ver\.\d+\.\d+\.\d+' "${ROOT_DIR}/config-pdf.yaml" | head -1 | sed 's/^Ver\.//')"
OUTPUT_PDF="${OUT_DIR}/admintext_${VER}.pdf"
OUTPUT_NO_COVER="${OUT_DIR}/admintext_${VER}_no_cover.pdf"

if ! command -v pandoc >/dev/null 2>&1 || ! command -v lualatex >/dev/null 2>&1; then
  exec "${ROOT_DIR}/scripts/with-build-image.sh" "./build-pdf.sh"
fi

mkdir -p "${OUT_DIR}"

chapters=()
while IFS= read -r -d '' f; do
  chapters+=("$(basename "${f}")")
done < <(find "${ROOT_DIR}" -maxdepth 1 -type f -name 'Chapter*.md' ! -name 'Chapter00.md' -print0 | LC_ALL=C sort -z)

if ((${#chapters[@]} == 0)); then
  echo "no chapter markdown files found" >&2
  exit 1
fi

(
  cd "${ROOT_DIR}"
  pandoc Chapter00.md -o preface.tex
  pandoc -d config-pdf.yaml --template template.tex -B preface.tex "${chapters[@]}" \
    -o "${OUTPUT_PDF}"
  pandoc -d config-pdf.yaml --template template.tex -B preface.tex "${chapters[@]}" \
    -M no-cover=true -o "${OUTPUT_NO_COVER}"
  rm -f preface.tex
)

echo "Output: ${OUTPUT_PDF}"
echo "Output: ${OUTPUT_NO_COVER}"
ls -lh "${OUTPUT_PDF}" "${OUTPUT_NO_COVER}"
