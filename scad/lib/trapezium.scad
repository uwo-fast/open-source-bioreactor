/**
 * @file trapezium.scad
 * @brief Create a trapezium shape with the given parameters
 * @copyright Cameron K. Brooks 2025
 * @description Create a trapezium shape given the bottom width and optionally the top width, height, angle, and offset.
 * The default call using only the bottom width will create a trapezium with a top width equal to half the bottom width
 * and a height calculated from the default angle of 45 degrees.
 */

/**
 * @brief Create a trapezium shape with the given parameters
 * @param bottom_width The width of the bottom of the trapezium
 * @param top_width The width of the top of the trapezium
 * @param height The height of the trapezium
 * @param angle The angle of the trapezium sides
 * @param offset The offset of the top of the trapezium
 * @return The trapezium polygon
 */
module trapezium(bottom_width, top_width = undef, height = undef, angle = 45, offset = 0) {
  // Calculate missing parameter based on the provided inputs
  // First calculate the top width if it is not provided
  top_width =
    is_undef(top_width) ? // check top_width undef
      (
        is_undef(height) // check if height is undef
        ? bottom_width / 2 // if height is also undef, set top width to half of bottom width
        : bottom_width - 2 * height * tan(angle)
      ) // if height is provided, calculate top width
    : top_width; // if top width is provided, use it

  // Next calculate height if it is not provided
  height =
    is_undef(height) ? // check if height is undef
      (bottom_width - top_width) / (2 * tan(angle)) // calculate height based on the angle and width difference
    : height; // if height is provided, use it

  polygon(
    points=[
      [-bottom_width / 2, 0], // Bottom left
      [bottom_width / 2, 0], // Bottom right
      [offset + top_width / 2, height], // Top right
      [offset - top_width / 2, height], // Top left
    ]
  );
}

/**
 * @brief Create a list of points that form a trapezium shape with the given parameters
 * @param bottom_width The width of the bottom of the trapezium
 * @param top_width The width of the top of the trapezium
 * @param height The height of the trapezium
 * @param angle The angle of the trapezium sides
 * @param offset The offset of the top of the trapezium
 * @return The points of the trapezium shape
 */
function trapezium_pts(bottom_width, top_width = undef, height = undef, angle = 45, offset = 0) =
  let (
    top_width = is_undef(top_width) ? // check top_width undef
      (
        is_undef(height) // check if height is undef
        ? bottom_width / 2 // if height is also undef, set top width to half of bottom width
        : bottom_width - 2 * height * tan(angle)
      ) // if height is provided, calculate top width
    : top_width, // if top width is provided, use it

    // Next calculate height if it is not provided
    height = is_undef(height) ? // check if height is undef
      (bottom_width - top_width) / (2 * tan(angle)) // calculate height based on the angle and width difference
    : height // if height is provided, use it
  ) [
      [-bottom_width / 2, 0], // Bottom left
      [bottom_width / 2, 0], // Bottom right
      [offset + top_width / 2, height], // Top right
      [offset - top_width / 2, height], // Top left
  ];

// -----------------------------------------
// Example usage of the trapezium module
// -----------------------------------------

// Shared offset parameter, shifts the top of the trapezium left (-) or right (+)
example_offset = 0;

// Default call using bottom_width, top_width, height
translate([0, 0, 0]) trapezium(bottom_width=40, top_width=25, height=12, offset=example_offset);

// Call using bottom_width, top_width, angle
translate([0, 20, 0]) trapezium(bottom_width=40, top_width=25, angle=30, offset=example_offset);

// Call using bottom_width, top_width; here height is calculated from default angle (45) and widths
translate([0, 40, 0]) trapezium(bottom_width=40, top_width=25, offset=example_offset);

// Call using bottom_width, angle; here top_width = bottom_width / 2, height is calculated from angle and widths
translate([0, 60, 0]) trapezium(bottom_width=40, angle=60, offset=example_offset);

// Call using bottom_width and height; here top_width is calculated from default angle (45) and widths
translate([0, 80, 0]) trapezium(bottom_width=40, height=12, offset=example_offset);

// Call using bottom_width only; top_width = bottom_width / 2, height is calculated from default angle (45) and widths
translate([0, 100, 0]) trapezium(bottom_width=40, offset=example_offset);

// They can also be called analogously as a function
// Default call using bottom_width, top_width, height
translate([50, 0, 0]) polygon(trapezium_pts(bottom_width=40, top_width=25, height=12, offset=example_offset));

// Call using bottom_width, top_width, angle
translate([50, 20, 0]) polygon(trapezium_pts(bottom_width=40, top_width=25, angle=30, offset=example_offset));

// Call using bottom_width, top_width; here height is calculated from default angle (45) and widths
translate([50, 40, 0]) polygon(trapezium_pts(bottom_width=40, top_width=25, offset=example_offset));

// Call using bottom_width, angle; here top_width = bottom_width / 2, height is calculated from angle and widths
translate([50, 60, 0]) polygon(trapezium_pts(bottom_width=40, angle=60, offset=example_offset));

// Call using bottom_width and height; here top_width is calculated from default angle (45) and widths
translate([50, 80, 0]) polygon(trapezium_pts(bottom_width=40, height=12, offset=example_offset));

// Call using bottom_width only; top_width = bottom_width / 2, height is calculated from default angle (45) and widths
translate([50, 100, 0]) polygon(trapezium_pts(bottom_width=40, offset=example_offset));
