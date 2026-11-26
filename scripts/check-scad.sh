#!/usr/bin/env bash
#
# Evaluate every SCAD file and report anything that does not build.
#
# A failing CSG export still exits 0 and writes a 1 byte file, so nothing here may be gated
# on $?. ERROR on stderr is the signal, and the file size is the fallback.
#
# Files are checked in both directions. Files in $ENTRY must emit geometry. Every other file is
# include'd or use'd by another file and must emit none. A new entry file fails until it is
# listed.
#
# Files are rendered with the default render flags. render_all is declared in bioreactor.scad,
# head.scad and frame.scad, so -D render_all=false sets all three and leaves only 4 of the 36
# asserts active.
set -uo pipefail

: "${OPENSCAD:=openscad}"
# A file meant to emit nothing also passes on a binary that emits nothing, so first confirm that
# the binary renders.
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
: "${ENTRY:?the justfile exports the list of files that render on their own}"

entry=($ENTRY)
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
# _spikes/ holds self-contained experiments, which have their own checks
files=$(find scad -name '*.scad' -not -path '*/_archive/*' -not -path '*/_shelf/*' -not -path '*/_spikes/*' | sort)
# Both passes of every file render JOBS at a time (every core unless set), each to its own
# output file, and are checked in order below.
: "${JOBS:=$(nproc)}"
export OPENSCAD tmp
render_file() {
    local base="$tmp/$(echo "$1" | tr / _)"
    "$OPENSCAD" -o "$base.csg" "$1" 2>"$base.err"
    "$OPENSCAD" -o "$base.fn0.csg" -D '$fn=0' "$1" 2>"$base.err0"
}
export -f render_file
xargs -d '\n' -P "$JOBS" -I{} bash -c 'render_file "$1"' _ {} <<< "$files"
failed=0
while read -r f; do
    renders=0
    for e in "${entry[@]}"; do [ "$e" = "$f" ] && renders=1; done
    base="$tmp/$(echo "$f" | tr / _)"
    out="$base.csg"
    size=$(stat -c%s "$out" 2>/dev/null || echo 0)
    if [ ! -f "$base.err" ]; then
        echo "FAIL  $f  was never rendered"
        failed=1
    elif grep -q '^ERROR' "$base.err"; then
        echo "FAIL  $f"
        grep '^ERROR' "$base.err" | sed 's/^/        /'
        failed=1
    elif grep -q '^WARNING' "$base.err"; then
        # OpenSCAD reports an undef used in arithmetic as a warning, and a parse error in a
        # use'd file appears only as a warning.
        echo "FAIL  $f"
        grep '^WARNING' "$base.err" | sort | uniq -c | sort -rn | head -5 | sed 's/^/        /'
        failed=1
    elif [ "$renders" = 1 ] && [ "$size" -le 1 ]; then
        echo "FAIL  $f  renders nothing"
        failed=1
    elif [ "$renders" = 0 ] && [ "$size" -gt 1 ]; then
        echo "FAIL  $f  emits $size bytes into every consumer; add it to entry if it renders"
        failed=1
    else
        # Second pass with $fn forced to zero, the value an unset viewport has. 2021.01 lets a
        # `use`d module resolve $fn from its own file, while newer builds pass the caller's
        # value, so a file that divides by $fn can pass here and produce nan in a current GUI.
        if [ ! -f "$base.err0" ] || grep -qE '^(ERROR|WARNING)' "$base.err0"; then
            echo "FAIL  $f  at \$fn=0"
            grep -E '^(ERROR|WARNING)' "$base.err0" 2>/dev/null | sort | uniq -c | sort -rn | head -3 | sed 's/^/        /'
            failed=1
        else
            printf 'ok    %-46s %s\n' "$f" "$([ "$renders" = 1 ] && echo "$size bytes" || echo 'no geometry')"
        fi
    fi
done <<< "$files"
exit $failed
