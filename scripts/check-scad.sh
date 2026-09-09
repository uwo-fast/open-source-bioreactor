#!/usr/bin/env bash
#
# Evaluate every SCAD file and report anything that does not build.
#
# A failing CSG export still exits 0 and writes a 1 byte file, so nothing here may be gated
# on $?. ERROR on stderr is the signal; the file size is the backstop.
#
# Files are checked in both directions. The ones in $ENTRY are meant to render on their own
# and must emit geometry. Every other file is include'd or use'd by something and must emit
# none - a registry that draws its own example draws it into every consumer, which is what
# 1a6df3d fixed. A new entry file therefore fails until it is listed, which is the point: the
# list is the record of what renders, and it lives in the justfile beside the recipes that
# read it.
#
# Run with default render flags. render_all is declared in assembly.scad, head.scad and
# frame.scad, so -D render_all=false sets all three and leaves 4 of the 36 asserts standing.
set -uo pipefail

: "${OPENSCAD:=openscad}"
: "${ENTRY:?the justfile exports the list of files that render on their own}"

entry=($ENTRY)
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
failed=0
while read -r f; do
    renders=0
    for e in "${entry[@]}"; do [ "$e" = "$f" ] && renders=1; done
    out="$tmp/$(echo "$f" | tr / _).csg"
    "$OPENSCAD" -o "$out" "$f" 2>"$tmp/err"
    size=$(stat -c%s "$out" 2>/dev/null || echo 0)
    if grep -q '^ERROR' "$tmp/err"; then
        echo "FAIL  $f"
        grep '^ERROR' "$tmp/err" | sed 's/^/        /'
        failed=1
    elif grep -q '^WARNING' "$tmp/err"; then
        # Warnings are how OpenSCAD reports an undef reaching arithmetic, and a parse error in
        # a use'd file shows up as nothing else - ninety of them once rode in on a missing
        # comma between two string literals, which silently stopped head.scad exporting any of
        # its functions while it still rendered on its own. Nothing here may be warning-noisy.
        echo "FAIL  $f"
        grep '^WARNING' "$tmp/err" | sort | uniq -c | sort -rn | head -5 | sed 's/^/        /'
        failed=1
    elif [ "$renders" = 1 ] && [ "$size" -le 1 ]; then
        echo "FAIL  $f  renders nothing"
        failed=1
    elif [ "$renders" = 0 ] && [ "$size" -gt 1 ]; then
        echo "FAIL  $f  emits $size bytes into every consumer; add it to entry if it renders"
        failed=1
    else
        # SECOND PASS, with $fn forced to zero. Not a quality setting - zero is what $fn IS
        # unless something assigns it, and it means the fragment count comes from $fa and $fs
        # instead. OpenSCAD 2021.01 lets a module reached through `use` resolve $fn from its own
        # file; newer builds hand it the caller's. So a file that divides by $fn is fine here
        # and asserts on a nan the moment it is opened in a current GUI - which is exactly what
        # sparge_ring did, while this suite stayed green. CI cannot be on every version, so it
        # simulates the one it is not on.
        "$OPENSCAD" -o "$out" -D '$fn=0' "$f" 2>"$tmp/err0"
        if grep -qE '^(ERROR|WARNING)' "$tmp/err0"; then
            echo "FAIL  $f  at \$fn=0"
            grep -E '^(ERROR|WARNING)' "$tmp/err0" | sort | uniq -c | sort -rn | head -3 | sed 's/^/        /'
            failed=1
        else
            printf 'ok    %-46s %s\n' "$f" "$([ "$renders" = 1 ] && echo "$size bytes" || echo 'no geometry')"
        fi
    fi
done < <(find scad -name '*.scad' -not -path '*/_archive/*' -not -path '*/_shelf/*' | sort)
exit $failed
