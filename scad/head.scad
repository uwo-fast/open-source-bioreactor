/**
 * @file head.scad
 * @brief Head subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <utils/bolt_pattern.scad>;
use <utils/oring_gland.scad>;
use <utils/stirred_tank.scad>;
use <custom/sheet_gasket.scad>;

use <custom/motor_mount.scad>;
use <custom/bayonet_port.scad>;
use <custom/bayonet_probe_port.scad>;
use <custom/bayonet_thermocouple_port.scad>;
use <custom/bayonet_baffle_port.scad>;
use <custom/impeller.scad>;

include <purchased/dc_motors.scad>;
include <purchased/gearboxes.scad>;
include <purchased/vessels.scad>;
include <purchased/atlas_probes.scad>;
include <purchased/orings.scad>;
include <purchased/heat_set_inserts.scad>;
include <purchased/shaft_couplings.scad>;
include <purchased/shafts.scad>;
include <purchased/gasket_sheets.scad>;

include <custom/bayonet_interfaces.scad>;
include <custom/impellers.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/inserts.scad>; // F1BM4 type + insert()
include <NopSCADlib/vitamins/screws.scad>; // M4_cap_screw type + screw()
include <purchased/set_screws.scad>; // after screws.scad - the rows bind M4_grub_screw
include <NopSCADlib/vitamins/ball_bearings.scad>; // BB608 type + bb_diameter()/bb_width()
use <NopSCADlib/vitamins/shaft_coupling.scad>;

// Preview only, and only for the joint. The frame derives the rod circle, the bore and the outer
// face from its own allowances, and the assembly hands all three to head(); standalone there is
// nobody to hand them over, so the preview runs the same accessors rather than quoting what they
// came out as. use, not include, so none of the frame's geometry comes with them.
use <frame.scad>;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// -----

// Overrides all other render flags
render_all = true; // render all components
render_lid = false;

render_motor = false;
render_motor_mount = false;
motor_mount_part_to_render = "all"; // ["all", "base_plate", "face_plate", "middle_stand"]
render_motor_mount_inserts = false; // heat-set into the lid, and they stay there once set
render_motor_mount_screws = false; // the screws into them, which come out every service
render_shaft_coupler = false;
render_ext_shaft = false;
render_impeller = false;
render_bayonet_lock = false;
render_tube_pinlock = false;
render_thermocouple_pinlock = false;
render_probe_pinlock = false;
render_baffle_pinlock = false;
render_seals = false; // the EPDM parts: rim gasket, plug o-ring, port o-rings

// Draw the lid's 24 bayonet halves as bare shells while previewing; their pins and channels
// are boolean-heavy and only the coupling positions read on screen. Renders are unaffected.
fast_bayonet_preview = true;
$bayonet_shell_only = $preview && fast_bayonet_preview;

// -----

/* [Lid Parameters] */

// the height of the lids plug (inner diameter part)
lid_plug_height = 10;
// allowance for the lid to fit on the jar
lid_radial_allowance = 0.4;
// height allowance for the lid to fit on the jar
lid_vertical_allowance = 0.2;
// minimum wall the lid keeps around a bore: to the plug's edge, to a neighbouring port, and to the
// flange's outer edge for the joint posts
lid_holes_offset = 2.0;
// allowance for the bearing and shaft holes
bearing_hole_allowance = 0.2;

/* [Lid Seal Parameters] */

/** How the lid seals to the jar.
 * - The pressure boundary is a flat gasket cut from sheet, squeezed between the lid's flange and
 *   the flat land on top of the glass rim. It is recessed rather than clamped flat: the recess
 *   makes its compression a printed dimension instead of a torque guess, and because the recess
 *   swallows the gasket the flange still lands where it did, so the frame stack above is
 *   untouched. The land left either side of the recess bottoms on the glass and stops the bolts
 *   crushing the gasket, over an annulus broad enough that the stress on the glass is nothing.
 * - The plug o-ring is not a second pressure boundary and should not be trusted as one. A radial
 *   seal's squeeze is bore minus groove, so it tracks the jar's bore one for one, and a
 *   commodity jar's bore is not a controlled dimension - half a millimetre on the radius moves
 *   this cord across the whole of its usable band. It is here to centre the plug in the neck,
 *   which it does whatever the bore turns out to be, and to stand behind the gasket against
 *   splash. Sized toward the loose end for that reason.
 * Bands are Apple Rubber's Table A, static seals: 19-33% squeeze axial, 14-23% radial at this
 * cord. https://www.applerubber.com/src/pdf/section4-seal-types-and-gland-design-tables.pdf
 */

// the registered sheet the rim gasket is cut from. Its thickness sets the recess depth and its
// hardness sets the gasket factor the joint's bolt count comes from, so both are read back rather
// than entered - see head_gasket_factor() below
lid_gasket_sheet = sheet_epdm_1p6_60a;
// fraction of that the recess squeezes out; 25% is mid-band for a soft sheet
lid_gasket_compression = 0.25;
// land left between the gasket and each edge of the glass's flat top, for the flange to bear on
lid_gasket_land_margin = 1.0;
// the o-ring centring the plug in the neck. Its groove is cut from the jar's bore rather than
// from the ring, so the ring is stretched onto it and head() checks that stretch rather than
// deriving from it. A 3.53 cord digs too deep for this plug and trips the wall assert below
lid_plug_oring = oring_as568_160_epdm;
// radial squeeze; low in the 14-25% band because a ring stretched onto the groove thins by
// roughly half its stretch, landing this nearer 16%
lid_plug_oring_squeeze = 0.18;

/* [Bearing Parameters] */

// The registered bearing, which is what the pocket is cut from. The trade number is the part:
// a 608 is 22 x 7 on an 8 mm bore, and bearing_hole_allowance is the only allowance over it.
shaft_bearing = BB608; // McMaster 6153K71, 440C stainless, sealed, trade no. 608-2RS

/* [Motor & Gearbox Selection] */

// the registered motor type; the gearbox is taken from the motor's registration
// (dc_motor_gearbox), and all motor/gearbox dimensions are derived from these via
// the accessor functions rather than re-entered here
head_motor = motor_36pg_555pm_14_en;

/* [Shaft Parameters] */

// The distance between the bottom of the jar (punt) and the bottom of the shaft. A collision
// clearance, not the mixing one - head() derives the impeller's off-bottom clearance from this
// and reports it against Oldshue's band, which is measured to the floor the punt stands proud of.
shaft_jar_punt_clearance = 5;
// The registered impeller shaft. Diameter and length both come off the row; nothing here restates
// them. Length is not a free number - it sets how far the shaft protrudes above the lid and so how
// tall the motor mount has to be, which head() checks below.
head_shaft = shaft_8x400_316;
// adjust distance between the motor and the shaft coupling
shaft_shaft_coupling_offset = 0; // can be positive or negative
// the registered coupling joining the gearbox output shaft to the impeller shaft
shaft_coupler = shaft_coupler_8x8_rigid;

/* [Motor Mount Parameters] */

// outer diameter of the mount body
motor_mount_body_diameter = 56;
// wall thickness of the mount body; also sets the flange and raised face heights
motor_mount_wall_thickness = 10;
// clearance between the telescoping parts, for printed fit
motor_mount_coupling_allowance = 0.2;
// number of facets for the mount body (must be divisible by 4)
motor_mount_facets = 20;
// The mount comes off whenever the shaft, bearing or coupling is serviced, and a thread cut
// straight into the print does not survive that many cycles, so the lid takes heat-set inserts.
// The hole and the screw length both come off this row, so changing it is the whole change.
// Nothing here has anything to do with the gearbox - see the base screw note in motor_mount.scad.
motor_mount_base_insert = insert_m4x4p7_ss;
// the screw into that insert; its size must match what the insert takes
motor_mount_base_screw = M4_cap_screw;
// least lid left under a blind pocket - the insert holes and the bearing both stop short of the
// far side of the plug, which is the culture, so this is what keeps them blind rather than a leak
// path. One number because it is one property of the lid, not of what happens to be sunk into it
lid_blind_pocket_floor_min = 3.0;

/* [Impeller Parameters] */

/** Design guidelines for impeller:
 * - The impeller should be 0.3 to 0.5 of the tank diameter, and 0.4 to 0.5 for an axial-flow
 *   impeller in cell culture. The tank diameter meant here is the vessel's wetted bore, not the
 *   outside of the glass - see impeller_bore_ratio and utils/stirred_tank.scad, which carries the
 *   bands and their citations. Nienow 2006 also specifies, for a stacked pair, clearance between
 *   them of 0.33 to 0.5 of the tank diameter and the sparger below the lower impeller; this lid
 *   has no sparger, so that last part is unmet and is tracked in the agitation design basis.
 * - The number of fins (fins) and their twist angle (twist) influence mixing efficiency, flow patterns, and shear
 *   forces.
 *   - More fins generally increase turbulence and mixing but may require higher power input.
 *   - Twist angle adjusts the direction and intensity of flow, with higher angles promoting axial flow and lower angles
 *     favoring radial flow. Choose values based on the viscosity of the fluid, required mixing intensity, and sensitivity
 *     of the culture to shear forces.
 * - A tall vessel needs more than one impeller, spaced 1 to 2 impeller diameters apart. Closer than
 *   0.5 diameters the pair behaves as a single impeller rather than two; at 2 diameters their power
 *   draw is simply additive. https://onlinelibrary.wiley.com/doi/full/10.1002/cite.201900121
 * - The upper impeller is the mirror image of the lower, not the same part turned over. Pumping
 *   direction follows the blade's handedness, and rotating a part cannot change that, so only a
 *   mirrored blade opposes the one below it. Opposing them converges the two flows into a
 *   high velocity zone between the impellers, which mixes hard but shears hard with it.
 */

