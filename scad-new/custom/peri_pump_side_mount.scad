include <_config.scad>;

// diameter of the motor
motor_diameter = 34;

// motor mount side insert
flange_width = 5;
flange_height = 2.4;
flange_screw_distance = 48.0;

flange_insert_separation = 2;

insert_height = 15;
insert_width = 14.1;
insert_depth = 7.6;

screw_diameter = 4;

peri_pump_side_mount(flange_width = flange_width, flange_height = flange_height, flange_screw_distance = flange_screw_distance, flange_insert_separation = flange_insert_separation, insert_height = insert_height, insert_width = insert_width, insert_depth = insert_depth, motor_diameter = motor_diameter, screw_diameter = screw_diameter);

module peri_pump_side_mount(flange_width, flange_height, flange_screw_distance,
  flange_insert_separation, insert_height, insert_width, insert_depth,
  motor_diameter, screw_diameter) 
{

  outer_diameter = motor_diameter + flange_width * 2;

  union() {
    cube([insert_width, insert_depth, insert_height], center=true); // main insert block

    // gap bridge
    translate([0, insert_depth / 2 + flange_insert_separation / 2, insert_height / 2 - flange_height / 2])
      cube([insert_width, flange_insert_separation, flange_height], center=true);

    // motor cut out
    translate([0, outer_diameter / 2 + flange_width / 2 + flange_insert_separation, insert_height / 2 - flange_height / 2]) {
      difference() {
        resize([flange_screw_distance + flange_width * 2, outer_diameter, flange_height])
          cylinder(d=outer_diameter, h=flange_height, center=true);

        // face screw cut outs
        cylinder(d=motor_diameter, h=flange_height + 0.1, center=true); // cut out for motor
        for (i = [0:1])
          mirror([i * 1, 0, 0]) // cut outs for face screws
            translate([flange_screw_distance / 2, 0, 0]) cylinder(d=screw_diameter, h=flange_height + 0.1, center=true);
      }
    }
  }
}
