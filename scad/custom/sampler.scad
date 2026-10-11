/**
 * @file sampler.scad
 * @brief Turbidity sampler on a lid port: a flow cell round the turbidity probe's board, drawn
 *        through by a syringe actuator bolted on top
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Two prints. The base is the std bayonet pin with a skirt out to the housing, and the floor under
 * the board. The top houses the board, split at the PCB's underside, and grows a shroud that flares
 * into the face the actuator bolts to. The board drops into the top upside down and the base
 * closes it; a clear tube runs through both between the board's heads. The dip tube is the port's
 * own sparge riser, drilled where the sample is drawn, bushed into the tube's bottom.
 *
 * Port frame: origin on the port's axis at the lid's outer face, +z out of the vessel, +x radially
 * outward. The reactor's figures are restated for jar_10L until head.scad places the sampler
 * (TODO.md). The fits are checked by `just check-sampler`.
 */

use <turbidity-sensor/hardware/probe/probe.scad>
use <syringe-actuator/cad/main.scad>
use <bayonet_port.scad>
include <bayonet_interfaces.scad>
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/nuts.scad>
include <NopSCADlib/vitamins/inserts.scad>
// an exception to docs/architecture.md until head.scad passes the inserts in (TODO.md)
include <../purchased/heat_set_inserts.scad>

part = "assembly"; // [assembly, base, top]
// print: lay the base upside down on its parting face, the top face-down on its 4-hole face
orient = "print"; // [print, assembly]
$fn = 64;

// ---- sources ----
// head.scad: the lid is lid_flange_height 8 + lid_plug_height 10 thick
panel = 18;
flange_h = bayonet_flange_height(bayonet_std);
// head.scad, jar_10L: the riser is 4 x 0.5 steel, bored 0.2 over, sealed by the 4x1.5 rod o-ring;
// it stands 14.9375 over its port's top and is cut 188.174; the culture's surface is 88.4342 from
// a riser's top end
riser_od = 4;
riser_id = 3;
riser_bore = riser_od / 2 + 0.2;
riser_proud = 14.9375;
riser_l = 188.174;
surface_z = flange_h + riser_proud - 88.4342;
// turbidity-sensor hardware/case/README.md: the clear tube is 5/16 in outside, 1/4 in inside, and
// a bore 0.2 over its outside holds it snugly
tube_od = 7.9375;
tube_id = 6.35;
tube_fit = 0.2;
// syringe-actuator, 5 mL, from its layout, in its frame: x along the syringe's axis, the nozzle
// towards -x, z up from the plate's underside. Its front face's holes and outline are [y, z].
act = actuator("5ml");
act_body = get(act, "body");
holes = get(act_body, "mount_front");
axis_z = get(act, "axis_z");
syringe_past_face = front_x(act) - tip_x(act);
barrel_od = get(get(act, "syringe"), "barrel_od");
// syringe-actuator's front wall, end_t thick
actuator_wall = get(act_body, "end_t");
// the front face in the port frame, its motor side (-z) out along +x
face_outline = [for (p = front_face(act_body)) to_port(p)];
// the luer-to-barb fitting, the syringe's tip to the clear tube's top end (measured); its barb is
// heat-set into the clear tube's top end, which stretches over it (docs/build.md)
fitting_l = 5;
// Fasteners. Base to top: heat-set inserts, as the head's motor mount uses, from the registered
// rows; screws and nuts are NopSCADlib's. Actuator to face: nuts in slots, since an M3 insert is
// longer than the plate.
outer_screw = M3_dome_screw;   // ISO 7380, from below at the outer corners
outer_screw_l = 8;
outer_insert = insert_m3x5p56_ss;
inner_screw = M2_cs_cap_screw; // ISO 10642, from above at the inner end
inner_screw_l = 6;
inner_insert = insert_m2x4p78_ss;
face_screw = M3_cap_screw;     // ISO 4762, from inside the actuator's front wall
face_screw_l = 8;
face_nut = M3_nut;

