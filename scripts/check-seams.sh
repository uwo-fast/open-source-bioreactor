#!/usr/bin/env bash
#
# Pin the seams the model cannot close. Every part of every build that renders is exported and its
# mesh measured; a part that does not close is recorded as "<build> <part> <over> <dup>". `--update`
# rewrites the file instead of diffing it.
#
# An open edge is never pinned here. A hole is always this project's own problem, and
# export-parts.sh fails on one whatever this file says.
set -uo pipefail

: "${SEAMS:=tests/seams.txt}"
update=0
[ "${1:-}" = "--update" ] && update=1

tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
seen="$tmp/seen"
: > "$seen"

builds=$(/usr/bin/python3 -c 'import json;print("\n".join(json.load(open("scad/bioreactor.json"))["parameterSets"]))')
[ -n "$builds" ] || { echo "FAIL  could not read the parameter sets"; exit 1; }

built=0 skipped=0
while read -r b; do
    [ -z "$b" ] && continue
    # A build that cannot render is a vessel this model does not carry; check-echo pins those and
    # they are not this file's business.
    if SEAMS_SEEN="$seen" SEAMS=/dev/null scripts/export-parts.sh "$b" "$tmp/out" >"$tmp/log.$b" 2>&1; then
        built=$((built + 1))
    elif grep -q 'did not build' "$tmp/log.$b"; then
        skipped=$((skipped + 1))
        printf 'skip  %-22s a part of this build does not render; see just check-echo\n' "$b"
    else
        built=$((built + 1))
    fi
done <<< "$builds"

sort -o "$seen" "$seen"

{
    echo "# Seams the renderer leaves that this project cannot close, measured, not written by hand."
    echo "# One line per part that does not close: <build> <part> <over> <dup>, where over is edges"
    echo "# shared by more than two faces and dup is triangles that repeat. Both are zero-volume:"
    echo "# the surface is still closed, and a slicer drops them."
    echo "#"
    echo "# Rewrite with \`just check-seams-update\`, and read the diff before keeping it."
    echo "#"
    echo "# All of these are one shape of defect - two solids meeting exactly face to face, so the"
    echo "# renderer keeps the shared face instead of merging it, and what is left comes from the"
    echo "# probe port's transition meeting the collet. TODO.md carries why the obvious overlap"
    echo "# there costs material."
    cat "$seen"
} > "$tmp/new"

if [ "$update" = 1 ]; then
    mkdir -p "$(dirname "$SEAMS")"
    cp "$tmp/new" "$SEAMS"
    echo "wrote $SEAMS  ($(grep -vc '^#' "$SEAMS") pinned, $built builds rendered, $skipped skipped)"
    exit 0
fi

if [ ! -f "$SEAMS" ]; then
    echo "FAIL  no $SEAMS; run \`just check-seams-update\`"
    exit 1
fi
if diff -q "$SEAMS" "$tmp/new" >/dev/null; then
    echo "ok    $SEAMS  ($(grep -vc '^#' "$SEAMS") pinned, $built builds rendered, $skipped skipped)"
    exit 0
fi
echo "FAIL  the seams moved:"
diff "$SEAMS" "$tmp/new" | sed 's/^/        /'
exit 1
