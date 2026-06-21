// peristaltic pump
//
// Work-in-progress!
// Note to self: revive and use uniTube project for
// the tubing modelling? Here and in general?

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

motor_diameter = 50;

tube_diameter = 3;

roller_carrier_base_th = 4;

roller_inner_diameter = 10;
roller_outer_diameter = 20;
roller_length = 25;

// the roller radius offset is the distance 
roller_radius_offset = 0;

cassette_roller_carrier_allowance = 0.3;

module dummy() {
  // dummy module to prevent "No top-level modules" error while developing
}

// driven parameters

roller_carrier_diameter = motor_diameter;

cassette_inner_diameter = roller_carrier_diameter + cassette_roller_carrier_allowance;
cassette_entry_channels_width = tube_diameter * 2;

module roller_carrier() {
  // base plate
  cylinder(d=roller_carrier_diameter, h=roller_carrier_base_th);

  // carrier posts
  for (i = [0:2]) {
    rotate([0, 0, i * 120])
      translate([roller_carrier_diameter / 2 - roller_outer_diameter / 2 + roller_radius_offset, 0, 0])
        cylinder(d=roller_inner_diameter, h=roller_length);
  }
}

module roller() {
  difference() {
    cylinder(d=roller_outer_diameter, h=roller_length);
    cylinder(d=roller_inner_diameter, h=roller_length * 2); //x2 for thru cut
  }
}

//roller_carrier();

linear_extrude(height=10) {
  circle(d=cassette_inner_diameter);

  for (i = [0:1])
    mirror([i, 0, 0])
      color("green")
        translate([cassette_inner_diameter / 2 - cassette_entry_channels_width * 2, 0, 0])
          polygon(points=[[-cassette_inner_diameter / 2, 0], [cassette_entry_channels_width, 0], [cassette_entry_channels_width, cassette_inner_diameter / 2], [0, cassette_inner_diameter / 2]]);
}

color("red")
  difference() {

    union() {
      circle(d=cassette_inner_diameter);
      for (i = [0:1])
        mirror([i, 0, 0])
          translate([cassette_inner_diameter / 2 - cassette_entry_channels_width * 2, cassette_inner_diameter / 4, 0])
            polygon(points=[[0, 0], [cassette_entry_channels_width, 0], [cassette_entry_channels_width, cassette_inner_diameter / 4], [0, cassette_inner_diameter / 4]]);
    }

    circle(d=cassette_inner_diameter - tube_diameter * 4);
    translate([0, cassette_inner_diameter / 4, 0])
      square([2 * (cassette_inner_diameter / 2 - cassette_entry_channels_width * 2), cassette_inner_diameter / 2], center=true);
  }

module pump_cassette(){}

// composable and parameteric assembly of the full head (everything that is not the motor)
module peri_pump_head(){}