// ---- choices ----
clr = 0.2;        // round the board, per side; the case's proven fit
wall = 2;         // the housing's sides round the board's pocket
floor_t = 1.2;    // under the relief
roof_t = 1.2;     // over the connector
min_wall = 0.8;   // the thinnest any of them may be
corner_r = 4;
neck_h = 1;       // the housing overhangs the neighbours' flanges, and clears them by the lid's 1 mm
neck_r = bayonet_flange_radius(bayonet_std); // the pin's flange runs straight up into the skirt
// A skirt from the neck out to the outline, the hull of the two, so the underside slopes into the
// neck instead of stepping; it faces up when the base prints upside down
skirt_h = 8;
// Clear tube above the roof, for the fitting's barb, clear of the funnel. UNMEASURED: it has to cover
// the length the barb stretches the tube's end; 5 stands in until that is measured (TODO.md)
tube_above_roof = 5;
riser_under_window = 2;
bushing_l = 6;        // riser up inside the clear tube, through a 1/8 x 1/4 in silicone bushing
sample_under_surface = 40;
clamp_t = 2.2;      // base under each outer screw's head
seat_t = 2.5;       // top under the inner screw's countersink
shroud_id = barrel_od + 1;
shroud_wall = 2.4;
plate_t = 5;
lead_in = 0.6;
// the fasteners' holes, from their rows
outer_cbore_d = 2 * screw_head_radius(outer_screw) + 0.5;
outer_insert_d = 2 * insert_hole_radius(outer_insert);
outer_insert_l = insert_hole_length(outer_insert) + 1;
inner_clear_d = 2 * screw_clearance_radius(inner_screw);
inner_seat_d = 2 * screw_head_radius(inner_screw) + 0.6;
inner_insert_d = 2 * insert_hole_radius(inner_insert);
inner_insert_l = insert_hole_length(inner_insert) + 0.5;
face_clear_d = 2 * screw_clearance_radius(face_screw);
nut_slot_w = 2 * nut_flat_radius(face_nut) + 0.3;  // the nut's flats against its sides
nut_slot_t = nut_thickness(face_nut) + 0.2;
nut_slot_end = nut_radius(face_nut) + 0.15;         // its corners point along the slot

// ---- derived ----
pocket = probe_bbox(clr);            // board frame, its clearance included
axis = probe_optical_axis();         // where the clear tube runs, board frame
split_b = -clr;                      // the parting plane, board frame: the PCB pocket's floor
bot_b = pocket[0][2] - floor_t;      // the base's underside, board frame
top_b = pocket[1][2] + roof_t;       // the roof's top, board frame
base_z0 = flange_h + neck_h + skirt_h;  // the base's underside, port frame
board_z = base_z0 - bot_b;              // the board's z = 0, port frame
split_z = board_z + split_b;
roof_z = board_z + top_b;
window_z = board_z + probe_pcb()[0];    // the heads' bottom edge
riser_top_z = window_z - riser_under_window;
clear_z0 = riser_top_z - bushing_l;
face_z = roof_z + tube_above_roof + fitting_l + syringe_past_face;
plate_z0 = face_z - plate_t;
nut_z = plate_z0 + (plate_t - nut_slot_t) / 2;  // the nut slots' floor, the slots centred in the plate
shroud_r = shroud_id / 2 + shroud_wall;
bore_r = (tube_od + tube_fit) / 2;
function to_port(p) = [axis_z - p[1], p[0]]; // actuator [y, z] to port [x, y], its motor side out
// The pocket in the port frame: board y runs outward along -x from the axis
pocket_x = [axis[1] - pocket[1][1], axis[1] - pocket[0][1]];  // [inner, outer]
// the inner screw stands just outside the shroud tube, and its slot keeps min_wall to the inner end;
// its head sits flush in the countersink's top
inner_screw_x = -(shroud_r + inner_seat_d / 2 + 0.1);
inner_head_z = split_z + seat_t + (inner_seat_d - inner_clear_d) / 2;
// the outline: the pocket and its walls, wide enough for the inner screw's slot; its inner end a
// half-circle the housing's width across
half_w = max(pocket[1][0] + wall, -inner_screw_x + inner_seat_d / 2 + min_wall);
// each outer screw at the centre of a rounded corner, its insert min_wall clear of the pocket's
// outer end, so its counterbore keeps the same wall all round
outer_screw_x = pocket_x[1] + min_wall + outer_insert_d / 2;
outer_x = outer_screw_x + corner_r;
outer_screws = [for (s = [-1, 1]) [outer_screw_x, s * (half_w - corner_r)]];
outline_reach = norm([outer_x - corner_r, half_w - corner_r]) + corner_r;
top_skirt_h = outline_reach - shroud_r; // 45 degrees where it reaches farthest
flare_h = max([for (p = face_outline) norm(p)]) - shroud_r;
sampler_riser_l = riser_l - (flange_h + riser_proud - riser_top_z);
hole_from_top = riser_top_z - (surface_z - sample_under_surface);
line_ml = (hole_from_top * PI * pow(riser_id / 2, 2) + (window_z - riser_top_z) * PI * pow(tube_id / 2, 2)) / 1000;

assert(tube_od < probe_gap(), "the clear tube does not pass between the heads");
assert(half_w >= neck_r, "the pin's flange reaches past the housing's inner end, which would overhang");
assert(min(wall, floor_t, roof_t) >= min_wall, "a wall is thinner than min_wall");
assert(corner_r - outer_cbore_d / 2 >= min_wall, "an outer screw's counterbore breaks the rounded corner");
assert(inner_screw_x + inner_seat_d / 2 < pocket_x[0] - min_wall, "the inner screw's seat runs into the pocket");
assert(riser_top_z < split_z, "the riser's top reaches up into the top part");
assert(clear_z0 > flange_h, "the clear tube's seat reaches down into the pin");
assert(plate_z0 - flare_h > roof_z + top_skirt_h, "the face's flare reaches down into the top skirt");

