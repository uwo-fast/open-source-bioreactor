/**
 * @file sparge_ring.scad
 * @brief Ring sparger for a stirred tank: a hollow ring with radial gas holes and a top feed boss.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Why a ring and not a pipe, and why THIS ring, is docs/agitation.md. What the module needs to
 * know is that the section is deliberately NOT round. It sits in the annulus between the baffles
 * and the jar's mouth, which is a few millimetres wide, while the space above and below it is tens
 * of millimetres. A round tube of any useful bore does not fit that band at any diameter; a tall
 * narrow section does, and it is the one thing a printed ring can do that a bent one cannot.
 *
 * The feed does not attach at the ring's radius at all. A round boss there is wider than the
 * section and fouls the baffles on one side and the jar's mouth on the other. Instead an ARM runs
 * inboard, along the one angular sector that has no baffle in it - the air inlet's - and ends in a
 * vertical socket directly under the lid port. The riser is then a straight tube with no bend and
 * no hollow tee to build: the junction is printed into this part.
 */

z_fight = $preview ? 0.05 : 0;
$fn = $preview ? 64 : 128;

/**
 * @brief Hollow ring sparger.
 *
 * @param radius        Ring centreline radius
 * @param section       [radial, axial] of the ring's outer section
 * @param wall          Wall thickness around the bore
 * @param hole_diameter Gas hole diameter
 * @param hole_count    Number of gas holes, equally spaced
 * @param feed_angle    Angular sector the arm runs along, degrees. Must be one with no baffle.
 * @param feed_radius   Where the socket sits, normally the lid's port circle so the riser is straight
 * @param feed_bore     Socket bore, sized to the riser it accepts
 * @param feed_height   How far the socket stands above the ring's top face
 * @param feed_wall     Wall around the socket bore
 */
module sparge_ring(
  radius,
  section,
  wall,
  hole_diameter,
  hole_count,
  feed_angle = 0,
  feed_radius = undef,
  feed_bore = 4,
  feed_height = 8,
  feed_wall = 1.2
) {
  _feed_r = is_undef(feed_radius) ? radius : feed_radius;
  _bore = [section[0] - 2 * wall, section[1] - 2 * wall];

  assert(
    _bore[0] > 0 && _bore[1] > 0,
    str("sparge_ring: a ", wall, " mm wall leaves no bore in a ", section, " mm section")
  );

  // The holes open into the bore through the inner wall, so their diameter is limited by how tall
  // the bore is, not by how deep it is - which is the whole point of the tall section.
  assert(
    hole_diameter < _bore[1],
    str("sparge_ring: a ", hole_diameter, " mm hole does not open into a ", _bore[1], " mm tall bore")
  );

  module _torus(sect) {
    rotate_extrude(convexity = 4)
      translate([radius, 0])
        square(sect, center = true);
  }

  difference() {
    union() {
      _torus(section);

      rotate([0, 0, feed_angle]) {
        // arm inboard to the socket, in the ring's own section so it adds no radial width
        translate([_feed_r, -section[0] / 2, -section[1] / 2])
          cube([radius - _feed_r, section[0], section[1]]);

        // socket, standing on the arm for the riser to drop into
        translate([_feed_r, 0, -section[1] / 2])
          cylinder(h = section[1] + feed_height, d = feed_bore + 2 * feed_wall);
      }
    }

    _torus(_bore);

    rotate([0, 0, feed_angle]) {
      // the arm's own bore, meeting the ring's
      translate([_feed_r, -_bore[0] / 2, -_bore[1] / 2])
        cube([radius - _feed_r + z_fight, _bore[0], _bore[1]]);

      // and the socket's, down into the arm
      translate([_feed_r, 0, -_bore[1] / 2])
        cylinder(h = _bore[1] / 2 + section[1] / 2 + feed_height + z_fight, d = feed_bore);
    }

    // gas holes, pointing radially inward - Birch & Ahmed discharged theirs towards the turbine
    for (i = [0:hole_count - 1])
      rotate([0, 0, i * 360 / hole_count + feed_angle + 180 / hole_count])
        translate([radius, 0, 0])
          rotate([0, -90, 0])
            cylinder(h = section[0] / 2 + z_fight, d = hole_diameter);
  }
}

// example usage - this file is an entry and must emit geometry; head.scad passes its own numbers
sparge_ring(
  radius = 68.04, section = [4, 10], wall = 1.2, hole_diameter = 3, hole_count = 8,
  feed_angle = 240, feed_radius = 56.9
);
