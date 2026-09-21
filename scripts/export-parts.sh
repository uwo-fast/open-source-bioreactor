#!/usr/bin/env bash
#
# Export every printed part as its own STL, with a print list. $1 a build - a parameter set in
# scad/bioreactor.json, or empty for the file's own defaults - $2 the output root, $3 one part
# by name, which writes that STL alone and no list.
#
# The renders run JOBS at a time (every core, unless set): each is one OpenSCAD process on one
# core, and the lid alone is a minute and a half, so the lot takes about as long as the lid.
#
: "${OPENSCAD:=openscad}"
: "${JOBS:=$(nproc)}"

# A failing render still exits 0 and writes a small file, the same as check-mesh, so nothing
# here may be gated on $?. stderr is the signal and the file size is the backstop.
set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT

build="${1:-}"
only="${3:-}"
# A string, not an array, because the render below runs in a child shell and an array cannot be
# exported; set names are identifiers, so word splitting is safe.
sel=""
if [ -n "$build" ]; then
    # OpenSCAD ignores a -P naming a set that does not exist and silently falls back to the
    # file's own defaults, which would write a directory labelled with one build and full of
    # another's parts. So the set is looked up first.
    if ! /usr/bin/python3 -c 'import json,sys; sys.exit(sys.argv[2] not in json.load(open(sys.argv[1]))["parameterSets"])' scad/bioreactor.json "$build"; then
        echo "FAIL  no parameter set is named $build in scad/bioreactor.json"
        exit 1
    fi
    sel="-p scad/bioreactor.json -P $build"
fi

# Ask the model what it prints, through the assembly, which owns both halves. A stub with
# render_all off, so it costs a second. Each row says which half it belongs to.
cat > "$tmp/m.scad" <<SCAD
include <$PWD/scad/bioreactor.scad>
_v = reactor_vessel;
for (p = head_print_parts(vessel_opening_diameter(_v), lid_flange_height,
                          vessel_internal_height(_v), vessel_punt_height(_v), drive_name))
  echo(str("PART|scad/head.scad|", p[0], "|", p[1], "|", p[2]));
for (p = frame_print_parts(n_rods, drive_name))
  echo(str("PART|scad/frame.scad|", p[0], "|", p[1], "|", p[2]));
SCAD
# shellcheck disable=SC2086
"$OPENSCAD" $sel -D render_all=false -o "$tmp/m.csg" "$tmp/m.scad" 2>"$tmp/err" >/dev/null
if grep -q '^ERROR' "$tmp/err"; then
    echo "FAIL  ${build:-the default build} does not resolve, so there is nothing to export"
    grep -m1 '^ERROR' "$tmp/err" | sed 's/^/        /'
    exit 1
fi
# What the build is, in the model's own words: the vessel, the drive and every designation
# stated rather than left auto. Printed and written into the list, because an STL of a g1
# collet and one of a g2 collet look identical in a directory listing.
stated=$(grep -m1 '^ECHO: "build: ' "$tmp/err" | sed 's/^ECHO: "//; s/"$//')
echo "note  $stated"
rows=$(grep '^ECHO: "PART|' "$tmp/err" | sed 's/^ECHO: "PART|//; s/"$//')
if [ -z "$rows" ]; then echo "FAIL  the model lists no printed parts"; exit 1; fi
if [ -n "$only" ]; then
    rows=$(grep "|$only|" <<< "$rows" || true)
    if [ -z "$rows" ]; then
        echo "FAIL  no part is named $only in this build; the print list names them"
        exit 1
    fi
fi

label="${build:-default}"
dir="${2:-output}/$label"
mkdir -p "$dir"
list="$dir/print-list.md"
: > "$tmp/rows.md"
failed=0
pieces=0
parts=0

# One row's render. Every part renders through bioreactor.scad, whichever half it belongs to:
# that file carries the build's designations, and head.scad's own tail calls head() with no
# build. The manifest's file column says which half a row belongs to, which decides the render
# flags. render_all overrides every other flag, so it has to go off before the row's own go on;
# export_at_origin puts a head part where head.scad would have put it instead of at its
# assembled height, which moves the part and does not change its shape. stderr is kept per part
# for the pass below to read.
render() {
    IFS='|' read -r file name _ flags <<< "$1"
    case "$file" in
        scad/head.scad)  half=(-D render_vessel=false -D render_frame=false -D render_head=true -D export_at_origin=true) ;;
        scad/frame.scad) half=(-D render_vessel=false -D render_head=false -D render_frame=true) ;;
        *) echo "no render flags known for $file" > "$tmp/$name.err"; return ;;
    esac
    # shellcheck disable=SC2086
    "$OPENSCAD" $sel -D render_all=false "${half[@]}" $flags -o "$dir/$name.stl" scad/bioreactor.scad 2>"$tmp/$name.err" >/dev/null
}
export -f render
export OPENSCAD tmp dir sel
xargs -d '\n' -P "$JOBS" -I{} bash -c 'render "$1"' _ {} <<< "$rows"

