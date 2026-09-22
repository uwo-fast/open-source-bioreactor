/**
 * @file frame.scad
 * @brief Frame subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

include <purchased/strip_lights.scad>;
include <purchased/vessels.scad>; // the preview builds against a registered jar, not copied numbers
include <purchased/fans.scad>; // the fan a magnetic drive turns under the jar, NopSCADlib's rows
include <purchased/magnets.scad>; // the magnets on its hub, NopSCADlib's rows

use <custom/magnet_hub_cap.scad>;

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
// The carrier that hangs the stirrer fan in the base bore, for a magnetic drive
render_stir_carrier = false;
// The cap on the fan hub that carries the magnets, for a magnetic drive
render_hub_cap = false;
// The fan, its screws and the magnets - bought, drawn where the carrier holds them
render_stir_fan = false;

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
base_jar_fit_allow = 0.6;

// the registered base corner radius is eyeballed, so this covers where the glass actually bears
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

/* [Stir Drive Parameters] */

// The base is cut for a magnetic drive whichever drive a build takes, so one base serves both: a
// fan in a carrier hung in the bore, magnets on its hub, and a slot that lets the lead out and
// keys the carrier. The fan is picked by rule from the bore, where one fits; the magnets are named.

// The magnets on the hub cap, two of them
stir_magnet_name = "MAG5x8"; // [MAG5x8, MAGRE6x2p5, MAG8x4x4p2, MAG484]
// allowance for the carrier to slide in the bore (diametral)
carrier_fit_allow = 0.4;
// wall the carrier keeps around the fan's corners
carrier_wall = 3;
// allowance for the fan to drop into its pocket
carrier_fan_allow = 0.4;
// Least material under the fan: the nut trap is sunk into it and what is left over the nut is
// what the screw clamps, so fan selection reserves this whole depth.
// least material under the fan, in mm
carrier_lip = 6;
// The fan's lead leaves at a corner of its frame, which sits on the pocket's wall rather than
// over the aperture, so the pocket is slotted out to the carrier's face on the flat nearest the
// ear: the lead leaves sideways, drops into the gap the ear holds under the carrier, and runs out
// through the groove.
// width of that notch, in mm
carrier_lead_width = 8;
// A fan's lead leaves anywhere along its frame, so the pocket wall on that flat is cut down to a
// seat: the wire reaches the notch from any point on that side, and the fan still lands on a
// complete outline.
// wall left at the bottom of the pocket where the lead crosses it, in mm
carrier_fan_seat = 3;
// The carrier's rim can stand over the fan, so the screw heads on it are not the highest thing in
// the bore - a dome head is 2.2 mm on M4. Off by default: the nuts are under the carrier where the
// ear leaves 8 mm, the heads clear the glass as they are, and every millimetre here is floor depth
// a shallow jar needs for its fan. The hub cap makes the height back up, so the magnets do not
// move whatever this is.
// how far the fan is recessed below the carrier's top, in mm
carrier_fan_recess = 0;
// The fan is bolted rather than screwed into its own plastic: its own screw down through it, and
// a nut held in a hex trap in the carrier's bottom face so one driver from above does the job.
// allowance on the trap's depth over the nut, in mm
carrier_nut_trap_allow = 0.2;
// clearance between the magnets' faces and the glass over them; sets how high the carrier hangs
stir_magnet_glass_clearance = 1;
// how far the key ear reaches into the base floor, radially
carrier_key_reach = 8;
// the shoulder each side of the wire groove that the ear lands on
carrier_key_shoulder = 3;
// allowance for the ear in its notch
carrier_key_allow = 0.4;

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

// The joint, read back so the lid is bored to the same circle, bore and face the frame builds.
function frame_rod_diameter() = threaded_rod_diameter;
function frame_upper_base_height() = upper_base_height;
function frame_rod_hole_diameter() = threaded_rod_diameter + threaded_rod_hole_allowance;
// The pocket the jar sits in, cut in the base, the top base and every rib; the allowance grows
// the outside rather than thinning the wall.
function frame_jar_cut_diameter(vessel_outer_diameter) = vessel_outer_diameter + base_jar_fit_allow;
// The rods stand one hole diameter outside the pocket's wall.
function frame_bolt_circle_diameter(vessel_outer_diameter) =
  frame_jar_cut_diameter(vessel_outer_diameter) + frame_rod_hole_diameter() * 2;
