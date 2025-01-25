include <_config.scad>;

/**
 * @brief Generates a series of points defining an arc.
 *
 * Returns a list of (x,y) coordinates forming an arc specified by a start angle, end angle, and number of points.
 * The arc is determined by the radius derived from the given diameter.
 *
 * @param diameter The diameter of the arc's circle.
 * @param start_angle The starting angle of the arc (in degrees).
 * @param end_angle The ending angle of the arc (in degrees).
 * @param num_points The number of points along the arc, defining its resolution.
 * @param z_val The z-coordinate value for the arc points.
 *
 * @return A list of [x, y] points representing the arc.
 */
function arc_points(diameter, start_angle = 0, end_angle = 360, num_points = 32) =
    let(radius = diameter /
                 2)[for (i = [0:num_points])[radius * cos(start_angle + (end_angle - start_angle) * i / num_points),
                                             radius *sin(start_angle + (end_angle - start_angle) * i / num_points)]];

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
function pie_slice(diameter, start_angle = 0, end_angle = 360,
                   num_points = 32) = concat([[ 0, 0 ]], arc_points(diameter, start_angle, end_angle, num_points));

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
module tab(width, thickness, height, hole, collar_thickness = 0)
{
    difference()
    {
        cube([ width, thickness, height ]);
        translate([ width / 2 + collar_thickness / 2, thickness / 2, height / 4 ]) rotate([ 90, 0, 0 ])
            cylinder(d = hole, h = thickness + zFite, center = true);
        translate([ width / 2 + collar_thickness / 2, thickness / 2, height / 4 * 3 ]) rotate([ 90, 0, 0 ])
            cylinder(d = hole, h = thickness + zFite, center = true);
    }
}

// Main body
diameter = 30;
diameter_prime = 32;
height = 15;

// For tabs
collar_thickness = 3;
mount_thickness = 3;
mount_width = 6;
hole_diameter = 3.2;

// For rod mount
rod_mount_width = 12;
rod_diameter = 6;

dia_diff = diameter_prime - diameter;
cord = circumference_from_diameter(diameter);
echo("Circumference: ", cord);

step = (sin($t * 360) + 1) * (dia_diff / 2); // Harmonic motion
diameter_prime_step = diameter + step;
echo("Diameter prime: ", diameter_prime_step);

angle_in_degrees = chord_to_angle(cord, diameter_prime_step);
echo("Angle in degrees: ", angle_in_degrees);

inner = pie_slice(diameter_prime_step);
outer = pie_slice(diameter_prime_step + collar_thickness * 2, 0, angle_in_degrees);
half_angle_difference = (360 - angle_in_degrees) / 2;

rotate([ 0, 0, half_angle_difference ]) difference()
{
    union()
    {
        linear_extrude(height) polygon(outer);

        rotate([ 0, 0, 0 ]) translate([ diameter_prime_step / 2, 0, 0 ])
            tab(mount_width + collar_thickness, mount_thickness, height, hole_diameter, collar_thickness);

        rotate([ 0, 0, -half_angle_difference * 2 ]) mirror([ 0, 1, 0 ]) translate([ diameter_prime_step / 2, 0, 0 ])
            tab(mount_width + collar_thickness, mount_thickness, height, hole_diameter, collar_thickness);

        rotate([ 0, 0, -half_angle_difference  ])translate([ -(diameter_prime_step - collar_thickness) / 2, 0, 0 ]) scale([1,0.75,1])
            cylinder(r = rod_mount_width, h = height);
    }
    translate([ 0, 0, -zFite / 2 ]) linear_extrude(height + zFite) polygon(inner);

    rotate([ 0, 0, -half_angle_difference  ])translate([ -diameter_prime_step/ 2 - rod_mount_width /2, 0, -zFite / 2 ])
            cylinder(d = rod_diameter, h = height+ zFite);
}