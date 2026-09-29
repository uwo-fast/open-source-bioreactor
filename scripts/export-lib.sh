#!/usr/bin/env bash
#
# What export-parts.sh does to a part, as functions, so exporting one build and exporting every
# vessel judge a part and write a print list the same way. Sourced, not run; the caller sets
# OPENSCAD, JOBS, SEAM_CEILING and tmp, and a failure sets `failed`.
# shellcheck disable=SC2034,SC2154

# The model's print list for a build: `sel` is empty for the file's own defaults, or a -p/-P pair,
# and the rows land in $2.rows ("file|name|qty|flags") with the model's statement of the build in
# $2.stated and the render's stderr in $2.err. Returns 1 when the build does not resolve; the
# caller reports it.
export_manifest() {
    local sel="$1" out="$2"
    cat > "$out.scad" <<SCAD
include <$PWD/scad/bioreactor.scad>
_v = reactor_vessel;
for (p = head_print_parts(vessel_opening_diameter(_v), lid_flange_height,
                          vessel_internal_height(_v), vessel_punt_height(_v), drive_name, sparger_name, lid_center_name))
  echo(str("PART|scad/head.scad|", p[0], "|", p[1], "|", p[2]));
for (p = frame_print_parts(n_rods, drive_name, frame_riser_height(_v, _reactor_light, _build_magnet, drive_name) > 0))
  echo(str("PART|scad/frame.scad|", p[0], "|", p[1], "|", p[2]));
SCAD
    # shellcheck disable=SC2086
    "$OPENSCAD" $sel -D render_all=false -o "$out.csg" "$out.scad" 2>"$out.err" >/dev/null
    grep -m1 '^ECHO: "build: ' "$out.err" | sed 's/^ECHO: "//; s/"$//' > "$out.stated"
    grep '^ECHO: "PART|' "$out.err" | sed 's/^ECHO: "PART|//; s/"$//' > "$out.rows"
    ! grep -q '^ERROR' "$out.err"
}

# The flags that isolate one half of the assembly. Every part renders through bioreactor.scad,
# whichever half it belongs to: that file carries the build's designations, and head.scad's own
# tail calls head() with no build. render_all overrides every other flag, so it goes off first;
# export_at_origin puts a head part where head.scad would have put it rather than at its
# assembled height, which moves the part and does not change its shape.
export_half_flags() {
    case "$1" in
        scad/head.scad)  echo "-D render_vessel=false -D render_frame=false -D render_head=true -D export_at_origin=true" ;;
        scad/frame.scad) echo "-D render_vessel=false -D render_head=false -D render_frame=true" ;;
        *) return 1 ;;
    esac
}

# Render jobs, JOBS at a time. A job is "sel|file|flags|out|err"; `out` is written as whatever its
# extension says, an STL to print or a CSG to compare. stderr goes to `err` for the judge.
export_render_one() {
    local sel file flags out err half
    IFS='|' read -r sel file flags out err <<< "$1"
    if ! half=$(export_half_flags "$file"); then
        echo "no render flags known for $file" > "$err"
        return
    fi
    # shellcheck disable=SC2086
    "$OPENSCAD" $sel -D render_all=false $half $flags -o "$out" scad/bioreactor.scad 2>"$err" >/dev/null
}
export_render() {
    export -f export_render_one export_half_flags
    export OPENSCAD
    xargs -d '\n' -P "$JOBS" -I{} bash -c 'export_render_one "$1"' _ {} < "$1"
}

# A CSG's identity: the text with the empty groups a branch that draws nothing leaves behind
# stripped out, since they carry no geometry and differ between builds that differ elsewhere.
export_csg_key() {
    /usr/bin/python3 -c 'import re, sys, hashlib
s = open(sys.argv[1]).read()
while True:
    t = re.sub(r"^\s*group\(\);\n", "", s, flags=re.M)
    t = re.sub(r"^\s*group\(\) \{\s*\}\n", "", t, flags=re.M)
    if t == s: break
    s = t
print(hashlib.sha256(s.encode()).hexdigest())' "$1"
}

