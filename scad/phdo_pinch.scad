include <_config.scad>;

// TODO
// right now the pinch is hardcoded to be a single wall inside the main body, 
// but it would be nice to have the option to tune this to allow variability
// as well as enabling animation by setting from 0 to the full pinch offset.

// hardware params

probe_body_lenth = 35.6;
probe_body_diameter = 16.3;

tail_major_diameter = 8.7;
tail_minor_diameter = 4.3;
tail_length = 24.5;

// design parameters

wall_thickness = 0.6 * 2; // 2 walls of 0.6mm each

height_ratio = 0.80; // the pinch height is 80% of the body length, centered on the body
width_ratio = 0.70; // the pinch width is 70% of the body outer diameter, centered on the body
pinch_gap = 0.8; // 0.8mm gap separating pinch tab from shell body

connector_part_diameter = 10;

// optional dev params

render_optional_supports = true;

// animate from -wall_thickness (fully open) to zero (fully pinched)
// use $t to control the animation frame (0 to 1)
// use sine wave to create a smooth open-close-open animation loop
// if animate_pinch is false, pinch_offset_anim will be zero and 
// the pinch will be fully closed for rendering to 3D print
animate_pinch = false;
pinch_offset_anim = animate_pinch ? -(sin($t * 360) + 1) / 2 * wall_thickness : 0;

// ----- build -----

cross_section()
  phdo_pinch(
    body_length=probe_body_lenth,
    body_diameter=probe_body_diameter,
    tail_diameter_start=tail_major_diameter,
    tail_diameter_end=tail_minor_diameter,
    tail_len=tail_length,
    shell_wall=wall_thickness,
    height_pinch_ratio=height_ratio,
    width_pinch_ratio=width_ratio,
    pinch_clearance=pinch_gap,
    connector_diameter=connector_part_diameter,
    pinch_offset=pinch_offset_anim,
    render_supports=render_optional_supports
  );

// ----- dev -----

module cross_section(show_cross = false) {
  difference() {
    children();
    if (show_cross) {
      translate([0, -50, 0])
        cube([100, 100, 100], center=true);
    }
  }
}

// ----- helper funcs -----

module pinch_profile(height, d1, d2) {
  scale([10, 1, 1])
    cylinder(h=height, d1=d1, d2=d2);
}

module probe_outer_body(
  body_length,
  body_diameter,
  tail_len,
  tail_diameter_end,
  connector_diameter,
  shell_wall
) {
  // Main body and tail
  union() {
    translate([0, 0, -body_length])
      cylinder(h=body_length, d=body_diameter + shell_wall * 2);
    cylinder(h=tail_len, d1=body_diameter + shell_wall * 2, d2=tail_diameter_end + shell_wall * 2);
    translate([0, 0, tail_len * 0.5])
      cylinder(h=tail_len, d=connector_diameter + shell_wall * 2);
  }
}

module probe_negative_space(
  body_length,
  body_diameter,
  tail_len,
  tail_diameter_start,
  tail_diameter_end,
  shell_wall
) {
  translate([0, 0, -zFite / 2]) // Avoid z-fighting with main body
  {
    // Main body
    translate([0, 0, -body_length])
      cylinder(h=body_length, d=body_diameter);
    // Tail body
    translate([0, 0, -zFite / 2]) // Avoid z-fighting with main body
      cylinder(h=tail_len + zFite, d1=tail_diameter_start, d2=tail_diameter_end);
    // Cord body
    translate([0, 0, tail_len - zFite / 2])
      cylinder(h=tail_len, d=tail_diameter_end);
  }
}

module phdo_pinch(
  body_length,
  body_diameter,
  tail_diameter_start,
  tail_diameter_end,
  tail_len,
  shell_wall,
  height_pinch_ratio,
  width_pinch_ratio,
  pinch_clearance,
  connector_diameter,
  pinch_offset = 0,
  connector_facets = 6,
  render_supports = false,
  support_z_contact_distance = 0.2
) {

  // internal derived params for pinch design
  pinch_z_start = -body_length * (1 + height_pinch_ratio) / 2;
  pinch_height = body_length * height_pinch_ratio;
  pinch_d1 = (body_diameter + shell_wall * 2) * (width_pinch_ratio * width_pinch_ratio);
  pinch_d2 = (body_diameter + shell_wall * 2) * (width_pinch_ratio);

  union() {
    difference() {

      probe_outer_body(
        body_length=body_length,
        body_diameter=body_diameter,
        tail_len=tail_len,
        tail_diameter_end=tail_diameter_end,
        connector_diameter=connector_diameter,
        shell_wall=shell_wall
      );

      // Probe negative space
      probe_negative_space(
        body_length=body_length,
        body_diameter=body_diameter,
        tail_len=tail_len,
        tail_diameter_start=tail_diameter_start,
        tail_diameter_end=tail_diameter_end,
        shell_wall=shell_wall
      );

      // Cut out pinch window
      translate([0, 0, pinch_z_start])
        pinch_profile(height=pinch_height, d1=pinch_d1, d2=pinch_d2);

      // Hex cut thru all for the SMA connector
      cylinder(h=body_length * 3, d=connector_diameter, center=true, $fn=connector_facets);
    }

    translate([0, 0, pinch_z_start])
      intersection() {
        // Bell shape for pinch area
        difference() {
          cylinder(h=pinch_height, d2=body_diameter - pinch_offset * 2, d1=body_diameter + shell_wall * 2);
          translate([0, 0, -shell_wall])
            cylinder(h=body_length, d2=body_diameter - shell_wall, d1=body_diameter);
        }

        // Intersection (same as cut out pinch window) to create pinch tabs
        pinch_profile(
          height=pinch_height - pinch_clearance,
          d1=pinch_d1 - pinch_clearance,
          d2=pinch_d2 - pinch_clearance
        );
      }
  }

  if (render_supports) {
    color("pink", 0.5) {
      // Optional built-in supports
      translate([0, 0, -body_length])
        cylinder(h=body_length - support_z_contact_distance, d=body_diameter - shell_wall * 2);
    }
  }
}
