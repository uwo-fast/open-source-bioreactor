#!/usr/bin/env bash
#
# Fail when a registered build does not build.
#
# A set in scad/bioreactor.json is a build someone is meant to print, so every one has to resolve
# with no failed assert. check-echo covers each vessel at the file's own defaults, where an ERROR
# is the recorded reason that vessel cannot carry them; this covers the builds as registered.
set -uo pipefail
: "${OPENSCAD:=openscad}"
# The sets render JOBS at a time (every core, unless set), then are judged in order.
: "${JOBS:=$(nproc)}"
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
sets=$(/usr/bin/python3 -c 'import json; print("\n".join(json.load(open("scad/bioreactor.json"))["parameterSets"]))')
[ -n "$sets" ] || { echo "FAIL  scad/bioreactor.json registers no builds"; exit 1; }
failed=0
# One file per set, so a render that writes nothing cannot be read as another's; its exit status
# and stderr land beside it.
export OPENSCAD tmp
render_set() {
    "$OPENSCAD" -p scad/bioreactor.json -P "$1" --export-format echo -o "$tmp/$1.txt" scad/bioreactor.scad 2>"$tmp/$1.err" >/dev/null
    echo $? > "$tmp/$1.rc"
}
export -f render_set
printf '%s\n' $sets | xargs -d '\n' -P "$JOBS" -I{} bash -c 'render_set "$1"' _ {}
for s in $sets; do
    out="$tmp/$s.txt"
    if [ "$(cat "$tmp/$s.rc" 2>/dev/null)" != 0 ]; then
        echo "FAIL  $s  openscad exited non-zero"
        head -3 "$tmp/$s.err" 2>/dev/null | sed 's/^/        /'
        failed=1
        continue
    fi
    stated=$(grep -m1 '^ECHO: "build: ' "$out" 2>/dev/null | sed 's/^ECHO: "build: //; s/"$//')
    if grep -q '^ERROR' "$out" 2>/dev/null; then
        echo "FAIL  $s"
        grep -m1 '^ERROR' "$out" | sed 's/.*failed: //; s/ in file.*//' | sed 's/^/        /'
        failed=1
    elif [ -z "$stated" ]; then
        # the assembly states every build it evaluates, so no statement means it was not evaluated
        echo "FAIL  $s  the render said nothing about the build"
        failed=1
    else
        printf 'ok    %-22s %s\n' "$s" "$stated"
    fi
done
exit $failed
