#!/usr/bin/env bash
#
# Fail when a designation stops reaching the model.
#
: "${OPENSCAD:=openscad}"

# A designation is a string a build states and a registry answers to. Nothing else in the suite
# exercises one: a lookup that quietly returned undef for every name would pass check-echo and
# check-scad both.
#
# Three kinds of row:
#   differs - the value must change the geometry, proving the designation reaches the model
#   builds  - it must resolve and render; some designations legitimately cannot move geometry
#   number  - a plain build parameter, which gets the differs test and no bad-name test
# The two name kinds also get a name nothing answers to, which must fail. A fourth field names a
# base build, key=value, that both sides of the differs test are taken on, where the file's
# defaults cannot show the value: a plain lid only differs off the shaft drive.
#
# Driven by a parameter set, not -D: -D reaches a `use`d file's globals and would pass on that
# leak even with reactor_build broken. -p assigns only the file being rendered.
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
    "lid_center_name|plain|differs|drive_name=magnetic"
    "sparger_name|ring|differs"
    "stir_bar_name|50x8|builds"
    "stir_magnet_name|MAGRE6x2p5|builds"
    "culture_fill_fraction|0.7|number"
)
"$OPENSCAD" -o "$tmp/base.csg" scad/bioreactor.scad 2>"$tmp/be" >/dev/null
if grep -q '^ERROR' "$tmp/be"; then echo "FAIL  bioreactor.scad does not build at its defaults"; exit 1; fi
failed=0
# One parameter set: the row's base, key=value, with the named parameter over it.
set_json() { # base param value number
    /usr/bin/python3 -c 'import json,sys
b, p, v, n = sys.argv[1:]
s = dict(kv.split("=", 1) for kv in b.split(",") if kv)
if p: s[p] = float(v) if n == "1" else v
print(json.dumps({"parameterSets": {"t": s}, "fileFormatVersion": "1"}))' "$@"
}
for row in "${matrix[@]}"; do
    IFS='|' read -r param value want base <<< "$row"
    case "$want" in
        number) shown="$param=$value"; num=1 ;;
        *)      shown="$param=\"$value\""; num=0 ;;
    esac
    ref="$tmp/base.csg"
    if [ -n "$base" ]; then
        shown="$shown on $base"
        set_json "$base" "" "" 0 > "$tmp/b.json"
        "$OPENSCAD" -p "$tmp/b.json" -P t -o "$tmp/rowbase.csg" scad/bioreactor.scad 2>"$tmp/rbe" >/dev/null
        if grep -q '^ERROR' "$tmp/rbe" || [ ! -s "$tmp/rowbase.csg" ]; then
            echo "FAIL  the base build $base does not build, so $shown cannot be compared"
            failed=1
            continue
        fi
        ref="$tmp/rowbase.csg"
    fi
    set_json "$base" "$param" "$value" "$num" > "$tmp/p.json"
    "$OPENSCAD" -p "$tmp/p.json" -P t -o "$tmp/d.csg" scad/bioreactor.scad 2>"$tmp/e" >/dev/null
    if grep -q '^ERROR' "$tmp/e"; then
        echo "FAIL  $shown does not build"
        grep -m1 '^ERROR' "$tmp/e" | sed 's/.*failed: //; s/ in file.*//' | sed 's/^/        /'
        failed=1
    elif [ "$want" != builds ] && cmp -s "$ref" "$tmp/d.csg"; then
        echo "FAIL  $shown resolved but changed nothing - it is not reaching the model"
        failed=1
    else
        printf 'ok    %-18s %-12s %s%s\n' "$param" "$value" "$want" "${base:+ on $base}"
    fi
    # a name nothing answers to has to fail, loudly. Only for the name kinds - a number has no
    # registry to be absent from.
    if [ "$want" != number ]; then
        set_json "$base" "$param" no_such_row 0 > "$tmp/x.json"
        "$OPENSCAD" -p "$tmp/x.json" -P t -o "$tmp/x.csg" scad/bioreactor.scad 2>"$tmp/xe" >/dev/null
        if ! grep -q '^ERROR' "$tmp/xe"; then
            echo "FAIL  $param accepted a name nothing is registered under"
            failed=1
        fi
    fi
done
[ $failed -eq 0 ] && echo "ok    every build parameter reaches the model, and a bad name is refused"
exit $failed
