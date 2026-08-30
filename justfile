PY := "analysis/.venv/bin/python"
OPENSCAD := env("OPENSCAD", "openscad")

# The files that are meant to render on their own. THE LIST IS THE RECORD - a new entry file fails
# check-scad until it is here, which is the point - and it lives up here because two recipes read
# it. check-scad asserts that everything else emits NO geometry; check-mesh builds these into
# solids. A second copy of this list would be a second answer to "what renders".
# What check-mesh does NOT build by default. Each of these renders every part it carries as one
# CGAL union, which is minutes to tens of minutes - assembly.scad passed fifteen without finishing,
# on a picture that unions purchased vitamins nobody prints. Named here rather than dropped
# quietly, and still reachable: `just check-mesh scad/head.scad` builds one however long it takes,
# which is what you want before committing to a print. Shrinking this list is not the work.
#
# head.scad is the one that no longer needs it: `just export-parts` CGAL-renders every part it
# carries, one at a time, which is finer than this recipe could ever be at the file level - and it
# reaches the pitched blade that custom/impeller.scad's own example does not. The remaining four
# are still only checked whole.
MESH_SLOW := "scad/assembly.scad scad/cart.scad scad/electronics_stand.scad scad/frame.scad \
scad/head.scad"

ENTRY := "scad/assembly.scad scad/bottle_holder.scad scad/cart.scad scad/electronics_stand.scad \
scad/frame.scad scad/head.scad scad/custom/bayonet_baffle_port.scad scad/custom/bayonet_port.scad \
scad/custom/bayonet_probe_port.scad scad/custom/bayonet_thermocouple_port.scad \
scad/custom/cylindrical_flex_collet.scad scad/custom/gasket_cutter.scad scad/custom/impeller.scad \
scad/custom/motor_mount.scad scad/custom/peri_pump_frame_mount.scad \
scad/custom/peri_pump_head.scad scad/custom/sheet_gasket.scad \
scad/custom/sparge_ring.scad"

# List available recipes.
default:
    @just --list

# Everything CI runs.
check: check-scad check-vessels check-json check-bom check-parts

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
    entry=({{ENTRY}})
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
            # SECOND PASS, with $fn forced to zero. Not a quality setting - zero is what $fn IS
            # unless something assigns it, and it means the fragment count comes from $fa and $fs
            # instead. OpenSCAD 2021.01 lets a module reached through `use` resolve $fn from its own
            # file; newer builds hand it the caller's. So a file that divides by $fn is fine here
            # and asserts on a nan the moment it is opened in a current GUI - which is exactly what
            # sparge_ring did, while this suite stayed green. CI cannot be on every version, so it
            # simulates the one it is not on.
            {{OPENSCAD}} -o "$out" -D '$fn=0' "$f" 2>"$tmp/err0"
            if grep -qE '^(ERROR|WARNING)' "$tmp/err0"; then
                echo "FAIL  $f  at \$fn=0"
                grep -E '^(ERROR|WARNING)' "$tmp/err0" | sort | uniq -c | sort -rn | head -3 | sed 's/^/        /'
                failed=1
            else
                printf 'ok    %-46s %s\n' "$f" "$([ "$renders" = 1 ] && echo "$size bytes" || echo 'no geometry')"
            fi
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
        "jar_1gal_155x251"    # a vertical DO probe runs 6.29 mm through the upper impeller,
                              # and the motor mount overlaps the port flanges by 8.30 mm
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
    echo(str("BOM|", hose_clamp_part_number(sparge_riser_clamp), "|riser hose clamp"));
    echo(str("BOM|", peri_pump_part_number(head_dosing_pump), "|dosing pump"));
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

