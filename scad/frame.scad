/**
 * @file frame.scad
 * @brief Frame subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

include <purchased/strip_lights.scad>;

use <utils/bolt_pattern.scad>;

include <NopSCADlib/core.scad>; // core utils (also silences the inch() warning)
include <NopSCADlib/vitamins/nuts.scad>; // M8_nut type + nut()
include <NopSCADlib/vitamins/screws.scad>; // M8_hex_screw type + screw_length()
use <NopSCADlib/vitamins/rod.scad>; // studding()

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// -------

render_all = true; // render all components
render_base = false;
render_upper_base = false;
render_ribs = false;
render_rods = false;
render_rodspacers = false;
render_lights = false;

// -------

frame(
  vessel_height=305, vessel_outer_diameter=220, lights_length=330, wall_thickness=37,
  lid_flange_height=8, n_rods=4, bolt_screw=M8_hex_screw,
  bolt_pts=bolt_pattern_pts(_preview_posts, _preview_bolt_circle, 4),
  collapse_spacer_z_allow=false
);

// -------

/* [Light Parameters] */

// the registered strip light the base is pocketed for; every light dimension is read back
// out of it via the accessor functions (see purchased/strip_light.scad)
frame_light = rwntao_13in; // [generic_strip_light, rwntao_13in, grow_13in, grow_16in, grow_8p6in]
// which quadrants to place lights in, 1-4 starting from positive x and going CCW
light_quadrants = [1, 3];
// number of lights to place in each quadrant
lights_per_quadrant = 3;
// angle that the lights occupy
occupy_angle = 60; // of the 90 degree quadrant
// allowance for the light to fit in the base
light_allow = 0.4;

/* [Nut & Rod Parameters] */

// diameter of the threaded rod
threaded_rod_diameter = 8.0; // M8
// allowance for the nut pocket to fit the nut
nut_pocket_allowance = 0.6;
// allowance for the hole for the threaded rod
threaded_rod_hole_allowance = 1.2;
// thread left showing above the topmost rod nut; two coarse M8 pitches
rod_thread_proud = 2.5;

// diameter of the nut
nut_pocket_diameter = 2 * nut_radius(M8_nut) + nut_pocket_allowance;
// height of the nut
nut_height = nut_thickness(M8_nut);

/* [Base Parameters] */

// allowance for the jar to fit in the base
base_jar_fit_allow = 0.4;

// height of the bottom base (holding jar)
lower_base_wall_height = 25;
// height of the top base (holding lid)
upper_base_height = 10;
// height of the rib base
rib_base_height = 10;
// stack a second rib at each level, rotated to close the arc the pair below leaves open
double_ribs = true;

/* [Rod Spacer Parameters] */

// thickness of the rod spacer
rod_spacer_thickness = 2;
// allowance for the rod spacer to fit on the rod
spacer_dia_allow = 0.2;
// allowance for the rod spacer to fit on the rod
spacer_z_allow = 0.4;

/* [Color Parameters] */

// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

// The rod circle is where the frame puts its tie rods, and the lid has to bolt to the same circle,
// so the assembly reads these back out rather than rebuilding them from the frame's own allowances.
function frame_rod_hole_diameter() = threaded_rod_diameter + threaded_rod_hole_allowance;
function frame_bolt_circle_diameter(vessel_outer_diameter) =
  (vessel_outer_diameter + base_jar_fit_allow) + frame_rod_hole_diameter() * 2;

// the assembly derives the joint once and hands the same pattern to the frame and the lid; the
// standalone preview above reproduces it, see the interface TODO about the hardcoded vessel dimensions
_preview_bolt_circle = frame_bolt_circle_diameter(220);
_preview_posts = bolt_post_count(4, threaded_rod_diameter, _preview_bolt_circle, 8, 0.5);

