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
use <../frame.scad>; // the pocket's allowance over the light

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

/* [Preview] */

// the registered motor this mount collars, for the preview
mount_motor = dc_motor_by_name("12v_5w");
// the registered light whose pocket the insert seats in, for the preview; the frame cuts the pocket
pocket_light = strip_light_by_name("RWNTAO 13in");

/* [Peristaltic Pump Side Mount Parameters] */

// diameter of the motor the flange bore clears
motor_diameter = dc_motor_diameter(mount_motor);

// motor mount side insert
flange_width = 5;

// height of the flange that the motor mounts to
flange_height = 2.4;

// Centre to centre distance between the flange screws, bolting to the pump head faceplate.
// Move onto the peri pump registration once that faceplate is modelled.
flange_screw_distance = 48.0;

// Distance of the bridge separating the flange from the main insert block
flange_insert_separation = 2;

// height of the insert block
insert_height = 15;

// the pocket is the light's section plus this; the frame's number, read back
pocket_allow = frame_light_pocket_allowance();

// radius of the half-round rib down each side face of the insert
rib_radius = 1;

// how far each rib's crest stands past the pocket's wall, the press
rib_interference = 0.15;

// diameter of the screws used to attach the pump to the mount
screw_diameter = 4;

peri_pump_frame_mount(
  flange_width=flange_width,
  flange_height=flange_height,
  flange_screw_distance=flange_screw_distance,
  flange_insert_separation=flange_insert_separation,
  insert_height=insert_height,
  pocket_width=strip_light_width(pocket_light) + pocket_allow,
  insert_depth=strip_light_depth(pocket_light),
  rib_radius=rib_radius,
  rib_interference=rib_interference,
  motor_diameter=motor_diameter,
  screw_diameter=screw_diameter
);

module peri_pump_frame_mount(
  flange_width,
  flange_height,
  flange_screw_distance,
  flange_insert_separation,
  insert_height,
  pocket_width,
  insert_depth,
  rib_radius,
  rib_interference,
  motor_diameter,
  screw_diameter
) {

  outer_diameter = motor_diameter + flange_width * 2;
  flange_span = flange_screw_distance + flange_width * 2;

  // The ribs' crests reach past the pocket's side walls by the interference, so the block
  // between them is the pocket less a rib each side and plus the press. Its depth is the light's,
  // with the light's clearance: nothing on the inner face to press against, since the pocket is
  // open to the jar.
  insert_width = pocket_width + 2 * rib_interference - 2 * rib_radius;

  assert(
    insert_width > 2 * rib_radius,
    str("peri_pump_frame_mount: a ", pocket_width, " mm pocket leaves no block between ", rib_radius, " mm ribs")
  );

  // a motor wider than the flange span cuts the bore clean through it, splitting the part
  assert(
    flange_span > motor_diameter,
    str(
      "peri_pump_frame_mount: motor_diameter ", motor_diameter,
      " does not fit the flange span ", flange_span,
      "; widen flange_screw_distance or flange_width"
    )
  );

  union() {
    cube([insert_width, insert_depth, insert_height], center=true); // main insert block

    // the ribs, half-rounds down the side faces
    for (s = [-1, 1])
      translate([s * insert_width / 2, 0, 0])
        cylinder(r=rib_radius, h=insert_height, center=true);

    // gap bridge
    translate([0, insert_depth / 2 + flange_insert_separation / 2, insert_height / 2 - flange_height / 2])
      cube([insert_width, flange_insert_separation, flange_height], center=true);

    // flange the motor bolts to
    translate([0, outer_diameter / 2 + flange_width / 2 + flange_insert_separation, insert_height / 2 - flange_height / 2]) {
      difference() {
        resize([flange_screw_distance + flange_width * 2, outer_diameter, flange_height])
          cylinder(d=outer_diameter, h=flange_height, center=true);

        // motor cut out
        cylinder(d=motor_diameter, h=flange_height + z_fight, center=true); // cut out for motor

        // face screw cut outs
        for (i = [0:1])
          mirror([i, 0, 0]) // cut outs for face screws
            translate([flange_screw_distance / 2, 0, 0])
              cylinder(d=screw_diameter, h=flange_height + z_fight, center=true);
      }
    }
  }
}
