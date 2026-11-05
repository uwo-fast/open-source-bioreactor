#!/usr/bin/env bash
#
# Build every column lid to output/column_lid/<name>.stl, turned as it prints, and fail on any
# that does not. The repo's checks skip scad/_spikes/, so this is the spike's check as well as its
# export.
#
# A failing render still exits 0, so stderr is the signal: an ERROR, or a WARNING, which is where
# OpenSCAD says a solid is not a 2-manifold; and a file that is not there or is empty.
set -uo pipefail
: "${OPENSCAD:=openscad}"
: "${OUT:=output/column_lid}"
src=scad/_spikes/column_lid/column_lid.scad
mkdir -p "$OUT"

# One lid: its name, then the settings that make it.
build() {
    local name=$1
    shift
    "$OPENSCAD" "$@" -D 'part="print"' -o "$OUT/$name.stl" "$src" 2>"$OUT/$name.err" >/dev/null
}
build npt -D 'variant="npt"' &
build centre -D 'variant="centre"' &
build ring -D 'variant="ring"' &
build centre_pocket -D 'variant="centre"' -D pocket_depth=100 &
wait

failed=0
for name in npt centre ring centre_pocket; do
    if grep -qE '^(ERROR|WARNING)' "$OUT/$name.err"; then
        echo "FAIL  $name  $(grep -m1 -E '^(ERROR|WARNING)' "$OUT/$name.err")"
        failed=1
    elif [ ! -s "$OUT/$name.stl" ]; then
        echo "FAIL  $name  wrote no STL; see $OUT/$name.err"
        failed=1
    else
        echo "ok    $name  $OUT/$name.stl  $(sed -n 's/^ECHO: "column lid: [a-z]*; //p' "$OUT/$name.err" | sed 's/"$//; s/.*mm holes on [0-9.]* mm; //')"
        rm -f "$OUT/$name.err"
    fi
done
exit $failed
