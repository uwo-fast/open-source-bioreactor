/**
 * @file frame.scad
 * @brief Frame subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

include <purchased/strip_lights.scad>;
include <purchased/vessels.scad>; // the preview builds against a registered jar, not copied numbers

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
// Which rib, counted in the order they are emitted, for a per-part export. undef renders the whole
// set at their own positions, which is the assembly picture rather than something to put on a bed.
rib_to_render = undef;
render_rods = false;
render_rodspacers = false;
// Which rod spacer, for the same reason. There are three runs of four and they are all one part -
// a plain annulus with nothing to tell them apart - so a per-part export wants any single one.
rodspacer_to_render = undef;
render_lights = false;

// -------

frame(
  vessel_height=vessel_height(_preview_vessel),
  vessel_outer_diameter=vessel_diameter(_preview_vessel),
  light=_preview_light,
  wall_thickness=_preview_wall_thickness,
  lid_flange_height=_preview_flange_height,
  n_rods=_preview_n_rods,
  bolt_screw=_preview_bolt,
  bolt_pts=bolt_pattern_pts(_preview_posts, _preview_bolt_circle, _preview_n_rods),
  collapse_spacer_z_allow=false
);

// -------

/* [Light Parameters] */

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
// the nut that runs on it - every pocket, every drawn nut and every height reads this one
rod_nut = M8_nut;
// allowance for the nut pocket to fit the nut
nut_pocket_allowance = 0.6;
// allowance for the hole for the threaded rod
threaded_rod_hole_allowance = 1.2;
// thread left showing above the topmost rod nut; two coarse pitches, from the rod's own diameter
rod_thread_proud = 2 * bolt_coarse_pitch(threaded_rod_diameter);

// diameter of the nut
nut_pocket_diameter = 2 * nut_radius(rod_nut) + nut_pocket_allowance;
// height of the nut
nut_height = nut_thickness(rod_nut);

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
// how many rib levels the stack carries. Up here beside double_ribs rather than inside frame(),
// because frame_print_parts() has to count the ribs and the spacers and cannot see a local.
n_rib_levels = 2;

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
function frame_rod_diameter() = threaded_rod_diameter; // exported so the joint can check its bolts against it
function frame_rod_hole_diameter() = threaded_rod_diameter + threaded_rod_hole_allowance;
function frame_bolt_circle_diameter(vessel_outer_diameter) =
  (vessel_outer_diameter + base_jar_fit_allow) + frame_rod_hole_diameter() * 2;

// The joint's outer face. The wall is material between the jar pocket and the outside, and the
// pocket carries the fit allowance, so the allowance grows the outside rather than thinning the
// wall. The lid flange closes the same face, so it reads this rather than rebuilding it from the
// vessel - which is what left it 0.4 mm short of the frame it lands on.
function frame_outer_diameter(vessel_outer_diameter, wall_thickness) =
  (vessel_outer_diameter + base_jar_fit_allow) + wall_thickness;

/**
 * @brief Every printed part the frame carries: [name, quantity, the flags that render it alone].
 *
 * The other half of head_print_parts(), and the half that matters most for what a builder needs to
 * own: the base and the top base are as wide as the lid and wider than anything hanging off it, so
 * a print list without them omits the parts that decide the printer. `just export-parts` walks both.
 *
 * THE RIBS ARE ONE PART, EIGHT TIMES, and that took measuring rather than reading. Each is rotated
 * by a multiple of 90 degrees and then bitten by the same lights cutout, and the exported meshes do
 * NOT agree: the vertices land at different radii, because the cut surface tessellates differently
 * at each rotation. Volume, facet count and bounding box all match, and intersecting one with
 * another turned to its angle returns a rib's whole volume - the same solid, meshed two ways.
 */
function frame_print_parts(n_rods) =
  [
    ["frame_base", 1, "-D render_base=true"],
    ["frame_upper_base", 1, "-D render_upper_base=true"],
    ["frame_rib", n_rib_levels * 2 * (double_ribs ? 2 : 1), "-D render_ribs=true -D rib_to_render=0"],
    ["frame_rod_spacer", (n_rib_levels + 1) * n_rods, "-D render_rodspacers=true -D rodspacer_to_render=0"],
  ];

