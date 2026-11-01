#!/usr/bin/env bash
#
# Fail when the wall cage's blades do not slide, stop and hold as the cage is drawn, or when the
# cage stands in the glass or in anything that hangs from the lid.
#
# For each build in bioreactor.json that carries a wall cage, its hoops and its blades are rendered
# apart, in place, through bioreactor.scad with the build's own parameter set, so its designations
# are the ones the reactor is built with. The blade at 0 deg is then slid along its bar against
# both hoops, and each row says whether it must meet them:
#   - at the slide's two ends, out and at the stop, and between the detents, it slides free;
#   - just past out, the tip detent; just in, the out-detent; just short of the stop, the
#     in-detent: each has to be pushed through a hoop;
#   - past the stop, the bar's closed end meets the hoop's lip.
# The cage, out, must clear the glass and the probes, tubes, sparger, condenser, sampler, shaft and
# impellers. And its hoops turned 2 deg either way must meet the air inlet's riser, the tube the
# arm catches, so the cage cannot turn; the same blade 1 mm further out must meet the glass, which
# is what shows the glass rows can fail. An intersection writes no file when it is empty.
#
# It needs the manifold backend: about 16 s a render on it, and four renders a build that carries
# a cage. Without it, it says SKIP.
set -uo pipefail
: "${OPENSCAD:=openscad}"
# "Nothing rendered" is also what a binary that renders nothing says.
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT

echo 'cube(1);' > "$tmp/probe.scad"
if ! "$OPENSCAD" --backend=manifold -o "$tmp/probe.stl" "$tmp/probe.scad" >/dev/null 2>&1; then
    echo "SKIP  check-baffle-cage: $("$OPENSCAD" --version 2>&1 | head -1) has no manifold backend; nothing was checked"
    exit 0
fi

# $1 output, $2 build, the rest -D flags; through bioreactor.scad, the head alone unless a flag
# turns the vessel back on
render() {
    local out=$1 build=$2
    shift 2
    "$OPENSCAD" --backend=manifold --export-format binstl -p scad/bioreactor.json -P "$build" \
        -D render_all=false -D render_frame=false -D render_vessel=false "$@" \
        -o "$out" scad/bioreactor.scad 2>"$out.err" >/dev/null
    if grep -qE '^(ERROR|WARNING)|Assertion' "$out.err"; then
        echo "FAIL  $build  did not render: $*"
        grep -m3 -E '^(ERROR|WARNING)|Assertion' "$out.err" | sed 's/^/        /'
        return 1
    fi
    if [ ! -s "$out" ]; then
        echo "FAIL  $build  rendered nothing, so nothing could be checked: $*"
        return 1
    fi
}

# $1 label, $2 want (clear|meet), $3 and $4 OpenSCAD objects; prints FAIL and returns 1 when the
# answer is not the one wanted
meets() {
    local label=$1 want=$2 x got
    x="$tmp/x$((++n))"
    printf 'intersection() { %s %s }\n' "$3" "$4" > "$x.scad"
    "$OPENSCAD" --backend=manifold --export-format binstl -o "$x.stl" "$x.scad" 2>"$x.err" >/dev/null
    # an import that fails also leaves no file, so a clean log is part of a clear
    if grep -qE '^(ERROR|WARNING)' "$x.err"; then
        echo "FAIL  $b  $label: the intersection did not render"
        grep -m3 -E '^(ERROR|WARNING)' "$x.err" | sed 's/^/        /'
        return 1
    fi
    got=clear
    [ -f "$x.stl" ] && got=meet
    [ "$got" = "$want" ] && return 0
    echo "FAIL  $b  $label: wants $want, got $got"
    return 1
}

builds=$(python3 -c 'import json; print("\n".join(json.load(open("scad/bioreactor.json"))["parameterSets"]))')
[ -n "$builds" ] || { echo "FAIL  could not read the builds in scad/bioreactor.json"; exit 1; }
# $1 narrows it to one build by name
if [ -n "${1:-}" ]; then
    builds=$(grep -x -- "$1" <<< "$builds") || { echo "FAIL  no build named $1 in scad/bioreactor.json"; exit 1; }