// Impeller diameter as a fraction of the vessel's BORE - the wetted internal diameter, which is
// what D/T means everywhere in the literature. This used to multiply the outer diameter, which
// let the real ratio drift with the glass: 0.468 to 0.489 across the registry for one nominal
// 0.45. The value was never wrong, only the dimension it was measured against.
//
// 0.45 is kept, now against the bore. It sits mid-band on every citation - Fitschen's 0.3-0.5,
// Nienow's 0.4-0.5 for axial impellers, and Lonza's "most preferred" 0.44-0.46 - and it is what
// lets every registered vessel build. jar_6p5gal_305x470 is the binding one: a 137 mm mouth on a
// 280.8 mm bore caps the ratio at 0.4594 with the impeller exactly filling the neck, so 0.45
// leaves 2.64 mm to actually pass it through. Every other jar tolerates 0.59 to 0.82.
//
// Consequence worth knowing: this makes the impeller 94.5 mm where the first build ran 99 mm,
// which was 0.4714 of the bore. Both are in band; 0.45 is the one that fits every vessel.
// utils/stirred_tank.scad carries the relations and the citations.
impeller_bore_ratio = 0.45;
// The registered impeller type. Blade count, twist and the blade's own span come from the row,
// as do the two process numbers a stirred-tank calculation needs - see custom/impellers.scad.
// Everything below this line is a printed-fit allowance rather than a property of the type.
//
// pbt_45_4 is a four-blade 45 degree pitched blade turbine on the Czech Standard CVS 691020
// geometry - blade width h/D 0.2 from Fort et al. 2002 - and it is chosen for what can be said
// about it. Po and the flow number come from Medek's correlation, which reports which of its
// validity conditions this vessel breaks; this one breaks T/D and H/T and head() names them.
//
// It replaced impeller_twisted_paddle_4, the blade this project drew by hand, whose power number
// is UNMEASURED and uncorrelatable: nothing in the literature covers a constant-pitch helicoid at
// 53-83 degrees of blade angle, Medek's envelope stops at 60, and Ameur's helical-screw work is
// viscous and laminar where this vessel runs Re 47,000 in water. Its blade width had no source
// either. The twisted row stays registered and head() still draws it if selected.
head_impeller_type = impeller_pbt_45_4;

// Where a borrowed power number comes from when the chosen type has none of its own. The
// folded-blade axial series is the nearest measured shape - same blade count, untwisted - and
// both Patwardhan and Kumaresan find twist LOWERS Po, so this over-estimates and everything
// derived from it is conservative. Fořt et al. 2002 and Jirout & Rieger; docs/references.md.
head_impeller_po_fallback = impeller_folded_axial_4;

// width of each fin blade
impeller_fin_width = 4;
// size of the center hub; the set screw threads through it, so it sets the thread engagement
impeller_hub_radius = 10;
// the set screw holding each impeller to the shaft
impeller_set_screw = set_screw_m4x6_316;
// where they land around the collar
impeller_set_screw_at = [0, 120];
// hub collar standing above the blades. The set screws thread into this rather than into the hub
// alongside the fins, which is what keeps them clear of a fin at any count, twist or phase
impeller_collar_height = 8;
// added to the tap hole for print calibration; printed holes come out undersize
impeller_set_screw_allow = 0;
// allowance for the shaft hole
impeller_shaft_allow = 0.4;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;
// centre to centre spacing of the two impellers, in impeller diameters
impeller_spacing_factor = 1.0;
// Lower impeller centreline off the vessel floor, in impeller diameters. Set from Fořt, who tested
// this impeller class at C/D 0.5 and 1.0 and found hydraulic efficiency higher at 1.0 - bottom
// interference costs it at the low setting - and who ties low clearances to solids suspension and
// higher ones to the blending duty this reactor actually has. Medek's correlation reproduces it
// from the other side: Po falls and the flow number rises with C/D, so circulation per watt is
// 18.5 % better at 0.9 than at 0.6. Not 1.0, which is the correlation's own C/D limit and leaves
// no margin, and which drops coverage over the upper impeller below half a diameter.
impeller_clearance_factor = 0.9;

// Derived from the registered type, not entered here. impeller_height is the blade's axial span:
// the row carries it as a fraction of diameter so it scales with the impeller rather than staying
// at whatever this build happened to use. Still UNCHARACTERISED - no citable blade-height ratio
// exists for a twisted extrusion, and the classic w = D/4 describes flat Rushton blades.
impeller_n_fins = impeller_blades(head_impeller_type);
impeller_twist_ang = impeller_twist(head_impeller_type);
// Culture depth as a fraction of the vessel's internal height. An operating choice, not geometry -
// nothing in this model sets a fill line - but the mean dissipation echo needs a volume, and the
// full internal volume would understate it. 0.8 leaves the usual headspace for foam and gas.
culture_fill_fraction = 0.8;
// Window a shaft speed measurement is averaged over, in seconds. Another operating choice with no
// geometry behind it: it sets what a fitted encoder resolves, and the controller owns the real one.
encoder_speed_window = 0.1;

/* [Thermocouple Mount Parameters] */

// height of the thermocouple mount
thermocouple_mount_height = 20;

/* [Bayonet Lock Parameters] */

// the registered bayonet interface every port on the lid mates to; all bayonet
// dimensions are derived from it via the accessor functions in bayonet_port.scad
head_bayonet = bayonet_std;

// how to draw each port on its lock: "locked" as assembled, or "entry" as it sits on
// insertion before the turn. Entry is the useful one for checking clearance around the
// bent atlas probe bodies.
port_position = "locked"; // [locked, entry]

/* [Port Assignment] */

// What sits at each of the lid_holes_n bayonet locks, going around the lid.
// Each entry is [type, bore_radius], plus a third slot for "probe":
//   "tube"         -> generic bayonet port, bore_radius sets the tube through-hole
//   "probe"        -> atlas probe holder (flex collet); bore is swallowed by the connector cut,
//                     so 0, and the third slot is the registered probe it is cut for
//   "thermocouple" -> NPT thread mount, bore_radius is the through-hole the thermocouple passes down
//   "baffle"       -> blind port carrying a swirl baffle, bore 0 since nothing passes through it.
//                     However many are listed, they have to come out equally spaced, so their
//                     count has to divide lid_holes_n; the assert in head() enforces it.
// Four baffles at 90 degrees, which on twelve ports means every third one. That leaves the other
// eight as four adjacent PAIRS, one between each baffle, and the pairs are what the functional
// grouping below is built on. Derivation and the checks against it: docs/ports-layout.md.
head_ports = [
  ["tube", 3],               //   0 deg  air out
  ["baffle", 0],             //  30
  ["probe", 0, do_lab_g2],   //  60      DO, opposite the air inlet
  ["thermocouple", 3],       //  90      beside DO, which compensates from it
  ["baffle", 0],             // 120
  ["probe", 0, ph_lab_g2],   // 150      pH, away from both dosing lines
  ["tube", 1.5],             // 180      media / spare
  ["baffle", 0],             // 210
  ["tube", 3],               // 240      air in
  ["tube", 2.4],             // 270      acid
  ["baffle", 0],             // 300
  ["tube", 2.4],             // 330      base
];

// how many bayonet locks the lid carries. The list above is the statement of it, so this counts
// it rather than repeating it; the assert in head() still catches an override that disagrees
lid_holes_n = len(head_ports);

/* [Baffle Parameters] */

/** How baffles sit in this vessel. What a baffle is, and what settles its width, belong to
 *  custom/bayonet_baffle_port.scad, which owns the part.
 * - Each plate is centred on its port, a quarter of the vessel diameter out, and can be no wider
 *   than its lock's bore lets through. So it reaches nowhere near the wall the standard wants it
 *   against: these are partial baffles standing inboard. They still break the swirl and the vortex
 *   with it, and standing off the wall is not purely a loss, since flow accelerating behind a
 *   baffle is what keeps that region from going stagnant.
 *   https://pmc.ncbi.nlm.nih.gov/articles/PMC8459426/
 * - Centred, the plates overlap the circle the impellers sweep, so they have to stop above them.
 *   That is the trade for the width: depth is capped, and the assert below says where.
 */

// clearance between the baffle and the impellers it passes, radially at the plate's inner edge
baffle_impeller_clearance = 2;
// clearance between the bottom of the baffle and the jar's floor
baffle_floor_clearance = 10;
// clearance between the jar's neck bore and the baffle's outer corner
baffle_neck_clearance = 1.5;
// clearance between the lock's bore and the plate dropping through it on assembly
baffle_bore_clearance = 0.2;
// how far the plate hangs below the port's bottom face. 280 is the floor limit for the registered
// jar, and head() reports what the plate does under load at it rather than leaving it to a print
baffle_length = 280;
// Thickness of the plate. Not a strength choice - root stress at full depth is about 1 % of yield
// at any of these - but a dynamic and a stiffness one. A 4 mm plate this long has its first
// bending mode at 5.4 Hz, which is shaft rotation at the rated 320 rpm. 8 cleared that; 9 is what
// the pitched blade's higher power number then asked for, since the plates react the impeller's
// torque and Po went 0.99 borrowed to 1.602 correlated. See docs/agitation.md.
baffle_thickness = 9;
// printed PETG, for the plate's stiffness. REASONED, NOT CITED - derated from ~2.0 GPa bulk
baffle_modulus = 1800; // MPa
baffle_density = 1270; // kg/m^3
// height over which the port's round bottom face blends out into the plate
baffle_transition_height = 10;

/* [Probe Port Parameters] */

// Design choices for the collet. Every hardware dimension comes from the registered probe
// named in head_ports, so nothing about the probe itself is entered here.
probe_port_collet_wall_thickness = 1.2;
probe_port_collet_body_allowance = 0.6; // grip fit; tune this, not the registry, if a cap is tight
probe_port_collet_connector_allowance = 0.6;
probe_port_collet_tab_gap = 1.0;
probe_port_collet_tab_deflection = 0.5;
// Tilt to keep bubbles off the sensor face
probe_port_tilt_degrees = 7;
probe_port_transition_length = 25;

/* [Color Parameters] */

// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

