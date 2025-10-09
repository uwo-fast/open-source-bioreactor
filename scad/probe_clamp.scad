include <_config.scad>;
use <lib/arc_points.scad>;

/**
 * @brief Generates a series of points defining a pie slice.
 *
 * Returns a list of (x,y) coordinates forming a pie slice specified by a diameter, start angle, end angle, and number
 * of points.
 *
 * @param diameter The diameter of the pie slice's circle.
 * @param start_angle The starting angle of the pie slice (in degrees).
 * @param end_angle The ending angle of the pie slice (in degrees).
 * @param num_points The number of points along the pie slice, defining its resolution.
 *
 * @return A list of [x, y] points representing the pie slice.
 */
function pie_slice(
  diameter,
  start_angle = 0,
  end_angle = 360,
  num_points = 32
) =
  concat([[0, 0]], arc_points(diameter, start_angle, end_angle, num_points));

/**
 * @brief Calculates the circumference of a circle from its diameter.
 *
 * @param diameter The diameter of the circle.
 *
 * @return The circumference of the circle.
 */
function circumference_from_diameter(diameter) = PI * diameter;

/**
 * @brief Calculates the resultant angle for a chord distance for a circle of a given diameter.
 *
 * @param cord_distance The chord distance.
 * @param diameter The diameter of the circle.
 *
 * @return The angle in degrees.
 */
function chord_to_angle(cord_distance, diameter) = cord_distance / (diameter / 2) * 180 / PI;

/**
 * @brief Generates a tab with a hole for a given collar thickness, dimension, and height.
 *
 * @param thickness The thickness of the tab.
 * @param width The width of the tab.
 * @param height The height of the tab.
 * @param hole The diameter of the hole in the tab.
 */
module tab(width, thickness, height, hole, collar_thickness = 0) {
  difference() {
    cube([width, thickness, height]);
    translate([width / 2 + collar_thickness / 2, thickness / 2, height / 4]) rotate([90, 0, 0])
        cylinder(d=hole, h=thickness + zFite, center=true);
    translate([width / 2 + collar_thickness / 2, thickness / 2, height / 4 * 3]) rotate([90, 0, 0])
        cylinder(d=hole, h=thickness + zFite, center=true);
  }
}

/**
 * @brief Generates a probe pinch collar.
 *
 * Generates a probe pinch collar with a given nominal diameter and expanded diameter where the nominal diameter is
 * expanded to the expanded diameter while maintaining the same cord distance at a decreased angular range. This means
 * the nominal diameter has a full angle of 360 degrees while the expanded diameter has a smaller angle. The mount is to
 * allow for screws in application to clamp the collar around a probe in order to pinch it to the nominal diameter.
 *
 * @param nominal_diameter The nominal diameter of the collar.
 * @param expanded_diameter The expanded diameter of the collar.
 * @param height The height of the collar.
 * @param collar_thickness The thickness of the collar.
 * @param mount_thickness The thickness of the mount.
 * @param mount_width The width of the mount.
 * @param hole_diameter The diameter of the hole in the collar.
 * @param rod_diameter The diameter of the rod.
 * @param rod_diameter_taper The diameter taper of the rod.
 * @param rod_mount_width The width of the rod mount.
 * @param animate Whether to animate the collar.
 * @param static_angle_factor The static angle factor for the collar.
 */
module probe_pinch_collar(
  nominal_diameter,
  expanded_diameter,
  height,
  collar_thickness,
  mount_thickness,
  mount_width,
  hole_diameter,
  rod_diameter,
  rod_diameter_taper,
  rod_mount_width,
  animate = false,
  static_angle_factor = 0.5,
  debug = false
) {

  cord = circumference_from_diameter(nominal_diameter);
  if (debug)
    echo("Circumference: ", cord);

  step = (sin($t * 360) + 1) * ( (expanded_diameter - nominal_diameter) / 2); // Harmonic motion
  diameter_prime_step = nominal_diameter + step;
  if (debug)
    echo("Diameter prime: ", diameter_prime_step);

  angular_range = chord_to_angle(cord, nominal_diameter) - chord_to_angle(cord, expanded_diameter);
  if (debug)
    echo("Angular range: ", angular_range);

  set_angle = 360 - angular_range * static_angle_factor;

  angle_in_degrees = animate ? chord_to_angle(cord, diameter_prime_step) : set_angle;
  if (debug)
    echo("Angle in degrees: ", angle_in_degrees);

  inner = pie_slice(diameter_prime_step);
  outer = pie_slice(diameter_prime_step + collar_thickness * 2, 0, angle_in_degrees);
  half_angle_difference = (360 - angle_in_degrees) / 2;

  rotate([0, 0, half_angle_difference]) difference() {
      union() {
        linear_extrude(height) polygon(outer);

        rotate([0, 0, 0]) translate([diameter_prime_step / 2, 0, 0])
            tab(mount_width + collar_thickness, mount_thickness, height, hole_diameter, collar_thickness);

        rotate([0, 0, -half_angle_difference * 2]) mirror([0, 1, 0])
            translate([diameter_prime_step / 2, 0, 0])
              tab(mount_width + collar_thickness, mount_thickness, height, hole_diameter, collar_thickness);

        rotate([0, 0, -half_angle_difference]) translate([-(diameter_prime_step - collar_thickness) / 2, 0, 0])
            scale([1, 0.5, 1]) cylinder(r=rod_mount_width, h=height);
      }
      translate([0, 0, -zFite / 2]) linear_extrude(height + zFite) polygon(inner);

      rotate([0, 0, -half_angle_difference])
        translate([-diameter_prime_step / 2 - rod_mount_width / 2, 0, -zFite / 2])
          cylinder(d2=rod_diameter, d1=rod_diameter_taper, h=height + zFite);
    }
}

// Define the nominal and expanded diameters for the collar.
test_nominal_diameter = 20;
test_expanded_diameter = 22;

// Define the height and thickness of the collar
test_height = 10;
test_collar_thickness = 2;

// Define the thickness and width of the mount as well as the diameter of the hole for screws
test_mount_thickness = 2;
test_mount_width = 10;
test_hole_diameter = 3;

// Define the diameter of the rod and the width of the rod mount
test_rod_diameter = 5;
test_rod_diameter_taper = 3;
test_rod_mount_width = 10;

probe_pinch_collar(
  nominal_diameter=test_nominal_diameter, expanded_diameter=test_expanded_diameter,
  height=test_height, collar_thickness=test_collar_thickness,
  mount_thickness=test_mount_thickness, mount_width=test_mount_width,
  hole_diameter=test_hole_diameter, rod_diameter=test_rod_diameter,
  rod_diameter_taper=test_rod_diameter_taper, rod_mount_width=test_rod_mount_width, animate=true,
  static_angle_factor=0.5
);
