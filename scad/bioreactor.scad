/**
 * @file bioreactor.scad
 * @brief Assembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The reactor consists of a purchased glass jar (purchased/vessel.scad), a head (head.scad: lid,
 * drive, ports) and a frame (frame.scad: bases, ribs, rods, lights). This file holds only two
 * kinds of parameter.
 *
 * CROSS-COUPLING: values two subassemblies must agree on, derived once here and passed down.
 *   vessel -> head, frame   the registered row
 *   light  -> frame   the registered strip light row
 *   drive  -> head, frame   shaft, magnetic or none; the head drops its drive stack, the frame holds the fan
 *   head  <-> frame   the joint: lid_flange_height (set here), the bolt circle, the bore and
 *                     the outer face (read from frame.scad), and the post pattern
 *   head   -> here    head_gasket_factor(), which sets the joint bolt count
 *
 * BUILD DESIGNATIONS: the choices an operator makes for each reactor. They are set here because a
 * Customizer parameter set can only assign parameters of the file being rendered. Each names a
 * registered row by its STRING name and is resolved once below. "auto" means the subassembly
 * chooses the value; only explicit choices are passed down.
 */

include <purchased/vessels.scad>;
include <purchased/strip_lights.scad>;
include <purchased/heat_pads.scad>;
include <purchased/printers.scad>;
include <purchased/stir_bars.scad>;
include <purchased/magnets.scad>;

use <utils/bolt_pattern.scad>;
use <utils/elastomer.scad>;
use <utils/section.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/screws.scad>; // M8_hex_screw type

use <head.scad>;
use <frame.scad>;

/* [Part Render Selection] */

// Render the glass jar, translucent so the fit of the printed parts is visible
render_vessel = true;
// Render the head subassembly: lid, ports, drive, impellers, sparger
render_head = false;
// Render the frame subassembly: bases, ribs, rods, spacers, lights
render_frame = false;
// Render the whole reactor, overriding the three flags above
render_all = true;
// The show_ flags hide a subassembly in a render_all picture. render_all is also a flag in
// head.scad and frame.scad, so turning it off renders nothing from either.
// Draw the jar; off hides it regardless of the flags above
show_vessel = true;
// Draw the head; off hides it regardless of the flags above
show_head = true;
// Draw the frame; off hides it regardless of the flags above
show_frame = true;
// Export a part at its head.scad position, not its assembled height (see `just export-parts`)
export_at_origin = false;

/* [Rendering Parameters] */

// $fn is zero unless assigned, and frame.scad uses the caller's value. head.scad sets its own
// from $fa/$fs and re-sets it inside head(), so this value does not reach it (utils/facets.scad).
$fn = $preview ? 64 : 128;

// Cut the preview open to show the inside; ignored on a render
cross_section_active = true;
// Fraction of the assembly kept by the cut: 0.5 keeps half, 0.75 removes a quarter
cross_section_keep = 0.5;

/* [Vessel Selection] */

// The jar for this build, by name (a parameter set can only store a name, not a row)
reactor_vessel_name = "jar_10L_220x305"; // [jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_112x215, jar_1gal_155x251]

/* [Light Strip Selection] */

// The strip light; auto selects the shortest row that covers the culture depth
strip_light_name = "auto"; // [auto, RWNTAO 13in, grow 13in, grow 16in, grow 8.6in]
// Number of light tubes in each lit quadrant
lights_per_quadrant = 3; // [1:1:6]
// The heating pad held against the jar in each unlit quadrant, or none
heat_pad_name = "none"; // [none, 20W 150x50]

/* [Head Parameters - Coupling] */

// Height of the lid flange from the vessel rim to the top of the lid, in mm
lid_flange_height = 8;
// Frame wall thickness outside the jar pocket, in mm (diametral)
frame_wall_thickness = 37;

/* [Head to Frame Joint] */

// Number of tie rods in the assembly; each is also a post on the bolt circle
n_rods = 4;
// M8 is the maximum because NopSCADlib's screw rows stop there. The only joint load is gasket
// seating, a few hundred newtons per post and 1.7 kN on the widest jar, well within an M8's
// capacity. For a jar that needs more, check the gasket width first (lid_gasket_width_max).
// The fastener clamping the lid flange to the top base
joint_bolt = M8_hex_screw;

/* [Build] */