// the assembly derives the joint from the frame and hands the same pattern to both sides; the
// standalone preview reproduces it, see the interface TODO about the hardcoded vessel dimensions
// The lid is one part in two sections: a flange landing on the vessel rim that carries the joint,
// and a plug entering the mouth that carries the ports. Both sections are bored for the ports, so
// the ring is set by how far out a bore can sit and still leave lid_holes_offset to the plug's
// edge. Derived here rather than in each consumer, so the holes and the couplings cannot drift.
function head_lid_thickness(lid_flange_height) = lid_flange_height + lid_plug_height;
function head_lid_plug_diameter(vessel_opening_diameter) = vessel_opening_diameter - lid_radial_allowance;
function head_port_circle_radius(vessel_opening_diameter) =
  head_lid_plug_diameter(vessel_opening_diameter) / 2 - bayonet_port_hole_radius(head_bayonet) - lid_holes_offset;

// The mount's base screws land on one circle in two parts: clearance holes through the mount's
// flange, insert holes into the lid. Both read this, so the pattern cannot drift between them.
function head_motor_mount_screw_hole_diameter() = screw_clearance_radius(motor_mount_base_screw) * 2;
function head_motor_mount_screw_radius() =
  get_base_screw_separation_radius(motor_mount_body_diameter, head_motor_mount_screw_hole_diameter());

// The gasket sits on the flat top of the glass, which runs from the bore out by the wall
// thickness, inset by a land at each edge for the flange to bottom on.
function head_gasket_inner_radius(vessel_opening_diameter) =
  vessel_opening_diameter / 2 + lid_gasket_land_margin;
function head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness) =
  vessel_opening_diameter / 2 + vessel_wall_thickness - lid_gasket_land_margin;
function head_gasket_depth() = gasket_sheet_thickness(lid_gasket_sheet) * (1 - lid_gasket_compression);

// Gasket factor m, ASME VIII-1 Table 2-5.1: 0 for an o-ring, 0.5 for elastomer under 75A, 1.0
// over. The joint's bolt count is derived from it, and the assembly reads it back from here
// because the sheet is the head's to choose - same shape as the frame exporting its bolt circle.
function head_gasket_factor() = gasket_sheet_shore_a(lid_gasket_sheet) < 75 ? 0.5 : 1.0;

// z = 0 is the lid's OUTER face, and the assembly seats the flange on the rim, so the lid's own
// flange height stands between that face and the glass. Every vessel-referenced depth in this file
// goes through here rather than off vessel_internal_height directly, which is what dropped 8 mm
// out of the shaft, the impellers and the mount.
function head_punt_top_depth(lid_flange_height, vessel_internal_height) =
  lid_flange_height + vessel_internal_height;
function head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height) =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) + vessel_punt_height;

// The plate is capped twice over: by the lock bore it drops through, and by the circle the
// impellers sweep, which it now passes alongside rather than stopping above. Whichever binds.
function head_baffle_width(vessel_opening_diameter, impeller_diameter) =
  min(
    bayonet_baffle_width(head_bayonet, baffle_thickness, baffle_bore_clearance),
    2 * (head_port_circle_radius(vessel_opening_diameter) - impeller_diameter / 2 - baffle_impeller_clearance)
  );

// The drive stack, from the lid's outer face up. head() builds against these rather than
// recomputing them, and anything that has to make room for an assembled reactor reads them back
// out - the cart is the one that does.
function head_shaft_protrusion(lid_flange_height, vessel_internal_height) =
  shaft_length(head_shaft) - (head_punt_top_depth(lid_flange_height, vessel_internal_height) - shaft_jar_punt_clearance);
function head_motor_mount_height(lid_flange_height, vessel_internal_height) =
  gearbox_output_shaft_length(dc_motor_gearbox(head_motor))
  + head_shaft_protrusion(lid_flange_height, vessel_internal_height) + shaft_shaft_coupling_offset;
// top of the motor, which is the highest thing on the reactor
function head_stack_height(lid_flange_height, vessel_internal_height) =
  head_motor_mount_height(lid_flange_height, vessel_internal_height)
  + dc_motor_length(head_motor) + gearbox_length(dc_motor_gearbox(head_motor));
function head_plug_groove_width() = oring_gland_width(oring_cross_section(lid_plug_oring));

// A piston gland: cut relative to the bore it seals against, not to the plug it is cut into, so
// the ring's squeeze is what the glass leaves it.
function head_plug_oring_groove_radius(vessel_opening_diameter) =
  vessel_opening_diameter / 2 - oring_gland_depth(oring_cross_section(lid_plug_oring), lid_plug_oring_squeeze);

// Place children at port i, on the ring and turned to face out.
module head_port_at(i, vessel_opening_diameter) {
  rotate([0, 0, i * 360 / lid_holes_n])
    translate([head_port_circle_radius(vessel_opening_diameter), 0, 0])
      children();
}

module lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, joint_outer_diameter, post_pts, post_hole_diameter) {

  _thickness = head_lid_thickness(lid_flange_height);

  // z = 0 is the lid's outer face here and the part is flipped by the caller, so the flange's
  // glass-facing side is its far face, at z = lid_flange_height, where the plug starts.
  _gasket_depth = head_gasket_depth();
  _plug_groove_w = head_plug_groove_width();
  _plug_groove_z = lid_flange_height + lid_plug_height / 2; // mid plug: most land either side,
  // and clear of the bayonet channels, which sit in the half of the coupling nearest this face

  // the rods run through the flange alongside the bolts, so every post on the circle is bored
  bolt_pattern_bores(post_pts, post_hole_diameter, lid_flange_height + z_fight, -z_fight / 2)
    difference() {
      // flange, then the plug that enters the vessel opening
      union() {
        cylinder(d=joint_outer_diameter, h=lid_flange_height);
        translate([0, 0, lid_flange_height])
          cylinder(d=head_lid_plug_diameter(vessel_opening_diameter), h=lid_plug_height);
      }

      // cut out the bearing and shaft hole
      translate([0, 0, -z_fight / 2])
        union() {
          // shaft hole
          cylinder(d=shaft_diameter(head_shaft) + bearing_hole_allowance, h=_thickness + z_fight);

          // bearing pocket
          rotate([0, 0, 30])
            cylinder(d=bb_diameter(shaft_bearing) + bearing_hole_allowance, h=bb_width(shaft_bearing) + z_fight);
        }

      // Insert holes for the motor mount, blind: this face carries the mount, the far side of
      // the plug is the culture, and the assert in head() is what keeps the two apart.
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([head_motor_mount_screw_radius(), 0, -z_fight / 2])
            cylinder(r=insert_hole_radius(motor_mount_base_insert), h=insert_hole_length(motor_mount_base_insert) + z_fight / 2);

      // cut out the entry holes for the probes and tubes; the port sizes its own hole so the
      // lock keeps a bearing land against the lid's underside
      for (i = [0:lid_holes_n - 1])
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, _thickness / 2])
            cylinder(r=bayonet_port_hole_radius(head_bayonet), h=_thickness + z_fight, center=true);

      // rim gasket recess, sunk into the flange's glass-facing face
      translate([0, 0, lid_flange_height - _gasket_depth])
        difference() {
          cylinder(r=head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness), h=_gasket_depth + z_fight);
          translate([0, 0, -z_fight])
            cylinder(r=head_gasket_inner_radius(vessel_opening_diameter), h=_gasket_depth + z_fight * 3);
        }

      // o-ring groove round the plug
      translate([0, 0, _plug_groove_z - _plug_groove_w / 2])
        difference() {
          cylinder(r=head_lid_plug_diameter(vessel_opening_diameter) / 2 + 1, h=_plug_groove_w);
          translate([0, 0, -z_fight])
            cylinder(r=head_plug_oring_groove_radius(vessel_opening_diameter), h=_plug_groove_w + z_fight * 2);
        }
    }
}

// Does this port type care which way round it ends up? A tube's bore and a thermocouple's
// thread mount are figures of revolution, so their seating does not matter. A baffle plate
// stands in a plane and a probe collet leans in a direction, and both take that direction from
// the port's own frame - so both need the coupling to admit exactly one seating.
function head_port_is_oriented(type) = type == "baffle" || type == "probe";

// One port pin half, dispatched on its registered type. All share the same bayonet
// interface, so they are interchangeable across the lid's locks.
module head_port(port, panel_thickness, baffle_width) {
  _type = port[0];
  _bore = port[1];
  _probe = port[2];

  if (_type == "tube") {
    // The tube interface is just the generic port with its bore set, and the bore printed
    // on the flange.
    bayonet_port(
      type=head_bayonet,
      part="pin",
      panel_thickness=panel_thickness,
      center_bore_radius=_bore,
      text_labels=true
    );
  } else if (_type == "probe") {
    assert(!is_undef(_probe), "head_port: a \"probe\" entry needs a registered atlas probe in slot 3");
    bayonet_probe_port(
      type=head_bayonet,
      probe=_probe,
      panel_thickness=panel_thickness,
      center_bore_radius=_bore,
      collet_wall_thickness=probe_port_collet_wall_thickness,
      collet_body_allowance=probe_port_collet_body_allowance,
      collet_connector_allowance=probe_port_collet_connector_allowance,
      collet_tab_gap=probe_port_collet_tab_gap,
      collet_tab_internal_deflection=probe_port_collet_tab_deflection,
      tilt_degrees=probe_port_tilt_degrees,
      transition_length=probe_port_transition_length
    );
  } else if (_type == "baffle") {
    bayonet_baffle_port(
      type=head_bayonet,
      panel_thickness=panel_thickness,
      length=baffle_length,
      thickness=baffle_thickness,
      transition_height=baffle_transition_height,
      bore_clearance=baffle_bore_clearance,
      width=baffle_width
    );
  } else if (_type == "thermocouple") {
    bayonet_thermocouple_port(
      type=head_bayonet,
      panel_thickness=panel_thickness,
      center_bore_radius=_bore,
      mount_height=thermocouple_mount_height
    );
  } else {
    assert(false, str("head_port: unknown port type '", _type, "'"));
  }
}

