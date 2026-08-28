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
use <utils/gas_supply.scad>;
use <utils/meridian.scad>;
use <utils/gasket_load.scad>;
use <custom/sheet_gasket.scad>;
use <custom/gasket_cutter.scad>;

use <custom/motor_mount.scad>;
use <custom/bayonet_port.scad>;
use <custom/bayonet_probe_port.scad>;
use <custom/bayonet_thermocouple_port.scad>;
use <custom/bayonet_baffle_port.scad>;
use <custom/impeller.scad>;
use <custom/sparge_ring.scad>;

include <purchased/dc_motors.scad>;
include <purchased/gearboxes.scad>;
include <purchased/vessels.scad>;
include <purchased/atlas_probes.scad>;
include <purchased/thermocouple_probes.scad>;
include <purchased/orings.scad>;
include <purchased/heat_set_inserts.scad>;
include <purchased/steel_tubes.scad>;
include <purchased/shaft_couplings.scad>;
include <purchased/shafts.scad>;
include <purchased/gasket_sheets.scad>;

include <custom/bayonet_interfaces.scad>;
include <custom/impellers.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/inserts.scad>; // F1BM4 type + insert()
include <NopSCADlib/vitamins/screws.scad>; // M4_cap_screw type + screw()
include <purchased/set_screws.scad>; // after screws.scad - the rows bind M4_grub_screw
include <purchased/air_pumps.scad>;
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
render_bearing = false; // the 608 in the lid's pocket
render_ext_shaft = false;
render_impeller = false;
// Which of the pair, for a per-part export. They are mirror images and therefore two different
// parts, so one STL of both is an assembly picture rather than something to print. Same shape as
// motor_mount_part_to_render above, and useful interactively for the same reason.
impeller_to_render = "both"; // [both, lower, upper]
render_set_screws = false; // the grub screws holding each impeller to the shaft
render_bayonet_lock = false;
render_tube_pinlock = false;
render_thermocouple_pinlock = false;
render_probe_pinlock = false;
// Narrows the pin halves above to ONE port, named by function - "air_in", "do_probe", "baffle_1".
// The type flags render a whole class at once, which is the right thing on screen and the wrong
// thing for a print file: five tube ports differ by bore and by what is engraved on them. Baffles
// all carry the same function, so they take an index suffix. "" is every port the flags allow.
port_to_render = "";
// Which piece of a baffle plate, for the same reason. A plate prints in segments and undef emits
// them all interlocked, which is the assembled part rather than something to put on a bed.
baffle_segment_to_render = undef;
render_probes = false; // the Atlas probes themselves, hanging in their collets
render_baffle_pinlock = false;
render_seals = false; // the EPDM parts: rim gasket, plug o-ring, port o-rings
// The culture, at the fill line the volume is reported for. Not in render_all: it is not a part,
// and translucent or not it stands over everything immersed in it.
render_culture = false;
// The templates the rim gasket is cut with. Deliberately NOT in render_all: it is a tool, and the
// assembly is the reactor. Turn it on beside render_seals to see the ring against what cuts it.
render_gasket_cutter = false;
// Which of its two discs. "all" stands them side by side, which is the picture, not the print.
gasket_cutter_part_to_render = "all"; // [all, outer, inner]
render_sparger = false; // the ring in the inter-impeller gap and its feed arm
// The 316 SS riser and its support, which are BOUGHT and cut to length rather than printed. Their
// own flag because render_sparger is what a per-part export asks for, and a print file with two
// steel tubes in it is not a print file - it stood 197 mm tall on a ring whose section is 10.
render_sparge_tubes = false;

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
// The gasket's width is capped rather than simply taken from the rim. Squeezing a wide gasket costs
// far more than squeezing a narrow one - the area grows with the width and the stiffness with its
// square, approaching a cube law once the gasket is much wider than it is thick - and all of it
// lands on glass. Six millimetres seals; the 12 mm wall on jar_6p5gal would otherwise ask for ten,
// which is 4.4x the force (87.9 kN against 20.1) at 1.7x the width.
lid_gasket_width_max = 6;
// Below this a gasket is fiddly to cut and will not stay in its recess. Reported, not enforced:
// what is available is the jar's rim, and this file does not get to choose how thick the glass is.
lid_gasket_width_min = 3;
// the o-ring centring the plug in the neck. Its groove is cut from the jar's bore rather than
// from the ring, so the ring is stretched onto it and head() checks that stretch rather than
// deriving from it. A 3.53 cord digs too deep for this plug and trips the wall assert below
// Which ring centres the lid plug. undef derives it: any registered ring whose free ID lands this
// jar's groove between zero and five percent stretch. Set a row to pin one.
//
// It has to vary with the jar. The groove is cut from the mouth, so its diameter follows the mouth
// directly, and no gland depth can absorb that - closing a 7 mm difference in mouth would want a
// gland several times the cord's own diameter. One registered ring therefore seals one mouth.
lid_plug_oring = undef;
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
// Which impeller shaft. undef derives it: the shortest registered row that still leaves the
// coupling something to grip on this vessel. Set a row to pin one instead - the registry carries
// 200/400/600/800 mm of the same part, and a taller jar simply wants a longer cut.
head_shaft = undef;
// adjust distance between the motor and the shaft coupling
shaft_shaft_coupling_offset = 0; // can be positive or negative
// the registered coupling joining the gearbox output shaft to the impeller shaft
shaft_coupler = shaft_coupler_8x8_rigid;

/* [Motor Mount Parameters] */

// Outer diameter of the mount body. Left at 56 deliberately after being asked what it could be.
//
// It can go to 42 - below that the mount's own base inserts run into the bearing pocket, which the
// assert in head() catches at 0.15 mm of clearance. But shrinking buys nothing worth having.
// Deflection goes as the cube of height over diameter, and that ratio is calibrated against the
// build in hand at 2.3; 42 would take jar_10L to 2.9, against a warning that starts at 3.
//
// It does not rescue the narrow jars either, which is what the question was really about. Their
// port flanges leave 35.4 mm on jar_1gal_155 and 27.1 on jar_1p5L, so they are 6.6 and 14.9 mm of
// diameter short of the floor, not a millimetre. Neither can carry a top-entry drive on its lid at
// any mount size - see TODO.md, where that is answered by changing the agitation rather than the
// mount.
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
// 280.8 mm bore caps the ratio at 0.4879, so 0.45 leaves 10.64 mm to actually pass it through.
// Every other jar tolerates 0.64 to 0.87. Those caps read 0.4594 and 0.59-0.82 for as long as the
// mouth assert went on charging 8 mm for a tip ring that had been moved inboard of the blades -
// the ratio was never in danger, but the headroom it was picked on was understated by 8 mm.
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

// Which way the shaft turns, right-handed about +Z: +1 is counter-clockwise seen from above, from
// the motor end. A DESIGN DECLARATION rather than a property of any part - a pitched blade
// reverses its pumping when the shaft reverses, which is how Birch & Ahmed reversed theirs, "by
// changing the direction of rotation of the stirrer". The motor will turn either way, so the
// direction has to be written down somewhere, and everything downstream reads it from here.
//
// It is not arbitrary in its consequences. The two impellers are mirror images, so they always
// oppose each other; what the rotation picks is WHICH WAY. At +1 the lower pumps up and the upper
// pumps down and their flows CONVERGE on the gap between them, which is the one arrangement where
// a single sparge ring sits in both impellers' discharge - Birch & Ahmed put a ring above an
// up-pumping blade and below a down-pumping one. Reverse it and the flows diverge, and that same
// rule would demand two rings.
head_shaft_rotation = 1;
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
// How much culture is in the jar. An operating choice rather than geometry, but not a free one:
// every process number this model reports is per unit volume, so the fill line sets them all.
//
// TWO WAYS TO SAY IT, and they are not equally good. A WORKING VOLUME in litres is what a person
// actually pours and what another builder can repeat - "we ran 8.0 L" means the same thing on
// someone else's jar. A fraction of internal height does not: it lands on a different volume in
// every vessel, and it is only a proxy for the volume in the first place. So working volume pins
// it when set, and the fill height is solved back from the jar's own profile.
//
// The fraction stays as the DERIVATION, undef working volume, because it is the only one that
// scales across the registry - a litre figure that suits jar_10L will not fit jar_1p5L, and every
// registered vessel has to build. 0.8 leaves the usual headspace for foam and gas.
// 8.25 L on this jar. A quarter-litre figure is easy to pour, easy to repeat, and sits close
// enough to what the fraction was giving that nothing downstream moves much - coverage over the
// upper impeller stays at 0.555 D against the 0.5 this project holds, where a round 8.0 would have
// put it at 0.479 and spent that margin for the sake of a tidier number.
culture_working_volume = 8.25; // litres; undef derives from the fraction below
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

// What sits at each bayonet lock on the lid, going around it.
// Each entry is [function, type, bore_radius], plus a fourth slot for "probe". The FUNCTION is what
// the port is for and is this table's identity, the same way a name leads every other registered
// row; the type is only how it is built. Two ports can share a type and never a purpose, so the
// function is what the rest of the file looks a port up by - see head_port_index(). Baffles are the
// exception and all carry the same "baffle", because being a baffle is the whole of their purpose.
//   "tube"         -> generic bayonet port, bore_radius sets the tube through-hole
//   "probe"        -> atlas probe holder (flex collet); bore is swallowed by the connector cut,
//                     so 0, and the third slot is the registered probe it is cut for
//   "thermocouple" -> NPT thread mount, bore_radius is the through-hole the thermocouple passes down
//   "baffle"       -> blind port carrying a swirl baffle, bore 0 since nothing passes through it.
//                     However many are listed, they have to come out equally spaced, so their
//                     count has to divide the port count; the assert in head() enforces it.
// Four baffles at 90 degrees, which on twelve ports means every third one. That leaves the other
// eight as four adjacent PAIRS, one between each baffle, and the pairs are what the functional
// grouping below is built on. Derivation and the checks against it: docs/ports-layout.md.

// The riser: a straight rigid tube from the lid port down into the sparge ring's socket. Rigid and
// not flexible tubing because it is the only thing holding the ring - nothing else in the vessel
// touches it - so it is structure as much as gas path.
//
// A registered row, so the OD, the bore and the part number all come off one part rather than
// being three numbers that have to agree. It was 4 x 2.5 mm as two literals, which is a size
// nobody sells: at 4 mm OD the catalogue offers 0.25, 0.4 and 0.5 mm walls and no 0.75. Wall is a
// stiffness choice here rather than a pressure one - see the support report in head() - and 0.5 is
// the thickest the 4 mm size comes in, so it keeps the most of it and survives cutting best.
//
// It sits up here rather than with the rest of the sparger because the two gas ports below are
// bored for it, and OpenSCAD gives a table no value assigned under it.
sparge_riser_tube = steel_tube_welded_4x0p5;

// What the two gas ports are bored to, and a GUIDE rather than a grip: flexible tubing pressed
// into a printed bore deforms and holds itself there, a ground steel tube cannot. The old literal
// 3 was a hose radius on a port no hose enters - the supply line pushes over the riser's proud end
// instead - so a 4 mm tube hung in a 6 mm hole with 2 mm of slack.
tube_port_riser_bore = steel_tube_od(sparge_riser_tube) / 2 + 0.2; // 0.2 as the bearing hole takes

// What closes the annulus that fit leaves. A rod seal rather than a face one: it sits in a
// counterbore at the lid's inner face and seals on the tube, so its ID is the tube's OD and head()
// checks the two against oring_stretch rather than trusting the pair. Without it the lid carries
// two open holes into the headspace, which is a filter on the air in and none of it on the way out.
tube_port_riser_oring = oring_4x1p5_epdm;

head_port_set_full = [
  ["air_out",     "tube",         tube_port_riser_bore], //   0 deg
  ["baffle",      "baffle",       0           ], //  30
  ["do_probe",    "probe",        0, do_lab_g2], //  60      opposite the air inlet
  ["temperature", "thermocouple", 3, mcmaster_1245N31_thermocouple_probe], //  90  beside DO, which compensates from it
  ["baffle",      "baffle",       0           ], // 120
  ["ph_probe",    "probe",        0, ph_lab_g2], // 150      away from both dosing lines
  ["media",       "tube",         1.5         ], // 180      also the spare
  ["baffle",      "baffle",       0           ], // 210
  ["air_in",      "tube",         tube_port_riser_bore], // 240   the sparger hangs from this one
  ["acid",        "tube",         2.4         ], // 270
  ["baffle",      "baffle",       0           ], // 300
  ["base",        "tube",         2.4         ], // 330
];

// What a narrow jar carries instead. Six ports at 60 degrees, no baffles, no dosing pair - a mouth
// under about 142 mm cannot hold four baffles beside two O16 probes at any port count, and under
// 98 mm it cannot hold a baffle beside them at all. See docs/ports-layout.md for where those come
// from. What is given up is pH CONTROL, not pH measurement; both probes stay.
//
// The order is not arbitrary. The two probes are the only std flanges here, so they are put
// opposite each other and never adjacent, which leaves every pair std-against-mini and buys 10 mm
// of smallest mouth. DO still sits opposite the air inlet and the thermocouple still sits beside
// DO, which are the two heuristics from the twelve-port layout that survive at six.
//
// Its thermocouple is 1/8 NPT where the full set's is 1/2, and that is what lets both survive. A
// 1/2 NPT mount needs a std flange to stand on, which would make three std ports out of six; three
// of six can only be kept apart by strict alternation, and alternating puts the thermocouple two
// ports from DO instead of beside it. On twelve ports there is no such cost - the binding pair is
// already baffle-against-probe - so the full set keeps the 1/2 NPT thread.
head_port_set_reduced = [
  ["do_probe",    "probe",        0, do_lab_g2], //   0 deg  opposite the air inlet
  ["air_out",     "tube",         tube_port_riser_bore], //  60
  ["media",       "tube",         1.5         ], // 120      also the spare
  ["air_in",      "tube",         tube_port_riser_bore], // 180   the sparger hangs from this one
  ["ph_probe",    "probe",        0, ph_lab_g2], // 240
  ["temperature", "thermocouple", 3, mcmaster_3872K129_thermocouple_probe], // 300  beside DO
];

// Which set this lid carries. undef derives it from the mouth, which is the honest default: what
// decides it is whether the flanges clear each other, and that is geometry rather than preference.
// Set it to a table to pin one - an operator swapping a dosing line for a second gas line is
// choosing what to put in each port, which is theirs to choose and not this file's.
head_ports = undef;

// how many bayonet locks the lid carries. The list above is the statement of it, so this counts
// it rather than repeating it; the assert in head() still catches an override that disagrees
// The sets this lid knows, widest first, so the search below takes the fullest that fits.
function head_port_sets() = [head_port_set_full, head_port_set_reduced];

// Whether a set's flanges clear each other on this mouth. The chord is the same between every
// pair and the flanges are not, so what decides it is the worst ADJACENT PAIR - see head()'s own
// assert, which is this same expression on the set that was chosen.
function head_port_set_fits(vessel_opening_diameter, ports) =
  let (
    _n = len(ports),
    _chord = 2 * head_port_circle_radius(vessel_opening_diameter, ports) * sin(180 / _n)
  ) min([
      for (i = [0:_n - 1])
        _chord
        - bayonet_flange_radius(head_port_interface(ports[i]))
        - bayonet_flange_radius(head_port_interface(ports[(i + 1) % _n]))
    ]) >= lid_holes_offset;

function head_port_set_for(vessel_opening_diameter) =
  let (_fit = [for (p = head_port_sets()) if (head_port_set_fits(vessel_opening_diameter, p)) p])
    len(_fit) == 0 ? undef : _fit[0];

// The table this lid actually carries, and how many ports are on it.
function head_ports_for(vessel_opening_diameter) =
  is_undef(head_ports) ? head_port_set_for(vessel_opening_diameter) : head_ports;
function head_ports_n(vessel_opening_diameter) = len(head_ports_for(vessel_opening_diameter));

// Which bayonet a port mates to. Every port shared one until the family outgrew it: std is sized
// for a 16 mm Atlas probe body, and what limits a port circle is the worst ADJACENT PAIR of
// flanges, so putting a 2.4 mm dosing line on a probe-sized flange cost the whole lid. Derived
// rather than registered - what a port has to pass is already in its row.
// Material the pin half keeps around its own bore.
port_bore_wall = 2;

// Smallest first, so the search below returns the least interface that will do.
function head_interfaces_by_size() = [bayonet_mini, bayonet_midi, bayonet_std];

// Two ways a port can be too big for an interface, and they are not the same test. What passes
// THROUGH has to clear the bore; what stands ON TOP has to fit the flange - an NPT mount is bolted
// to the flange's outer face and never enters the coupling, so a 1/8 NPT thermocouple sits happily
// on a mini while a 1/2 NPT one needs a std flange to stand on.
function head_interface_fits(iface, bore, thread) =
  bayonet_interface_radius(iface) - bore >= port_bore_wall
  && (
    is_undef(thread)
    || bayonet_flange_radius(iface) >= npt_thread_major_diameter(thread) / 2 + npt_mount_wall()
  );

