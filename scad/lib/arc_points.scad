

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