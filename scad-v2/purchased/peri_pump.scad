// peristaltic pump
// Work-in-progress

motor_diameter = 50;

roller_carrier_base_th = 4;

roller_inner_diameter = 10;
roller_outer_diameter = 20;
roller_length = 15;

// the roller radius offset is the distance 
roller_radius_offset = 0;

// driven parameters

roller_carrier_diameter = motor_diameter;

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

module pump_cassette(){}

// composable and parameteric assembly of the full head (everything that is not the motor)
module peri_pump_head(){}
