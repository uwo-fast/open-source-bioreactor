/**
 * @file support/estop_box.scad
 * @brief A two-piece box for a panel-mount e-stop: an open base and a screw-down lid
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Square, sized by the body's wider side plus wire_space all round and below. The neck goes
 * through the lid's centre bore, the lid screws into four corner posts, and the wires leave by
 * one hole in the +y wall. Measure the four e-stop numbers and everything else follows from them.
 *
 * DATUM: z = 0 is the underside of the base.
 */

$fn = $preview ? 64 : 128;

/* [E-stop - measure these] */

// height of the body below the panel, from the lid's underside to the bottom of the contact blocks
estop_body_height = 45;
// body width across x, the widest point below the panel, contact blocks included
estop_body_width = 38;
// body length across y, the widest point below the panel, contact blocks included
estop_body_length = 30;
// panel cutout the neck passes through; 22.5 fits the 22 mm neck on a print
estop_neck_bore = 22.5;

/* [Box] */

// room for the wires, kept around the body on every side and below it
wire_space = 10;
// diameter of the hole the four wires leave by, a grommet's or gland's mounting hole
wire_hole_diameter = 8;
// side wall and floor thickness
wall = 2.4;
// lid thickness, which has to be inside the e-stop's panel clamping range
lid_thickness = 3;

/* [Screws] */

// diameter of the posts the lid screws into
post_diameter = 7;
// pilot hole in the post: 2.5 for an M3 self-tapping screw, or a heat-set insert's hole
screw_pilot_diameter = 2.5;
// clearance hole in the lid
screw_clearance_diameter = 3.4;

/* [Output] */

// what to draw: both parts laid out to print, one of them, or the box closed
part = "print"; // [print, base, lid, assembled]

module dummy() {
  // stop the customizer detection from here onwards
}

cavity_side = max(estop_body_width, estop_body_length) + 2 * wire_space;
cavity_z = estop_body_height + wire_space;
outer_side = cavity_side + 2 * wall;
base_height = wall + cavity_z;
// sunk half a wall into the corner so the post is not tangent to the walls
post_offset = cavity_side / 2 - post_diameter / 2 + wall / 2;
// the outside corners are arcs on the post centres, so the wall round each screw is even
corner_radius = outer_side / 2 - post_offset;

assert(
  wire_space >= post_diameter - wall / 2,
  str("estop_box: ", wire_space, " mm of wire space puts the corner posts into the body")
);

module at_posts() {
  for (sx = [-1, 1], sy = [-1, 1]) translate([sx * post_offset, sy * post_offset, 0]) children();
}

module rounded_square(h) {
  hull() at_posts() cylinder(r=corner_radius, h=h);
}

module base() {
  difference() {
    union() {
      difference() {
        rounded_square(base_height);
        translate([-cavity_side / 2, -cavity_side / 2, wall]) cube([cavity_side, cavity_side, cavity_z + 1]);
      }
      at_posts() cylinder(d=post_diameter, h=base_height);
    }
    at_posts() translate([0, 0, wall]) cylinder(d=screw_pilot_diameter, h=cavity_z + 1);
    // centred in the space below the body
    translate([0, cavity_side / 2 - 1, wall + wire_space / 2])
      rotate([-90, 0, 0]) cylinder(d=wire_hole_diameter, h=wall + 2);
  }
}

module lid() {
  difference() {
    rounded_square(lid_thickness);
    translate([0, 0, -1]) cylinder(d=estop_neck_bore, h=lid_thickness + 2);
    at_posts() translate([0, 0, -1]) cylinder(d=screw_clearance_diameter, h=lid_thickness + 2);
  }
}

echo(str("estop_box: outside ", outer_side, " x ", outer_side, " x ", base_height + lid_thickness, " mm closed"));

if (part == "base") base();
else if (part == "lid") lid();
else if (part == "assembled") {
  base();
  translate([0, 0, base_height]) lid();
} else {
  base();
  translate([outer_side + 5, 0, 0]) lid();
}
