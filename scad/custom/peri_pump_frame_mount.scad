/**
 * @file peri_pump_frame_mount.scad
 * @brief Peristaltic pump mount insert for the frame ribs
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * An insert block that seats in the pockets in the frame's ribs, bridging out to a flange
 * that the pump's motor bolts through. The pockets are the light pockets, so the insert is the
 * light's section less a clearance, and a half-round rib down each side face stands past the
 * pocket's wall by a little: the block presses in and stays put instead of rattling. Nothing on
 * the frame changes, so the lights keep their loose fit.
 */

use <../purchased/dc_motors.scad>;
use <../purchased/dc_motor.scad>;
use <../purchased/strip_lights.scad>;
use <../purchased/strip_light.scad>;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

/* [Peristaltic Pump Side Mount Parameters] */

// height of the flange that the motor mounts to
flange_height = 2.4;

// diameter of the motor the flange bore clears
motor_diameter = 27.5;

// Centre to centre distance between the flange screws, bolting to the pump head faceplate.
// Move onto the peri pump registration once that faceplate is modelled.
screw_separation = 48.0;

// Distance of the bridge separating the flange from the main insert block
flange_insert_separation = 6;

// height of the insert block
insert_height = 15;

// width of the insert block
insert_width = 14.1;

// depth of the insert block
insert_depth = 7.6;

// radius of the half-round rib down each side face of the insert
detent_radius = 0.4;

// diameter of the screws used to attach the pump to the mount
screw_diameter = 4;

peri_pump_frame_mount(
  flange_height=flange_height,
  flange_insert_separation=flange_insert_separation,
  screw_separation=screw_separation,
  motor_diameter=motor_diameter,
  screw_diameter=screw_diameter,
  insert_height=insert_height,
  insert_width=insert_width,
  insert_depth=insert_depth,
  detent_radius=detent_radius
);

module peri_pump_frame_mount(
  flange_height,
  flange_insert_separation,
  motor_diameter,
  screw_diameter,
  screw_separation,
  insert_height,
  insert_width,
  insert_depth,
  detent_radius,
) {

  _flange_width = screw_diameter * 1.5;

  echo("insert_width", insert_width, "insert_depth", insert_depth);

  outer_diameter = motor_diameter + _flange_width * 2;
  flange_span = screw_separation + _flange_width * 2;

  // Add the rib radius such that the insert_width input argument reflects the height
  // of the part it will couple to (i.e. the rib)
  _insert_height = insert_height + detent_radius * 2;

  assert(
    insert_width > 2 * detent_radius,
    str("peri_pump_frame_mount: a ", insert_width, " mm pocket leaves no block between ", detent_radius, " mm ribs")
  );

  // a motor wider than the flange span cuts the bore clean through it, splitting the part
  assert(
    flange_span > motor_diameter,
    str(
      "peri_pump_frame_mount: motor_diameter ", motor_diameter,
      " does not fit the flange span ", flange_span,
      "; widen screw_separation"
    )
  );

  union() {
    // main insert block
    translate([0, 0, -insert_height / 2])
      cube([insert_width, insert_depth, insert_height], center=true);

    // the rib, half-round on outwards face
    translate([0, insert_depth / 2, -insert_height + detent_radius * 2])
      rotate([0, 90, 0])
        scale([2, 1, 1]) cylinder(r=detent_radius, h=insert_width, center=true);

    
    // flange the motor bolts to
    _flange_y = outer_diameter / 2 + _flange_width / 2 + flange_insert_separation;
    translate([0, _flange_y, -flange_height / 2]) {
      difference() {
        // the ellipse, bridged straight back to the insert's footprint so the bridge lands on
        // the insert's back face and covers its corners
        hull() {
          resize([screw_separation + _flange_width * 2, outer_diameter, flange_height])
            cylinder(d=outer_diameter, h=flange_height, center=true);
          translate([0, -_flange_y, 0])
            cube([insert_width, insert_depth, flange_height], center=true);
        }
        // motor cut out
        cylinder(d=motor_diameter, h=flange_height + z_fight, center=true); // cut out for motor

        // face screw cut outs
        for (i = [0:1])
          mirror([i, 0, 0]) // cut outs for face screws
            translate([screw_separation / 2, 0, 0])
              cylinder(d=screw_diameter, h=flange_height + z_fight, center=true);
      }
    }
  }
}
