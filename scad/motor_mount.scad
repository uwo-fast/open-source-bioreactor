use <lib/trapezium.scad>;

include <_config.scad>;

/**
 * @brief Create a motor mount for a DC motor with a gearbox
 * @param height The height of the motor mount
 * @param width The width of the motor mount
 * @param wall_thickness The thickness of the walls of the motor mount
 * @param floor_thickness The thickness of the floor of the motor mount
 * @param inner_dia The inner diameter of the cavity where the motor shafts couple
 * @param pillar_width The width of the pillars that support the motor
 * @ param base_screws_diameter The diameter of the screws that attach the motor mount to the base
 * @param base_screws_cdist The distance between the screws that attach the motor mount to the base
 * @param face_screws_diameter The diameter of the screws that attach the faceplate to the motor mount
 * @param face_screws_cdist The distance between the screws that attach the faceplate to the motor mount
 */
module motor_mount(
  height,
  width,
  wall_thickness,
  floor_thickness,
  inner_dia,
  pillar_width,
  base_screws_diameter,
  base_screws_cdist,
  face_screws_diameter,
  face_screws_cdist
) {

  window_width = octagon_side_length(width / 2) - pillar_width;
  window_depth = wall_thickness * 2;
  window_height = height - floor_thickness * 2;

  difference() {

    // main body
    linear_extrude(height=height) difference() {
        rotate([0, 0, 360 / 8 / 2]) circle(d=width, $fn=8);
      }

    // central cut out where shafts couple
    translate([0, 0, -zFite / 2]) cylinder(h=height + zFite, d=inner_dia);

    // windows
    for (i = [0:7])
      rotate([0, 0, i * 45]) translate([0, width / 2 - window_depth, floor_thickness]) rotate([-90, 0, 0])
            linear_extrude(window_depth) elongated_octagonal_prism(width=window_width, height=window_height);

    // base screw holes
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45]) translate([base_screws_cdist / 2, 0, -zFite / 2]) {
          cylinder(h=height + zFite, d=base_screws_diameter);
          translate([0, 0, wall_thickness])
            cylinder(h=height - wall_thickness + zFite, d=base_screws_diameter * 1.5);
        }

    // faceplate screw holes
    for (i = [0:3])
      rotate([0, 0, i * 90]) translate([face_screws_cdist / 2, 0, -zFite / 2]) {
          cylinder(h=height + zFite, d=face_screws_diameter);
          translate([0, 0, 0]) cylinder(h=wall_thickness + zFite, d=face_screws_diameter * 1.5);
        }
  }
}

// ---------------------------------
// Utility Functions
// ---------------------------------

/**
 * @brief Calculate the side length of an octagon given the radius of the circumscribed circle
 * @param radius The radius of the circumscribed circle
 * @return The side length of the octagon
 */
function octagon_side_length(radius) = radius * sqrt(2 - sqrt(2));

/**
 * @brief Create a elongated octagonal prism
 * @param width The width of the prism
 * @param height The height of the prism
 */
module elongated_octagonal_prism(width, height) {
  trap_pts = trapezium_pts(bottom_width=width);
  adjusted_height = height - trap_pts[3][1] * 2;
  translate([0, -trap_pts[3][1], 0]) {
    polygon(trap_pts);
    translate([0, -adjusted_height / 2, 0]) square([width, adjusted_height], center=true);
    translate([0, -adjusted_height, 0]) mirror([0, 1, 0]) polygon(trap_pts);
  }
}
