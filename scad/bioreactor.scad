/**
 * @file bioreactor.scad
 * @brief Assembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The reactor is a purchased glass jar (purchased/vessel.scad), a head (head.scad: lid, drive,
 * ports) and a frame (frame.scad: bases, ribs, rods, lights). This file carries two kinds of
 * parameter and nothing else - see docs/architecture.md.
 *
 * CROSS-COUPLING: what two subassemblies must agree on, derived once here and handed down.
 *   vessel -> head, frame   the registered row
 *   light  -> frame   the registered strip light row
 *   drive  -> head, frame   shaft or magnetic: the head loses its drive stack, the frame hangs the fan
 *   head  <-> frame   the joint: lid_flange_height (chosen here), the bolt circle, the bore and
 *                     the outer face (read back from frame.scad), and the post pattern
 *   head   -> here    head_gasket_factor(), which sets the joint's bolt count
 *
 * BUILD DESIGNATIONS: the choices an operator states per reactor. They live here because a
 * customizer parameter set can only assign parameters of the file being rendered. Each names a
 * registered row by its STRING name, resolved once below; "auto" means the subassembly derives
 * it, and only stated departures are passed down.
 */

include <purchased/vessels.scad>;
include <purchased/strip_lights.scad>;
include <purchased/printers.scad>;
include <purchased/stir_bars.scad>;
include <purchased/magnets.scad>;

use <utils/bolt_pattern.scad>;
use <utils/elastomer.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/screws.scad>; // M8_hex_screw type

use <head.scad>;
use <frame.scad>;

/* [Part Render Selection] */

// The glass jar, translucent, so what the printed parts have to fit is visible
render_vessel = true;
// The head subassembly: lid, ports, drive, impellers, sparger
render_head = false;
// The frame subassembly: bases, ribs, rods, spacers, lights
render_frame = false;
// Overrides the three above, which is the whole reactor as a picture
render_all = true;
// Export a part where head.scad would have put it, not at its assembled height (see `just export-parts`)
export_at_origin = false;

/* [Rendering Parameters] */

// $fn is zero unless something assigns it, and frame.scad takes the caller's. head.scad sets its
// own from $fa/$fs and re-asserts it inside head(), so this cannot reach it - see utils/facets.scad.
$fn = $preview ? 64 : 128;

// Cut the preview in half to see inside; ignored on a render
cross_section_active = true;

/* [Vessel Selection] */

// Which jar this build is for; a parameter set names it, so it must be a name and not a row
reactor_vessel_name = "jar_10L_220x305"; // [jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]

/* [Light Strip Selection] */

// The strip light; auto takes the shortest row that covers the culture
strip_light_name = "auto"; // [auto, RWNTAO 13in, grow 13in, grow 16in, grow 8.6in]

/* [Head Parameters - Coupling] */

// Height of the lid flange, vessel rim to the top of the lid, in mm
lid_flange_height = 8;
// Wall the frame carries outboard of its jar pocket, in mm (diametral)
frame_wall_thickness = 37;

/* [Head to Frame Joint] */

// How many tie rods run the assembly; they are posts on the bolt circle too
n_rods = 4;
// M8 is the cap: NopSCADlib's screw rows stop there, and the joint's only load is seating the
// gasket - a few hundred newtons a post, 1.7 kN on the widest jar - which an M8 carries many
// times over. A jar that wants more should look at the gasket width first (lid_gasket_width_max).
// The fastener clamping the lid flange to the top base
joint_bolt = M8_hex_screw;

/* [Build] */