module head(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, vessel_internal_height, vessel_punt_height, joint_outer_diameter, post_pts, post_hole_diameter) {

  // the gearbox carried by the selected motor - single source for gearbox dims
  head_gearbox = dc_motor_gearbox(head_motor);

  // Both state the port count. The bores loop over lid_holes_n, so a longer head_ports is silently
  // truncated - a 13th port drops out with the model byte-identical.
  assert(
    len(head_ports) == lid_holes_n,
    str(len(head_ports), " head_ports entries for ", lid_holes_n, " lid holes.")
  );

  // Impeller Driven Parameters
  // The bore is what the impeller mixes and what D/T is measured against; the glass wall is not
  // part of the tank. Both the diameter and the spacing come from utils/stirred_tank.scad so the
  // relations and their citations live in one place.
  _vessel_bore = vessel_outer_diameter - 2 * vessel_wall_thickness;
  _liquid_height = vessel_internal_height * culture_fill_fraction;

  // Read off the port table, so it depends on nothing else and can sit this early. It has to:
  // Medek's envelope is conditioned on four baffles and the Po block below is the first consumer.
  _baffle_at = [for (i = [0:lid_holes_n - 1]) if (head_ports[i][0] == "baffle") i];
  impeller_diameter = stirred_tank_impeller_diameter(_vessel_bore, impeller_bore_ratio);
  impeller_radius = impeller_diameter / 2; // radius of the impeller

  // The blade's axial span, from the type's own width ratio so it scales with the impeller rather
  // than staying at whatever this build happened to use. Still uncharacterised: nothing citable
  // gives a blade-height ratio for a twisted extrusion, and the classic w = D/4 is a flat Rushton
  // blade. A type that registers no ratio has no height to derive, which head() refuses below.
  assert(
    !is_undef(impeller_width_ratio(head_impeller_type)),
    str(
      "head: impeller type \"", impeller_name(head_impeller_type),
      "\" registers no width ratio, so the blade has no axial span to derive. Register one on the ",
      "row, or choose a type that carries it."
    )
  );
  // What the blade occupies along the shaft. Not the registered width on a pitched blade - a plate
  // set at an angle projects only sin(angle) of itself onto the axis - so this goes through the
  // accessor rather than multiplying the ratio here. Everything downstream is a vertical budget:
  // clearance, coverage, the collar's room, the baffle gap.
  impeller_height = impeller_axial_span(head_impeller_type, impeller_diameter);
  impeller_blade_width = impeller_width_ratio(head_impeller_type) * impeller_diameter;

  // radius of the shaft hole in the impeller
  impeller_shaft_hole_radius = (shaft_diameter(head_shaft) + impeller_shaft_allow) / 2;

  impeller_spacing = stirred_tank_impeller_spacing(impeller_diameter, impeller_spacing_factor);

  // Where this build sits against the literature. Reported rather than asserted: a ratio outside
  // the band may be the thing being studied, and refusing to draw it would make the model less
  // useful, not safer. What is asserted is only what cannot physically work - the span check
  // below, which stops an impeller too wide to pass the vessel's mouth.
  _impeller_ratio = stirred_tank_ratio(impeller_diameter, _vessel_bore);
  _ratio_band = stirred_tank_ratio_band();
  _ratio_band_axial = stirred_tank_ratio_band_axial();
  _spacing_band = stirred_tank_spacing_band();

  // Off-bottom clearance, measured the way the literature measures it: impeller CENTRELINE to the
  // vessel FLOOR. Two different clearances are in play and they are not the same number.
  // shaft_jar_punt_clearance is the shaft's gap over the punt - a collision dimension, and the
  // punt stands proud of the floor around it. The mixing quantity is measured to that lower floor,
  // which the impeller sweeps almost entirely over: the punt is 30 mm across on a 210 mm bore,
  // about 2 % of the floor area.
  //
  // Chosen, not inherited. This used to be vessel_punt_height + shaft_jar_punt_clearance +
  // impeller_height / 2 - where the impeller landed if its bottom sat flush with a shaft bottoming
  // out over the punt - which made a mixing quantity a consequence of how long the shaft was. That
  // sum is now the LOWER BOUND asserted below rather than the definition, and the shaft runs past
  // the impeller to the punt whatever clearance is asked for, so raising it costs no mount height.
  _impeller_clearance = stirred_tank_clearance(impeller_diameter, impeller_clearance_factor);
  _clearance_ratio = stirred_tank_clearance_ratio(_impeller_clearance, impeller_diameter);
  _clearance_band = stirred_tank_clearance_band_fluidfoil();

  echo(str(
    "impeller: ", impeller_diameter, " mm in a ", _vessel_bore, " mm bore, D/T ", _impeller_ratio,
    " (band ", _ratio_band[0], "-", _ratio_band[1], ", axial ", _ratio_band_axial[0], "-",
    _ratio_band_axial[1], "); spacing ", impeller_spacing_factor, " D (band ", _spacing_band[0],
    "-", _spacing_band[1], ")"
  ));

  // What the clearance spends and what it buys, neither of which was visible before. Coverage is
  // over the UPPER impeller because that is the one nearest the surface, and the room is under the
  // LOWER one because that is where a sparger has to go.
  _upper_impeller_top = _impeller_clearance + impeller_spacing + impeller_height / 2;
  _impeller_coverage =
  stirred_tank_coverage(vessel_punt_height + _liquid_height, _upper_impeller_top);
  _coverage_ratio = stirred_tank_coverage_ratio(_impeller_coverage, impeller_diameter);
  _sparger_room = _impeller_clearance - impeller_height / 2;

  echo(str(
    "impeller clearance: centreline ", _impeller_clearance, " mm off the floor = ",
    _clearance_ratio, " D (Oldshue allows ", _clearance_band[0], "-", _clearance_band[1], "), C/T ",
    _impeller_clearance / _vessel_bore, "; ", _sparger_room, " mm under the lower impeller and ",
    _impeller_coverage, " mm (", _coverage_ratio, " D) of culture over the upper"
  ));

  if (_coverage_ratio < stirred_tank_coverage_minimum())
    echo(str(
      "WARNING impeller coverage: ", _coverage_ratio, " D of liquid over the upper impeller is ",
      "under the ", stirred_tank_coverage_minimum(), " D this project holds. Oldshue warns ",
      "fluidfoils short-circuit to a low distance above themselves; a down-pumping one this ",
      "shallow draws its own discharge off the surface. Lower impeller_clearance_factor."
    ));

  // Reported against the guidance that fits the blade, which is not always Oldshue's. His 1-2 d is
  // about "these FLUIDFOIL impellers" - the hydrofoil class - and it is permissive even there:
  // "if the impeller CAN be placed ... these impellers OFFER". A pitched blade turbine is a
  // different and older class, so quoting the number is context rather than a target it misses.
  //
  // What does fit a pitched blade is Fořt, the same source the power number comes from: he tested
  // C/D 0.5 and 1.0 and found hydraulic efficiency higher at 1.0, bottom interference costing it
  // at the low setting. Whether C/D is inside his correlation's envelope is already checked - it
  // appears in the departures list above if not.
  if (!stirred_tank_in_band(_clearance_ratio, _clearance_band))
    echo(str(
      "impeller clearance: ", _clearance_ratio, " D sits below the ", _clearance_band[0], "-",
      _clearance_band[1], " D Oldshue allows, but that allowance is for fluidfoils and this is a ",
      impeller_name(head_impeller_type),
      ". The guidance that fits it is Fořt's, who measured better hydraulic efficiency at C/D 1.0 ",
      "than 0.5; his correlation's own C/D limit is 1.0 and coverage over the upper impeller binds ",
      "at ", (vessel_punt_height + _liquid_height - impeller_spacing - impeller_height / 2
              - stirred_tank_coverage_minimum() * impeller_diameter) / impeller_diameter,
      " D. See docs/agitation.md."
    ));

  if (!stirred_tank_in_band(_impeller_ratio, _ratio_band))
    echo(str(
      "WARNING impeller: D/T of ", _impeller_ratio, " is outside the ", _ratio_band[0], "-",
      _ratio_band[1], " band bioreactor practice works in. Below it the impeller does not move ",
      "enough fluid; above it an axial impeller loses its axial motion."
    ));

  if (!stirred_tank_in_band(impeller_spacing_factor, _spacing_band))
    echo(str(
      "WARNING impeller: spacing of ", impeller_spacing_factor, " D is outside the ",
      _spacing_band[0], "-", _spacing_band[1], " D band; too close costs up to 35% of the power ",
      "imparted to the fluid, too far mixes the two zones poorly."
    ));

  // Set screws hold the impeller to the shaft; nothing else does. The bore tapers to the shaft's
  // nominal radius, so the fit is a slip fit whatever its parameter is called. Engagement is what
  // the hub wall leaves between socket and shaft, and reach is whether the tip gets there at all.
  _set_screw_engagement = impeller_hub_radius - impeller_shaft_hole_radius;
  _set_screw_reach =
  impeller_hub_radius - shaft_diameter(head_shaft) / 2 - set_screw_length(impeller_set_screw);

  _set_screw_hole = (set_screw_tap_radius(impeller_set_screw) + impeller_set_screw_allow) * 2;

  echo(str(
    "impeller set screws: ", len(impeller_set_screw_at), " x ", set_screw_name(impeller_set_screw),
    " (", set_screw_part_number(impeller_set_screw), ") at ", impeller_set_screw_at, " deg, ",
    _set_screw_engagement, " mm of thread in a ", _set_screw_hole,
    " mm tap hole, through a ", impeller_collar_height, " mm collar above the blades"
  ));

  // The collar stands in the gap between the impellers, so it is the lower one's that runs out of
  // room first.
  assert(
    impeller_collar_height < impeller_spacing - impeller_height,
    str(
      "The lower impeller's ", impeller_collar_height, " mm collar reaches into the ",
      impeller_spacing - impeller_height, " mm gap above it."
    )
  );

