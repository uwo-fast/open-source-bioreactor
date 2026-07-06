/**
 * @file castor.scad
 * @brief Creates a swivel plate castor for the open-source-bioreactor project
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A representative swivel plate castor: a top mounting plate (top face at the
 * origin) with a 4-hole bolt pattern, a central swivel column, a fork, and an
 * offset wheel. The whole castor hangs below z = 0, so it can be dropped
 * straight onto the underside of a frame member.
 */

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 48 : 96;

function castor_plate_size(type) = [type[1][0], type[1][1]]; // mounting plate [x, y]
function castor_bolt_spacing(type) = [type[1][2], type[1][3]]; // bolt hole spacing [x, y]
function castor_bolt_diameter(type) = type[1][4]; // mounting bolt hole diameter
function castor_plate_thickness(type) = type[1][5]; // mounting plate thickness
function castor_mount_height(type) = type[1][6]; // plate top face to floor (overall height)
function castor_wheel_diameter(type) = type[1][7]; // wheel diameter
function castor_wheel_width(type) = type[1][8]; // wheel width
function castor_swivel_offset(type) = type[1][9]; // wheel axle offset from swivel axis (trail)

/**
 * @brief Creates a swivel plate castor from a registered type
 * @param type Registered parameter set (see castors.scad)
 * @param swivel Rotation of the fork+wheel about the vertical swivel axis (deg)
 */
module castor(type, swivel = 0) {
  ps = castor_plate_size(type);
  pt = castor_plate_thickness(type);
  bs = castor_bolt_spacing(type);
  bd = castor_bolt_diameter(type);
  mh = castor_mount_height(type);
  wd = castor_wheel_diameter(type);
  ww = castor_wheel_width(type);
  trail = castor_swivel_offset(type);

  axle_z = -(mh - wd / 2); // wheel axle height (wheel bottom sits on the floor)

  // mounting plate, top face flush with z = 0
  color("silver")
    translate([0, 0, -pt / 2])
      difference() {
        cube([ps.x, ps.y, pt], center=true);
        for (sx = [-1, 1], sy = [-1, 1])
          translate([sx * bs.x / 2, sy * bs.y / 2, 0])
            cylinder(d=bd, h=pt + 1, center=true);
      }

  // fork + wheel swivel about the central vertical axis
  rotate([0, 0, swivel]) {
    // fork: blends the central swivel column down to the offset wheel hub
    color("dimgray")
      hull() {
        translate([0, 0, -pt]) mirror([0, 0, 1]) cylinder(d=ww * 1.4, h=1);
        translate([trail, 0, axle_z]) rotate([90, 0, 0]) cylinder(d=ww * 1.3, h=ww + 6, center=true);
      }

    // wheel
    color("gray")
      translate([trail, 0, axle_z]) rotate([90, 0, 0]) cylinder(d=wd, h=ww, center=true);

    // axle
    color("silver")
      translate([trail, 0, axle_z]) rotate([90, 0, 0]) cylinder(d=bd, h=ww + 8, center=true);
  }
}
