#!/usr/bin/env bash
#
# Diff every entry file's echo stream, on every registered vessel, against a committed
# transcript, and bioreactor.scad's on every registered build that sets more than its vessel,
# which the vessel rows do not reach. `--update` rewrites the transcripts instead of diffing. Not with
# -D render_all=false, which would reach bioreactor.scad's own flag and drop most of the stream.
set -uo pipefail

: "${OPENSCAD:=openscad}"
# The cells render JOBS at a time (every core, unless set), then are compared in order.
: "${JOBS:=$(nproc)}"
BASE=tests/echo
update=0
[ "${1:-}" = "--update" ] && update=1

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir -p "$BASE"

printf 'include <%s/scad/purchased/vessels.scad>\nfor (v = vessels) echo(str("V|", vessel_name(v), "|", v));\n' "$PWD" > "$tmp/rows.scad"
"$OPENSCAD" -o "$tmp/rows.csg" "$tmp/rows.scad" 2>"$tmp/rows.err" >/dev/null
rows=$(grep '^ECHO: "V|' "$tmp/rows.err" | sed 's/^ECHO: "V|//; s/"$//')
[ -n "$rows" ] || { echo "FAIL  could not read the vessel registry"; exit 1; }
builds=$(/usr/bin/python3 -c 'import json
for k, v in json.load(open("scad/bioreactor.json"))["parameterSets"].items():
    if set(v) - {"reactor_vessel_name"}: print(k)')
# one cell per line, file|name|vessel row (empty for a build), in the order they are compared
cell_list=$(
    while IFS='|' read -r name row; do
        for f in bioreactor head frame; do printf '%s|%s|%s\n' "$f" "$name" "$row"; done
    done <<< "$rows"
    for b in $builds; do printf 'build|%s|\n' "$b"; done
)

failed=0 cells=0 changed=0 known=0
declare -a known_rows=()
# Every cell is its own OpenSCAD process and none reads another's output, so they render at once
# into one file each; the loop below compares them in the registry's order as before.
export OPENSCAD tmp
render_cell() {
    IFS='|' read -r f name row <<< "$1"
    # a build's own values are listed options of bioreactor.scad's, which a set reaches on any release
    if [ "$f" = build ]; then
        "$OPENSCAD" -p scad/bioreactor.json -P "$name" --export-format echo -o "$tmp/raw.$f.$name.txt" scad/bioreactor.scad 2>/dev/null >/dev/null
    else
        "$OPENSCAD" -D "reactor_vessel=$row" --export-format echo -o "$tmp/raw.$f.$name.txt" "scad/$f.scad" 2>/dev/null >/dev/null
    fi
}
export -f render_cell
xargs -d '\n' -P "$JOBS" -I{} bash -c 'render_cell "$1"' _ {} <<< "$cell_list"
while IFS='|' read -r f name _; do
    cells=$((cells + 1))
    out="$BASE/${f}__${name}.txt"
    cp "$tmp/raw.$f.$name.txt" "$tmp/e.txt" 2>/dev/null || : > "$tmp/e.txt"
    # --export-format echo writes ERROR and TRACE into the output file, so the transcript is
    # that file alone. Line numbers are normalised out: an assert's identity is its condition
    # and its message. TRACE lines go too: they are OpenSCAD's call stack, worded differently
    # from one release to the next, not anything the model said.
    sed -e 's/, line [0-9]*/, line N/g' -e '/^TRACE: /d' "$tmp/e.txt" > "$tmp/cell.txt" 2>/dev/null
    n=$(grep -c '^ECHO' "$tmp/cell.txt" || true)
    # A cell that ERRORs is a vessel this build cannot carry; the assert's message is the reason.
    if grep -q '^ERROR' "$tmp/cell.txt"; then
        known=$((known + 1))
        known_rows+=("$(printf '%-9s %-22s %s' "$f" "$name" \
            "$(grep -m1 '^ERROR' "$tmp/cell.txt" | sed 's/.*failed: //; s/ in file.*//' | cut -c1-70)")")
    fi
    if [ "$update" = 1 ]; then
        cp "$tmp/cell.txt" "$out"
        printf 'wrote %-9s %-22s %s lines\n' "$f" "$name" "$n"
        continue
    fi
    if [ ! -f "$out" ]; then
        echo "FAIL  $f  $name  no transcript; run \`just check-echo-update\`"
        failed=1
    elif diff -q "$out" "$tmp/cell.txt" >/dev/null; then
        printf 'ok    %-9s %-22s %s lines\n' "$f" "$name" "$n"
    else
        echo "FAIL  $f  $name  the reported stream moved:"
        diff "$out" "$tmp/cell.txt" | head -12 | sed 's/^/        /'
        d=$(diff "$out" "$tmp/cell.txt" | grep -c '^[<>]')
        [ "$d" -gt 12 ] && echo "        ... $d changed lines in all"
        failed=1; changed=$((changed + 1))
    fi
done <<< "$cell_list"

report_known() {
    [ "$known" -eq 0 ] && return
    echo "      $known of $cells cells cannot build this vessel, which is expected and pinned:"
    printf '        %s\n' "${known_rows[@]}"
}

[ "$update" = 1 ] && { echo "$cells transcripts written"; report_known; exit 0; }
[ $failed -eq 0 ] && { echo "ok    $cells echo transcripts unchanged"; report_known; }
[ $failed -eq 0 ] || echo "      $changed of $cells cells moved - re-baseline only once you have read the diff"
exit $failed
