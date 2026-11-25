#!/usr/bin/env bash
#
# Build entry files into solids and fail on a non-manifold. One file as $1, or all of $ENTRY.
#
: "${OPENSCAD:=openscad}"
: "${ENTRY:?exported by the justfile}"
: "${MESH_SKIP:?exported by the justfile}"

# A failing render still exits 0 and writes a small file, so nothing may be gated on $?. The
# manifold error on stderr is the signal, and the file size is the fallback.
set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
# The error comes from CGAL. A binary with the manifold backend uses it by default and reports
# nothing on a non-manifold, so request CGAL whenever the binary offers a choice. A binary without
# --backend already uses CGAL.
backend=""
help=$("$OPENSCAD" --help 2>&1)
case "$help" in *--backend*) backend="--backend=CGAL" ;; esac
# Flags that make a file render the part it prints, for files whose default is an assembly.
mesh_flags() {
    case "$1" in
        scad/support/electronics_stand.scad) echo "-D print_corner=true" ;;
        *) echo "" ;;
    esac
}
# Why a file is not built by default; see MESH_SKIP in the justfile.
mesh_why() {
    case "$1" in
        scad/head.scad)     echo "not a 2-manifold as it previews - export-parts builds its 23 parts" ;;
        scad/frame.scad)    echo "a clean 2-manifold but 141 s - export-parts builds its parts" ;;
        scad/bioreactor.scad) echo "the assembled reactor as a picture; nothing is printed from it" ;;
        scad/custom/condenser_coil.scad) echo "its preview stands the coil on the former it is wound on, so the two touch; build its parts with part=" ;;
        scad/custom/sampler.scad) echo "its preview carries the screws, inserts and nuts; build its parts with part=" ;;
        scad/support/equipment_cart.scad)     echo "not a 2-manifold as it previews; its bracket has no render of its own" ;;
        *) echo "" ;;
    esac
}
if [ -n "${1:-}" ]; then
    targets="${1:-}"
    # A skipped file named explicitly is built anyway, after a note on what to expect.
    why=$(mesh_why "${1:-}")
    [ -n "$why" ] && printf 'note  %-46s %s\n' "${1:-}" "$why"
else
    targets=""
    for f in $ENTRY; do
        skip=0
        for s in $MESH_SKIP; do [ "$s" = "$f" ] && skip=1; done
        [ "$skip" = 0 ] && targets="$targets $f"
    done
    for s in $MESH_SKIP; do
        printf 'skip  %-46s %s\n' "$s" "$(mesh_why "$s")"
    done
fi
failed=0
for f in $targets; do
    out="$tmp/$(echo "$f" | tr / _).stl"
    "$OPENSCAD" $backend $(mesh_flags "$f") -o "$out" "$f" 2>"$tmp/err" >/dev/null
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