// probe and baffle are fixed by what they carry: a 16 mm Atlas body with its collet, and a plate
// that has to drop through the lock bore. Everything else takes the smallest that fits, so a 2.4 mm
// dosing line stops carrying a probe's flange.
function head_interface_for(type, bore, thread = undef) =
  type == "probe" || type == "baffle"
    ? bayonet_std
    : let (_fit = [for (i = head_interfaces_by_size()) if (head_interface_fits(i, bore, thread)) i])
      len(_fit) == 0 ? undef : _fit[0];

function head_port_interface(port) =
  head_interface_for(
    head_port_type(port),
    head_port_bore_radius(port),
    head_port_type(port) == "thermocouple" && !is_undef(head_port_probe(port))
      ? thermocouple_probe_thread(head_port_probe(port))
      : undef
  );

// The biggest interface in use. The port circle has to clear the widest through-bore and the plug
// groove the widest lock, so both derive from this rather than from whichever port is handy.
function head_widest_interface(ports) =
  let (
    _used = [for (p = ports) head_port_interface(p)],
    _holes = [for (i = _used) bayonet_port_hole_radius(i)]
  ) _used[search(max(_holes), _holes)[0]];

function head_port_function(port) = port[0]; // what it is for, and this table's identity
function head_port_type(port) = port[1]; // how it is built
function head_port_bore_radius(port) = port[2]; // through-hole, 0 where nothing passes
function head_port_probe(port) = port[3]; // registered probe, "probe" entries only

// Where the port with this purpose sits. Anything that needs a particular port asks for it by what
// it does rather than by a number, so moving a port around the lid moves everything bound to it and
// nothing else. Exactly one, because a purpose two ports both claim is a table that cannot be read.
function head_port_index(vessel_opening_diameter, fn) =
  let (
    _ports = head_ports_for(vessel_opening_diameter),
    _at = [for (i = [0:len(_ports) - 1]) if (head_port_function(_ports[i]) == fn) i]
  )
    assert(
      len(_at) == 1,
      str("This lid has ", len(_at), " ports for \"", fn, "\"; looking one up by function needs exactly one.")
    ) _at[0];

// The gas comes down whichever port is the air inlet, wherever that ends up sitting.
function head_sparge_feed_port(vessel_opening_diameter) = head_port_index(vessel_opening_diameter, "air_in");

/**
 * @brief Every printed part this lid carries: [name, quantity, the flags that render it alone].
 *
 * The one list nothing outside the model can hold. It VARIES WITH THE VESSEL - a narrow jar takes
 * six ports where a wide one takes twelve - and it is the complement of the purchase list, which
 * only knows about things you buy. So the sparge ring, the second impeller and every port half
 * appear here and nowhere else.
 *
 * Each row carries how to render itself rather than leaving a recipe to work it out from the name,
 * because a mapping written down twice is the defect docs/design-conventions.md names as this
 * repo's recurring one. `just export-parts` walks these rows and does what they say.
 */
function head_print_parts(vessel_opening_diameter, lid_flange_height, vessel_internal_height, vessel_punt_height) =
  let (
    _ports = head_ports_for(vessel_opening_diameter),
    _segs = head_baffle_segments(lid_flange_height, vessel_internal_height, vessel_punt_height)
  )
    concat(
      [["lid", 1, "-D render_lid=true"]],
      [
        for (m = ["base_plate", "face_plate", "middle_stand"])
          [str("motor_mount_", m), 1, str("-D render_motor_mount=true -D motor_mount_part_to_render=\"", m, "\"")],
      ],
      // Mirror images, so two parts and not one printed twice.
      [
        for (h = ["lower", "upper"])
          [str("impeller_", h), 1, str("-D render_impeller=true -D impeller_to_render=\"", h, "\"")],
      ],
      [["sparge_ring", 1, "-D render_sparger=true"]],
      // Ports, in the order they sit on the lid. A baffle's plate prints in pieces, so it is that
      // many parts; every other port is one.
      [
        for (i = [0:len(_ports) - 1])
          let (_n = head_port_export_name(_ports, i))
            if (head_port_type(_ports[i]) != "baffle")
              [str("port_", _n), 1, str("-D port_to_render=\"", _n, "\"")],
      ],
      // Every baffle port is the same part - same width, same length, same pieces, same mark - so
      // this is ONE part with a quantity, not four that happen to match. Rendered off the first of
      // them; which one it is does not reach the geometry.
      let (
        _baffles = [for (i = [0:len(_ports) - 1]) if (head_port_type(_ports[i]) == "baffle") i]
      )
        len(_baffles) == 0
          ? []
          : [
            for (k = [0:_segs - 1])
              [
                str("port_baffle_piece_", k),
                len(_baffles),
                str(
                  "-D port_to_render=\"", head_port_export_name(_ports, _baffles[0]),
                  "\" -D baffle_segment_to_render=", k
                ),
              ],
          ],
      // A tool rather than a reactor part, which is why render_all leaves it out - but you cannot
      // cut the rim gasket without it, and no purchase list will ever mention it.
      [
        for (g = ["outer", "inner"])
          [str("gasket_cutter_", g), 1, str("-D render_gasket_cutter=true -D gasket_cutter_part_to_render=\"", g, "\"")],
      ]
    );

// What a per-part export addresses a port by. Its function, which is this table's identity -
// except that every baffle carries the same one, so those take the index of the port they sit on.
function head_port_export_name(ports, i) =
  head_port_function(ports[i]) == "baffle" ? str("baffle_", i) : head_port_function(ports[i]);

// Which ports have a RIGID tube standing in them, and so want a seal around it rather than a bore
// that only guides it: the sparger's feed, and whatever steadies it. Asked by function, so moving a
// support to another port takes its gland with it.
function head_port_carries_riser(port) =
  let (_f = head_port_function(port))
    _f == "air_in" || len([for (s = sparge_support_functions) if (s == _f) 1]) > 0;

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
// How far the plate hangs below the port's bottom face. undef hangs it to the floor limit for
// whatever jar is being built, which is what the area report already asks for: depth is the only
// lever left on baffle area once the count and the width are settled by the port circle.
//
// It was 280, the limit for the 143 mm jar, applied to every jar. That put a 280 mm plate in a
// vessel with 172 mm of room. Derived, the same three vessels come out at 275, 280 and 172, and the
// short jar ends up the best baffled of the family at 1.07 of the reference area against jar_10L's
// 0.84 - a short wide jar gets proportionally more plate.
//
// Set it to a number to pin one; head() still checks it against the floor.
baffle_length = undef;
// Thickness of the plate. Not a strength choice - root stress at full depth is about 1 % of yield
// at any of these - but a dynamic and a stiffness one. A 4 mm plate this long has its first
// bending mode at 5.4 Hz, which is shaft rotation at the rated 320 rpm. 8 cleared that; 9 is what
// the pitched blade's higher power number then asked for, since the plates react the impeller's
// torque and Po went 0.99 borrowed to 1.602 correlated. See docs/agitation.md.
//
// 10 is where the two reported limits both clear, and the window is one millimetre wide in each
// direction. At 9 the tip deflects 1.635 mm, past a tenth of the 15.3 mm plate. Thickening is the
// obvious lever and it was written down as a nearly free one, on the grounds that the lock bore
// does not cut into the width until 12.5 - but the bore is not what binds. THE MODE IS. Stiffness
// goes as t^3 and frequency as t^1.5, so the plate's first mode climbs with the fix: 15.4 Hz at 9,
// 17.6 at 10, 19.8 at 11, 22.0 at 12.
//
// Blade passing is four per revolution, so it sweeps 0 to 28 Hz as the drive runs up to its 420 rpm
// no-load speed and CROSSES the mode at whatever speed makes the two equal. That crossing is at
// 231 rpm on a 9 mm plate and 264 on a 10, both under the 320 rpm rated point, so it is passed
// through on the way up. At 11 it is 297 and at 12 it is 330 - the second is inside the operating
// band and the first is 23 rpm off it. 12 also fires the resonance echo below.
//
// 10 leaves 15 % under the deflection limit and puts the crossing 17 % under rated. Joints take a
// larger share of a stiffer plate - 0.184 mm of 1.296 against 0.110 of 1.635 - because the
// dovetail's 4.2 mm neck does not thicken with it.
baffle_thickness = 10;
// printed PETG, for the plate's stiffness. REASONED, NOT CITED - derated from ~2.0 GPa bulk
baffle_modulus = 1800; // MPa
baffle_density = 1270; // kg/m^3
// height over which the port's round bottom face blends out into the plate
baffle_transition_height = 10;

/** Splitting the plate so it can be printed.
 * - Hanging to the floor, a plate is 172 mm in the short jar and 280 in jar_10L, and a taller jar
 *   with a wide enough mouth would ask for more. Standing that on a bed is the tallest, most
 *   slender thing in the model by a wide margin, and it prints slowly, badly and unreliably.
 * - The part stands in the port's own axis - the flange, the o-ring groove and the pins all want
 *   that - so it is the printer's Z that bounds it, and the port's own 23 mm counts against the
 *   first piece. 170 mm is the cap: 180 mm machines (Prusa MINI, Bambu A1 mini) are the small end
 *   of what anyone building this owns, and 10 mm leaves room for a brim. It costs less than it
 *   looks: at a 250 mm cap jar_10L still needs two pieces, since its part is 303 mm whole. What a
 *   bigger machine buys is the SHORT jar, whose 195 mm part would go on the bed in one.
 * - What it costs is the joint, which is a local drop in section, so a split plate deflects further
 *   than a whole one. head() reports the difference rather than hiding it.
 */

// Tallest a printed piece may stand on the bed, the port's own stack included.
baffle_segment_height_max = 170;
// How many pieces each plate splits into. undef derives it from the cap above; a number pins it,
// including 1, which is a plate printed whole on a machine that can take it.
baffle_segments = undef;
// The dovetail. It slides along the plate's width and is blind at the far end - see
// custom/bayonet_baffle_port.scad for why that axis and not the other.
//
// The neck is the parameter rather than the tail's depth because the neck is the mechanics: it is
// the only material crossing the joint plane. 4.2 of 9 mm leaves the joint a tenth of the plate's
// second moment, which is a 7 % tip deflection penalty at one joint and the reason the cap above
// is not lower. Depth follows from it and the flare, at 4.54 mm.
baffle_joint_lip = 1.6; // socket wall each side, four perimeters at a 0.4 nozzle
baffle_joint_neck = 4.2;
baffle_joint_flare = 10; // degrees off vertical - shallow, so engagement is not bought from the neck
// Slide fit between tail and socket. The butt faces meet with nothing between them, so this is
// flank clearance only and the plate keeps its length.
baffle_joint_allowance = 0.1;

/* [Sparger Parameters] */

/** Where the gas enters, and why there.
 *  - The ring goes in the gap BETWEEN the impellers, not under the lower one. Birch & Ahmed 1997
 *    place a ring in the impeller's discharge - above an up-pumping blade, below a down-pumping
 *    one - and a converging pair puts both discharges in the same place. head_shaft_rotation is
 *    what makes the pair converge; reverse it and this position stops being right.
 *  - 1.4 D is the ring they tested, the equal-swept-volume radius, and the largest that passes the
 *    jar's mouth. Three reasons landing on one number.
 *  - Hole size and count are for spacing and against fouling, NOT for even flow. Rewatkar & Joshi
 *    1993: "hole size and number of holes have negligible effect when the sparger is located near
 *    the impeller", which this one is. Even flow is unreachable at the low end of the range anyway.
 */

// Clearance the ring keeps to the baffles inboard of it and to the jar's mouth it passes through.
// Both are static fits between rigid parts, so this is a print-and-assembly tolerance rather than a
// running clearance.
sparge_ring_clearance = 1.25;
// where the ring sits in the gap: 0 at the lower impeller's collar, 1 at the upper impeller
sparge_ring_gap_fraction = 0.5;
// The ring's own section, [radial, axial]. NOT round, and that is the point: the squeeze here is
// entirely radial - 6.95 mm between the baffles and the mouth - while the gap gives 73 mm of
// height. A round tube of any bore worth having will not fit that band at any ratio. A tall narrow
// section spends the dimension that is free, and it is the one thing a printed ring can do that a
// bent tube cannot.
sparge_ring_section = [4, 10];
// wall around the bore
sparge_ring_wall = 1.2;
// Gas holes, drilled radially inward - Birch & Ahmed: "all spargers discharged gas towards the
// turbine". 3 mm is mid Rewatkar's tested 2-6 and the least tolerance-sensitive that still spaces.
sparge_hole_diameter = 3;
sparge_hole_count = 8;
// Which ports carry a tube down to the ring purely to hold it steady, named by function the way the
// feed is. One riser leaves the ring on a 1.33 N/mm cantilever - 0.75 mm of sway per newton against
// 1.7 mm of clearance to the baffles - so two newtons of flow would have it touching.
//
// air_out is the second because it is the one tube port both the full and the reduced set place
// 120 degrees from air_in, which is as far apart as either layout allows. Its socket is blind: the
// tube is capped there and takes a drilled hole higher up, where a vent actually wants to be.
sparge_support_functions = ["air_out"];
// sparge_riser_tube is registered up in [Port Assignment], because the ports it passes are bored
// for it and a table cannot read a value set below it.
// bore of the socket the riser drops into, off the tube itself so the two cannot drift
sparge_feed_bore = steel_tube_od(sparge_riser_tube);
// how far it lands inside the socket
sparge_riser_insertion = 8;
// How far a tube stands above the top of its port, so something can be connected to it.
//
// It used to stand nowhere: the length was measured to the lid's OUTER face, which the port's own
// flange stands 5 mm above, so every tube finished INSIDE its port with nothing to grip. Flexible
// tubing pushed over 4 mm needs a few diameters of engagement and a worm clamp's band is about 9 mm
// wide, so 15 mm carries the clamp with lead-in either side. It is shorter than the thermocouple's
// own 20 mm NPT mount, which is the tallest thing already standing on this lid.
sparge_riser_proud = 15;
// What the sterile inlet filter costs, kPa per L/min. EXTRAPOLATED, NOT MEASURED: Cole-Parmer do
// not publish a curve for 1594522, so this is a linear fit taken from an equivalent 0.2 um PTFE
// disc of near-identical dimensions. Linear is the right shape - membrane flow at these pressures
// is viscous, so Darcy makes it proportional to flow - and the slope is corroborated rather than
// invented: area-correcting Pall's Acro 50 from 19.6 to this filter's 16.2 cm2 gives 3.02 against
// the 3.45 used here, so it sits 14 % conservative of the best-documented comparable part.
//
// It matters more than its size suggests. At the design flow it is 14.1 kPa against the vessel's
// own 1.1, so it takes over half of what the throttle would otherwise have had - see the gas
// supply report, which sizes the metering valve from what is left. Worth replacing with a measured
// number; a water manometer across it at the set flow is enough. See TODO.md.
sparge_filter_drop_slope = 3.45;
// The check valve, as the LINE sees it rather than as its headline reads. Both numbers come off the
// datasheet of the registered part - see purchased-parts.csv - and both are needed, because a check
// valve costs a CRACKING pressure to open at all and a flowing drop on top of that, and only the
// first is ever quoted. Cole-Parmer 5011521: 0.18 psi to crack, Cv 0.12 open.
sparge_check_valve_cracking = 1241; // Pa; 0.18 psi
sparge_check_valve_cv = 0.12;
// the aeration rate the holes are reported against, volumes of gas per volume of liquid per minute
sparge_design_vvm = 0.5;
// the band the gas metering has to cover, in vvm
sparge_vvm_band = [0.1, 0.5];
// what pushes the gas
head_air_pump = air_pump_resun_35w;

/* [Probe Port Parameters] */

// Design choices for the collet. Every hardware dimension comes from the registered probe
// named in head_ports, so nothing about the probe itself is entered here.
probe_port_collet_wall_thickness = 1.2;
probe_port_collet_body_allowance = 0.6; // grip fit; tune this, not the registry, if a cap is tight
probe_port_collet_connector_allowance = 0.6;
probe_port_collet_tab_gap = 1.0;
probe_port_collet_tab_deflection = 0.5;
// What a galvanic DO probe needs moving past its membrane, mL/min. Atlas state it as a FLOW -
// "approximately 60 ml/min" - and chart stagnant water taking the reading from 90 % to 20 % in
// thirty seconds. That is a collapse rather than a correction: the probe consumes the oxygen it
// reads and needs it replaced, so a still probe reports the hole it has eaten around itself.
//
// A property of the sensing principle rather than of any one catalogue row, which is why it is here
// and not a column in atlas_probes.scad. See docs/references.md.
do_probe_flow_requirement = 60;