// How far the frame reaches below the vessel's bottom. The lights set it: the base floor is
// whatever is left once a light, a nut and a half for the radial bolt heads, and the top base have
// been stacked against the vessel's height. Read back out by anything that has to make room for an
// assembled reactor, since it is the bottom of the envelope.
_base_floor_height_min = 2; // minimum height of the base floor
function frame_floor_depth(vessel_height, light) =
  let (delta = (strip_light_length(light) + nut_height * 1.5 + upper_base_height) - vessel_height)
    delta > _base_floor_height_min ? delta : _base_floor_height_min;

// What the assembly would hand this frame. The vessel, the light, the wall and the flange are its
// choices, so the preview picks them; everything after that is derived here the same way the
// assembly derives it, rather than quoting the numbers it comes out as.
_preview_vessel = vessel_by_name("jar_10L_220x305"); // by name, for the same reason assembly.scad is
// Derived the same way the assembly derives it, rather than naming a row: the shortest registered
// light that covers this jar's culture. 0.8 is head.scad's culture_fill_fraction, quoted rather
// than read because frame.scad does not depend on head.scad and should not start to for this.
_preview_light = strip_light_for(vessel_internal_height(_preview_vessel) * 0.8);
_preview_wall_thickness = 37;
_preview_flange_height = 8;
_preview_n_rods = 4;
_preview_bolt = M8_hex_screw;
// the head owns the gasket and hence the factor; standalone there is nobody to ask, so this is the
// soft-sheet value the registered EPDM gives
_preview_gasket_factor = 0.5;

_preview_bolt_circle = frame_bolt_circle_diameter(vessel_diameter(_preview_vessel));
_preview_posts = bolt_post_count(
  _preview_n_rods, screw_radius(_preview_bolt) * 2, _preview_bolt_circle,
  _preview_flange_height, _preview_gasket_factor
);

module lights(quadrants, vessel_outer_diameter, light, lights_per_quadrant, occupy_angle, allowance_cutout = undef) {
  for (q = quadrants) {
    rotate([0, 0, (q - 1) * 90]) {
      for (i = [0:lights_per_quadrant - 1]) {

        angle_offset = (90 - occupy_angle) / 2;
        light_angle =
          lights_per_quadrant == 1 ? 45
          : i * (occupy_angle / (lights_per_quadrant - 1)) + angle_offset;

        rotate([0, 0, light_angle])
          translate([0, vessel_outer_diameter / 2, 0]) if (is_undef(allowance_cutout)) {
            strip_light(light);
          } else {
            translate([0, strip_light_depth(light) / 2, strip_light_length(light) / 2])
              cube([strip_light_width(light) + allowance_cutout, strip_light_depth(light) + allowance_cutout, strip_light_length(light)], center=true);

            // same profile on its side, cut radially thru the wall so the cord can escape
            translate([0, vessel_outer_diameter / 2, (strip_light_depth(light) + allowance_cutout) / 2 - z_fight/2])
              cube([strip_light_width(light) + allowance_cutout, vessel_outer_diameter, strip_light_depth(light) + allowance_cutout], center=true);
          }
      }
    }
  }
}

module frame(vessel_height, vessel_outer_diameter, light, wall_thickness, lid_flange_height, n_rods, bolt_pts, bolt_screw, collapse_spacer_z_allow=true) {

  base_floor_height = frame_floor_depth(vessel_height, light);

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

  // ribs and spacers share one stack, so both read this rather than deriving it separately
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
  base_wall_thickness_from_lights = (strip_light_depth(light) * 1.5) * 2; // thinnest part is 50% thicker than the light depth

  base_wall_thickness_from_rod = threaded_rod_hole_diameter * 4; // thinnest part is 4x the rod diameter or approx x2 the nut diameter

  assert(
    wall_thickness >= max(base_wall_thickness_from_lights, base_wall_thickness_from_rod),
    str(
      "Base wall thickness is too thin. Must be at least ",
      max(base_wall_thickness_from_lights, base_wall_thickness_from_rod),
      " mm."
    )
  );

