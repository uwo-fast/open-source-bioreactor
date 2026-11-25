/**
 * @file bearing_blank.scad
 * @brief Printed plug for the lid bearing pocket, for a build without a shaft
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A boss the size of the bearing fits the pocket and seals on the pocket o-ring. A pin fills the
 * shaft bore down to the underside of the lid. A flange bolts to the same inserts the motor mount
 * uses. The lid print is the same with or without a shaft.
 *
 * DATUM: z = 0 is the outer face of the lid, +z outward. The boss and pin extend below it and the
 * flange sits above it.
 */

$fn = $preview ? 64 : 128;
z_fight = $preview ? 0.05 : 0;

/* [Preview] */

// boss diameter, equal to the bearing the pocket is cut for
boss_diameter = 22;
// boss height, equal to the bearing width (the pocket depth)
boss_height = 7;
// pin diameter, equal to the shaft the bore is cut for
pin_diameter = 8;
// pin length below the boss, down to the underside of the lid
pin_length = 24;
// diameter of the flange
flange_diameter = 56;
// thickness of the flange (the screw grip length)
flange_thickness = 5;
// radius the four screw holes sit on
screw_radius = 23;
// clearance diameter of those holes
screw_hole_diameter = 4.5;

module dummy() {
  // stop the customizer detection from here onwards
}

/**
 * @brief The blank: flange on z = 0 extending up, boss and pin extending down
 * @param boss_diameter Diameter of the bearing the pocket is cut for. The pocket o-ring seals on it
 * @param boss_height Pocket depth, less enough that the flange seats first
 * @param pin_diameter Diameter of the shaft the bore is cut for
 * @param pin_length From the underside of the boss to the underside of the lid
 * @param flange_diameter Outside diameter of the flange
 * @param flange_thickness Flange thickness (the screw grip length)
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