// Degrees each probe port leans its probe OUTWARD from vertical. Two numbers rather than one,
// because the two probes want opposite things and this vessel has room for only one of them to
// lean at all. See docs/references.md, probe mounting.
//
// DO LEANS. Its membrane is a galvanic cell that consumes the oxygen it reads, and a bubble sitting
// on the face reads high - Sensorex have air bubbles collecting on the sensor's tip as a named
// failure. Nothing retrievable states an ANGLE for it, so 4.5 is reasoned rather than cited, and it
// is the ceiling anyway: past it the printed collet will not pass the jar's mouth, which head()
// asserts below and which has been confirmed by hand on a printed part.
//
// pH DOES NOT, and vertical is not a concession. Yokogawa ask for a pH sensor "at least 15 degrees
// above the horizontal plane to eliminate air bubbles in the pH glass bulb"; hanging straight down
// is 90 degrees above it, so a vertical probe clears that requirement by 75 degrees. Which is
// fortunate, because the pH probe is the long one - the only thing on this lid that reaches the
// sparge ring's height, and at any lean at all it goes through the ring.
// BOTH ARE PER-BUILD, against one jar's internals, and not properties of the design - the same
// footing as culture_working_volume. 4.5 is what jar_10L allows; jar_1gal_180x197 is shorter, so
// its DO tip reaches the ring and its own ceiling is nearer 2.5. check-vessels therefore sweeps the
// registry with both flat, because vertical clears every jar, and the numbers below are checked by
// check-scad against the jar they were chosen for.
do_probe_port_tilt_degrees = 4.5;
ph_probe_port_tilt_degrees = 0;
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
// `ports` is taken explicitly by the set search only, which cannot ask for the table it is in the
// middle of choosing. Everywhere else leaves it undef and gets whatever this lid carries.
function head_port_circle_radius(vessel_opening_diameter, ports = undef) =
  head_lid_plug_diameter(vessel_opening_diameter) / 2
  - bayonet_port_hole_radius(
    head_widest_interface(is_undef(ports) ? head_ports_for(vessel_opening_diameter) : ports)
  )
  - lid_holes_offset;

// The mount's base screws land on one circle in two parts: clearance holes through the mount's
// flange, insert holes into the lid. Both read this, so the pattern cannot drift between them.
function head_motor_mount_screw_hole_diameter() = screw_clearance_radius(motor_mount_base_screw) * 2;
function head_motor_mount_screw_radius() =
  get_base_screw_separation_radius(motor_mount_body_diameter, head_motor_mount_screw_hole_diameter());

// The gasket sits on the flat top of the glass, which runs from the bore out by the wall thickness,
// inset by a land at each edge for the flange to bottom on. That rim is what is AVAILABLE; the
// gasket takes the lesser of it and lid_gasket_width_max, and sits against its inner edge, which
// keeps the seal as near the bore as the land allows.
function head_gasket_rim_width(vessel_wall_thickness) =
  vessel_wall_thickness - 2 * lid_gasket_land_margin;
function head_gasket_width(vessel_wall_thickness) =
  min(head_gasket_rim_width(vessel_wall_thickness), lid_gasket_width_max);
function head_gasket_inner_radius(vessel_opening_diameter) =
  vessel_opening_diameter / 2 + lid_gasket_land_margin;
function head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness) =
  head_gasket_inner_radius(vessel_opening_diameter) + head_gasket_width(vessel_wall_thickness);

// What the joint has to hold. Exported because the gasket is the head's to choose and the bolt
// count is the assembly's, so the force crosses that boundary as one number - see
// utils/gasket_load.scad on why it is reported rather than asserted on.
function head_gasket_mean_diameter(vessel_opening_diameter, vessel_wall_thickness) =
  head_gasket_inner_radius(vessel_opening_diameter)
  + head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness);
function head_gasket_seating_force(vessel_opening_diameter, vessel_wall_thickness) =
  gasket_seating_force(
    gasket_sheet_shore_a(lid_gasket_sheet),
    head_gasket_width(vessel_wall_thickness),
    gasket_sheet_thickness(lid_gasket_sheet),
    head_gasket_mean_diameter(vessel_opening_diameter, vessel_wall_thickness),
    lid_gasket_compression
  );
function head_gasket_depth() = gasket_sheet_thickness(lid_gasket_sheet) * (1 - lid_gasket_compression);
// The other part of the same sheet: what the recess keeps against what the joint has to move. Two
// halves of one thickness, so neither is free to drift from the other.
function head_gasket_travel() = gasket_sheet_thickness(lid_gasket_sheet) * lid_gasket_compression;

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
// How deep the culture stands. head() has always computed this inline; it is exported because the
// frame needs it too - the lights are chosen to cover the liquid, and nothing else in the model
// knows how much liquid there is.
// Where a probe's axis sits `length` down its own lean, in the meridional half-plane: radius out
// from the shaft, height in head()'s frame. The lean is RADIAL - the port tilts the probe within
// the plane its own axis lies in - so this stays a straight line, which is what turns a 3D
// interference question into a 2D one. See utils/meridian.scad.
// Which lean a port gets. Anything that is not one of the two named probe ports hangs STRAIGHT,
// which is the orientation that clears everything here - so a probe port nobody has thought about
// is safe by default rather than quietly leaning into an impeller.
function head_probe_tilt(port) =
  head_port_function(port) == "do_probe"
    ? do_probe_port_tilt_degrees
    : head_port_function(port) == "ph_probe" ? ph_probe_port_tilt_degrees : 0;

function head_probe_axis_at(vessel_opening_diameter, lid_flange_height, length, tilt) =
  [
    head_port_circle_radius(vessel_opening_diameter) + length * sin(tilt),
    -head_lid_thickness(lid_flange_height) - length * cos(tilt),
  ];

// The two runs a probe hangs into the vessel: the collet, with the probe's body inside it, and the
// bare sensing tip below. One line broken where it narrows.
function head_probe_runs(probe, vessel_opening_diameter, lid_flange_height, tilt) =
  let (
    _shoulder = bayonet_probe_port_collet_drop(probe, probe_port_transition_length)
      + atlas_probe_body_height(probe),
    _tip = _shoulder + atlas_probe_tip_height(probe)
  )
    [
      [
        head_probe_axis_at(vessel_opening_diameter, lid_flange_height, 0, tilt),
        head_probe_axis_at(vessel_opening_diameter, lid_flange_height, _shoulder, tilt),
        atlas_probe_body_dia(probe) / 2 + probe_port_collet_wall_thickness,
      ],
      [
        head_probe_axis_at(vessel_opening_diameter, lid_flange_height, _shoulder, tilt),
        head_probe_axis_at(vessel_opening_diameter, lid_flange_height, _tip, tilt),
        atlas_probe_tip_dia(probe) / 2,
      ],
    ];

// The thermocouple hangs straight, and the length that is in the vessel is all sensing tip - its
// body is up in the NPT boss. So it is one run with no lean.
function head_thermocouple_run(probe, vessel_opening_diameter, lid_flange_height) =
  [
    [head_port_circle_radius(vessel_opening_diameter), -head_lid_thickness(lid_flange_height)],
    [head_port_circle_radius(vessel_opening_diameter), -thermocouple_probe_tip_height(probe)],
    thermocouple_probe_tip_dia(probe) / 2,
  ];

// How far below the lid's OUTER face a probe's deepest point lands.
//
// Fixed by geometry rather than by how far someone pushes it in: the collet grips the probe's BODY
// between a pocket the body's own length and a tail that houses its boot, so the probe seats at one
// depth and only one. Transition, body and tip, all leaned over by the port's tilt - which is why
// this is not simply their sum.
//
// The last term is the tilt again, on the tip's RIM rather than its axis: lean a flat-ended
// cylinder over and its low corner hangs r*sin(tilt) below the end of its centreline, and that
// corner is what meets the floor first. Measured against the drawn probe, this over-states the real
// low point by 0.02 mm, because the sensing slots cut away the very edge - conservative on the
// floor, which is the check it exists for. The surface check reads a fraction of a millimetre
// optimistic in exchange, against a margin of a hundred.
function head_probe_reach(probe, lid_flange_height, tilt) =
  head_lid_thickness(lid_flange_height)
  + (
    bayonet_probe_port_collet_drop(probe, probe_port_transition_length)
    + atlas_probe_body_height(probe)
    + atlas_probe_tip_height(probe)
  ) * cos(tilt)
  + atlas_probe_tip_dia(probe) / 2 * sin(tilt);

// The fill height that holds `litres`, by bisection on the jar's own profile. Volume rises
// monotonically with height above the floor, so halving the bracket converges; 40 halvings take the
// tallest registered vessel below a nanometre, which is far past what anything downstream can use.
// Inverted numerically rather than in closed form because the profile is a list of arcs - there is
// no expression to rearrange, and writing one would be the second statement of a shape this repo
// has just finished reducing to one.
function head_fill_height_for(vessel_profile, litres, lo, hi, steps = 40) =
  steps <= 0
    ? (lo + hi) / 2
    : let (_mid = (lo + hi) / 2)
      vessel_profile_litres(vessel_profile, vessel_profile[0][1] + _mid) < litres
        ? head_fill_height_for(vessel_profile, litres, _mid, hi, steps - 1)
        : head_fill_height_for(vessel_profile, litres, lo, _mid, steps - 1);

// The datum is the profile's own first point - the floor at the axis - which is exactly what
// vessel_internal_height() measures down from, so the two cannot drift.
function head_liquid_height(vessel_internal_height, vessel_profile) =
  is_undef(culture_working_volume)
    ? vessel_internal_height * culture_fill_fraction
    : head_fill_height_for(vessel_profile, culture_working_volume, 0, vessel_internal_height);

function head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height) =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) + vessel_punt_height;

// The plate is capped twice over: by the lock bore it drops through, and by the circle the
// impellers sweep, which it now passes alongside rather than stopping above. Whichever binds.
// The floor is what stops the plate - it clears the impellers radially by construction. lid_thickness
// is subtracted because the plate hangs from the port's underside, not from the lid's outer face.
function head_baffle_max_length(lid_flange_height, vessel_internal_height, vessel_punt_height) =
  head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
  - head_lid_thickness(lid_flange_height)
  - baffle_floor_clearance;

function head_baffle_length(lid_flange_height, vessel_internal_height, vessel_punt_height) =
  is_undef(baffle_length)
    ? head_baffle_max_length(lid_flange_height, vessel_internal_height, vessel_punt_height)
    : baffle_length;

function head_baffle_segments(lid_flange_height, vessel_internal_height, vessel_punt_height) =
  is_undef(baffle_segments)
    ? bayonet_baffle_segments(
      head_interface_for("baffle", 0),
      head_lid_thickness(lid_flange_height),
      head_baffle_length(lid_flange_height, vessel_internal_height, vessel_punt_height),
      baffle_segment_height_max
    )
    : baffle_segments;

// What the tail gives up at the joint plane, as a fraction of the solid plate's second moment.
function head_baffle_joint_stiffness_ratio() = pow(baffle_joint_neck / baffle_thickness, 3);

// What the impeller actually sweeps, as against the diameter the correlations are keyed on. They
// should be equal - the blades solve so their corners land on the radius, and the tip ring is
// inboard of it - and this exists so that stops being an assumption. Anything added outboard of the
// blades shows up here, and the baffle width below is derived from it rather than from the nominal,
// so a part that grows takes its clearance with it.
function head_impeller_swept_radius(impeller_diameter) =
  max(impeller_diameter / 2, impeller_hub_radius);

function head_baffle_width(vessel_opening_diameter, impeller_diameter) =
  min(
    bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance),
    2 * (head_port_circle_radius(vessel_opening_diameter) - head_impeller_swept_radius(impeller_diameter) - baffle_impeller_clearance),
    head_baffle_ring_limit(vessel_opening_diameter)
  );

// ----- the sparge ring's radius, and what it costs the baffles -----
//
// The ring is placed by the MOUTH, not by the impeller. It has to pass through the mouth, and both
// experimental sources want it as large as it can be - Birch & Ahmed tested 1.4 D, Rewatkar & Joshi
// found the critical speed lowest at 2 D - so the outermost position the mouth allows is also the
// best one available. The ratio then falls out and is reported against their band rather than
// chosen against it.
//
// That inverts what used to give way. The room outside a baffle is
//
//     mouth/2 - (port circle + w/2)
//
// and since the port circle is itself mouth/2 minus a constant of the bayonet and the lid, that
// room is a CONSTANT - it does not grow with the mouth. A full-width baffle leaves 5.78 mm, and a
// 4 mm ring with a clearance each side needs more. So the ring cannot fit outside a full-width
// baffle on ANY jar; it cannot fit inside them either, since that gap is baffle_impeller_clearance
// wide by construction. The baffle has to yield, and head_baffle_width() takes a third bound.
function head_sparge_ring_radius(mouth) =
  mouth / 2 - sparge_ring_clearance - sparge_ring_section[0] / 2;

// The widest plate that still leaves the ring its section and a clearance either side.
function head_baffle_ring_limit(mouth) =
  2 * (mouth / 2 - head_port_circle_radius(mouth) - 2 * sparge_ring_clearance - sparge_ring_section[0]);

// ----- where the mouth and the bore have to agree -----
//
// Nothing couples a jar's MOUTH to its BORE. The mouth sets the port circle, and through it where
// the baffles hang; the bore sets the impeller, and through it the baffle's inner edge and the
// sparge ring's diameter. So a jar can have a mouth too small to pass its own ring, or too large -
// which pushes the baffles outward until they foul it. The window between those is narrow, and
// nothing in the model said so until it was asked to.
//
// These are the four couplings, written as functions of (mouth, impeller diameter) so that the
// asserts in head() and the feasibility report below are the SAME expression and cannot drift.
// Each returns a clearance: positive is feasible, and the magnitude is what the assert reports.

function head_ring_baffle_gap(mouth, impeller_diameter) =
  (head_sparge_ring_radius(mouth) - sparge_ring_section[0] / 2)
  - (head_port_circle_radius(mouth) + head_baffle_width(mouth, impeller_diameter) / 2);

function head_ring_mouth_gap(mouth, impeller_diameter) =
  mouth / 2 - (head_sparge_ring_radius(mouth) + sparge_ring_section[0] / 2);

// The impeller itself has to go in through the mouth, whatever the lid carries. This was only ever
// an assert inside head(), so head_feasible_mouths() reported mouths the impeller could not pass -
// the one coupling of the four that was not in the predicate.
function head_mouth_passes_impeller(mouth, impeller_diameter) =
  mouth - 2 * head_impeller_swept_radius(impeller_diameter) > 0;

// Two of the four only bind if the lid carries baffles at all. A baffle-free lid still has to
// pass its ring and its impeller through its own mouth, but has nothing for the ring to foul.
function head_mouth_is_feasible(mouth, impeller_diameter, has_baffles = true) =
  // A mouth too narrow for any registered port set is not feasible whatever the impeller does, and
  // the && short-circuits so the rest is never asked about a lid that does not exist. The sweep
  // runs from 40 mm, where that is most of the range.
  !is_undef(head_ports_for(mouth))
  && (!has_baffles
    || (head_baffle_width(mouth, impeller_diameter) > 0
      && head_ring_baffle_gap(mouth, impeller_diameter) > 0))
  && head_ring_mouth_gap(mouth, impeller_diameter) > 0
  && head_mouth_passes_impeller(mouth, impeller_diameter);

// Solved by sweeping the predicate rather than inverted in closed form. A closed form would be a
// second expression of the same four couplings and would go wrong the first time an allowance
// moved - which is the defect docs/design-conventions.md names as this repo's recurring one.
function head_feasible_mouth_sweep() = [40, 400, 0.25]; // [lo, hi, step] - the range searched
function head_feasible_mouths(impeller_diameter, has_baffles = true) =
  let (_s = head_feasible_mouth_sweep())
    [for (m = [_s[0]:_s[2]:_s[1]]) if (head_mouth_is_feasible(m, impeller_diameter, has_baffles)) m];

// The drive stack, from the lid's outer face up. head() builds against these rather than
// recomputing them, and anything that has to make room for an assembled reactor reads them back
// out - the cart is the one that does.
// What the shaft has to clear the lid by. The coupling joins two 8 mm shafts over its own length,
// so half of it is the impeller side's share - anything less and the joint is gripping air. The
// old rule was protrusion > 0, which would have accepted a tenth of a millimetre.
function head_shaft_min_protrusion() = sc_length(shaft_coupler) / 2;

// How long a shaft this vessel needs: down to the punt, back up through the lid, plus that grip.
function head_shaft_length_needed(lid_flange_height, vessel_internal_height) =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) - shaft_jar_punt_clearance
  + head_shaft_min_protrusion();