// Fraction of the jar CAPACITY filled with culture; set it for a run at another volume
culture_fill_fraction = 0.865;
// shaft: through the lid. magnetic: a stir bar driven by a fan magnet under the base.
// none: gas only. airlift: none plus a draft tube.
// Mixing method: shaft, magnetic stir bar, gas only (none), or airlift
drive_name = "shaft"; // [shaft, magnetic, none, airlift]
// Lid centre: bearing pocket and mount inserts, or plain; auto is plain when there is no drive
lid_center_name = "auto"; // [auto, bearing, plain]
// ring: between the impellers. arm: under the lower impeller. loop: the arm riser bent around into
// a C under the lower impeller. auto is the arm with a drive and the ring without one.
// Sparger type: ring, arm or loop; auto chooses from the drive
sparger_name = "auto"; // [auto, ring, arm, loop]
// lid: plates hung from the lid. wall: the standard four wall baffles on a cage inserted through
// the mouth.
// Baffle type: lid plates or wall baffles; auto is the lid plates
baffle_name = "auto"; // [auto, lid, wall]
// none: a tube hangs from the air_out port and the headspace vents through a slot in it.
// auto is the coil, unless the ring sparger needs that tube.
// Fitting on the air_out port: the coil condenser or none
condenser_name = "auto"; // [auto, none, coil]
// The stir bar for a magnetic drive; auto uses the head default
stir_bar_name = "auto"; // [auto, 25x8, 38x8, 50x8]
// The two magnets on the fan hub; auto uses the frame default
stir_magnet_name = "auto"; // [auto, MAG5x8, MAGRE6x2p5, MAG8x4x4p2, MAG484]
// The impeller shaft; auto selects the shortest row long enough for this vessel
shaft_name = "auto"; // [auto, 8x200_316, 8x400_316, 8x600_316, 8x800_316]
// The o-ring centring the lid plug; auto selects one that stretches onto this mouth
plug_oring_name = "auto"; // [auto, 4x1.5 EPDM, 11x1.5 EPDM, 12x1.5 EPDM, 13x1.5 EPDM, 14x1.5 EPDM, 15x1.5 EPDM, 16x1.5 EPDM, 17x1.5 EPDM, 18x1.5 EPDM, 20x1.5 EPDM, 22x1.5 EPDM, 23x1.5 EPDM, 24x1.5 EPDM, 25x1.5 EPDM, 28x1.5 EPDM, 30x1.5 EPDM, AS568-150, AS568-151, AS568-152, AS568-153, AS568-154, AS568-155, AS568-156, AS568-157, AS568-158, AS568-159, AS568-160, AS568-161, AS568-162, AS568-163, AS568-164, AS568-165, AS568-166, AS568-167, AS568-168, AS568-169, AS568-170, AS568-171]
// The drive motor; auto uses the head default
motor_name = "auto"; // [auto, 36GP-3530-5.18, 36PG-3429-5.2, 36PG-555PM-14-EN, 12v_5w]
// The lid rim gasket stock; auto uses the head default sheet
gasket_sheet_name = "auto"; // [auto, EPDM 1/16 60A]
// Either port accepts any registered Atlas row, including EC and ORP. The fit checks run on the
// named probe, but the DO-specific reports assume a galvanic DO probe.
// The probe in the DO port; auto uses the port table entry
do_probe_name = "auto"; // [auto, pH mini, pH con, pH lab g1, pH lab g2, pH res, DO mini, DO lab g1, DO lab g2, EC mini K1.0, EC K0.1, EC K1.0, EC K10, EC K0.1 8cm, ORP mini, ORP con, ORP lab, ORP gold]
// The probe in the pH port; auto uses the port table entry
ph_probe_name = "auto"; // [auto, pH mini, pH con, pH lab g1, pH lab g2, pH res, DO mini, DO lab g1, DO lab g2, EC mini K1.0, EC K0.1, EC K1.0, EC K10, EC K0.1 8cm, ORP mini, ORP con, ORP lab, ORP gold]
// The tilt is always derived as the maximum the jar internals allow, so this can only reduce it.
// Maximum DO probe tilt, in degrees
do_probe_port_tilt_max = 4.5;

// Values resolved from the parameters above; not inputs.
/* [Hidden] */

// Each designation is resolved once, here. registry_by_name returns undef for a name that matches
// no row and for one that matches two rows, so the assert message covers both. A failing assert
// exits 0, so the ERROR line on stderr is the only thing the checks can detect.
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
  str("No registered o-ring is named \"", plug_oring_name, "\", or it is registered twice. See bayonet-port-scad's purchased/orings.scad.")
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

// Gasket factor m for the lid seal, read from the sheet. A harder sheet needs more bolts.
lid_gasket_factor = head_gasket_factor(_build_gasket_sheet);