echo(str("sampler: housing ", outer_x + half_w, " x ", 2 * half_w, ", face ", face_z, " over the lid; riser cut ",
         sampler_riser_l, ", drilled ", hole_from_top, " from its top end; clear tube cut ",
         roof_z + tube_above_roof - clear_z0, "; ", line_ml, " mL from the hole to the window"));

// The board in the port frame: its optical axis on the port's, its connector end outward (+x).
module board_place() {
  translate([0, 0, board_z]) rotate([0, 0, 90]) translate([-axis[0], -axis[1], 0]) children();
}

module outline() {
  offset(r=corner_r) offset(delta=-corner_r) hull() {
    translate([0, -half_w]) square([outer_x, 2 * half_w]);
    circle(r=half_w, $fn=192);
  }
}

// Each child hulled with the next: one solid through its sections in order, with no seam to step
module loft() for (i = [0 : $children - 2]) hull() { children(i); children(i + 1); }

// A round section for a loft, at height z
module disk(r, z) translate([0, 0, z]) cylinder(r=r, h=0.01, $fn=128);

// A blind hole up from z = 0, open 1 below it, its end a 45 degree point so it prints either way up
module drill(d, h) {
  translate([0, 0, -1]) cylinder(d=d, h=h + 1);
  translate([0, 0, h - 0.01]) cylinder(r1=d / 2, r2=0, h=d / 2);
}

// The slot between the heads where the clear tube passes, board frame, from z0 to z1: the tube's
// round bore would otherwise clip the heads' pockets and leave knife-edge cusps in the beam's path
module tube_slot(half, z0, z1) {
  translate([-half, axis[1] - bore_r - 0.5, z0]) cube([2 * half, pocket[1][1] - axis[1] + bore_r + 0.5, z1 - z0]);
}

module sampler_base() {
  difference() {
    union() {
      bayonet_port(type=bayonet_std, part="pin", panel_thickness=panel, center_bore_radius=riser_bore,
                   bore_oring=oring_4x1p5_epdm, catch_pockets=false);
      loft() {
        disk(neck_r, flange_h - 1);
        disk(neck_r, flange_h + neck_h);
        translate([0, 0, base_z0]) linear_extrude(split_z - base_z0) outline();
      }
    }
    // the relief under the board, opened past the arms' reliefs' inner edges across the tube's path,
    // its floor level with theirs so it bridges in the same layer when printed
    board_place() {
      probe(clr);
      tube_slot(probe_heads()[0] + 0.5, pocket[0][2], split_b + 0.01);
    }
    // the clear tube's seat, with a lead-in from the split, and the riser's bore below it; the seat
    // narrows to the riser's bore at 45 degrees, which still stops the tube's end (its outside wall
    // meets the cone at once) and prints upside down with nothing to bridge
    translate([0, 0, clear_z0]) cylinder(r=bore_r, h=split_z - clear_z0 + 1);
    translate([0, 0, clear_z0 - (bore_r - riser_bore) + 0.01]) cylinder(r1=riser_bore, r2=bore_r, h=bore_r - riser_bore);
    translate([0, 0, split_z - lead_in]) cylinder(r1=bore_r, r2=bore_r + lead_in, h=lead_in + 0.01);
    translate([0, 0, flange_h - 2]) cylinder(r=riser_bore, h=clear_z0 - flange_h + 3);
    // the outer screws, from below: clearance through to the split, counterbored up from the
    // underside to leave clamp_t under the head
    for (p = outer_screws) translate([each p, 0]) {
      translate([0, 0, split_z - clamp_t - 1]) cylinder(r=screw_clearance_radius(outer_screw), h=clamp_t + 2);
      translate([0, 0, base_z0]) cylinder(d=outer_cbore_d, h=split_z - clamp_t - base_z0);
      // below the skirt's top edge the underside slopes in, so the counterbore opens straight out
      // to the corner there: a clean notch, not a wall that feathers to nothing round its mouth
      hull() for (o = [[0, 0], [20, sign(p[1]) * 20]]) translate([each o, -1]) cylinder(d=outer_cbore_d, h=base_z0 + 1.01);
    }
    // the inner screw's insert, from the split down
    translate([inner_screw_x, 0, split_z]) mirror([0, 0, 1]) drill(inner_insert_d, inner_insert_l);
  }
}

