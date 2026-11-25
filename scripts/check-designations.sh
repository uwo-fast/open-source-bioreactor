#!/usr/bin/env bash
#
# Fail when a designation no longer reaches the model.
#
: "${OPENSCAD:=openscad}"

# A designation is a string that a build sets and a registry looks up. Nothing else in the suite
# tests one: a lookup that silently returned undef for every name would pass both check-echo and
# check-scad.
#
# There are three kinds of row:
#   differs - the value must change the geometry, proving the designation reaches the model
#   builds  - it must resolve and render; some designations legitimately cannot move geometry
#   number  - a plain build parameter, which gets the differs test and no bad-name test
# The two name kinds are also tested with an unregistered name, which must fail. An optional
# fourth field gives a base build, as key=value, on which both sides of the differs test are run,
# for values the file defaults cannot show: a plain lid only differs from the default when the
# drive is not the shaft drive.
#
# Values are passed in a parameter set, not with -D. -D also sets the globals of a `use`d file,
# so the test could pass through that leak even with reactor_build broken; -p assigns only the
# file being rendered. The bad names are the exception: newer OpenSCAD silently drops a set value
# that is not among the listed options of its parameter, so an unregistered name never arrives
# that way and is passed with -D instead. A rejection cannot pass through a leak, because it is
# the build's own assert either way.
set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
matrix=(
    "shaft_name|8x600_316|differs"
    "strip_light_name|grow 16in|differs"
    "do_probe_name|DO lab g1|differs"
    "ph_probe_name|pH lab g1|differs"
    "plug_oring_name|AS568-160|builds"
    "gasket_sheet_name|EPDM 1/16 60A|builds"
    "motor_name|36PG-3429-5.2|differs"
    "do_probe_port_tilt_max|2|number"
    "drive_name|magnetic|differs"
    "drive_name|none|differs"
    "drive_name|none|differs|drive_name=magnetic"
    "drive_name|airlift|differs|reactor_vessel_name=jar_1gal_155x251,drive_name=none"
    "lid_center_name|plain|differs|drive_name=magnetic"
    "sparger_name|ring|differs"
    "sparger_name|loop|differs"
    "baffle_name|lid|differs"       # auto selects the cage on the default jar, so the plates differ
    "condenser_name|none|differs"
    "stir_bar_name|50x8|builds"
    "stir_magnet_name|MAGRE6x2p5|builds"
    "culture_fill_fraction|0.7|number"
    "lights_per_quadrant|4|number"
    "heat_pad_name|20W 150x50|differs"
)
# Each render is a separate OpenSCAD process. The parameter sets are written first, then all of
# them render JOBS at a time (every core unless set), and the rows are then checked in order.
: "${JOBS:=$(nproc)}"
# One parameter set: the row base, as key=value, with the named parameter applied on top.
set_json() { # base param value number
    /usr/bin/python3 -c 'import json,sys
b, p, v, n = sys.argv[1:]
s = dict(kv.split("=", 1) for kv in b.split(",") if kv)
if p: s[p] = float(v) if n == "1" else v
print(json.dumps({"parameterSets": {"t": s}, "fileFormatVersion": "1"}))' "$@"
}
# job lines: <name>|<json, or empty for the file defaults, or an args file of -D pairs>. Each
# renders to $tmp/<name>.csg.
jobs="base|"
for i in "${!matrix[@]}"; do
    IFS='|' read -r param value want base <<< "${matrix[$i]}"
    [ "$want" = number ] && num=1 || num=0
    if [ -n "$base" ]; then set_json "$base" "" "" 0 > "$tmp/b$i.json"; jobs+=$'\n'"b$i|$tmp/b$i.json"; fi
    set_json "$base" "$param" "$value" "$num" > "$tmp/p$i.json"; jobs+=$'\n'"p$i|$tmp/p$i.json"
    if [ "$want" != number ]; then
        for kv in ${base//,/ } "$param=no_such_row"; do printf -- '-D\n%s="%s"\n' "${kv%%=*}" "${kv#*=}"; done > "$tmp/x$i.args"
        jobs+=$'\n'"x$i|$tmp/x$i.args"
    fi
done
export OPENSCAD tmp
render_job() {
    IFS='|' read -r name json <<< "$1"
    local defs=()
    if [ "${json##*.}" = args ]; then mapfile -t defs < "$json"; json=; fi
    "$OPENSCAD" "${defs[@]}" ${json:+-p "$json" -P t} -o "$tmp/$name.csg" scad/bioreactor.scad 2>"$tmp/$name.err" >/dev/null
}
export -f render_job
xargs -d '\n' -P "$JOBS" -I{} bash -c 'render_job "$1"' _ {} <<< "$jobs"

if grep -q '^ERROR' "$tmp/base.err" || [ ! -s "$tmp/base.csg" ]; then echo "FAIL  bioreactor.scad does not build at its defaults"; exit 1; fi
failed=0
for i in "${!matrix[@]}"; do
    IFS='|' read -r param value want base <<< "${matrix[$i]}"
    case "$want" in
        number) shown="$param=$value" ;;
        *)      shown="$param=\"$value\"" ;;
    esac
    ref="$tmp/base.csg"
    if [ -n "$base" ]; then
        shown="$shown on $base"
        if grep -q '^ERROR' "$tmp/b$i.err" || [ ! -s "$tmp/b$i.csg" ]; then
            echo "FAIL  the base build $base does not build, so $shown cannot be compared"
            failed=1
            continue
        fi
        ref="$tmp/b$i.csg"
    fi
    if grep -q '^ERROR' "$tmp/p$i.err" || [ ! -s "$tmp/p$i.csg" ]; then
        echo "FAIL  $shown does not build"
        grep -m1 '^ERROR' "$tmp/p$i.err" | sed 's/.*failed: //; s/ in file.*//' | sed 's/^/        /'
        failed=1
    elif [ "$want" != builds ] && cmp -s "$ref" "$tmp/p$i.csg"; then
        echo "FAIL  $shown resolved but changed nothing - it is not reaching the model"
        failed=1
    else
        printf 'ok    %-18s %-12s %s%s\n' "$param" "$value" "$want" "${base:+ on $base}"
    fi
    # an unregistered name must fail with an error. This applies only to the name kinds, since a
    # number has no registry to be missing from.
    if [ "$want" != number ] && ! grep -q '^ERROR' "$tmp/x$i.err"; then
        echo "FAIL  $param accepted a name nothing is registered under"
        failed=1
    fi
done
[ $failed -eq 0 ] && echo "ok    every build parameter reaches the model, and a bad name is refused"
exit $failed
