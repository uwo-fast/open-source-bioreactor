// peristaltic pump
//
// Work-in-progress!
//
// Note to self: revive and use uniTube project for
// the tubing modelling? Here and in general? Save
// for when approaching final design. 

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

motor_diameter = 50;

tube_diameter = 3;

roller_carrier_base_th = 4;

roller_inner_diameter = 10;
roller_outer_diameter = 20;
roller_length = 20;

// the roller radius offset is the distance 
roller_radius_offset = -1.5;

cassette_height = 28;
cassette_roller_carrier_allowance = 0.3;
cassette_wall_thickness = 3;
roller_carrier_allowance = 0.2;

motor_shaft_diameter = 4;

module dummy() {
  // dummy module to prevent "No top-level modules" error while developing
}

// driven parameters

roller_carrier_diameter = motor_diameter;

cassette_inner_diameter = roller_carrier_diameter + cassette_roller_carrier_allowance;
cassette_entry_channels_width = tube_diameter * 2;

module roller_carrier() {

  difference() {

    union() {
      // base plate
      cylinder(d=roller_carrier_diameter, h=roller_carrier_base_th);

      // collet protrusion for gripping the motor shaft
      translate([0, 0, roller_carrier_base_th])
        cylinder(d1=roller_carrier_diameter / 2, d2=roller_carrier_diameter / 4, h=roller_length - roller_carrier_base_th);
    }

    // remove material where rollers would interfere with the carrier center
    for (i = [0:2]) {
      rotate([0, 0, i * 120])
        translate([roller_carrier_diameter / 2 - roller_outer_diameter / 2 + roller_radius_offset, 0, roller_carrier_base_th])
          cylinder(d=roller_outer_diameter + roller_carrier_allowance, h=roller_length);
    }

    // center hole for motor shaft
    cylinder(d=motor_shaft_diameter, h=roller_length * 2, center=true);
  }

  // carrier posts
  for (i = [0:2]) {
    rotate([0, 0, i * 120])
      translate([roller_carrier_diameter / 2 - roller_outer_diameter / 2 + roller_radius_offset, 0, roller_carrier_base_th / 2])
        cylinder(d=roller_inner_diameter, h=roller_length);
  }
}

module roller() {
  difference() {
    cylinder(d=roller_outer_diameter, h=roller_length);
    translate([0, 0, -z_fight / 2]) // z-fighting avoidance
      cylinder(d=roller_inner_diameter, h=roller_length + z_fight);
  }
}

module roller_subassembly() {

  color("forestgreen")
    roller_carrier();

  color("beige")
    translate([0, 0, roller_carrier_base_th])for (i = [0:2]) {
      rotate([0, 0, i * 120])
        translate([roller_carrier_diameter / 2 - roller_outer_diameter / 2 + roller_radius_offset, 0, 0])
          roller();
    }
}

module cassette_inner_profile() {
  union() {
    circle(d=cassette_inner_diameter);

    for (i = [0:1])
      mirror([i, 0, 0])
        translate([cassette_inner_diameter / 2 - cassette_entry_channels_width * 2, 0, 0])
          polygon(points=[[-cassette_inner_diameter / 2, 0], [cassette_entry_channels_width, 0], [cassette_entry_channels_width, cassette_inner_diameter / 2], [0, cassette_inner_diameter / 2]]);
  }
}

module cassette_tube_path_profile() {
  color("red")
    difference() {

      union() {
        circle(d=cassette_inner_diameter);
        for (i = [0:1])
          mirror([i, 0, 0])
            translate([cassette_inner_diameter / 2 - cassette_entry_channels_width * 2, cassette_inner_diameter / 4, 0])
              polygon(points=[[0, 0], [cassette_entry_channels_width, 0], [cassette_entry_channels_width, cassette_inner_diameter / 2], [0, cassette_inner_diameter / 2]]);
      }

      circle(d=cassette_inner_diameter - tube_diameter * 4);
      translate([0, cassette_inner_diameter / 4, 0])
        square([2 * (cassette_inner_diameter / 2 - cassette_entry_channels_width * 2), cassette_inner_diameter / 2], center=true);
    }
}

module pump_cassette() {
  difference() {
    linear_extrude(height=cassette_height)
      offset(cassette_wall_thickness)
        cassette_inner_profile();

    translate([0, 0, cassette_wall_thickness])
      linear_extrude(height=cassette_height)
        union() {
          cassette_inner_profile();
          cassette_tube_path_profile();
        }

    // center hole for motor shaft
    cylinder(d=motor_shaft_diameter, h=cassette_wall_thickness * 2, center=true);
  }
}

module pump_cassette_cover() {
  linear_extrude(height=cassette_wall_thickness)
    offset(cassette_wall_thickness)
      cassette_inner_profile();
}

// composable and parameteric assembly of the full head (everything that is not the motor)
module peri_pump_head() {

  color("steelblue")
    pump_cassette();

  translate([0, 0, cassette_wall_thickness])
    roller_subassembly();

  translate([0, 0, cassette_height])
    color("lightblue")
      pump_cassette_cover();
}
