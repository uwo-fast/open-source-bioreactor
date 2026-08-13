PY := "analysis/.venv/bin/python"
OPENSCAD := env("OPENSCAD", "openscad")

# List available recipes.
default:
    @just --list

# Everything CI runs.
check: check-scad

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
        scad/custom/impeller.scad
        scad/custom/motor_mount.scad
        scad/custom/peri_pump_frame_mount.scad
        scad/custom/sheet_gasket.scad
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