function frame_outer_diameter(vessel_outer_diameter, wall_thickness) =
  frame_jar_cut_diameter(vessel_outer_diameter) + wall_thickness;

// Every printed part the frame carries: [name, quantity, the flags that render it alone]. The
// other half of head_print_parts(); `just export-parts` walks both. The ribs are one part eight
// times - their exported meshes differ only by how the lights cutout tessellates at each rotation.
function frame_print_parts(n_rods, drive = "shaft") =
  concat(
    [
      ["frame_base", 1, "-D render_base=true"],
      ["frame_upper_base", 1, "-D render_upper_base=true"],
      ["frame_rib", n_rib_levels * 2 * (double_ribs ? 2 : 1), "-D render_ribs=true -D rib_to_render=0"],
      ["frame_rod_spacer", (n_rib_levels + 1) * n_rods, "-D render_rodspacers=true -D rodspacer_to_render=0"],
    ],
    // the drive's own two parts; the base is cut for them whichever drive a build takes
    drive == "magnetic"
      ? [
        ["frame_stir_carrier", 1, "-D render_stir_carrier=true"],
        ["frame_hub_cap", 1, "-D render_hub_cap=true"],
      ]
      : []
  );

// The bore under the jar: the ring the jar lands on, less what the floor reaches inboard of it.
// Read by the carrier, so it is derived here once rather than in frame() and again in a part.
function frame_center_bore_diameter(vessel) =
  (vessel_diameter(vessel) / 2 - vessel_corner_radius_base(vessel) - base_jar_support_reach) * 2;

// How far the frame reaches below the vessel's bottom: whatever a light, a nut and a half, and the
// top base stack to past the vessel's height. The bottom of the reactor's envelope.
_base_floor_height_min = 2; // minimum height of the base floor
function frame_floor_depth(vessel_height, light) =
  let (delta = (strip_light_length(light) + nut_height * 1.5 + upper_base_height) - vessel_height)
    delta > _base_floor_height_min ? delta : _base_floor_height_min;

// What the assembly would hand this frame. The preview picks what the assembly chooses (light,
// wall, flange, rods, bolt) and derives the rest. The 0.8 is a fraction of INTERNAL HEIGHT.
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

// Where light i of a quadrant's set sits, in degrees from the quadrant's start.
function light_angle(i, lights_per_quadrant, occupy_angle) =
  lights_per_quadrant == 1 ? 45
  : i * (occupy_angle / (lights_per_quadrant - 1)) + (90 - occupy_angle) / 2;

