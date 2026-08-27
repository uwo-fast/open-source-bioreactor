PY := "analysis/.venv/bin/python"
OPENSCAD := env("OPENSCAD", "openscad")

# List available recipes.
default:
    @just --list

# Everything CI runs.
check: check-scad check-vessels check-json check-bom

# Evaluate every SCAD file and report anything that does not build.
check-scad:
    #!/usr/bin/env bash
    # A failing CSG export still exits 0 and writes a 1 byte file, so nothing here may be gated
    # on $?. ERROR on stderr is the signal; the file size is the backstop.
    #
    # Files are checked in both directions. The ones listed below are meant to render on their
    # own and must emit geometry. Every other file is include'd or use'd by something and must
    # emit none - a registry that draws its own example draws it into every consumer, which is
    # what 1a6df3d fixed. A new entry file therefore fails until it is listed, which is the
    # point: the list is the record of what renders.
    #
    # Run with default render flags. render_all is declared in assembly.scad, head.scad and
    # frame.scad, so -D render_all=false sets all three and leaves 4 of the 36 asserts standing.
    set -uo pipefail
    entry=(
        scad/assembly.scad
        scad/bottle_holder.scad
        scad/cart.scad
        scad/electronics_stand.scad
        scad/frame.scad
        scad/head.scad
        scad/custom/bayonet_baffle_port.scad
        scad/custom/bayonet_port.scad
        scad/custom/bayonet_probe_port.scad
        scad/custom/bayonet_thermocouple_port.scad
        scad/custom/cylindrical_flex_collet.scad
        scad/custom/gasket_cutter.scad
        scad/custom/impeller.scad
        scad/custom/motor_mount.scad
        scad/custom/peri_pump_frame_mount.scad
        scad/custom/sheet_gasket.scad
        scad/custom/sparge_ring.scad
    )
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
    failed=0
    while read -r f; do
        renders=0
        for e in "${entry[@]}"; do [ "$e" = "$f" ] && renders=1; done
        out="$tmp/$(echo "$f" | tr / _).csg"
        {{OPENSCAD}} -o "$out" "$f" 2>"$tmp/err"
        size=$(stat -c%s "$out" 2>/dev/null || echo 0)
        if grep -q '^ERROR' "$tmp/err"; then
            echo "FAIL  $f"
            grep '^ERROR' "$tmp/err" | sed 's/^/        /'
            failed=1
        elif grep -q '^WARNING' "$tmp/err"; then
            # Warnings are how OpenSCAD reports an undef reaching arithmetic, and a parse error in
            # a use'd file shows up as nothing else - ninety of them once rode in on a missing
            # comma between two string literals, which silently stopped head.scad exporting any of
            # its functions while it still rendered on its own. Nothing here may be warning-noisy.
            echo "FAIL  $f"
            grep '^WARNING' "$tmp/err" | sort | uniq -c | sort -rn | head -5 | sed 's/^/        /'
            failed=1
        elif [ "$renders" = 1 ] && [ "$size" -le 1 ]; then
            echo "FAIL  $f  renders nothing"
            failed=1
        elif [ "$renders" = 0 ] && [ "$size" -gt 1 ]; then
            echo "FAIL  $f  emits $size bytes into every consumer; add it to entry if it renders"
            failed=1
        else
            printf 'ok    %-46s %s\n' "$f" "$([ "$renders" = 1 ] && echo "$size bytes" || echo 'no geometry')"
        fi
    done < <(find scad -name '*.scad' -not -path '*/_archive/*' -not -path '*/_shelf/*' | sort)
    exit $failed

