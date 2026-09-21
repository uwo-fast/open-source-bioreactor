/**
 * @file bearing_blank.scad
 * @brief A printed plug for the lid's bearing pocket, for a build with no shaft
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A boss the bearing's size enters the pocket and is sealed by the pocket's own o-ring; a pin
 * fills the shaft bore to the lid's underside; a flange bolts down on the inserts the motor
 * mount would use. The lid is the same print either way.
 *
 * DATUM: z = 0 is the lid's outer face, +z outward. The boss and pin hang below, the flange
 * stands above.
 */

$fn = $preview ? 64 : 128;
z_fight = $preview ? 0.05 : 0;

/* [Preview] */

// diameter of the pocket's bearing, which the boss matches
boss_diameter = 22;
// width of that bearing, the pocket's depth
boss_height = 7;
// diameter of the shaft the bore was cut for, which the pin matches
pin_diameter = 8;
// how far the pin reaches below the boss, to the lid's underside
pin_length = 24;
// diameter of the flange
flange_diameter = 56;
// thickness of the flange, the screws' grip
flange_thickness = 5;
// radius the four screw holes sit on
screw_radius = 23;
// clearance diameter of those holes
screw_hole_diameter = 4.5;

module dummy() {
  // stop the customizer detection from here onwards
}

/**
 * @brief The blank, flange on z = 0 standing up, boss and pin hanging down
 * @param boss_diameter Matches the bearing the pocket is cut for; the pocket's o-ring seals on it
 * @param boss_height The pocket's depth, less what keeps the flange seated first
 * @param pin_diameter Matches the shaft the bore was cut for
 * @param pin_length From the boss's underside to the lid's underside
 * @param flange_diameter Outside of the flange
 * @param flange_thickness The screws' grip
 * @param screw_radius Radius of the four screw holes
 * @param screw_hole_diameter Clearance for the screw
 */
module bearing_blank(boss_diameter, boss_height, pin_diameter, pin_length, flange_diameter, flange_thickness, screw_radius, screw_hole_diameter) {
  assert(
    flange_diameter / 2 > screw_radius + screw_hole_diameter / 2,
    str("bearing_blank: screws on r ", screw_radius, " fall off a ", flange_diameter, " mm flange")
  );

  difference() {
    union() {
      cylinder(d=flange_diameter, h=flange_thickness);
      translate([0, 0, -boss_height])
        cylinder(d=boss_diameter, h=boss_height + z_fight);
      translate([0, 0, -boss_height - pin_length])
        cylinder(d=pin_diameter, h=pin_length + z_fight);
    }
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([screw_radius, 0, -z_fight])
          cylinder(d=screw_hole_diameter, h=flange_thickness + 2 * z_fight);
  }
}

bearing_blank(boss_diameter, boss_height, pin_diameter, pin_length, flange_diameter, flange_thickness, screw_radius, screw_hole_diameter);
