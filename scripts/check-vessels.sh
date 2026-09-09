#!/usr/bin/env bash
#
# Render every entry file against every registered vessel, not just the selected one.
#
: "${OPENSCAD:=openscad}"

# check-scad renders each file once, at its defaults, and those defaults name one jar. So five
# of six registered vessels were unbuildable for months while check-scad stayed green - nothing
# ever built the others. This recipe builds them all.
#
# THREE ENTRY FILES, not one. Sweeping only head.scad is how four failing vessels read as two:
# head.scad standalone and assembly.scad configure the same lid by different routes and can
# disagree, and frame.scad was never swept at all - its base centre bore was cut from the wall
# instead of the jar's base corner, and jar_6p5gal_305x470 stood on its own fillet over the
# bore edge for as long as that went unmeasured.
#
# SWEPT AT THEIR OWN DEFAULTS. This used to force the working volume and both probe leans,
# because one jar's numbers were pinned on all six and a jar that builds perfectly well was
# being called broken. Both are DERIVED now, so an override here would not neutralise them, it
# would defeat the derivation and check a configuration nobody renders - and holding the DO
# lean at 0 is not even neutral, it is that probe's worst case against the impellers. What a
# jar can carry is the model's question to answer; this asks whether it answered.
#
# `broken` below is the record of what does not build, keyed by FILE and vessel because the
# files can disagree and a divergence is the interesting result. It fails BOTH ways on purpose:
# an unlisted cell that breaks is a regression, and a listed cell that builds means the list
# has gone stale and the fix went unnoticed. Shrinking this list is the work.
set -uo pipefail
broken=(
    "assembly|jar_1p5L_109x215"   # motor mount overlaps the port flanges by 12.45 mm
    "head|jar_1p5L_109x215"       # the same lid, reached from head.scad's own preview
    "assembly|jar_1gal_155x251"   # a vertical pH probe runs 6.29 mm through the lower impeller
    "head|jar_1gal_155x251"       # the same
)
# All three entry files now carry the same public selector, so the sweep names one variable.
# frame.scad used to reach its jar through a private _preview_vessel below `module dummy()`.
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
# The registry is the source of the list, so adding a jar adds it to the sweep.
printf 'include <%s/scad/purchased/vessels.scad>\nfor (v = vessels) echo(str("V|", vessel_name(v), "|", v));\n' "$PWD" > "$tmp/rows.scad"
"$OPENSCAD" -o "$tmp/rows.csg" "$tmp/rows.scad" 2>"$tmp/rows.err" >/dev/null
rows=$(grep '^ECHO: "V|' "$tmp/rows.err" | sed 's/^ECHO: "V|//; s/"$//')
if [ -z "$rows" ]; then echo "FAIL  could not read the vessel registry"; exit 1; fi
failed=0
seen=()
while IFS='|' read -r name row; do
    for f in assembly head frame; do
        listed=0
        for b in "${broken[@]}"; do [ "${b%%#*}" = "$f|$name" ] && listed=1; done
        # Recorded on REACHING the cell, not on failing it - a listed cell that builds is a
        # stale list, which the branch below already says, and it should not also be reported
        # as a key nothing ever swept.
        [ "$listed" = 1 ] && seen+=("$f|$name")
        "$OPENSCAD" -D "reactor_vessel=$row" -o "$tmp/v.csg" "scad/$f.scad" 2>"$tmp/err" >/dev/null
        if grep -q '^ERROR' "$tmp/err"; then
            if [ "$listed" = 1 ]; then
                printf 'ok    %-9s %-22s known broken: %s\n' "$f" "$name" "$(grep -m1 '^ERROR' "$tmp/err" | sed 's/.*failed: //; s/ in file.*//' | cut -c1-62)"
            else
                echo "FAIL  $f  $name  builds no longer"
                grep -m1 '^ERROR' "$tmp/err" | sed 's/^/        /'
                failed=1
            fi
        elif [ "$listed" = 1 ]; then
            echo "FAIL  $f  $name  now builds, but is still listed as broken - remove it from check-vessels"
            failed=1
        else
            printf 'ok    %-9s %-22s builds\n' "$f" "$name"
        fi
    done
done <<< "$rows"
# A listed cell the sweep never reached is a stale key - a renamed jar, or a file that is no
# longer an entry - and it would otherwise sit there guarding nothing.
for b in "${broken[@]}"; do
    key="${b%%#*}"; key="${key%"${key##*[![:space:]]}"}"
    hit=0
    for s in "${seen[@]:-}"; do [ "$s" = "$key" ] && hit=1; done
    if [ "$hit" = 0 ]; then
        echo "FAIL  $key is listed as broken but the sweep never reached it - stale key"
        failed=1
    fi
done
exit $failed
