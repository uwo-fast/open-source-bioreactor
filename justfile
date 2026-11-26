set dotenv-load := false

PY := "analysis/.venv/bin/python"
export OPENSCAD := env("OPENSCAD", "openscad")

# Libraries pinned in scadman.lock and installed by `just setup`. They are project-local, so a
# render is either reproducible or fails loudly.
export OPENSCADPATH := justfile_directory() + "/.scadman/env"

# Tool caches are also kept in the repository (gitignored), so the gate behaves the same on a
# bench machine, in CI and in a sandbox that cannot write to the home directory.
export npm_config_cache := justfile_directory() + "/.cache/npm"
export UV_CACHE_DIR := justfile_directory() + "/.cache/uv"
export UV_TOOL_DIR := justfile_directory() + "/.cache/uv-tools"

# Files passed to the formatters: tracked files of the types they handle, so untracked files do
# not affect the gate. .prettierignore still applies.
FORMATTED := "$(git ls-files '*.md' '*.json' '*.jsonc' '*.yml' '*.yaml')"

# Files check-mesh skips by default, each for its own reason. head.scad and equipment_cart.scad
# are not 2-manifold as previewed, because the vitamins (seals, probes, bearing) break the union;
# those are on the not_printed list in check-parts. frame.scad is clean but takes 141 s.
# bioreactor.scad does not finish. `just export-parts` checks the reactor parts one at a time
# instead.
export MESH_SKIP := "scad/bioreactor.scad scad/support/equipment_cart.scad scad/frame.scad scad/head.scad scad/custom/condenser_coil.scad scad/custom/sampler.scad"

ENTRY_CUSTOMIZED := "scad/bioreactor.scad scad/head.scad scad/frame.scad"

# Files that render on their own. check-scad asserts that every other file emits no geometry, so
# a new entry file fails until it is added here.
export ENTRY := "scad/bioreactor.scad scad/support/bottle_holder.scad scad/support/equipment_cart.scad scad/support/electronics_stand.scad \
scad/support/estop_box.scad \
scad/frame.scad scad/head.scad \
scad/custom/gasket_cutter.scad scad/custom/gl_port_cap.scad \
scad/custom/condenser_cold_finger.scad scad/custom/condenser_coil.scad \
scad/custom/gasket_cutter_v2.scad scad/custom/impeller.scad \
scad/custom/motor_mount.scad scad/custom/magnet_hub_cap.scad scad/custom/heat_pad_mount.scad scad/custom/bearing_blank.scad scad/custom/draft_tube.scad scad/custom/baffle_cage.scad scad/custom/peri_pump_frame_mount.scad \
scad/custom/peri_pump_head.scad scad/custom/sheet_gasket.scad \
scad/custom/sparger.scad scad/custom/sparge_puck.scad scad/custom/sampler.scad"

# List available recipes.
default:
    @just --list

# Install the OpenSCAD libraries the model depends on.
setup:
    @scripts/install-libraries.sh

# Run every check that CI runs.
check: check-openscad fmt-check lint check-recipes check-echo check-scad check-designations check-json check-builds check-bom check-prices check-parts check-customizer

# Prettier formats markdown, JSON and YAML, and ruff formats the Python. SCAD has no formatter;
# the registries are aligned by hand. Versions are pinned so a formatter update does not produce
# an unexpected diff.
#
# Format markdown, JSON and the analysis Python in place.
fmt:
    npx --yes prettier@3.8.4 --write {{FORMATTED}}
    uvx ruff@0.14.5 format analysis scripts
    uvx ruff@0.14.5 check --fix analysis scripts

# Check formatting without modifying any files, as `check` requires.
fmt-check:
    npx --yes prettier@3.8.4 --check {{FORMATTED}}
    uvx ruff@0.14.5 format --check analysis scripts

# Lint markdown and the analysis Python.
lint:
    npx --yes markdownlint-cli2@0.18.1 $(git ls-files '*.md')
    uvx ruff@0.14.5 check analysis scripts

