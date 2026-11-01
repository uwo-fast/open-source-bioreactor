#!/usr/bin/env bash
#
# Export the bench's printed parts - what stands beside the reactor rather than in it - as STLs
# with a print list, to $1/accessories (output/ unless given). The list is
# accessory_print_parts() in scad/support/accessories.scad; each part renders from its own file
# and is judged as export-parts judges the reactor's.
: "${OPENSCAD:=openscad}"
: "${JOBS:=$(nproc)}"
: "${SEAM_CEILING:=10}" # as export-parts.sh, which says why

# A failing render still exits 0 and writes a small file, so nothing here may be gated on $?.
set -uo pipefail
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
export OPENSCAD JOBS SEAM_CEILING tmp

# shellcheck source=scripts/export-lib.sh
source "$(dirname "$0")/export-lib.sh"
failed=0

printf 'include <%s/scad/support/accessories.scad>\nfor (p = accessory_print_parts()) echo(str("PART|", p[0], "|", p[1], "|", p[2], "|", p[3]));\n' \
    "$PWD" > "$tmp/m.scad"
"$OPENSCAD" -o "$tmp/m.csg" "$tmp/m.scad" 2>"$tmp/m.err" >/dev/null
rows=$(grep '^ECHO: "PART|' "$tmp/m.err" | sed 's/^ECHO: "PART|//; s/"$//; s/\\"/"/g')
if [ -z "$rows" ]; then
    echo "FAIL  accessory_print_parts() lists nothing"
    grep -m1 '^ERROR' "$tmp/m.err" | sed 's/^/        /'
    exit 1
fi

dir="${1:-output}/accessories"
mkdir -p "$dir"
: > "$tmp/rows.md"; : > "$tmp/sizes"
pieces=0
parts=0
while IFS='|' read -r file name _ flags; do
    [ -n "$name" ] && printf '|%s|%s|%s|%s\n' "$file" "$flags" "$dir/$name.stl" "$tmp/$name.err"
done <<< "$rows" > "$tmp/jobs"
export_render "$tmp/jobs"
while IFS='|' read -r _ name qty _; do
    [ -z "$name" ] && continue
    parts=$((parts + 1))
    pieces=$((pieces + qty))
    export_judge "$name" "$qty" "$dir/$name.stl" "$tmp/rows.md" "$tmp/sizes" "$tmp/$name.err"
done <<< "$rows"

allfit=$(export_fits "$tmp/sizes" "" "$tmp/nofit")
while read -r m; do
    [ -n "$m" ] && { echo "FAIL  $m  fits no registered printer at all - see scad/purchased/printers.scad"; failed=1; }
done < "$tmp/nofit"
[ -n "$allfit" ] && echo "ok    every exported part fits: $allfit"

{ echo "# Print list — accessories"
  echo
  echo "$pieces pieces, $parts distinct parts: the bench around one reactor, not the reactor itself,"
  echo "whose list is \`just export-parts\`. Written by \`just export-accessories\` from"
  echo "\`accessory_print_parts()\` in [scad/support/accessories.scad](../../scad/support/accessories.scad);"
  echo "regenerate rather than editing."
  echo
  echo "**Printers that take every part on this list:** $allfit."
  echo
  echo '| part | qty | file | size, mm | triangles |'
  echo '| --- | --- | --- | --- | --- |'
  cat "$tmp/rows.md"
} > "$dir/print-list.md"

echo "ok    $dir/print-list.md  ($pieces pieces, $parts parts)"
exit $failed
