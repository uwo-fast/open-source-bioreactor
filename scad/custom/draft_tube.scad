/**
 * @file draft_tube.scad
 * @brief The draft tube of an internal-loop airlift, standing on feet
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A plain tube: the gas rises inside it and the liquid comes down outside. It stands on feet so the
 * liquid can turn under it, and what sits just inside its foot centres it.
 *
 * DATUM: z = 0 is the tube's bottom edge, +z up. The feet reach below it.
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
// how far each foot reaches below the bottom edge
foot_lengths = [12, 12, 12];
// where the feet stand, in degrees around the tube
foot_angles = [0, 120, 240];
// width of each foot, around the tube
foot_width = 8;

module dummy() {
  // stop the customizer detection from here onwards
}

/**
 * @brief The tube, bottom edge on z = 0 and standing up, feet hanging below
 * @param inner_radius Clears everything inside it
 * @param wall Wall thickness
 * @param height Bottom edge to top edge
 * @param foot_lengths How far each foot reaches below the bottom edge, one per foot
 * @param foot_angles Where each foot stands, in degrees
 * @param foot_width Each foot's width around the tube
 */
module draft_tube(inner_radius, wall, height, foot_lengths, foot_angles, foot_width) {
  assert(len(foot_lengths) == len(foot_angles), "draft_tube: one length per foot");
  assert(len(foot_angles) >= 3, "draft_tube: it stands on three feet or more");
  assert(min(foot_lengths) > 0, "draft_tube: a foot has to reach below the bottom edge");

  difference() {
    cylinder(r=inner_radius + wall, h=height);
    translate([0, 0, -z_fight]) cylinder(r=inner_radius, h=height + 2 * z_fight);
  }

  // Each foot is the wall carried on down over its width, so it prints as part of the wall. It
  // overlaps the wall rather than meeting it at the bottom edge.
  for (i = [0:len(foot_angles) - 1])
    rotate([0, 0, foot_angles[i]])
      intersection() {
        translate([0, 0, -foot_lengths[i]])
          difference() {
            cylinder(r=inner_radius + wall, h=foot_lengths[i] + 1);
            translate([0, 0, -1]) cylinder(r=inner_radius, h=foot_lengths[i] + 3);
          }
        translate([0, -foot_width / 2, -foot_lengths[i] - 1])
          cube([inner_radius + wall + 1, foot_width, foot_lengths[i] + 3]);
      }
}

draft_tube(inner_radius, wall, height, foot_lengths, foot_angles, foot_width);
