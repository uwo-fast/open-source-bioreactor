/**
 * @file draft_tube.scad
 * @brief Draft tube for an internal-loop airlift, standing on feet
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A plain tube. Gas rises inside it and liquid flows down outside it. It stands on feet so the
 * liquid can flow under the bottom edge. The part just inside the feet centres it.
 *
 * DATUM: z = 0 is the bottom edge of the tube, +z up. The feet extend below it.
 */

$fn = $preview ? 64 : 128;
z_fight = $preview ? 0.05 : 0;

/* [Preview] */

// inside radius of the tube
inner_radius = 39;
// wall thickness
wall = 2;
// length of the tube, bottom edge to top edge
height = 140;
// length of each foot below the bottom edge
foot_lengths = [12, 12, 12];
// angular positions of the feet, in degrees around the tube
foot_angles = [0, 120, 240];
// width of each foot, measured around the tube
foot_width = 8;
// radius of the fillet on each side of a foot where it meets the bottom edge
foot_fillet = 6;

module dummy() {
  // stop the customizer detection from here onwards
}

/**
 * @brief The tube, bottom edge on z = 0 extending up, feet extending below
 * @param inner_radius Inside radius; must clear everything inside the tube
 * @param wall Wall thickness
 * @param height Bottom edge to top edge
 * @param foot_lengths Length of each foot below the bottom edge, one per foot
 * @param foot_angles Angular position of each foot, in degrees
 * @param foot_width Width of each foot around the tube
 * @param foot_fillet Radius of the fillet on each side of a foot, no larger than the foot length
 */
module draft_tube(inner_radius, wall, height, foot_lengths, foot_angles, foot_width, foot_fillet = 0) {
  assert(len(foot_lengths) == len(foot_angles), "draft_tube: one length per foot");
  assert(len(foot_angles) >= 3, "draft_tube: it stands on three feet or more");
  assert(min(foot_lengths) > 0, "draft_tube: a foot has to reach below the bottom edge");

  difference() {
    cylinder(r=inner_radius + wall, h=height);
    translate([0, 0, -z_fight]) cylinder(r=inner_radius, h=height + 2 * z_fight);
  }

  // Each foot is a downward extension of the wall over its width, so it prints as part of the
  // wall. It overlaps the wall instead of meeting it at the bottom edge. The outline (foot plus a
  // fillet on each side at the edge) is drawn flat and extruded through the wall.
  for (i = [0:len(foot_angles) - 1])
    let (_l = foot_lengths[i], _r = min(foot_fillet, _l))
      rotate([0, 0, foot_angles[i]])
        intersection() {
          translate([0, 0, -_l])
            difference() {
              cylinder(r=inner_radius + wall, h=_l + 1);
              translate([0, 0, -1]) cylinder(r=inner_radius, h=_l + 3);
            }
          rotate([90, 0, 90])
            linear_extrude(inner_radius + wall + 1)
              _foot_outline(foot_width, _l, _r);
        }
}

// Outline of a foot across the wall: width along x, downward along -y, bottom edge at y = 0. It
// is the foot plus, on each side, a square with a quarter circle cut out to form the fillet.
module _foot_outline(width, length, fillet) {
  translate([-width / 2, -length - 1]) square([width, length + 2]);
  if (fillet > 0)
    for (side = [-1, 1])
      difference() {
        translate([side > 0 ? width / 2 - 0.01 : -width / 2 - fillet + 0.01, -fillet]) square([fillet, fillet + 1]);
        translate([side * (width / 2 + fillet), -fillet]) circle(r=fillet);
      }
}

draft_tube(inner_radius, wall, height, foot_lengths, foot_angles, foot_width, foot_fillet);