// The shortest registered row that reaches. Shortest because every millimetre over is a millimetre
// the motor mount grows by - the shaft does not get deeper, it sticks out further.
function head_shaft_for(lid_flange_height, vessel_internal_height) =
  let (
    _need = head_shaft_length_needed(lid_flange_height, vessel_internal_height),
    _fits = [for (t = shafts) if (shaft_length(t) >= _need) shaft_length(t)]
  )
    len(_fits) == 0 ? undef : [for (t = shafts) if (shaft_length(t) == min(_fits)) t][0];

function head_shaft_selected(lid_flange_height, vessel_internal_height) =
  is_undef(head_shaft) ? head_shaft_for(lid_flange_height, vessel_internal_height) : head_shaft;

function head_shaft_protrusion(lid_flange_height, vessel_internal_height) =
  shaft_length(head_shaft_selected(lid_flange_height, vessel_internal_height))
  - (head_punt_top_depth(lid_flange_height, vessel_internal_height) - shaft_jar_punt_clearance);
function head_motor_mount_height(lid_flange_height, vessel_internal_height) =
  gearbox_output_shaft_length(dc_motor_gearbox(head_motor))
  + head_shaft_protrusion(lid_flange_height, vessel_internal_height) + shaft_shaft_coupling_offset;
// top of the motor, which is the highest thing on the reactor
function head_stack_height(lid_flange_height, vessel_internal_height) =
  head_motor_mount_height(lid_flange_height, vessel_internal_height)
  + dc_motor_length(head_motor) + gearbox_length(dc_motor_gearbox(head_motor));
// The groove a given ring would get in a given mouth, and how far that stretches it. Written
// per-candidate because the groove's depth follows the ring's own cord, so choosing a ring and
// cutting its groove are one question rather than two.
function head_plug_groove_diameter(vessel_opening_diameter, ring) =
  vessel_opening_diameter - 2 * oring_gland_depth(oring_cross_section(ring), lid_plug_oring_squeeze);

function head_plug_oring_stretch(vessel_opening_diameter, ring) =
  oring_stretch(oring_inner_diameter(ring), head_plug_groove_diameter(vessel_opening_diameter, ring));

// The groove and the port bores are cut into the same wall of the plug, and the same
// lid_holes_offset stands on either side of the web between them, so it cancels; the mouth cancels
// too, since both radii are measured from it. What is left is the entire budget for the groove's
// depth - the plug's own fit clearance, plus the step from the bayonet's port hole down to its lock
// bore. So this is a property of the bayonet and the lid, not of any jar: a cord over it fouls the
// bores on every vessel in the family, and a cord under it fits on all of them.
function head_plug_oring_cord_limit(vessel_opening_diameter) =
  let (_w = head_widest_interface(head_ports_for(vessel_opening_diameter)))
  (lid_radial_allowance / 2 + bayonet_port_hole_radius(_w) - bayonet_lock_bore_radius(_w))
  / (1 - lid_plug_oring_squeeze);

// Under zero the ring sags out of its groove; over five percent it thins the cord; over the cord
// limit the groove eats the wall the port bores need.
function head_plug_oring_fits(vessel_opening_diameter, ring) =
  let (_s = head_plug_oring_stretch(vessel_opening_diameter, ring))
    _s >= 0 && _s <= 0.05 && oring_cross_section(ring) <= head_plug_oring_cord_limit(vessel_opening_diameter);

function head_plug_oring_for(vessel_opening_diameter) =
  let (_fits = [for (r = orings) if (head_plug_oring_fits(vessel_opening_diameter, r)) r])
    len(_fits) == 0 ? undef : _fits[0];

function head_plug_oring_selected(vessel_opening_diameter) =
  is_undef(lid_plug_oring) ? head_plug_oring_for(vessel_opening_diameter) : lid_plug_oring;

function head_plug_groove_width(vessel_opening_diameter) =
  oring_gland_width(oring_cross_section(head_plug_oring_selected(vessel_opening_diameter)));

// A piston gland: cut relative to the bore it seals against, not to the plug it is cut into, so
// the ring's squeeze is what the glass leaves it.
function head_plug_oring_groove_radius(vessel_opening_diameter) =
  head_plug_groove_diameter(
    vessel_opening_diameter, head_plug_oring_selected(vessel_opening_diameter)
  ) / 2;

// Place children at port i, on the ring and turned to face out.
//
// `flipped` is for callers drawing inside lid_pocketed, which head() turns over with
// rotate([0, 180, 0]). That flip sends a port at angle t to 180 - t, so a bore cut at port i's own
// angle does not land on port i - it lands on whichever port sits opposite. That was harmless for
// as long as every port was the same size, since mirroring a ring of identical holes changes
// nothing, and it stopped being harmless the moment they differed: two ports came out with a std
// bore around a mini lock, leaving an annular gap right through the lid.
//
// Placing at the mirrored angle rather than mirroring the index also drops a requirement nobody
// had written down - that the port count be even, without which 180 - t is not a port angle at all.
module head_port_at(i, vessel_opening_diameter, flipped = false) {
  _angle = i * 360 / head_ports_n(vessel_opening_diameter);
  rotate([0, 0, flipped ? 180 - _angle : _angle])
    translate([head_port_circle_radius(vessel_opening_diameter), 0, 0])
      children();
}

module lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, joint_outer_diameter, post_pts, post_hole_diameter, shaft_diameter) {

  _ports = head_ports_for(vessel_opening_diameter);
  _n = len(_ports);

  _thickness = head_lid_thickness(lid_flange_height);

  // z = 0 is the lid's outer face here and the part is flipped by the caller, so the flange's
  // glass-facing side is its far face, at z = lid_flange_height, where the plug starts.
  _gasket_depth = head_gasket_depth();
  _plug_groove_w = head_plug_groove_width(vessel_opening_diameter);
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
      for (i = [0:_n - 1])
        head_port_at(i, vessel_opening_diameter, flipped=true)
          translate([0, 0, _thickness / 2])
            cylinder(r=bayonet_port_hole_radius(head_port_interface(_ports[i])), h=_thickness + z_fight, center=true);

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
module head_port(port, panel_thickness, baffle_width, baffle_length, baffle_segments) {
  _type = head_port_type(port);
  _bore = head_port_bore_radius(port);
  _probe = head_port_probe(port);
  _iface = head_port_interface(port);

  if (_type == "tube") {
    // The tube interface is just the generic port with its bore set, and the bore printed
    // on the flange.
    // Labelled by WHAT IT IS FOR, not just how wide it is. The default mark is the bore, and on
    // this lid that made pairs of ports identical: air_in and air_out are both 3 mm, so both read
    // "O6", and acid and base are both 2.4 and both read "O4.8". A gas line on the wrong one vents
    // into the headspace while the rotameter still reads flow; a dosing line on the wrong one puts
    // acid where base should go. The bore stays on the mark because it is what a hose has to fit.
    bayonet_port(
      type=_iface,
      part="pin",
      panel_thickness=panel_thickness,
      center_bore_radius=_bore,
      bore_oring=head_port_carries_riser(port) ? tube_port_riser_oring : undef,
      text_labels=true,
      label=str(bayonet_label_text(head_port_function(port)), " \u00d8", _bore * 2)
    );
  } else if (_type == "probe") {
    assert(!is_undef(_probe), "head_port: a \"probe\" entry needs a registered atlas probe in slot 4");
    bayonet_probe_port(
      type=_iface,
      probe=_probe,
      panel_thickness=panel_thickness,
      center_bore_radius=_bore,
      collet_wall_thickness=probe_port_collet_wall_thickness,
      collet_body_allowance=probe_port_collet_body_allowance,
      collet_connector_allowance=probe_port_collet_connector_allowance,
      collet_tab_gap=probe_port_collet_tab_gap,
      collet_tab_internal_deflection=probe_port_collet_tab_deflection,
      tilt_degrees=head_probe_tilt(port),
      transition_length=probe_port_transition_length
    );
  } else if (_type == "baffle") {
    bayonet_baffle_port(
      type=_iface,
      panel_thickness=panel_thickness,
      length=baffle_length,
      thickness=baffle_thickness,
      transition_height=baffle_transition_height,
      bore_clearance=baffle_bore_clearance,
      joint_lip=baffle_joint_lip,
      joint_neck=baffle_joint_neck,
      joint_flare=baffle_joint_flare,
      joint_allowance=baffle_joint_allowance,
      segments=baffle_segments,
      segment=baffle_segment_to_render,
      width=baffle_width
    );
  } else if (_type == "thermocouple") {
    assert(
      !is_undef(_probe),
      "head_port: a \"thermocouple\" entry needs a registered probe in slot 4, which is what names its thread"
    );
    bayonet_thermocouple_port(
      type=_iface,
      panel_thickness=panel_thickness,
      center_bore_radius=_bore,
      mount_height=thermocouple_mount_height,
      thread=thermocouple_probe_thread(_probe)
    );
  } else {
    assert(false, str("head_port: unknown port type '", _type, "'"));
  }
}

module head(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, vessel_internal_height, vessel_punt_height, joint_outer_diameter, post_pts, post_hole_diameter, vessel_profile) {

  // The table this lid carries, resolved once. head_ports pins it; undef derives it from the mouth.
  _ports = head_ports_for(vessel_opening_diameter);
  _n = len(_ports);

  assert(
    !is_undef(_ports),
    str(
      "No registered port set fits a ", vessel_opening_diameter, " mm mouth. The full twelve wants ",
      "142 mm and the reduced six wants 77.6 - see docs/ports-layout.md."
    )
  );

  // the gearbox carried by the selected motor - single source for gearbox dims
  head_gearbox = dc_motor_gearbox(head_motor);

  // There was an assert here that len(head_ports) equalled the hole count, from when the table and
  // the count were two statements that could drift. They are one now - _n counts the table this lid
  // resolved - so the check could only ever compare a number with itself. Removed rather than left
  // to look like it was guarding something; see docs/design-conventions.md on dead asserts.

  // Impeller Driven Parameters
  // The bore is what the impeller mixes and what D/T is measured against; the glass wall is not
  // part of the tank. Both the diameter and the spacing come from utils/stirred_tank.scad so the
  // relations and their citations live in one place.
  _vessel_bore = vessel_outer_diameter - 2 * vessel_wall_thickness;

  // Resolved once. head_shaft may pin a row; otherwise the shortest that reaches this vessel.
  _shaft = head_shaft_selected(lid_flange_height, vessel_internal_height);
  _liquid_height = head_liquid_height(vessel_internal_height, vessel_profile);

  // Read off the port table, so it depends on nothing else and can sit this early. It has to:
  // Medek's envelope is conditioned on four baffles and the Po block below is the first consumer.
  _baffle_at = [for (i = [0:_n - 1]) if (head_port_type(_ports[i]) == "baffle") i];

  // A lid need not carry baffles. Everything below that measures, checks or loads a plate has to
  // ask first - a lid with none was reporting a plate width, warning about its area, and dividing
  // the impeller's torque by a count of zero.
  _has_baffles = len(_baffle_at) > 0;
  impeller_diameter = stirred_tank_impeller_diameter(_vessel_bore, impeller_bore_ratio);

  // The window this jar had to land in, reported whether or not it did. The three couplings above
  // squeeze from both sides: too small a mouth and the ring will not pass, too large and the port
  // circle carries the baffles out until the ring fouls them. Nothing chooses a jar's mouth to suit
  // its bore, so where a given jar falls in here is luck, and worth seeing rather than inferring
  // from an assert that only speaks when it fails.
  _feasible = head_feasible_mouths(impeller_diameter, _has_baffles);

  echo(
    len(_feasible) == 0
      ? str(
        "vessel fit: NO mouth is feasible for a ", impeller_diameter,
        " mm impeller at these allowances - the couplings have closed on each other."
      )
      : str(
        "vessel fit: a ", impeller_diameter, " mm impeller is feasible in mouths ", _feasible[0],
        " to ",
        // an upper bound equal to the search ceiling is the search running out, not a constraint
        _feasible[len(_feasible) - 1] >= head_feasible_mouth_sweep()[1]
          ? "anything wider (nothing bounds it above)"
          : str(_feasible[len(_feasible) - 1], " mm, a window ",
                _feasible[len(_feasible) - 1] - _feasible[0], " mm wide"),
        "; this jar's is ", vessel_opening_diameter
      )
  );
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
  // set at an angle projects only sin(angle) of itself onto the axis, plus cos(angle) of its own
  // thickness, which is why the fin width goes in - so this goes through the accessor rather than
  // multiplying the ratio here. Everything downstream is a vertical budget: clearance, coverage,
  // the collar's room, the baffle gap, and each of them was 2.83 mm short while the thickness was
  // left out.
  impeller_height = impeller_axial_span(head_impeller_type, impeller_diameter, impeller_fin_width);
  impeller_blade_width = impeller_width_ratio(head_impeller_type) * impeller_diameter;

  // radius of the shaft hole in the impeller
  impeller_shaft_hole_radius = (shaft_diameter(_shaft) + impeller_shaft_allow) / 2;

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

  // The diameter the part sweeps against the one the correlations use. Equal by construction, and
  // said out loud because they were not: a tip ring drawn outboard of the blades put 4 mm on the
  // radius, and D/T, the power number and the baffle clearance were all computed on the nominal.
  _swept = head_impeller_swept_radius(impeller_diameter) * 2;