module lights(quadrants, vessel_outer_diameter, lights_per_quadrant, occupy_angle, allowance_cutout = undef) {
  for (q = quadrants) {
    rotate([0, 0, (q - 1) * 90]) {
      for (i = [0:lights_per_quadrant - 1]) {

        angle_offset = (90 - occupy_angle) / 2;
        light_angle =
          lights_per_quadrant == 1 ? 45
          : i * (occupy_angle / (lights_per_quadrant - 1)) + angle_offset;

        rotate([0, 0, light_angle])
          translate([0, vessel_outer_diameter / 2, 0]) if (is_undef(allowance_cutout)) {
            strip_light(frame_light);
          } else {
            translate([0, strip_light_depth(frame_light) / 2, strip_light_length(frame_light) / 2])
              cube([strip_light_width(frame_light) + allowance_cutout, strip_light_depth(frame_light) + allowance_cutout, strip_light_length(frame_light)], center=true);

            // same profile on its side, cut radially thru the wall so the cord can escape
            translate([0, vessel_outer_diameter / 2, (strip_light_depth(frame_light) + allowance_cutout) / 2 - z_fight/2])
              cube([strip_light_width(frame_light) + allowance_cutout, vessel_outer_diameter, strip_light_depth(frame_light) + allowance_cutout], center=true);
          }
      }
    }
  }
}

module frame(vessel_height, vessel_outer_diameter, lights_length, wall_thickness, lid_flange_height, n_rods, bolt_pts, bolt_screw, collapse_spacer_z_allow=true) {

  _base_floor_height_min = 2; // minimum height of the base floor

  height_delta = (lights_length + nut_height * 1.5 + upper_base_height) - vessel_height; // 150% nut thickness added so radial bolt heads have clearance
  base_floor_height = height_delta > _base_floor_height_min ? height_delta : _base_floor_height_min;

  // total height of the assembly
  total_height = vessel_height + base_floor_height;

  // diameter of the cutout for the jar
  base_jar_cut_diameter = vessel_outer_diameter + base_jar_fit_allow;

  // diameter of the hole for the threaded rod
  threaded_rod_hole_diameter = frame_rod_hole_diameter();

  // distance from the center of the jar to the threaded rod
  rod_shift = frame_bolt_circle_diameter(vessel_outer_diameter) / 2;

  f_height = 0 - z_fight;

  lower_base_height = base_floor_height + lower_base_wall_height;

  // ribs and spacers share one stack, so both read these rather than deriving them separately
  // TODO: n_rib_levels is still hardcoded to 2 by the loops below
  n_rib_levels = 2;
  ribs_per_level = double_ribs ? 2 : 1;
  rib_level_height = rib_base_height * ribs_per_level;
  spacers_total_height = total_height - upper_base_height - lower_base_height - rib_level_height * n_rib_levels;
  z_shift_factor = 1 / (n_rib_levels + 1);
  spacer_slot_height = spacers_total_height * z_shift_factor;
  spacer_height = spacer_slot_height - spacer_z_allow * 2;

  // collapsed, the stack pitches on the real part height and butts down from the lower base, so every
  // joint allowance shows as one gap under the top base - review that against the lid flange
  spacer_pitch = collapse_spacer_z_allow ? spacer_height : spacer_slot_height;
  spacer_joint = collapse_spacer_z_allow ? 0 : spacer_z_allow / 2;
  stack_slack = (spacer_slot_height - spacer_pitch) * (n_rib_levels + 1); // what the collapsed stack gives up, so the top base drops with it

  // The lid is located by the vessel rim, the top base by the collapsed stack below it, so the
  // two faces do not meet - stack_slack is the clearance between them and that is what lets the
  // bolts pull the lid down into the vessel rather than bottoming it on the frame. Every span
  // that crosses the joint therefore has to count it: the bolt grips both parts and the gap.
  bolt_length = screw_length(bolt_screw, upper_base_height + stack_slack + lid_flange_height, 0, nut=true);

  // The rod runs from the base floor up to a nut sitting on top of the lid, which is on the rim
  // datum, so it clears the gap too. Derived rather than passed in: the caller knows the vessel
  // and the flange but not the stack, and this is the stack's business.
  rod_length = vessel_height + lid_flange_height + nut_height + rod_thread_proud;

  // distance from the center of the jar to the threaded rod
  base_wall_thickness_from_lights = (strip_light_depth(frame_light) * 1.5) * 2; // thinnest part is 50% thicker than the light depth

  base_wall_thickness_from_rod = threaded_rod_hole_diameter * 4; // thinnest part is 4x the rod diameter or approx x2 the nut diameter