  if (impeller_collar_height < _set_screw_hole + 2 * impeller_fin_width / 2)
    echo(str(
      "WARNING impeller set screws: a ", impeller_collar_height, " mm collar leaves ",
      (impeller_collar_height - _set_screw_hole) / 2, " mm of wall each side of a ", _set_screw_hole,
      " mm hole. Raise impeller_collar_height."
    ));

  assert(
    _set_screw_reach <= 0,
    str(
      "A ", set_screw_length(impeller_set_screw), " mm set screw in a ", impeller_hub_radius,
      " mm hub stops ", _set_screw_reach, " mm short of the shaft and holds nothing."
    )
  );

  if (_set_screw_reach < -1)
    echo(str(
      "WARNING impeller set screws: the screw stands ", -_set_screw_reach,
      " mm proud of the hub. A shorter row, or a hub of ",
      shaft_diameter(head_shaft) / 2 + set_screw_length(impeller_set_screw), " mm, sits flush."
    ));

  if (_set_screw_engagement < set_screw_diameter(impeller_set_screw))
    echo(str(
      "WARNING impeller set screws: ", _set_screw_engagement, " mm of thread is under one ",
      set_screw_diameter(impeller_set_screw), " mm diameter. In PETG the thread strips before the ",
      "joint slips; grow impeller_hub_radius. See docs/procurement.md."
    ));

  // What the drive does to the culture. Reported, never asserted: the margin against damage runs
  // to orders of magnitude, and why there is no tip-speed limit anywhere here is in
  // utils/stirred_tank.scad's header. What is worth seeing at render is where the operating point
  // lands, because the band that earns its power turns out to be narrow.
  //
  // Re and tip speed are as good as the speed they are handed. Everything past Po is an estimate:
  // the power number is measured on a folded axial blade rather than this twisted one, and P is
  // one impeller's, where the stacked pair draws more - though less than double, being closer
  // than the spacing at which two impellers stop interacting. See docs/agitation.md.
  _culture_volume = stirred_tank_volume(_vessel_bore, _liquid_height);
  // Po and x are properties of the blade, so they come off the registered type. Three ways to get
  // one, in descending order of what it is worth:
  //
  //   MEASURED   the row carries it, with a tolerance where the source gave one
  //   CORRELATED the row carries a blade angle instead, so Medek's correlation computes it from
  //              the geometry - and reports which of its validity conditions this vessel breaks,
  //              which a single borrowed number can never do
  //   BORROWED   neither, so a fallback row's number stands in. The blade this project drew by
  //              hand is the only row that lands here
  //
  // Whichever applies is echoed. Po is the largest single uncertainty in every power, dissipation
  // and torque figure below, so which kind of number it is has to travel with it.
  _po_measured = impeller_has_power_number(head_impeller_type);
  _po_correlated = !_po_measured && !is_undef(impeller_blade_angle(head_impeller_type));
  _po_borrowed = !_po_measured && !_po_correlated;

  _medek_departures = stirred_tank_medek_departures(
    impeller_blades(head_impeller_type), _clearance_ratio, _vessel_bore / impeller_diameter,
    _liquid_height / _vessel_bore, impeller_blade_angle(head_impeller_type),
    len(_baffle_at), stirred_tank_reynolds(impeller_diameter, dc_motor_rated_output_rpm(head_motor))
  );

  _impeller_po =
  _po_measured ? impeller_power_number(head_impeller_type)
  : _po_correlated ? stirred_tank_medek_power_number(
      impeller_blades(head_impeller_type), _clearance_ratio, _vessel_bore / impeller_diameter,
      _liquid_height / _vessel_bore, impeller_blade_angle(head_impeller_type))
  : impeller_power_number(head_impeller_po_fallback);
  _impeller_x = impeller_dissipation_factor(head_impeller_type);

  if (_po_borrowed)
    echo(str(
      "impeller: ", impeller_name(head_impeller_type), " has no measured power number and no blade ",
      "angle for a correlation to work from; borrowing ", _impeller_po, " from ",
      impeller_name(head_impeller_po_fallback),
      ". Twist lowers Po, so this over-estimates and every figure derived from it is conservative."
    ));

  if (_po_correlated)
    echo(str(
      "impeller: ", impeller_name(head_impeller_type), " Po ", _impeller_po,
      " and flow number ", stirred_tank_medek_flow_number(
        impeller_blades(head_impeller_type), _clearance_ratio, _vessel_bore / impeller_diameter,
        _liquid_height / _vessel_bore, impeller_blade_angle(head_impeller_type)),
      " from Medek's correlation at ", impeller_blade_angle(head_impeller_type), " deg, ",
      len(_medek_departures) == 0
        ? "inside its validity envelope"
        : str("extrapolated on ", _medek_departures)
    ));
  _rated_torque = dc_motor_rated_output_torque(head_motor); // undef on a motor that publishes none

  // no-load and rated are different facts and either may be unpublished, so each is reported as
  // itself and a motor missing both says so rather than echoing a silent undef
  _drive_speeds = [
    for (s = [
      ["no-load", dc_motor_no_load_output_rpm(head_motor)],
      ["rated", dc_motor_rated_output_rpm(head_motor)],
    ]) if (!is_undef(s[1])) s
  ];

  if (len(_drive_speeds) == 0)
    echo(str("drive: ", head_motor[0], " registers no output speed, so no Re or dissipation follows"));

  for (s = _drive_speeds)
    let (_rpm = s[1], _power = stirred_tank_power(impeller_diameter, _rpm, _impeller_po))
      echo(str(
        "drive ", s[0], " ", _rpm, " rpm: Re ", stirred_tank_reynolds(impeller_diameter, _rpm),
        ", tip ", stirred_tank_tip_speed(impeller_diameter, _rpm), " m/s, ", _power, " W into ",
        _culture_volume, " L = ", stirred_tank_mean_dissipation(_power, _culture_volume),
        " W/m3 mean, ", stirred_tank_max_dissipation(impeller_diameter, _rpm, _impeller_po, _impeller_x),
        " W/kg peak",
        // twice one impeller's torque: an upper bound on the pair, as P above is a lower one
        is_undef(_rated_torque) ? "" : str(
          ", pair under ", 2 * stirred_tank_torque(_power, _rpm), " Nm of ", _rated_torque, " Nm rated"
        )
      ));

  // Whether the speed above can be measured or only commanded. Worth reporting next to it because
  // the band the drive aims at is narrow, so what resolves it decides whether the model's numbers
  // describe the shaft or only the request.
  _encoder = dc_motor_encoder(head_motor);
  _encoder_counts = dc_motor_encoder_counts_per_output_rev(head_motor);

  if (is_undef(_encoder))
    echo(str("drive: ", head_motor[0], " carries no encoder, so shaft speed is commanded, not measured"));
  else
    echo(str(
      "drive encoder: ", _encoder[0], " ppr x ", _encoder[1], " channels through ",
      gearbox_ratio(head_gearbox), ":1 = ", _encoder_counts, " counts per output turn, resolving ",
      60 / (_encoder_counts * encoder_speed_window), " rpm over ", encoder_speed_window * 1000, " ms"
    ));

  // this impeller is tall for its diameter, so the pair collide before they reach the 0.5 diameter
  // spacing at which they would stop behaving as two impellers
  assert(
    impeller_spacing > impeller_height,
    str("Impellers overlap: ", impeller_spacing, " mm apart but ", impeller_height, " mm tall.")
  );

  // The shaft bottoms out over the punt and the impeller is placed off the floor, so nothing makes
  // them meet any more. Below this the lower impeller hangs off the end of its own shaft.
  assert(
    _impeller_clearance - impeller_height / 2 >= vessel_punt_height + shaft_jar_punt_clearance,
    str(
      "Lower impeller reaches ", _impeller_clearance - impeller_height / 2,
      " mm off the floor but the shaft stops at ", vessel_punt_height + shaft_jar_punt_clearance,
      " mm; raise impeller_clearance_factor above ",
      (vessel_punt_height + shaft_jar_punt_clearance + impeller_height / 2) / impeller_diameter, "."
    )
  );

  // An impeller in the headspace pumps air, so this is submersion rather than fit.
  assert(
    _impeller_clearance + impeller_spacing + impeller_height / 2 <= vessel_punt_height + _liquid_height,
    str(
      "Upper impeller reaches ", _impeller_clearance + impeller_spacing + impeller_height / 2,
      " mm off the floor, past the ", vessel_punt_height + _liquid_height,
      " mm of culture there is to cover it."
    )
  );

  // The impeller is scaled off the vessel's outer diameter but has to pass through its opening,
  // and the ring joining the fin tops is what meets the neck first, not the blades.
  assert(
    impeller_diameter + 2 * impeller_fin_width <= vessel_opening_diameter,
    str(
      "Impeller spans ", impeller_diameter + 2 * impeller_fin_width, " mm across its top ring, past the ",
      vessel_opening_diameter, " mm opening it has to pass through."
    )
  );

  // Negative, the shaft is drawn below the jar's internal floor rather than clear of it, and the
  // reach assert above is helped toward passing by it.
  assert(
    shaft_jar_punt_clearance >= 0,
    str("Shaft is drawn ", -shaft_jar_punt_clearance, " mm into the jar's floor.")
  );

  // Motor and shaft driven parameters
  shaft_protrusion = head_shaft_protrusion(lid_flange_height, vessel_internal_height);

  // What the shaft leaves above the lid for the coupling to grip. At or below zero the shaft ends
  // inside the vessel and there is nothing for the motor to couple to.
  assert(
    shaft_protrusion > 0,
    str("Shaft ends ", -shaft_protrusion, " mm below the lid's outer face, so the coupling cannot reach it.")
  );