# These checks need a CGAL render, which takes minutes rather than seconds, so they are kept out
# of the fast gate.
#
# Run the slow checks: mesh validity, holes, sampler fits, lid clashes and the wall cage.
test: check-openscad check-mesh check-holes check-clash check-baffle-cage

# Remove the files the recipes build.
clean:
    rm -rf output

# just runs the first openscad on PATH unless OPENSCAD names one, so every gate first prints which
# one it uses and rejects any version older than 2021.01, the oldest supported. CI runs the
# snapshot pinned in .github/workflows/check.yml, and its floor job also runs the gates on 2021.01.
#
# Print the OpenSCAD version, and fail if it is older than the oldest supported or cannot render.
check-openscad:
    @scripts/check-openscad.sh

# OpenSCAD reads only the line immediately above a variable, and /* [Hidden] */ applies until the
# next marker, so the script checks both.
#
# Fail when a Customizer parameter has no description the UI can show.
check-customizer:
    @scripts/check_customizer.py {{ENTRY_CUSTOMIZED}}

# Pins the full echo output of 3 entry files x 5 registered vessels, byte for byte. Cells that
# ERROR are pinned like any other.
#
# Fail when the echo output of any entry file differs from its committed transcript.
check-echo:
    @scripts/check-echo.sh

# Rewrite the transcripts. Run this only after reading the diff that `just check-echo` printed.
check-echo-update:
    @scripts/check-echo.sh --update

# `just` shows only the comment line immediately above a recipe, so the description must be the
# last line of its block.
#
# Fail when a recipe has no description, or shows a fragment as one.
check-recipes:
    @scripts/check-recipes.py

# Evaluate every SCAD file and report anything that does not build.
check-scad:
    @scripts/check-scad.sh

# Not part of `check`. It uses cloc rather than tokei because the tokei in trixie predates
# OpenSCAD support and counts none of the SCAD files. cloc is not installed by this repository;
# add it to whatever provisions the machine.
#
# Report lines of code and comment per language. Needs cloc.
stats:
    #!/usr/bin/env bash
    set -uo pipefail
    if ! command -v cloc >/dev/null 2>&1; then
        echo "cloc is not installed (apt has it); add it to whatever provisions your machines."
        exit 1
    fi
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

# Rebuild one run, e.g. `just analysis-run 2026-07-23-chlorella-cpcc90`.
analysis-run name:
    {{PY}} analysis/runs/{{name}}/pipeline.py --verify

# Rebuild one method, e.g. `just analysis-method light-irradiance`.
analysis-method name:
    {{PY}} analysis/methods/{{name}}/pipeline.py --verify

# Fail when a registered build in bioreactor.json does not build.
check-builds:
    @scripts/check-builds.sh

# Fail when a designation no longer reaches the model.
check-designations:
    @scripts/check-designations.sh

# Fail when a gas hole the model declares does not actually break through.
check-holes file="" flags="-D render_all=false -D render_sparger=true":
    @scripts/check-holes.sh "{{file}}" "{{flags}}"

# Requires the manifold backend, and prints SKIP without it.
#
# Fail when the condenser or the sampler overlaps any other part on the lid, locked or at entry.
check-clash build="":
    @scripts/check-clash.sh "{{build}}"

# Requires the manifold backend, and prints SKIP without it.
#
# Fail when the wall-cage blades no longer slide, stop or hold, or the cage touches the glass or the lid parts.
check-baffle-cage build="":
    @scripts/check-baffle-cage.sh "{{build}}"

# Only registries that carry a part number are checked, and only the entries the reference build
# selects. It compares the part_number field, not the file. The script lists what is not enrolled.
#
# Fail when the purchase list is missing a part the model specifies.
check-bom:
    @scripts/check-bom.sh

# Fail when a purchase-list row cannot be summed: no scope, a qty that is not a count, or a price with no currency.
check-prices:
    @/usr/bin/python3 scripts/bom-cost.py --check

