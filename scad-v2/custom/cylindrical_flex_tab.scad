zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// hardware params

probe_body_lenth = 35.6;
probe_body_diameter = 16.3;

tail_major_diameter = 8.7;
tail_minor_diameter = 4.3;
tail_length = 24.5;

// design parameters

wall_thickness = 1.0;

height_ratio = 0.60; // the flex_tab  height is 60% of the body length, centered on the body
width_ratio = 0.70; // the flex_tab  width is 70% of the body outer diameter, centered on the body
flex_tab_gap = 0.8; // 0.8mm gap separating flex_tab  tab from shell body

flex_tab_offset = 0.5;

connector_part_diameter = 10;

// optional dev params

render_optional_supports = true;

// animate from -wall_thickness (fully open) to zero (fully pinched)
// use $t to control the animation frame (0 to 1)
// use sine wave to create a smooth open-close-open animation loop
// if animate_flex_tab  is false, flex_tab_offset_anim will be zero and 
// the flex_tab  will be fully closed for rendering to 3D print
animate_flex_tab = false;
flex_tab_offset_anim = animate_flex_tab ? -(sin($t * 360) + 1) / 2 * wall_thickness + flex_tab_offset : flex_tab_offset;

// ----- build -----

cross_section(show_cross=false)
  cylindrical_flex_tab(
    body_length=probe_body_lenth,
    body_diameter=probe_body_diameter,
    tail_diameter_start=tail_major_diameter,
    tail_diameter_end=tail_minor_diameter,
    tail_len=tail_length,
    shell_wall=wall_thickness,
    height_flex_tab_ratio=height_ratio,
    width_flex_tab_ratio=width_ratio,
    flex_tab_clearance=flex_tab_gap,
    connector_diameter=connector_part_diameter,
    flex_tab_keep_ratio=flex_tab_keep_ratio,
    flex_tab_offset=flex_tab_offset_anim
  );

// ----- dev -----

module cross_section(show_cross = false) {
  difference() {
    children();
    if (show_cross) {
      translate([-50, 0, 0])
        cube([100, 100, 100], center=true);
    }
  }
}

// ----- helper funcs -----

module flex_tab_profile(height, d1, d2) {
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

module cylindrical_flex_tab(
  body_length,
  body_diameter,
  tail_diameter_start,
  tail_diameter_end,
  tail_len,
  shell_wall,
  height_flex_tab_ratio,
  width_flex_tab_ratio,
  flex_tab_clearance,
  connector_diameter,
  allowance,
  flex_tab_keep_ratio = 0.75,
  flex_tab_offset = 0,
  connector_facets = 6,
  support_z_contact_distance = 0.25
) {

  // internal derived params for flex_tab  design
  flex_tab_z_start = -body_length * (1 + height_flex_tab_ratio) / 2;
  flex_tab_height = body_length * height_flex_tab_ratio;
  flex_tab_d1 = (body_diameter + shell_wall * 2) * (width_flex_tab_ratio * width_flex_tab_ratio);
  flex_tab_d2 = (body_diameter + shell_wall * 2) * (width_flex_tab_ratio);

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
        body_diameter=body_diameter + allowance,
        tail_len=tail_len,
        tail_diameter_start=tail_diameter_start,
        tail_diameter_end=tail_diameter_end,
        shell_wall=shell_wall
      );

      // Cut out flex_tab window
      translate([0, 0, flex_tab_z_start])
        flex_tab_profile(height=flex_tab_height, d1=flex_tab_d1, d2=flex_tab_d2);

      // Hex cut thru all for the SMA connector
      cylinder(h=body_length * 3, d=connector_diameter, center=true, $fn=connector_facets);
    }

    translate([0, 0, flex_tab_z_start]) {
      intersection() {

        // Bell shape for flex_tab area
        difference() {
          cylinder(h=flex_tab_height, d2=body_diameter - flex_tab_offset * 2, d1=body_diameter + shell_wall * 2);
          translate([0, 0, -zFite])
            cylinder(h=body_length, d2=body_diameter - shell_wall * 2 - flex_tab_offset * 2 + allowance, d1=body_diameter + allowance);
        }

        difference() {
          // Intersection (same as cut out flex_tab window) to create flex_tab tabs
          flex_tab_profile(
            height=flex_tab_height - flex_tab_clearance,
            d1=flex_tab_d1 - flex_tab_clearance,
            d2=flex_tab_d2 - flex_tab_clearance
          );
          translate([0, 0, (flex_tab_height - flex_tab_clearance) * flex_tab_keep_ratio + body_length / 2])
            cube([body_diameter * 10, body_diameter * 2, body_length], center=true);
        }
      }
    }
  }
}