# Fail when a render flag in head.scad or frame.scad reaches no row of a print manifest and is not
# declared here as something nobody prints.
#
# head_print_parts() is hand-written where the flags it drives are hand-written, so the two can
# drift in the one direction that matters: add a printed part, give it a flag, forget the manifest,
# and `just export-parts` quietly writes a print list one part short. Nothing else would notice -
# the geometry is fine, the export succeeds, and the part is simply never made.
#
# So `not_printed` below is the record, the same way `entry` and `broken` are. A new render flag
# fails this until someone either puts it in the manifest or says here why it makes nothing you
# print. It fails BOTH ways: a flag listed here that the manifest also covers means the list has
# gone stale.
#
# Fail when a printed part exists that the print manifest does not carry.
check-parts:
    #!/usr/bin/env bash
    set -uo pipefail
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
    not_printed=(
        render_all                  # the meta flag every other one is measured against
        render_bayonet_lock         # a view of channels the lid buries; the locks print WITH the lid
        render_culture              # the broth at the fill line, which is not a part
        render_motor                # vitamin
        render_motor_mount_inserts  # vitamin, and heat-set into the lid rather than printed
        render_motor_mount_screws   # vitamin
        render_shaft_coupler        # vitamin
        render_bearing              # vitamin
        render_ext_shaft            # vitamin
        render_set_screws           # vitamin
        render_probes               # vitamin - the Atlas bodies hanging in their collets
        render_seals                # purchased EPDM: the rim gasket, the plug ring, the port rings
        render_sparge_tubes         # vitamin - the 316 SS riser and support, bought as stock and cut
        render_tube_pinlock         # a whole CLASS of port at once; the manifest names each one
        render_probe_pinlock        # through port_to_render, which is what makes them separate
        render_thermocouple_pinlock # parts rather than one STL of five
        render_baffle_pinlock       #
        render_rods                 # vitamin - the M8 studding and its nuts, cut from stock
        render_lights               # vitamin - the LED strips the frame makes room for
    )
    cat > "$tmp/m.scad" <<SCAD
    include <$PWD/scad/assembly.scad>
    _v = reactor_vessel;
    for (p = head_print_parts(vessel_opening_diameter(_v), lid_flange_height,
                              vessel_internal_height(_v), vessel_punt_height(_v)))
      echo(str("PART|", p[2]));
    for (p = frame_print_parts(n_rods)) echo(str("PART|", p[2]));
    SCAD
    {{OPENSCAD}} -D render_all=false -o "$tmp/m.csg" "$tmp/m.scad" 2>"$tmp/err" >/dev/null
    manifest=$(grep '^ECHO: "PART|' "$tmp/err" | sed 's/^ECHO: "PART|//; s/"$//')
    if [ -z "$manifest" ]; then echo "FAIL  could not read the print manifest"; exit 1; fi
    failed=0
    for f in $(grep -hoE '^render_[a-z_]+' scad/head.scad scad/frame.scad | sort -u); do
        listed=0
        for n in "${not_printed[@]}"; do [ "$n" = "$f" ] && listed=1; done
        if grep -q -- "$f=true" <<< "$manifest"; then
            if [ "$listed" = 1 ]; then
                echo "FAIL  $f  is in the manifest AND listed as not printed - drop it from one"
                failed=1
            fi
        elif [ "$listed" = 0 ]; then
            echo "FAIL  $f  renders something no print manifest row asks for"
            echo "        add it to head_print_parts() or frame_print_parts(), whichever file it is"
            echo "        in, or to not_printed in check-parts if it makes nothing anybody prints"
            failed=1
        fi
    done
    # AND EVERY ENTRY FILE IS ACCOUNTED FOR, which is the other half of the same hole. The two
    # manifests live in head.scad and frame.scad, so a printed part in any OTHER file that renders
    # on its own reaches no print list and nothing notices - true today of the pump mount, the cart,
    # the stand and the bottle holder. This does not put them on a list. It stops the omission being
    # silent, which is what let the print list call itself the whole reactor while covering two
    # files of eighteen.
    exported=(scad/head.scad scad/frame.scad)
    not_exported=(
        scad/assembly.scad                          # the whole reactor as a picture, not a part
        scad/custom/bayonet_baffle_port.scad        # a COMPONENT: head.scad renders it into a
        scad/custom/bayonet_port.scad               # manifest row of its own, so it reaches a print
        scad/custom/bayonet_probe_port.scad         # list through head rather than on its own. Its
        scad/custom/bayonet_thermocouple_port.scad  # standalone render is a preview of the part,
        scad/custom/cylindrical_flex_collet.scad    # not a second copy of it
        scad/custom/gasket_cutter.scad
        scad/custom/impeller.scad
        scad/custom/motor_mount.scad
        scad/custom/sparge_ring.scad
        scad/custom/sheet_gasket.scad               # EPDM cut from a sheet with a knife, not printed
        scad/bottle_holder.scad                     # bench furniture AROUND the reactor rather than
        scad/cart.scad                              # part of it. Printed, and on no print list -
        scad/electronics_stand.scad                 # see TODO.md, they want manifests of their own
        scad/custom/peri_pump_frame_mount.scad      # printed and part of the reactor, but waiting on
                                                    # where the bought pumps mount at all
        scad/custom/peri_pump_head.scad             # a stretch goal rather than this build
    )
    for f in {{ENTRY}}; do
        seen=0
        for e in "${exported[@]}"; do [ "$e" = "$f" ] && seen=$((seen + 1)); done
        for n in "${not_exported[@]}"; do [ "$n" = "$f" ] && seen=$((seen + 2)); done
        if [ "$seen" = 0 ]; then
            echo "FAIL  $f  renders on its own and reaches no print list"
            echo "        give it a manifest and walk it in export-parts, or say here why not"
            failed=1
        elif [ "$seen" = 3 ]; then
            echo "FAIL  $f  is both walked by export-parts and declared as not walked"
            failed=1
        fi
    done

    [ $failed -eq 0 ] && echo "ok    every printed part is on the print manifest"
    exit $failed