module lights(quadrants, vessel_outer_diameter, light, lights_per_quadrant, occupy_angle, allowance_cutout = undef) {
  for (q = quadrants) {
    rotate([0, 0, (q - 1) * 90]) {
      for (i = [0:lights_per_quadrant - 1]) {

        rotate([0, 0, light_angle(i, lights_per_quadrant, occupy_angle)])
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

module frame(vessel, light, wall_thickness, lid_flange_height, n_rods, bolt_pts, bolt_screw, drive = "shaft", magnet = undef, collapse_spacer_z_allow=true) {

  // The vessel's fields, read once.
  vessel_height = vessel_height(vessel);
  vessel_outer_diameter = vessel_diameter(vessel);
  vessel_corner_radius_base = vessel_corner_radius_base(vessel);

  base_floor_height = frame_floor_depth(vessel_height, light);

  // total height of the assembly
  total_height = vessel_height + base_floor_height;

  base_jar_cut_diameter = frame_jar_cut_diameter(vessel_outer_diameter);

  // The jar's underside dishes up from its base corner, so it lands on one circle and the floor
  // ring has to reach inboard of that. Cut from the jar, not from the wall.
  _jar_contact_radius = vessel_outer_diameter / 2 - vessel_corner_radius_base;
  _base_center_bore_diameter = frame_center_bore_diameter(vessel);

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

  // ----- stir drive -----
  // The slot takes the middle light position of the first quadrant without lights: its cord notch
  // is already cut through the wall, so the groove only has to cross the floor ring to the bore.
  _slot_quadrants = [for (q = [1:4]) if (len([for (l = light_quadrants) if (l == q) l]) == 0) q];
  _slot_quadrant = len(_slot_quadrants) > 0 ? _slot_quadrants[0] : undef;
  _slot_angle = is_undef(_slot_quadrant) ? undef
    : (_slot_quadrant - 1) * 90 + light_angle(floor(lights_per_quadrant / 2), lights_per_quadrant, occupy_angle);
  _slot_width = strip_light_width(light) + light_allow; // the cord notch's profile, continued
  _slot_height = strip_light_depth(light) + light_allow;

  // The carrier hangs from an ear that lands on the shoulders beside the groove, so its bottom is
  // the groove's ceiling and the lead runs under it to the groove. The fan is picked on the room
  // between that and the landing plane; how high it actually hangs is set by the magnets below.
  _magnet = is_undef(magnet) ? magnet_by_name(stir_magnet_name) : magnet;
  _carrier_diameter = _base_center_bore_diameter - carrier_fit_allow;
  _fan_room = base_floor_height - _slot_height - carrier_lip - carrier_fan_recess;
  // A fan whose hub cannot carry the magnets is no use however well it fits the bore.
  _fan = fan_for(_carrier_diameter - 2 * carrier_wall, _fan_room, hub_cap_min_hub(_magnet));
  _hub_cap_pitch = is_undef(_fan) ? undef : hub_cap_pitch(fan_hub(_fan), _magnet);
  _hub_cap_height = hub_cap_height(_magnet);

  // The jar's underside is flat across the punt plateau and a straight cone from there down to
  // the landing circle, so it is lowest over a magnet at the magnet's outer edge.
  _punt_plateau_radius = vessel_punt_width(vessel) / 2;
  function punt_under(r) =
    base_floor_height + vessel_punt_height(vessel) * (1 - max(0, r - _punt_plateau_radius) / (_jar_contact_radius - _punt_plateau_radius));
  _magnet_outer_radius = is_undef(_fan) ? undef : _hub_cap_pitch / 2 + magnet_od(_magnet) / 2;

  // The magnets reach up into the punt to their clearance, the cap stands on the hub and the
  // hub's face is the fan's, which is the carrier's top; never above the landing plane, since the
  // bore ends there.
  _magnet_top = is_undef(_fan) ? undef : punt_under(_magnet_outer_radius) - stir_magnet_glass_clearance;
  // _hub_cap_height is what the cap stands above the carrier's top face; the cap itself is that
  // plus the recess, since it stands on the fan rather than on the rim.
  _carrier_top = is_undef(_fan) ? undef : min(base_floor_height, _magnet_top - _hub_cap_height);
  _carrier_height = is_undef(_fan) ? undef : _carrier_top - _slot_height;
  _magnet_glass_gap = is_undef(_fan) ? undef : punt_under(_magnet_outer_radius) - (_carrier_top + _hub_cap_height);
  // and the fan's corners are the widest thing under the cone
  _fan_corner_gap = is_undef(_fan) ? undef : punt_under(fan_corner_diameter(_fan) / 2) - _carrier_top;

  // The fan's joint: its own screw through it, into a nut trapped under the carrier. The stack
  // the screw clamps is the fan and what is left of the carrier over the trap.
  _fan_screw = is_undef(_fan) ? undef : fan_screw(_fan);
  _fan_nut = is_undef(_fan) ? undef : screw_nut(_fan_screw);
  _nut_trap_depth = is_undef(_fan) ? undef : nut_thickness(_fan_nut) + carrier_nut_trap_allow;
  _fan_under = is_undef(_fan) ? undef : _carrier_height - fan_depth(_fan) - carrier_fan_recess;
  _nut_trap_ceiling = is_undef(_fan) ? undef : _fan_under - _nut_trap_depth;
  _fan_screw_length = is_undef(_fan) ? undef
    : screw_length(_fan_screw, fan_depth(_fan) + _nut_trap_ceiling, 0, nut=true);

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

  // every base closes on this face, and so does the lid flange above them
  _outer_diameter = frame_outer_diameter(vessel_outer_diameter, wall_thickness);

  echo("base wall thickness: ", wall_thickness / 10, " cm");

  echo("threaded rod length: ", rod_length, " mm");

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

  assert(
    !is_undef(_slot_quadrant),
    "Every quadrant carries lights, so there is no light position free for the stir drive's slot."
  );

  assert(
    !is_undef(_magnet),
    str("No registered magnet is named \"", stir_magnet_name, "\". See scad/purchased/magnets.scad.")
  );

  // The lead's notch runs through the ear on its way out, which leaves a leg each side.
  assert(
    is_undef(_fan) || _ear_legs > 0,
    str("The lead's ", carrier_lead_width, " mm notch leaves ", _ear_legs, " mm of ear each side of it.")
  );

  // The ear's notch is cut into the floor ring's top, so it has to stop short of where the jar lands.
  assert(
    _base_center_bore_diameter / 2 + carrier_key_reach < _jar_contact_radius,
    str(
      "The carrier's ear reaches r ", _base_center_bore_diameter / 2 + carrier_key_reach,
      " mm and the jar lands at r ", _jar_contact_radius, " mm."
    )
  );

  if (is_undef(_fan))
    echo(str(
      "WARNING stir drive: no registered fan clears a ", _carrier_diameter - 2 * carrier_wall,
      " mm pocket in ", _fan_room, " mm under this jar, so the base is not slotted and no carrier is drawn"
    ));
  else {
    // Hanging the magnets up to their clearance can pull the carrier down past the fan's room.
    assert(
      carrier_fan_seat < fan_depth(_fan),
      str("The pocket's seat is ", carrier_fan_seat, " mm of a ", fan_depth(_fan), " mm pocket, so the lead's relief cuts nothing.")
    );

    assert(
      _carrier_height - carrier_lip - carrier_fan_recess >= fan_depth(_fan),
      str(
        "The magnets hang the carrier ", _carrier_height, " mm tall and a ", fan_name(_fan), " recessed ",
        carrier_fan_recess, " mm over its ", carrier_lip, " mm lip wants ",
        fan_depth(_fan) + carrier_lip + carrier_fan_recess, "; a thinner cap or magnet, or less stir_magnet_glass_clearance."
      )
    );

    assert(
      _nut_trap_ceiling > 0,
      str(
        "An M", nut_size(_fan_nut), " nut trap ", _nut_trap_depth, " mm deep leaves ", _nut_trap_ceiling,
        " mm of carrier over it; recess the fan less, or take a thinner fan."
      )
    );

    echo(str(
      "fan joint: 4 x M", screw_radius(_fan_screw) * 2, " x ", _fan_screw_length,
      " mm down through the fan into nuts in ", _nut_trap_depth, " mm traps at the carrier's bottom face, ",
      _nut_trap_ceiling, " mm of carrier over them; the head stands ", screw_head_height(_fan_screw),
      " mm on the fan, ", carrier_fan_recess + _fan_corner_gap - screw_head_height(_fan_screw), " mm under the glass"
    ));

    assert(
      _fan_corner_gap >= stir_magnet_glass_clearance,
      str("The fan's corners come ", _fan_corner_gap, " mm under the punt cone; the magnets are set to clear it by ", stir_magnet_glass_clearance, ".")
    );

    echo(str(
      "stir drive: ", fan_name(_fan), " in a ", _carrier_diameter, " mm carrier ", _carrier_height,
      " mm tall, its top ", base_floor_height - _carrier_top, " mm under the landing plane, hung on its ear ",
      _slot_height, " mm off the bottom face; the fan is turned ", _fan_turn,
      " deg to put a flat on the slot's bearing, and the lead leaves its ", carrier_lead_width,
      " mm notch there for the ", _slot_width, " mm slot at ", _slot_angle, " deg"
    ));

    // What stands on the fan's top face has the recess plus what the cone leaves at the screws.
    echo(str(
      "fan fasteners: the fan is ", carrier_fan_recess, " mm under the carrier's top and the punt is ",
      punt_under(fan_hole_pitch(_fan) * sqrt(2)) - _carrier_top, " mm over it at the screw circle, so a head or a nut has ",
      carrier_fan_recess + punt_under(fan_hole_pitch(_fan) * sqrt(2)) - _carrier_top, " mm"
    ));

    echo(str(
      "stir magnets: 2 x ", magnet_designation(_magnet), " on the ", fan_hub(_fan), " mm hub at ", _hub_cap_pitch,
      " mm pitch, faces ", _magnet_glass_gap, " mm under the punt and ",
      _magnet_glass_gap + vessel_thickness(vessel), " mm from the floor inside"
    ));
  }

  // The slot, in the base's own frame: the wire groove is the cord notch's profile carried across
  // the floor ring to the bore, and above it the notch the ear drops down, a shoulder wider each
  // side so the ear lands on the groove's ceiling. Only cut where a fan fits, since it serves
  // the carrier and a floor too shallow for one is too shallow for the slot.
  // Both run from the axis: a face starting flat at the bore's radius leaves a sliver of the
  // bore's curve across the slot's edges, and everything inboard of the bore is void anyway.
  module frame_stir_slot() {
    rotate([0, 0, _slot_angle]) {
      translate([-_slot_width / 2, 0, -z_fight])
        cube([_slot_width, vessel_outer_diameter / 2 + z_fight, _slot_height + z_fight]);
      translate([-_slot_width / 2 - carrier_key_shoulder, 0, _slot_height])
        cube([_slot_width + 2 * carrier_key_shoulder, _base_center_bore_diameter / 2 + carrier_key_reach, base_floor_height - _slot_height + z_fight]);
    }
  }

  // The carrier: a cup the fan drops into from above and is screwed to from below, a notch the
  // lead leaves by, and the ear. Bottom at the groove's ceiling, where the ear lands. Under the
  // fan it is solid but for the fan's own holes: the ear holds the whole part clear of the
  // bottom face, so the lead has that gap to run in and a hollow here would only be a roof to
  // bridge.
  // A flat onto the slot's bearing, so the lead leaves there and drops straight into the groove.
  // The square repeats every 90 degrees, which is the whole of the turn.
  _fan_turn = is_undef(_slot_angle) ? undef : _slot_angle % 90;
  _ear_legs = (_slot_width + 2 * carrier_key_shoulder - carrier_key_allow - carrier_lead_width) / 2;

  module frame_stir_carrier() {
    _fan_r = fan_width(_fan) / 2 - fan_hole_pitch(_fan); // the frame's corner radius
    _fan_flat = fan_width(_fan) - 2 * _fan_r; // the straight run of one side, between the corners
    _pocket_floor = _carrier_height - fan_depth(_fan) - carrier_fan_recess;
    _ear_width = _slot_width + 2 * carrier_key_shoulder - carrier_key_allow;
    _ear_reach = carrier_fit_allow / 2 + carrier_key_reach - carrier_key_allow; // past the carrier's face

    translate([0, 0, _slot_height])
      difference() {
        union() {
          cylinder(d=_carrier_diameter, h=_carrier_height);
          // the ear's section, radial out and up: a block at the edge, rising at 45 deg to the wall
          rotate([0, 0, _slot_angle])
            translate([-_ear_width / 2, _carrier_diameter / 2 - carrier_wall, 0])
              rotate([90, 0, 90]) // the section's x radial, its y up, extruded across the width
                linear_extrude(_ear_width)
                  polygon([
                    [0, 0],
                    [carrier_wall + _ear_reach, 0],
                    [carrier_wall + _ear_reach, _slot_height],
                    [carrier_wall, _slot_height + _ear_reach],
                    [0, _slot_height + _ear_reach],
                  ]);
        }

        // the pocket, the fan's own outline with its corners, turned with the fan
        translate([0, 0, _pocket_floor])
          rotate([0, 0, _fan_turn])
            linear_extrude(fan_depth(_fan) + carrier_fan_recess + z_fight)
              offset(r=_fan_r + carrier_fan_allow / 2)
                square(fan_width(_fan) - 2 * _fan_r, center=true);

        // The fan's own holes, cut clean through what is under it: the four screw holes, so a
        // screw and a driver reach the fan from below, and the aperture with them. Vertical, so
        // nothing bridges.
        translate([0, 0, _pocket_floor / 2])
          rotate([0, 0, _fan_turn])
            fan_holes(_fan, screws=false, h=_pocket_floor + z_fight);

        // and at each corner, the screw's clearance hole with a hex trap for its nut, open at the
        // bottom face so the nut goes in before the fan does
        rotate([0, 0, _fan_turn])
          fan_hole_positions(_fan, z=0)
            nut_trap(_fan_screw, _fan_nut, depth=_nut_trap_depth);

        // The lead's notch: a slot from the fan's flat out to the carrier's face, the full
        // height of the part, so the wire leaves the pocket sideways and drops straight into the
        // groove below. It starts at the flat because _fan_turn put one there. Cut in vertical
        // walls, so it prints without an overhang, and it splits the ear into two legs on the
        // way past.
        rotate([0, 0, _slot_angle])
          translate([-carrier_lead_width / 2, fan_width(_fan) / 2, -z_fight])
            cube([carrier_lead_width, _carrier_diameter / 2, _carrier_height + 2 * z_fight]);

        // and the wall above the seat, across the flat's straight run, so the lead reaches the
        // notch from wherever it leaves the fan. The corners are left alone: cutting past them
        // would step the pocket's own radius out into the relief.
        rotate([0, 0, _slot_angle])
          translate([
            -_fan_flat / 2,
            fan_width(_fan) / 2,
            _pocket_floor + carrier_fan_seat,
          ])
            cube([_fan_flat, carrier_lead_width, _carrier_height - _pocket_floor - carrier_fan_seat + z_fight]);
      }
  }

  // The fan's face sits the recess under the carrier's top, and the cap stands on its hub, so
  // the cap is the recess taller and the magnets land where they would have anyway.
  _fan_top = is_undef(_fan) ? undef : _slot_height + _carrier_height - carrier_fan_recess;

  // The bought parts: the fan in its pocket (drawn centred, so lifted by half its depth), its
  // screws from below, and the magnets in the cap's pockets.
  module frame_stir_fan() {
    translate([0, 0, _fan_top - fan_depth(_fan) / 2])
      rotate([0, 0, _fan_turn]) {
        fan(_fan);
        // the screws from the fan's own face, down through the carrier to the nuts under it
        fan_hole_positions(_fan, z=fan_depth(_fan) / 2)
          screw(_fan_screw, _fan_screw_length);
      }
    // the nuts, in their traps at the carrier's bottom face
    translate([0, 0, _slot_height])
      rotate([0, 0, _fan_turn])
        fan_hole_positions(_fan, z=0)
          nut(_fan_nut);
    translate([0, 0, _fan_top])
      magnet_hub_cap(fan_hub(_fan), _magnet, pedestal=carrier_fan_recess, cap=false, magnets=true);
  }

  module frame_hub_cap() {
    translate([0, 0, _fan_top])
      color(prints2_color)
        magnet_hub_cap(fan_hub(_fan), _magnet, pedestal=carrier_fan_recess);
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

            if (!is_undef(_fan))
              frame_stir_slot();

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

    // the magnetic drive, drawn only when a build takes it; the slot above is cut regardless
    _drive_shown = drive == "magnetic" && render_all;
    if (!is_undef(_fan)) {
      if (render_stir_carrier || _drive_shown)
        color(prints2_color)
          frame_stir_carrier();
      if (render_hub_cap || _drive_shown)
        frame_hub_cap();
      if (render_stir_fan || _drive_shown)
        frame_stir_fan();
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
          // Each level turns 90, which would put the pair carrying the empty light pockets under
          // the other pair's bosses on even levels; the stacking order flips with it, so that
          // pair is the upper ring at every level and a pump mount can drop into any pocket.
          rotate([0, 0, j * 180 + k * 90])
            rotate([0, 0, i * 90])
              translate([0, 0, rib_pos + ((i + k + 1) % 2) * rib_base_height])
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
                            cylinder(d=wall_thickness, h=rib_base_height);
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
