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

// Internals, not build choices.
/* [Hidden] */
z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

/* [Part Render Selection] */

// a per-part export turns this off before a part's own flag on, which is what the manifest does
// Everything at once, the assembly picture; overrides every flag below
render_all = true;
// The lower base, which the jar stands in
render_base = false;
// The upper base, which the lid bolts to
render_upper_base = false;
// The rib stack that ties the rods between the two bases
render_ribs = false;
// Which rib, in emission order, for a per-part export; undef renders the set in place
rib_to_render = undef;
// The threaded rods themselves - bought, so a vitamin rather than a part
render_rods = false;
// The printed annuli that set the gap between rib levels on each rod
render_rodspacers = false;
// three runs of four, all one part, so a per-part export wants any single one
// Which rod spacer, for a per-part export; undef renders them all
rodspacer_to_render = undef;
// The strip lights, bought and drawn where they sit in their pockets
render_lights = false;

/* [Vessel Selection] */

// Which jar this frame is for; a parameter set names it, so it must be a name and not a row
reactor_vessel_name = "jar_10L_220x305"; // [jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]
// resolved from the name, not chosen
/* [Hidden] */
reactor_vessel = vessel_by_name(reactor_vessel_name);

assert(
  !is_undef(reactor_vessel),
  str("No registered vessel is named \"", reactor_vessel_name, "\". See scad/purchased/vessels.scad.")
);

// -------

