// Peristaltic pump frame mount insert for
// inserting into the pockets in the ribs
// of the frame to allow mounting the pump

zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// diameter of the motor
motor_diameter = 34;

// motor mount side insert
flange_width = 5;

// height of the flange that the motor mounts to
flange_height = 2.4;

// Center to center distance between the flange screws
flange_screw_distance = 48.0;

// Distance of the bridge separating the flange from the main insert block
flange_insert_separation = 2;

// height of the insert block
insert_height = 15;

// width of the insert block (x-dim)
insert_width = 14.1;

// depth of the insert block (y-dim)
insert_depth = 7.6;

// diameter of the screws used to attach the motor to the mount
screw_diameter = 4;

peri_pump_frame_mount(
  flange_width=flange_width,
  flange_height=flange_height,
  flange_screw_distance=flange_screw_distance,
  flange_insert_separation=flange_insert_separation,
  insert_height=insert_height,
  insert_width=insert_width,
  insert_depth=insert_depth,
  motor_diameter=motor_diameter,
  screw_diameter=screw_diameter
);

module peri_pump_frame_mount(
  flange_width,
  flange_height,
  flange_screw_distance,
  flange_insert_separation,
  insert_height,
  insert_width,
  insert_depth,
  motor_diameter,
  screw_diameter
) {

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

        // motor cut out
        cylinder(d=motor_diameter, h=flange_height + 0.1, center=true); // cut out for motor

        // face screw cut outs
        for (i = [0:1])
          mirror([i * 1, 0, 0]) // cut outs for face screws
            translate([flange_screw_distance / 2, 0, 0])
              cylinder(d=screw_diameter, h=flange_height + 0.1, center=true);
      }
    }
  }
}