  // The coupling's two bores are catalogue facts and the shafts they go on are set elsewhere, so
  // The shaft runs directly in the bearing's inner race, so the fit is two tolerances meeting.
  // Both are registered, so this is checked rather than assumed - a plain rod at h9 would nominally
  // be "8 mm" and still rattle. Reported, not asserted: a transition fit is what a rotating inner
  // ring wants, and which side of line-to-line a given pair lands on is not ours to refuse.
  _fit_loosest = bb_bore(shaft_bearing) - shaft_diameter_min(head_shaft);
  _fit_tightest = (bb_bore(shaft_bearing) - 0.007) - shaft_diameter_max(head_shaft);
  echo(str(
    "shaft: ", shaft_name(head_shaft), " (", shaft_part_number(head_shaft), ") ",
    shaft_diameter_min(head_shaft), "-", shaft_diameter_max(head_shaft), " mm in a ",
    bb_bore(shaft_bearing), " mm bore: ", _fit_tightest, " to ", _fit_loosest, " mm"
  ));

  // nothing but this stops a coupling that fits neither end.
  assert(
    sc_diameter1(shaft_coupler) == gearbox_output_shaft_dia(head_gearbox) &&
    sc_diameter2(shaft_coupler) == shaft_diameter(head_shaft),
    str(
      "The ", shaft_coupler[0], " coupling bores ", sc_diameter1(shaft_coupler), " and ",
      sc_diameter2(shaft_coupler), " mm, for a ", gearbox_output_shaft_dia(head_gearbox),
      " mm gearbox shaft and a ", shaft_diameter(head_shaft), " mm impeller shaft."
    )
  );

  // the height that the motor coupling assembly requires
  motor_mount_height = head_motor_mount_height(lid_flange_height, vessel_internal_height);

  // Mount slenderness. REASONED, NOT CITED - no source stands behind these two numbers. The
  // coupling is rigid, so it transmits misalignment rather than absorbing it, and any deflection
  // of the mount is reacted by this bearing and the gearbox's. Lateral deflection of a thin tube
  // goes as the cube of its slenderness, so height over diameter is the measure. Calibrated
  // against the build in hand, which sits at 2.3 and works.
  _mount_slenderness = motor_mount_height / motor_mount_body_diameter;

  if (_mount_slenderness > 3)
    echo(str(
      "WARNING motor mount: ", _mount_slenderness, " diameters tall. A shorter registered shaft ",
      "lowers it - shaft length sets the protrusion, and the protrusion is the mount."
    ));

  assert(
    _mount_slenderness <= 5,
    str(
      "Motor mount is ", motor_mount_height, " mm on a ", motor_mount_body_diameter, " mm body, ",
      _mount_slenderness, " diameters. A printed telescoping tube that slender will not hold a ",
      "rigid coupling in alignment. Choose a shorter registered shaft."
    )
  );

  echo("motor mount height: ", motor_mount_height / 10, " cm");

  // --- motor mount joint ---

  // The insert is bought and the screw is bought, and nothing about either makes the pair agree.
  assert(
    screw_radius(motor_mount_base_screw) * 2 == insert_screw_diameter(motor_mount_base_insert),
    str(
      "The motor mount takes an M", screw_radius(motor_mount_base_screw) * 2, " screw into an insert sized for M",
      insert_screw_diameter(motor_mount_base_insert), "."
    )
  );

  // The hole is blind because what is on the other side of the plug is the culture. This is the
  // one guard that matters here: the insert reaches most of the way through the flange already,
  // so a thinner lid or a longer insert breaks through without it.
  _insert_floor = head_lid_thickness(lid_flange_height) - insert_hole_length(motor_mount_base_insert);
  assert(
    _insert_floor >= lid_blind_pocket_floor_min,
    str(
      "A ", motor_mount_base_insert[0], " insert leaves ", _insert_floor, " mm of lid before the culture; ",
      lid_blind_pocket_floor_min, " mm is the least this lid keeps."
    )
  );

  // The bearing pocket is the other blind hole in this face, and the deeper of the two.
  _bearing_floor = head_lid_thickness(lid_flange_height) - bb_width(shaft_bearing);
  assert(
    _bearing_floor >= lid_blind_pocket_floor_min,
    str(
      "A ", bb_name(shaft_bearing), " bearing leaves ", _bearing_floor, " mm of lid before the culture; ",
      lid_blind_pocket_floor_min, " mm is the least this lid keeps."
    )
  );

  // Negative, it cuts interference instead of clearance and the pocket closes on the bearing.
  assert(
    bearing_hole_allowance >= 0,
    str("Bearing hole allowance of ", bearing_hole_allowance, " mm is negative, so the pocket is cut under the bearing.")
  );

  // The screw circle is set by the mount's body and the pocket by the bearing, and the two are
  // chosen independently, so nothing but this stops an insert being sunk into the bearing's wall.
  _insert_to_bearing =
  head_motor_mount_screw_radius() - insert_outer_d(motor_mount_base_insert) / 2 - (bb_diameter(shaft_bearing) + bearing_hole_allowance) / 2;
  assert(
    _insert_to_bearing > 0,
    str(
      "Motor mount inserts on a ", head_motor_mount_screw_radius() * 2, " mm circle overlap the bearing pocket by ",
      -_insert_to_bearing, " mm."
    )
  );

  echo(str(
    "motor mount: 4 x ", motor_mount_base_insert[0], " inserts on a ", head_motor_mount_screw_radius() * 2,
    " mm circle, ", screw_length(motor_mount_base_screw, motor_mount_base_screw_grip(motor_mount_wall_thickness), 0, insert=motor_mount_base_insert),
    " mm M", insert_screw_diameter(motor_mount_base_insert), " screws, ", _insert_floor, " mm of lid left under them, ",
    _insert_to_bearing, " mm to the bearing pocket"
  ));

  // The lid is flipped so its outer face lands on z = 0, which is the datum both port halves
  // are built around; that is why the ports below need no z placement of their own.
  lid_thickness = head_lid_thickness(lid_flange_height);

  port_circle_radius = head_port_circle_radius(vessel_opening_diameter);

  // the plate clears the impellers radially, so what stops it is the floor
  baffle_max_length =
  head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
  - lid_thickness - baffle_floor_clearance;

  // the plate's width is settled by the lock it hangs from and the impellers it passes, so it is
  // read back, not chosen here
  _baffle_width = head_baffle_width(vessel_opening_diameter, impeller_diameter);

  assert(
    _baffle_width > 0,
    str(
      "A ", impeller_diameter, " mm impeller leaves no room for a baffle on a ",
      head_port_circle_radius(vessel_opening_diameter) * 2, " mm port circle at ",
      baffle_impeller_clearance, " mm clearance."
    )
  );