frame(
  vessel=reactor_vessel,
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

// Derived from the nut, so not choices.
/* [Hidden] */
nut_pocket_diameter = 2 * nut_radius(rod_nut) + nut_pocket_allowance;
nut_height = nut_thickness(rod_nut);

/* [Base Parameters] */

// allowance for the jar to fit in the base
base_jar_fit_allow = 0.4;

// reasoned, not cited: the registered base corner radius is eyeballed, so this covers where the
// glass actually bears
// How far the base floor reaches inboard of the circle the jar lands on, in mm
base_jar_support_reach = 15;

// height of the bottom base (holding jar)
lower_base_wall_height = 25;
// height of the top base (holding lid)
upper_base_height = 10;
// height of the rib base
rib_base_height = 10;
// stack a second rib at each level, rotated to close the arc the pair below leaves open
double_ribs = true;
// up here rather than inside frame() because frame_print_parts() has to count the ribs
// How many rib levels the stack carries
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

// The joint, read back by bioreactor.scad so the lid is bored to the same circle, bore and face
// the frame builds. The top base height is exported because the bolt spacing rule is driven by
// the thinner of the two plates in the joint.
function frame_rod_diameter() = threaded_rod_diameter;
function frame_upper_base_height() = upper_base_height;
function frame_rod_hole_diameter() = threaded_rod_diameter + threaded_rod_hole_allowance;
function frame_bolt_circle_diameter(vessel_outer_diameter) =
  (vessel_outer_diameter + base_jar_fit_allow) + frame_rod_hole_diameter() * 2;
// The pocket carries the fit allowance, so the allowance grows the outside rather than thinning
// the wall.
function frame_outer_diameter(vessel_outer_diameter, wall_thickness) =
  (vessel_outer_diameter + base_jar_fit_allow) + wall_thickness;

// Every printed part the frame carries: [name, quantity, the flags that render it alone]. The
// other half of head_print_parts(); `just export-parts` walks both. The ribs are one part eight
// times - their exported meshes differ only by how the lights cutout tessellates at each rotation.
function frame_print_parts(n_rods) =
  [
    ["frame_base", 1, "-D render_base=true"],
    ["frame_upper_base", 1, "-D render_upper_base=true"],
    ["frame_rib", n_rib_levels * 2 * (double_ribs ? 2 : 1), "-D render_ribs=true -D rib_to_render=0"],
    ["frame_rod_spacer", (n_rib_levels + 1) * n_rods, "-D render_rodspacers=true -D rodspacer_to_render=0"],
  ];

// How far the frame reaches below the vessel's bottom: whatever a light, a nut and a half, and the
// top base stack to past the vessel's height. The bottom of the reactor's envelope.
_base_floor_height_min = 2; // minimum height of the base floor
function frame_floor_depth(vessel_height, light) =
  let (delta = (strip_light_length(light) + nut_height * 1.5 + upper_base_height) - vessel_height)
    delta > _base_floor_height_min ? delta : _base_floor_height_min;

// What the assembly would hand this frame. The preview picks what the assembly chooses (light,
// wall, flange, rods, bolt) and derives the rest. The 0.8 is a fraction of INTERNAL HEIGHT, not
// head.scad's culture_fill_fraction (a fraction of capacity); they agree only on jar_10L, and the
// restatement is deliberate so frame.scad does not read head.scad for a preview.
_preview_light = strip_light_for(vessel_internal_height(reactor_vessel) * 0.8);
_preview_wall_thickness = 37;
_preview_flange_height = 8;
_preview_n_rods = 4;
_preview_bolt = M8_hex_screw;
// the head owns the gasket factor; standalone this is the soft-sheet value the registered EPDM gives
_preview_gasket_factor = 0.5;

_preview_bolt_circle = frame_bolt_circle_diameter(vessel_diameter(reactor_vessel));
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

// Where a tie rod stands and which way its features face. Places children rather than returning
// points because the nut pockets are slots and have to be oriented.
module frame_rod_at(i, n_rods, rod_shift) {
  rotate([0, 0, i * 360 / n_rods])
    translate([rod_shift, 0, 0])
      children();
}

module frame(vessel, light, wall_thickness, lid_flange_height, n_rods, bolt_pts, bolt_screw, collapse_spacer_z_allow=true) {

  // The vessel's fields, read once.
  vessel_height = vessel_height(vessel);
  vessel_outer_diameter = vessel_diameter(vessel);
  vessel_corner_radius_base = vessel_corner_radius_base(vessel);

  base_floor_height = frame_floor_depth(vessel_height, light);

  // total height of the assembly
  total_height = vessel_height + base_floor_height;

  // diameter of the cutout for the jar
  base_jar_cut_diameter = vessel_outer_diameter + base_jar_fit_allow;

  // The jar's underside dishes up from its base corner, so it lands on one circle and the floor
  // ring has to reach inboard of that. Cut from the jar, not from the wall.
  _jar_contact_radius = vessel_outer_diameter / 2 - vessel_corner_radius_base;
  _base_center_bore_diameter = (_jar_contact_radius - base_jar_support_reach) * 2;

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

  // Where rib level i (1-based) starts: on the spacer run below it and the levels under that.
  function rib_level_bottom(i) = lower_base_height + spacer_pitch * i - spacer_joint + rib_level_height * (i - 1);

  // The light pockets end at the light's length, and the cutout runs through every rib level and
  // the top base. A pocket that ends inside one leaves a lip of it across a slot that wants to be
  // through, so where the pocket ends is held against each of them.
  _pocket_top = strip_light_length(light);
  _pocketed = concat(
    [for (i = [1:n_rib_levels]) [str("rib level ", i), rib_level_bottom(i), rib_level_bottom(i) + rib_level_height]],
    [["top base", total_height - stack_slack - upper_base_height, total_height - stack_slack]]
  );
  _pocket_lip = [for (p = _pocketed) if (_pocket_top > p[1] && _pocket_top < p[2]) p];
  _pocket_next = [for (p = _pocketed) if (_pocket_top <= p[1]) p];

  // The lid is located by the rim and the top base by the stack below it, so stack_slack is the
  // gap between them that lets the bolts pull the lid into the vessel. Every span crossing the
  // joint counts it.
  bolt_length = screw_length(bolt_screw, upper_base_height + stack_slack + lid_flange_height, 0, nut=true);

  // From the base floor to a nut on top of the lid, which is on the rim datum.
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

  // The nut pocket is sunk into the top base's underside, so the base has to be deeper than the nut.
  assert(
    upper_base_height > nut_height,
    str("Top base is ", upper_base_height, " mm with a ", nut_height, " mm nut pocket sunk in it.")
  );

  // Without the gap the lid bottoms on the frame instead of seating on the glass. Conditional
  // because this file's own preview passes collapse_spacer_z_allow=false, which sets it to 0.
  assert(
    !collapse_spacer_z_allow || stack_slack > 0,
    str("The lid-to-top-base gap is ", stack_slack, " mm; the bolts cannot clamp the lid into the vessel without it.")
  );

  assert(
    _base_center_bore_diameter > 0,
    str(
      "The jar lands on the base floor at r ", _jar_contact_radius, " mm and the ring is asked to reach ",
      base_jar_support_reach, " mm inboard of that, which is past the axis."
    )
  );

  _base_wall_thickness = wall_thickness;

  // every base closes on this face, and so does the lid flange above them
  _outer_diameter = frame_outer_diameter(vessel_outer_diameter, wall_thickness);

  echo("base wall thickness: ", _base_wall_thickness / 10, " cm");

  echo(
    "base floor: jar lands at r", _jar_contact_radius, "mm, ring spans r",
    _base_center_bore_diameter / 2, "to r", base_jar_cut_diameter / 2, "mm"
  );

  echo(str(
    "light pockets: end at z ", _pocket_top, "; ",
    len(_pocket_lip) > 0
      ? str("inside the ", _pocket_lip[0][0], ", leaving a ", _pocket_lip[0][2] - _pocket_top, " mm lip of it across a blind slot")
      : len(_pocket_next) > 0
        ? str("stopping ", _pocket_next[0][1] - _pocket_top, " mm under the ", _pocket_next[0][0])
        : "through every rib level and the top base"
  ));

  if (len(_pocket_lip) > 0)
    echo(str(
      "WARNING light pockets: the ", _pocket_lip[0][0], " keeps a ", _pocket_lip[0][2] - _pocket_top,
      " mm lip over a ", _pocket_top, " mm light; a longer light or a lower stack clears it"
    ));

  // Lights come as a fixed number to a cord, so a layout that is not a whole number of cords buys
  // the next one up. Reported, so the purchase list is not hand-counted; never enforced.
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

  // z = 0 is the bottom of the vessel, so the whole frame drops by its floor
  translate([0, 0, -base_floor_height - z_fight]) {
    if (render_lights || render_all) {
      frame_lights();
    }

    // rods and nuts
    if (render_rods || render_all) {
      for (i = [0:n_rods - 1]) {
        frame_rod_at(i, n_rods, rod_shift) {

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
              cylinder(d=_base_center_bore_diameter, h=lower_base_height + z_fight);

            for (i = [0:n_rods - 1]) {
              _nut_pocket_height = nut_height * 1.1;
              frame_rod_at(i, n_rods, rod_shift) {
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
                frame_rod_at(i, n_rods, rod_shift) {
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

        rib_pos = rib_level_bottom(i);

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