# Render head.scad against every registered vessel, not just the selected one.
check-vessels:
    #!/usr/bin/env bash
    # check-scad renders each file once, at its defaults, and head.scad defaults to the one jar
    # that works. So five of six registered vessels were unbuildable for months while check-scad
    # stayed green - nothing ever built the others. This recipe builds them all.
    #
    # `broken` below is the record of what does not build, the same way `entry` above is the record
    # of what renders. It fails BOTH ways on purpose: an unlisted vessel that breaks is a
    # regression, and a listed vessel that builds means the list has gone stale and the fix went
    # unnoticed. Shrinking this list is the work.
    set -uo pipefail
    broken=(
        "jar_1p5L_109x215"    # motor mount overlaps the port flanges by 12.45 mm
        "jar_1gal_155x251"    # motor mount overlaps the port flanges by 8.30 mm
    )
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    # The registry is the source of the list, so adding a jar adds it to the sweep.
    printf 'include <%s/scad/purchased/vessels.scad>\nfor (v = vessels) echo(str("V|", vessel_name(v), "|", v));\n' "$PWD" > "$tmp/rows.scad"
    {{OPENSCAD}} -o "$tmp/rows.csg" "$tmp/rows.scad" 2>"$tmp/rows.err" >/dev/null
    rows=$(grep '^ECHO: "V|' "$tmp/rows.err" | sed 's/^ECHO: "V|//; s/"$//')
    if [ -z "$rows" ]; then echo "FAIL  could not read the vessel registry"; exit 1; fi
    failed=0
    while IFS='|' read -r name row; do
        listed=0
        for b in "${broken[@]}"; do [ "$b" = "$name" ] && listed=1; done
        # Two of this build's numbers are unset for the sweep, for the same reason.
        #
        # A WORKING VOLUME is a property of a run on one jar, not of the design - 8.25 L is this
        # build's statement and it is a third of jar_6p5gal, which leaves its thermocouple in the
        # headspace and rightly asserts.
        #
        # A PROBE LEAN is the same. The DO probe leans 4.5 degrees here because that is what
        # jar_10L's internals and mouth allow; jar_1gal_180x197 is shorter, so its DO tip reaches
        # the sparge ring and its ceiling is about 2.5. One number cannot suit six jars, and making
        # it try is how a jar that builds perfectly well gets called broken.
        #
        # What is being checked here is whether each jar can be BUILT, so each is swept at the
        # values that scale - vertical clears every jar's internals - and the pinned figures are
        # checked by check-scad against the jar they were chosen for.
        {{OPENSCAD}} -D "reactor_vessel=$row" -D "culture_working_volume=undef" \
            -D "do_probe_port_tilt_degrees=0" -D "ph_probe_port_tilt_degrees=0" \
            -o "$tmp/v.csg" scad/head.scad 2>"$tmp/err" >/dev/null
        if grep -q '^ERROR' "$tmp/err"; then
            if [ "$listed" = 1 ]; then
                printf 'ok    %-22s known broken: %s\n' "$name" "$(grep -m1 '^ERROR' "$tmp/err" | sed 's/.*failed: //; s/ in file.*//' | cut -c1-70)"
            else
                echo "FAIL  $name  builds no longer"
                grep -m1 '^ERROR' "$tmp/err" | sed 's/^/        /'
                failed=1
            fi
        elif [ "$listed" = 1 ]; then
            echo "FAIL  $name  now builds, but is still listed as broken - remove it from check-vessels"
            failed=1
        else
            printf 'ok    %-22s builds\n' "$name"
        fi
    done <<< "$rows"
    exit $failed

# Create the analysis virtualenv from analysis/pyproject.toml.
analysis-setup:
    uv venv analysis/.venv
    uv pip install --python {{PY}} -r analysis/pyproject.toml

# Rebuild every run and method, with verification.
analysis: analysis-all

analysis-all:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in analysis/runs/*/pipeline.py analysis/methods/*/pipeline.py; do
        echo "=== $p"
        {{PY}} "$p" --verify
    done

# Rebuild one run, e.g. `just analysis-run 2026-07-23-chlorella-ccpc90`.
analysis-run name:
    {{PY}} analysis/runs/{{name}}/pipeline.py --verify

# Rebuild one method, e.g. `just analysis-method light-irradiance`.
analysis-method name:
    {{PY}} analysis/methods/{{name}}/pipeline.py --verify