  if (_swept != impeller_diameter)
    echo(str(
      "WARNING impeller: sweeps ", _swept, " mm but Po, D/T and the baffle clearance are computed on ",
      impeller_diameter, ". D/T is really ", stirred_tank_ratio(_swept, _vessel_bore),
      " and power goes as the fifth power of diameter, so this is ",
      pow(_swept / impeller_diameter, 5), "x on shaft power."
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

  // Which way the pair pumps, and therefore where gas belongs. Reported because nothing about the
  // drawn parts shows it - they are mirror images either way - and the sparger's position is
  // downstream of it.
  echo(str(
    "impeller pumping: shaft turns ", head_shaft_rotation > 0 ? "counter-clockwise" : "clockwise",
    " seen from above, so the lower impeller pumps ",
    stirred_tank_lower_pumps_up(head_shaft_rotation) ? "UP and the upper DOWN" : "DOWN and the upper UP",
    " and the pair ", stirred_tank_pair_converges(head_shaft_rotation) ? "CONVERGES on" : "DIVERGES from",
    " the ", impeller_spacing - impeller_height - impeller_collar_height,
    " mm gap between them"
  ));

  if (!stirred_tank_pair_converges(head_shaft_rotation))
    echo(str(
      "WARNING impeller pumping: a diverging pair puts the two discharge streams at opposite ends ",
      "of the vessel, so no single sparge ring sits in both. Birch & Ahmed place a ring above an ",
      "up-pumping blade and below a down-pumping one; reverse head_shaft_rotation or accept that ",
      "the gas enters only one impeller's discharge. See docs/agitation.md."
    ));

  // Set screws hold the impeller to the shaft; nothing else does. The bore tapers to the shaft's
  // nominal radius, so the fit is a slip fit whatever its parameter is called. Engagement is what
  // the hub wall leaves between socket and shaft, and reach is whether the tip gets there at all.
  _set_screw_engagement = impeller_hub_radius - impeller_shaft_hole_radius;
  _set_screw_reach =
  impeller_hub_radius - shaft_diameter(_shaft) / 2 - set_screw_length(impeller_set_screw);

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
      shaft_diameter(_shaft) / 2 + set_screw_length(impeller_set_screw), " mm, sits flush."
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
  // Integrated over the jar's OWN wetted profile, not a cylinder on its bore. The profile arrives
  // as a point list for the same reason post_pts does - head() is handed what it needs as data,
  // never a registry row it could read a different jar out of than the one its scalars came from.
  // The datum is the punt top, which is where vessel_internal_height() measures from too.
  _floor_y = vessel_wall_thickness + vessel_punt_height;
  _culture_volume = vessel_profile_litres(vessel_profile, _floor_y + _liquid_height);
  _vessel_capacity = vessel_profile_litres(vessel_profile, _floor_y + vessel_internal_height);

  echo(str(
    "culture: ", _culture_volume, " L standing ", _liquid_height, " mm deep, ",
    _liquid_height / vessel_internal_height * 100, "% of the ", vessel_internal_height,
    " mm internal height - ",
    is_undef(culture_working_volume)
      ? "DERIVED from culture_fill_fraction, so it is a depth this jar happens to give rather than a run anyone can repeat; set culture_working_volume to state one in litres"
      : "PINNED by culture_working_volume",
    ". The jar holds ", _vessel_capacity, " L brim full, and a cylinder on the ", _vessel_bore,
    " mm bore would have called this fill ", PI / 4 * pow(_vessel_bore, 2) * _liquid_height / 1e6, " L"
  ));

  // Asked for more than the jar holds. The solver's bracket tops out at the rim, so the fill line
  // is there and every volume below is the jar's capacity - which is a different number than the
  // one that was asked for, and nothing else would say so.
  if (!is_undef(culture_working_volume) && culture_working_volume > _vessel_capacity)
    echo(str(
      "WARNING culture: ", culture_working_volume, " L was asked for and this jar holds ",
      _vessel_capacity, " L brim full. The fill line is pinned at the rim and every volume ",
      "reported below is the capacity, not the working volume."
    ));
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

  // Hoisted because the DO probe's flow check reads it too, and one number said twice is how two
  // numbers start. Guarded, because Medek's correlation is keyed on a blade ANGLE and a twisted
  // blade has none - unguarded it feeds undef into a correlation and four warnings out of it.
  _impeller_flow_number = !_po_correlated
    ? undef
    : stirred_tank_medek_flow_number(
      impeller_blades(head_impeller_type), _clearance_ratio, _vessel_bore / impeller_diameter,
      _liquid_height / _vessel_bore, impeller_blade_angle(head_impeller_type)
    );

  if (_po_correlated)
    echo(str(
      "impeller: ", impeller_name(head_impeller_type), " Po ", _impeller_po,
      " and flow number ", _impeller_flow_number,
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

  // The thermocouple has to end up IN the culture and short of the floor, and nothing said so. A
  // 9 in probe was registered against every vessel in the twelve-port set, which overshoots
  // jar_1gal_180x197's floor by 28.6 mm - the tip would be through the glass. Asserted rather than
  // reported because a probe below the floor is not a departure from a band, it is a part that does
  // not fit.
  _tc_port = [for (q = _ports) if (head_port_type(q) == "thermocouple") q];

  if (len(_tc_port) > 0) {
    _tc_reach = thermocouple_probe_tip_height(head_port_probe(_tc_port[0]));
    _tc_floor = head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height);
    _tc_surface = _tc_floor - vessel_punt_height - _liquid_height;

    echo(str(
      "thermocouple: ", thermocouple_probe_part_number(head_port_probe(_tc_port[0])), " on ",
      npt_thread_name(thermocouple_probe_thread(head_port_probe(_tc_port[0]))),
      ", ", _tc_reach, " mm reach, tip ", _tc_reach - _tc_surface,
      " mm under the surface with ", _tc_floor - _tc_reach, " mm to the floor"
    ));

    assert(
      _tc_reach < _tc_floor,
      str(
        "Thermocouple reaches ", _tc_reach, " mm but the floor is ", _tc_floor,
        " mm below the lid, so the tip would be ", _tc_reach - _tc_floor, " mm through it."
      )
    );

    assert(
      _tc_reach > _tc_surface,
      str(
        "Thermocouple reaches ", _tc_reach, " mm and the culture starts ", _tc_surface,
        " mm below the lid, so the tip sits in the headspace and reads gas, not broth."
      )
    );
  }

  // The probes have to end up in the culture and short of the floor - the same two questions the
  // thermocouple answers, and until now the thermocouple was the only one asked. Both are asserted
  // for the same reason its are: a tip in the headspace reads gas rather than broth, and a tip
  // through the floor is not a fit at all.
  //
  // What is different is what FIXES the depth. A thermocouple threads into an NPT boss and lands
  // where the thread stops. These hang in flex collets, which sounds adjustable and is not: the
  // collet grips the BODY between a pocket its own length and a tail sized for its boot, so the
  // probe seats where the collet puts it. head_probe_reach() is that depth.
  for (i = [for (j = [0:_n - 1]) if (head_port_type(_ports[j]) == "probe") j])
    let (
      _p = head_port_probe(_ports[i]),
      _tilt = head_probe_tilt(_ports[i]),
      _reach = head_probe_reach(_p, lid_flange_height, _tilt),
      _floor = head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height),
      _surface = _floor - vessel_punt_height - _liquid_height
    ) {
      echo(str(
        "probe: ", head_port_function(_ports[i]), " carries ", atlas_probe_name(_p), ", reaching ",
        _reach, " mm - tip ", _reach - _surface, " mm under the surface with ", _floor - _reach,
        " mm to the floor, leaning ", _tilt, " deg"
      ));

      assert(
        _reach < _floor,
        str(
          "The ", atlas_probe_name(_p), " probe on ", head_port_function(_ports[i]), " reaches ",
          _reach, " mm but the floor is ", _floor, " mm below the lid, so its tip would be ",
          _reach - _floor, " mm through it."
        )
      );

      assert(
        _reach > _surface,
        str(
          "The ", atlas_probe_name(_p), " probe on ", head_port_function(_ports[i]), " reaches ",
          _reach, " mm and the culture starts ", _surface,
          " mm below the lid, so its tip sits in the headspace and reads gas, not broth."
        )
      );
    }

  // How long it takes to blend, and how fast oxygen crosses in. Both follow from the specific power
  // already echoed above, so they sit here rather than with the sparger; both are reported and
  // neither is asserted on - see utils/stirred_tank.scad for what each correlation is worth.
  for (s = _drive_speeds)
    let (
      _rpm = s[1],
      _power = stirred_tank_power(impeller_diameter, _rpm, _impeller_po),
      _pv = stirred_tank_mean_dissipation(_power, _culture_volume),
      _us = stirred_tank_superficial_gas_velocity(_sparge_flow, _vessel_bore)
    )
      echo(str(
        "transfer ", s[0], " ", _rpm, " rpm: blend to 95% in ",
        stirred_tank_blend_time(_vessel_bore, impeller_diameter, _pv), " s; kLa ",
        stirred_tank_kla_coalescing(_pv, _us), " 1/s coalescing, ",
        stirred_tank_kla_non_coalescing(_pv, _us), " 1/s not, at ", _us * 1000,
        " mm/s superficial gas"
      ));

  // Both correlations are used outside the range they were fitted in, which is worth saying every
  // render rather than leaving for someone to find in the source.
  _kla_band = stirred_tank_kla_power_band();
  _blend_band = stirred_tank_blend_time_volume_band();
  _pv_rated = len(_drive_speeds) == 0 ? undef
    : stirred_tank_mean_dissipation(
      stirred_tank_power(impeller_diameter, _drive_speeds[len(_drive_speeds) - 1][1], _impeller_po),
      _culture_volume
    );

  if (!is_undef(_pv_rated) && _pv_rated < _kla_band[0])
    echo(str(
      "transfer: kLa is van't Riet's air-water correlation, fitted over ", _kla_band[0], "-",
      _kla_band[1], " W/m3, and this vessel runs ", _pv_rated,
      ". Read it as an order of magnitude, not a number."
    ));

  if (_culture_volume / 1000 < _blend_band[0])
    echo(str(
      "transfer: blend time is Ruszkowski's, fitted on ", _blend_band[0], "-", _blend_band[1],
      " m3 fully baffled, and this is ", _culture_volume / 1000,
      " m3. It reproduces Hall's published table at a tenth of that, so the extrapolation is a short one."
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

  // The impeller is scaled off the vessel's bore but has to pass through its opening. This charged
  // 2 * fin_width for a tip ring standing OUTBOARD of the blades; that ring was moved inside
  // impeller_radius and this went on charging 8 mm for it, which is 8 mm of mouth no jar has to
  // give. What has to pass the neck is what the part sweeps, and head_impeller_swept_radius is
  // already the one place that answers that - for the baffle gap and for the D/T echo - so it
  // answers here rather than being spelled out a third time.
  assert(
    head_mouth_passes_impeller(vessel_opening_diameter, impeller_diameter),
    str(
      "Impeller sweeps ", 2 * head_impeller_swept_radius(impeller_diameter), " mm, past the ",
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
    shaft_protrusion >= head_shaft_min_protrusion(),
    str(
      "Shaft leaves ", shaft_protrusion, " mm above the lid's outer face and the ",
      sc_length(shaft_coupler), " mm coupling wants ", head_shaft_min_protrusion(),
      " to grip. No registered shaft is long enough for a ", vessel_internal_height,
      " mm vessel; the registry runs to ", max([for (t = shafts) shaft_length(t)]), " mm."
    )
  );

  // The coupling's two bores are catalogue facts and the shafts they go on are set elsewhere, so
  // The shaft runs directly in the bearing's inner race, so the fit is two tolerances meeting.
  // Both are registered, so this is checked rather than assumed - a plain rod at h9 would nominally
  // be "8 mm" and still rattle. Reported, not asserted: a transition fit is what a rotating inner
  // ring wants, and which side of line-to-line a given pair lands on is not ours to refuse.
  _fit_loosest = bb_bore(shaft_bearing) - shaft_diameter_min(_shaft);
  _fit_tightest = (bb_bore(shaft_bearing) - 0.007) - shaft_diameter_max(_shaft);
  echo(str(
    "shaft: ", shaft_name(_shaft), " (", shaft_part_number(_shaft), ") ",
    shaft_diameter_min(_shaft), "-", shaft_diameter_max(_shaft), " mm in a ",
    bb_bore(shaft_bearing), " mm bore: ", _fit_tightest, " to ", _fit_loosest, " mm"
  ));

  // nothing but this stops a coupling that fits neither end.
  assert(
    sc_diameter1(shaft_coupler) == gearbox_output_shaft_dia(head_gearbox) &&
    sc_diameter2(shaft_coupler) == shaft_diameter(_shaft),
    str(
      "The ", shaft_coupler[0], " coupling bores ", sc_diameter1(shaft_coupler), " and ",
      sc_diameter2(shaft_coupler), " mm, for a ", gearbox_output_shaft_dia(head_gearbox),
      " mm gearbox shaft and a ", shaft_diameter(_shaft), " mm impeller shaft."
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
      "WARNING motor mount: ", _mount_slenderness, " diameters tall. ",
      is_undef(head_shaft)
        ? str(
          "The shaft is already the shortest registered row that reaches - ", shaft_length(_shaft),
          " mm against the ", head_shaft_length_needed(lid_flange_height, vessel_internal_height),
          " this vessel needs. The registry steps 200/400/600/800, so the excess is the step, not a ",
          "choice; a cut between them would take it out."
        )
        : str(
          "head_shaft pins ", shaft_name(_shaft), "; leaving it undef would pick the shortest row ",
          "that reaches, which is ",
          shaft_name(head_shaft_for(lid_flange_height, vessel_internal_height)), "."
        )
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
  baffle_max_length = head_baffle_max_length(lid_flange_height, vessel_internal_height, vessel_punt_height);
  _baffle_length = head_baffle_length(lid_flange_height, vessel_internal_height, vessel_punt_height);
  _baffle_segments = head_baffle_segments(lid_flange_height, vessel_internal_height, vessel_punt_height);
  _baffle_joint_at = [for (j = [1:1:_baffle_segments - 1]) j * _baffle_length / _baffle_segments];

  // the plate's width is settled by the lock it hangs from and the impellers it passes, so it is
  // read back, not chosen here
  _baffle_width = head_baffle_width(vessel_opening_diameter, impeller_diameter);

  assert(
    !_has_baffles || _baffle_width > 0,
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
  _baffle_wetted = stirred_tank_baffle_wetted_length(_baffle_length, _baffle_freeboard, _liquid_height);
  _baffle_area_ratio =
  stirred_tank_baffle_area_ratio(_vessel_bore, _liquid_height, len(_baffle_at), _baffle_width, _baffle_wetted);

  echo(
    !_has_baffles
      ? "baffles: none on this lid, so the vessel is unbaffled and will swirl rather than mix"
      : str(
        "baffles: ", len(_baffle_at), " x ", _baffle_width, " x ", _baffle_length, " mm (",
        baffle_max_length, " mm clears the floor), ", _baffle_wetted, " mm of that submerged; ",
        _baffle_area_ratio, " of Oldshue's four-at-T/12 full-depth reference area"
      )
  );

  // Both levers, with the numbers, because "add another" stops being available: an equally spaced
  // count has to divide the port circle, so on twelve ports the counts are 2, 3, 4, 6, 12 and the
  // assert below enforces it. Depth is the lever that is still wide open.
  _next_baffle_count = [for (n = [len(_baffle_at) + 1:_n]) if (_n % n == 0) n];
  _baffle_ratio_at_depth = stirred_tank_baffle_area_ratio(
    _vessel_bore, _liquid_height, len(_baffle_at), _baffle_width,
    stirred_tank_baffle_wetted_length(baffle_max_length, _baffle_freeboard, _liquid_height));

  if (_has_baffles && _baffle_area_ratio < 0.9)
    echo(str(
      "WARNING baffles: ", _baffle_area_ratio, " of the reference projected area. ",
      _baffle_length < baffle_max_length
        ? str("Hanging these ", len(_baffle_at), " to the full ", baffle_max_length,
              " mm would give ", _baffle_ratio_at_depth, "; ")
        : "Depth is spent - these already hang to the floor limit. ",
      len(_next_baffle_count) > 0
        ? str("Going to ", _next_baffle_count[0], " plates, the next count that spaces equally on ",
              _n, " ports, would give ", stirred_tank_baffle_area_ratio(
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
  _baffle_solid_deflection = stirred_tank_baffle_deflection(
    _baffle_load, _baffle_length, _baffle_freeboard, _baffle_width, baffle_thickness, baffle_modulus);
  // The joints are in the headline number, not beside it: a split plate is what gets printed, so
  // its deflection is the one the W/10 check below has to be made against.
  _baffle_joint_depth = bayonet_baffle_joint_depth(
    baffle_thickness, baffle_joint_lip, baffle_joint_neck, baffle_joint_flare);
  _baffle_joint_each = [
    for (j = _baffle_joint_at)
      stirred_tank_baffle_joint_deflection(
        _baffle_load, _baffle_length, _baffle_freeboard, _baffle_width, baffle_thickness,
        baffle_modulus, j, baffle_joint_neck, _baffle_joint_depth)
  ];
  // dotted with ones, which is how a list gets summed here
  _baffle_joint_deflection =
    len(_baffle_joint_each) == 0 ? 0 : _baffle_joint_each * [for (d = _baffle_joint_each) 1];
  _baffle_deflection = _baffle_solid_deflection + _baffle_joint_deflection;
  _baffle_frequency = stirred_tank_baffle_frequency(
    _baffle_length, _baffle_width, baffle_thickness, baffle_modulus, baffle_density);

  if (_has_baffles)
    echo(str(
      "baffle plate: ", _baffle_load, " N each, deflecting ", _baffle_deflection, " mm at the tip",
      _baffle_segments < 2 ? "" : str(" (", _baffle_joint_deflection, " mm of it the joints)"),
      "; first mode ", _baffle_frequency, " Hz against ", stirred_tank_shaft_frequency(_baffle_rpm),
      " Hz shaft and ", stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins),
      " Hz blade passing - that mode is the solid plate, the joints soften it"
    ));

  // What splitting costs and what it buys, both in one line, since neither is decidable alone. The
  // cap only binds when the count is derived, so a pinned count that overruns it says so here
  // rather than being asserted - a bigger printer is a good reason to pin one.
  _baffle_piece_height =
    _baffle_length / _baffle_segments
    + bayonet_baffle_stack_height(head_interface_for("baffle", 0), lid_thickness);

  if (_has_baffles)
    echo(str(
      "baffle print: ", _baffle_segments, " piece", _baffle_segments == 1 ? "" : "s",
      " of ", _baffle_length / _baffle_segments, " mm, tallest standing ", _baffle_piece_height,
      " mm against a ", baffle_segment_height_max, " mm bed",
      _baffle_piece_height > baffle_segment_height_max
        ? str(" - PINNED AT ", _baffle_segments, ", WHICH THE CAP WOULD NOT HAVE CHOSEN")
        : "",
      _baffle_segments < 2
        ? ""
        : str("; the dovetail leaves ", baffle_joint_neck, " mm of ", baffle_thickness,
              " crossing each joint, ", head_baffle_joint_stiffness_ratio(),
              " of the plate's second moment")
    ));

  // The nominal gap is not the running one. The plate hangs from a coupling with its own fit
  // allowance, so it can lean: allowance over engagement is the slope, and it costs that much per
  // mm of depth. What matters is the lean at the impellers rather than at the tip, since that is
  // where there is something to hit. Reported and not asserted - it is a tolerance stack, not an
  // impossibility, and which way the play falls is the builder's luck rather than the model's.
  _baffle_lean_slope = bayonet_allowance(head_interface_for("baffle", 0)) / lid_thickness;
  _baffle_gap = port_circle_radius - _baffle_width / 2 - head_impeller_swept_radius(impeller_diameter);
  _baffle_lean_at_lower =
    (head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
      - _impeller_clearance - lid_thickness) * _baffle_lean_slope;

  if (_has_baffles)
    echo(str(
      "baffle clearance: ", _baffle_gap, " mm nominal to the impeller, less ", _baffle_lean_at_lower,
      " mm the coupling's ", bayonet_allowance(head_interface_for("baffle", 0)),
      " mm of play allows at the lower impeller = ", _baffle_gap - _baffle_lean_at_lower, " mm running",
      _baffle_gap - _baffle_lean_at_lower < 0 ? " - THE PLATE CAN REACH THE BLADES" : ""
    ));

  if (_has_baffles && _baffle_deflection > _baffle_width / 10)
    echo(str(
      "WARNING baffle plate: ", _baffle_deflection, " mm of tip deflection is over a tenth of the ",
      _baffle_width, " mm plate. It is bending away from the swirl rather than blocking it; ",
      "thicken it - stiffness goes as the cube of thickness and the lock bore allows ",
      bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance) > _baffle_width
        ? "more" : "no more", "."
    ));

  // Parenthesised, because && binds tighter than ||: this read (has_baffles && shaft) || blade, so
  // the blade-passing arm was asked about a lid with no baffles and no plate to have a mode.
  if (_has_baffles
   && (abs(_baffle_frequency - stirred_tank_shaft_frequency(_baffle_rpm)) < 0.3 * stirred_tank_shaft_frequency(_baffle_rpm)
    || abs(_baffle_frequency - stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins)) < 0.3 * stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins)))
    echo(str(
      "WARNING baffle plate: its first mode at ", _baffle_frequency,
      " Hz is within 30% of a drive excitation. Thickness raises it as t^1.5 and length lowers it ",
      "as 1/L^2, so a thicker plate is the cheaper fix."
    ));

  // ----- sparge ring -----
  //
  // The feed comes down whichever port is the air inlet, so the arm has to run along that port's
  // angular sector - which must be one with no baffle in it, or the arm crosses a plate.
  assert(
    head_port_type(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) == "tube",
    str("the air_in port, ", head_sparge_feed_port(vessel_opening_diameter), ", is a \"", head_port_type(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]),
        "\", not a tube.")
  );

  _sparge_feed_angle = head_sparge_feed_port(vessel_opening_diameter) * 360 / _n;
  _sparge_support_angles = [
    for (f = sparge_support_functions) head_port_index(vessel_opening_diameter, f) * 360 / _n,
  ];

  // A support tube is cut from the riser's own stock, so whichever ports carry one have to pass it.
  // air_out's bore is cut for that tube and cannot fail this; every other port's is registered
  // independently, and moving a support onto one is a one-line edit that nothing else would catch,
  // because the model never draws a tube through a port. Reports the narrowest of them.
  _support_bores = [
    for (f = sparge_support_functions)
      head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_port_index(vessel_opening_diameter, f)]),
  ];

  assert(
    len(_support_bores) == 0 || min(_support_bores) * 2 >= steel_tube_od(sparge_riser_tube),
    str(
      "sparge support: ", sparge_support_functions, " - the narrowest of those ports bores ",
      min(_support_bores) * 2, " mm and the support tube is ", steel_tube_od(sparge_riser_tube),
      " mm across, so it will not go through"
    )
  );

  //
  // Reported before it is drawn, the same way clearance and coverage were, because the fits are
  // tight enough that they should be visible in the model rather than in a plan document.
  _sparge_ring_radius = head_sparge_ring_radius(vessel_opening_diameter);
  _sparge_ring_diameter = _sparge_ring_radius * 2;
  _sparge_ring_ratio = stirred_tank_sparge_ring_ratio(_sparge_ring_diameter, impeller_diameter);

  // The gap the ring lives in, measured between the parts that actually bound it: the lower
  // impeller's set-screw collar, not its blades, and the upper impeller's blades.
  _gap_bottom = _impeller_clearance + impeller_height / 2 + impeller_collar_height;
  _gap_top = _impeller_clearance + impeller_spacing - impeller_height / 2;
  _sparge_ring_height = _gap_bottom + sparge_ring_gap_fraction * (_gap_top - _gap_bottom);

  _sparge_baffle_gap = head_ring_baffle_gap(vessel_opening_diameter, impeller_diameter);
  _sparge_mouth_gap = head_ring_mouth_gap(vessel_opening_diameter, impeller_diameter);
  _sparge_bore = [sparge_ring_section[0] - 2 * sparge_ring_wall, sparge_ring_section[1] - 2 * sparge_ring_wall];

  _sparge_flow = stirred_tank_gas_flow(sparge_design_vvm, _culture_volume);
  _sparge_velocity = stirred_tank_orifice_velocity(_sparge_flow, sparge_hole_count, sparge_hole_diameter);

  echo(str(
    "sparge ring: ", _sparge_ring_diameter, " mm = ", _sparge_ring_ratio, " D (band ",
    stirred_tank_sparge_ring_band()[0], "-", stirred_tank_sparge_ring_band()[1],
    ", equal-swept-volume ", stirred_tank_sparge_ring_equal_volume_ratio(), "), ",
    _sparge_ring_height, " mm off the floor - ",
    _sparge_ring_height - _impeller_clearance, " above the lower impeller and ",
    _impeller_clearance + impeller_spacing - _sparge_ring_height, " below the upper"
  ));

  echo(str(
    "sparge ring fits: ", _sparge_baffle_gap, " mm to the baffles, ", _sparge_mouth_gap,
    " mm to the jar's mouth on the way in. Section ", sparge_ring_section,
    " mm gives a ", _sparge_bore, " mm bore, ", _sparge_bore[0] * _sparge_bore[1], " mm2"
  ));

  echo(str(
    "sparge holes: ", sparge_hole_count, " x ", sparge_hole_diameter, " mm at ",
    PI * _sparge_ring_diameter / sparge_hole_count, " mm spacing; at ", sparge_design_vvm,
    " vvm that is ", _sparge_flow * 60000, " L/min through them at ", _sparge_velocity, " m/s"
  ));

  // Reported rather than bounded: Barbosa establishes no critical orifice velocity, and Rewatkar
  // finds hole geometry barely matters this close to an impeller. What is worth seeing is the
  // ratio, because it is why even flow is not a design target here.
  echo(str(
    "sparge holes: capillary ", stirred_tank_capillary_pressure(sparge_hole_diameter),
    " Pa to launch a bubble against ", stirred_tank_orifice_pressure(_sparge_velocity),
    " Pa to push gas through, so the holes will not all flow evenly - which Rewatkar & Joshi find ",
    "does not matter near the impeller."
  ));

  // No assert on either gap any more. The ring is PLACED to satisfy both - its radius is the
  // outermost the mouth allows, and head_baffle_width() gives way to it - so an assert here would
  // be derived from the thing it checks and could never fire, which docs/design-conventions.md
  // calls a dead assert. What is worth reporting is what the placement cost.
  if (_has_baffles && head_baffle_ring_limit(vessel_opening_diameter) < 2 * (port_circle_radius - impeller_diameter / 2 - baffle_impeller_clearance)
    && head_baffle_ring_limit(vessel_opening_diameter) < bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance))
    echo(str(
      "sparge ring: the ring is what caps the baffles here, at ",
      head_baffle_ring_limit(vessel_opening_diameter),
      " mm - they would otherwise be ",
      min(bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance),
        2 * (port_circle_radius - impeller_diameter / 2 - baffle_impeller_clearance)),
      " mm. Room outside a baffle does not grow with the mouth, so this is the trade on every jar."
    ));

  if (!stirred_tank_in_band(_sparge_ring_ratio, stirred_tank_sparge_ring_band()))
    echo(str(
      "WARNING sparge ring: ", _sparge_ring_ratio, " D is outside the ",
      stirred_tank_sparge_ring_band()[0], "-", stirred_tank_sparge_ring_band()[1],
      " D two experimental studies support. The mouth places it, so this jar's mouth and bore are ",
      "too far apart for a ring that suits both."
    ));

  // ----- does anything hanging from the lid run into anything already in the vessel? -----
  //
  // Nothing asked this until now, and the gap is a gap in KIND. The immersion asserts above measure
  // DEPTH, and a probe leaning in over an impeller has exactly the right depth - tip in the broth,
  // clear of the floor, both green, and through the blades. Every other port hangs straight, so its
  // hardware never leaves the radius its flange sits on and the question never came up; the probes
  // are the only ones that lean.
  //
  // It is a 2D question, not a solid intersection, because both obstacles are AXISYMMETRIC: the
  // impellers sweep a full circle and the ring is one, so neither cares what angle a probe hangs
  // at. utils/meridian.scad carries the argument and the arithmetic.
  _floor_z = -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height);

  _obstacles = [
    [
      "lower impeller",
      [0, head_impeller_swept_radius(impeller_diameter),
       _floor_z + _impeller_clearance - impeller_height / 2,
       _floor_z + _impeller_clearance + impeller_height / 2],
    ],
    [
      "upper impeller",
      [0, head_impeller_swept_radius(impeller_diameter),
       _floor_z + _impeller_clearance + impeller_spacing - impeller_height / 2,
       _floor_z + _impeller_clearance + impeller_spacing + impeller_height / 2],
    ],
    [
      "sparge ring",
      [_sparge_ring_radius - sparge_ring_section[0] / 2,
       _sparge_ring_radius + sparge_ring_section[0] / 2,
       _floor_z + _sparge_ring_height - sparge_ring_section[1] / 2,
       _floor_z + _sparge_ring_height + sparge_ring_section[1] / 2],
    ],
  ];

  _hanging = concat(
    [
      for (i = [0:_n - 1])
        if (head_port_type(_ports[i]) == "probe")
          each let (
            _runs = head_probe_runs(head_port_probe(_ports[i]), vessel_opening_diameter, lid_flange_height, head_probe_tilt(_ports[i]))
          )
            [
              [str(head_port_function(_ports[i]), "'s collet"), _runs[0]],
              [str(head_port_function(_ports[i]), "'s tip"), _runs[1]],
            ]
    ],
    len(_tc_port) == 0
      ? []
      : [[
        "the thermocouple",
        head_thermocouple_run(head_port_probe(_tc_port[0]), vessel_opening_diameter, lid_flange_height),
      ]]
  );

  // Only pairs that share a height are reported. A run that never reaches an obstacle's height has
  // no radial clearance from it at all, and printing a large number for that would be a claim about
  // a comparison that never happened.
  for (h = _hanging)
    for (o = _obstacles)
      let (_gap = meridian_clearance(h[1], o[1]))
        if (!is_undef(_gap)) {
          echo(str(
            "reach clearance: ", h[0], " passes the ", o[0], " with ", _gap,
            " mm of radial room, over the ", o[1][2], " to ", o[1][3], " mm the two share"
          ));

          assert(
            _gap > 0,
            str(
              h[0], " runs through the ", o[0], " by ", -_gap,
              " mm radially, over the heights they share. Both are drawn, so this is parts in the ",
              "same space rather than a margin being thin."
            )
          );
        }

  // ----- can the vessel keep the DO probe fed, and where does it sit in the gas? -----
  //
  // The probe is GALVANIC: it consumes the oxygen it reads, so in still liquid its reading decays
  // instead of settling - Atlas chart 90 % down to 20 % in thirty seconds. Every other number this
  // model reports about oxygen assumes the probe is telling the truth, and nothing has ever asked
  // whether the vessel keeps it fed.
  //
  // Atlas ask for a FLOW where a tank can only offer a VELOCITY, and the conversion is the
  // assumption in all of this: 60 mL/min spread over the probe's own sensing face is what the face
  // has to see. Its area is the tip's, which over-states the membrane a little and so the velocity
  // it asks for a little under - the error is in the safe direction and it is small either way.
  _do_probe = [
    for (q = _ports) if (head_port_type(q) == "probe" && head_port_function(q) == "do_probe") q
  ];

  if (len(_do_probe) > 0 && _po_correlated)
    let (
      _do = head_port_probe(_do_probe[0]),
      _face = PI / 4 * pow(atlas_probe_tip_dia(_do), 2),
      _needed = do_probe_flow_requirement * 1000 / 60 / _face
    ) {
      for (sp = _drive_speeds)
        let (
          _v = stirred_tank_circulation_velocity(
            _impeller_flow_number, sp[1], impeller_diameter, _vessel_bore
          ) * 1000
        )
          echo(str(
            "DO probe feed ", sp[0], " ", sp[1], " rpm: the vessel turns over at ", _v,
            " mm/s mean and the probe needs ", _needed, " mm/s past its face - ", _v / _needed,
            "x. MEAN, not local: it says the tank moves, not that this corner of it does"
          ));

      // Where it sits in what the sparger makes. The distance is exact; where the gas GOES is not
      // modelled and should not be guessed - the holes discharge inward, toward the impeller, and
      // the impeller disperses what it catches. What is worth stating is that the sensing face
      // hangs this close to a ring of bubbles, whichever way they turn.
      let (
        _tip = head_probe_axis_at(
          vessel_opening_diameter, lid_flange_height,
          bayonet_probe_port_collet_drop(_do, probe_port_transition_length)
          + atlas_probe_body_height(_do) + atlas_probe_tip_height(_do),
          head_probe_tilt(_do_probe[0])
        )
      )
      {
        echo(str(
          "DO probe in the gas: its face sits ", _tip[1] - (_floor_z + _sparge_ring_height),
          " mm above the sparge ring's centreline and ", abs(_tip[0] - _sparge_ring_radius),
          " mm off its radius. Where the bubbles actually go is a bench question - the holes point ",
          "inward, toward the impeller, and the impeller disperses what it catches - so nothing ",
          "here models it."
        ));

        // Reported, not asserted, and deliberately not dressed up as a plume model. What can be
        // said exactly is that the face stands within the ring's own width of the ring's radius,
        // directly above it. Whether that matters is a reading taken on the bench, not a number.
        if (abs(_tip[0] - _sparge_ring_radius)
          < sparge_ring_section[0] / 2 + atlas_probe_tip_dia(_do) / 2)
          echo(str(
            "WARNING DO probe: its face overlaps the sparge ring's own radius and hangs ",
            _tip[1] - (_floor_z + _sparge_ring_height), " mm over it. A galvanic probe reads HIGH ",
            "with a bubble on the membrane and low with none moving past, so this is the one ",
            "placement that can be wrong in both directions at once. See TODO.md."
          ));
      }
    }

  // ----- and does it fit through the mouth on the way in? -----
  //
  // A different question from the one above, and it is the one that bounds the lean. The lid
  // DESCENDS through the jar's neck, so every part of what hangs off it is level with the mouth at
  // some moment on the way down - what matters is the widest the assembly ever gets, not where it
  // finishes. Nothing said so, and a 7 degree lean drew a collet 2.5 mm too wide for the jar it was
  // for while every other check stayed green.
  //
  // What is checked is the PRINTED port. The probes go in afterwards, down through the bayonet's
  // bore into the collet, so they never pass the mouth at all; their own reach is checked against
  // the vessel's internals above.
  //
  // The transition cone above the collet flares wider, to meet the bayonet - but it sits where the
  // lean has barely carried it, and the bayonet's own footprint is inside the plug by construction,
  // since head_port_circle_radius() is derived from it. The collet's bottom is the widest point and
  // that is the end of the run measured here.
  for (i = [for (j = [0:_n - 1]) if (head_port_type(_ports[j]) == "probe") j])
    let (
      _tilt = head_probe_tilt(_ports[i]),
      _collet = head_probe_runs(
        head_port_probe(_ports[i]), vessel_opening_diameter, lid_flange_height, _tilt
      )[0],
      _widest = meridian_max_radius(_collet),
      _mouth = vessel_opening_diameter / 2
    ) {
      echo(str(
        "port fit: ", head_port_function(_ports[i]), "'s collet reaches ", _widest,
        " mm from the axis leaning ", _tilt, " deg, and the mouth is ", _mouth, " mm - ",
        _mouth - _widest, " mm to spare on the way in"
      ));

      assert(
        _widest <= _mouth,
        str(
          head_port_function(_ports[i]), "'s collet reaches ", _widest,
          " mm from the axis and the jar's mouth is ", _mouth, " mm, so the lid cannot be lowered ",
          "past it - ", _widest - _mouth, " mm too wide. The lean is what buys this, so it is the ",
          "lean that has to give."
        )
      );
    }

  // What the riser has to span, and what it costs to push gas down it. The socket's top face is
  // the ring's own top plus the boss standing on it.
  _sparge_socket_top =
  -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
  + _sparge_ring_height + sparge_ring_section[1] / 2 + 8;
  // The tube runs from inside its socket to clear of its port. Measured to the PORT's top face and
  // not the lid's, because the flange stands between the two and it is the flange a hose must clear.
  _sparge_port_top = bayonet_flange_height(head_interface_for("tube", steel_tube_od(sparge_riser_tube) / 2));
  _sparge_riser_length =
    _sparge_port_top + sparge_riser_proud - (_sparge_socket_top - sparge_riser_insertion);
  _sparge_submergence = vessel_punt_height + _liquid_height - _sparge_ring_height;

  // What holds the ring up, and how much it can still move. One tube is a cantilever; each extra
  // one at a real angle from it is another. Reported rather than asserted - what the flow actually
  // pushes the ring with is not something this model knows.
  // The cantilever is NOT the whole tube. What holds the ring is the span between the lid's
  // underside, where the port last touches the tube, and the socket - the stub standing proud above
  // the lid carries no load and the length inside the lid is supported. Using the whole tube here
  // understated the stiffness by the cube of the ratio.
  _riser_I = steel_tube_second_moment(sparge_riser_tube);
  _riser_free = -lid_thickness - _sparge_socket_top;
  _riser_k = 3 * steel_tube_modulus() * _riser_I / pow(_riser_free, 3);

  // Where to drill a support tube, which is a hand operation the model is nonetheless the only
  // thing that can dimension - it is the only one that knows where the culture stops. A support
  // tube is capped in its blind socket and does its own job through a hole higher up, so the hole
  // has to be ABOVE the liquid and BELOW the lid's inner face, and it is measured from the tube's
  // TOP end because that is the end you can reach when the tube is in your hand.
  //
  // Nearer the lid is better within that window: the headspace is there for foam, and a vent hole
  // just above a working surface is the first thing foam finds.
  _riser_top_z = _sparge_port_top + sparge_riser_proud;
  _liquid_surface_z =
  -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
  + vessel_punt_height + _liquid_height;

  if (len(_sparge_support_angles) > 0)
    echo(str(
      "sparge support drilling: a support tube vents through a hole drilled between ",
      _riser_top_z + lid_thickness, " and ", _riser_top_z - _liquid_surface_z,
      " mm from its TOP end - past the lid's inner face, short of the culture. Nearer the first ",
      "number is better; the headspace is there for foam and foam finds the lowest hole. A tube ",
      "meant to discharge INTO the culture instead is drilled past the second."
    ));

  echo(str(
    "sparge support: ", 1 + len(_sparge_support_angles), " tubes at ",
    concat([_sparge_feed_angle], _sparge_support_angles), " deg; ", _riser_free,
    " mm of free tube each, so one is ", _riser_k,
    " N/mm, so ", 1 / _riser_k, " mm of sway per newton against ",
    head_ring_baffle_gap(vessel_opening_diameter, impeller_diameter), " mm to the baffles"
  ));

  if (len(_sparge_support_angles) == 0)
    echo(str(
      "WARNING sparge support: the ring hangs on the feed riser alone. ",
      head_ring_baffle_gap(vessel_opening_diameter, impeller_diameter) * _riser_k,
      " N sideways closes its gap to the baffles."
    ));

  echo(str(
    "sparge riser: ", steel_tube_od(sparge_riser_tube), " x ", steel_tube_id(sparge_riser_tube), " mm tube, ", _sparge_riser_length,
    " mm long - ", sparge_riser_proud, " mm proud of its port for a hose, down to ",
    sparge_riser_insertion, " mm inside the socket; ",
    head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2 - steel_tube_od(sparge_riser_tube),
    " mm of slack through the port's bore"
  ));

  // The port's ring is chosen by its ID, and its ID is the tube: two registered rows that have to
  // agree, so this compares them rather than assuming. A ring stretched onto a rod thins the cord
  // it seals with, which is why the ceiling is the same 5% a piston gland takes.
  _riser_seal_stretch = oring_stretch(
    oring_inner_diameter(tube_port_riser_oring), steel_tube_od(sparge_riser_tube)
  );

  assert(
    _riser_seal_stretch >= 0 && _riser_seal_stretch <= 0.05,
    str(
      "sparge riser seal: a ", oring_name(tube_port_riser_oring), " ring on a ",
      steel_tube_od(sparge_riser_tube), " mm tube is ", _riser_seal_stretch * 100,
      "% of stretch, outside the 0-5% a rod seal takes"
    )
  );

  // Measured off the gland the port actually cuts rather than repeating the squeeze it was cut at,
  // and against the TUBE rather than the ring's own ID, which is the diameter it really seals on.
  _riser_seal_squeeze =
    1 - (bayonet_bore_gland_radius(tube_port_riser_oring) - steel_tube_od(sparge_riser_tube) / 2)
        / oring_cross_section(tube_port_riser_oring);

  _riser_port_bore =
    head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2;

  echo(str(
    "sparge riser seal: ", oring_name(tube_port_riser_oring), " (", oring_part_number(tube_port_riser_oring),
    ") in each of ", 1 + len(sparge_support_functions), " ports, at ", _riser_seal_stretch * 100,
    "% stretch and ", _riser_seal_squeeze * 100, "% squeeze - without it each port is a ",
    PI / 4 * (pow(_riser_port_bore, 2) - pow(steel_tube_od(sparge_riser_tube), 2)),
    " mm2 hole into the headspace, and the sterile filter only covers the way in"
  ));

  // It is bought as a length of stock and cut, not as a part per tube, so the purchase list needs
  // the stock and the cut list rather than a quantity - which is what this line gives it.
  _riser_count = 1 + len(_sparge_support_angles);
  _riser_stock = steel_tube_stock_for(_sparge_riser_length, _riser_count);

  echo(str(
    "sparge tube stock: ", steel_tube_part_number(sparge_riser_tube), ", ",
    steel_tube_material(sparge_riser_tube), " ", steel_tube_construction(sparge_riser_tube),
    ", ", steel_tube_temper(sparge_riser_tube), " temper; cut ", _riser_count, " x ",
    _sparge_riser_length, " mm = ", _riser_count * _sparge_riser_length, " mm",
    is_undef(_riser_stock)
      ? " - LONGER THAN ANY STOCK LENGTH, so it needs joining or a different tube"
      : str(" from a ", _riser_stock, " mm length, leaving ",
            _riser_stock - _riser_count * _sparge_riser_length, " mm spare")
  ));

  echo(str(
    "sparge back-pressure: ", _sparge_submergence, " mm of culture over the ring is ",
    _sparge_submergence / 1000 * stirred_tank_medium_density() * 9.81,
    " Pa, plus ", stirred_tank_capillary_pressure(sparge_hole_diameter),
    " Pa of capillary = ", _sparge_submergence / 1000 * stirred_tank_medium_density() * 9.81
    + stirred_tank_capillary_pressure(sparge_hole_diameter),
    " Pa the gas supply has to beat before anything bubbles"
  ));


  // ----- gas supply -----
  //
  // What the pump does against this vessel, what a throttle has to take out, and which meter reads
  // it. All of it derives from the registered pump and the vessel, so it re-answers itself for
  // another jar rather than being a table someone has to recompute.
  _gas_vessel_pressure = _sparge_submergence / 1000 * stirred_tank_medium_density() * 9.81
  + stirred_tank_capillary_pressure(sparge_hole_diameter);
  _gas_band = [sparge_vvm_band[0] * _culture_volume, sparge_vvm_band[1] * _culture_volume];

  // The line's own losses at the design flow. All three were missing from what the pump was said to
  // have to beat: the filter is the larger by an order of magnitude, and the riser and the check
  // valve are small but real. The check valve was the last one left out - it was registered after
  // the filter and the riser were counted, and its own row has said 1.85 kPa the whole time while
  // this sum ignored it.
  _gas_filter_drop = gas_filter_pressure_drop(_gas_band[1], sparge_filter_drop_slope);
  _gas_riser_drop = gas_tube_pressure_drop(
    _gas_band[1], steel_tube_id(sparge_riser_tube), _sparge_riser_length);
  _gas_check_valve_drop = sparge_check_valve_cracking
    + gas_valve_pressure_drop(_gas_band[1], sparge_check_valve_cv, _gas_vessel_pressure);
  _gas_back_pressure =
  _gas_vessel_pressure + _gas_filter_drop + _gas_riser_drop + _gas_check_valve_drop;

  echo(str(
    "gas line losses: filter ", _gas_filter_drop,
    " Pa (EXTRAPOLATED, not measured), check valve ", _gas_check_valve_drop,
    " Pa (", sparge_check_valve_cracking, " of it just to crack) and riser ", _gas_riser_drop,
    " Pa at ", _gas_band[1], " L/min, on top of the vessel's ", _gas_vessel_pressure,
    " - so the pump beats ", _gas_back_pressure, " Pa, and the filter alone is ",
    _gas_filter_drop / _gas_vessel_pressure, "x the vessel"
  ));
  _gas_free_flow = air_pump_free_flow_min(head_air_pump);
  _gas_dead_head = air_pump_dead_head(head_air_pump);

  echo(str(
    "gas supply: ", air_pump_name(head_air_pump), " would give ",
    gas_pump_flow(_gas_free_flow, _gas_dead_head, _gas_back_pressure),
    " L/min against this line's ", _gas_back_pressure, " Pa, where ", _gas_band[1],
    " L/min is wanted - so a throttle has to drop ",
    gas_throttle_pressure(_gas_free_flow, _gas_dead_head, _gas_band[1], _gas_back_pressure),
    " Pa on top of the line's own"
  ));

  // What that throttle is, as a part rather than as a pressure. The filter takes more than half of
  // what the valve would otherwise have had, so this number moved a long way when it landed.
  _gas_valve_cv = gas_valve_cv(
    _gas_band[1],
    gas_throttle_pressure(_gas_free_flow, _gas_dead_head, _gas_band[1], _gas_back_pressure),
    _gas_back_pressure);

  echo(str(
    "gas throttle: a valve of Cv ", _gas_valve_cv, " passes ", _gas_band[1],
    " L/min at that drop. Sold Cv should be 2-4x it, so the setting sits mid-travel rather than ",
    "at either stop"
  ));

  echo(str(
    "gas metering: ", sparge_vvm_band[0], "-", sparge_vvm_band[1], " vvm on ", _culture_volume,
    " L is ", _gas_band[0], "-", _gas_band[1], " L/min, ",
    is_undef(gas_meter_full_scale(_gas_band[0], _gas_band[1]))
      ? "which no single rotameter scale covers at 10% readability"
      : str("so a 0-", gas_meter_full_scale(_gas_band[0], _gas_band[1]), " L/min rotameter")
  ));

  // The pump's own numbers, checked against each other rather than believed
  if (gas_pump_implied_efficiency(_gas_free_flow, _gas_dead_head, air_pump_power(head_air_pump)) > 0.5)
    echo(str(
      "gas supply: ", air_pump_name(head_air_pump), "'s free flow and dead head cannot be ",
      "simultaneous - together they are ",
      gas_pump_implied_efficiency(_gas_free_flow, _gas_dead_head, air_pump_power(head_air_pump)) * 100,
      "% of its electrical input. They are the ends of its curve, which is how this reads them."
    ));

  // Oldshue p.228: gas rising through an axial impeller fights its pumping, and it takes 8-10x the
  // gas stream's power to hold the flow pattern. A radial impeller needs only 3x.
  _gas_ceiling = stirred_tank_gas_flow_ceiling(
    stirred_tank_power(impeller_diameter, _baffle_rpm, _impeller_po),
    impeller_pumping(head_impeller_type), _liquid_height);

  echo(str(
    "gas against the impeller: ", impeller_pumping(head_impeller_type), " pumping needs ",
    stirred_tank_gas_power_ratio(impeller_pumping(head_impeller_type)),
    "x the gas stream's power to hold its flow pattern, which at ", _baffle_rpm,
    " rpm caps aeration at ", _gas_ceiling * 60000 / _culture_volume, " vvm"
  ));

  if (sparge_design_vvm > _gas_ceiling * 60000 / _culture_volume)
    echo(str(
      "WARNING gas: ", sparge_design_vvm, " vvm is above the ", _gas_ceiling * 60000 / _culture_volume,
      " vvm at which the gas stream starts to negate this impeller's pumping. Run faster, or a ",
      "radial impeller would take ", stirred_tank_gas_flow_ceiling(
        stirred_tank_power(impeller_diameter, _baffle_rpm, _impeller_po), "radial", _liquid_height)
      * 60000 / _culture_volume, " vvm at the same power."
    ));

  // Echoed above and asserted here: a riser wider than the bore it passes is not a tight fit, it
  // is an assembly that does not exist. design-conventions.md puts that on the assert side.
  assert(
    steel_tube_od(sparge_riser_tube) <= head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2,
    str(
      "Sparge riser is ", steel_tube_od(sparge_riser_tube), " mm across but the air_in port bores ",
      head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2, " mm, so it cannot pass through the lid."
    )
  );

  // There was an assert here that the riser's bore was inside its outside diameter, from when the
  // two were separate literals that could disagree. The row carries od and wall now and the bore
  // is od - 2 * wall, so it could only compare a number with itself. Removed rather than left to
  // look like it was guarding something; see docs/design-conventions.md on dead asserts.

  // The feed riser and the support tubes are the same part in the same material, so they are drawn
  // together - one tube down each of the sparger's ports, whether it carries gas or only load.
  module _sparge_tube() {
    translate([port_circle_radius, 0, _sparge_socket_top - sparge_riser_insertion])
      difference() {
        cylinder(h=_sparge_riser_length, d=steel_tube_od(sparge_riser_tube));
        translate([0, 0, -z_fight])
          cylinder(h=_sparge_riser_length + 2 * z_fight, d=steel_tube_id(sparge_riser_tube));
      }
  }

  if (render_sparge_tubes || render_all)
    color("grey")
      for (a = concat([_sparge_feed_angle], _sparge_support_angles))
        rotate([0, 0, a])
          _sparge_tube();

  if (render_sparger || render_all)
    color(prints2_color)
      translate([
          0, 0,
          -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
          + _sparge_ring_height,
        ])
        sparge_ring(
          radius=_sparge_ring_radius,
          section=sparge_ring_section,
          wall=sparge_ring_wall,
          hole_diameter=sparge_hole_diameter,
          hole_count=sparge_hole_count,
          feed_angle=_sparge_feed_angle,
          feed_radius=port_circle_radius,
          feed_bore=sparge_feed_bore,
          support_angles=_sparge_support_angles
        );

  // the port circle is sized against the plug's edge, so what it does not settle is whether
  // that many ports clear each other on it. The flange is the widest thing a port has, and it
  // carries the o-ring groove outboard of the bore, so it is what meets the neighbour first.
  // The chord is the same between every pair, but the flanges are not, so what limits the circle is
  // the worst PAIR rather than twice any one port. Spreading the big ports so no two touch is worth
  // more than any single size change - see docs/ports-layout.md.
  _port_gap = min([
    for (i = [0:_n - 1])
      2 * port_circle_radius * sin(180 / _n)
      - bayonet_flange_radius(head_port_interface(_ports[i]))
      - bayonet_flange_radius(head_port_interface(_ports[(i + 1) % _n]))
  ]);

  assert(
    _port_gap >= lid_holes_offset,
    str(_n, " ports leave ", _port_gap, " mm between flanges on a ", port_circle_radius * 2, " mm circle; ", lid_holes_offset, " mm is the least this lid keeps.")
  );

  // The motor mount stands on the same face as those flanges, so the ports have to clear it going
  // inward as well as clearing each other going around. Nothing checked this: on a narrow mouth the
  // port circle comes in far enough that the mount lands on top of the flanges, and the spacing
  // assert above fires first only because such a mouth is crowded anyway. Both radii are measured
  // from the lid's centre, so the check is one subtraction.
  _mount_to_ports = port_circle_radius - bayonet_flange_radius(head_widest_interface(_ports)) - motor_mount_body_diameter / 2;

  assert(
    _mount_to_ports >= lid_holes_offset,
    str(
      "Motor mount is ", motor_mount_body_diameter, " mm across and the port flanges reach in to r ",
      port_circle_radius - bayonet_flange_radius(head_widest_interface(_ports)), ", leaving ", _mount_to_ports,
      " mm between them; ", lid_holes_offset, " mm is the least this lid keeps."
    )
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
  _groove_w = head_plug_groove_width(vessel_opening_diameter);
  // 0% stretch; anything down to this over 1.05 still hugs the groove. With no ring selected there
  // is no cord to cut a groove from, so the range is quoted against the largest cord registered -
  // which is the family a plug ring comes from, the small ones being port face seals.
  _plug_cord_nominal = max([for (r = orings) oring_cross_section(r)]);
  _ring_id =
  is_undef(_plug_ring)
    ? vessel_opening_diameter - 2 * oring_gland_depth(_plug_cord_nominal, lid_plug_oring_squeeze)
    : _groove_r * 2;

  _gasket_w = head_gasket_width(vessel_wall_thickness);
  _gasket_rim = head_gasket_rim_width(vessel_wall_thickness);
  _gasket_force = head_gasket_seating_force(vessel_opening_diameter, vessel_wall_thickness);

  echo(str(
    "lid gasket: cut ", _gasket_ir * 2, " x ", _gasket_or * 2, " mm from ",
    gasket_sheet_name(lid_gasket_sheet), " (", gasket_sheet_thickness(lid_gasket_sheet),
    " mm), recess ", head_gasket_depth(), " mm deep (", lid_gasket_compression * 100, "% squeeze); ",
    gasket_sheet_yield(lid_gasket_sheet, _gasket_or * 2), " per ",
    gasket_sheet_size(lid_gasket_sheet)[0], " x ", gasket_sheet_size(lid_gasket_sheet)[1], " mm sheet"
  ));

  // The only load in the reactor, so it is worth saying out loud. Reported and never asserted on:
  // the modulus is correlated from the sheet's hardness rather than measured. See
  // utils/gasket_load.scad.
  echo(str(
    "lid gasket load: ", _gasket_w, " mm wide on a ", _gasket_rim, " mm rim, ",
    _gasket_force, " N to hold ", lid_gasket_compression * 100, "% squeeze, ",
    gasket_seat_stress(
      gasket_sheet_shore_a(lid_gasket_sheet), _gasket_w,
      gasket_sheet_thickness(lid_gasket_sheet), lid_gasket_compression
    ), " MPa on the glass"
  ));

  if (_gasket_w < lid_gasket_width_min)
    echo(str(
      "WARNING lid gasket: ", _gasket_w, " mm wide, under the ", lid_gasket_width_min,
      " mm this lid wants. The jar's ", vessel_wall_thickness, " mm wall leaves only ", _gasket_rim,
      " mm of rim once both lands are taken. It will be fiddly to cut and may not stay in its recess."
    ));

  if (_gasket_rim > lid_gasket_width_max)
    echo(str(
      "lid gasket: rim offers ", _gasket_rim, " mm but the gasket is held to ", lid_gasket_width_max,
      " mm. Taking the whole rim would cost ",
      gasket_seating_force(
        gasket_sheet_shore_a(lid_gasket_sheet), _gasket_rim,
        gasket_sheet_thickness(lid_gasket_sheet), 2 * _gasket_ir + _gasket_rim,
        lid_gasket_compression
      ), " N instead of ", _gasket_force, "."
    ));
  _plug_ring = head_plug_oring_selected(vessel_opening_diameter);
  _plug_stretch =
  is_undef(_plug_ring) ? undef : oring_stretch(oring_inner_diameter(_plug_ring), _ring_id);

  echo(str(
    is_undef(_plug_ring)
      ? str("plug o-ring: NO registered ring suits this mouth. ")
      : str("plug o-ring: ", oring_name(_plug_ring), " at ", _plug_stretch * 100, "% stretch. "),
    "Groove takes ID ", _ring_id, " mm / ", _ring_id / 25.4, " in down to ",
    _ring_id / 1.05, " mm / ", _ring_id / 1.05 / 25.4, " in (0-5% stretch)"
  ));

  // One ring is registered for the whole vessel registry while the groove is cut from each jar's
  // own bore, so what this catches is the ring being wrong for the jar, not the jar being wrong.
  // Closing it properly means carrying a plug ring per vessel row - see the audit.
  assert(
    !is_undef(_plug_ring),
    str(
      "No registered o-ring suits a ", vessel_opening_diameter, " mm mouth. Its groove wants a ring ",
      "of ", _ring_id / 1.05, " to ", _ring_id, " mm free ID on a ",
      _plug_cord_nominal, " mm cord - under that it sags out of the ",
      "groove, over it the cord thins. Register one and it will be picked up; see ",
      "scad/purchased/orings.scad."
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
    _groove_r - (port_circle_radius + bayonet_lock_bore_radius(head_widest_interface(_ports))) >= lid_holes_offset,
    str(
      "A ", oring_cross_section(_plug_ring), " mm cord puts the plug groove at r ", _groove_r, ", leaving ",
      _groove_r - (port_circle_radius + bayonet_lock_bore_radius(head_widest_interface(_ports))),
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
    oring_cross_section(_plug_ring),
    _groove_w,
    oring_gland_depth(oring_cross_section(_plug_ring), lid_plug_oring_squeeze)
  );

  assert(
    _plug_fill <= 0.90,
    str("The plug o-ring fills ", _plug_fill * 100, "% of its gland; over 90 leaves the squeeze nowhere to go.")
  );

  // how much of the cord the groove is actually holding onto, which is the check against it
  // rolling out. Measured from the plug's own face, not from the bore it seals against.
  _plug_containment = oring_containment(
    oring_cross_section(_plug_ring),
    head_lid_plug_diameter(vessel_opening_diameter) / 2 - _groove_r
  );

  assert(
    _plug_containment >= 0.75,
    str("Only ", _plug_containment * 100, "% of the plug o-ring's section sits inside its groove; under 75 it rolls out.")
  );

  // The coupling decides where a port comes to rest, so a port carrying an orientation is only
  // as true as the coupling is keyed. Unkeyed, each of these locks just as willingly in any of
  // its seatings and the plate or the lean ends up somewhere the model never showed.
  _oriented_at = [for (i = [0:_n - 1]) if (head_port_is_oriented(head_port_type(_ports[i]))) i];

  // checked before the keying assert below, which would otherwise report the missing helpers as
  // an undef seating count and send you looking in the wrong place
  assert(
    !is_undef(bayonet_pin_angles(head_widest_interface(_ports))),
    "head: needs bayonet-lock-scad >= 0.11.0, for pin_angles and the keying functions"
  );

  // Keying belongs to the interface, and ports no longer share one, so this asks each oriented port
  // about its own rather than about a global that may not be the one it mates to.
  _unkeyed_at = [
    for (i = _oriented_at) if (!bayonet_is_keyed(head_port_interface(_ports[i]))) i,
  ];

  // Built by comprehension rather than by indexing _unkeyed_at[0]: OpenSCAD evaluates an assert's
  // MESSAGE whether or not the assert fires, so reaching into this list when it is empty - which is
  // the passing case - reads _ports[undef] and warns six times on every render.
  _unkeyed_detail = [
    for (i = _unkeyed_at) str(
      head_port_function(_ports[i]), " on ", bayonet_name(head_port_interface(_ports[i])),
      " (", bayonet_seating_count(head_port_interface(_ports[i])), " seatings, ",
      360 / bayonet_seating_count(head_port_interface(_ports[i])), " deg apart)"
    ),
  ];

  assert(
    len(_unkeyed_at) == 0,
    str(
      "These ports carry an orientation on an unkeyed interface, so each would come to rest at one ",
      "of its seatings rather than where it is drawn: ", _unkeyed_detail, ". Key the interface."
    )
  );

  assert(
    len(_baffle_at) == 0 || _baffle_at == [for (k = [0:len(_baffle_at) - 1]) _baffle_at[0] + k * _n / len(_baffle_at)],
    str("Baffles must come out equally spaced, but ", len(_baffle_at), " of them sit at ", _baffle_at, " of ", _n, " holes.")
  );

  assert(
    _baffle_length <= baffle_max_length,
    str("Baffle is ", _baffle_length, " mm long and would reach the jar's floor; ", baffle_max_length, " mm is the most that clears it.")
  );

  assert(
    !_has_baffles
    || port_circle_radius + _baffle_width / 2 <= vessel_opening_diameter / 2 - baffle_neck_clearance,
    str("Baffle reaches ", port_circle_radius + _baffle_width / 2, " mm out, past the ", vessel_opening_diameter / 2 - baffle_neck_clearance, " mm the jar's neck allows.")
  );

  // Every lock in the lid's bores, in the port datum. The bore is bayonet_port_hole_fudge
  // narrower than the lock, so this unions into the lid rather than dropping into it.
  module lid_locks() {
    for (i = [0:_n - 1])
      head_port_at(i, vessel_opening_diameter)
        bayonet_port(type=head_port_interface(_ports[i]), part="lock", panel_thickness=lid_thickness);
  }

  // The lid part: the blank, pocketed for the bearing and shaft and bored for the ports, with
  // its locks. One printed piece - the channels are the walls of its bores, so a lid without
  // them exports as twelve plain holes and nothing will lock into it.
  if (render_lid || render_all) {
    color(prints2_color)
      union() {
        rotate([0, 180, 0])
          lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, joint_outer_diameter, post_pts, post_hole_diameter, shaft_diameter(_shaft));
        lid_locks();
      }
  }

  // the locks alone, for looking at the channels the assembled lid buries
  if (render_bayonet_lock && !(render_lid || render_all)) {
    color(prints2_color)
      lid_locks();
  }

  // The culture, revolved from the SAME clipped profile vessel_profile_litres() integrates, so what
  // is drawn and what is echoed cannot disagree - the fill line is one statement, not two. The
  // profile is in the jar's own frame, y up from the outside of its base, so it is dropped by the
  // whole stack: internal height, punt, base and the lid flange standing on the rim.
  if (render_culture)
    color("DarkSeaGreen", 0.35)
      translate([0, 0, -(vessel_internal_height + vessel_punt_height + vessel_wall_thickness + lid_flange_height)])
        rotate_extrude($fn=64)
          polygon(
            concat(
              vessel_profile_below(vessel_profile, _floor_y + _liquid_height),
              [[0, _floor_y + _liquid_height]]
            )
          );

  // The templates the rim gasket is cut with, on the three numbers the gasket itself is drawn from
  // - so the tool cannot describe a different ring than the model does. Concentric with the gasket
  // and at its plane, which is where the two can be compared.
  if (render_gasket_cutter)
    translate([0, 0, -lid_flange_height - (gasket_sheet_thickness(lid_gasket_sheet) - head_gasket_depth())])
      gasket_cutter(_gasket_ir * 2, _gasket_or * 2, gasket_sheet_thickness(lid_gasket_sheet), part=gasket_cutter_part_to_render);

  // The EPDM. Each is drawn at its free size on the diameter it is installed at, so it overlaps
  // what it seals against by exactly the squeeze its gland was cut for - that overlap is the
  // check. Kept behind their own flag so a part export never picks up a purchased ring.
  if (render_seals || render_all) {
    // rim gasket, standing proud of the flange by what the recess squeezes out of it
    translate([0, 0, -lid_flange_height - (gasket_sheet_thickness(lid_gasket_sheet) - head_gasket_depth())])
      sheet_gasket(_gasket_ir * 2, _gasket_or * 2, gasket_sheet_thickness(lid_gasket_sheet));

    // plug o-ring, stretched onto its groove and reaching past the plug into the glass
    translate([0, 0, -lid_flange_height - lid_plug_height / 2])
      oring(_plug_ring, id=_ring_id);

    // port o-rings, each seated against the outer wall of its gland
    for (i = [0:_n - 1])
      let (_pi = head_port_interface(_ports[i]))
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, bayonet_gland_depth(_pi) / 2])
            oring(
              bayonet_oring(_pi),
              id=(bayonet_gland_outer_radius(_pi) - bayonet_oring_cs_diameter(_pi)) * 2
            );
  }

  // Port pin halves. Each shares the lock's datum, so it needs no placement beyond its hole
  // centre; port_position only turns it about its own axis, between locked and entry.
  if (port_to_render != "" || render_tube_pinlock || render_probe_pinlock || render_thermocouple_pinlock || render_baffle_pinlock || render_all) {
    for (i = [0:_n - 1]) {
      _port = _ports[i];
      _type = head_port_type(_port);
      _port_turn = (port_position == "entry")
        ? bayonet_entry_rotation(head_port_interface(_port))
        : 0;
      // Naming one port SELECTS it, rather than filtering what a type flag already allowed: an
      // export then asks for a part by name and gets exactly it, with no second flag to remember.
      _show = (port_to_render != "")
        ? port_to_render == head_port_export_name(_ports, i)
        : render_all || (_type == "tube" && render_tube_pinlock) || (_type == "probe" && render_probe_pinlock) || (_type == "thermocouple" && render_thermocouple_pinlock) || (_type == "baffle" && render_baffle_pinlock);

      if (_show)
        color(prints1_color)
          head_port_at(i, vessel_opening_diameter)
            rotate([0, 0, _port_turn])
              head_port(_port, lid_thickness, _baffle_width, _baffle_length, _baffle_segments);
    }
  }

  // The probes themselves. Their bodies are what every probe collet is bored to and what each
  // flange is labelled with, and nothing ever drew one - so where a tip lands has only ever been
  // arithmetic. Placed off the same two numbers the port is built from, so the probe cannot end up
  // somewhere the collet holding it is not.
  //
  // atlas_probe() draws tip-UP from its neck, and the collet's body pocket runs DOWN from its
  // origin, so the probe is flipped and then lifted by its own neck height to seat the body.
  if (render_probes || render_all)
    for (i = [for (j = [0:_n - 1]) if (head_port_type(_ports[j]) == "probe") j])
      let (_p = head_port_probe(_ports[i]))
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, -head_lid_thickness(lid_flange_height)])
            rotate([0, -head_probe_tilt(_ports[i]), 0])
              translate([
                0, 0,
                atlas_probe_neck_height(_p)
                - bayonet_probe_port_collet_drop(_p, probe_port_transition_length),
              ])
                rotate([180, 0, 0])
                  atlas_probe(_p);

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
        shaft_diameter=shaft_diameter(_shaft),
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