// Fraction of the jar's CAPACITY the culture fills; a run at another volume states its fraction
culture_fill_fraction = 0.865;
// What turns the culture: a shaft through the lid, or a stir bar following a fan under the base
drive_name = "shaft"; // [shaft, magnetic]
// The stir bar a magnetic drive turns; auto takes the head's own row
stir_bar_name = "auto"; // [auto, 25x8, 38x8, 50x8]
// The magnets on the fan hub, two; auto takes the frame's own row
stir_magnet_name = "auto"; // [auto, MAG5x8, MAGRE6x2p5, MAG8x4x4p2, MAG484]
// The impeller shaft; auto takes the shortest row that reaches this vessel
shaft_name = "auto"; // [auto, 8x200_316, 8x400_316, 8x600_316, 8x800_316]
// The ring centring the lid plug; auto takes one this mouth can stretch onto
plug_oring_name = "auto"; // [auto, 4x1.5 EPDM, 11x1.5 EPDM, 12x1.5 EPDM, 13x1.5 EPDM, 14x1.5 EPDM, 15x1.5 EPDM, 16x1.5 EPDM, 17x1.5 EPDM, 18x1.5 EPDM, 20x1.5 EPDM, 22x1.5 EPDM, 23x1.5 EPDM, 24x1.5 EPDM, 25x1.5 EPDM, 28x1.5 EPDM, 30x1.5 EPDM, AS568-150, AS568-151, AS568-152, AS568-153, AS568-154, AS568-155, AS568-156, AS568-157, AS568-158, AS568-159, AS568-160, AS568-161, AS568-162, AS568-163, AS568-164, AS568-165, AS568-166, AS568-167, AS568-168, AS568-169, AS568-170, AS568-171]
// The drive motor; auto takes the head's own registered row
motor_name = "auto"; // [auto, 36GP-3530-5.18, 36PG-3429-5.2, 36PG-555PM-14-EN, 12v_5w]
// The lid's rim gasket stock; auto takes the head's own registered sheet
gasket_sheet_name = "auto"; // [auto, EPDM 1/16 60A]
// Any registered Atlas row is accepted in either port, EC and ORP included; the fit checks run on
// whatever is named, but the DO-specific reports assume a galvanic DO probe.
// The probe in the DO port; auto takes whatever the port table carries
do_probe_name = "auto"; // [auto, pH mini, pH con, pH lab g1, pH lab g2, pH res, DO mini, DO lab g1, DO lab g2, EC mini K1.0, EC K0.1, EC K1.0, EC K10, EC K0.1 8cm, ORP mini, ORP con, ORP lab, ORP gold]
// The probe in the pH port; auto takes whatever the port table carries
ph_probe_name = "auto"; // [auto, pH mini, pH con, pH lab g1, pH lab g2, pH res, DO mini, DO lab g1, DO lab g2, EC mini K1.0, EC K0.1, EC K1.0, EC K10, EC K0.1 8cm, ORP mini, ORP con, ORP lab, ORP gold]
// The lean is always derived - the most of this the jar's internals allow - so this can only ask
// for less. It leans to shed bubbles off a galvanic membrane; 4.5 is reasoned, not cited.
// Ceiling on how far the DO probe leans out, in degrees
do_probe_port_tilt_max = 4.5;

// Resolved from the parameters above, not inputs.
/* [Hidden] */

// Each designation resolves once, here. registry_by_name returns undef for a name nothing answers
// to and for one two rows answer to, so the assert says both. A failing assert exits 0, so the
// ERROR line on stderr is the only thing the checks can catch.
reactor_vessel = vessel_by_name(reactor_vessel_name);

assert(
  !is_undef(reactor_vessel),
  str("No registered vessel is named \"", reactor_vessel_name, "\". See scad/purchased/vessels.scad.")
);

_build_shaft = shaft_name == "auto" ? undef : shaft_by_name(shaft_name);
assert(
  shaft_name == "auto" || !is_undef(_build_shaft),
  str("No registered shaft is named \"", shaft_name, "\", or it is registered twice. See scad/purchased/shafts.scad.")
);

_build_plug_oring = plug_oring_name == "auto" ? undef : oring_by_name(plug_oring_name);
assert(
  plug_oring_name == "auto" || !is_undef(_build_plug_oring),
  str("No registered o-ring is named \"", plug_oring_name, "\", or it is registered twice. See scad/purchased/orings.scad.")
);

_build_motor = motor_name == "auto" ? undef : dc_motor_by_name(motor_name);
assert(
  motor_name == "auto" || !is_undef(_build_motor),
  str("No registered motor is named \"", motor_name, "\", or it is registered twice. See scad/purchased/dc_motors.scad.")
);

_build_gasket_sheet = gasket_sheet_name == "auto" ? undef : gasket_sheet_by_name(gasket_sheet_name);
assert(
  gasket_sheet_name == "auto" || !is_undef(_build_gasket_sheet),
  str("No registered gasket sheet is named \"", gasket_sheet_name, "\", or it is registered twice. See scad/purchased/gasket_sheets.scad.")
);

// Gasket factor m for the lid seal, read back from the sheet: a harder sheet wants more bolts.
lid_gasket_factor = head_gasket_factor(_build_gasket_sheet);

_build_do_probe = do_probe_name == "auto" ? undef : atlas_probe_by_name(do_probe_name);
assert(
  do_probe_name == "auto" || !is_undef(_build_do_probe),
  str("No registered Atlas probe is named \"", do_probe_name, "\", or it is registered twice. See scad/purchased/atlas_probes.scad.")
);

_build_ph_probe = ph_probe_name == "auto" ? undef : atlas_probe_by_name(ph_probe_name);
assert(
  ph_probe_name == "auto" || !is_undef(_build_ph_probe),
  str("No registered Atlas probe is named \"", ph_probe_name, "\", or it is registered twice. See scad/purchased/atlas_probes.scad.")
);