  // Oldshue 1997 p. 202 sizes baffling by TOTAL PROJECTED AREA, not by count: four at T/12 is the
  // reference, and "either 3, 6 or 8 baffles can be used if preferred" at the same total. So the
  // count is a configuration choice and this reports where the chosen one lands. The width is not
  // free to compensate - head_baffle_width() returns whichever of the lock bore and the impeller
  // binds - so the levers are the count and how much plate ends up under the liquid.
  _baffle_freeboard =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) - _liquid_height - lid_thickness;
  _baffle_wetted = stirred_tank_baffle_wetted_length(baffle_length, _baffle_freeboard, _liquid_height);
  _baffle_area_ratio =
  stirred_tank_baffle_area_ratio(_vessel_bore, _liquid_height, len(_baffle_at), _baffle_width, _baffle_wetted);

  echo(str(
    "baffles: ", len(_baffle_at), " x ", _baffle_width, " x ", baffle_length, " mm (",
    baffle_max_length, " mm clears the floor), ", _baffle_wetted, " mm of that submerged; ",
    _baffle_area_ratio, " of Oldshue's four-at-T/12 full-depth reference area"
  ));

  // Both levers, with the numbers, because "add another" stops being available: an equally spaced
  // count has to divide the port circle, so on twelve ports the counts are 2, 3, 4, 6, 12 and the
  // assert below enforces it. Depth is the lever that is still wide open.
  _next_baffle_count = [for (n = [len(_baffle_at) + 1:lid_holes_n]) if (lid_holes_n % n == 0) n];
  _baffle_ratio_at_depth = stirred_tank_baffle_area_ratio(
    _vessel_bore, _liquid_height, len(_baffle_at), _baffle_width,
    stirred_tank_baffle_wetted_length(baffle_max_length, _baffle_freeboard, _liquid_height));

  if (_baffle_area_ratio < 0.9)
    echo(str(
      "WARNING baffles: ", _baffle_area_ratio, " of the reference projected area. ",
      baffle_length < baffle_max_length
        ? str("Hanging these ", len(_baffle_at), " to the full ", baffle_max_length,
              " mm would give ", _baffle_ratio_at_depth, "; ")
        : "Depth is spent - these already hang to the floor limit. ",
      len(_next_baffle_count) > 0
        ? str("Going to ", _next_baffle_count[0], " plates, the next count that spaces equally on ",
              lid_holes_n, " ports, would give ", stirred_tank_baffle_area_ratio(
                _vessel_bore, _liquid_height, _next_baffle_count[0], _baffle_width, _baffle_wetted))
        : str(len(_baffle_at), " is the most this port circle spaces equally"),
      ". Under-baffling lets the vessel swirl rather than mix; see docs/agitation.md."
    ));

  // What the plate does under load. Not a collision check - the plate bends tangentially and the
  // impeller sweeps a circle, so this does not close the radial gap. It is whether the plate still
  // blocks the swirl, and whether it sits on something the drive excites.
  // Worst case is the fastest the drive runs, which is its no-load speed, so this takes the top of
  // the registered speeds rather than the rated point the drive block reports against.
  _baffle_rpm = max([for (s = _drive_speeds) s[1]]);
  _baffle_torque = 2 * stirred_tank_torque(
    stirred_tank_power(impeller_diameter, _baffle_rpm, _impeller_po), _baffle_rpm);
  _baffle_load = stirred_tank_baffle_load(_baffle_torque, len(_baffle_at), port_circle_radius);
  _baffle_deflection = stirred_tank_baffle_deflection(
    _baffle_load, baffle_length, _baffle_freeboard, _baffle_width, baffle_thickness, baffle_modulus);
  _baffle_frequency = stirred_tank_baffle_frequency(
    baffle_length, _baffle_width, baffle_thickness, baffle_modulus, baffle_density);

  echo(str(
    "baffle plate: ", _baffle_load, " N each, deflecting ", _baffle_deflection, " mm at the tip; ",
    "first mode ", _baffle_frequency, " Hz against ", stirred_tank_shaft_frequency(_baffle_rpm),
    " Hz shaft and ", stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins), " Hz blade passing"
  ));

  if (_baffle_deflection > _baffle_width / 10)
    echo(str(
      "WARNING baffle plate: ", _baffle_deflection, " mm of tip deflection is over a tenth of the ",
      _baffle_width, " mm plate. It is bending away from the swirl rather than blocking it; ",
      "thicken it - stiffness goes as the cube of thickness and the lock bore allows ",
      bayonet_baffle_width(head_bayonet, baffle_thickness, baffle_bore_clearance) > _baffle_width
        ? "more" : "no more", "."
    ));

  if (abs(_baffle_frequency - stirred_tank_shaft_frequency(_baffle_rpm)) < 0.3 * stirred_tank_shaft_frequency(_baffle_rpm)
   || abs(_baffle_frequency - stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins)) < 0.3 * stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins))
    echo(str(
      "WARNING baffle plate: its first mode at ", _baffle_frequency,
      " Hz is within 30% of a drive excitation. Thickness raises it as t^1.5 and length lowers it ",
      "as 1/L^2, so a thicker plate is the cheaper fix."
    ));

  // the port circle is sized against the plug's edge, so what it does not settle is whether
  // that many ports clear each other on it. The flange is the widest thing a port has, and it
  // carries the o-ring groove outboard of the bore, so it is what meets the neighbour first.
  _port_gap = 2 * port_circle_radius * sin(180 / lid_holes_n) - bayonet_flange_radius(head_bayonet) * 2;

  assert(
    _port_gap >= lid_holes_offset,
    str(lid_holes_n, " ports leave ", _port_gap, " mm between flanges on a ", port_circle_radius * 2, " mm circle; ", lid_holes_offset, " mm is the least this lid keeps.")
  );

  // The joint posts are bored through the flange, and where its edge falls is the assembly's to
  // set, so nothing here stops a bore running off it. Caught only incidentally today, and by the
  // frame complaining about its own wall, in another file.
  _post_reach = max([for (p = post_pts) norm(p)]) + post_hole_diameter / 2;

  assert(
    joint_outer_diameter / 2 >= _post_reach + lid_holes_offset,
    str(
      "Joint bores reach r ", _post_reach, " on a flange of r ", joint_outer_diameter / 2,
      "; ", lid_holes_offset, " mm is the least this lid keeps."
    )
  );

  // --- lid seal ---
  _gasket_ir = head_gasket_inner_radius(vessel_opening_diameter);
  _gasket_or = head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness);
  _groove_r = head_plug_oring_groove_radius(vessel_opening_diameter);
  _groove_w = head_plug_groove_width();
  _ring_id = _groove_r * 2; // 0% stretch; anything down to this over 1.05 still hugs the groove

  echo(str(
    "lid gasket: cut ", _gasket_ir * 2, " x ", _gasket_or * 2, " mm from ",
    gasket_sheet_name(lid_gasket_sheet), " (", gasket_sheet_thickness(lid_gasket_sheet),
    " mm), recess ", head_gasket_depth(), " mm deep (", lid_gasket_compression * 100, "% squeeze)"
  ));
  _plug_stretch = oring_stretch(oring_inner_diameter(lid_plug_oring), _ring_id);

  echo(str(
    "plug o-ring: ", oring_name(lid_plug_oring), " at ", _plug_stretch * 100, "% stretch. Groove takes ",
    "ID ", _ring_id, " mm / ", _ring_id / 25.4, " in down to ",
    _ring_id / 1.05, " mm / ", _ring_id / 1.05 / 25.4, " in (0-5% stretch)"
  ));

  // One ring is registered for the whole vessel registry while the groove is cut from each jar's
  // own bore, so what this catches is the ring being wrong for the jar, not the jar being wrong.
  // Closing it properly means carrying a plug ring per vessel row - see the audit.
  assert(
    _plug_stretch >= 0 && _plug_stretch <= 0.05,
    str(
      oring_name(lid_plug_oring), " is the wrong ring for this bore: its ",
      oring_inner_diameter(lid_plug_oring), " mm ID sits at ", _plug_stretch * 100,
      "% stretch on the ", _ring_id, " mm groove, which takes a ring of ", _ring_id / 1.05,
      " to ", _ring_id, " mm. Under 0 it sags out of the groove and over 5 it thins the cord."
    )
  );

  assert(
    _gasket_or > _gasket_ir,
    str("Gasket land margin of ", lid_gasket_land_margin, " mm leaves no gasket on a ", vessel_wall_thickness, " mm rim.")
  );
  assert(
    _gasket_ir > head_lid_plug_diameter(vessel_opening_diameter) / 2,
    "Gasket recess reaches inside the plug, so it would open into the vessel rather than seat on the rim."
  );
  assert(
    head_gasket_depth() < lid_flange_height,
    str("Gasket recess is ", head_gasket_depth(), " mm deep in a ", lid_flange_height, " mm flange.")
  );
  // and bounded below, which the assert above trivially satisfies at a negative depth
  assert(
    head_gasket_depth() > 0,
    str("Gasket recess is ", head_gasket_depth(), " mm deep at ", lid_gasket_compression * 100, "% squeeze.")
  );

  // the groove is cut from the bore, so a fatter cord walks inward toward the port bores; the
  // wall it must leave them is the same one the lid keeps everywhere else
  assert(
    _groove_r - (port_circle_radius + bayonet_lock_bore_radius(head_bayonet)) >= lid_holes_offset,
    str(
      "A ", oring_cross_section(lid_plug_oring), " mm cord puts the plug groove at r ", _groove_r, ", leaving ",
      _groove_r - (port_circle_radius + bayonet_lock_bore_radius(head_bayonet)),
      " mm to the port bores; ", lid_holes_offset, " mm is the least this lid keeps."
    )
  );
  assert(
    _groove_w < lid_plug_height,
    str("Plug o-ring groove is ", _groove_w, " mm wide and the plug is only ", lid_plug_height, " mm.")
  );

  // the gland a radial seal actually lives in is the groove's width by the distance from its
  // bottom out to the bore, which is what the cord has to fit inside once it is squeezed
  _plug_fill = oring_gland_fill(
    oring_cross_section(lid_plug_oring),
    _groove_w,
    oring_gland_depth(oring_cross_section(lid_plug_oring), lid_plug_oring_squeeze)
  );

  assert(
    _plug_fill <= 0.90,
    str("The plug o-ring fills ", _plug_fill * 100, "% of its gland; over 90 leaves the squeeze nowhere to go.")
  );

  // how much of the cord the groove is actually holding onto, which is the check against it
  // rolling out. Measured from the plug's own face, not from the bore it seals against.
  _plug_containment = oring_containment(
    oring_cross_section(lid_plug_oring),
    head_lid_plug_diameter(vessel_opening_diameter) / 2 - _groove_r
  );

  assert(
    _plug_containment >= 0.75,
    str("Only ", _plug_containment * 100, "% of the plug o-ring's section sits inside its groove; under 75 it rolls out.")
  );

  // The coupling decides where a port comes to rest, so a port carrying an orientation is only
  // as true as the coupling is keyed. Unkeyed, each of these locks just as willingly in any of
  // its seatings and the plate or the lean ends up somewhere the model never showed.
  _oriented_at = [for (i = [0:lid_holes_n - 1]) if (head_port_is_oriented(head_ports[i][0])) i];

  // checked before the keying assert below, which would otherwise report the missing helpers as
  // an undef seating count and send you looking in the wrong place
  assert(
    !is_undef(bayonet_pin_angles(head_bayonet)),
    "head: needs bayonet-lock-scad >= 0.11.0, for pin_angles and the keying functions"
  );

  assert(
    len(_oriented_at) == 0 || bayonet_is_keyed(head_bayonet),
    str(
      "Ports at ", _oriented_at, " carry an orientation, but the bayonet locks in ",
      bayonet_seating_count(head_bayonet), " indistinguishable seatings, so each would come to rest ",
      360 / bayonet_seating_count(head_bayonet), " degrees from where it is drawn. Key the interface."
    )
  );

  assert(
    len(_baffle_at) == 0 || _baffle_at == [for (k = [0:len(_baffle_at) - 1]) _baffle_at[0] + k * lid_holes_n / len(_baffle_at)],
    str("Baffles must come out equally spaced, but ", len(_baffle_at), " of them sit at ", _baffle_at, " of ", lid_holes_n, " holes.")
  );

  assert(
    baffle_length <= baffle_max_length,
    str("Baffle is ", baffle_length, " mm long and would reach the jar's floor; ", baffle_max_length, " mm is the most that clears it.")
  );

  assert(
    port_circle_radius + _baffle_width / 2 <= vessel_opening_diameter / 2 - baffle_neck_clearance,
    str("Baffle reaches ", port_circle_radius + _baffle_width / 2, " mm out, past the ", vessel_opening_diameter / 2 - baffle_neck_clearance, " mm the jar's neck allows.")
  );

  // Every lock in the lid's bores, in the port datum. The bore is bayonet_port_hole_fudge
  // narrower than the lock, so this unions into the lid rather than dropping into it.
  module lid_locks() {
    for (i = [0:lid_holes_n - 1])
      head_port_at(i, vessel_opening_diameter)
        bayonet_port(type=head_bayonet, part="lock", panel_thickness=lid_thickness);
  }

  // The lid part: the blank, pocketed for the bearing and shaft and bored for the ports, with
  // its locks. One printed piece - the channels are the walls of its bores, so a lid without
  // them exports as twelve plain holes and nothing will lock into it.
  if (render_lid || render_all) {
    color(prints2_color)
      union() {
        rotate([0, 180, 0])
          lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, joint_outer_diameter, post_pts, post_hole_diameter);
        lid_locks();
      }
  }

  // the locks alone, for looking at the channels the assembled lid buries
  if (render_bayonet_lock && !(render_lid || render_all)) {
    color(prints2_color)
      lid_locks();
  }

  // The EPDM. Each is drawn at its free size on the diameter it is installed at, so it overlaps
  // what it seals against by exactly the squeeze its gland was cut for - that overlap is the
  // check. Kept behind their own flag so a part export never picks up a purchased ring.
  if (render_seals || render_all) {
    // rim gasket, standing proud of the flange by what the recess squeezes out of it
    translate([0, 0, -lid_flange_height - (gasket_sheet_thickness(lid_gasket_sheet) - head_gasket_depth())])
      sheet_gasket(_gasket_ir * 2, _gasket_or * 2, gasket_sheet_thickness(lid_gasket_sheet));

    // plug o-ring, stretched onto its groove and reaching past the plug into the glass
    translate([0, 0, -lid_flange_height - lid_plug_height / 2])
      oring(lid_plug_oring, id=_ring_id);

    // port o-rings, each seated against the outer wall of its gland
    for (i = [0:lid_holes_n - 1])
      head_port_at(i, vessel_opening_diameter)
        translate([0, 0, bayonet_gland_depth(head_bayonet) / 2])
          oring(
            bayonet_oring(head_bayonet),
            id=(bayonet_gland_outer_radius(head_bayonet) - bayonet_oring_cs_diameter(head_bayonet)) * 2
          );
  }

  // Port pin halves. Each shares the lock's datum, so it needs no placement beyond its hole
  // centre; port_position only turns it about its own axis, between locked and entry.
  if (render_tube_pinlock || render_probe_pinlock || render_thermocouple_pinlock || render_baffle_pinlock || render_all) {
    _port_turn = (port_position == "entry") ? bayonet_entry_rotation(head_bayonet) : 0;

    for (i = [0:lid_holes_n - 1]) {
      _port = head_ports[i];
      _show =
      render_all || (_port[0] == "tube" && render_tube_pinlock) || (_port[0] == "probe" && render_probe_pinlock) || (_port[0] == "thermocouple" && render_thermocouple_pinlock) || (_port[0] == "baffle" && render_baffle_pinlock);

      if (_show)
        color(prints1_color)
          head_port_at(i, vessel_opening_diameter)
            rotate([0, 0, _port_turn])
              head_port(_port, lid_thickness, _baffle_width);
    }
  }

  // motor and shaft
  if (render_motor || render_all) {

    // Motor, flipped so it hangs off the top of the mount; dc_motor mounts its own gearbox via
    // the registered type. motor_mount() takes an overall height, so the mount's top face sits
    // at motor_mount_height and the gearbox output face lands flush on it, with the output boss
    // dropping into the faceplate's centre hole.
    translate([0, 0, motor_mount_height + dc_motor_length(head_motor) + gearbox_length(head_gearbox)])
      rotate([0, 180, 0])
        dc_motor(head_motor);
  }

  // motor mount; the module does not color itself, so all three telescoping parts take this one
  if (render_motor_mount || render_all) {
    color(prints1_color)
      motor_mount(
        height=motor_mount_height,
        body_diameter=motor_mount_body_diameter,
        wall_thickness=motor_mount_wall_thickness,
        screws_diameter=gearbox_screw_diameter(head_gearbox),
        base_screw_hole_diameter=head_motor_mount_screw_hole_diameter(),
        shaft_diameter=shaft_diameter(head_shaft),
        motor_faceplate_bolt_circle_dia=gearbox_faceplate_bolt_circle_dia(head_gearbox),
        motor_boss_diameter=gearbox_out_boss(head_gearbox)[0],
        coupling_allowance=motor_mount_coupling_allowance,
        facets=motor_mount_facets,
        part_render=motor_mount_part_to_render
      );
  }

  // The joint holding the mount down: inserts heat-set into the lid from this face, screws
  // dropped through the mount's flange into them. The screw head lands on the counterbore floor
  // partway down that flange, so it is that depth, not the whole flange, the screw has to clear.
  _mm_grip = motor_mount_base_screw_grip(motor_mount_wall_thickness);

  // one placement for both halves of the joint, so a screw cannot land anywhere but in its insert
  module motor_mount_fastener_at() {
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([head_motor_mount_screw_radius(), 0, 0])
          children();
  }

  // Separate flags because the two have different lives: the insert is set into the lid once and
  // stays, while the screw comes out whenever the mount does. The insert drawn alone is also how
  // the interference against its hole reads on screen.
  if (render_motor_mount_inserts || render_all)
    motor_mount_fastener_at()
      insert(motor_mount_base_insert);

  if (render_motor_mount_screws || render_all)
    motor_mount_fastener_at()
      translate([0, 0, _mm_grip])
        screw(motor_mount_base_screw, screw_length(motor_mount_base_screw, _mm_grip, 0, insert=motor_mount_base_insert));

  // shaft coupling
  if (render_shaft_coupler || render_all) {

    translate(
      [0, 0, shaft_protrusion + shaft_shaft_coupling_offset / 2]
    )

      shaft_coupling(type=shaft_coupler, colour="MediumBlue");
  }

  // external shaft
  if (render_ext_shaft || render_all) {

    color("grey")
      translate([0, 0, -head_punt_top_depth(lid_flange_height, vessel_internal_height) + shaft_jar_punt_clearance])
        cylinder(h=shaft_length(head_shaft), d=shaft_diameter(head_shaft), center=false);
  }

  // Radial tap holes through the collar. Plain cylinders at the screw's tap radius - no thread is
  // modelled, the screw cuts its own. They start on the axis so they open into the bore.
  //
  // In the collar and not in the hub, because the fins pass through the hub. Each fin is resize()d
  // individually, which scales its y by a different factor than its x and so distorts the angle it
  // ends up at, and it is then twisted on top of that - so where the gaps between fins fall is not
  // something a formula gets right across the registry. Above the blades there are no fins at any
  // angle, which is the same answer for every row in impellers.scad.
  module head_impeller_set_screw_holes() {
    _r = set_screw_tap_radius(impeller_set_screw) + impeller_set_screw_allow;
    translate([0, 0, impeller_height / 2 + impeller_collar_height / 2])
      for (a = impeller_set_screw_at)
        rotate([0, 0, a])
          rotate([0, 90, 0])
            cylinder(r=_r, h=impeller_hub_radius + z_fight, $fn=32);
  }

  module head_impeller() {
    color(prints2_color)
      difference() {
      union() {
        // main impeller body
        impeller(
          radius=impeller_radius,
          height=impeller_height,
          fins=impeller_n_fins,
          twist=impeller_twist_ang,
          fin_width=impeller_fin_width,
          center_hub_radius=impeller_hub_radius,
          center_hole_radius=impeller_shaft_hole_radius,
          center_hole_radius_lower=impeller_shaft_hole_radius - impeller_shaft_radius_interference,
          blade_pitch=impeller_is_twisted(head_impeller_type) ? undef : impeller_blade_angle(head_impeller_type),
          blade_width=impeller_blade_width
        );
        // top ring to connect the fin tops for mechanical stability
        translate([0, 0, impeller_height / 2 - impeller_fin_width / 2])
          linear_extrude(impeller_fin_width, center=true)
            difference() {
              circle(r=impeller_radius + impeller_fin_width, $fn=64);
              circle(r=impeller_radius, $fn=64);
            }
        // collar for the set screws, standing clear of the blades
        translate([0, 0, impeller_height / 2 - z_fight])
          difference() {
            cylinder(r=impeller_hub_radius, h=impeller_collar_height + z_fight, $fn=64);
            translate([0, 0, -z_fight])
              cylinder(r=impeller_shaft_hole_radius, h=impeller_collar_height + 3 * z_fight, $fn=64);
          }
      }
        head_impeller_set_screw_holes();
      }
  }

  // impellers
  if (render_impeller || render_all) {
    translate([0, 0, -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height) + _impeller_clearance]) {
      head_impeller();

      // mirrored, not turned over: handedness sets which way a blade pumps and no rotation changes
      // it, so this is what makes the upper impeller push down against the lower one pushing up
      translate([0, 0, impeller_spacing])
        mirror([0, 1, 0])
          head_impeller();
    }
  }
}

