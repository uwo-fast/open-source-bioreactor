PY := "analysis/.venv/bin/python"
OPENSCAD := env("OPENSCAD", "openscad")

# The files that are meant to render on their own. THE LIST IS THE RECORD - a new entry file fails
# check-scad until it is here, which is the point - and it lives up here because two recipes read
# it. check-scad asserts that everything else emits NO geometry; check-mesh builds these into
# solids. A second copy of this list would be a second answer to "what renders".
# What check-mesh does NOT build by default. The reason DIFFERS per file, so the recipe prints one
# for each rather than calling them all slow, which is what it used to do and was wrong about.
# Measured 2026-08-31, not assumed:
#
#   head.scad       not a 2-manifold as it previews. `just export-parts` already builds all 23 of
#                   its parts one at a time, which is finer than this file could ever be, and it
#                   reaches the pitched blade custom/impeller.scad's own example does not
#   frame.scad      a CLEAN 2-manifold, 141 s. Skipped for time alone; its parts are in that same
#                   export
#   assembly.scad   fifteen minutes without finishing. check-parts already calls it "the whole
#                   reactor as a picture, not a part"
#   cart.scad       not a 2-manifold as it previews, 515 s, and its corner bracket has no render of
#                   its own to build instead - see TODO.md, these files want manifests
#
# THE FAILURES ARE NOT DEFECTS IN ANYTHING PRINTED. head.scad's printed geometry on its own IS a
# 2-manifold, built in 501 s. Adding one vitamin group at a time to that base, three of them break
# it on their own - render_seals, render_probes, and render_bearing with render_shaft_coupler - and
# three do not: render_culture, render_set_screws, render_sparge_tubes. Every one of the three that
# break it is already on check-parts' not_printed list: EPDM in its grooves, Atlas bodies in their
# collets, a bearing and a coupling on the shaft. So the check was failing on vitamins this repo
# has formally declared are not printed. It could not pass, and nothing about it was actionable.
# (render_motor with its inserts and screws was not measured - the sweep was stopped there.)
#
# electronics_stand.scad came OFF this list. It builds in 14 s rather than minutes, and
# `-D print_corner=true` gives its printed bracket as a clean 2-manifold in 4. It is checked now.
MESH_SKIP := "scad/assembly.scad scad/cart.scad scad/frame.scad scad/head.scad"

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
check: check-scad check-vessels check-designations check-json check-bom check-parts

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

# Render every entry file against every registered vessel, not just the selected one.
check-vessels:
    #!/usr/bin/env bash
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
    # Which variable carries the jar. frame.scad has no selector of its own yet - its vessel is a
    # private preview variable rather than a customizer parameter, which is also why it has no
    # .json. See TODO.md, tooling.
    vessel_var() { case "$1" in frame) echo _preview_vessel ;; *) echo reactor_vessel ;; esac; }
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    # The registry is the source of the list, so adding a jar adds it to the sweep.
    printf 'include <%s/scad/purchased/vessels.scad>\nfor (v = vessels) echo(str("V|", vessel_name(v), "|", v));\n' "$PWD" > "$tmp/rows.scad"
    {{OPENSCAD}} -o "$tmp/rows.csg" "$tmp/rows.scad" 2>"$tmp/rows.err" >/dev/null
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
            {{OPENSCAD}} -D "$(vessel_var "$f")=$row" -o "$tmp/v.csg" "scad/$f.scad" 2>"$tmp/err" >/dev/null
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
    exit $failed

