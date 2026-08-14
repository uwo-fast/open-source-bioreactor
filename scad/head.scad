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
include <purchased/gasket_sheets.scad>;

include <custom/bayonet_interfaces.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/inserts.scad>; // F1BM4 type + insert()
include <NopSCADlib/vitamins/screws.scad>; // M4_cap_screw type + screw()
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

// The distance between the bottom of the jar (punt) and the bottom of the shaft
shaft_jar_punt_clearance = 5;
// length of the shaft for the impeller
shaft_length = 400;
// diameter of the shaft
shaft_diameter = 8.0;
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
// Impeller height, i.e. the axial span of the blade. UNCHARACTERISED, in the same way the twist
// angle below is: no citable W/D or blade-height ratio was found for an axial impeller, and none
// at all for a twisted extrusion. The classic ratios (w = D/4 or D/5) are for flat Rushton blades
// and do not describe this shape.
impeller_height = 60;
// Number of fins. 4 is mid-range and measured: on otherwise identical folded-blade axial
// impellers, Po runs 0.79 / 0.99 / 1.34 for 3 / 4 / 6 blades, so going to 6 costs about 35% more
// power at the same speed and diameter. Fort et al. 2002, doi:10.14311/380 (see docs/references.md)
impeller_n_fins = 4;
// Twist angle of each fin. UNCHARACTERISED - no citable source recommends any twist value for a
// blade of this kind, and a search of the indexed literature turned up almost nothing on twisted
// impeller blades at all. Rather than borrow a number from work on a different geometry, what can
// honestly be said is derived from this geometry itself:
//
// linear_extrude(twist=) sweeps a constant-pitch helicoid, so this is a PITCH specifier, not a
// blade angle. The blade angle b, measured from the plane of rotation, therefore varies with
// radius as tan b = P / (2*pi*r), where the pitch P is the axial advance per full turn:
//
//   at 55 deg over a 60 mm impeller, P = 393 mm, P/D = 4.2
//   b runs 83 deg at the hub, 73 at 0.4R, 62 at 0.7R, 53 at the tip
//
// A flat pitched blade sits at one angle everywhere; the classic turbines are tested at 24, 35
// and 45. This blade is steeper than 45 at every radius, so it is a twisted paddle biased toward
// radial pumping rather than the axial impeller the D/T guidance above is written about. Getting
// a 45 deg tip would take roughly 73 deg of twist, not 55.
//
// What would settle it is a bench measurement, not a reference: Po = P/(rho*N^3*D^5) from shaft
// power at three or four known speeds in water, repeated across printed variants, gives a real
// power-number curve for this exact blade. See docs/agitation.md.
impeller_twist_ang = 55;
// width of each fin blade
impeller_fin_width = 4;
// size of the center hub
impeller_hub_radius = 7.5;
// allowance for the shaft hole
impeller_shaft_allow = 0.4;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;
// centre to centre spacing of the two impellers, in impeller diameters
impeller_spacing_factor = 1.0;
// Culture depth as a fraction of the vessel's internal height. An operating choice, not geometry -
// nothing in this model sets a fill line - but the mean dissipation echo needs a volume, and the
// full internal volume would understate it. 0.8 leaves the usual headspace for foam and gas.
culture_fill_fraction = 0.8;

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
head_ports = [
  ["thermocouple", 3],
  ["probe", 0, ph_lab_g2],
  ["probe", 0, do_lab_g2],
  ["baffle", 0],
  ["tube", 3],
  ["tube", 3],
  ["tube", 2.4],
  ["baffle", 0],
  ["tube", 2.4],
  ["tube", 1.5],
  ["tube", 1.5],
  ["baffle", 0],
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

// clearance between the top of the upper impeller and the bottom of the baffle
baffle_impeller_clearance = 2;
// clearance between the jar's neck bore and the baffle's outer corner
baffle_neck_clearance = 1.5;
// clearance between the lock's bore and the plate dropping through it on assembly
baffle_bore_clearance = 0.2;
// how far the plate hangs below the port's bottom face; raise it until the print goes floppy
baffle_length = 100;
// thickness of the plate
baffle_thickness = 4;
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

// The drive stack, from the lid's outer face up. head() builds against these rather than
// recomputing them, and anything that has to make room for an assembled reactor reads them back
// out - the cart is the one that does.
function head_shaft_protrusion(vessel_internal_height) =
  shaft_length - (vessel_internal_height - shaft_jar_punt_clearance);
function head_motor_mount_height(vessel_internal_height) =
  gearbox_output_shaft_length(dc_motor_gearbox(head_motor))
  + head_shaft_protrusion(vessel_internal_height) + shaft_shaft_coupling_offset;
// top of the motor, which is the highest thing on the reactor
function head_stack_height(vessel_internal_height) =
  head_motor_mount_height(vessel_internal_height)
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
          cylinder(d=shaft_diameter + bearing_hole_allowance, h=_thickness + z_fight);

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
module head_port(port, panel_thickness) {
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
      bore_clearance=baffle_bore_clearance
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

module head(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, vessel_internal_height, joint_outer_diameter, post_pts, post_hole_diameter) {

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
  impeller_diameter = stirred_tank_impeller_diameter(_vessel_bore, impeller_bore_ratio);
  impeller_radius = impeller_diameter / 2; // radius of the impeller

  // radius of the shaft hole in the impeller
  impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_allow) / 2;

  impeller_spacing = stirred_tank_impeller_spacing(impeller_diameter, impeller_spacing_factor);

  // Where this build sits against the literature. Reported rather than asserted: a ratio outside
  // the band may be the thing being studied, and refusing to draw it would make the model less
  // useful, not safer. What is asserted is only what cannot physically work - the span check
  // below, which stops an impeller too wide to pass the vessel's mouth.
  _impeller_ratio = stirred_tank_ratio(impeller_diameter, _vessel_bore);
  _ratio_band = stirred_tank_ratio_band();
  _ratio_band_axial = stirred_tank_ratio_band_axial();
  _spacing_band = stirred_tank_spacing_band();

  echo(str(
    "impeller: ", impeller_diameter, " mm in a ", _vessel_bore, " mm bore, D/T ", _impeller_ratio,
    " (band ", _ratio_band[0], "-", _ratio_band[1], ", axial ", _ratio_band_axial[0], "-",
    _ratio_band_axial[1], "); spacing ", impeller_spacing_factor, " D (band ", _spacing_band[0],
    "-", _spacing_band[1], ")"
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

  // What the drive does to the culture. Reported, never asserted: the margin against damage runs
  // to orders of magnitude, and why there is no tip-speed limit anywhere here is in
  // utils/stirred_tank.scad's header. What is worth seeing at render is where the operating point
  // lands, because the band that earns its power turns out to be narrow.
  //
  // Re and tip speed are as good as the speed they are handed. Everything past Po is an estimate:
  // the power number is measured on a folded axial blade rather than this twisted one, and P is
  // one impeller's, where the stacked pair draws more - though less than double, being closer
  // than the spacing at which two impellers stop interacting. See docs/agitation.md.
  _culture_volume = stirred_tank_volume(_vessel_bore, vessel_internal_height * culture_fill_fraction);
  _impeller_po = stirred_tank_power_number_folded_axial_4();
  _impeller_x = stirred_tank_dissipation_factor_pitched_blade();
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

  // this impeller is tall for its diameter, so the pair collide before they reach the 0.5 diameter
  // spacing at which they would stop behaving as two impellers
  assert(
    impeller_spacing > impeller_height,
    str("Impellers overlap: ", impeller_spacing, " mm apart but ", impeller_height, " mm tall.")
  );

  assert(
    shaft_jar_punt_clearance + impeller_height + impeller_spacing <= vessel_internal_height,
    str(
      "Upper impeller reaches ", shaft_jar_punt_clearance + impeller_height + impeller_spacing,
      " mm above the punt, past the ", vessel_internal_height, " mm the vessel has."
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
  shaft_protrusion = head_shaft_protrusion(vessel_internal_height);

  // What the shaft leaves above the lid for the coupling to grip. At or below zero the shaft ends
  // inside the vessel and there is nothing for the motor to couple to.
  assert(
    shaft_protrusion > 0,
    str("Shaft ends ", -shaft_protrusion, " mm below the lid's outer face, so the coupling cannot reach it.")
  );

  // The coupling's two bores are catalogue facts and the shafts they go on are set elsewhere, so
  // nothing but this stops a coupling that fits neither end.
  assert(
    sc_diameter1(shaft_coupler) == gearbox_output_shaft_dia(head_gearbox) &&
    sc_diameter2(shaft_coupler) == shaft_diameter,
    str(
      "The ", shaft_coupler[0], " coupling bores ", sc_diameter1(shaft_coupler), " and ",
      sc_diameter2(shaft_coupler), " mm, for a ", gearbox_output_shaft_dia(head_gearbox),
      " mm gearbox shaft and a ", shaft_diameter, " mm impeller shaft."
    )
  );

  // the height that the motor coupling assembly requires
  motor_mount_height = head_motor_mount_height(vessel_internal_height);
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

  // centred on its port the plate crosses the circle the impellers sweep, so it stops above them
  baffle_max_length =
  vessel_internal_height - shaft_jar_punt_clearance - impeller_height - impeller_spacing - baffle_impeller_clearance - lid_thickness;

  _baffle_at = [for (i = [0:lid_holes_n - 1]) if (head_ports[i][0] == "baffle") i];

  // the plate's width is settled by the lock it hangs from, so it is read back, not chosen here
  _baffle_width = bayonet_baffle_width(head_bayonet, baffle_thickness, baffle_bore_clearance);

  echo("baffles: ", len(_baffle_at), " x ", _baffle_width, " mm wide, up to ", baffle_max_length, " mm long");

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
    str("Baffle is ", baffle_length, " mm long and would reach the upper impeller; ", baffle_max_length, " mm is the most that clears it.")
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
              head_port(_port, lid_thickness);
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
        shaft_diameter=shaft_diameter,
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
      translate([0, 0, -vessel_internal_height + shaft_jar_punt_clearance])
        cylinder(h=shaft_length, d=shaft_diameter, center=false);
  }

  module head_impeller() {
    color(prints2_color)
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
          center_hole_radius_lower=impeller_shaft_hole_radius - impeller_shaft_radius_interference
        );
        // top ring to connect the fin tops for mechanical stability
        translate([0, 0, impeller_height / 2 - impeller_fin_width / 2])
          linear_extrude(impeller_fin_width, center=true)
            difference() {
              circle(r=impeller_radius + impeller_fin_width, $fn=64);
              circle(r=impeller_radius, $fn=64);
            }
      }
  }

  // impellers
  if (render_impeller || render_all) {
    translate([0, 0, -shaft_length + shaft_protrusion + impeller_height / 2]) {
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
  joint_outer_diameter=frame_outer_diameter(vessel_diameter(reactor_vessel), _preview_wall_thickness),
  post_pts=_preview_post_pts,
  post_hole_diameter=frame_rod_hole_diameter()
);
