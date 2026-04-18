zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// ----  hardware params   ------

part_body_length = 35.6;
part_body_diameter = 16.3;

part_tail_major_diameter = 8.7;
part_tail_minor_diameter = 4.3;
part_tail_length = 24.5;

part_end_diameter = 10;
part_end_fn = 6; // number of facets for the end cut, e.g. 6 for hexagonal cut for SMA connector

// ----  design parameters   ------

shell_thickness = 1.0;
flex_tab_offset = 0.5; // how much additional offset to apply for tigher pinch; by default it is deflected inwards by the shell thickness
allowance = 0.2; // general allowance to compensate for printer/material tolerance

// ----- build -----

cylindrical_flex_tab(
  body_length=part_body_length,
  body_diameter=part_body_diameter,
  tail_diameter_start=part_tail_major_diameter,
  tail_diameter_end=part_tail_minor_diameter,
  tail_len=part_tail_length,
  shell_wall=shell_thickness,
  end_diameter=part_end_diameter,
  allowance=allowance,
  flex_tab_offset=flex_tab_offset
);

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
  end_diameter,
  shell_wall
) {
  // Main body and tail
  union() {
    translate([0, 0, -body_length])
      cylinder(h=body_length, d=body_diameter + shell_wall * 2);
    cylinder(h=tail_len, d1=body_diameter + shell_wall * 2, d2=tail_diameter_end + shell_wall * 2);
    cylinder(h=tail_len, d=end_diameter + shell_wall * 2);
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
  height_flex_tab_ratio = 0.6,
  width_flex_tab_ratio = 0.7,
  flex_tab_clearance = undef,
  end_diameter,
  allowance,
  flex_tab_keep_ratio = 0.5,
  flex_tab_offset = 0,
  end_fn = 6
) {

  // internal derived params for flex_tab  design
  flex_tab_z_start = -body_length * (1 + height_flex_tab_ratio) / 2;
  flex_tab_height = body_length * height_flex_tab_ratio;
  flex_tab_d1 = (body_diameter + shell_wall * 2) * (width_flex_tab_ratio * width_flex_tab_ratio);
  flex_tab_d2 = (body_diameter + shell_wall * 2) * (width_flex_tab_ratio);
  flex_tab_clearance = (flex_tab_clearance == undef) ? shell_wall : flex_tab_clearance;

  union() {
    difference() {

      probe_outer_body(
        body_length=body_length,
        body_diameter=body_diameter,
        tail_len=tail_len,
        tail_diameter_end=tail_diameter_end,
        end_diameter=end_diameter,
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

      // Hex cut thru all for the end part (e.g. an SMA connector)
      cylinder(h=body_length * 3, d=end_diameter, center=true, $fn=end_fn);
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
