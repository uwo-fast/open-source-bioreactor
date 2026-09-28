#!/usr/bin/env bash
#
# Fail when a registered build does not build.
#
# A set in scad/bioreactor.json is a build someone is meant to print, so every one has to resolve
# with no failed assert. check-echo covers each vessel at the file's own defaults, where an ERROR
# is the recorded reason that vessel cannot carry them; this covers the builds as registered.
set -uo pipefail
: "${OPENSCAD:=openscad}"
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
sets=$(/usr/bin/python3 -c 'import json; print("\n".join(json.load(open("scad/bioreactor.json"))["parameterSets"]))')
[ -n "$sets" ] || { echo "FAIL  scad/bioreactor.json registers no builds"; exit 1; }
failed=0
for s in $sets; do
    "$OPENSCAD" -p scad/bioreactor.json -P "$s" --export-format echo -o "$tmp/e.txt" scad/bioreactor.scad 2>/dev/null >/dev/null
    if grep -q '^ERROR' "$tmp/e.txt"; then
        echo "FAIL  $s"
        grep -m1 '^ERROR' "$tmp/e.txt" | sed 's/.*failed: //; s/ in file.*//' | sed 's/^/        /'
        failed=1
    else
        printf 'ok    %-22s %s\n' "$s" "$(grep -m1 '^ECHO: "build: ' "$tmp/e.txt" | sed 's/^ECHO: "build: //; s/"$//')"
    fi
done
exit $failed