# Lines of code, comment and blank, per language.
#
# NOT PART OF `just check`, and not a gate on anything. It reports; a number that cannot fail is
# not a check, and wiring it into the suite would make the suite fail on a machine that simply does
# not have the tool.
#
# WHAT IS WORTH LOOKING AT HERE IS THE COMMENT SHARE, not the total. This model keeps its reasoning
# in the source - why a number is what it is, and what went wrong before it was - so the ratio is a
# property of the method rather than an accident. The SCAD tree is 3,852 comment to 4,907 code,
# 44 %.
# A sharp fall there means reasoning has started living somewhere it cannot be checked against the
# code it explains.
#
# cloc rather than tokei, and that is the whole point of this recipe: trixie's tokei is 12.1.2 and
# OpenSCAD only arrived upstream in 14.0.0, so tokei counts every .scad file as nothing at all. It
# was tried here and reported zero of them. cloc maps .scad natively and reads // and comment blocks
# the way OpenSCAD does.
#
# This recipe does not install anything. cloc is packaged, but what a workstation has belongs in
# workstation-configs rather than in a repo's build file - see the message below.
#
# Report lines of code and comment per language. Needs cloc.
stats:
    #!/usr/bin/env bash
    set -uo pipefail
    if ! command -v cloc >/dev/null 2>&1; then
        echo "cloc is not installed, so there is nothing to report."
        echo "        It is packaged - apt has 2.04 - but nothing here installs a tool: add it to"
        echo "        packages/dev.apt in CameronBrooks11/workstation-configs so every machine gets"
        echo "        the same one, then run this again."
        echo "        NOT tokei: trixie's is 12.1.2 and OpenSCAD only landed upstream in 14.0.0, so"
        echo "        it counts none of the SCAD tree, which is the one thing worth counting here."
        exit 1
    fi
    # --vcs=git so this counts what the repo actually carries: analysis/.venv, output/ and
    # working.tmp are all gitignored and drop out on their own. The cost is that a new file counts
    # only once it is tracked, which is the right side to err on for a figure about the method.
    #
    # CSV is data, never source, and two tracked instrument logs run to 740k lines - counted, they
    # bury every other language and the SUM stops meaning anything.
    #
    # _archive and _shelf are excluded from every other check too, so counting them here would make
    # this disagree with the rest of the tooling about what the model is.
    cloc --vcs=git --exclude-dir=_archive,_shelf --exclude-lang=CSV .

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

# Fail when a designation stops reaching the model.
check-designations:
    #!/usr/bin/env bash
    # A designation is a string a build states and a registry answers to - the vessel, the shaft,
    # the plug o-ring, the light, the two probes. Nothing else in the suite exercises one:
    # check-vessels sweeps jars, check-scad renders defaults, and a lookup that quietly returned
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
    # globals, so a row for a parameter both assembly.scad and head.scad declare - the lean ceiling,
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
        "do_probe_port_tilt_max|2|number"
        "culture_fill_fraction|0.7|number"
    )
    {{OPENSCAD}} -o "$tmp/base.csg" scad/assembly.scad 2>"$tmp/be" >/dev/null
    if grep -q '^ERROR' "$tmp/be"; then echo "FAIL  assembly.scad does not build at its defaults"; exit 1; fi
    failed=0
    for row in "${matrix[@]}"; do
        param="${row%%|*}"; rest="${row#*|}"; value="${rest%|*}"; want="${rest##*|}"
        case "$want" in
            number) json_value="$value"; shown="$param=$value" ;;
            *)      json_value="\"$value\""; shown="$param=\"$value\"" ;;
        esac
        printf '{"parameterSets":{"t":{"%s":%s}},"fileFormatVersion":"1"}' "$param" "$json_value" > "$tmp/p.json"
        {{OPENSCAD}} -p "$tmp/p.json" -P t -o "$tmp/d.csg" scad/assembly.scad 2>"$tmp/e" >/dev/null
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
            {{OPENSCAD}} -p "$tmp/x.json" -P t -o "$tmp/x.csg" scad/assembly.scad 2>"$tmp/xe" >/dev/null
            if ! grep -q '^ERROR' "$tmp/xe"; then
                echo "FAIL  $param accepted a name nothing is registered under"
                failed=1
            fi
        fi
    done
    [ $failed -eq 0 ] && echo "ok    every build parameter reaches the model, and a bad name is refused"
    exit $failed

