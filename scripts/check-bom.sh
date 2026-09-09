#!/usr/bin/env bash
#
# Fail when the purchase list misses a part the model prescribes.
#
: "${OPENSCAD:=openscad}"

set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/b.scad" <<SCAD
include <$PWD/scad/head.scad>
_v = reactor_vessel;
_m = vessel_opening_diameter(_v);
_p = head_ports_for(_m);
_ifaces = [for (i = bayonet_interfaces) if (len([for (q=_p) if (head_port_interface(q) == i) q]) > 0) i];
echo(str("BOM|", oring_part_number(head_plug_oring_selected(_m)), "|plug o-ring"));
for (i = _ifaces)
  echo(str("BOM|", oring_part_number(bayonet_oring(i)), "|", bayonet_name(i), " port o-ring"));
for (q = _p) if (head_port_type(q) == "thermocouple")
  echo(str("BOM|", thermocouple_probe_part_number(head_port_probe(q)), "|thermocouple"));
echo(str("BOM|", oring_part_number(bearing_oring), "|bearing rim seal"));
echo(str("BOM|", oring_part_number(tube_port_riser_oring), "|riser rod seal"));
echo(str("BOM|", shaft_part_number(head_shaft_selected(8, vessel_internal_height(_v))), "|impeller shaft"));
echo(str("BOM|", steel_tube_part_number(sparge_riser_tube), "|sparge riser tube"));
echo(str("BOM|", hose_clamp_part_number(sparge_riser_clamp), "|riser hose clamp"));
echo(str("BOM|", peri_pump_part_number(head_dosing_pump), "|dosing pump"));
echo(str("BOM|", set_screw_part_number(impeller_set_screw), "|impeller set screw"));
echo(str("BOM|", heat_set_insert_part_number(motor_mount_base_insert), "|motor mount heat-set insert"));
echo(str("BOM|", gas_filter_part_number(sparge_inlet_filter), "|sterile inlet filter"));
echo(str("BOM|", check_valve_part_number(sparge_check_valve), "|gas line check valve"));
SCAD
"$OPENSCAD" -o "$tmp/b.csg" "$tmp/b.scad" 2>"$tmp/err" >/dev/null
# the part_number COLUMN, so a match cannot come from a stale URL elsewhere in the row.
# The system python, not the analysis venv's: this reads a CSV with the stdlib and has no business
# requiring the analysis venv, which carries pandas and matplotlib and does not exist
# on a clean checkout - the gate would have failed on any machine that had not run
# `just analysis-setup` first, CI included.
/usr/bin/python3 -c 'import csv;print("\n".join(r["part_number"].strip() for r in csv.DictReader(open("purchased-parts.csv"))))' > "$tmp/pns"
lines=$(grep -oE 'BOM\|[^|]*\|[^"]*' "$tmp/err" || true)
if [ -z "$lines" ]; then echo "FAIL  could not read what the model prescribes"; exit 1; fi
failed=0
while IFS='|' read -r _ pn what; do
    # An EMPTY part number used to be skipped, which made a registry row with part_no "" invisible
    # to this check - the same silence the undef branch exists to break. It fails now.
    if [ -z "$pn" ]; then
        echo "FAIL  the $what prescribes an empty part number"; failed=1
    elif [ "$pn" = "undef" ]; then
        echo "FAIL  the $what has no part number in its registry"; failed=1
    elif ! grep -qxF "$pn" "$tmp/pns"; then
        echo "FAIL  the model prescribes $pn for the $what, and purchased-parts.csv has no such row"
        failed=1
    fi
done <<< "$lines"
[ $failed -eq 0 ] && echo "ok    purchase list carries every part the model prescribes"
exit $failed
