#!/usr/bin/env bash
#
# Fail when the sampler's parts stop fitting what goes in them, or grow a wall thinner than its
# min_wall.
#
# tests/sampler/fit.scad draws each fit as the material that should not exist - the board inside a
# part, a screw inside its hole, a part standing proud of its own outline - so every check passes
# only when it renders EMPTY. tests/sampler/thin_sweep.py slices both parts every 0.2 mm and keeps
# whatever an erode-and-grow by half of min_wall does not give back.
#
# Not in `just test`: ~410 slices and a minkowski sweep are minutes on the Manifold backend and far
# longer on CGAL, which is all the OpenSCAD CI installs has. Without Manifold it refuses to run
# rather than pass.
set -uo pipefail

: "${OPENSCAD:=openscad}"
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
if ! "$OPENSCAD" --help 2>&1 | grep -q -- '--backend'; then
    echo "FAIL  $("$OPENSCAD" --version 2>&1 | tail -1) has no --backend; the sampler checks need Manifold"
    exit 1
fi

here="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
failed=0
# The two prints, as they lie on the bed: each has to build, and build to something.
for p in base top; do
    "$OPENSCAD" --backend=manifold -D "part=\"$p\"" -o "$tmp/$p.stl" "$here/scad/custom/sampler.scad" 2>"$tmp/$p.err"
    if grep -qE 'ERROR|WARNING|Assertion' "$tmp/$p.err"; then
        echo "FAIL  $p: $(grep -m1 -E 'ERROR|WARNING|Assertion' "$tmp/$p.err")"
        failed=1
    elif [ ! -s "$tmp/$p.stl" ]; then
        echo "FAIL  $p: exported nothing"
        failed=1
    else
        echo "ok    $p exports"
    fi
done
for c in walls board flange tube cover insert proud key bolts; do
    # OpenSCAD writes no file for an empty result, so each check gets a file of its own, and an
    # ERROR, WARNING or failed assert is a failure, never an empty result.
    "$OPENSCAD" --backend=manifold -D "check=\"$c\"" -o "$tmp/$c.stl" "$here/tests/sampler/fit.scad" 2>"$tmp/$c.err"
    if grep -qE 'ERROR|WARNING|Assertion' "$tmp/$c.err"; then
        echo "FAIL  $c: $(grep -m1 -E 'ERROR|WARNING|Assertion' "$tmp/$c.err")"
        failed=1
    elif [ -f "$tmp/$c.stl" ]; then
        echo "FAIL  $c: not empty"
        failed=1
    else
        echo "ok    $c"
    fi
done
python3 "$here/tests/sampler/thin_sweep.py" "$OPENSCAD --backend=manifold" "$tmp" || failed=1
exit $failed