_build_stir_bar = stir_bar_name == "auto" ? undef : stir_bar_by_name(stir_bar_name);
assert(
  stir_bar_name == "auto" || !is_undef(_build_stir_bar),
  str("No registered stir bar is named \"", stir_bar_name, "\", or it is registered twice. See scad/purchased/stir_bars.scad.")
);

_build_magnet = stir_magnet_name == "auto" ? undef : magnet_by_name(stir_magnet_name);
assert(
  stir_magnet_name == "auto" || !is_undef(_build_magnet),
  str("No registered magnet is named \"", stir_magnet_name, "\", or it is registered twice. See scad/purchased/magnets.scad.")
);

_build_light = strip_light_name == "auto" ? undef : strip_light_by_name(strip_light_name);
assert(
  strip_light_name == "auto" || !is_undef(_build_light),
  str("No registered strip light is named \"", strip_light_name, "\", or it is registered twice. See scad/purchased/strip_lights.scad.")
);

// Pairs, not a positional row: each is optional, and an explicit undef ("derive it") has to stay
// distinguishable from not naming it. head_build() reads them.
reactor_build = [
  ["culture_fill_fraction", culture_fill_fraction],
  ["head_shaft", _build_shaft],
  ["lid_plug_oring", _build_plug_oring],
  ["do_probe_port_tilt_max", do_probe_port_tilt_max],
  ["head_motor", _build_motor],
  ["lid_gasket_sheet", _build_gasket_sheet],
  ["do_probe", _build_do_probe],
  ["ph_probe", _build_ph_probe],
  ["drive", drive_name],
  ["stir_bar", _build_stir_bar],
];

_reactor_light = is_undef(_build_light)
  ? strip_light_for(head_liquid_height(vessel_internal_height(reactor_vessel), vessel_inner_profile(reactor_vessel), culture_fill_fraction))
  : _build_light;

assert(
  !is_undef(_reactor_light),
  "No strip light is registered, so nothing can light the vessel. See scad/purchased/strip_lights.scad."
);

// A designated light skips the coverage test "auto" selects on. Echoed, not asserted: an under-lit
// reactor is buildable.
_culture_depth = head_liquid_height(vessel_internal_height(reactor_vessel), vessel_inner_profile(reactor_vessel), culture_fill_fraction);
if (strip_light_length(_reactor_light) < _culture_depth)
  echo(str(
    "WARNING lights: ", strip_light_name(_reactor_light), " is ", strip_light_length(_reactor_light),
    " mm and the culture stands ", _culture_depth, " mm deep, so ",
    _culture_depth - strip_light_length(_reactor_light), " mm of it is unlit; auto would take the shortest row that covers it"
  ));

module dummy() {
  // stop the customizer detection from here onwards
}

// The joint, derived once: the top base and the lid flange are bored from the same pattern.
joint_bolt_circle = frame_bolt_circle_diameter(vessel_diameter(reactor_vessel));
// Every post is bored to the rod's clearance, bolts included: the plug locates the lid radially,
// so the bolt positions are deliberately loose.
joint_hole_diameter = frame_rod_hole_diameter();
// The face the joint presents, which the head builds its flange to exactly.
joint_outer_diameter = frame_outer_diameter(vessel_diameter(reactor_vessel), frame_wall_thickness);
// ASME's spacing rule divides by the flange thickness, so the thinner of the two plates governs.
_joint_plate = min(lid_flange_height, frame_upper_base_height());
joint_posts = bolt_post_count(n_rods, screw_radius(joint_bolt) * 2, joint_bolt_circle, _joint_plate, lid_gasket_factor);

assert(
  bolt_post_spacing(joint_posts, joint_bolt_circle) >= screw_radius(joint_bolt) * 5, // 2.5x nominal, enough to get a wrench in
  str("Bolt spacing of ", bolt_post_spacing(joint_posts, joint_bolt_circle), " mm is too tight to get a wrench on.")
);

// The bore never reads the screw, so thinning the rod would take the bolt holes down with it.
assert(
  joint_hole_diameter >= screw_clearance_radius(joint_bolt) * 2,
  str(
    "The joint is bored ", joint_hole_diameter, " mm from the rod's allowance, but an M",
    screw_radius(joint_bolt) * 2, " bolt needs ", screw_clearance_radius(joint_bolt) * 2, " mm to pass."
  )
);

echo(str("joint: ", joint_posts, " posts at ", bolt_post_spacing(joint_posts, joint_bolt_circle), " mm on a ", joint_bolt_circle, " mm circle"));

