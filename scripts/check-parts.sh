#!/usr/bin/env bash
#
# Fail when a printed part exists that the print manifest does not carry.
#
: "${OPENSCAD:=openscad}"
: "${ENTRY:?the justfile exports the list of files that render on their own}"

set -uo pipefail
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT
not_printed=(
    render_all                  # the meta flag every other one is measured against
    render_bayonet_lock         # a view of channels the lid buries; the locks print WITH the lid
    render_culture              # the broth at the fill line, which is not a part
    render_motor                # vitamin
    render_motor_mount_inserts  # vitamin, and heat-set into the lid rather than printed
    render_motor_mount_screws   # vitamin
    render_shaft_coupler        # vitamin
    render_bearing              # vitamin
    render_ext_shaft            # vitamin
    render_set_screws           # vitamin
    render_probes               # vitamin - the Atlas bodies hanging in their collets
    render_seals                # purchased EPDM: the rim gasket, the plug ring, the port rings
    render_sparge_tubes         # vitamin - the 316 SS riser and support, bought as stock and cut
    render_tube_pinlock         # a whole CLASS of port at once; the manifest names each one
    render_probe_pinlock        # through port_to_render, which is what makes them separate
    render_thermocouple_pinlock # parts rather than one STL of five
    render_baffle_pinlock       #
    render_rods                 # vitamin - the M8 studding and its nuts, cut from stock
    render_lights               # vitamin - the LED strips the frame makes room for
)
cat > "$tmp/m.scad" <<SCAD
include <$PWD/scad/assembly.scad>
_v = reactor_vessel;
for (p = head_print_parts(vessel_opening_diameter(_v), lid_flange_height,
                          vessel_internal_height(_v), vessel_punt_height(_v)))
  echo(str("PART|", p[2]));
for (p = frame_print_parts(n_rods)) echo(str("PART|", p[2]));
SCAD
"$OPENSCAD" -D render_all=false -o "$tmp/m.csg" "$tmp/m.scad" 2>"$tmp/err" >/dev/null
manifest=$(grep '^ECHO: "PART|' "$tmp/err" | sed 's/^ECHO: "PART|//; s/"$//')
if [ -z "$manifest" ]; then echo "FAIL  could not read the print manifest"; exit 1; fi
failed=0
for f in $(grep -hoE '^render_[a-z_]+' scad/head.scad scad/frame.scad | sort -u); do
    listed=0
    for n in "${not_printed[@]}"; do [ "$n" = "$f" ] && listed=1; done
    if grep -q -- "$f=true" <<< "$manifest"; then
        if [ "$listed" = 1 ]; then
            echo "FAIL  $f  is in the manifest AND listed as not printed - drop it from one"
            failed=1
        fi
    elif [ "$listed" = 0 ]; then
        echo "FAIL  $f  renders something no print manifest row asks for"
        echo "        add it to head_print_parts() or frame_print_parts(), whichever file it is"
        echo "        in, or to not_printed in check-parts if it makes nothing anybody prints"
        failed=1
    fi
done
# AND EVERY ENTRY FILE IS ACCOUNTED FOR, which is the other half of the same hole. The two
# manifests live in head.scad and frame.scad, so a printed part in any OTHER file that renders
# on its own reaches no print list and nothing notices - true today of the pump mount, the cart,
# the stand and the bottle holder. This does not put them on a list. It stops the omission being
# silent, which is what let the print list call itself the whole reactor while covering two
# files of eighteen.
exported=(scad/head.scad scad/frame.scad)
not_exported=(
    scad/assembly.scad                          # the whole reactor as a picture, not a part
    scad/custom/bayonet_baffle_port.scad        # a COMPONENT: head.scad renders it into a
    scad/custom/bayonet_port.scad               # manifest row of its own, so it reaches a print
    scad/custom/bayonet_probe_port.scad         # list through head rather than on its own. Its
    scad/custom/bayonet_thermocouple_port.scad  # standalone render is a preview of the part,
    scad/custom/cylindrical_flex_collet.scad    # not a second copy of it
    scad/custom/gasket_cutter.scad
    scad/custom/impeller.scad
    scad/custom/motor_mount.scad
    scad/custom/sparger.scad                    # exported through head's manifest as "sparger";
                                                # this file's own render is a preview of it
    scad/custom/sheet_gasket.scad               # EPDM cut from a sheet with a knife, not printed
    # Bench furniture AROUND the reactor rather than part of it, and only ONE of the three
    # makes anything printed - which is not what this list said until it was read.
    scad/bottle_holder.scad                     # one printed part, a dovetailed sleeve. The
                                                # only original printed geometry of the three,
                                                # and an accessory rather than a reactor part
    scad/cart.scad                              # prints NOTHING: bought extrusion, bought
                                                # NopSCADlib brackets, bought castors, and a
                                                # translucent envelope that is a picture
    scad/electronics_stand.scad                 # prints nothing original either - print_corner
                                                # renders a NopSCADlib BRACKET, which is a
                                                # vitamin, so that is a printed substitute for
                                                # a bought part. See TODO.md
    scad/custom/peri_pump_frame_mount.scad      # printed and part of the reactor, but waiting on
                                                # where the bought pumps mount at all
    scad/custom/peri_pump_head.scad             # a stretch goal rather than this build
    scad/custom/gasket_cutter_v2.scad           # WORK IN PROGRESS - a cutter built around a
                                                # standard #11 blade rather than a printed edge.
                                                # It renders so it can be previewed while it is
                                                # worked on, and reaches no print list because
                                                # there is not yet a part to print
)
for f in $ENTRY; do
    seen=0
    for e in "${exported[@]}"; do [ "$e" = "$f" ] && seen=$((seen + 1)); done
    for n in "${not_exported[@]}"; do [ "$n" = "$f" ] && seen=$((seen + 2)); done
    if [ "$seen" = 0 ]; then
        echo "FAIL  $f  renders on its own and reaches no print list"
        echo "        give it a manifest and walk it in export-parts, or say here why not"
        failed=1
    elif [ "$seen" = 3 ]; then
        echo "FAIL  $f  is both walked by export-parts and declared as not walked"
        failed=1
    fi
done

[ $failed -eq 0 ] && echo "ok    every printed part is on the print manifest"
exit $failed