  // The 608 the lid is pocketed for. Its numbers have cut that pocket all along without the part
  // ever being drawn, which is a pocket nobody can check against the thing it is cut for. The
  // pocket runs from this face down by bb_width and ball_bearing() draws itself centred, so half a
  // width down puts it in the hole rather than beside it.
  if (render_bearing || render_all)
    translate([0, 0, -bb_width(shaft_bearing) / 2])
      ball_bearing(shaft_bearing);

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
        cylinder(h=shaft_length(_shaft), d=shaft_diameter(_shaft), center=false);
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

  // The screws that go in those holes. Vitamins, so they sit outside head_impeller()'s difference
  // and keep their own colour. Placed from the same three numbers the holes are - the hub radius,
  // the collar's mid-height and the angle list - so the two cannot drift apart.
  //
  // Drawn pointing INWARD from the hub's outer surface: screw() runs its shaft down local -Z from
  // the socket, and rotate([0, 90, 0]) turns that into +X, which puts the socket on the outside
  // where a key reaches it and the cup tip at the shaft.
  module head_impeller_set_screws() {
    translate([0, 0, impeller_height / 2 + impeller_collar_height / 2])
      for (a = impeller_set_screw_at)
        rotate([0, 0, a])
          translate([impeller_hub_radius, 0, 0])
            rotate([0, 90, 0])
              screw(set_screw_screw(impeller_set_screw), set_screw_length(impeller_set_screw));
  }

