set dotenv-load := false

PY := "analysis/.venv/bin/python"
export OPENSCAD := env("OPENSCAD", "openscad")

# Where `just setup` puts the libraries openscad-libraries.txt pins, exported so
# every recipe's OpenSCAD finds them. PROJECT-LOCAL ON PURPOSE: these four used to
# come from whatever the machine happened to have installed globally, which is why
# the model built here and nowhere else. Pointing at the checkout in the repository
# means a render is reproducible or it fails loudly, with no third answer.
export OPENSCADPATH := justfile_directory() + "/.openscad-libraries"

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
export MESH_SKIP := "scad/assembly.scad scad/cart.scad scad/frame.scad scad/head.scad"

ENTRY_CUSTOMIZED := "scad/assembly.scad scad/head.scad scad/frame.scad"

export ENTRY := "scad/assembly.scad scad/bottle_holder.scad scad/cart.scad scad/electronics_stand.scad \
scad/frame.scad scad/head.scad scad/custom/bayonet_baffle_port.scad scad/custom/bayonet_port.scad \
scad/custom/bayonet_probe_port.scad scad/custom/bayonet_thermocouple_port.scad \
scad/custom/cylindrical_flex_collet.scad scad/custom/gasket_cutter.scad \
scad/custom/gasket_cutter_v2.scad scad/custom/impeller.scad \
scad/custom/motor_mount.scad scad/custom/peri_pump_frame_mount.scad \
scad/custom/peri_pump_head.scad scad/custom/sheet_gasket.scad \
scad/custom/sparger.scad"

# List available recipes.
default:
    @just --list

# Clone the pinned OpenSCAD libraries. SSH first, HTTPS if that fails, so the same
# line in openscad-libraries.txt serves a keyed workstation and a bare CI runner.
# Idempotent, so it is cheap in front of a build. The analysis virtualenv is a
# separate concern and a separate recipe - nothing in `check` needs it.
#
# Install the OpenSCAD libraries the model depends on.
setup:
    @scripts/install-libraries.sh

# Everything CI runs.
check: fmt-check lint check-recipes check-scad check-vessels check-designations check-json check-bom check-parts check-customizer

# Prettier owns markdown, JSON and YAML; ruff owns the analysis Python. NOTHING formats
# SCAD - no formatter understands it, and the registries say DO NOT FORMAT in the files
# themselves because their columns are aligned by hand. purchased-parts.csv is ignored
# for the same reason, and analysis/runs/*/raw because those are measurements rather
# than documents: reformatting them would rewrite the record of an experiment.
#
# Versions are PINNED. An unpinned `npx prettier` reformats the repo the day upstream
# changes a default, which turns a style bump into a diff nobody asked for.
#
# Format markdown, JSON and the analysis Python in place.
fmt:
    npx --yes prettier@3.8.4 --write .
    uvx ruff@0.14.5 format analysis scripts
    uvx ruff@0.14.5 check --fix analysis scripts

# Verify formatting without touching anything, which is what `check` needs.
fmt-check:
    npx --yes prettier@3.8.4 --check .
    uvx ruff@0.14.5 format --check analysis scripts

# The negated globs are markdownlint-cli2's own exclude syntax; a .markdownlintignore
# did not reach working.tmp, which is untracked scratch and not ours to lint.
#
# Lint markdown and the analysis Python.
lint:
    npx --yes markdownlint-cli2@0.18.1 "**/*.md" "#analysis/.venv" "#working.tmp" "#output" "#.openscad-libraries"
    uvx ruff@0.14.5 check analysis scripts

# The two checks a CGAL render puts out of the gate's reach, which is what makes them
# tests rather than checks: check-mesh builds every entry file into a solid, and
# check-holes proves each declared gas hole breaks through AND is fed. Minutes, not
# seconds - so they run here and `check` stays the fast gate.
#
# The slow half of verification: mesh validity and gas-hole breakthrough.
test: check-mesh check-holes