reactor_vessel = jar_10L_220x305; // [generic_vessel, jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]

// The two the assembly chooses rather than derives; everything below follows from them.
_preview_flange_height = 8;
_preview_wall_thickness = 37;
_preview_n_rods = 4;
_preview_bolt = M8_hex_screw;

_preview_bolt_circle = frame_bolt_circle_diameter(vessel_diameter(reactor_vessel));
_preview_post_pts = bolt_pattern_pts(
  bolt_post_count(
    _preview_n_rods, screw_radius(_preview_bolt) * 2, _preview_bolt_circle,
    _preview_flange_height, head_gasket_factor()
  ),
  _preview_bolt_circle
);

head(
  lid_flange_height=_preview_flange_height,
  vessel_outer_diameter=vessel_diameter(reactor_vessel),
  vessel_opening_diameter=vessel_opening_diameter(reactor_vessel),
  vessel_wall_thickness=vessel_thickness(reactor_vessel),
  vessel_internal_height=vessel_internal_height(reactor_vessel),
  vessel_punt_height=vessel_punt_height(reactor_vessel),
  joint_outer_diameter=frame_outer_diameter(vessel_diameter(reactor_vessel), _preview_wall_thickness),
  post_pts=_preview_post_pts,
  post_hole_diameter=frame_rod_hole_diameter()
);
