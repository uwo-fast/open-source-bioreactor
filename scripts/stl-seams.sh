#!/usr/bin/env bash
#
# Report whether an ASCII STL is closed: the triangle count, edges used by one face, edges used by
# more than two faces, and repeated triangles. A closed surface uses every edge exactly twice and
# no triangle twice. Anything else is a seam left by the renderer.
#
# Prints "<triangles> <open> <over> <duplicate>" on one line. Exits 1 if any of the last three is
# non-zero, so it can be used as a gate by itself, and 0 otherwise.
#
# The OpenSCAD "not a valid 2-manifold" check applies to the CSG result, not to the mesh written
# afterwards, so a tangency that tessellates into coincident faces passes it. This script checks
# the file on disk.
set -uo pipefail

file="${1:?usage: stl-seams.sh <file.stl>}"
[ -r "$file" ] || { echo "stl-seams: cannot read $file" >&2; exit 2; }

read -r tris open over dup < <(awk '
    /^ *vertex/ {
        v[n++ % 3] = $2 " " $3 " " $4
        if (n % 3 == 0) {
            tris++
            # the triangle itself, keyed on its vertices in a fixed order
            a = v[0]; b = v[1]; c = v[2]
            if (a > b) { t = a; a = b; b = t }
            if (b > c) { t = b; b = c; c = t }
            if (a > b) { t = a; a = b; b = t }
            face[a "|" b "|" c]++
            # and its three edges, each keyed on its two ends in a fixed order
            for (i = 0; i < 3; i++) {
                p = v[i]; q = v[(i + 1) % 3]
                edge[(p < q) ? p "|" q : q "|" p]++
            }
        }
    }
    END {
        for (k in edge) if (edge[k] == 1) open++; else if (edge[k] > 2) over++
        for (k in face) if (face[k] > 1) dup += face[k] - 1
        printf "%d %d %d %d\n", tris + 0, open + 0, over + 0, dup + 0
    }
' "$file")

echo "$tris $open $over $dup"
[ "$open" -eq 0 ] && [ "$over" -eq 0 ] && [ "$dup" -eq 0 ]
