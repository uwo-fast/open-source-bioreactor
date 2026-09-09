#!/usr/bin/env bash
#
# Regenerate the Customizer parameter JSON from the registries.
#
: "${OPENSCAD:=openscad}"

set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
# Every designation and the registry it draws from. A dropdown is a hand-written comment, so it
# is the one place a registry's names are duplicated - this is what verifies the copy.
# The third field says whether "auto" is a legal value, which it is for anything derivable.
DESIGNATIONS="reactor_vessel_name:0 shaft_name:1 strip_light_name:1 plug_oring_name:1 \
              do_probe_name:1 ph_probe_name:1 gasket_sheet_name:1 motor_name:1"
{
  for inc in vessels shafts strip_lights orings atlas_probes gasket_sheets dc_motors; do
    printf 'include <%s/scad/purchased/%s.scad>\n' "$PWD" "$inc"
  done
  echo 'for (v = vessels)       echo(str("N|reactor_vessel_name|", vessel_name(v)));'
  echo 'for (t = shafts)        echo(str("N|shaft_name|", shaft_name(t)));'
  echo 'for (l = strip_lights)  echo(str("N|strip_light_name|", strip_light_name(l)));'
  echo 'for (r = orings)        echo(str("N|plug_oring_name|", oring_name(r)));'
  echo 'for (r = atlas_probes)  echo(str("N|do_probe_name|", atlas_probe_name(r)));'
  echo 'for (r = atlas_probes)  echo(str("N|ph_probe_name|", atlas_probe_name(r)));'
  echo 'for (r = gasket_sheets) echo(str("N|gasket_sheet_name|", gasket_sheet_name(r)));'
  echo 'for (r = dc_motors)     echo(str("N|motor_name|", dc_motor_name(r)));'
} > "$tmp/n.scad"
"$OPENSCAD" -o "$tmp/n.csg" "$tmp/n.scad" 2>"$tmp/err" >/dev/null
names=$(grep '^ECHO: "N|reactor_vessel_name|' "$tmp/err" | sed 's/^ECHO: "N|reactor_vessel_name|//; s/"$//')
if [ -z "$names" ]; then echo "FAIL  could not read the vessel registry"; exit 1; fi
failed=0
for f in scad/assembly.scad scad/head.scad scad/frame.scad; do
    # A dropdown is a comment, so it cannot derive - check it instead. Every designation this
    # file DECLARES WITH a dropdown is compared; one declared without a list is left alone,
    # because there is no copy to drift. A file that does not declare the parameter is skipped.
    #
    # Split on the commas FIRST and trim each field, rather than deleting every space in the
    # list. `tr -d ' '` worked only because vessel names happen to be identifier-shaped; the
    # moment a registry with spaced names is compared this way - "pH lab g2", "EPDM 1/16 60A" -
    # the listed name loses its spaces, the registry's does not, and the two never match.
    for spec in $DESIGNATIONS; do
        param="${spec%%:*}"; takes_auto="${spec#*:}"
        decl=$(grep -m1 "^$param" "$f" || true)
        [ -z "$decl" ] && continue
        case "$decl" in *'['*']'*) ;; *) continue ;; esac
        listed=$(echo "$decl" | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n' | sed 's/^ *//; s/ *$//')
        want=$(grep "^ECHO: \"N|$param|" "$tmp/err" | sed "s/^ECHO: \"N|$param|//; s/\"$//")
        [ "$takes_auto" = 1 ] && want=$(printf 'auto\n%s' "$want")
        if [ "$(echo "$want" | sort)" != "$(echo "$listed" | sort)" ]; then
            echo "FAIL  $f: the $param dropdown does not match its registry"
            diff <(echo "$want" | sort) <(echo "$listed" | sort) | sed 's/^/        /'
            failed=1
        fi
    done
    out="${f%.scad}.json"
    { echo '{'; echo '  "parameterSets": {'
      first=1
      while read -r n; do
          [ -z "$n" ] && continue
          [ $first -eq 0 ] && echo ','
          printf '    "%s": { "reactor_vessel_name": "%s" }' "$n" "$n"
          first=0
      done <<< "$names"
      echo; echo '  },'; echo '  "fileFormatVersion": "1"'; echo '}'
    } > "$out"
    echo "ok    $out  ($(echo "$names" | grep -c .) sets)"
done
exit $failed
