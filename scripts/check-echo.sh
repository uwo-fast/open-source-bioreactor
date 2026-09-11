#!/usr/bin/env bash
#
# Diff every entry file's echo stream, on every registered vessel, against a committed
# transcript. `--update` rewrites the transcripts instead of diffing.
#
# NOT with -D render_all=false: that flag reaches bioreactor.scad's own render_all and takes it
# from 83 echoes to 5, so a baseline captured with it would cover 6% and read as complete.
set -uo pipefail

: "${OPENSCAD:=openscad}"
BASE=tests/echo
update=0
[ "${1:-}" = "--update" ] && update=1

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir -p "$BASE"

printf 'include <%s/scad/purchased/vessels.scad>\nfor (v = vessels) echo(str("V|", vessel_name(v), "|", v));\n' "$PWD" > "$tmp/rows.scad"
"$OPENSCAD" -o "$tmp/rows.csg" "$tmp/rows.scad" 2>"$tmp/rows.err" >/dev/null
rows=$(grep '^ECHO: "V|' "$tmp/rows.err" | sed 's/^ECHO: "V|//; s/"$//')
[ -n "$rows" ] || { echo "FAIL  could not read the vessel registry"; exit 1; }

failed=0 cells=0 changed=0 known=0
declare -a known_rows=()
while IFS='|' read -r name row; do
    for f in bioreactor head frame; do
        cells=$((cells + 1))
        out="$BASE/${f}__${name}.txt"
        "$OPENSCAD" -D "reactor_vessel=$row" --export-format echo -o "$tmp/e.txt" "scad/$f.scad" 2>"$tmp/err" >/dev/null
        # A cell that ERRORs still has a transcript worth pinning - it is what the model says on
        # the way to failing, and the summary below names which cells those are.
        # --export-format echo writes ERROR and TRACE into the OUTPUT file, not to stderr, so the
        # transcript is that file alone. Line numbers are normalised out of it: an assert's identity
        # is its condition and its message, both kept verbatim, where "line 3192" changes for free
        # whenever a line is added above it - which made step 4 red for moving one line.
        sed 's/, line [0-9]*/, line N/g' "$tmp/e.txt" > "$tmp/cell.txt" 2>/dev/null
        n=$(grep -c '^ECHO' "$tmp/cell.txt" || true)
        # A cell that ERRORs is a vessel this build cannot carry. Recorded here rather than in a
        # hand-written list: the assert's own message is the reason, and it cannot go stale.
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
    done
done <<< "$rows"

report_known() {
    [ "$known" -eq 0 ] && return
    echo "      $known of $cells cells cannot build this vessel, which is expected and pinned:"
    printf '        %s\n' "${known_rows[@]}"
}

[ "$update" = 1 ] && { echo "$cells transcripts written"; report_known; exit 0; }
[ $failed -eq 0 ] && { echo "ok    $cells echo transcripts unchanged"; report_known; }
[ $failed -eq 0 ] || echo "      $changed of $cells cells moved - re-baseline only once you have read the diff"
exit $failed