_build_do_probe = do_probe_name == "auto" ? undef : atlas_probe_by_name(do_probe_name);
assert(
  do_probe_name == "auto" || !is_undef(_build_do_probe),
  str("No registered Atlas probe is named \"", do_probe_name, "\", or it is registered twice. See bayonet-port-scad's purchased/atlas_probes.scad.")
);

_build_ph_probe = ph_probe_name == "auto" ? undef : atlas_probe_by_name(ph_probe_name);
assert(
  ph_probe_name == "auto" || !is_undef(_build_ph_probe),
  str("No registered Atlas probe is named \"", ph_probe_name, "\", or it is registered twice. See bayonet-port-scad's purchased/atlas_probes.scad.")
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

_build_heat_pad = heat_pad_name == "none" ? undef : heat_pad_by_name(heat_pad_name);
assert(
  heat_pad_name == "none" || !is_undef(_build_heat_pad),
  str("No registered heating pad is named \"", heat_pad_name, "\", or it is registered twice. See scad/purchased/heat_pads.scad.")
);

// Key-value pairs, not a positional row: each entry is optional, and an explicit undef ("derive
// it") must stay distinguishable from an omitted entry. head_build() reads them.
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
  ["lid_center", lid_center_name],
  ["stir_bar", _build_stir_bar],
  ["sparger", sparger_name],
  ["baffles", baffle_name],
  ["condenser", condenser_name],
];

_reactor_light = is_undef(_build_light)
  ? strip_light_for(head_liquid_height(vessel_internal_height(reactor_vessel), vessel_inner_profile(reactor_vessel), culture_fill_fraction))
  : _build_light;

assert(
  !is_undef(_reactor_light),
  "No strip light is registered, so nothing can light the vessel. See scad/purchased/strip_lights.scad."
);

// A named light skips the coverage test that "auto" uses for selection. This is a warning, not an
// assert, because an under-lit reactor can still be built.
_culture_depth = head_liquid_height(vessel_internal_height(reactor_vessel), vessel_inner_profile(reactor_vessel), culture_fill_fraction);
if (strip_light_length(_reactor_light) < _culture_depth)
  echo(str(
    "WARNING lights: ", strip_light_name(_reactor_light), " is ", strip_light_length(_reactor_light),
    " mm and the culture stands ", _culture_depth, " mm deep, so ",
    _culture_depth - strip_light_length(_reactor_light), " mm of it is unlit; auto would take the shortest row that covers it"
  ));

// One-line summary of the explicit choices in this build, so a transcript or print list can
// identify the build without listing every parameter. "auto" values are left out.
_designated = [
  for (d = [
    ["shaft", shaft_name], ["plug o-ring", plug_oring_name], ["motor", motor_name],
    ["gasket sheet", gasket_sheet_name], ["DO probe", do_probe_name], ["pH probe", ph_probe_name],
    ["light", strip_light_name], ["stir bar", stir_bar_name], ["magnets", stir_magnet_name],
    ["sparger", sparger_name], ["lid centre", lid_center_name], ["baffles", baffle_name],
    ["condenser", condenser_name],
  ]) if (d[1] != "auto") str(d[0], " ", d[1])
];
function _joined(v, i = 0) = i >= len(v) ? "" : str(i == 0 ? "" : ", ", v[i], _joined(v, i + 1));
echo(str(
  "build: ", vessel_name(reactor_vessel), ", ", drive_name, " drive, ", culture_fill_fraction * 100, "% of capacity",
  len(_designated) == 0 ? "; everything else auto" : str("; designated ", _joined(_designated))
));

module dummy() {
  // stop the customizer detection from here onwards
}

// The joint is derived once: the top base and the lid flange are drilled from the same pattern.
joint_bolt_circle = frame_bolt_circle_diameter(vessel_diameter(reactor_vessel));
// Every post hole, including the bolt holes, is sized for rod clearance. The plug locates the lid
// radially, so the bolt holes are deliberately loose.
joint_hole_diameter = frame_rod_hole_diameter();
// Outer diameter of the joint; the head matches its flange to it exactly.
joint_outer_diameter = frame_outer_diameter(vessel_diameter(reactor_vessel), frame_wall_thickness);
// The ASME spacing rule divides by the flange thickness, so the thinner of the two plates governs.
_joint_plate = min(lid_flange_height, frame_upper_base_height());
joint_posts = bolt_post_count(n_rods, screw_radius(joint_bolt) * 2, joint_bolt_circle, _joint_plate, lid_gasket_factor);

