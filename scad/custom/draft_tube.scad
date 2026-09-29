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
// radius of the fillet each side of a foot, where it meets the bottom edge
foot_fillet = 6;

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
 * @param foot_fillet Radius of the fillet each side of a foot, no longer than the foot
 */
module draft_tube(inner_radius, wall, height, foot_lengths, foot_angles, foot_width, foot_fillet = 0) {
  assert(len(foot_lengths) == len(foot_angles), "draft_tube: one length per foot");
  assert(len(foot_angles) >= 3, "draft_tube: it stands on three feet or more");
  assert(min(foot_lengths) > 0, "draft_tube: a foot has to reach below the bottom edge");

  difference() {
    cylinder(r=inner_radius + wall, h=height);
    translate([0, 0, -z_fight]) cylinder(r=inner_radius, h=height + 2 * z_fight);
  }

  // Each foot is the wall carried on down over its width, so it prints as part of the wall. It
  // overlaps the wall rather than meeting it at the bottom edge. Its outline is drawn flat, the
  // foot and a fillet each side of it where it meets the edge, and pressed through the wall.
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

// A foot's outline across the wall, width along x and down along -y, the bottom edge at y = 0:
// the foot, and a quarter circle cut from a square each side of it for the fillet.
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