# Export every printed part of one build as its own STL, with a print list beside them.
#
# THE COMPLEMENT OF THE PURCHASE LIST. A purchase list only knows about things you buy, so the
# sparge ring, the mirrored second impeller and every port half appear nowhere else - and nothing
# would remind you to make them. head_print_parts() in head.scad is the statement of what they are.
# It has to live there rather than here because the list VARIES WITH THE VESSEL: a narrow jar
# carries six ports where a wide one carries twelve. Each row also carries the flags that render
# itself, so this recipe does what the rows say and knows nothing about any part.
#
# It also does per-PART what check-mesh does per FILE, which is the one thing that recipe cannot
# reach. custom/impeller.scad's own example renders the TWISTED blade, so the pitched one the build
# actually uses is only reachable through head.scad - which is on check-mesh's slow list. Every
# part here is CGAL-rendered and checked for a manifold on the way past.
#
# MINUTES, NOT SECONDS: every part re-evaluates the whole of head.scad, about a minute apiece.
#
# `just export-parts` takes the vessel the model selects. Naming another uses the parameter sets
# `just json` writes - and today only the selected one gets all the way through, because the probe
# tilt and the working volume are pinned to it. A jar that fails is reported rather than skipped.
#
# Export every printed part as its own STL, with a print list. `just export-parts <vessel>` for one.
export-parts vessel="" out="output":
    #!/usr/bin/env bash
    # A failing render still exits 0 and writes a small file, the same as check-mesh, so nothing
    # here may be gated on $?. stderr is the signal and the file size is the backstop.
    set -uo pipefail
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT

    sel=()
    label="{{vessel}}"
    if [ -n "{{vessel}}" ]; then sel=(-p scad/head.json -P "{{vessel}}"); fi

    # Ask the model what it prints. Through ASSEMBLY, because that is the file that owns both
    # halves - the flange height and the rod count are chosen there and the head and the frame both
    # build to them, so asking either one directly would be reading a preview's copy. A stub rather
    # than a render, and with render_all off, so it costs a second where the assembly costs minutes.
    #
    # Each row says which FILE renders it, since that is the one thing a manifest row cannot carry
    # about itself.
    cat > "$tmp/m.scad" <<SCAD
    include <$PWD/scad/assembly.scad>
    _v = reactor_vessel;
    for (p = head_print_parts(vessel_opening_diameter(_v), lid_flange_height,
                              vessel_internal_height(_v), vessel_punt_height(_v)))
      echo(str("PART|scad/head.scad|", p[0], "|", p[1], "|", p[2]));
    for (p = frame_print_parts(n_rods))
      echo(str("PART|scad/frame.scad|", p[0], "|", p[1], "|", p[2]));
    echo(str("VESSEL|", vessel_name(_v)));
    SCAD
    {{OPENSCAD}} "${sel[@]}" -D render_all=false -o "$tmp/m.csg" "$tmp/m.scad" 2>"$tmp/err" >/dev/null
    if grep -q '^ERROR' "$tmp/err"; then
        echo "FAIL  ${label:-the selected vessel} does not resolve, so there is nothing to export"
        grep -m1 '^ERROR' "$tmp/err" | sed 's/^/        /'
        exit 1
    fi
    # What the model actually resolved, which is not always what was asked for: OpenSCAD ignores a
    # -P naming a set that does not exist and silently falls back to the file's own defaults. Left
    # unchecked that writes a directory labelled with one jar and full of another one's parts.
    got=$(grep -m1 '^ECHO: "VESSEL|' "$tmp/err" | sed 's/.*VESSEL|//; s/"$//')
    if [ -n "$label" ] && [ "$label" != "$got" ]; then
        echo "FAIL  no parameter set is named $label - the model resolved $got instead"
        echo "        the sets come from the vessel registry; run just json after adding a jar"
        exit 1
    fi
    label="$got"
    rows=$(grep '^ECHO: "PART|' "$tmp/err" | sed 's/^ECHO: "PART|//; s/"$//')
    if [ -z "$rows" ]; then echo "FAIL  the model lists no printed parts"; exit 1; fi

    dir="{{out}}/$label"
    mkdir -p "$dir"
    list="$dir/print-list.md"
    : > "$tmp/rows.md"
    failed=0
    pieces=0
    parts=0

    while IFS='|' read -r file name qty flags; do
        [ -z "$name" ] && continue
        parts=$((parts + 1))
        pieces=$((pieces + qty))
        out="$dir/$name.stl"
        # The vessel selection only reaches head.scad: frame.scad has no parameter set and builds
        # the jar named in its own preview, so handing it -P would look like it worked and quietly
        # produce another jar's frame. Naming a vessel already fails on the head before it gets
        # here, so this is a latent gap rather than a live one - it is in TODO.md.
        fsel=(); [ "$file" = "scad/head.scad" ] && fsel=("${sel[@]}")
        # render_all overrides every other flag, so it has to go off before the row's own go on.
        {{OPENSCAD}} ${fsel[@]+"${fsel[@]}"} -D render_all=false $flags -o "$out" "$file" 2>"$tmp/e" >/dev/null
        size=$(stat -c%s "$out" 2>/dev/null || echo 0)
        tris=$(grep -c '^ *facet' "$out" 2>/dev/null || echo 0)
        # The bounding box, because "will this fit my printer" is the question the baffle is split
        # to answer and a triangle count cannot answer it. Read off the mesh rather than asked of
        # the model, so it measures what was actually exported.
        raw=$(awk '/^ *vertex/ {
            if (n++ == 0) { x1=x2=$2; y1=y2=$3; z1=z2=$4 }
            else {
                if ($2<x1) x1=$2; if ($2>x2) x2=$2
                if ($3<y1) y1=$3; if ($3>y2) y2=$3
                if ($4<z1) z1=$4; if ($4>z2) z2=$4
            }
        } END { if (n) printf "%.2f %.2f %.2f", x2-x1, y2-y1, z2-z1 }' "$out" 2>/dev/null)
        box=$(echo "$raw" | awk '{ printf "%.0f x %.0f x %.0f", $1, $2, $3 }')
        if grep -q '^ERROR' "$tmp/e"; then
            echo "FAIL  $name"; grep -m1 '^ERROR' "$tmp/e" | sed 's/^/        /'; failed=1
            printf '| %s | %s | — | — | **did not build** |\n' "$name" "$qty" >> "$tmp/rows.md"
        elif grep -qi '2-manifold' "$tmp/e"; then
            echo "FAIL  $name  not a valid 2-manifold"; failed=1
            printf '| %s | %s | `%s.stl` | — | **not a 2-manifold** |\n' "$name" "$qty" "$name" >> "$tmp/rows.md"
        elif [ "$size" -le 1 ]; then
            echo "FAIL  $name  rendered nothing"; failed=1
            printf '| %s | %s | — | — | **rendered nothing** |\n' "$name" "$qty" >> "$tmp/rows.md"
        else
            printf 'ok    %-28s x%-3s %-16s %s triangles\n' "$name" "$qty" "$box mm" "$tris"
            printf '| %s | %s | `%s.stl` | %s | %s |\n' "$name" "$qty" "$name" "$box" "$tris" >> "$tmp/rows.md"
            echo "$name $raw" >> "$tmp/sizes"
        fi
    done <<< "$rows"

    # WHICH PRINTERS TAKE THESE, asked of the model rather than worked out here. The rule for
    # whether a box fits a bed lives in purchased/printers.scad and this passes it the sizes that
    # came off the meshes - so the registry decides, and there is no second copy of the arithmetic
    # in awk.
    #
    # REPORTED, not targeted. The design does not name a printer and bend itself to fit one; it is
    # what it is and this says what that needs. assembly.scad reports the same thing off the
    # geometry, and the two are now measuring the same set of parts - so if they ever disagree, a
    # part has fallen off a manifest. A part that fits NOTHING is the only thing that fails.
    {
        # printers.scad explicitly, not by way of head.scad: the fit rule is this stub's dependency
        # and it should say so rather than lean on another file's include chain.
        printf 'include <%s/scad/purchased/printers.scad>\n' "$PWD"
        printf 'include <%s/scad/assembly.scad>\n_s = [' "$PWD"
        while read -r n w d h; do printf '["%s", [%s, %s, %s]],' "$n" "$w" "$d" "$h"; done < "$tmp/sizes"
        printf '];\n'
        printf 'for (s = _s) if (len(printers_fitting(s[1])) == 0) echo(str("NOFIT|", s[0]));\n'
        printf 'echo(str("ALLFIT|", [for (p = printers) if (len([for (s = _s) if (!printer_fits(p, s[1])) 1]) == 0) printer_name(p)]));\n'
    } > "$tmp/fit.scad"
    {{OPENSCAD}} "${sel[@]}" -D render_all=false -o "$tmp/fit.csg" "$tmp/fit.scad" 2>"$tmp/fit" >/dev/null
    allfit=$(grep -m1 '^ECHO: "ALLFIT|' "$tmp/fit" | sed 's/.*ALLFIT|//; s/"$//; s/[]["]//g')
    for m in $(grep '^ECHO: "NOFIT|' "$tmp/fit" | sed 's/.*NOFIT|//; s/"$//'); do
        echo "FAIL  $m  fits no registered printer at all - see scad/purchased/printers.scad"
        failed=1
    done
    [ -n "$allfit" ] && echo "ok    every exported part fits: $allfit"

    { echo "# Print list — $label"
      echo
      echo "$pieces pieces, $parts distinct parts. Written by \`just export-parts\`; the model is the"
      echo "authority and this is a transcript of it, so regenerate rather than editing."
      echo
      echo "Transparent PETG for anything the culture touches, grey for structure. The gasket cutter"
      echo "is a tool rather than a part of the reactor, and you need it to cut the rim gasket."
      echo "Assembly, and the numbers that go with it, are in [docs/build.md](../../docs/build.md)."
      echo
      echo "**This is the reactor's own parts** - the lid and everything hanging from it, and the"
      echo "frame's base, top base, ribs and rod spacers. It is NOT everything this repo prints: the"
      echo "cart, the electronics stand, the bottle holder and the peri pump mount each render from"
      echo "their own file and reach no manifest, which \`just check-parts\` records rather than"
      echo "hides. The frame is built at the vessel named in \`frame.scad\`'s own preview, which is"
      echo "the only jar this exports today anyway."
      echo
      echo "**Printers that take every part on this list:** $allfit. Reported, not targeted - the"
      echo "design is what it is and this says what it needs, measured off the meshes below rather"
      echo "than off the model. \`scad/assembly.scad\` reports the same thing from the geometry and"
      echo "should agree; the two disagreeing means a part is not on this list."
      echo "Volumes: [scad/purchased/printers.scad](../../scad/purchased/printers.scad)."
      echo
      echo "Sizes are the exported mesh's own bounding box. Each part is written where it sits in the"
      echo "assembly rather than at the origin, so let the slicer place it - what the size column is"
      echo "for is whether it fits the bed at all. The baffle pieces are the ones to watch."
      echo
      echo '| part | qty | file | size, mm | triangles |'
      echo '| --- | --- | --- | --- | --- |'
      cat "$tmp/rows.md"
      echo
      echo "The bought parts are in [purchased-parts.csv](../../purchased-parts.csv)."
    } > "$list"

    echo "ok    $list  ($pieces pieces, $parts parts)"
    exit $failed