# Then each part, in the manifest's order, judged off what its render left behind.
while IFS='|' read -r file name qty flags; do
    [ -z "$name" ] && continue
    parts=$((parts + 1))
    pieces=$((pieces + qty))
    out="$dir/$name.stl"
    cp "$tmp/$name.err" "$tmp/e"
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
    if grep -q '^ERROR\|^no render flags' "$tmp/e"; then
        echo "FAIL  $name"; grep -m1 '^ERROR\|^no render flags' "$tmp/e" | sed 's/^/        /'; failed=1
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

# One part alone is for looking at it; the list is the whole build's.
if [ -n "$only" ]; then exit $failed; fi

# Which printers take these, asked of purchased/printers.scad with the sizes off the meshes.
# Reported, not targeted; a part that fits nothing is the only thing that fails.
{
    # printers.scad explicitly, not by way of head.scad: the fit rule is this stub's dependency
    # and it should say so rather than lean on another file's include chain.
    printf 'include <%s/scad/purchased/printers.scad>\n' "$PWD"
    printf 'include <%s/scad/bioreactor.scad>\n_s = [' "$PWD"
    while read -r n w d h; do printf '["%s", [%s, %s, %s]],' "$n" "$w" "$d" "$h"; done < "$tmp/sizes"
    printf '];\n'
    printf 'for (s = _s) if (len(printers_fitting(s[1])) == 0) echo(str("NOFIT|", s[0]));\n'
    printf 'echo(str("ALLFIT|", [for (p = printers) if (len([for (s = _s) if (!printer_fits(p, s[1])) 1]) == 0) printer_name(p)]));\n'
} > "$tmp/fit.scad"
# shellcheck disable=SC2086
"$OPENSCAD" $sel -D render_all=false -o "$tmp/fit.csg" "$tmp/fit.scad" 2>"$tmp/fit" >/dev/null
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
  echo "**\`$stated\`** — the model's own statement of what this is. A part whose designation"
  echo "differs from this list's is a different part, whatever its file is called."
  echo
  echo "Food-grade clear PETG for anything the culture touches, grey PETG for structure -"
  echo "food-grade is a purchasing constraint, not a colour. The gasket cutter"
  echo "is a tool rather than a part of the reactor, and you need it to cut the rim gasket."
  echo "Assembly, and the numbers that go with it, are in [docs/build.md](../../docs/build.md)."
  echo
  echo "**This is the reactor's own parts** - the lid and everything hanging from it, and the"
  echo "frame's base, top base, ribs and rod spacers, plus the drive's own parts under whichever"
  echo "drive this build names. It is NOT everything this repo prints: the cart, the electronics"
  echo "stand, the bottle holder and the peri pump mount each render from their own file and reach"
  echo "no manifest, which \`just check-parts\` records rather than hides."
  echo
  echo "**Printers that take every part on this list:** $allfit. Reported, not targeted - the"
  echo "design is what it is and this says what it needs, measured off the meshes below rather"
  echo "than off the model. \`scad/bioreactor.scad\` reports the same thing from the geometry and"
  echo "should agree; the two disagreeing means a part is not on this list."
  echo "Volumes: [scad/purchased/printers.scad](../../scad/purchased/printers.scad)."
  echo
  echo "Sizes are the exported mesh's own bounding box. A part is written where its own file"
  echo "draws it - the head's at the lid's datum, the frame's at their height in the stack - so"
  echo "let the slicer drop it to the bed. What the size column is for is whether it fits the bed"
  echo "at all. The baffle pieces are the ones to watch."
  echo
  echo '| part | qty | file | size, mm | triangles |'
  echo '| --- | --- | --- | --- | --- |'
  cat "$tmp/rows.md"
  echo
  echo "The bought parts are in [purchased-parts.csv](../../purchased-parts.csv)."
} > "$list"

echo "ok    $list  ($pieces pieces, $parts parts)"
exit $failed