  // The rod is a diameter and the nut is a registered part, and nothing else makes the two agree.
  assert(
    nut_size(rod_nut) == threaded_rod_diameter,
    str("The rod is ", threaded_rod_diameter, " mm but its nut is an M", nut_size(rod_nut), ".")
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

  // every base closes on this face, and so does the lid flange above them
  _outer_diameter = frame_outer_diameter(vessel_outer_diameter, wall_thickness);

  echo("base wall thickness: ", _base_wall_thickness / 10, " cm");

  // WHAT THE LAYOUT COSTS TO BUY. The light count is a layout decision - which quadrants carry
  // lights and how many sit in each - and these do not come as tubes: one cord and controller
  // drives a fixed number. So a layout that is not a whole number of cords buys the next one up and
  // leaves the rest in the box, along with a controller it does not need.
  //
  // Reported rather than enforced, and the arrow points this way on purpose. How much light the
  // culture gets is an illumination question; letting the packaging answer it would be letting the
  // shop set the design. What this does is stop the purchase list being hand-counted.
  _light_total = len(light_quadrants) * lights_per_quadrant;
  _light_per_cord = strip_light_per_cord(light);
  _light_cords = ceil(_light_total / _light_per_cord);

  _light_spare = _light_cords * _light_per_cord - _light_total;

  echo(str(
    "lights: ", _light_total, " tube", _light_total == 1 ? "" : "s", " - ", lights_per_quadrant,
    " in each of ", len(light_quadrants), " quadrant", len(light_quadrants) == 1 ? "" : "s",
    " - on a light that comes ", _light_per_cord, " to a cord, so ", _light_cords, " cord",
    _light_cords == 1 ? "" : "s",
    _light_spare == 0
      ? " and nothing spare"
      : str(" and ", _light_spare, " tube", _light_spare == 1 ? "" : "s", " left over")
  ));

  module frame_lights(local_quadrants = light_quadrants) {
    lights(local_quadrants, vessel_outer_diameter, light, lights_per_quadrant, occupy_angle);
  }

  module frame_lights_cutout(local_quadrants = [1, 2, 3, 4]) {
    difference() {
      children();
      lights(local_quadrants, vessel_outer_diameter, light, lights_per_quadrant, occupy_angle, allowance_cutout=light_allow);
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
                nut(rod_nut);

            // pocketed in the top base, holding it as the fixed face the lid bolts to
            translate([0, 0, total_height - stack_slack - nut_height - z_fight])
              rotate([0, 0, 30])
                nut(rod_nut);

            // the rods are posts like the bolts, so they take a nut on top of the lid as well.
            // The lid sits on the rim, so this reads total_height, not the top base's face
            translate([0, 0, total_height + lid_flange_height])
              rotate([0, 0, 30])
                nut(rod_nut);
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
            cylinder(d=_outer_diameter, h=lower_base_height);

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
              cylinder(d=_outer_diameter, h=upper_base_height);

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

      // create the ribs, one level per rib level
      for (i = [1:n_rib_levels]) {

        rib_pos = lower_base_height + spacer_pitch * i - spacer_joint + rib_level_height * (i - 1);

        frame_lights_cutout()

        // a 2-rod base is a 90 degree arc, so the j pair leaves two gaps; k stacks a second
        // pair on the first pair's rod bosses, turned 90 to fill them
        for (j = [1:2], k = [0:ribs_per_level - 1])
          // Flat over the three loops, so an export can name one without knowing how they nest.
          if (is_undef(rib_to_render) || rib_to_render == ((i - 1) * 2 + (j - 1)) * ribs_per_level + k) {
          rotate([0, 0, j * 180 + k * 90])
            rotate([0, 0, i * 90])
              translate([0, 0, rib_pos + k * rib_base_height])
                color(prints1_color)
                  difference() {
                    union() {
                      rotate_extrude(angle=(n_rods_ribs - 1) * 90)
                        square([_outer_diameter / 2, rib_base_height]);

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

      // one spacer run under each rib level and one above the topmost, hence the extra
      color(prints2_color)for (i = [0:n_rib_levels]) {
        for (j = [0:n_rods - 1])
          if (is_undef(rodspacer_to_render) || rodspacer_to_render == i * n_rods + j) {

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