  // The printed part and the screws that hold it, at one impeller's position. One placement, two
  // flags: the mirror below has to catch both, or the upper impeller's screws stay on the lower
  // one's angles.
  module head_impeller_assembly() {
    if (render_impeller || render_all) head_impeller();
    if (render_set_screws || render_all) head_impeller_set_screws();
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
        // Top ring tying the blade tips together, INBOARD of the radius rather than outboard.
        //
        // It used to run from impeller_radius out to impeller_radius + fin_width, which put 4 mm of
        // impeller outside the diameter every correlation is keyed on: the part swept 102.5 mm where
        // the model said 94.5, D/T was 0.488 against a reported 0.45, and the blades overlapped the
        // baffles by 1.98 mm. Nothing caught it because nothing compares what is drawn against what
        // is claimed - the baffle width is derived from impeller_diameter, and the ring was not.
        //
        // Inboard it still does its job: the blade's far face reaches r 46.55 against the ring's
        // inner edge at 43.25, so they overlap 3.3 mm radially and the full 4 mm axially.
        translate([0, 0, impeller_height / 2 - impeller_fin_width / 2])
          linear_extrude(impeller_fin_width, center=true)
            difference() {
              circle(r=impeller_radius, $fn=64);
              circle(r=impeller_radius - impeller_fin_width, $fn=64);
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
  if (render_impeller || render_set_screws || render_all) {
    translate([0, 0, -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height) + _impeller_clearance]) {
      if (impeller_to_render != "upper")
        head_impeller_assembly();

      // Mirrored, not turned over: that is what makes the pair oppose each other at all. Which of
      // them pumps up is then set by head_shaft_rotation, not by the part.
      if (impeller_to_render != "lower")
        translate([0, 0, impeller_spacing])
          mirror([0, 1, 0])
            head_impeller_assembly();
    }
  }
}

// Which jar this build is for, chosen BY NAME so a customizer parameter set can carry it - a .json
// holds values, not references, so it cannot name the variable. `just json` writes one set per
// registered vessel from this same registry.
reactor_vessel_name = "jar_10L_220x305"; // [generic, jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]
reactor_vessel = vessel_by_name(reactor_vessel_name);

assert(
  !is_undef(reactor_vessel),
  str("No registered vessel is named \"", reactor_vessel_name, "\". See scad/purchased/vessels.scad.")
);

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
  post_hole_diameter=frame_rod_hole_diameter(),
  vessel_profile=vessel_inner_profile(reactor_vessel)
);
