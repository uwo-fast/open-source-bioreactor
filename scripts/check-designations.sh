#!/usr/bin/env bash
#
# Fail when a designation stops reaching the model.
#
: "${OPENSCAD:=openscad}"

# A designation is a string a build states and a registry answers to - the vessel, the shaft,
# the plug o-ring, the light, the two probes. Nothing else in the suite exercises one:
# check-echo sweeps jars, check-scad renders defaults, and a lookup that quietly returned
# undef for every name would pass both. That is not hypothetical - nine by_name wrappers shipped
# once with no `use <../utils/registries.scad>`, every one answering undef, and the round-trip
# test meant to catch it passed because it included a file whose own `use` leaked the function in.
#
# Two kinds of row, because two things can break:
#   differs - the value must change the geometry. Proves the designation reaches the model
#             rather than resolving and being dropped on the floor.
#   builds  - it must resolve and render. Some designations legitimately cannot move geometry:
#             every registered AS568 ring shares a 2.62 cord and the groove is cut from the
#             cord, so pinning a different one changes the stretch and not the shape.
#   number  - not a name at all. A build parameter that is a plain number carries through the
#             same build list and can stop reaching the model the same way, so it gets the
#             differs test - but there is no registry to give it a bad name from.
# The two name kinds also get a name nothing answers to, which must FAIL - that is what proves
# the lookup reads its argument instead of always handing back a row.
#
# Driven by a PARAMETER SET, not by -D, and that is the whole point. -D reaches a `use`d file's
# globals, so a row for a parameter both bioreactor.scad and head.scad declare - the lean ceiling,
# the fill fraction - would pass on the -D leak even with reactor_build broken. -p assigns only
# the file being rendered, so the value has to travel the build list to be seen. It is also the
# channel a real build uses.
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
    "culture_fill_fraction|0.7|number"
)
"$OPENSCAD" -o "$tmp/base.csg" scad/bioreactor.scad 2>"$tmp/be" >/dev/null
if grep -q '^ERROR' "$tmp/be"; then echo "FAIL  bioreactor.scad does not build at its defaults"; exit 1; fi
failed=0
for row in "${matrix[@]}"; do
    param="${row%%|*}"; rest="${row#*|}"; value="${rest%|*}"; want="${rest##*|}"
    case "$want" in
        number) json_value="$value"; shown="$param=$value" ;;
        *)      json_value="\"$value\""; shown="$param=\"$value\"" ;;
    esac
    printf '{"parameterSets":{"t":{"%s":%s}},"fileFormatVersion":"1"}' "$param" "$json_value" > "$tmp/p.json"
    "$OPENSCAD" -p "$tmp/p.json" -P t -o "$tmp/d.csg" scad/bioreactor.scad 2>"$tmp/e" >/dev/null
    if grep -q '^ERROR' "$tmp/e"; then
        echo "FAIL  $shown does not build"
        grep -m1 '^ERROR' "$tmp/e" | sed 's/.*failed: //; s/ in file.*//' | sed 's/^/        /'
        failed=1
    elif [ "$want" != builds ] && cmp -s "$tmp/base.csg" "$tmp/d.csg"; then
        echo "FAIL  $shown resolved but changed nothing - it is not reaching the model"
        failed=1
    else
        printf 'ok    %-18s %-12s %s\n' "$param" "$value" "$want"
    fi
    # a name nothing answers to has to fail, loudly. Only for the name kinds - a number has no
    # registry to be absent from.
    if [ "$want" != number ]; then
        printf '{"parameterSets":{"t":{"%s":"no_such_row"}},"fileFormatVersion":"1"}' "$param" > "$tmp/x.json"
        "$OPENSCAD" -p "$tmp/x.json" -P t -o "$tmp/x.csg" scad/bioreactor.scad 2>"$tmp/xe" >/dev/null
        if ! grep -q '^ERROR' "$tmp/xe"; then
            echo "FAIL  $param accepted a name nothing is registered under"
            failed=1
        fi
    fi
done
[ $failed -eq 0 ] && echo "ok    every build parameter reaches the model, and a bad name is refused"
exit $failed
