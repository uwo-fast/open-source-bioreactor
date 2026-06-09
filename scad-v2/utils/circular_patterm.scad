/**
 * @brief Creates a circular pattern of children around the z-axis
 * @param a Angle between each child
 * @param n Number of children
 * @param r Radius of the circle
 * @param offset Offset of the first child
 */
module circular_pattern(a, n, r, offset, center = false) {
  c = center ? -a / n : 0;
  for (i = [0:n - 1]) {
    rotate([0, 0, i * a / n + offset + c]) {
      translate([0, r, 0]) children();
    }
  }
}
