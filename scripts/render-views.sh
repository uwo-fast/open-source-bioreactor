#!/usr/bin/env bash
#
# Render pictures of the model to PNG, for the paper and the docs.
#
#   views  the rows of scad/views.tsv, each a name, a build, a view and what is drawn. $2 is a
#          glob over the names, "*" for all; $3 is a build that replaces every row's own.
#   parts  every printed part of a build on its own, from the print list export-parts writes, so
#          a new part gets its picture without a row. $2 is a glob over the part names, $3 the
#          build (jar_10L_220x305 unless given).
#
# Pictures land in $OUT/<build>/ (output/figures unless set), parts under parts/. Each is
# cropped to the model with a small margin, and nothing is committed: a model change makes a
# committed picture stale without anything noticing, so the list of views is what is kept.
#
# Previews, not renders: a preview keeps the model's colours and the glass's translucency, and
# takes seconds where a render of the assembly takes minutes. The renders run JOBS at a time.
#
: "${OPENSCAD:=openscad}"
: "${JOBS:=$(nproc)}"
: "${OUT:=output/figures}"
# Pixels before the crop; the crop keeps the model's share of them
: "${RENDER_SIZE:=2400,1800}"
: "${RENDER_SCHEME:=Tomorrow}"

# A failing render still exits 0, so stderr is the signal, and a picture of nothing is the other
# failure: a flag that hides more than it meant to leaves an empty frame and no error.
set -uo pipefail
# shellcheck source=scripts/openscad-canary.sh
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
# shellcheck source=scripts/export-lib.sh
source "$(dirname "$0")/export-lib.sh"
# The crop and the blank check need ImageMagick; without it the pictures are written as rendered
if command -v magick >/dev/null; then MAGICK=1; else
    MAGICK=0; echo "skip  crop and blank check (ImageMagick not installed)"
fi
export OPENSCAD RENDER_SIZE RENDER_SCHEME MAGICK

mode="${1:-views}"
filter="${2:-*}"
build="${3:-}"

# One picture. A job is "name|build|view|scope|flags|out", out without its extension.
#
# A view is a name below, or a rotation as the GUI's Edit > Copy Viewport Rotation gives it,
# "[55.00, 0.00, 25.00]", for an angle found by eye. Every view is orthographic, as a drawing is.
# In perspective the eye can sit inside a section's cutter, and the preview then draws the model
# uncut; this cut's cutter has not done that from any view here, but one that reaches further would.
# The scope says which half a part belongs to: "assembly" draws through bioreactor.scad as it
# stands, "head" and "frame" isolate that half the way export-parts does, part at the origin.
render_one() {
    local name build view scope flags out cam half box bg
    IFS='|' read -r name build view scope flags out <<< "$1"
    case "$view" in
        iso)      cam=60,0,30 ;;
        iso_back) cam=60,0,210 ;;
        front)    cam=90,0,0 ;;
        back)     cam=90,0,180 ;;
        right)    cam=90,0,90 ;;
        left)     cam=90,0,270 ;;
        top)      cam=0,0,0 ;;
        bottom)   cam=180,0,0 ;;
        *,*,*)    cam=$(tr -d '[] ' <<< "$view") ;;
        *) echo "FAIL  $name  no view is named $view"; return ;;
    esac
    case "$scope" in
        assembly)   half="" ;;
        head|frame) half="-D render_all=false $(export_half_flags "scad/$scope.scad")" ;;
        *) echo "FAIL  $name  the scope is assembly, head or frame, not $scope"; return ;;
    esac
    mkdir -p "$(dirname "$out")"
    # The cut is off unless a row turns it on: a later -D wins over an earlier one.
    # shellcheck disable=SC2086
    "$OPENSCAD" -p scad/bioreactor.json -P "$build" --imgsize="$RENDER_SIZE" \
        --colorscheme="$RENDER_SCHEME" --viewall --autocenter \
        --camera="0,0,0,$cam,0" --projection=o \
        -D cross_section_active=false $half $flags \
        -o "$out.png" scad/bioreactor.scad 2>"$out.err" >/dev/null
    # A failure keeps the log and not the picture, which could pass for a real one
    if grep -q '^ERROR' "$out.err"; then
        echo "FAIL  $name  $(grep -m1 '^ERROR' "$out.err")"
        rm -f "$out.png"
        return
    fi
    if [ ! -s "$out.png" ]; then
        echo "FAIL  $name  wrote no picture; see $out.err"
        return
    fi
    if [ "$MAGICK" = 1 ]; then
        # The crop box of a frame holding only background is 0 wide
        box=$(magick "$out.png" -fuzz 2% -format '%@' info: 2>/dev/null)
        if [[ "$box" == 0x* ]]; then
            echo "FAIL  $name  drew nothing: the flags hide everything ($flags)"
            rm -f "$out.png"
            return
        fi
        bg=$(magick "$out.png" -format '%[pixel:p{0,0}]' info:)
        magick "$out.png" -fuzz 2% -trim +repage -bordercolor "$bg" -border 40 "$out.png"
    fi
    rm -f "$out.err"
    echo "ok    $name  $out.png"
}
export -f render_one export_half_flags

# OpenSCAD ignores a -P naming a set that does not exist and draws the file's defaults, which
# would label one build's pictures with another's name.
known_build() {
    /usr/bin/python3 -c 'import json,sys; sys.exit(sys.argv[2] not in json.load(open(sys.argv[1]))["parameterSets"])' scad/bioreactor.json "$1" ||
        { echo "FAIL  no parameter set is named $1 in scad/bioreactor.json"; return 1; }
}

jobs="$tmp/jobs"
: > "$jobs"
case "$mode" in
    views)
        # name, build, view, scope, flags: tab-separated, # starts a comment
        while IFS=$'\t' read -r name b view scope flags; do
            [[ -z "$name" || "$name" == \#* ]] && continue
            # shellcheck disable=SC2053
            [[ "$name" == $filter ]] || continue
            b="${build:-$b}"
            echo "$name|$b|$view|$scope|${flags:-}|$OUT/$b/$name" >> "$jobs"
        done < scad/views.tsv
        ;;
    parts)
        build="${build:-jar_10L_220x305}"
        known_build "$build" || exit 1
        if ! export_manifest "-p scad/bioreactor.json -P $build" "$tmp/m"; then
            echo "FAIL  $build does not resolve, so it has no parts to draw"
            grep -m1 '^ERROR' "$tmp/m.err" | sed 's/^/        /'
            exit 1
        fi
        # rows are file|name|qty|flags
        while IFS='|' read -r file name _ flags; do
            # shellcheck disable=SC2053
            [[ "$name" == $filter ]] || continue
            scope=$(basename "$file" .scad)
            echo "$name|$build|iso|$scope|$flags|$OUT/$build/parts/$name" >> "$jobs"
        done < "$tmp/m.rows"
        ;;
    *) echo "FAIL  the mode is views or parts, not $mode"; exit 1 ;;
esac

if [ ! -s "$jobs" ]; then
    echo "FAIL  nothing matches $filter"
    exit 1
fi
while read -r b; do
    known_build "$b" || exit 1
done < <(cut -d'|' -f2 "$jobs" | sort -u)

xargs -d '\n' -P "$JOBS" -I{} bash -c 'render_one "$1"' _ {} < "$jobs" | tee "$tmp/log"
n=$(wc -l < "$jobs")
if grep -q '^FAIL' "$tmp/log"; then
    echo "FAIL  $(grep -c '^FAIL' "$tmp/log") of $n pictures did not render"
    exit 1
fi
echo "ok    $n pictures in $OUT"
