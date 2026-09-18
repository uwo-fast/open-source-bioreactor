set dotenv-load := false

PY := "analysis/.venv/bin/python"
export OPENSCAD := env("OPENSCAD", "openscad")

# The libraries openscad-libraries.txt pins, installed by `just setup`. Project-local so a
# render is reproducible or fails loudly.
export OPENSCADPATH := justfile_directory() + "/.openscad-libraries"

# Tool caches live in the repository too, so the gate runs the same on a bench, in CI and in a
# sandbox that cannot write the home directory. Gitignored.
export npm_config_cache := justfile_directory() + "/.cache/npm"
export UV_CACHE_DIR := justfile_directory() + "/.cache/uv"
export UV_TOOL_DIR := justfile_directory() + "/.cache/uv-tools"

# What the formatters see: the tracked files of the types they own, so a stray in the tree is not
# the gate's business. .prettierignore still applies.
FORMATTED := "$(git ls-files '*.md' '*.json' '*.jsonc' '*.yml' '*.yaml')"

# What check-mesh does not build by default, each for its own reason: head.scad and
# equipment_cart.scad are not 2-manifolds as they preview (vitamins - seals, probes, bearing -
# break the union, and those are on check-parts' not_printed list); frame.scad is clean but
# 141 s; bioreactor.scad does not finish. `just export-parts` covers the reactor's parts one at
# a time instead.
export MESH_SKIP := "scad/bioreactor.scad scad/support/equipment_cart.scad scad/frame.scad scad/head.scad"

ENTRY_CUSTOMIZED := "scad/bioreactor.scad scad/head.scad scad/frame.scad"

# The files that render on their own. check-scad asserts everything else emits no geometry, so a
# new entry file fails until it is listed here.
export ENTRY := "scad/bioreactor.scad scad/support/bottle_holder.scad scad/support/equipment_cart.scad scad/support/electronics_stand.scad \
scad/frame.scad scad/head.scad scad/custom/bayonet_port.scad \
scad/custom/cylindrical_flex_collet.scad scad/custom/gasket_cutter.scad \
scad/custom/gasket_cutter_v2.scad scad/custom/impeller.scad \
scad/custom/motor_mount.scad scad/custom/magnet_hub_cap.scad scad/custom/peri_pump_frame_mount.scad \
scad/custom/peri_pump_head.scad scad/custom/sheet_gasket.scad \
scad/custom/sparger.scad"

# List available recipes.
default:
    @just --list

# Install the OpenSCAD libraries the model depends on.
setup:
    @scripts/install-libraries.sh

# Everything CI runs.
check: fmt-check lint check-recipes check-echo check-scad check-designations check-json check-bom check-parts check-customizer

# Prettier owns markdown, JSON and YAML; ruff owns the Python. Nothing formats SCAD: the registries
# are aligned by hand. Versions are pinned so a style bump is not a surprise diff.
#
# Format markdown, JSON and the analysis Python in place.
fmt:
    npx --yes prettier@3.8.4 --write {{FORMATTED}}
    uvx ruff@0.14.5 format analysis scripts
    uvx ruff@0.14.5 check --fix analysis scripts

# Verify formatting without touching anything, which is what `check` needs.
fmt-check:
    npx --yes prettier@3.8.4 --check {{FORMATTED}}
    uvx ruff@0.14.5 format --check analysis scripts

# Lint markdown and the analysis Python.
lint:
    npx --yes markdownlint-cli2@0.18.1 $(git ls-files '*.md')
    uvx ruff@0.14.5 check analysis scripts

# The two checks a CGAL render puts out of the fast gate's reach: minutes, not seconds.
#
# The slow half of verification: mesh validity and gas-hole breakthrough.
test: check-mesh check-holes

# Remove what the recipes build.
clean:
    rm -rf output working.tmp

# OpenSCAD reads only the line immediately above a variable, and /* [Hidden] */ runs to the next
# marker, so both are checked.
#
# Fail when a Customizer parameter has no description the UI can show.
check-customizer:
    @scripts/check_customizer.py {{ENTRY_CUSTOMIZED}}

# Pins the whole reported surface, 3 entry files x 5 registered vessels, byte for byte. Cells
# that ERROR are pinned like any other.
#
# Fail when any entry file's echo stream moves against its committed transcript.
check-echo:
    @scripts/check-echo.sh

# Rewrite the transcripts. Only after reading the diff `just check-echo` printed.
check-echo-update:
    @scripts/check-echo.sh --update

# `just` shows only the comment line immediately above a recipe, so a description has to be last
# in its block.
#
# Fail when a recipe has no description, or shows a fragment as one.
check-recipes:
    @scripts/check-recipes.py

# Evaluate every SCAD file and report anything that does not build.
check-scad:
    @scripts/check-scad.sh

# Not part of `check`. cloc rather than tokei: trixie's tokei predates OpenSCAD support and
# counts none of the SCAD tree. It is not installed here; add it to whatever provisions the
# machine.
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

# Only registries that carry a part number are checked, and only what the reference build
# selects; it compares the part_number field, not the file. The script says what is not enrolled.
#
# Fail when the purchase list misses a part the model prescribes.
check-bom:
    @scripts/check-bom.sh

# The .json beside each entry file is authored, one set per registered vessel, holding only what
# that build changes from the defaults. The GUI reads <file>.json automatically and
# `-p <file>.json -P <vessel>` selects one from a script.
#
# Fail when a parameter-set file has drifted from its entry file or the registries.
check-json:
    @scripts/check-json.py {{ENTRY_CUSTOMIZED}}

# The Customizer writes every parameter when it saves; this strips a set back to its deviations.
#
# Strip parameters a set carries at the file's own default.
json-prune:
    @scripts/json-prune.py {{ENTRY_CUSTOMIZED}}

# head_print_parts() is hand-written where the render flags are, so a new printed part with a
# flag and no manifest row is caught here. `not_printed` in the script is the record of flags
# that make nothing you print, and it fails both ways.
#
# Fail when a printed part exists that the print manifest does not carry.
check-parts:
    @scripts/check-parts.sh

# The complement of the purchase list: head_print_parts() and frame_print_parts() say what is
# printed, and this renders each part CGAL and checks it for a manifold. About a minute a part.
# Naming another vessel uses bioreactor.json's parameter sets.
#
# Export every printed part as its own STL, with a print list. `just export-parts <vessel>` for one.
export-parts vessel="" out="output":
    @scripts/export-parts.sh "{{vessel}}" "{{out}}"

# check-scad exports the CSG tree, so CGAL never runs and a degenerate solid is invisible to it.
# This builds the entry files into solids. Not part of `check`: minutes, not seconds. What to run
# before printing is `just export-parts`, which covers the reactor's own parts.
#
# Build entry files into solids and fail on a non-manifold. `just check-mesh <file>` for one.
check-mesh file="":
    @scripts/check-mesh.sh "{{file}}"