# One purchase list covers every build. The scope column separates the reference reactor from the
# sampler, the bench and the tools. Totals are kept per currency unless you pass a current rate.
#
# Total the purchase list by scope, e.g. `just cost 1.3960` for one figure at that CAD per USD rate.
cost rate="":
    @/usr/bin/python3 scripts/bom-cost.py {{ if rate == "" { "" } else { "--cad-per-usd " + rate } }}

# The .json file next to each entry file is a source file, not generated. It holds one set per
# registered vessel, with only the values that build changes from the defaults. The GUI loads
# <file>.json automatically, and `-p <file>.json -P <vessel>` selects a set from a script.
#
# Fail when a parameter-set file has drifted from its entry file or the registries.
check-json:
    @scripts/check-json.py {{ENTRY_CUSTOMIZED}}

# The Customizer writes every parameter when it saves. This removes those left at their defaults.
#
# Remove the parameters in a set that equal the entry file's default.
json-prune:
    @scripts/json-prune.py {{ENTRY_CUSTOMIZED}}

# head_print_parts() is written by hand next to the render flags, so this catches a new printed
# part that has a flag but no manifest row. `not_printed` in the script lists the flags that
# produce nothing to print, and the check fails in both directions.
#
# Fail when a printed part is missing from the print manifest.
check-parts:
    @scripts/check-parts.sh

# The counterpart of the purchase list. head_print_parts() and frame_print_parts() list the
# printed parts, and this renders each one with CGAL and checks that it is manifold, on every core
# (JOBS=n for fewer). A build is a parameter set in bioreactor.json: a vessel and whatever it
# designates (`jar_10L_magnetic` names the drive). Given a build, it writes that build flat to
# output/<build> in about the time the lid takes, a minute and a half. Without one, it writes
# every registered build to build/<vessel>/ in about ten minutes. common/ holds the parts that
# every build of that vessel prints the same, and stirred/, magnetic/ or airlift/ hold what each
# build adds.
#
# Export printed parts as STLs with print lists: every build by vessel, or `just export-parts jar_10L_magnetic` for one.
export-parts build="" out="":
    @scripts/export-parts.sh "{{build}}" "{{out}}"

# The export-parts render for a single row of the print list, for iterating on a part before
# printing it. No print list is written.
#
# Export one printed part by its print-list name, e.g. `just export-part frame_base jar_10L_magnetic`.
export-part part build="" out="output":
    @scripts/export-parts.sh "{{build}}" "{{out}}" "{{part}}"

# Uses the bench print list, accessory_print_parts() in scad/support/accessories.scad: the bottle
# holders, the e-stop box and the stand corner, each from its own file. Each part is checked the
# same way export-parts checks the reactor parts.
#
# Export the bench printed parts with a print list, to output/accessories.
export-accessories out="output":
    @scripts/export-accessories.sh "{{out}}"

# Figures for the paper and the docs, listed in scad/views.tsv. They are previews, so each takes
# seconds. `just render-parts` renders every printed part without needing a row.
#
# Render the pictures in scad/views.tsv to output/figures: all, or `just render 'head_*'`.
render filter="*" build="":
    @scripts/render-views.sh views "{{filter}}" "{{build}}"

# Render every printed part of a build on its own, e.g. `just render-parts jar_10L_magnetic`.
render-parts build="jar_10L_220x305" filter="*":
    @scripts/render-views.sh parts "{{filter}}" "{{build}}"

# check-scad only exports the CSG tree, so CGAL never runs and it cannot see a degenerate solid.
# This recipe builds the entry files into solids. It is not part of `check` because it takes
# minutes rather than seconds. Before printing, run `just export-parts`, which covers the reactor
# parts.
#
# Build entry files into solids and fail on a non-manifold. `just check-mesh <file>` for one.
check-mesh file="":
    @scripts/check-mesh.sh "{{file}}"