  assert(
    wall_thickness >= max(base_wall_thickness_from_lights, base_wall_thickness_from_rod),
    str(
      "Base wall thickness is too thin. Must be at least ",
      max(base_wall_thickness_from_lights, base_wall_thickness_from_rod),
      " mm."
    )
  );

  // The top base carries a nut pocket sunk into its underside, so it has to be deeper than the nut
  // or the pocket opens out the bottom and merges with the bolt bores into a slot.
  assert(
    upper_base_height > nut_height,
    str("Top base is ", upper_base_height, " mm with a ", nut_height, " mm nut pocket sunk in it.")
  );

  // The gap the joint bolts pull the lid down through. Without it the top base's top face lands on
  // the rim and the lid bottoms on the frame instead of seating on the glass. Conditional because
  // this file's own preview passes collapse_spacer_z_allow=false, which sets it to 0 by design.
  assert(
    !collapse_spacer_z_allow || stack_slack > 0,
    str("The lid-to-top-base gap is ", stack_slack, " mm; the bolts cannot clamp the lid into the vessel without it.")
  );

  _base_wall_thickness = wall_thickness;

  echo("base wall thickness: ", _base_wall_thickness / 10, " cm");

  module frame_lights(local_quadrants = light_quadrants) {
    lights(local_quadrants, vessel_outer_diameter, lights_per_quadrant, occupy_angle);
  }

  module frame_lights_cutout(local_quadrants = [1, 2, 3, 4]) {
    difference() {
      children();
      lights(local_quadrants, vessel_outer_diameter, lights_per_quadrant, occupy_angle, allowance_cutout=light_allow);
    }
  }