// The rod and the bolt are set in different files; a mismatch is allowed but worth saying.
_rod_d = frame_rod_diameter();
_bolt_d = screw_radius(joint_bolt) * 2;
if (_rod_d != _bolt_d)
  echo(str(
    "WARNING joint: M", _rod_d, " rod but M", _bolt_d, " bolts in a ", joint_hole_diameter,
    " mm bore cut for the rod, leaving the bolts ", joint_hole_diameter - screw_clearance_radius(joint_bolt) * 2,
    " mm of slop; run the bolts at M", _rod_d, " to match"
  ));

// The head owns the gasket so it owns the force; the count is this file's. See utils/elastomer.scad.
_seating_force = head_gasket_seating_force(
  vessel_opening_diameter(reactor_vessel), vessel_thickness(reactor_vessel),
  _build_gasket_sheet, vessel_rim_arc_radius(reactor_vessel)
);
echo(str(
  "joint load: ", _seating_force, " N of gasket seating over ", joint_posts, " posts = ",
  _seating_force / joint_posts, " N each, on M", _bolt_d, " bolts and M", _rod_d, " rods"
));

// The bench instruction is a turn past snug, not a torque: the gasket's travel over the thread's
// pitch has no friction coefficient in it, and the glass is what limits this joint anyway.
_joint_pitch = bolt_coarse_pitch(_bolt_d);

assert(
  !is_undef(_joint_pitch),
  str("No coarse pitch is listed for an M", _bolt_d, " joint bolt - see utils/bolt_pattern.scad.")
);

echo(str(
  "joint tightening: ", 360 * head_gasket_travel(_build_gasket_sheet) / _joint_pitch,
  " deg past snug on each of the ", joint_posts, " nuts (", head_gasket_travel(_build_gasket_sheet),
  " mm of gasket travel on a ", _joint_pitch, " mm pitch); the printed flange creeps, so go back to them"
));

// The assembled envelope, for anything that has to make room for one (support/equipment_cart.scad).
function reactor_envelope_diameter() = joint_outer_diameter; // the flange circle IS the envelope
function reactor_envelope_height() =
  frame_floor_depth(vessel_height(reactor_vessel), _reactor_light)
  + vessel_height(reactor_vessel) + lid_flange_height
  + head_stack_height(lid_flange_height, vessel_internal_height(reactor_vessel), _build_shaft, _build_motor, drive_name);

echo(str("reactor envelope: ", reactor_envelope_diameter(), " mm dia x ", reactor_envelope_height(), " mm tall"));

// The lid and both frame bases are discs of the joint's outer diameter, the widest parts by far,
// and only this file sees both halves. A disc wants min(x, y) of the bed, not printer_fits().
// Height is not checked: every registered printer has 250 mm of Z against a tallest part of ~163.
_widest_printed = joint_outer_diameter;
_printers_fitting = [for (p = printers) if (printer_max_disc(p) >= _widest_printed) printer_name(p)];

echo(str("printers: the widest printed part is a ", _widest_printed, " mm disc (lid, base, top base); registered printers that take it: ", _printers_fitting));

if (len(_printers_fitting) == 0)
  echo(str("WARNING printers: no registered printer takes a ", _widest_printed, " mm disc; see scad/purchased/printers.scad"));

// The vessel sections itself by revolving through 180 degrees, keeping +y; the head is cut to the
// same half. Preview only: a part exported half-cut would be silently wrong.
_section_active = cross_section_active && $preview;

module cross_section(active) {
  _s = vessel_height(reactor_vessel) * 2; // comfortably past anything the head reaches

  if (active)
    difference() {
      children();
      translate([-_s, -_s, -_s]) cube([_s * 2, _s, _s * 2]);
    }
  else
    children();
}

if (render_vessel || render_all) {
  vessel(reactor_vessel, angle=(_section_active ? 180 : 360));
}

if (render_frame || render_all) {
  frame(
    vessel=reactor_vessel,
    light=_reactor_light,
    wall_thickness=frame_wall_thickness,
    lid_flange_height=lid_flange_height,
    n_rods=n_rods,
    bolt_screw=joint_bolt,
    bolt_pts=bolt_pattern_pts(joint_posts, joint_bolt_circle, n_rods),
    drive=drive_name,
    magnet=_build_magnet,
    collapse_spacer_z_allow=true
  );
}

if (render_head || render_all) {
  cross_section(_section_active)
  translate(export_at_origin ? [0, 0, 0] : [0, 0, vessel_height(reactor_vessel) + lid_flange_height])
    head(
      vessel=reactor_vessel,
      lid_flange_height=lid_flange_height,
      joint_outer_diameter=joint_outer_diameter,
      post_pts=bolt_pattern_pts(joint_posts, joint_bolt_circle),
      post_hole_diameter=joint_hole_diameter,
      build=reactor_build
    );
}