fi
failed=0
n=0
while read -r b; do
    # the echoes alone, no geometry: whether it carries a cage, and the blade's travel
    "$OPENSCAD" -p scad/bioreactor.json -P "$b" -D render_all=false -D render_head=true \
        -o "$tmp/$b.echo" scad/bioreactor.scad 2>/dev/null
    # head() says where every build's baffles are, so without that line it did not run
    if ! grep -q '^ECHO: "baffles: ' "$tmp/$b.echo"; then
        echo "FAIL  $b  head() echoed nothing about its baffles, so whether it carries a cage is unknown"
        failed=1
        continue
    fi
    if ! grep -q '^ECHO: "baffles: [0-9]* on the wall cage' "$tmp/$b.echo"; then
        echo "ok    $b  carries no wall cage"
        continue
    fi
    travel=$(sed -n 's/.*"baffle cage: .* slides in \([0-9.]*\) mm to its stop.*/\1/p' "$tmp/$b.echo")
    if [ -z "$travel" ]; then
        echo "FAIL  $b  carries a wall cage but did not echo its travel"
        failed=1
        continue
    fi
    if ! render "$tmp/hoops.stl" "$b" -D render_head=true -D render_baffle_cage=true -D 'baffle_cage_part_to_render="hoops"' ||
        ! render "$tmp/blades.stl" "$b" -D render_head=true -D render_baffle_cage=true -D 'baffle_cage_part_to_render="blades"' ||
        ! render "$tmp/glass.stl" "$b" -D render_head=false -D render_vessel=true ||
        ! render "$tmp/hung.stl" "$b" -D render_head=true -D render_probes=true -D render_sparger=true \
            -D render_sparge_tubes=true -D render_condenser=true -D render_sampler=true \
            -D render_thermocouple_pinlock=true -D render_tube_pinlock=true -D render_probe_pinlock=true \
            -D render_impeller=true -D render_ext_shaft=true; then
        failed=1
        continue
    fi
    hoops="import(\"$tmp/hoops.stl\");"
    blades="import(\"$tmp/blades.stl\");"
    glass="import(\"$tmp/glass.stl\");"
    hung="import(\"$tmp/hung.stl\");"
    # the blade at 0 deg lies along +x and no other blade comes near x 40
    blade="intersection() { $blades translate([40, -20, -1000]) cube([200, 40, 2000]); }"
    bad=0
    while IFS='|' read -r label s want; do
        meets "slid in $s mm, $label" "$want" "$hoops" "translate([-($s), 0, 0]) $blade" || bad=1
    done <<EOF
out, it slides free|0|clear
past out, the tip detent holds it|-1|meet
just in, the out-detent holds it|2|meet
a third of the way in, it slides free|$travel / 3|clear
two thirds in, it slides free|$travel * 2 / 3|clear
just short of the stop, the in-detent holds it|$travel - 2|meet
at the stop, it slides free|$travel|clear
past the stop, the closed end stops it|$travel + 1|meet
EOF
    meets "the blades, out, against the glass" clear "$glass" "$blades" || bad=1
    meets "the hoops against the glass" clear "$glass" "$hoops" || bad=1
    meets "a blade 1 mm further out against the glass" meet "$glass" "translate([1, 0, 0]) $blade" || bad=1
    meets "the cage, out, against what hangs from the lid" clear "$hung" "union() { $hoops $blades }" || bad=1
    meets "the hoops turned 2 deg against the riser" meet "$hung" "rotate([0, 0, 2]) $hoops" || bad=1
    meets "the hoops turned -2 deg against the riser" meet "$hung" "rotate([0, 0, -2]) $hoops" || bad=1
    if [ $bad -eq 0 ]; then
        echo "ok    $b  the blades slide $travel mm, stop and hold; the cage clears the glass and the lid's parts and cannot turn"
    else
        failed=1
    fi
done <<< "$builds"
exit $failed