# Fail when a part the model PRESCRIBES is not on the purchase list.
#
# Only the registries that carry a part number can be checked - orings, shafts, thermocouple
# probes, set screws and steel tubes - so this is a floor, not a full audit. It is worth having
# anyway: the CSV has now drifted behind the model twice in two days, once carrying a 9 in
# thermocouple the model had replaced because it went through a jar's floor, and once missing the
# mini port seal entirely.
#
# What it checks is what the model SELECTS for the reference build, not everything registered.
# Twenty-two plug o-rings are registered and one is bought.
#
# It compares the part_number FIELD, not the file. A plain grep passes on a number that survives
# only in a stale URL, which is exactly what the first version did - it reported the purchase list
# clean while the thermocouple row named a part the model had replaced.
check-bom:
    #!/usr/bin/env bash
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
    echo(str("BOM|", shaft_part_number(head_shaft_selected(8, vessel_internal_height(_v))), "|impeller shaft"));
    echo(str("BOM|", steel_tube_part_number(sparge_riser_tube), "|sparge riser tube"));
    echo(str("BOM|", set_screw_part_number(impeller_set_screw), "|impeller set screw"));
    SCAD
    {{OPENSCAD}} -o "$tmp/b.csg" "$tmp/b.scad" 2>"$tmp/err" >/dev/null
    # the part_number COLUMN, so a match cannot come from a stale URL elsewhere in the row
    {{PY}} -c 'import csv;print("\n".join(r["part_number"].strip() for r in csv.DictReader(open("purchased-parts.csv"))))' > "$tmp/pns"
    lines=$(grep -oE 'BOM\|[^|]*\|[^"]*' "$tmp/err" || true)
    if [ -z "$lines" ]; then echo "FAIL  could not read what the model prescribes"; exit 1; fi
    failed=0
    while IFS='|' read -r _ pn what; do
        [ -z "$pn" ] && continue
        if [ "$pn" = "undef" ]; then
            echo "FAIL  the $what has no part number in its registry"; failed=1
        elif ! grep -qxF "$pn" "$tmp/pns"; then
            echo "FAIL  the model prescribes $pn for the $what, and purchased-parts.csv has no such row"
            failed=1
        fi
    done <<< "$lines"
    [ $failed -eq 0 ] && echo "ok    purchase list carries every part the model prescribes"
    exit $failed

# Fail if the generated parameter files are stale or the dropdowns have drifted from the registry.
# Regenerating is cheap and the files are committed, so a diff means someone added a jar without
# running `just json` - which would leave the customizer offering a vessel that no longer exists,
# or hiding one that does.
check-json:
    #!/usr/bin/env bash
    set -uo pipefail
    before=$(cat scad/assembly.json scad/head.json 2>/dev/null || true)
    just json > /dev/null || { echo "FAIL  the dropdowns have drifted - run just json"; exit 1; }
    if [ "$before" != "$(cat scad/assembly.json scad/head.json)" ]; then
        echo "FAIL  parameter files were stale - run just json and commit the result"; exit 1
    fi
    echo "ok    parameter files match the registry"

# Write one customizer parameter set per registered vessel, beside each entry file that takes one.
# OpenSCAD picks up <file>.json automatically, so the presets appear in the customizer's dropdown,
# and `openscad -p <file>.json -P <vessel> ...` selects one from a script.
#
# Generated from the registry rather than written by hand, for the same reason check-vessels sweeps
# it: adding a jar should add it everywhere it belongs and nowhere should have to be remembered.
# The recipe also checks the dropdown annotation in each file against the registry, which is the one
# place the names are still duplicated - a comment cannot be derived, but it can be verified.
json:
    #!/usr/bin/env bash
    set -uo pipefail
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
    printf 'include <%s/scad/purchased/vessels.scad>\nfor (v = vessels) echo(str("N|", vessel_name(v)));\n' "$PWD" > "$tmp/n.scad"
    {{OPENSCAD}} -o "$tmp/n.csg" "$tmp/n.scad" 2>"$tmp/err" >/dev/null
    names=$(grep '^ECHO: "N|' "$tmp/err" | sed 's/^ECHO: "N|//; s/"$//')
    if [ -z "$names" ]; then echo "FAIL  could not read the vessel registry"; exit 1; fi
    failed=0
    for f in scad/assembly.scad scad/head.scad; do
        # the dropdown is a comment, so it cannot derive - check it instead
        listed=$(grep -m1 '^reactor_vessel_name' "$f" | sed 's/.*\[\(.*\)\].*/\1/' | tr -d ' ' | tr ',' '\n')
        if [ "$(echo "$names" | sort)" != "$(echo "$listed" | sort)" ]; then
            echo "FAIL  $f dropdown does not match the registry"
            diff <(echo "$names" | sort) <(echo "$listed" | sort) | sed 's/^/        /'
            failed=1
        fi
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
