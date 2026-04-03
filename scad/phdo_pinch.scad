
probe_body_lenth = 35.6;
probe_body_diameter = 16.3;

tail_major_diameter = 8.7;
tail_minor_diameter = 4.3;
tail_length = 24.5;
wall_thickness = 0.6 * 2; // 2 walls of 0.6mm each

ratio = 0.8;

pinch_gap = 0.8;

connector_part_diameter = 9;

z_fight = 0.05; // A small gap to avoid z-fighting when cutting shapes

union() {
  difference() {

    // Main body and tail
    union() {
      translate([0, 0, -probe_body_lenth])
        cylinder(h=probe_body_lenth, d=probe_body_diameter + wall_thickness * 2, $fn=64);
      cylinder(h=tail_length, d1=probe_body_diameter + wall_thickness * 2, d2=tail_minor_diameter + wall_thickness * 2, $fn=64);
    }

    // Probe negative space and tail negative space
    translate([0, 0, -wall_thickness]) {
      translate([0, 0, -probe_body_lenth])
        cylinder(h=probe_body_lenth, d=probe_body_diameter, $fn=64);
      translate([0, 0, -z_fight]) // Avoid z-fighting with main body
        cylinder(h=tail_length + z_fight, d1=probe_body_diameter, d2=tail_major_diameter, $fn=64);
      translate([0, 0, tail_length])
        cylinder(h=tail_length, d=tail_minor_diameter, $fn=64);
    }

    // Cut off tail shell body halfway to let it flex
    translate([0, 0, tail_length / 2])
      cylinder(h=tail_length, d=probe_body_diameter + wall_thickness * 2, $fn=64);

    // Cut out pinch window
    translate([0, 0, -probe_body_lenth * (1 - (1 - ratio) / 2)]) scale([10, 1, 1])
        cylinder(h=probe_body_lenth * ratio, d2=probe_body_diameter * ratio, d1=probe_body_diameter * (ratio - 0.2), $fn=64);
  }

  translate([0, 0, -probe_body_lenth * (1 - (1 - ratio) / 2)])
    intersection() {
      // Bell shape for pinch area
      difference() {
        cylinder(h=probe_body_lenth * ratio, d2=probe_body_diameter, d1=probe_body_diameter + wall_thickness * 2, $fn=64);
        translate([0, 0, -wall_thickness])
          cylinder(h=probe_body_lenth, d2=probe_body_diameter - wall_thickness, d1=probe_body_diameter, $fn=64);
      }

      // Intersection (same as cut out pinch window) to create pinch tabs
      scale([10, 1, 1]) {
        cylinder(h=probe_body_lenth * ratio - pinch_gap, d2=probe_body_diameter * ratio - pinch_gap, d1=probe_body_diameter * (ratio - 0.2) - pinch_gap, $fn=64);
      }
    }
}
