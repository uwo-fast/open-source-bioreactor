#!/usr/bin/env bash
#
# Fail when the turbidity sampler stops fitting the board, the clear tube, a driver or its screws.
#
# tests/sampler/fit.scad draws each fit as the material that should not exist, so it passes only
# by rendering EMPTY, and OpenSCAD writes no file then. Under `just test`: about 40 s on CGAL.
set -uo pipefail
: "${OPENSCAD:=openscad}"
# "Nothing rendered" is also what a binary that renders nothing says.
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
"$OPENSCAD" -o "$tmp/fit.stl" tests/sampler/fit.scad 2>"$tmp/err" >/dev/null
if grep -qE '^(ERROR|WARNING)|Assertion' "$tmp/err"; then
    echo "FAIL  sampler fits did not render"; grep -m3 -E '^(ERROR|WARNING)|Assertion' "$tmp/err" | sed 's/^/        /'; exit 1
elif [ -f "$tmp/fit.stl" ]; then
    echo "FAIL  sampler fits: something stands where it must not; render tests/sampler/fit.scad to see it"; exit 1
fi
echo "ok    sampler fits the board, the clear tube, the driver and its screws"
