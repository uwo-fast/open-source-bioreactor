#!/usr/bin/env bash
#
# Build every column lid variant to output/column_lid/<variant>.stl, and fail on any that does not.
# The repo's checks skip scad/_spikes/, so this is the spike's check as well as its export.
#
# A failing render still exits 0, so stderr is the signal: an ERROR, or a WARNING, which is where
# OpenSCAD says a solid is not a 2-manifold; and a file that is not there or is empty.
set -uo pipefail
: "${OPENSCAD:=openscad}"
: "${OUT:=output/column_lid}"
src=scad/_spikes/column_lid/column_lid.scad
variants="npt centre ring"
mkdir -p "$OUT"
failed=0
for v in $variants; do
    "$OPENSCAD" -D "variant=\"$v\"" -o "$OUT/$v.stl" "$src" 2>"$OUT/$v.err" >/dev/null &
done
wait
for v in $variants; do
    if grep -qE '^(ERROR|WARNING)' "$OUT/$v.err"; then
        echo "FAIL  $v  $(grep -m1 -E '^(ERROR|WARNING)' "$OUT/$v.err")"
        failed=1
    elif [ ! -s "$OUT/$v.stl" ]; then
        echo "FAIL  $v  wrote no STL; see $OUT/$v.err"
        failed=1
    else
        echo "ok    $v  $OUT/$v.stl  $(sed -n 's/^ECHO: "column lid: [a-z]*; //p' "$OUT/$v.err" | sed 's/"$//' | sed 's/.*mm bore; //')"
        rm -f "$OUT/$v.err"
    fi
done
exit $failed
