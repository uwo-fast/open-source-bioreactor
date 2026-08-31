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
  feed_wall = 1.2,
  support_angles = []
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

  // How far a hole has to travel inward from the section's centreline to break through the inner
  // wall everywhere, not just where a facet vertex happens to land.
  //
  // The facet count is DERIVED the way OpenSCAD derives it, not read off $fn. $fn is zero unless
  // something sets it, and a zero $fn means the count comes from $fa and $fs instead - so 180/$fn
  // was a division by zero for any consumer that had not set one. assembly.scad is exactly that
  // consumer. It stayed hidden because a 2021.01 module still resolved $fn from its own file, and
  // this file sets one; newer builds hand the module the caller's $fn, and there it evaluated to
  // cos(inf) - a nan reach, and the assert below firing on a jar that renders fine.
  _facets = $fn > 0
    ? max($fn, 3)
    : ceil(max(min(360 / $fa, (radius + section[0] / 2) * 2 * PI / $fs), 5));
  _inner_r = radius - section[0] / 2;
  _facet_skin = _inner_r * (1 - cos(180 / _facets));
  _hole_reach = section[0] / 2 + _facet_skin;

  // Inward only. The hole starts at the section's centreline, inside the bore, so it never reaches
  // the outer wall - and it must not, or the ring would vent away from the impeller as well as
  // towards it. This is what stops the breakthrough allowance above from being extended the wrong
  // way if the reach is ever rewritten.
  assert(
    _hole_reach < section[0],
    str(
      "sparge_ring: a hole reaching ", _hole_reach, " mm inward from the centreline of a ",
      section[0], " mm section breaks through the outer wall as well as the inner one"
    )
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

        // Socket, standing on the arm for the riser to drop into - and HEXAGONAL, where the
        // supports below are round, because that is the only thing that tells them apart.
        //
        // They are otherwise the same boss: same bore, same height, same arm. The difference is
        // inside, where this one opens into the ring and a support's pocket is blind, and you
        // cannot see inside a socket at the bottom of a jar. Get it wrong and the gas goes down a
        // capped tube and back out its own vent hole into the headspace, while the rotameter reads
        // flow and the culture gets nothing.
        //
        // Sized across FLATS, so the wall is the same feed_wall it always was and only the corners
        // are new material.
        translate([_feed_r, 0, -section[1] / 2])
          cylinder(h = section[1] + feed_height, d = (feed_bore + 2 * feed_wall) / cos(30), $fn = 6);
      }

      // Support arms. Identical to the feed's, and BLIND - nothing is bored through them, so the
      // tube that drops in carries no gas and is simply what stops the ring swinging. One riser
      // holds it on a 1.33 N/mm cantilever, which is 0.75 mm of sway per newton against 1.7 mm of
      // clearance to the baffles, so a couple of newtons of flow closes the gap.
      //
      // A tube landing here can still do its own job: capped at this end, it takes a drilled hole
      // or a filed slit at whatever height that job wants - a vent up in the headspace, a media line
      // wherever it should discharge. That is a hand operation and is not modelled.
      for (a = support_angles)
        rotate([0, 0, a]) {
          translate([_feed_r, -section[0] / 2, -section[1] / 2])
            cube([radius - _feed_r, section[0], section[1]]);

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

    // The support sockets take the same tube, but only as deep as it needs to seat: the pocket
    // stops at the top of the ring's own section, so the arm below stays solid and the tube cannot
    // vent into the bore.
    for (a = support_angles)
      rotate([0, 0, a])
        translate([_feed_r, 0, section[1] / 2 - feed_height / 2])
          cylinder(h = feed_height / 2 + feed_height + z_fight, d = feed_bore);

    // Gas holes, pointing radially inward - Birch & Ahmed discharged theirs towards the turbine.
    //
    // The length is not section[0]/2, which is what the nominal geometry says and what this used to
    // cut. rotate_extrude facets the ring, so between vertices the inner wall is a CHORD sitting at
    // r*cos(180/facets) rather than at r - closer to the axis, which leaves material where the nominal
    // radius says there is none. A hole stopping at the nominal inner face therefore stops short of
    // the real one and leaves a skin: 0.08 mm at r 66.25 and $fn 64, and 2.3 mm by $fn 12, which is
    // more than the whole wall. Blind holes on a part whose entire job is to let gas out.
    //
    // So it is cut to the deepest the faceted wall can reach. Overshooting is free - past the inner
    // wall the hole is cutting the void inside the ring - while stopping short is not.
    for (i = [0:hole_count - 1])
      rotate([0, 0, i * 360 / hole_count + feed_angle + 180 / hole_count])
        translate([radius, 0, 0])
          rotate([0, -90, 0])
            cylinder(h = _hole_reach + z_fight, d = hole_diameter);
  }
}

// example usage - this file is an entry and must emit geometry; head.scad passes its own numbers.
// These CANNOT be derived the way the conventions ask: the radius comes from
// head_sparge_ring_radius() and including head.scad here would close a cycle, since head.scad uses
// this file. So they are quoted, and quoted numbers drift - the radius read 68.04 against the
// model's 68.25 until 2026-08-30. Check both against head()'s echo before trusting a render here.
sparge_ring(
  radius = 68.25, section = [4, 10], wall = 1.2, hole_diameter = 3, hole_count = 8,
  feed_angle = 240, feed_radius = 56.9
);