module sampler_top() {
  difference() {
    // the housing, its skirt up into the shroud tube at 45 degrees where it reaches farthest, and
    // the flare out to the face: nothing past 45 when the top prints face-down
    loft() {
      translate([0, 0, split_z]) linear_extrude(roof_z - split_z) outline();
      disk(shroud_r, roof_z + top_skirt_h);
      disk(shroud_r, plate_z0 - flare_h);
      translate([0, 0, plate_z0]) linear_extrude(plate_t) polygon(face_outline);
    }
    // the outer screws' inserts, from the split up
    for (p = outer_screws) translate([each p, split_z]) drill(outer_insert_d, outer_insert_l);
    // the inner screw: clearance through seat_t, a 90 degree countersink, and a slot up through the
    // skirt and out through the inner end for the driver
    translate([inner_screw_x, 0, 0]) {
      translate([0, 0, split_z - 1]) cylinder(d=inner_clear_d, h=seat_t + 1.01);
      translate([0, 0, split_z + seat_t]) cylinder(r1=inner_clear_d / 2, r2=inner_seat_d / 2, h=inner_head_z - split_z - seat_t);
      hull() for (x = [0, -50]) translate([x, 0, inner_head_z - 0.01]) cylinder(d=inner_seat_d, h=roof_z + top_skirt_h - inner_head_z + 2);
    }
    board_place() {
      probe(clr);
      // The board goes in upside down, heads first, so the PCB's layer passes all of it: the heads
      // stand wider than the arms, and the connector overhangs the PCB's end
      translate([0, 0, split_b - 1]) linear_extrude(probe_pcb()[0] + clr - split_b + 1) projection() probe(clr);
      // the tube's slot, opened whole from the parting face to the heads' tops
      tube_slot(probe_heads()[0] + 0.1, split_b - 1, probe_heads()[4] + clr);
      // the connector's window: its plug enters through the outer end
      conn = probe_connector();
      translate([-conn[0] - clr, -50, split_b - 1]) cube([2 * (conn[0] + clr), 50 + conn[2], conn[3] + clr - split_b + 1]);
    }
    // the clear tube's bore up through the roof, then the syringe's way down to it, its floor a 45
    // degree funnel into the bore, so the floor prints face-down and leads the tube in
    _funnel = shroud_id / 2 - bore_r;
    translate([0, 0, split_z - 1]) cylinder(r=bore_r, h=roof_z - split_z + 1.01);
    translate([0, 0, roof_z - 0.01]) cylinder(r1=bore_r, r2=shroud_id / 2, h=_funnel + 0.01);
    translate([0, 0, roof_z + _funnel - 0.01]) cylinder(d=shroud_id, h=face_z - roof_z - _funnel + 1);
    // the actuator's holes down from the face, and a nut slot for each, entered from the face's
    // nearer side edge (+-y), the short way out
    for (h = holes) translate([each to_port(h), 0]) {
      translate([0, 0, face_z]) mirror([0, 0, 1]) drill(face_clear_d, plate_t + 1);
      translate([-nut_slot_w / 2, h[0] > 0 ? -nut_slot_end : -50, nut_z]) cube([nut_slot_w, 50 + nut_slot_end, nut_slot_t]);
    }
  }
}

// Every fastener in place: the outer screws from below and their inserts in the top, the inner
// screw from above and its insert in the base, and the actuator's screws and nuts. lift stands each
// head that much off its seat, so a check reads a seated head as contact, not overlap.
module sampler_fasteners(inserts=true, lift=0) {
  for (p = outer_screws) {
    translate([each p, split_z - clamp_t - lift]) rotate([180, 0, 0]) screw(outer_screw, outer_screw_l);
    if (inserts) translate([each p, split_z]) rotate([180, 0, 0]) insert(outer_insert);
  }
  translate([inner_screw_x, 0, inner_head_z + lift]) screw(inner_screw, inner_screw_l);
  if (inserts) translate([inner_screw_x, 0, split_z]) insert(inner_insert);
  for (h = holes) translate([each to_port(h), 0]) {
    translate([0, 0, face_z + actuator_wall]) screw(face_screw, face_screw_l);
    translate([0, 0, nut_z + (nut_slot_t - nut_thickness(face_nut)) / 2]) rotate([0, 0, 90]) nut(face_nut);
  }
}

// print orientation: turned over about z
module lay(z) if (orient == "print") translate([0, 0, z]) rotate([180, 0, 0]) children(); else children();

if (part == "base") lay(split_z) sampler_base();
else if (part == "top") lay(face_z) sampler_top();
else if (part == "assembly") {
  color("orange") sampler_base();
  color("darkorange") sampler_top();
  %board_place() probe();
  sampler_fasteners();
  %translate([0, 0, clear_z0]) cylinder(d=tube_od, h=roof_z + tube_above_roof - clear_z0);
  %translate([0, 0, riser_top_z - sampler_riser_l]) cylinder(d=riser_od, h=sampler_riser_l);
}