  // Translate entire frame down by the height of the base floor
  // Since design is located based on the bottom of the vessel
  translate([0, 0, -base_floor_height - z_fight]) {
    if (render_lights || render_all) {
      frame_lights();
    }

    // rods and nuts
    if (render_rods || render_all) {
      for (i = [0:n_rods - 1]) {
        rotate([0, 0, i * 360 / n_rods])
          translate([rod_shift, 0, 0]) {

            // M8 threaded rod, full height (base at z = 0)
            translate([0, 0, base_floor_height])
            studding(d=threaded_rod_diameter, l=rod_length, center=false);

            // within of base
            translate([0, 0, base_floor_height])
              rotate([0, 0, 30])
                nut(M8_nut);

            // pocketed in the top base, holding it as the fixed face the lid bolts to
            translate([0, 0, total_height - stack_slack - nut_height - z_fight])
              rotate([0, 0, 30])
                nut(M8_nut);

            // the rods are posts like the bolts, so they take a nut on top of the lid as well.
            // The lid sits on the rim, so this reads total_height, not the top base's face
            translate([0, 0, total_height + lid_flange_height])
              rotate([0, 0, 30])
                nut(M8_nut);
          }
      }

      // bolts clamping the lid flange onto the top base, heads bearing on the face underneath
      translate([0, 0, total_height - stack_slack - upper_base_height]) {
        bolt_pattern_bolts(bolt_pts, bolt_screw, bolt_length);

        // their nuts land on the far side of the grip, on top of the lid flange, which is the
        // gap above this base plus the flange itself
        for (p = bolt_pts)
          translate([p[0], p[1], upper_base_height + stack_slack + lid_flange_height])
            rotate([0, 0, 30])
              nut(screw_nut(bolt_screw));
      }
    }

    // lower base
    if (render_base || render_all) {
      frame_lights_cutout()
        color(prints1_color)
          // create the base
          difference() {
            cylinder(d=base_jar_cut_diameter + _base_wall_thickness, h=lower_base_height);

            // jar cavity above the floor, and the bore that leaves the floor a ring
            translate([0, 0, base_floor_height])
              cylinder(d=base_jar_cut_diameter, h=lower_base_height - base_floor_height + z_fight);
            translate([0, 0, -z_fight / 2])
              cylinder(d=base_jar_cut_diameter - _base_wall_thickness * 2, h=lower_base_height + z_fight);

            for (i = [0:n_rods - 1]) {
              _nut_pocket_height = nut_height * 1.1;
              rotate([0, 0, i * 360 / n_rods])
                translate([rod_shift, 0, 0]) {
                  translate([0, 0, base_floor_height])
                    cylinder(d=threaded_rod_hole_diameter, h=lower_base_height + z_fight);

                  // cut out the nut pocket sitting at same height as vessel
                  translate([0, 0, base_floor_height]) {
                    cylinder(d=nut_pocket_diameter, h=_nut_pocket_height + z_fight);
                    translate([nut_pocket_diameter / 2, 0, (_nut_pocket_height + z_fight) / 2])
                      cube([nut_pocket_diameter, nut_pocket_diameter, _nut_pocket_height + z_fight], center=true);
                  }
                }
            }
          }
    }

    // top base
    if (render_upper_base || render_all) {
      frame_lights_cutout()
        color(prints1_color)
          translate([0, 0, total_height - stack_slack - upper_base_height])
            // the lid bolts down through these, the heads bearing on the face underneath
            bolt_pattern_bores(bolt_pts, threaded_rod_hole_diameter, upper_base_height + z_fight, -z_fight / 2)
            difference() {
              cylinder(d=base_jar_cut_diameter + _base_wall_thickness, h=upper_base_height);

              // hollow right through - the lid sits in it, so there is no floor
              translate([0, 0, f_height])
                cylinder(d=base_jar_cut_diameter, h=upper_base_height - f_height + z_fight);

              for (i = [0:n_rods - 1]) {
                rotate([0, 0, i * 360 / n_rods])
                  translate([rod_shift, 0, 0]) {
                    translate([0, 0, -z_fight / 2])
                      cylinder(d=threaded_rod_hole_diameter, h=upper_base_height + z_fight);

                    // cut out the nut pocket on the top base
                    translate([0, 0, upper_base_height - nut_height])
                      rotate([0, 0, 30])
                        cylinder(d=nut_pocket_diameter, h=nut_height + z_fight);
                  }
              }
            }
    }

    // ribs
    if (render_ribs || render_all) {
      // Number of rods holders on the ribs
      n_rods_ribs = 2;

      // create the ribs
      for (i = [1:2]) {

        rib_pos = lower_base_height + spacer_pitch * i - spacer_joint + rib_level_height * (i - 1);

        frame_lights_cutout()

        // a 2-rod base is a 90 degree arc, so the j pair leaves two gaps; k stacks a second
        // pair on the first pair's rod bosses, turned 90 to fill them
        for (j = [1:2], k = [0:ribs_per_level - 1]) {
          rotate([0, 0, j * 180 + k * 90])
            rotate([0, 0, i * 90])
              translate([0, 0, rib_pos + k * rib_base_height])
                color(prints1_color)
                  difference() {
                    union() {
                      rotate_extrude(angle=(n_rods_ribs - 1) * 90)
                        square([(base_jar_cut_diameter + _base_wall_thickness) / 2, rib_base_height]);

                      // a boss at each rod, so the arc's cut ends still enclose the hole
                      // TODO: make a clean semi circle end cap that matches instead of oversized
                      for (r = [0:n_rods_ribs - 1])
                        rotate([0, 0, r * 90])
                          translate([base_jar_cut_diameter / 2, 0, 0])
                            cylinder(d=_base_wall_thickness, h=rib_base_height);
                    }

                    for (r = [0:n_rods_ribs - 1])
                      rotate([0, 0, r * 90])
                        translate([rod_shift, 0, -z_fight / 2])
                          cylinder(d=threaded_rod_hole_diameter, h=rib_base_height + z_fight);

                    translate([0, 0, f_height])
                      cylinder(d=base_jar_cut_diameter, h=rib_base_height - f_height + z_fight);
                  }
        }
      }
    }

    // rod rib spacers
    if (render_rodspacers || render_all) {
      rod_spacer_diameter = threaded_rod_diameter + 2 * rod_spacer_thickness;

      color(prints2_color)for (i = [0:2]) {
        for (j = [0:n_rods - 1]) {

          spacer_pos = lower_base_height + spacer_pitch * i + spacer_joint + rib_level_height * i;

          rotate([0, 0, j * 360 / n_rods])
            translate([rod_shift, 0, spacer_pos])
              difference() {
                cylinder(d=rod_spacer_diameter, h=spacer_height);
                cylinder(d=threaded_rod_diameter + spacer_dia_allow, h=spacer_height + z_fight);
              }
        }
      }
    }
  }
}