# Build the entry files into SOLIDS, which nothing else here does.
#
# check-scad exports .csg - the CSG tree, not a mesh - so CGAL never runs and a degenerate solid is
# invisible to it. That is how a pitched blade sat TANGENT to its hub, joined along a line of zero
# width with 264 non-manifold edges, through a green suite; anyone slicing the STL would have met it
# immediately.
#
# NOT part of `just check`, and that is a deliberate trade. head.scad takes minutes to render where
# its .csg takes seconds, and `check` is the loop you run on every edit. Run this before printing.
# The risk is the usual one - a check nobody runs is a check that does not exist - so it belongs in
# the build instructions beside the print list.
#
# Build entry files into solids and fail on a non-manifold. `just check-mesh <file>` for one.
check-mesh file="":
    #!/usr/bin/env bash
    # A failing render still exits 0 and writes a small file, so nothing may be gated on $?. The
    # manifold complaint on stderr is the signal and the file size is the backstop.
    set -uo pipefail
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
    if [ -n "{{file}}" ]; then
        targets="{{file}}"
    else
        targets=""
        for f in {{ENTRY}}; do
            slow=0
            for s in {{MESH_SLOW}}; do [ "$s" = "$f" ] && slow=1; done
            [ "$slow" = 0 ] && targets="$targets $f"
        done
        for s in {{MESH_SLOW}}; do
            printf 'skip  %-46s minutes to build; pass it as an argument\n' "$s"
        done
    fi
    failed=0
    for f in $targets; do
        out="$tmp/$(echo "$f" | tr / _).stl"
        {{OPENSCAD}} -o "$out" "$f" 2>"$tmp/err" >/dev/null
        size=$(stat -c%s "$out" 2>/dev/null || echo 0)
        if grep -qi '2-manifold' "$tmp/err"; then
            echo "FAIL  $f  not a valid 2-manifold"
            grep -i '2-manifold' "$tmp/err" | head -2 | sed 's/^/        /'
            failed=1
        elif grep -q '^ERROR' "$tmp/err"; then
            echo "FAIL  $f"
            grep '^ERROR' "$tmp/err" | head -2 | sed 's/^/        /'
            failed=1
        elif [ "$size" -le 1 ]; then
            echo "FAIL  $f  rendered nothing"
            failed=1
        else
            printf 'ok    %-46s %s triangles\n' "$f" "$(grep -c '^ *facet' "$out" 2>/dev/null || echo '?')"
        fi
    done
    exit $failed