assert(
  bolt_post_spacing(joint_posts, joint_bolt_circle) >= screw_radius(joint_bolt) * 5, // 2.5x nominal, enough to get a wrench in
  str("Bolt spacing of ", bolt_post_spacing(joint_posts, joint_bolt_circle), " mm is too tight to get a wrench on.")
);

// The hole size depends only on the rod, not the screw, so a thinner rod would also shrink the
// bolt holes.
assert(
  joint_hole_diameter >= screw_clearance_radius(joint_bolt) * 2,
  str(
    "The joint is bored ", joint_hole_diameter, " mm from the rod's allowance, but an M",
    screw_radius(joint_bolt) * 2, " bolt needs ", screw_clearance_radius(joint_bolt) * 2, " mm to pass."
  )
);

echo(str("joint: ", joint_posts, " posts at ", bolt_post_spacing(joint_posts, joint_bolt_circle), " mm on a ", joint_bolt_circle, " mm circle"));

// The rod and the bolt are set in different files. A mismatch is allowed but gets a warning.
_rod_d = frame_rod_diameter();
_bolt_d = screw_radius(joint_bolt) * 2;
if (_rod_d != _bolt_d)
  echo(str(
    "WARNING joint: M", _rod_d, " rod but M", _bolt_d, " bolts in a ", joint_hole_diameter,
    " mm bore cut for the rod, leaving the bolts ", joint_hole_diameter - screw_clearance_radius(joint_bolt) * 2,
    " mm of slop; run the bolts at M", _rod_d, " to match"
  ));

// The head defines the gasket, so it computes the force; this file sets the post count. See
// utils/elastomer.scad.
_seating_force = head_gasket_seating_force(
  vessel_opening_diameter(reactor_vessel), vessel_thickness(reactor_vessel),
  _build_gasket_sheet, vessel_rim_arc_radius(reactor_vessel)
);
echo(str(
  "joint load: ", _seating_force, " N of gasket seating over ", joint_posts, " posts = ",
  _seating_force / joint_posts, " N each, on M", _bolt_d, " bolts and M", _rod_d, " rods"
));

// The assembly instruction is an angle past snug, not a torque. Gasket travel divided by thread
// pitch involves no friction coefficient, and the glass limits this joint in any case.
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

// The assembled envelope, for parts that must make room for it (support/equipment_cart.scad).
function reactor_envelope_diameter() = joint_outer_diameter; // the flange circle IS the envelope
function reactor_envelope_height() =
  frame_base_floor(reactor_vessel, _reactor_light, _build_magnet)
  + frame_riser_height(reactor_vessel, _reactor_light, _build_magnet, drive_name)
  + vessel_height(reactor_vessel) + lid_flange_height
  + head_stack_height(lid_flange_height, vessel_internal_height(reactor_vessel), _build_shaft, _build_motor, drive_name);

echo(str("reactor envelope: ", reactor_envelope_diameter(), " mm dia x ", reactor_envelope_height(), " mm tall"));

// The lid and both frame bases are discs at the joint outer diameter, by far the widest parts, and
// only this file sees both halves. A disc needs min(x, y) of the bed, not printer_fits().
// Height is not checked: every registered printer has 250 mm of Z and the tallest part is ~163.
_widest_printed = joint_outer_diameter;
_printers_fitting = [for (p = printers) if (printer_max_disc(p) >= _widest_printed) printer_name(p)];

echo(str("printers: the widest printed part is a ", _widest_printed, " mm disc (lid, base, top base); registered printers that take it: ", _printers_fitting));

if (len(_printers_fitting) == 0)
  echo(str("WARNING printers: no registered printer takes a ", _widest_printed, " mm disc; see scad/purchased/printers.scad"));

// The vessel is sectioned by revolving it through a smaller angle, which is cheaper than cutting
// it. The head and frame are cut to the same sector. utils/section.scad keeps the sector starting
// at 0 degrees, where the vessel sweep also starts, so the three match without sharing state.
// Preview only: an exported part with a wedge missing would be wrong without any warning.
_section_active = cross_section_active && $preview;
_section_size = vessel_height(reactor_vessel) * 2; // well beyond the extent of the assembly

if ((render_vessel || render_all) && show_vessel) {
  vessel(reactor_vessel, angle=(_section_active ? cross_section_keep * 360 : 360));
}

if ((render_frame || render_all) && show_frame) {
  section(keep=cross_section_keep, size=_section_size, active=_section_active)
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
    collapse_spacer_z_allow=true,
    lights_per_quadrant=lights_per_quadrant,
    heat_pad=_build_heat_pad
  );
}

if ((render_head || render_all) && show_head) {
  section(keep=cross_section_keep, size=_section_size, active=_section_active)
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
