#!/usr/bin/env bash
#
# Fail when a gas hole the model declares does not actually break through.
#
: "${OPENSCAD:=openscad}"
: "${ENTRY:?the justfile exports the list of files that render on their own}"

# $1 one file to probe, empty for all of $ENTRY; $2 the render flags.

# THE FAILURE THIS EXISTS FOR. Every hole on the tube sparger was once cut a quarter of a
# millimetre short - the section is a polygon quoted across FLATS and its material reaches
# across CORNERS - so all twenty ended blind. Nothing caught it. The part rendered, it was a
# clean 2-manifold, `check-mesh` passed it, and every render looked right because a 1.2 mm hole
# is under a pixel when you photograph a 180 mm ring. A blind hole is a perfectly good solid.
#
# So this is not a mesh check. The MODEL states a claim - "if this hole opened, this point is
# void" - by echoing HOLEPROBE lines, and this tests the claim against the built mesh. The probe
# is derived from the same functions that cut the hole, so it cannot drift away from it.
#
# RENDERED IN THE CONFIGURATION THAT MAKES THE PART, not the one that makes the picture -
# the same lesson 011fea7 wrote into check-mesh. head.scad at its defaults draws the whole lid
# with its seals, probes and bearing, which check-parts has already declared are not printed and
# which make it a non-2-manifold; a point-in-solid test against that mesh answers nothing. The
# default flags below are what the print manifest exports the sparger with.
#
# A file that emits no HOLEPROBE is not a failure, it is a file with nothing to say.
#
# NOT IN `just check`, for the same reason check-mesh is not: it needs a CGAL render, and
# head.scad alone is minutes. It is in that recipe's cost class and belongs beside it. The cheap
# coverage is custom/sparger.scad on its own, which exercises the same cut through the same
# functions in seconds - run this against head.scad before a print, not on every edit.
set -uo pipefail
targets="${1:-}"
[ -n "$targets" ] || targets="$ENTRY"
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
failed=0
checked=0
for f in $targets; do
    "$OPENSCAD" ${2:-} -D sparge_hole_probes=true --export-format binstl \
        -o "$tmp/p.stl" "$f" 2>"$tmp/err" >/dev/null
    # A file that does not RENDER has not passed, it has not been tested. Without this a part
    # whose assert fires reads as "nothing to say" and the recipe reports ok on a file that
    # produced no geometry at all - which is how a stale fire-test came back green.
    if grep -q '^ERROR' "$tmp/err"; then
        echo "FAIL  $f  does not render, so its holes cannot be checked"
        grep -m1 '^ERROR' "$tmp/err" | sed 's/.*failed: //; s/ in file.*//' | sed 's/^/        /'
        failed=1
        continue
    fi
    grep -o 'HOLEPROBE|[^"]*' "$tmp/err" > "$tmp/probes" || true
    [ -s "$tmp/probes" ] || continue
    checked=$((checked + 1))
    # uv rather than the system python, because this probe needs numpy and nothing
    # said so - CI has a python3 without it, and the failure was a traceback from
    # inside a heredoc rather than anything naming a dependency. --with declares it
    # at the point of use, so the check carries its own requirement.
    if ! uv run --no-project --quiet --with numpy python - "$tmp/p.stl" "$tmp/probes" "$f" <<'EOF'
import struct, sys, numpy as np
stl, probes, name = sys.argv[1], sys.argv[2], sys.argv[3]
with open(stl, 'rb') as fh:
    fh.read(80)
    n = struct.unpack('<I', fh.read(4))[0]
    raw = fh.read(50 * n)
tri = np.frombuffer(
    np.frombuffer(raw, dtype=np.uint8).reshape(n, 50)[:, 12:48].tobytes(),
    dtype='<f4').reshape(n, 3, 3).astype(np.float64)
# kind is 'exit' (through the discharge face) or 'feed' (on the bore's centreline). A hole is a
# gas path only if BOTH are void, and they fail for different reasons, so they are named apart.
pts = []
for line in open(probes):
    _, kind, x, y, z = line.strip().split('|')
    pts.append((kind, float(x), float(y), float(z)))
# Point in solid by ray parity, Moller-Trumbore. The direction is arbitrary but fixed and
# irrational-ish, so a ray does not run along an edge or through a vertex and count twice.
d = np.array([0.3137, 0.5171, 0.7963]); d /= np.linalg.norm(d)
v0, v1, v2 = tri[:, 0], tri[:, 1], tri[:, 2]
e1, e2 = v1 - v0, v2 - v0
h = np.cross(d, e2)
a = np.einsum('ij,ij->i', e1, h)
par = np.abs(a) < 1e-12
inv = np.where(par, 0.0, 1.0 / np.where(par, 1.0, a))
bad = []
for (kind, px, py, pz) in pts:
    s = np.array([px, py, pz]) - v0
    u = np.einsum('ij,ij->i', s, h) * inv
    q = np.cross(s, e1)
    v = (q @ d) * inv
    t = np.einsum('ij,ij->i', e2, q) * inv
    hit = (~par) & (u >= 0) & (u <= 1) & (v >= 0) & (u + v <= 1) & (t > 1e-9)
    if int(hit.sum()) % 2 == 1:
        bad.append((kind, px, py, pz))
why = {'exit': 'does not break through the discharge face',
       'feed': 'is not reached by the bore, so it opens into nothing'}
if bad:
    n_holes = sum(1 for k, *_ in pts if k == 'exit')
    print(f"FAIL  {name}  {len(bad)} of {len(pts)} probes on {n_holes} holes are solid")
    for k, x, y, z in bad[:5]:
        print("        %s end solid at (%.3f, %.3f, %.3f) - %s" % (k, x, y, z, why.get(k, k)))
    sys.exit(1)
n_holes = sum(1 for k, *_ in pts if k == 'exit')
print("ok    %-46s %d holes break through and are fed" % (name, n_holes))
EOF
    then failed=1; fi
done
[ "$checked" = 0 ] && [ "$failed" = 0 ] && echo "ok    no part declares a hole probe"
exit $failed