# output/ is the export tree and working.tmp holds scratch; neither is tracked, and
# nothing else here writes outside them.
#
# Remove what the recipes build.
clean:
    rm -rf output working.tmp

# Fail when a Customizer parameter has no description the UI can actually show.
#
# OpenSCAD reads ONLY the line immediately above a variable. A multi-line comment block shows its
# last line, and a trailing comment shows nothing at all - so 46 parameters across the three entry
# files offered the previous LINE OF CODE as their help text, render_base advising the reader that
# "render_all = true; // render all components". Prose is not checked by `just json` the way the
# dropdowns are, so nothing but this stops the next parameter being as silent.
#
# A parameter under /* [Hidden] */ is exempt: it is not offered, so it needs no description. That
# section runs until the NEXT marker, which is the trap this recipe also covers - hiding one
# internal hid every render flag below it once, because head.scad had no marker between them.
#
# Fail when a Customizer parameter has no description the UI can show.
check-customizer:
    @scripts/check_customizer.py {{ENTRY_CUSTOMIZED}}

# The list of files that render on their own is exported above rather than passed, because
# check-mesh reads the same one and a second copy would be a second answer to "what renders".
#
# `just` reads only the comment line immediately above a recipe, the same rule the OpenSCAD
# Customizer uses - so a multi-line block shows its LAST line, and four recipes here once
# advertised the middle of a sentence. Structural, not a guess at prose: see the script.
#
# Fail when a recipe has no description, or shows a fragment as one.
check-recipes:
    @scripts/check-recipes.py

# Evaluate every SCAD file and report anything that does not build.
check-scad:
    @scripts/check-scad.sh

# Render every entry file against every registered vessel, not just the selected one.
check-vessels:
    @scripts/check-vessels.sh

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
# This recipe does not install anything. cloc is packaged, but which tools a machine carries is a
# property of that machine rather than of this repository, so it belongs in whatever manifest
# provisions the machine - see the message below.
#
# Report lines of code and comment per language. Needs cloc.
stats:
    #!/usr/bin/env bash
    set -uo pipefail
    if ! command -v cloc >/dev/null 2>&1; then
        echo "cloc is not installed, so there is nothing to report."
        echo "        It is packaged - apt has 2.04 - but nothing here installs a tool. Add it to"
        echo "        whatever provisions your machines, so they all get the same one, and run this"
        echo "        again."
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

# Rebuild every run and method, without the verification pass `analysis` adds.
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
    @scripts/check-designations.sh

# Fail when a gas hole the model declares does not actually break through.
check-holes file="" flags="-D render_all=false -D render_sparger=true":
    @scripts/check-holes.sh "{{file}}" "{{flags}}"

# Fail when a part the model PRESCRIBES is not on the purchase list.
#
# Only the registries that carry a part number can be checked - orings, shafts, thermocouple
# probes, set screws, steel tubes, hose clamps, peri pumps, heat-set inserts, the sterile filter and
# the check valve - so this is a floor, not a full audit. Two prescriptions are deliberately absent: the gasket sheet and the drive
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
#
# Fail when the purchase list misses a part the model prescribes.
check-bom:
    @scripts/check-bom.sh

# Fail if the generated parameter files are stale or the dropdowns have drifted from the registry.
# Regenerating is cheap and the files are committed, so a diff means someone added a jar without
# running `just json` - which would leave the customizer offering a vessel that no longer exists,
# or hiding one that does.
#
# Fail when the committed parameter JSON has drifted from the registries.
check-json:
    @scripts/check-json.sh

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
# to list in a comment - the o-ring has 38 rows - and it is why adding a dropdown is safe.
#
# Regenerate the Customizer parameter JSON from the registries.
json:
    @scripts/gen-parameter-json.sh

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
    @scripts/check-parts.sh

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
    @scripts/export-parts.sh "{{vessel}}" "{{out}}"

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
    @scripts/check-mesh.sh "{{file}}"
