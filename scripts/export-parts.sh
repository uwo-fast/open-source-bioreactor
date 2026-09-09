#!/usr/bin/env bash
#
# Export every printed part as its own STL, with a print list. $1 one vessel, $2 the output root.
#
: "${OPENSCAD:=openscad}"

# A failing render still exits 0 and writes a small file, the same as check-mesh, so nothing
# here may be gated on $?. stderr is the signal and the file size is the backstop.
set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT

sel=()
label="${1:-}"
if [ -n "${1:-}" ]; then sel=(-p scad/assembly.json -P "${1:-}"); fi

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
"$OPENSCAD" "${sel[@]}" -D render_all=false -o "$tmp/m.csg" "$tmp/m.scad" 2>"$tmp/err" >/dev/null
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

dir="${2:-output}/$label"
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
    "$OPENSCAD" ${sel[@]+"${sel[@]}"} -D render_all=false "${half[@]}" $flags -o "$out" scad/assembly.scad 2>"$tmp/e" >/dev/null
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
"$OPENSCAD" "${sel[@]}" -D render_all=false -o "$tmp/fit.csg" "$tmp/fit.scad" 2>"$tmp/fit" >/dev/null
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