# Judge one exported part and append its row to $4 (the list's table) and its size to $5.
# A failing render still exits 0 and writes a small file, so nothing here is gated on $?: stderr
# is the signal and the file size is the backstop.
export_judge() {
    local name="$1" qty="$2" out="$3" rows="$4" sizes="$5" err="$6" size tris raw box open_edges over_edges dup_faces
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
    # How well the written mesh closes. OpenSCAD's own "not a valid 2-manifold" is about the CSG
    # result, not the file it then writes, so a tangency that tessellates into coincident faces
    # passes it and reaches the slicer.
    read -r _ open_edges over_edges dup_faces <<< "$(scripts/stl-seams.sh "$out" 2>/dev/null)"
    if grep -q '^ERROR\|^no render flags' "$err"; then
        echo "FAIL  $name"; grep -m1 '^ERROR\|^no render flags' "$err" | sed 's/^/        /'; failed=1
        printf '| %s | %s | — | — | **did not build** |\n' "$name" "$qty" >> "$rows"
    elif grep -qi '2-manifold' "$err"; then
        echo "FAIL  $name  not a valid 2-manifold"; failed=1
        printf '| %s | %s | `%s.stl` | — | **not a 2-manifold** |\n' "$name" "$qty" "$name" >> "$rows"
    elif [ "$size" -le 1 ]; then
        echo "FAIL  $name  rendered nothing"; failed=1
        printf '| %s | %s | — | — | **rendered nothing** |\n' "$name" "$qty" >> "$rows"
    elif [ "${open_edges:-0}" -gt 0 ] || [ "${over_edges:-0}" -gt 0 ] || [ "${dup_faces:-0}" -gt 0 ]; then
        # A hole is always this project's problem. A handful of coincident faces is a tangency the
        # renderer left, zero-volume and dropped by any slicer; a great many is two solids sharing
        # a face, which is a defect in the model.
        if [ "${open_edges:-0}" -eq 0 ] && [ "${over_edges:-0}" -le "$SEAM_CEILING" ]; then
            printf 'note  %-28s x%-3s %-16s %s triangles, %s coincident edges\n' \
                "$name" "$qty" "$box mm" "$tris" "$over_edges"
            printf '| %s | %s | `%s.stl` | %s | %s (%s coincident edges) |\n' \
                "$name" "$qty" "$name" "$box" "$tris" "$over_edges" >> "$rows"
            echo "$name $raw" >> "$sizes"
        else
            echo "FAIL  $name  the mesh does not close: $open_edges edges on one face, $over_edges on more than two (ceiling $SEAM_CEILING), $dup_faces repeated triangles"; failed=1
            printf '| %s | %s | `%s.stl` | %s | **does not close: %s/%s/%s** |\n' \
                "$name" "$qty" "$name" "$box" "$open_edges" "$over_edges" "$dup_faces" >> "$rows"
        fi
    else
        printf 'ok    %-28s x%-3s %-16s %s triangles\n' "$name" "$qty" "$box mm" "$tris"
        printf '| %s | %s | `%s.stl` | %s | %s |\n' "$name" "$qty" "$name" "$box" "$tris" >> "$rows"
        echo "$name $raw" >> "$sizes"
    fi
}

# Which registered printers take every part in a sizes file, asked of purchased/printers.scad
# with the sizes off the meshes. Reported, not targeted. Prints the list of printers, and writes
# the name of any part that fits none to $3, which the caller fails on: this runs in the
# subshell that captures its output, so it cannot set `failed` itself.
export_fits() {
    local sizes="$1" sel="$2" nofit="$3" stub="$tmp/fit.$RANDOM"
    {
        # printers.scad explicitly, not by way of head.scad: the fit rule is this stub's dependency
        # and it should say so rather than lean on another file's include chain.
        printf 'include <%s/scad/purchased/printers.scad>\n' "$PWD"
        printf 'include <%s/scad/bioreactor.scad>\n_s = [' "$PWD"
        while read -r n w d h; do printf '["%s", [%s, %s, %s]],' "$n" "$w" "$d" "$h"; done < "$sizes"
        printf '];\n'
        printf 'for (s = _s) if (len(printers_fitting(s[1])) == 0) echo(str("NOFIT|", s[0]));\n'
        printf 'echo(str("ALLFIT|", [for (p = printers) if (len([for (s = _s) if (!printer_fits(p, s[1])) 1]) == 0) printer_name(p)]));\n'
    } > "$stub.scad"
    # shellcheck disable=SC2086
    "$OPENSCAD" $sel -D render_all=false -o "$stub.csg" "$stub.scad" 2>"$stub.err" >/dev/null
    grep '^ECHO: "NOFIT|' "$stub.err" | sed 's/.*NOFIT|//; s/"$//' > "$nofit"
    grep -m1 '^ECHO: "ALLFIT|' "$stub.err" | sed 's/.*ALLFIT|//; s/"$//; s/[]["]//g'
}

# The print list's fixed text, after its title and what it is.
export_list_body() {
    local allfit="$1" rows="$2" up="$3"
    echo "Food-grade clear PETG for anything the culture touches, grey PETG for structure -"
    echo "food-grade is a purchasing constraint, not a colour. The gasket cutter"
    echo "is a tool rather than a part of the reactor, and you need it to cut the rim gasket."
    echo "Assembly, and the numbers that go with it, are in [docs/build.md]($up/docs/build.md)."
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
    echo "Volumes: [scad/purchased/printers.scad]($up/scad/purchased/printers.scad)."
    echo
    echo "Sizes are the exported mesh's own bounding box. A part is written where its own file"
    echo "draws it - the head's at the lid's datum, the frame's at their height in the stack - so"
    echo "let the slicer drop it to the bed. What the size column is for is whether it fits the bed"
    echo "at all. The baffle pieces are the ones to watch."
    echo
    echo '| part | qty | file | size, mm | triangles |'
    echo '| --- | --- | --- | --- | --- |'
    cat "$rows"
    echo
    echo "The bought parts are in [purchased-parts.csv]($up/purchased-parts.csv)."
}