# Fail when a part the model PRESCRIBES is not on the purchase list.
#
# Only the registries that carry a part number can be checked - orings, shafts, thermocouple
# probes, set screws, steel tubes, hose clamps, peri pumps and heat-set inserts - so this is a
# floor, not a full audit. Two prescriptions are deliberately absent: the gasket sheet and the drive
# motor. The sheet is not selected per build yet, and the motor's CSV part_number field is the
# compound string "RM-ESMO-071 (36PG-555PM-14-EN)", which grep -qxF can never match - normalize that
# column before enrolling it. The shaft coupling stays out because uxcell publish no number for it,
# so its registry returns undef by design and the undef branch below would fail on it. It is worth having
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
    echo(str("BOM|", heat_set_insert_part_number(motor_mount_base_insert), "|motor mount heat-set insert"));
    SCAD
    {{OPENSCAD}} -o "$tmp/b.csg" "$tmp/b.scad" 2>"$tmp/err" >/dev/null
    # the part_number COLUMN, so a match cannot come from a stale URL elsewhere in the row
    {{PY}} -c 'import csv;print("\n".join(r["part_number"].strip() for r in csv.DictReader(open("purchased-parts.csv"))))' > "$tmp/pns"
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
# The recipe also checks every dropdown annotation in each file against the registry it draws from,
# which is the one place a registry's names are still duplicated - a comment cannot be derived, but
# it can be verified. A designation declared WITHOUT a dropdown is left alone: there is no second
# copy of the names, so there is nothing to drift. That is the honest trade for a registry too long
# to list in a comment - the o-ring has 26 rows - and it is why adding a dropdown is safe.
json:
    #!/usr/bin/env bash
    set -uo pipefail
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
    # Every designation and the registry it draws from. A dropdown is a hand-written comment, so it
    # is the one place a registry's names are duplicated - this is what verifies the copy.
    # The third field says whether "auto" is a legal value, which it is for anything derivable.
    DESIGNATIONS="reactor_vessel_name:vessels:0 shaft_name:shafts:1 strip_light_name:strip_lights:1"
    {
      for inc in vessels shafts strip_lights; do printf 'include <%s/scad/purchased/%s.scad>\n' "$PWD" "$inc"; done
      echo 'for (v = vessels)      echo(str("N|reactor_vessel_name|", vessel_name(v)));'
      echo 'for (t = shafts)       echo(str("N|shaft_name|", shaft_name(t)));'
      echo 'for (l = strip_lights) echo(str("N|strip_light_name|", strip_light_name(l)));'
    } > "$tmp/n.scad"
    {{OPENSCAD}} -o "$tmp/n.csg" "$tmp/n.scad" 2>"$tmp/err" >/dev/null
    names=$(grep '^ECHO: "N|reactor_vessel_name|' "$tmp/err" | sed 's/^ECHO: "N|reactor_vessel_name|//; s/"$//')
    if [ -z "$names" ]; then echo "FAIL  could not read the vessel registry"; exit 1; fi
    failed=0
    for f in scad/assembly.scad scad/head.scad; do
        # A dropdown is a comment, so it cannot derive - check it instead. Every designation this
        # file DECLARES WITH a dropdown is compared; one declared without a list is left alone,
        # because there is no copy to drift. A file that does not declare the parameter is skipped.
        #
        # Split on the commas FIRST and trim each field, rather than deleting every space in the
        # list. `tr -d ' '` worked only because vessel names happen to be identifier-shaped; the
        # moment a registry with spaced names is compared this way - "pH lab g2", "EPDM 1/16 60A" -
        # the listed name loses its spaces, the registry's does not, and the two never match.
        for spec in $DESIGNATIONS; do
            param="${spec%%:*}"; rest="${spec#*:}"; takes_auto="${rest#*:}"
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
    if [ -n "{{vessel}}" ]; then sel=(-p scad/assembly.json -P "{{vessel}}"); fi

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
    echo(str("DESIG|shaft_name|", shaft_name));
    echo(str("DESIG|plug_oring_name|", plug_oring_name));
    echo(str("DESIG|strip_light_name|", strip_light_name));
    echo(str("DESIG|do_probe_name|", do_probe_name));
    echo(str("DESIG|ph_probe_name|", ph_probe_name));
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
    # WHAT THIS BUILD DESIGNATED, reported rather than assumed. These parts now render through
    # assembly.scad so a designation does reach them, and the print list should say which one it
    # carries - an STL of a g1 collet and one of a g2 collet look identical in a directory listing.
    pinned=$(grep '^ECHO: "DESIG|' "$tmp/err" | sed 's/.*DESIG|//; s/"$//' | grep -v '|auto$' || true)
    if [ -n "$pinned" ]; then
        echo "note  this build designates:"
        echo "$pinned" | sed 's/|/ = /' | sed 's/^/          /'
    fi

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
        # EVERY PART RENDERS THROUGH assembly.scad, whichever half it belongs to. That file is the
        # one that carries a build's designations - the probes, the shaft, the o-ring, the light -
        # and head.scad's own tail calls head() with no build, so exporting from it wrote the
        # DEFAULT part under a build that had asked for another one. Measured before this changed:
        # the do_probe port rendered from head.scad was byte-identical with and without
        # -D do_probe_name="DO lab g1", while the same designation moved 134 CSG tokens through
        # assembly.
        #
        # It also closes the frame's vessel gap in passing. frame.scad has no parameter set and
        # built the jar named in its own preview, so a named vessel silently produced another jar's
        # frame; through assembly the frame gets the selected vessel like everything else.
        #
        # The manifest's file column now says which HALF a row belongs to rather than which file
        # renders it, because that is what decides the render flags.
        case "$file" in
            scad/head.scad)  half=(-D render_vessel=false -D render_frame=false -D render_head=true -D export_at_origin=true) ;;
            scad/frame.scad) half=(-D render_vessel=false -D render_head=false -D render_frame=true) ;;
            *) echo "FAIL  $name: no render flags known for $file"; failed=1; continue ;;
        esac
        # render_all overrides every other flag, so it has to go off before the row's own go on.
        # export_at_origin puts a head part where head.scad would have put it instead of at its
        # assembled height; it moves the part and does not change its shape.
        {{OPENSCAD}} ${sel[@]+"${sel[@]}"} -D render_all=false "${half[@]}" $flags -o "$out" scad/assembly.scad 2>"$tmp/e" >/dev/null
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
      echo "Food-grade clear PETG for anything the culture touches, grey PETG for structure -"
      echo "food-grade is a purchasing constraint, not a colour. The gasket cutter"
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
# NOT part of `just check`, and that is a deliberate trade. Building solids takes minutes where a
# .csg takes seconds, and `check` is the loop you run on every edit.
#
# WHAT TO RUN BEFORE PRINTING is `just export-parts`, not this. It applies the same 2-manifold test
# to every part on the manifest, one at a time, and that is where the reactor's own parts are
# covered. This recipe covers the files that render a printed part on their own and reach no
# manifest - the ports, the collet, the cutter, the impeller, the mount, the pump head, the gasket,
# the sparge ring, the bottle holder and the stand's bracket.
#
# The risk is the usual one - a check nobody runs is a check that does not exist. A check that
# CANNOT PASS is worse, because it teaches people to ignore a real failure later: this recipe told
# you to run it on head.scad before a print, where it had never once passed.
#
# Build entry files into solids and fail on a non-manifold. `just check-mesh <file>` for one.
check-mesh file="":
    #!/usr/bin/env bash
    # A failing render still exits 0 and writes a small file, so nothing may be gated on $?. The
    # manifold complaint on stderr is the signal and the file size is the backstop.
    set -uo pipefail
    tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
    # Flags that turn a file's PREVIEW into the part it prints. Most files need none: their default
    # render already IS the part. The ones that need it render an assembly to be looked at.
    mesh_flags() {
        case "$1" in
            scad/electronics_stand.scad) echo "-D print_corner=true" ;;
            *) echo "" ;;
        esac
    }
    # Why a file is not built by default. See MESH_SKIP above for how each was measured.
    mesh_why() {
        case "$1" in
            scad/head.scad)     echo "not a 2-manifold as it previews - export-parts builds its 23 parts" ;;
            scad/frame.scad)    echo "a clean 2-manifold but 141 s - export-parts builds its parts" ;;
            scad/assembly.scad) echo "the assembled reactor as a picture; nothing is printed from it" ;;
            scad/cart.scad)     echo "not a 2-manifold as it previews; its bracket has no render of its own" ;;
            *) echo "" ;;
        esac
    }
    if [ -n "{{file}}" ]; then
        targets="{{file}}"
        # Naming a skipped file builds it anyway, but say first what it will do, so nobody reads a
        # guaranteed failure as a defect in something they were about to print.
        why=$(mesh_why "{{file}}")
        [ -n "$why" ] && printf 'note  %-46s %s\n' "{{file}}" "$why"
    else
        targets=""
        for f in {{ENTRY}}; do
            skip=0
            for s in {{MESH_SKIP}}; do [ "$s" = "$f" ] && skip=1; done
            [ "$skip" = 0 ] && targets="$targets $f"
        done
        for s in {{MESH_SKIP}}; do
            printf 'skip  %-46s %s\n' "$s" "$(mesh_why "$s")"
        done
    fi
    failed=0
    for f in $targets; do
        out="$tmp/$(echo "$f" | tr / _).stl"
        {{OPENSCAD}} $(mesh_flags "$f") -o "$out" "$f" 2>"$tmp/err" >/dev/null
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
