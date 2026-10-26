#!/usr/bin/env bash
#
# Fail when the coil condenser or the turbidity sampler stands in anything else on the lid.
#
# Both are tall, and both turn through their bayonet's entry rotation going on. For each build in
# bioreactor.json, its lid is rendered from head.scad with the build's vessel, drive and lid centre
# (the build's other designations are below the lid or off it). Each tall part is rendered in
# place, locked and at entry, and intersected with the probes, the port pins, the motor, the motor
# mount and the other one, locked. An intersection writes no file when it is empty, which is the
# pass.
#
# It needs the manifold backend: about 16 s a render on it, and over ten minutes for the rest of
# the lid alone on CGAL, which is all the apt build CI uses has. Without it, it says SKIP.
set -uo pipefail
: "${OPENSCAD:=openscad}"
# "Nothing rendered" is also what a binary that renders nothing says.
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT

echo 'cube(1);' > "$tmp/probe.scad"
if ! "$OPENSCAD" --backend=manifold -o "$tmp/probe.stl" "$tmp/probe.scad" >/dev/null 2>&1; then
    echo "SKIP  check-clash: $("$OPENSCAD" --version 2>&1 | head -1) has no manifold backend; nothing was checked"
    exit 0
fi

# $1 output, $2 build, the rest -D flags; $lid holds the build's own
render() {
    local out=$1 build=$2
    shift 2
    # shellcheck disable=SC2086 # $lid is a list of -D words with no spaces inside them
    "$OPENSCAD" --backend=manifold --export-format binstl $lid \
        -D render_all=false "$@" -o "$out" scad/head.scad 2>"$out.err" >/dev/null
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

# name|-D words, one build a line; what a set leaves out is the file's default in both files
builds=$(python3 -c 'import json
for k, v in json.load(open("scad/bioreactor.json"))["parameterSets"].items():
    d = {"reactor_vessel_name": "reactor_vessel_name", "drive_name": "head_drive", "lid_center_name": "head_lid_center"}
    print(k + "|" + " ".join(f"-D {d[x]}=\"{y}\"" for x, y in v.items() if x in d))')
[ -n "$builds" ] || { echo "FAIL  could not read the builds in scad/bioreactor.json"; exit 1; }
# $1 narrows it to one build by name
if [ -n "${1:-}" ]; then
    builds=$(grep "^$1|" <<< "$builds") || { echo "FAIL  no build named $1 in scad/bioreactor.json"; exit 1; }
fi
failed=0
while IFS='|' read -r b lid; do
    bad=0
    render "$tmp/rest.stl" "$b" -D render_probes=true -D render_motor=true -D render_motor_mount=true \
        -D render_tube_pinlock=true -D render_probe_pinlock=true -D render_thermocouple_pinlock=true \
        -D render_baffle_pinlock=true || { failed=1; continue; }
    parts=()
    grep -q '"condenser: the coil' "$tmp/rest.stl.err" && parts+=(condenser)
    grep -q '"sampler: on port' "$tmp/rest.stl.err" && parts+=(sampler)
    for p in "${parts[@]}"; do
        for pos in locked entry; do
            render "$tmp/$p-$pos.stl" "$b" -D "render_$p=true" -D "port_position=\"$pos\"" || bad=1
        done
    done
    [ "${#parts[@]}" -gt 0 ] || { echo "ok    $b  carries neither"; continue; }
    [ $bad -eq 0 ] || { failed=1; continue; }
    for p in "${parts[@]}"; do
        others="import(\"$tmp/rest.stl\");"
        for q in "${parts[@]}"; do
            [ "$q" = "$p" ] || others="$others import(\"$tmp/$q-locked.stl\");"
        done
        for pos in locked entry; do
            x="$tmp/$b-$p-$pos-x"
            printf 'intersection() { import("%s"); union() { %s } }\n' "$tmp/$p-$pos.stl" "$others" > "$x.scad"
            "$OPENSCAD" --backend=manifold --export-format binstl -o "$x.stl" "$x.scad" 2>"$x.err" >/dev/null
            # an import that fails also leaves no file, so a clean log is part of the pass
            if grep -qE '^(ERROR|WARNING)' "$x.err"; then
                echo "FAIL  $b  the $p's intersection did not render"
                grep -m3 -E '^(ERROR|WARNING)' "$x.err" | sed 's/^/        /'
                bad=1
            elif [ -f "$x.stl" ]; then
                echo "FAIL  $b  the $p, $pos, stands in something else on the lid"
                bad=1
            fi
        done
    done
    if [ $bad -eq 0 ]; then
        echo "ok    $b  ${parts[*]} clear of the lid, locked and at entry"
    else
        failed=1
    fi
done <<< "$builds"
exit $failed
