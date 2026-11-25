#!/usr/bin/env bash
#
# Render pictures of the model to PNG, for the paper and the docs.
#
#   views  the rows of scad/views.tsv, each with a name, a build, a view and what is drawn. $2 is
#          a glob over the names, "*" for all; $3 is a build that overrides the build in every row.
#   parts  every printed part of a build separately, from the print list export-parts writes, so
#          a new part gets a picture without a row. $2 is a glob over the part names, $3 the
#          build (jar_10L_220x305 by default).
#
# Pictures are written to $OUT/<build>/ (output/figures unless set), with parts under parts/.
# Each is cropped to the model with a small margin. None are committed: a model change would make
# a committed picture stale without anything detecting it, so only the list of views is kept.
#
# These are previews, not renders: a preview keeps the model colours and the glass translucency,
# and takes seconds where a render of the assembly takes minutes. The renders run JOBS at a time.
#
: "${OPENSCAD:=openscad}"
: "${JOBS:=$(nproc)}"
: "${OUT:=output/figures}"
# Image size in pixels before the crop; the crop keeps the part that contains the model
: "${RENDER_SIZE:=2400,1800}"
: "${RENDER_SCHEME:=Tomorrow}"

# A failing render still exits 0, so stderr is the signal. An empty picture is the other failure:
# a flag that hides more than intended leaves an empty frame and no error.
set -uo pipefail
# shellcheck source=scripts/openscad-canary.sh
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
# shellcheck source=scripts/export-lib.sh
source "$(dirname "$0")/export-lib.sh"
# The crop and the blank check need ImageMagick; without it the pictures are written uncropped
if command -v magick >/dev/null; then MAGICK=1; else
    MAGICK=0; echo "skip  crop and blank check (ImageMagick not installed)"
fi
export OPENSCAD RENDER_SIZE RENDER_SCHEME MAGICK

mode="${1:-views}"
filter="${2:-*}"
build="${3:-}"

# Render one picture. A job is "name|build|view|scope|flags|out", with out given without its
# extension.
#
# A view is one of the names below, or a rotation in the format the GUI copies with Edit > Copy
# Viewport Rotation, "[55.00, 0.00, 25.00]", for an angle chosen by eye. Every view is
# orthographic, like a drawing. In perspective the camera can sit inside the cutter of a section,
# and the preview then draws the model uncut. The current cutter has not done that from any view
# here, but a larger one would.
# The scope gives the half a part belongs to: "assembly" renders bioreactor.scad unchanged, and
# "head" and "frame" isolate that half the way export-parts does, with the part at the origin.
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
    # The cut is off unless a row turns it on, since a later -D overrides an earlier one.
    # shellcheck disable=SC2086
    "$OPENSCAD" -p scad/bioreactor.json -P "$build" --imgsize="$RENDER_SIZE" \
        --colorscheme="$RENDER_SCHEME" --viewall --autocenter \
        --camera="0,0,0,$cam,0" --projection=o \
        -D cross_section_active=false $half $flags \
        -o "$out.png" scad/bioreactor.scad 2>"$out.err" >/dev/null
    # On failure, keep the log and delete the picture, which could be mistaken for a real one
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
        # The crop box of an image that contains only background is 0 wide
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

# OpenSCAD ignores a -P that names a nonexistent set and draws the file defaults, which would
# label pictures of one build with the name of another.
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
