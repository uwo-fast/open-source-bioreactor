/**
 * @file head.scad
 * @brief Head subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <utils/bolt_pattern.scad>;
use <utils/facets.scad>;
use <utils/elastomer.scad>;
use <utils/oring_gland.scad>;
use <utils/stirred_tank.scad>;
use <utils/gas_supply.scad>;
use <utils/meridian.scad>;
use <custom/sheet_gasket.scad>;
use <custom/gasket_cutter.scad>;

use <custom/motor_mount.scad>;
use <custom/bayonet_port.scad>;
use <custom/impeller.scad>;
use <custom/sparger.scad>;

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
include <purchased/printers.scad>;
include <purchased/hose_clamps.scad>;
include <purchased/gas_filters.scad>;
include <purchased/check_valves.scad>;

include <custom/bayonet_interfaces.scad>;
include <custom/impellers.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/inserts.scad>; // F1BM4 type + insert()
include <NopSCADlib/vitamins/screws.scad>; // M4_cap_screw type + screw()
include <purchased/set_screws.scad>; // after screws.scad - the rows bind M4_grub_screw
include <purchased/air_pumps.scad>;
include <purchased/peri_pumps.scad>;
include <NopSCADlib/vitamins/ball_bearings.scad>; // BB608 type + bb_diameter()/bb_width()
use <NopSCADlib/vitamins/shaft_coupling.scad>;

// Preview only: the standalone preview derives the joint with the frame's own accessors rather
// than quoting it. See docs/architecture.md rule 1.
use <frame.scad>;

// Internals and tessellation, which are not build choices. See utils/facets.scad.
/* [Hidden] */
z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
// Tessellate by feature size. head() re-asserts these: $fn is dynamically scoped and `use`
// resolves it per OpenSCAD version, so a head rendered from bioreactor.scad would otherwise take
// the assembly's flat 64/128 on a newer binary.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

/* [Part Render Selection] */

// Overrides all other render flags
render_all = true;
// The printed lid itself, with its ports, pockets and gasket recess
render_lid = false;

// The gearmotor, bought, drawn where it sits on its mount
render_motor = false;
// The printed mount that stands the motor off the lid
render_motor_mount = false;
// Which piece of it, for a per-part export - the mount prints in three
motor_mount_part_to_render = "all"; // ["all", "base_plate", "face_plate", "middle_stand"]
// heat-set into the lid, and they stay there once set
render_motor_mount_inserts = false;
// the screws into them, which come out every service
render_motor_mount_screws = false;
// The bought coupler joining the gearbox shaft to the reactor shaft
render_shaft_coupler = false;
// the 608 in the lid's pocket
render_bearing = false;
// The 316 SS shaft, bought and cut to length
render_ext_shaft = false;
// The printed impellers on that shaft
render_impeller = false;
// Which of the pair, for a per-part export; they are mirror images, so two different parts
impeller_to_render = "both"; // [both, lower, upper]
// the grub screws holding each impeller to the shaft
render_set_screws = false;
// The bayonet lock rings alone, for looking at the channels an assembled lid buries
render_bayonet_lock = false;
// The pin half of every TUBE port - gas, media, acid, base
render_tube_pinlock = false;
// The pin half of the thermocouple port
render_thermocouple_pinlock = false;
// The pin half of both Ø16 Atlas probe ports
render_probe_pinlock = false;
// Narrows the pin halves above to one port by function ("air_in", "baffle_1"); "" is every port
port_to_render = "";
// Which piece of a baffle plate; undef emits them all interlocked, the assembled part
baffle_segment_to_render = undef;
// the Atlas probes themselves, hanging in their collets
render_probes = false;
// The pin half of each baffle port, which the plates hang from
render_baffle_pinlock = false;
// the EPDM parts: rim gasket, plug o-ring, port o-rings
render_seals = false;
// The culture at the fill line; not in render_all, it is not a part
render_culture = false;
// The templates the rim gasket is cut with; a tool, so not in render_all
render_gasket_cutter = false;
// Which of its two discs; "all" stands them side by side
gasket_cutter_part_to_render = "all"; // [all, outer, inner]
// the ring in the inter-impeller gap and its feed arm
render_sparger = false;
// The bought 316 riser and its supports; their own flag so a sparger export is a print file
render_sparge_tubes = false;

// Draw the lid's 24 bayonet halves as bare shells while previewing; renders are unaffected
fast_bayonet_preview = true;
$bayonet_shell_only = $preview && fast_bayonet_preview;

// -----

/* [Vessel Selection] */

// Which jar this lid is for; a parameter set names it, so it must be a name and not a row
reactor_vessel_name = "jar_10L_220x305"; // [jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]
// resolved from the name, not chosen
/* [Hidden] */
reactor_vessel = vessel_by_name(reactor_vessel_name);
assert(
  !is_undef(reactor_vessel),
  str("No registered vessel is named \"", reactor_vessel_name, "\". See scad/purchased/vessels.scad.")
);

/* [Lid Parameters] */

// the height of the lids plug (inner diameter part)
lid_plug_height = 10;
// allowance for the lid to fit on the jar
lid_radial_allowance = 0.4;
// to the plug's edge, to a neighbouring port, and to the flange's outer edge for the joint posts
// Least wall the lid keeps around a bore, in mm
lid_holes_offset = 2.0;
// the flanges stand on the lid's outer face; the wall between their bores is lid_holes_offset
// Least air between two neighbouring port flanges, in mm
lid_flange_gap = 1.0;
// allowance for the bearing and shaft holes
bearing_hole_allowance = 0.2;

/* [Lid Seal Parameters] */

/** How the lid seals to the jar.
 * - The pressure boundary is a flat sheet gasket recessed into the lid's flange, squeezed against
 *   the top of the glass. Only jar_6p5gal presents a flat; every other jar is fire-polished and
 *   presents a crown (vessel_rim_radius()), so the gasket covers the lip and what is squeezed is
 *   the band the crown makes. Compression is set by the turn past snug (docs/build.md), not by a
 *   land bottoming out.
 * - The plug o-ring centres the plug in the neck and stands behind the gasket against splash. It
 *   is not a pressure boundary: a radial squeeze tracks the jar's bore, which is not a controlled
 *   dimension, so it is sized toward the loose end.
 * Bands are Apple Rubber's Table A, static seals: 19-33% squeeze axial, 14-23% radial at this
 * cord. https://www.applerubber.com/src/pdf/section4-seal-types-and-gland-design-tables.pdf
 */

// its thickness sets the recess depth and its hardness the gasket factor (head_gasket_factor())
// The registered sheet the rim gasket is cut from
lid_gasket_sheet = sheet_epdm_1p6_60a;
// fraction of that the recess squeezes out; 25% is mid-band for a soft sheet
lid_gasket_compression = 0.25;
// land left between the gasket and each edge of the glass's flat top, for the flange to bear on
lid_gasket_land_margin = 1.0;
// Seating force grows with width and stiffness with its square, and all of it lands on glass;
// six millimetres seals (jar_6p5gal's 12 mm wall would otherwise ask 4.4x the force)
// Widest the rim gasket is cut, in mm
lid_gasket_width_max = 6;
// below this a gasket is fiddly to cut and will not stay in its recess; reported, not enforced
lid_gasket_width_min = 3;
// derived: any registered ring whose free ID lands this jar's groove between zero and five percent
// stretch. The groove is cut from the mouth, so one ring seals one mouth.
// The ring centring the lid plug; undef derives it from the mouth
lid_plug_oring = undef;
// radial squeeze; low in the 14-25% band because a stretched ring thins by about half its stretch
lid_plug_oring_squeeze = 0.18;

/* [Bearing Parameters] */

// The registered bearing the pocket is cut from, plus bearing_hole_allowance
shaft_bearing = BB608; // McMaster 6153K71, 440C stainless, sealed, trade no. 608-2RS

// Closes the path up the shaft bore and out round the rim. On the OUTER race, which does not
// turn - a 608's race faces are flush, so a face gasket would be clamped against steel turning at
// shaft speed. Its ID is the bearing, 22 on 22, so it seats at 0% stretch, and head() checks that.
// The seal on the bearing's outer diameter
bearing_oring = oring_22x1p5_epdm;

// A radial gland cut outward from the pocket wall, Table A's radial column.
function head_bearing_gland_diameter() =
  oring_rod_gland_diameter(bb_diameter(shaft_bearing), oring_cross_section(bearing_oring));
function head_bearing_gland_length() = oring_gland_width(oring_cross_section(bearing_oring));
// centred in the pocket's depth, so there is wall either side
function head_bearing_gland_z() = bb_width(shaft_bearing) / 2;

/* [Motor & Gearbox Selection] */

// the registered motor; the gearbox comes off its row
head_motor = motor_36pg_555pm_14_en;
// undef means this file's own row; an explicit undef does not trigger a default argument
function head_motor_selected(motor) = is_undef(motor) ? head_motor : motor;

/* [Shaft Parameters] */

// Gap between the punt and the bottom of the shaft: a collision clearance, not the mixing one
shaft_jar_punt_clearance = 5;
// Length sets how far the shaft protrudes above the lid, and so the mount's height.
// The impeller shaft; undef takes the shortest registered row that leaves the coupling a grip
head_shaft = undef;
// adjust distance between the motor and the shaft coupling
shaft_shaft_coupling_offset = 0; // can be positive or negative
// the registered coupling joining the gearbox output shaft to the impeller shaft
shaft_coupler = shaft_coupler_8x8_rigid;

/* [Motor Mount Parameters] */

// Outer diameter of the mount body: the gearbox it collars plus a wall each side. It could go to
// 42 before the base inserts meet the bearing pocket, and that does not rescue the narrow jars
// (TODO.md).
function head_motor_mount_body_diameter(gearbox) =
  gearbox_diameter(gearbox) + 2 * motor_mount_wall_thickness;
// wall thickness of the mount body; also sets the flange and raised face heights
motor_mount_wall_thickness = 10;
// clearance between the telescoping parts, for printed fit
motor_mount_coupling_allowance = 0.2;
// number of facets for the mount body (must be divisible by 4)
motor_mount_facets = 20;
// heat-set, because the mount comes off at every service and a printed thread would not survive
// it; the hole and the screw length both come off this row
// The heat-set insert the mount screws into
motor_mount_base_insert = insert_m4x4p7_ss;
// the screw into that insert; its size must match what the insert takes
motor_mount_base_screw = M4_cap_screw;
// the insert holes and the bearing pocket; what keeps them from being a leak path into the culture
// Least lid left under a blind pocket, in mm
lid_blind_pocket_floor_min = 3.0;

/* [Impeller Parameters] */

// The relations and their citations are in utils/stirred_tank.scad; the impeller types and their
// process numbers in custom/impellers.scad; the design reasoning in docs/agitation.md.

// The bore, not the outer diameter, is what D/T means in the literature. 0.45 is mid-band on every
// citation and lets every registered vessel pass its mouth.
// Impeller diameter as a fraction of the vessel's bore (D/T)
impeller_bore_ratio = 0.45;
// pbt_45_4 is chosen for what can be said about it: Medek's correlation gives Po and names the
// conditions this vessel breaks. The hand-drawn twisted paddle stays registered, with no power
// number anyone can cite.
// The registered impeller type
head_impeller_type = impeller_pbt_45_4;

// the nearest measured shape, and an over-estimate since twist lowers Po (Patwardhan, Kumaresan)
// The row whose power number stands in when the type has none
head_impeller_po_fallback = impeller_folded_axial_4;

// width of each fin blade
impeller_fin_width = 4;
// Ring tying the blade tips; off, it prints as an overhang and nothing needs it (docs/decisions.md)
impeller_tip_ring = false;
// size of the center hub; the set screw threads through it, so it sets the thread engagement
impeller_hub_radius = 10;
// the set screw holding each impeller to the shaft
impeller_set_screw = set_screw_m4x6_316;
// where they land around the collar
impeller_set_screw_at = [0, 120];
// the screws thread into the collar rather than the hub, which keeps them clear of a fin at any
// count, twist or phase
// Height of the set-screw collar above the blades, in mm
impeller_collar_height = 8;
// added to the tap hole for print calibration; printed holes come out undersize
impeller_set_screw_allow = 0;
// allowance for the shaft hole
impeller_shaft_allow = 0.4;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;
// centre to centre spacing of the two impellers, in impeller diameters
impeller_spacing_factor = 1.0;

// A design declaration: the pair are mirror images and always oppose, and at +1 the lower pumps
// up, the upper down, and the flows converge on the gap - the one arrangement where a single
// sparge ring sits in both discharges (Birch & Ahmed).
// Which way the shaft turns, right-handed about +Z: +1 counter-clockwise seen from above
head_shaft_rotation = 1;
// Fořt found hydraulic efficiency higher at C/D 1.0 than 0.5; 0.9 keeps margin inside the
// correlation's own limit and coverage over the upper impeller.
// Lower impeller centreline off the floor, in impeller diameters
impeller_clearance_factor = 0.9;

// Derived from the registered row; the section re-opens below so the customizer UI is unaffected
/* [Hidden] */
impeller_n_fins = impeller_blades(head_impeller_type);
impeller_twist_ang = impeller_twist(head_impeller_type);

/* [Impeller Parameters] */
// A fraction of capacity, so it scales across the registry (docs/decisions.md). 0.865 is what the
// reference build runs; the literature's 0.8 is reported against, and coverage over the upper
// impeller is what the margin buys.
// Fraction of the jar's capacity the culture fills
culture_fill_fraction = 0.865;
// Window a shaft speed measurement is averaged over, in seconds; sets what an encoder resolves
encoder_speed_window = 0.1;

/* [Thermocouple Mount Parameters] */

// height of the thermocouple mount
thermocouple_mount_height = 20;

// NPT wedges rather than bottoming out; 0.5 is hand-tight on a printed thread, from the bench
// Fraction of the probe's threaded body engaged in its mount, 0 to 1.
thermocouple_thread_engagement = 0.5;

/* [Bayonet Lock Parameters] */

// how to draw each port on its lock: "locked" as assembled, or "entry" as it sits before the turn
port_position = "locked"; // [locked, entry]

/* [Port Assignment] */

// What sits at each bayonet lock on the lid, going around it: [function, type, bore_radius, probe].
// The FUNCTION is the port's identity and what head_port_index() looks it up by; baffles all carry
// "baffle". Types:
//   "tube"         -> generic bayonet port, bore_radius sets the through-hole
//   "probe"        -> atlas probe holder (flex collet), bore 0, fourth slot the registered probe
//   "thermocouple" -> NPT thread mount, bore_radius the through-hole, fourth slot the probe
//   "baffle"       -> blind port carrying a swirl baffle, bore 0; count must divide the port count
// Derivation and the checks against it: docs/ports-layout.md.

// A rigid tube from the lid port down into the sparge ring's socket, and the only thing holding
// the ring. Above the port tables because they are bored for it.
// The registered tube the sparger hangs from
sparge_riser_tube = steel_tube_welded_4x0p5;

// a guide, not a grip: a ground steel tube does not hold itself in a printed bore the way
// flexible tubing does
// Bore radius of the tube ports, cut for the riser, in mm
tube_port_riser_bore = steel_tube_od(sparge_riser_tube) / 2 + 0.2; // 0.2 as the bearing hole takes

// The rod seal closing that annulus; its ID is the tube's OD, which head() checks
tube_port_riser_oring = oring_4x1p5_epdm;

// The twelve-port table. Nested, so no parameter set can carry it.
head_port_set_full = [
  ["air_out",     "tube",         tube_port_riser_bore], //   0 deg
  ["baffle",      "baffle",       0           ], //  30
  ["do_probe",    "probe",        0, do_lab_g2], //  60      opposite the air inlet
  ["temperature", "thermocouple", 3, mcmaster_1245N31_thermocouple_probe], //  90  beside DO, which compensates from it
  ["baffle",      "baffle",       0           ], // 120
  ["ph_probe",    "probe",        0, ph_lab_g2], // 150      away from both dosing lines
  ["media",       "tube",         tube_port_riser_bore], // 180      also the spare
  ["baffle",      "baffle",       0           ], // 210
  ["air_in",      "tube",         tube_port_riser_bore], // 240   the sparger hangs from this one
  ["acid",        "tube",         tube_port_riser_bore], // 270
  ["baffle",      "baffle",       0           ], // 300
  ["base",        "tube",         tube_port_riser_bore], // 330
];

// No baffles and no dosing pair (pH is measured, not controlled). The two probes are the only std
// flanges, so they sit opposite; the thermocouple is 1/8 NPT so it fits a mini beside DO. See
// docs/ports-layout.md.
// The six-port table a narrow jar carries
head_port_set_reduced = [
  ["do_probe",    "probe",        0, do_lab_g2], //   0 deg  opposite the air inlet
  ["air_out",     "tube",         tube_port_riser_bore], //  60
  ["media",       "tube",         tube_port_riser_bore], // 120      also the spare
  ["air_in",      "tube",         tube_port_riser_bore], // 180   the sparger hangs from this one
  ["ph_probe",    "probe",        0, ph_lab_g2], // 240
  ["temperature", "thermocouple", 3, mcmaster_3872K129_thermocouple_probe], // 300  beside DO
];

// Which set this lid carries. undef derives it from the mouth; set a table to pin one.
head_ports = undef;

// The sets this lid knows, widest first, so the search takes the fullest that fits.
function head_port_sets() = [head_port_set_full, head_port_set_reduced];

// Whether a set's flanges clear each other on this mouth: the worst adjacent pair decides.
// `uniform` asks it of a lid that gives every port the std interface.
function head_port_set_fits(vessel_opening_diameter, ports, uniform = false) =
  let (
    _n = len(ports),
    _chord = 2 * head_port_circle_radius(vessel_opening_diameter, ports) * sin(180 / _n)
  )
    min([
      for (i = [0:_n - 1])
        _chord
        - bayonet_flange_radius(head_port_interface(ports[i], uniform))
        - bayonet_flange_radius(head_port_interface(ports[(i + 1) % _n], uniform))
    ]) >= lid_flange_gap
    && min([
      for (i = [0:_n - 1])
        _chord
        - bayonet_port_hole_radius(head_port_interface(ports[i], uniform))
        - bayonet_port_hole_radius(head_port_interface(ports[(i + 1) % _n], uniform))
    ]) >= lid_holes_offset;

// The widest set that fits at all, on the smallest interface each port can take.
function head_port_set_for(vessel_opening_diameter) =
  let (_fit = [for (p = head_port_sets()) if (head_port_set_fits(vessel_opening_diameter, p)) p])
    len(_fit) == 0 ? undef : _fit[0];

// Whether this lid can afford std on every port, so any port takes any function and there is one
// face o-ring to buy. Usually free, since std-against-std pairs already bind the twelve-port
// circle; jar_1p5L's six-port set is the one that cannot.
function head_ports_uniform(vessel_opening_diameter, ports) =
  head_port_set_fits(vessel_opening_diameter, ports, true);

// The table this lid carries, each row with its interface pinned: uniformity is a property of the
// lid, not of a port.
function head_ports_for(vessel_opening_diameter) =
  let (_set = is_undef(head_ports) ? head_port_set_for(vessel_opening_diameter) : head_ports)
    is_undef(_set)
      ? undef
      : let (_u = head_ports_uniform(vessel_opening_diameter, _set))
        [for (p = _set) [p[0], p[1], p[2], p[3], head_port_interface(p, _u)]];
function head_ports_n(vessel_opening_diameter) = len(head_ports_for(vessel_opening_diameter));

// Which bayonet a port mates to is derived from what the port has to pass.

// Material the pin half keeps around its own bore.
port_bore_wall = 2;

// Smallest first, so the search returns the least interface that will do; std alone when uniform.
function head_interfaces_by_size(uniform = false) =
  uniform ? [bayonet_std] : [bayonet_mini, bayonet_midi, bayonet_std];

// What passes through has to clear the bore; what stands on top (an NPT mount) must fit the flange.
function head_interface_fits(iface, bore, thread) =
  bayonet_interface_radius(iface) - bore >= port_bore_wall
  && (
    is_undef(thread)
    || bayonet_flange_radius(iface) >= npt_thread_major_diameter(thread) / 2 + npt_mount_wall()
  );

// probe and baffle are fixed by what they carry; everything else takes the smallest that fits
// when the lid has to economise, and std when it does not.
function head_interface_for(type, bore, thread = undef, uniform = false) =
  type == "probe" || type == "baffle"
    ? bayonet_std
    : let (_fit = [for (i = head_interfaces_by_size(uniform)) if (head_interface_fits(i, bore, thread)) i])
      len(_fit) == 0 ? undef : _fit[0];

// A resolved row carries its own interface, and that pin wins.
function head_port_interface(port, uniform = false) =
  !is_undef(head_port_pinned_interface(port))
    ? head_port_pinned_interface(port)
    : head_interface_for(
        head_port_type(port),
        head_port_bore_radius(port),
        head_port_type(port) == "thermocouple" && !is_undef(head_port_probe(port))
          ? thermocouple_probe_thread(head_port_probe(port))
          : undef,
        uniform
      );

// The biggest interface in use; the port circle and the plug groove both derive from it.
function head_widest_interface(ports) =
  let (
    _used = [for (p = ports) head_port_interface(p)],
    _holes = [for (i = _used) bayonet_port_hole_radius(i)]
  ) _used[search(max(_holes), _holes)[0]];

function head_port_function(port) = port[0]; // what it is for, and this table's identity
function head_port_type(port) = port[1]; // how it is built
function head_port_bore_radius(port) = port[2]; // through-hole, 0 where nothing passes
function head_port_probe(port) = port[3]; // registered probe, "probe" entries only
function head_port_pinned_interface(port) = port[4]; // set by head_ports_for(), undef on a raw row

// Where the port with this purpose sits; exactly one.
function head_port_index(vessel_opening_diameter, fn) =
  let (
    _ports = head_ports_for(vessel_opening_diameter),
    _at = [for (i = [0:len(_ports) - 1]) if (head_port_function(_ports[i]) == fn) i]
  )
    assert(
      len(_at) == 1,
      str("This lid has ", len(_at), " ports for \"", fn, "\"; looking one up by function needs exactly one.")
    ) _at[0];

// What the line costs at a given flow, Pa, the vessel and any outlet filter included. A function
// of flow because the filter is linear in it and dominates.
function head_gas_line_pressure(flow, vessel_pressure, riser_length) =
  vessel_pressure
  + gas_filter_pressure_drop(flow, gas_filter_drop_slope(sparge_inlet_filter))
  + gas_tube_pressure_drop(flow, steel_tube_id(sparge_riser_tube), riser_length)
  + check_valve_cracking(sparge_check_valve)
  + gas_valve_pressure_drop(flow, check_valve_cv(sparge_check_valve), vessel_pressure)
  + (
    is_undef(sparge_outlet_filter)
      ? 0
      : gas_filter_pressure_drop(flow, gas_filter_drop_slope(sparge_outlet_filter))
        + gas_tube_pressure_drop(flow, steel_tube_id(sparge_riser_tube), riser_length)
  );

// The gas comes down whichever port is the air inlet, wherever that ends up sitting.
function head_sparge_feed_port(vessel_opening_diameter) = head_port_index(vessel_opening_diameter, "air_in");

// Every printed part this lid carries: [name, quantity, the flags that render it alone]. It
// varies with the vessel, so it lives here; `just export-parts` walks it.
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
      [["sparger", 1, "-D render_sparger=true"]],
      // Ports, in the order they sit on the lid. A baffle's plate prints in pieces, so it is that
      // many parts; every other port is one.
      [
        for (i = [0:len(_ports) - 1])
          let (_n = head_port_export_name(_ports, i))
            if (head_port_type(_ports[i]) != "baffle")
              [str("port_", _n), 1, str("-D port_to_render=\"", _n, "\"")],
      ],
      // Every baffle port is the same part, so one part with a quantity, rendered off the first
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
      // A tool, not a reactor part, but the rim gasket cannot be cut without it
      [
        for (g = ["outer", "inner"])
          [str("gasket_cutter_", g), 1, str("-D render_gasket_cutter=true -D gasket_cutter_part_to_render=\"", g, "\"")],
      ]
    );

// What a per-part export addresses a port by: its function, or baffle_<index>.
function head_port_export_name(ports, i) =
  head_port_function(ports[i]) == "baffle" ? str("baffle_", i) : head_port_function(ports[i]);

// Which ports have a rigid tube standing in them, and so want a seal around it.
function head_port_carries_riser(port) = head_port_type(port) == "tube";

/* [Baffle Parameters] */

// Each plate is centred on its port and no wider than its lock's bore lets through, so these are
// partial baffles standing inboard of the wall. They still break the swirl, and flow accelerating
// behind a baffle keeps the region from going stagnant.
// https://pmc.ncbi.nlm.nih.gov/articles/PMC8459426/

// clearance between the baffle and the impellers it passes, radially at the plate's inner edge
baffle_impeller_clearance = 2;
// clearance between the bottom of the baffle and the jar's floor
baffle_floor_clearance = 10;
// clearance between the jar's neck bore and the baffle's outer corner
baffle_neck_clearance = 1.5;
// clearance between the lock's bore and the plate dropping through it on assembly
baffle_bore_clearance = 0.2;
// a pinned number is still checked against the floor
// How far the plate hangs below its port, in mm; undef hangs it to the floor limit
baffle_length = undef;
// A stiffness and dynamics choice, not strength: 10 keeps the blade-passing crossing under the
// drive's band, thicker walks it in and thinner deflects more. head() warns on both. See
// docs/agitation.md.
// Thickness of the baffle plate, in mm
baffle_thickness = 10;
// printed PETG, for the plate's stiffness. REASONED, NOT CITED - derated from ~2.0 GPa bulk
baffle_modulus = 1800; // MPa
// kg/m^3, PETG
baffle_density = 1270;
// height over which the port's round bottom face blends out into the plate
baffle_transition_height = 10;

// Splitting the plate so it can be printed. A full-depth plate is the tallest, most slender thing
// in the model, and it stands in the port's own axis, so what bounds a piece is how tall it may
// stand on its own footprint - a print quality cap, not a bed one. The joint is a local drop in
// section, and head() reports what it costs.

// What a piece stands on: its own section plus a brim as wide again each side
baffle_brim_spread = 3;
// A judgement, graded on the plate's own section, since a tip piece is more slender than the one
// carrying the port's flange.
// How tall a printed piece may stand per unit of footprint
baffle_slenderness = 4;
// And a ceiling: the shortest Z any registered printer has, less room for a brim
baffle_segment_height_ceiling = min([for (p = printers) printer_build_z(p)]) - 10;

// The port's own stack included. Graded on the widest plate the port's bore will pass, so the cap
// is a property of the port, not the vessel.
// Tallest a printed baffle piece may stand, in mm
baffle_segment_height_max =
  min(
    baffle_segment_height_ceiling,
    baffle_brim_spread * baffle_slenderness
      * max(bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance), baffle_thickness)
  );
// How many pieces each plate splits into. undef derives it from the cap above; a number pins it.
baffle_segments = undef;
// The dovetail slides along the plate's width and is blind at the far end. The neck is the only
// material crossing the joint plane, so it is the parameter and the depth follows.
// Socket wall each side of the dovetail, in mm; four perimeters at a 0.4 nozzle
baffle_joint_lip = 1.6;
// material left crossing the joint
baffle_joint_neck = 4.2;
// degrees off vertical - shallow, so engagement is not bought from the neck
baffle_joint_flare = 10;
// slide fit between tail and socket; flank clearance only, the butt faces meet
baffle_joint_allowance = 0.1;

/* [Sparger Parameters] */

// The ring goes in the gap between the impellers: Birch & Ahmed 1997 place a ring in the
// impeller's discharge, and a converging pair (head_shaft_rotation) puts both discharges there.
// 1.4 D is the ring they tested, the equal-swept-volume radius, and the largest that passes the
// mouth. Hole size and count are for spacing and against fouling, not for even flow (Rewatkar &
// Joshi 1993: negligible effect near the impeller).

// clearance the ring keeps to the baffles inboard and the mouth it passes; a static fit
sparge_ring_clearance = 1.25;
// where the ring sits in the gap: 0 at the lower impeller's collar, 1 at the upper impeller
sparge_ring_gap_fraction = 0.5;
// The feed socket is this tube standing up, so the bore is the riser's own and the outside is
// that plus this wall, which is also what the socket keeps around the riser.
// Wall around the sparger's bore, in mm
sparge_wall = 1.2;
// octagon outside: flats to drill into, and no crown to bridge
sparge_tube_facets = 8;
function sparge_bore() = steel_tube_od(sparge_riser_tube); // one passage, the riser's own
function sparge_tube() = sparge_bore() + 2 * sparge_wall;  // across FLATS
// How many concentric rings; above one they sit on equal area
sparge_ring_count = 1;
// reasoned, not cited
// Where the innermost ring sits when there is more than one, as a fraction of the outermost
sparge_inner_fraction = 0.35;
// the cleaning gap opposite the feed
sparge_split_angle = 14;
// caps each cut end of the ring, self-tapping into a pilot
sparge_plug_screw = set_screw_m4x6_316;

// Hidden to the next marker: registry row references a parameter set cannot name, derived values,
// and settled design constants.
/* [Hidden] */
// Emit the breakthrough probes check-holes tests. Off for a normal render.
sparge_hole_probes = false;
// Gas holes, drilled radially inward (Birch & Ahmed). 3 mm is mid Rewatkar's tested 2-6.
sparge_hole_diameter = 3;
sparge_hole_count = 8;
// Which ports drop a tube to the ring to hold it steady: every tube port but the feed. Each is
// capped at the ring and takes a hole higher up, cut at the bench and not modelled (TODO.md).
// Derived from the table, since a narrow jar's port set carries no dosing pair.
function head_sparge_support_ports(vessel_opening_diameter) =
  let (_p = head_ports_for(vessel_opening_diameter))
    [for (i = [0:len(_p) - 1])
      if (head_port_type(_p[i]) == "tube" && head_port_function(_p[i]) != "air_in") i];
// bore of the socket the riser drops into, off the tube itself
sparge_feed_bore = steel_tube_od(sparge_riser_tube);
// how far it lands inside the socket
sparge_riser_insertion = 8;
// Lead-in at each socket mouth: five tubes have to find five sockets blind. sparger() bounds it
// against the wall it eats; the bore below is unchanged.
sparge_socket_chamfer = 0.5;
// The clamp that lands on the riser; its band width is what sets how far the tube stands proud.
// Which clamp, docs/procurement.md.
sparge_riser_clamp = clamp_sae4_316_5p16;
// bare tube either side of the band, so the clamp lands wholly on the riser
sparge_riser_clamp_lead_in = 3.5;

// How far a tube stands above the top of its port, from the registered clamp. Flexible tubing
// wants a few diameters of engagement, and this is 3.7.
sparge_riser_proud = hose_clamp_band_width(sparge_riser_clamp) + 2 * sparge_riser_clamp_lead_in;
// The sterile inlet filter; its drop slope is extrapolated, see the registry
sparge_inlet_filter = gas_filter_cp_1594522;
// A filter on the way out. undef is what this build has: the headspace vents through a support
// tube into the room. Set it and head() prices the exhaust; leave it and head() reports the budget.
sparge_outlet_filter = undef;
// the check valve; cracking pressure and Cv both come off the row
sparge_check_valve = check_valve_cp_5011521;
// the aeration rate the holes are reported against, volumes of gas per volume of liquid per minute
sparge_design_vvm = 0.5;
// the band the gas metering has to cover, in vvm
sparge_vvm_band = [0.1, 0.5];
// what pushes the gas
head_air_pump = air_pump_resun_35w;
// what doses acid and base; what this model knows of it is the tube it pushes
head_dosing_pump = peri_pump_kamoer_nkp;
// which ports it feeds; a list, because a narrow jar's port set has no dosing pair
dosing_pump_functions = ["acid", "base"];

/* [Probe Port Parameters] */

// The collet's own choices; every probe dimension comes from the registered probe in head_ports.
// Wall of the probe collet, in mm
probe_port_collet_wall_thickness = 1.2;
// grip fit; 0.5 was tried twice and was tight, 0.6 stuck
probe_port_collet_body_allowance = 0.6;
// the same fit on the hex the probe's connector passes through, one size up from the body
probe_port_collet_connector_allowance = 0.6;
// clearance slot cut around each flex tab, which is what leaves it free to move
probe_port_collet_tab_gap = 1.0;
// how far each flex tab is squeezed inward, so the probe is held by spring rather than a press fit
probe_port_collet_tab_deflection = 0.5;
// Atlas say "approximately 60 ml/min"; the probe consumes the oxygen it reads. A property of the
// sensing principle, so here and not in the registry. See docs/references.md.
// Flow a galvanic DO probe needs past its membrane, mL/min
do_probe_flow_requirement = 60;

// The DO probe leans outward to shed bubbles off its membrane. The lean is derived: the most of
// this ceiling the jar's internals allow (scanned, since the bounds close from both sides), and
// 0 where nothing clears so the reach asserts report the real conflict. 4.5 is reasoned, not
// cited, and is the most jar_10L takes before the collet stops passing the mouth.
// Ceiling on how far the DO probe leans out, in degrees
do_probe_port_tilt_max = 4.5;
// Yokogawa want a pH bulb at least 15 degrees above horizontal, and the long pH probe goes
// through the sparge ring at any lean
// How far the pH probe leans, in degrees; vertical
ph_probe_port_tilt_degrees = 0;
// the collet's standoff below the coupling, before the probe's own diameter is added to it
probe_port_transition_length = 25;

/* [Color Parameters] */

// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

// What a build chooses, as [name, value] pairs resolved against the defaults above. A key named
// with the value undef ("derive it") is distinguishable from one not named ("head.scad's own").
function head_build(build, key, fallback) =
  let (_hit = [for (kv = build) if (kv[0] == key) kv])
    len(_hit) == 0 ? fallback : _hit[0][1];

// The lid is a flange landing on the rim, carrying the joint, and a plug entering the mouth,
// carrying the ports. The port circle is as far out as a bore can sit and still leave
// lid_holes_offset to the plug's edge.
function head_lid_thickness(lid_flange_height) = lid_flange_height + lid_plug_height;
function head_lid_plug_diameter(vessel_opening_diameter) = vessel_opening_diameter - lid_radial_allowance;
// `ports` is passed only by the set search, which cannot ask for the table it is choosing.
function head_port_circle_radius(vessel_opening_diameter, ports = undef) =
  head_lid_plug_diameter(vessel_opening_diameter) / 2
  - bayonet_port_hole_radius(
    head_widest_interface(is_undef(ports) ? head_ports_for(vessel_opening_diameter) : ports)
  )
  - lid_holes_offset;

// The mount's base screws: clearance holes through its flange, insert holes into the lid.
function head_motor_mount_screw_hole_diameter() = screw_clearance_radius(motor_mount_base_screw) * 2;
function head_motor_mount_screw_radius(body_diameter) =
  get_base_screw_separation_radius(body_diameter, head_motor_mount_screw_hole_diameter());

// Which lip this jar has. A ground lip is a flat annulus the gasket insets into with a land each
// side; a crowned lip has neither, so the gasket covers it and the crown sinks in.
function head_lip_is_flat(rim_arc_radius) = rim_arc_radius == 0;

function head_gasket_rim_width(vessel_wall_thickness) =
  vessel_wall_thickness - 2 * lid_gasket_land_margin;

// A ground lip: inset into the flat, capped. A crowned lip: covered from the bore out past the
// lip's footprint. The width cap does not apply to a crown, where only the contact band is
// squeezed - see head_lip_contact_width().
function head_gasket_width(vessel_wall_thickness, rim_arc_radius) =
  head_lip_is_flat(rim_arc_radius)
    ? min(head_gasket_rim_width(vessel_wall_thickness), lid_gasket_width_max)
    : 2 * rim_arc_radius + lid_gasket_land_margin;
function head_gasket_inner_radius(vessel_opening_diameter, rim_arc_radius) =
  head_lip_is_flat(rim_arc_radius)
    ? vessel_opening_diameter / 2 + lid_gasket_land_margin
    : vessel_opening_diameter / 2;
function head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness, rim_arc_radius) =
  head_gasket_inner_radius(vessel_opening_diameter, rim_arc_radius)
  + head_gasket_width(vessel_wall_thickness, rim_arc_radius);

// What actually gets squeezed: the gasket's width on a flat lip; on a crown, the chord the lip
// makes as it sinks by the same fraction of thickness the recess would have squeezed on a flat.
function head_lip_contact_width(vessel_wall_thickness, rim_arc_radius, sheet) =
  head_lip_is_flat(rim_arc_radius)
    ? head_gasket_width(vessel_wall_thickness, rim_arc_radius)
    // The crown is rigid, so what it sinks into the gasket is the travel itself.
    : let (_d = head_gasket_travel(sheet))
        2 * sqrt(max(2 * rim_arc_radius * _d - _d * _d, 0));

// and where that band sits: on a crown it is centred on the crown, not on the gasket.
function head_lip_contact_mean_diameter(vessel_opening_diameter, vessel_wall_thickness, rim_arc_radius) =
  head_lip_is_flat(rim_arc_radius)
    ? head_gasket_inner_radius(vessel_opening_diameter, rim_arc_radius)
      + head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness, rim_arc_radius)
    : vessel_opening_diameter + 2 * rim_arc_radius;

// What the joint has to hold, on the contact band. Exported: the gasket is the head's and the
// bolt count is the assembly's. Reported, never asserted on - utils/elastomer.scad.
function head_gasket_seating_force(vessel_opening_diameter, vessel_wall_thickness, sheet, rim_arc_radius) =
  gasket_seating_force(
    gasket_sheet_shore_a(head_gasket_sheet(sheet)),
    head_lip_contact_width(vessel_wall_thickness, rim_arc_radius, sheet),
    gasket_sheet_thickness(head_gasket_sheet(sheet)),
    head_lip_contact_mean_diameter(vessel_opening_diameter, vessel_wall_thickness, rim_arc_radius),
    lid_gasket_compression
  );
function head_gasket_depth(sheet) = gasket_sheet_thickness(head_gasket_sheet(sheet)) * (1 - lid_gasket_compression);
// The other part of the same thickness: what the joint has to move.
function head_gasket_travel(sheet) =
  gasket_sheet_thickness(head_gasket_sheet(sheet)) * lid_gasket_compression;

// Gasket factor m, ASME BPVC.VIII.1-2019 Table 2-5.1: 0 self-energizing, 0.50 below 75A Shore,
// 1.00 at or above; y is 0 psi below 75A, so this sheet has no seating minimum. The sheet is an
// argument so the bolt count follows the sheet the lid is cut for; undef means the head's own,
// resolved here because an explicit undef does not trigger a default (and `undef < 75` is false).
function head_gasket_sheet(sheet) = is_undef(sheet) ? lid_gasket_sheet : sheet;
function head_gasket_factor(sheet) = gasket_sheet_shore_a(head_gasket_sheet(sheet)) < 75 ? 0.5 : 1.0;

// z = 0 is the lid's OUTER face and the flange stands between it and the rim, so every
// vessel-referenced depth in this file goes through here.
function head_punt_top_depth(lid_flange_height, vessel_internal_height) =
  lid_flange_height + vessel_internal_height;
// Which lean a port gets; anything not one of the two named probe ports hangs straight.
function head_probe_tilt(port, do_tilt) =
  head_port_function(port) == "do_probe"
    ? do_tilt
    : head_port_function(port) == "ph_probe" ? ph_probe_port_tilt_degrees : 0;

// Where a probe's axis sits `length` down its own lean, in the meridional half-plane (radius out
// from the shaft, height in head()'s frame). The lean is radial, so this is a straight line.
function head_probe_axis_at(vessel_opening_diameter, lid_flange_height, length, tilt) =
  [
    head_port_circle_radius(vessel_opening_diameter) + length * sin(tilt),
    -head_lid_thickness(lid_flange_height) - length * cos(tilt),
  ];

// The two runs a probe hangs into the vessel: the collet with the body inside, and the bare tip.
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

// Where the sparge ring sits in the gap: between the lower impeller's collar and the upper
// impeller's blades.
function head_sparge_ring_z(impeller_diameter) =
  let (
    _clearance = stirred_tank_clearance(impeller_diameter, impeller_clearance_factor),
    _height = impeller_axial_span(head_impeller_type, impeller_diameter, impeller_fin_width),
    _bottom = _clearance + _height / 2 + impeller_collar_height,
    _top = _clearance + stirred_tank_impeller_spacing(impeller_diameter, impeller_spacing_factor) - _height / 2
  )
    _bottom + sparge_ring_gap_fraction * (_top - _bottom);

// Everything axisymmetric a hanging run has to miss, as annuli in the (radius, height) half-plane.
// See utils/meridian.scad for why that is enough.
function head_reach_obstacles(vessel_opening_diameter, lid_flange_height, vessel_internal_height, vessel_punt_height, impeller_diameter) =
  let (
    _floor_z = -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height),
    _swept = head_impeller_swept_radius(impeller_diameter),
    _clearance = stirred_tank_clearance(impeller_diameter, impeller_clearance_factor),
    _height = impeller_axial_span(head_impeller_type, impeller_diameter, impeller_fin_width),
    _spacing = stirred_tank_impeller_spacing(impeller_diameter, impeller_spacing_factor),
    _ring_r = head_sparge_ring_radius(vessel_opening_diameter),
    _ring_z = head_sparge_ring_z(impeller_diameter)
  )
    [
      [
        "lower impeller",
        [0, _swept, _floor_z + _clearance - _height / 2, _floor_z + _clearance + _height / 2],
      ],
      [
        "upper impeller",
        [0, _swept,
         _floor_z + _clearance + _spacing - _height / 2,
         _floor_z + _clearance + _spacing + _height / 2],
      ],
      [
        "sparge ring",
        [_ring_r - sparge_tube_extent() / 2, _ring_r + sparge_tube_extent() / 2,
         _floor_z + _ring_z - sparge_tube_extent() / 2,
         _floor_z + _ring_z + sparge_tube_extent() / 2],
      ],
    ];

// Does a probe at this lean clear the vessel's internals AND still pass the mouth on the way in?
function head_probe_lean_fits(probe, vessel_opening_diameter, lid_flange_height, vessel_internal_height, vessel_punt_height, impeller_diameter, tilt) =
  let (
    _runs = head_probe_runs(probe, vessel_opening_diameter, lid_flange_height, tilt),
    _obstacles = head_reach_obstacles(
      vessel_opening_diameter, lid_flange_height, vessel_internal_height, vessel_punt_height, impeller_diameter
    ),
    _gaps = [
      for (r = _runs)
        for (o = _obstacles)
          let (_g = meridian_clearance(r, o[1])) if (!is_undef(_g)) _g
    ]
  )
    meridian_max_radius(_runs[0]) <= vessel_opening_diameter / 2
    && (len(_gaps) == 0 || min(_gaps) > 0);

// The most of `want` this jar allows, scanned down from the ceiling; 0 where nothing fits.
function head_probe_tilt_ceiling(probe, vessel_opening_diameter, lid_flange_height, vessel_internal_height, vessel_punt_height, impeller_diameter, want, steps = 45) =
  let (
    _ok = [
      for (i = [0:steps])
        let (_t = want * (steps - i) / steps)
          if (head_probe_lean_fits(
                probe, vessel_opening_diameter, lid_flange_height, vessel_internal_height,
                vessel_punt_height, impeller_diameter, _t
              )) _t
    ]
  )
    len(_ok) == 0 ? 0 : _ok[0];

// How far below the lid's outer face the thermocouple tip lands. tip_height is the sheath from
// the end of the threads, so the flange and the mount stand between it and the lid, less the
// engaged thread.
function head_thermocouple_depth(probe, iface, engagement = thermocouple_thread_engagement) =
  thermocouple_probe_tip_height(probe)
  - bayonet_flange_height(iface)
  - thermocouple_mount_height
  + thermocouple_probe_body_height(probe) * engagement;

// One straight run, all sensing tip. Takes the interface the lid pinned, which a uniform lid may
// have set wider than smallest-that-fits.
function head_thermocouple_run(probe, iface, vessel_opening_diameter, lid_flange_height) =
  [
    [head_port_circle_radius(vessel_opening_diameter), -head_lid_thickness(lid_flange_height)],
    [head_port_circle_radius(vessel_opening_diameter), -head_thermocouple_depth(probe, iface)],
    thermocouple_probe_tip_dia(probe) / 2,
  ];

// How far below the lid's outer face a probe's deepest point lands. The collet seats the probe at
// one depth; transition, body and tip lean over by the tilt, and the tip's low corner hangs
// r*sin(tilt) below its centreline.
function head_probe_reach(probe, lid_flange_height, tilt) =
  head_lid_thickness(lid_flange_height)
  + (
    bayonet_probe_port_collet_drop(probe, probe_port_transition_length)
    + atlas_probe_body_height(probe)
    + atlas_probe_tip_height(probe)
  ) * cos(tilt)
  + atlas_probe_tip_dia(probe) / 2 * sin(tilt);

// The fill height that holds `litres`, by bisection on the jar's own profile; 40 halvings take
// the tallest registered vessel below a nanometre.
function head_fill_height_for(vessel_profile, litres, lo, hi, steps = 40) =
  steps <= 0
    ? (lo + hi) / 2
    : let (_mid = (lo + hi) / 2)
      vessel_profile_litres(vessel_profile, vessel_profile[0][1] + _mid) < litres
        ? head_fill_height_for(vessel_profile, litres, _mid, hi, steps - 1)
        : head_fill_height_for(vessel_profile, litres, lo, _mid, steps - 1);

// What the jar holds to the rim, from the profile's floor at the axis.
function head_vessel_capacity(vessel_profile, vessel_internal_height) =
  vessel_profile_litres(vessel_profile, vessel_profile[0][1] + vessel_internal_height);

// The fill line; the fraction is a fraction of VOLUME, which is what a bioprocess specifies.
function head_liquid_height(vessel_internal_height, vessel_profile, fill_fraction) =
  head_fill_height_for(
    vessel_profile,
    head_vessel_capacity(vessel_profile, vessel_internal_height) * fill_fraction,
    0, vessel_internal_height
  );

function head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height) =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) + vessel_punt_height;

// The floor is what stops the plate; it clears the impellers radially by construction. The plate
// hangs from the port's underside, not the lid's outer face.
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

// What the impeller actually sweeps, against the diameter the correlations are keyed on; anything
// added outboard of the blades shows up here and takes its clearance with it.
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
// The ring is placed by the mouth: it has to pass through it, and both sources want it as large
// as possible (Birch & Ahmed 1.4 D, Rewatkar & Joshi 2 D), so the outermost position the mouth
// allows is the best available. The room outside a full-width baffle is a constant that does not
// grow with the mouth and is too small for the ring, so the baffle yields: head_baffle_width()
// takes a third bound.

// What the tube occupies, across corners, where the material is.
function sparge_tube_extent() = sparger_across_corners(sparge_tube(), sparge_tube_facets);

// Socket depth, passed to sparger() so the datum arithmetic reads the number the part is built with
function sparge_feed_height() = 8;

function head_sparge_ring_radius(mouth) =
  mouth / 2 - sparge_ring_clearance - sparge_tube_extent() / 2;

// Every ring's radius: one as far out as the mouth allows, several on equal area inboard of it.
function head_sparge_radii(mouth) =
  let (_o = head_sparge_ring_radius(mouth))
    sparge_ring_count == 1
      ? [_o]
      : sparger_equal_area_radii(sparge_ring_count, _o, sparge_inner_fraction * _o);

// and the holes each of them carries, split by the area it serves.
function head_sparge_holes(mouth) =
  let (_o = head_sparge_ring_radius(mouth))
    sparge_ring_count == 1
      ? [sparge_hole_count]
      : sparger_holes_per_ring(
          sparge_hole_count,
          sparger_area_shares(head_sparge_radii(mouth), _o, sparge_inner_fraction * _o)
        );

// The widest plate that still leaves the ring its section and a clearance either side.
function head_baffle_ring_limit(mouth) =
  2 * (mouth / 2 - head_port_circle_radius(mouth) - 2 * sparge_ring_clearance - sparge_tube_extent());

// ----- where the mouth and the bore have to agree -----
//
// Nothing couples a jar's mouth to its bore: the mouth sets the port circle and where the baffles
// hang, the bore sets the impeller and the ring. The four couplings below are functions of (mouth,
// impeller diameter) so the asserts in head() and the feasibility report are the same expression.
// Each returns a clearance; positive is feasible.

function head_ring_baffle_gap(mouth, impeller_diameter) =
  (head_sparge_ring_radius(mouth) - sparge_tube_extent() / 2)
  - (head_port_circle_radius(mouth) + head_baffle_width(mouth, impeller_diameter) / 2);

function head_ring_mouth_gap(mouth, impeller_diameter) =
  mouth / 2 - (head_sparge_ring_radius(mouth) + sparge_tube_extent() / 2);

// The impeller itself has to go in through the mouth.
function head_mouth_passes_impeller(mouth, impeller_diameter) =
  mouth - 2 * head_impeller_swept_radius(impeller_diameter) > 0;

// Two of the four only bind if the lid carries baffles. A mouth too narrow for any port set is
// not feasible whatever the impeller does, and short-circuits the rest.
function head_mouth_is_feasible(mouth, impeller_diameter, has_baffles = true) =
  !is_undef(head_ports_for(mouth))
  && (!has_baffles
    || (head_baffle_width(mouth, impeller_diameter) > 0
      && head_ring_baffle_gap(mouth, impeller_diameter) > 0))
  && head_ring_mouth_gap(mouth, impeller_diameter) > 0
  && head_mouth_passes_impeller(mouth, impeller_diameter);

// Solved by sweeping the predicate, so there is one expression of the four couplings.
function head_feasible_mouth_sweep() = [40, 400, 0.25]; // [lo, hi, step] - the range searched
function head_feasible_mouth_count() =
  let (_s = head_feasible_mouth_sweep()) floor((_s[1] - _s[0]) / _s[2]) + 1;
function head_feasible_mouth_at(i) =
  let (_s = head_feasible_mouth_sweep()) _s[0] + i * _s[2];
function head_feasible_mouths(impeller_diameter, has_baffles = true) =
  let (_s = head_feasible_mouth_sweep())
    [for (m = [_s[0]:_s[2]:_s[1]]) if (head_mouth_is_feasible(m, impeller_diameter, has_baffles)) m];

// Feasibility flips exactly once as the mouth widens (measured over D = 60..180 mm), so the edge
// is bisected on the sweep's own grid rather than walked. Lowest feasible index in (lo, hi].
function head_feasible_edge(impeller_diameter, has_baffles, lo, hi) =
  hi - lo <= 1 ? hi
  : let (_mid = floor((lo + hi) / 2))
      head_mouth_is_feasible(head_feasible_mouth_at(_mid), impeller_diameter, has_baffles)
        ? head_feasible_edge(impeller_diameter, has_baffles, lo, _mid)
        : head_feasible_edge(impeller_diameter, has_baffles, _mid, hi);

// [first, last] feasible mouth, or undef if none. An infeasible ceiling means an upper coupling has
// bound, which the single-flip measurement never covered, so that case walks the full sweep.
function head_feasible_mouth_window(impeller_diameter, has_baffles = true) =
  let (
    _top = head_feasible_mouth_count() - 1,
    _lo_ok = head_mouth_is_feasible(head_feasible_mouth_at(0), impeller_diameter, has_baffles),
    _hi_ok = head_mouth_is_feasible(head_feasible_mouth_at(_top), impeller_diameter, has_baffles)
  )
  _hi_ok
    ? [head_feasible_mouth_at(_lo_ok ? 0
         : head_feasible_edge(impeller_diameter, has_baffles, 0, _top)),
       head_feasible_mouth_at(_top)]
    : let (_all = head_feasible_mouths(impeller_diameter, has_baffles))
        len(_all) == 0 ? undef : [_all[0], _all[len(_all) - 1]];

// ----- the drive stack, from the lid's outer face up -----

// What the shaft has to clear the lid by: the impeller side's half of the coupling.
function head_shaft_min_protrusion() = sc_length(shaft_coupler) / 2;

// How long a shaft this vessel needs: down to the punt, back up through the lid, plus that grip.
function head_shaft_length_needed(lid_flange_height, vessel_internal_height) =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) - shaft_jar_punt_clearance
  + head_shaft_min_protrusion();

// The shortest registered row that reaches; every millimetre over grows the motor mount.
function head_shaft_for(lid_flange_height, vessel_internal_height) =
  let (
    _need = head_shaft_length_needed(lid_flange_height, vessel_internal_height),
    _fits = [for (t = shafts) if (shaft_length(t) >= _need) shaft_length(t)]
  )
    len(_fits) == 0 ? undef : [for (t = shafts) if (shaft_length(t) == min(_fits)) t][0];

function head_shaft_selected(lid_flange_height, vessel_internal_height, shaft) =
  is_undef(shaft) ? head_shaft_for(lid_flange_height, vessel_internal_height) : shaft;

function head_shaft_protrusion(lid_flange_height, vessel_internal_height, shaft) =
  shaft_length(head_shaft_selected(lid_flange_height, vessel_internal_height, shaft))
  - (head_punt_top_depth(lid_flange_height, vessel_internal_height) - shaft_jar_punt_clearance);
function head_motor_mount_height(lid_flange_height, vessel_internal_height, shaft, motor) =
  gearbox_output_shaft_length(dc_motor_gearbox(head_motor_selected(motor)))
  + head_shaft_protrusion(lid_flange_height, vessel_internal_height, shaft) + shaft_shaft_coupling_offset;
// top of the motor, which is the highest thing on the reactor
function head_stack_height(lid_flange_height, vessel_internal_height, shaft, motor) =
  head_motor_mount_height(lid_flange_height, vessel_internal_height, shaft, motor)
  + dc_motor_length(head_motor_selected(motor)) + gearbox_length(dc_motor_gearbox(head_motor_selected(motor)));
// The groove a given ring would get in a given mouth, and how far that stretches it.
function head_plug_groove_diameter(vessel_opening_diameter, ring) =
  vessel_opening_diameter - 2 * oring_gland_depth(oring_cross_section(ring), lid_plug_oring_squeeze);

function head_plug_oring_stretch(vessel_opening_diameter, ring) =
  oring_stretch(oring_inner_diameter(ring), head_plug_groove_diameter(vessel_opening_diameter, ring));

// The groove and the port bores are cut into the same wall of the plug; the mouth and the offset
// cancel, so the cord budget is a property of the bayonet and the lid, not of any jar.
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

function head_plug_oring_selected(vessel_opening_diameter, plug_oring) =
  is_undef(plug_oring) ? head_plug_oring_for(vessel_opening_diameter) : plug_oring;

function head_plug_groove_width(vessel_opening_diameter, plug_oring) =
  oring_gland_width(oring_cross_section(head_plug_oring_selected(vessel_opening_diameter, plug_oring)));

// A piston gland: cut relative to the bore it seals against, not to the plug it is cut into, so
// the ring's squeeze is what the glass leaves it.
function head_plug_oring_groove_radius(vessel_opening_diameter, plug_oring) =
  head_plug_groove_diameter(
    vessel_opening_diameter, head_plug_oring_selected(vessel_opening_diameter, plug_oring)
  ) / 2;

// Place children at port i, on the ring and turned to face out. `flipped` is for callers drawing
// inside lid_pocketed, which head() turns over with rotate([0, 180, 0]), sending t to 180 - t.
module head_port_at(i, vessel_opening_diameter, flipped = false) {
  _angle = i * 360 / head_ports_n(vessel_opening_diameter);
  rotate([0, 0, flipped ? 180 - _angle : _angle])
    translate([head_port_circle_radius(vessel_opening_diameter), 0, 0])
      children();
}

module lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, joint_outer_diameter, post_pts, post_hole_diameter, shaft_diameter, plug_oring, sheet, lip_arc_radius, mount_body_diameter) {

  _ports = head_ports_for(vessel_opening_diameter);
  _n = len(_ports);

  _thickness = head_lid_thickness(lid_flange_height);

  // z = 0 is the lid's outer face here and the part is flipped by the caller, so the flange's
  // glass-facing side is its far face, at z = lid_flange_height, where the plug starts.
  _gasket_depth = head_gasket_depth(sheet);
  _plug_groove_w = head_plug_groove_width(vessel_opening_diameter, plug_oring);
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

          // seal groove round the bearing's rim, mid-depth so there is wall both sides while the
          // bearing is pushed past the ring
          translate([0, 0, z_fight / 2 + head_bearing_gland_z() - head_bearing_gland_length() / 2])
            cylinder(d=head_bearing_gland_diameter(), h=head_bearing_gland_length());
        }

      // insert holes for the motor mount, blind; the assert in head() keeps them out of the culture
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([head_motor_mount_screw_radius(mount_body_diameter), 0, -z_fight / 2])
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
          cylinder(r=head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness, lip_arc_radius), h=_gasket_depth + z_fight);
          translate([0, 0, -z_fight])
            cylinder(r=head_gasket_inner_radius(vessel_opening_diameter, lip_arc_radius), h=_gasket_depth + z_fight * 3);
        }

      // o-ring groove round the plug
      translate([0, 0, _plug_groove_z - _plug_groove_w / 2])
        difference() {
          cylinder(r=head_lid_plug_diameter(vessel_opening_diameter) / 2 + 1, h=_plug_groove_w);
          translate([0, 0, -z_fight])
            cylinder(r=head_plug_oring_groove_radius(vessel_opening_diameter, plug_oring), h=_plug_groove_w + z_fight * 2);
        }
    }
}

// Does this port type care which way round it ends up? A plate and a leaning collet do.
function head_port_is_oriented(type) = type == "baffle" || type == "probe";

// One port pin half, dispatched on its registered type.
module head_port(port, panel_thickness, baffle_width, baffle_length, baffle_segments, do_tilt) {
  _type = head_port_type(port);
  _bore = head_port_bore_radius(port);
  _probe = head_port_probe(port);
  _iface = head_port_interface(port);

  if (_type == "tube") {
    // Labelled by function as well as bore: air_in and air_out share a bore, as do acid and base.
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
      tilt_degrees=head_probe_tilt(port, do_tilt),
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

module head(vessel, lid_flange_height, joint_outer_diameter, post_pts, post_hole_diameter, build = []) {

  // ===== derived =====

  // The vessel's fields, read once. A row, because the head reads seven of them.
  vessel_outer_diameter = vessel_diameter(vessel);
  vessel_opening_diameter = vessel_opening_diameter(vessel);
  vessel_wall_thickness = vessel_thickness(vessel);
  vessel_internal_height = vessel_internal_height(vessel);
  vessel_punt_height = vessel_punt_height(vessel);
  vessel_profile = vessel_inner_profile(vessel);
  lip_arc_radius = vessel_rim_arc_radius(vessel);

  // This file's tessellation, whatever the caller set - see utils/facets.scad.
  $fn = 0;
  $fa = facet_angle();
  $fs = facet_size();

  // Resolved before anything reads them. An empty build is head.scad's own parameters.
  _build_fill_fraction = head_build(build, "culture_fill_fraction", culture_fill_fraction);
  _build_shaft = head_build(build, "head_shaft", head_shaft);
  _build_plug_oring = head_build(build, "lid_plug_oring", lid_plug_oring);
  _build_do_tilt_max = head_build(build, "do_probe_port_tilt_max", do_probe_port_tilt_max);
  _gasket_sheet = head_gasket_sheet(head_build(build, "lid_gasket_sheet", lid_gasket_sheet));
  _motor = head_motor_selected(head_build(build, "head_motor", head_motor));
  _build_do_probe = head_build(build, "do_probe", undef);
  _build_ph_probe = head_build(build, "ph_probe", undef);

  // The table this lid carries, resolved once, with a designated probe spliced in. Safe because
  // every "probe" port gets bayonet_std whatever it carries; it would not be safe for a
  // thermocouple, whose interface follows its thread (docs/decisions.md).
  _designated = [
    for (p = head_ports_for(vessel_opening_diameter))
      let (
        _swap = head_port_function(p) == "do_probe" ? _build_do_probe
              : head_port_function(p) == "ph_probe" ? _build_ph_probe
              : undef
      )
        is_undef(_swap) ? p : [p[0], p[1], p[2], _swap]
  ];
  _ports = _designated;
  _n = len(_ports);
  head_gearbox = dc_motor_gearbox(_motor);
  _mount_body_d = head_motor_mount_body_diameter(head_gearbox);

  // ----- impeller -----
  // The bore is what the impeller mixes and what D/T is measured against.
  _vessel_bore = vessel_outer_diameter - 2 * vessel_wall_thickness;

  // Resolved once. head_shaft may pin a row; otherwise the shortest that reaches this vessel.
  _shaft = head_shaft_selected(lid_flange_height, vessel_internal_height, _build_shaft);
  _liquid_height = head_liquid_height(vessel_internal_height, vessel_profile, _build_fill_fraction);
  _baffle_at = [for (i = [0:_n - 1]) if (head_port_type(_ports[i]) == "baffle") i];

  // A lid need not carry baffles; everything that measures a plate asks first.
  _has_baffles = len(_baffle_at) > 0;
  impeller_diameter = stirred_tank_impeller_diameter(_vessel_bore, impeller_bore_ratio);

  // The DO lean, always derived: the most of the ceiling this jar allows.
  _do_port = [for (p = _ports) if (head_port_function(p) == "do_probe") p];

  _do_tilt =
    len(_do_port) == 0 ? 0
    : head_probe_tilt_ceiling(
      head_port_probe(_do_port[0]), vessel_opening_diameter, lid_flange_height,
      vessel_internal_height, vessel_punt_height, impeller_diameter, _build_do_tilt_max
    );

  // The mouth window this jar had to land in: too small and the ring will not pass, too large and
  // the port circle carries the baffles out until the ring fouls them.
  _feasible = head_feasible_mouth_window(impeller_diameter, _has_baffles);

  impeller_radius = impeller_diameter / 2; // radius of the impeller

  // A type that registers no width ratio has no axial span to derive.
  assert(
    !is_undef(impeller_width_ratio(head_impeller_type)),
    str(
      "head: impeller type \"", impeller_name(head_impeller_type),
      "\" registers no width ratio, so the blade has no axial span to derive. Register one on the ",
      "row, or choose a type that carries it."
    )
  );

  // What the blade occupies along the shaft, thickness included - every vertical budget reads it.
  impeller_height = impeller_axial_span(head_impeller_type, impeller_diameter, impeller_fin_width);
  impeller_blade_width = impeller_width_ratio(head_impeller_type) * impeller_diameter;

  // radius of the shaft hole in the impeller
  impeller_shaft_hole_radius = (shaft_diameter(_shaft) + impeller_shaft_allow) / 2;
  impeller_spacing = stirred_tank_impeller_spacing(impeller_diameter, impeller_spacing_factor);

  // Where this build sits against the literature. Reported, not asserted.
  _impeller_ratio = stirred_tank_ratio(impeller_diameter, _vessel_bore);
  _ratio_band = stirred_tank_ratio_band();
  _ratio_band_axial = stirred_tank_ratio_band_axial();
  _spacing_band = stirred_tank_spacing_band();

  // Off-bottom clearance as the literature measures it: impeller centreline to the vessel floor,
  // not the shaft's collision gap over the punt. Chosen; the shaft's own bound is asserted below.
  _impeller_clearance = stirred_tank_clearance(impeller_diameter, impeller_clearance_factor);
  _clearance_ratio = stirred_tank_clearance_ratio(_impeller_clearance, impeller_diameter);
  _clearance_band = stirred_tank_clearance_band_fluidfoil();

  // The diameter the part sweeps against the one the correlations use; equal by construction.
  _swept = head_impeller_swept_radius(impeller_diameter) * 2;

  // Coverage over the upper impeller, and the room under the lower one where a sparger goes.
  _upper_impeller_top = _impeller_clearance + impeller_spacing + impeller_height / 2;

  _impeller_coverage =
  stirred_tank_coverage(vessel_punt_height + _liquid_height, _upper_impeller_top);
  _coverage_ratio = stirred_tank_coverage_ratio(_impeller_coverage, impeller_diameter);
  _sparger_room = _impeller_clearance - impeller_height / 2;

  // Whether this column wants two impellers at all: the spacing band bounds the count, in liquid
  // height over IMPELLER diameter. Reported, since the bounds come from a convention.
  _liquid_to_bore = _liquid_height / _vessel_bore;
  _count_bounds = stirred_tank_impeller_count_bounds(_liquid_height, impeller_diameter);

  // Set screws hold the impeller to the shaft; the bore is a slip fit. Engagement is what the hub
  // wall leaves between socket and shaft, reach is whether the tip gets there at all.
  _set_screw_engagement = impeller_hub_radius - impeller_shaft_hole_radius;

  _set_screw_reach =
  impeller_hub_radius - shaft_diameter(_shaft) / 2 - set_screw_length(impeller_set_screw);
  _set_screw_hole = (set_screw_tap_radius(impeller_set_screw) + impeller_set_screw_allow) * 2;

  // ----- culture -----
  // Integrated over the jar's own wetted profile, from the punt top.
  _floor_y = vessel_wall_thickness + vessel_punt_height;
  _culture_volume = vessel_profile_litres(vessel_profile, _floor_y + _liquid_height);
  _vessel_capacity = head_vessel_capacity(vessel_profile, vessel_internal_height);

  // ----- power number -----
  // Po and x come off the registered type: measured (the row carries it), correlated (the row
  // carries a blade angle and Medek's correlation reports its envelope) or borrowed (a fallback
  // row's number). Which kind is echoed, since Po is the largest uncertainty in everything below.
  _tank_ratio = _vessel_bore / impeller_diameter;
  _height_ratio = _liquid_height / _vessel_bore;
  _po_measured = impeller_has_power_number(head_impeller_type);
  _po_correlated = !_po_measured && !is_undef(impeller_blade_angle(head_impeller_type));
  _po_borrowed = !_po_measured && !_po_correlated;

  _medek_departures = stirred_tank_medek_departures(
    impeller_blades(head_impeller_type), _clearance_ratio, _tank_ratio,
    _height_ratio, impeller_blade_angle(head_impeller_type),
    len(_baffle_at), stirred_tank_reynolds(impeller_diameter, dc_motor_rated_output_rpm(_motor))
  );

  _impeller_po =
  _po_measured ? impeller_power_number(head_impeller_type)
  : _po_correlated ? stirred_tank_medek_power_number(
      impeller_blades(head_impeller_type), _clearance_ratio, _tank_ratio,
      _height_ratio, impeller_blade_angle(head_impeller_type))
  : impeller_power_number(head_impeller_po_fallback);
  _impeller_x = impeller_dissipation_factor(head_impeller_type);

  // Guarded: a twisted blade has no angle for the correlation.
  _impeller_flow_number = !_po_correlated
    ? undef
    : stirred_tank_medek_flow_number(
      impeller_blades(head_impeller_type), _clearance_ratio, _tank_ratio,
      _height_ratio, impeller_blade_angle(head_impeller_type)
    );

  _rated_torque = dc_motor_rated_output_torque(_motor); // undef on a motor that publishes none

  // no-load and rated are different facts and either may be unpublished
  _drive_speeds = [
    for (s = [
      ["no-load", dc_motor_no_load_output_rpm(_motor)],
      ["rated", dc_motor_rated_output_rpm(_motor)],
    ]) if (!is_undef(s[1])) s
  ];

  // ----- probes -----
  // The thermocouple has to end up in the culture and short of the floor. Asserted: a probe
  // through the floor is not a departure, it is a part that does not fit.
  _tc_port = [for (q = _ports) if (head_port_type(q) == "thermocouple") q];

  // ----- transfer and drive -----
  // Both correlations are used outside the range they were fitted in.
  _kla_band = stirred_tank_kla_power_band();
  _blend_band = stirred_tank_blend_time_volume_band();

  _pv_rated = len(_drive_speeds) == 0 ? undef
    : stirred_tank_mean_dissipation(
      stirred_tank_power(impeller_diameter, _drive_speeds[len(_drive_speeds) - 1][1], _impeller_po),
      _culture_volume
    );

  // Whether the speed above can be measured or only commanded.
  _encoder = dc_motor_encoder(_motor);
  _encoder_counts = dc_motor_encoder_counts_per_output_rev(_motor);

  // ----- drive stack -----
  shaft_protrusion = head_shaft_protrusion(lid_flange_height, vessel_internal_height, _build_shaft);

  // The shaft runs in the bearing's inner race: two registered tolerances meeting. Reported, since
  // a transition fit is what a rotating inner ring wants.
  _fit_loosest = bb_bore(shaft_bearing) - shaft_diameter_min(_shaft);
  _fit_tightest = (bb_bore(shaft_bearing) - 0.007) - shaft_diameter_max(_shaft);

  // the height that the motor coupling assembly requires
  motor_mount_height = head_motor_mount_height(lid_flange_height, vessel_internal_height, _build_shaft, _motor);

  // Mount slenderness, height over diameter: reasoned, not cited, calibrated on the build in hand
  // at 2.3. The coupling is rigid, so the mount's deflection is reacted by the bearings.
  _mount_slenderness = motor_mount_height / _mount_body_d;

  // The hole is blind because the other side of the plug is the culture.
  _insert_floor = head_lid_thickness(lid_flange_height) - insert_hole_length(motor_mount_base_insert);

  // The bearing pocket is the other blind hole in this face, and the deeper of the two.
  _bearing_floor = head_lid_thickness(lid_flange_height) - bb_width(shaft_bearing);

  // The bearing's seal, whose ID is the bearing, seats at 0% stretch; checked, not assumed.
  _bearing_seal_stretch =
  oring_stretch(oring_inner_diameter(bearing_oring), bb_diameter(shaft_bearing));

  // The screw circle and the pocket are chosen independently. Measured to the seal groove, which
  // is wider than the pocket.
  _insert_to_bearing =
  head_motor_mount_screw_radius(_mount_body_d) - insert_outer_d(motor_mount_base_insert) / 2 - head_bearing_gland_diameter() / 2;

  // ----- baffles -----
  lid_thickness = head_lid_thickness(lid_flange_height);
  port_circle_radius = head_port_circle_radius(vessel_opening_diameter);
  baffle_max_length = head_baffle_max_length(lid_flange_height, vessel_internal_height, vessel_punt_height);
  _baffle_length = head_baffle_length(lid_flange_height, vessel_internal_height, vessel_punt_height);
  _baffle_segments = head_baffle_segments(lid_flange_height, vessel_internal_height, vessel_punt_height);
  _baffle_joint_at = [for (j = [1:1:_baffle_segments - 1]) j * _baffle_length / _baffle_segments];
  _baffle_width = head_baffle_width(vessel_opening_diameter, impeller_diameter);

  // Oldshue sizes baffling by total projected area; the width is bound, so the levers are the
  // count and how much plate is under the liquid.
  _baffle_freeboard =
  head_punt_top_depth(lid_flange_height, vessel_internal_height) - _liquid_height - lid_thickness;
  _baffle_wetted = stirred_tank_baffle_wetted_length(_baffle_length, _baffle_freeboard, _liquid_height);

  _baffle_area_ratio =
  stirred_tank_baffle_area_ratio(_vessel_bore, _liquid_height, len(_baffle_at), _baffle_width, _baffle_wetted);

  // Both levers, with the numbers; an equally spaced count has to divide the port count.
  _next_baffle_count = [for (n = [len(_baffle_at) + 1:_n]) if (_n % n == 0) n];

  _baffle_ratio_at_depth = stirred_tank_baffle_area_ratio(
    _vessel_bore, _liquid_height, len(_baffle_at), _baffle_width,
    stirred_tank_baffle_wetted_length(baffle_max_length, _baffle_freeboard, _liquid_height));

  // What the plate does under load: whether it still blocks the swirl, and whether it sits on
  // something the drive excites. Worst case is the no-load speed.
  _baffle_rpm = max([for (s = _drive_speeds) s[1]]);

  _baffle_torque = 2 * stirred_tank_torque(
    stirred_tank_power(impeller_diameter, _baffle_rpm, _impeller_po), _baffle_rpm);

  _baffle_load = stirred_tank_baffle_load(_baffle_torque, len(_baffle_at), port_circle_radius);

  _baffle_solid_deflection = stirred_tank_baffle_deflection(
    _baffle_load, _baffle_length, _baffle_freeboard, _baffle_width, baffle_thickness, baffle_modulus);

  // A split plate is what gets printed, so the joints are in the headline number.
  _baffle_joint_depth = bayonet_baffle_joint_depth(
    baffle_thickness, baffle_joint_lip, baffle_joint_neck, baffle_joint_flare);

  _baffle_joint_each = [
    for (j = _baffle_joint_at)
      stirred_tank_baffle_joint_deflection(
        _baffle_load, _baffle_length, _baffle_freeboard, _baffle_width, baffle_thickness,
        baffle_modulus, j, baffle_joint_neck, _baffle_joint_depth)
  ];

  _baffle_joint_deflection =
    len(_baffle_joint_each) == 0 ? 0 : _baffle_joint_each * [for (d = _baffle_joint_each) 1];

  _baffle_deflection = _baffle_solid_deflection + _baffle_joint_deflection;

  _baffle_frequency = stirred_tank_baffle_frequency(
    _baffle_length, _baffle_width, baffle_thickness, baffle_modulus, baffle_density);

  // The cap only binds when the count is derived; a pinned count that overruns it says so.
  _baffle_piece_height =
    _baffle_length / _baffle_segments
    + bayonet_baffle_stack_height(head_interface_for("baffle", 0), lid_thickness);

  // The plate hangs from a coupling with its own fit allowance, so it can lean; what matters is
  // the lean at the impellers. Reported: a tolerance stack, not an impossibility.
  _baffle_lean_slope = bayonet_allowance(head_interface_for("baffle", 0)) / lid_thickness;
  _baffle_gap = port_circle_radius - _baffle_width / 2 - head_impeller_swept_radius(impeller_diameter);

  _baffle_lean_at_lower =
    (head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
      - _impeller_clearance - lid_thickness) * _baffle_lean_slope;

  // Where the mode is crossed, as a speed: a DC motor sweeps every frequency below its maximum,
  // so what decides the plate is whether a crossing is inside the operating band.
  _drive_rpm_lo = min([for (s = _drive_speeds) s[1]]);

  _baffle_crossings = [
    ["the shaft", stirred_tank_critical_speed(_baffle_frequency, 1)],
    ["blade passing", stirred_tank_critical_speed(_baffle_frequency, impeller_n_fins)],
  ];

  _baffle_crossings_in_band =
    [for (c = _baffle_crossings) if (c[1] >= _drive_rpm_lo && c[1] <= _baffle_rpm) c];

  // How far the nearest crossing sits outside the band.
  _baffle_crossing_clearance = min([
    for (c = _baffle_crossings)
      c[1] < _drive_rpm_lo
        ? (_drive_rpm_lo - c[1]) / _drive_rpm_lo
        : c[1] > _baffle_rpm ? (c[1] - _baffle_rpm) / _baffle_rpm : 0
  ]);

  // ----- sparger -----
  _sparge_feed_angle = head_sparge_feed_port(vessel_opening_diameter) * 360 / _n;
  _sparge_support_ports = head_sparge_support_ports(vessel_opening_diameter);
  _sparge_support_angles = [for (i = _sparge_support_ports) i * 360 / _n];

  // A support tube is cut from the riser's own stock, so whichever ports carry one have to pass it.
  _support_bores = [for (i = _sparge_support_ports) head_port_bore_radius(_ports[i])];

  // Reported before it is drawn.
  _sparge_ring_radius = head_sparge_ring_radius(vessel_opening_diameter);
  _sparge_ring_diameter = _sparge_ring_radius * 2;
  _sparge_ring_ratio = stirred_tank_sparge_ring_ratio(_sparge_ring_diameter, impeller_diameter);
  _sparge_ring_height = head_sparge_ring_z(impeller_diameter);
  _sparge_baffle_gap = head_ring_baffle_gap(vessel_opening_diameter, impeller_diameter);
  _sparge_mouth_gap = head_ring_mouth_gap(vessel_opening_diameter, impeller_diameter);
  _sparge_radii = head_sparge_radii(vessel_opening_diameter);
  _sparge_holes = head_sparge_holes(vessel_opening_diameter);
  _sparge_flow = stirred_tank_gas_flow(sparge_design_vvm, _culture_volume);
  _sparge_velocity = stirred_tank_orifice_velocity(_sparge_flow, sparge_hole_count, sparge_hole_diameter);

  // ----- does anything hanging from the lid run into anything already in the vessel? -----
  //
  // The immersion asserts measure depth; a leaning probe can have the right depth and go through
  // the blades. A 2D question because the obstacles are axisymmetric - utils/meridian.scad.
  _floor_z = -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height);

  _obstacles = head_reach_obstacles(
    vessel_opening_diameter, lid_flange_height, vessel_internal_height, vessel_punt_height, impeller_diameter
  );

  _hanging = concat(
    [
      for (i = [0:_n - 1])
        if (head_port_type(_ports[i]) == "probe")
          each let (
            _runs = head_probe_runs(head_port_probe(_ports[i]), vessel_opening_diameter, lid_flange_height, head_probe_tilt(_ports[i], _do_tilt))
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
        head_thermocouple_run(head_port_probe(_tc_port[0]), head_port_interface(_tc_port[0]),
                              vessel_opening_diameter, lid_flange_height),
      ]]
  );

  // ----- can the vessel keep the DO probe fed, and where does it sit in the gas? -----
  //
  // The probe is galvanic and consumes the oxygen it reads. Atlas ask for a flow where a tank can
  // only offer a velocity, so 60 mL/min is spread over the probe's sensing face.
  _do_probe = [
    for (q = _ports) if (head_port_type(q) == "probe" && head_port_function(q) == "do_probe") q
  ];

  // ----- risers -----
  // What the riser has to span. Two datums: the feed's socket sits on the elbow, a support's on
  // the section's top face.
  _sparge_ring_top_z =
  -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
  + _sparge_ring_height;

  _sparge_socket_top_feed = _sparge_ring_top_z
  + sparger_socket_top(sparge_tube(), sparge_tube_facets, sparge_feed_height(), "feed");

  _sparge_socket_top = _sparge_ring_top_z
  + sparger_socket_top(sparge_tube(), sparge_tube_facets, sparge_feed_height(), "support");

  // From inside its socket to clear of its port's flange.
  _sparge_port_top = bayonet_flange_height(head_interface_for("tube", steel_tube_od(sparge_riser_tube) / 2));

  _sparge_riser_length =
    _sparge_port_top + sparge_riser_proud - (_sparge_socket_top - sparge_riser_insertion);

  _sparge_feed_length =
    _sparge_port_top + sparge_riser_proud - (_sparge_socket_top_feed - sparge_riser_insertion);

  _sparge_submergence = vessel_punt_height + _liquid_height - _sparge_ring_height;

  // What holds the ring up, as cantilevers over the free span between the lid's underside and
  // the socket. Reported: what the flow pushes the ring with is not known. A support's span is
  // the longer and softer, so it is the one reported.
  _riser_I = steel_tube_second_moment(sparge_riser_tube);
  _riser_free = -lid_thickness - _sparge_socket_top;
  _riser_k = 3 * steel_tube_modulus() * _riser_I / pow(_riser_free, 3);
  _feed_free = -lid_thickness - _sparge_socket_top_feed;
  _feed_k = 3 * steel_tube_modulus() * _riser_I / pow(_feed_free, 3);

  // Where to drill a support tube's vent: above the liquid, below the lid's inner face, measured
  // from the tube's top end. Nearer the lid is better, since foam finds the lowest hole.
  _riser_top_z = _sparge_port_top + sparge_riser_proud;

  _liquid_surface_z =
  -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
  + vessel_punt_height + _liquid_height;

  // The port's ring is chosen by its ID, and its ID is the tube: two registered rows compared.
  _riser_seal_stretch = oring_stretch(
    oring_inner_diameter(tube_port_riser_oring), steel_tube_od(sparge_riser_tube)
  );

  // Off the gland the port actually cuts, against the tube it seals on.
  _riser_seal_squeeze =
    oring_rod_gland_squeeze(steel_tube_od(sparge_riser_tube), 2 * bayonet_bore_gland_radius(tube_port_riser_oring),
                  oring_cross_section(tube_port_riser_oring));

  _riser_port_bore =
    head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2;

  // ----- dosing -----
  // The dosing line goes over the riser's proud end, so the fit is the pump tube's inside against
  // the riser's outside, and interference is the grip. Empty on a narrow jar with no dosing pair.
  _dosing_ports = [
    for (i = [0:_n - 1])
      if (len([for (f = dosing_pump_functions) if (head_port_function(_ports[i]) == f) 1]) > 0) i
  ];
  _dosing_tube_id = peri_pump_tube_inner_diameter(head_dosing_pump);
  _riser_od = steel_tube_od(sparge_riser_tube);

  // Bought as stock and cut, so the purchase list needs the stock length and the cut list.
  _riser_total = _sparge_feed_length + len(_sparge_support_angles) * _sparge_riser_length;
  _riser_stock = steel_tube_stock_for(_riser_total, 1);

  // ----- gas supply -----
  //
  // What the pump does against this vessel, what a throttle takes out, and which meter reads it.
  _gas_vessel_pressure = _sparge_submergence / 1000 * stirred_tank_medium_density() * 9.81
  + stirred_tank_capillary_pressure(sparge_hole_diameter);
  _gas_band = [sparge_vvm_band[0] * _culture_volume, sparge_vvm_band[1] * _culture_volume];

  // The line's own losses at the design flow, for the echo; head_gas_line_pressure() has the total.
  _gas_filter_drop = gas_filter_pressure_drop(_gas_band[1], gas_filter_drop_slope(sparge_inlet_filter));

  _gas_riser_drop = gas_tube_pressure_drop(
    _gas_band[1], steel_tube_id(sparge_riser_tube), _sparge_feed_length);

  _gas_check_valve_drop = check_valve_cracking(sparge_check_valve)
    + gas_valve_pressure_drop(_gas_band[1], check_valve_cv(sparge_check_valve), _gas_vessel_pressure);

  _gas_back_pressure =
    head_gas_line_pressure(_gas_band[1], _gas_vessel_pressure, _sparge_feed_length);

  _gas_outlet_drop = is_undef(sparge_outlet_filter)
    ? 0
    : gas_filter_pressure_drop(_gas_band[1], gas_filter_drop_slope(sparge_outlet_filter)) + _gas_riser_drop;

  _gas_free_flow = air_pump_free_flow_min(head_air_pump);
  _gas_dead_head = air_pump_dead_head(head_air_pump);

  // The line priced at both ends of the band, so where the pump settles can be asked.
  _gas_line = gas_line_secant(
    _gas_band[0], head_gas_line_pressure(_gas_band[0], _gas_vessel_pressure, _sparge_feed_length),
    _gas_band[1], _gas_back_pressure);

  _gas_ceiling_flow = gas_operating_flow(_gas_free_flow, _gas_dead_head, _gas_line);

  // What guards the way out, which today is nothing.
  _gas_outlet_budget =
    gas_filter_slope_budget(_gas_free_flow, _gas_dead_head, _gas_line, _gas_band[1]);

  // What the way out costs before any filter: the vent slot is hand-cut, and an orifice is
  // unforgiving in the small direction. Both come out of the throttle's headroom.
  _vent_bore = steel_tube_id(sparge_riser_tube);
  _vent_bore_area = PI / 4 * pow(_vent_bore, 2);
  _vent_budget_pa = _gas_outlet_budget * _gas_band[1] * 1000;

  _vent_slot_drop =
    stirred_tank_orifice_pressure(stirred_tank_orifice_velocity(_gas_band[1] / 60000, 1, _vent_bore));

  _vent_run = [_riser_top_z + lid_thickness, _riser_top_z - _liquid_surface_z];
  _vent_tube_drop = [for (l = _vent_run) gas_tube_pressure_drop(_gas_band[1], _vent_bore, l)];
  _vent_min_area = stirred_tank_orifice_area(_gas_band[1] / 60000, _vent_budget_pa) * 1e6;
  _vent_min_diameter = sqrt(4 * _vent_min_area / PI);

  // The throttle as a part, only where a valve has anything to do: a negative drop is a nan Cv.
  _gas_throttle_drop =
    gas_throttle_pressure(_gas_free_flow, _gas_dead_head, _gas_band[1], _gas_back_pressure);

  // Oldshue p.228: an axial impeller needs 8-10x the gas stream's power to hold its flow pattern,
  // a radial one 3x.
  _gas_ceiling = stirred_tank_gas_flow_ceiling(
    stirred_tank_power(impeller_diameter, _baffle_rpm, _impeller_po),
    impeller_pumping(head_impeller_type), _liquid_height);

  // ----- port spacing -----
  // Whether that many ports clear each other on the circle: the worst adjacent pair of flanges
  // decides. See docs/ports-layout.md.
  _port_gap = min([
    for (i = [0:_n - 1])
      2 * port_circle_radius * sin(180 / _n)
      - bayonet_flange_radius(head_port_interface(_ports[i]))
      - bayonet_flange_radius(head_port_interface(_ports[(i + 1) % _n]))
  ]);

  _bore_gap = min([
    for (i = [0:_n - 1])
      2 * port_circle_radius * sin(180 / _n)
      - bayonet_port_hole_radius(head_port_interface(_ports[i]))
      - bayonet_port_hole_radius(head_port_interface(_ports[(i + 1) % _n]))
  ]);

  // Which interfaces this lid ended up with, since the answer is derived.
  _iface_names = [for (p = _ports) bayonet_name(head_port_interface(p))];
  _uniform = len([for (nm = _iface_names) if (nm != _iface_names[0]) nm]) == 0;

  // The motor mount stands on the same face as the flanges, so the ports have to clear it inward.
  _mount_to_ports = port_circle_radius - bayonet_flange_radius(head_widest_interface(_ports)) - _mount_body_d / 2;

  // What the slack above that minimum would be worth as an eccentric offset. Not a gain this
  // build collects: Karcz's correlation is for an unbaffled tank. Reported, never warned on.
  _eccentricity_room = max(0, _mount_to_ports - lid_holes_offset);
  _eccentricity_ratio = _eccentricity_room / _vessel_bore;

  _karcz_departures = stirred_tank_eccentric_departures(
    _impeller_ratio, _liquid_to_bore, _culture_volume,
    stirred_tank_reynolds(impeller_diameter, dc_motor_rated_output_rpm(_motor)),
    _eccentricity_ratio, len(_baffle_at), impeller_to_render == "both", false
  );

  // The joint posts are bored through the flange, and where its edge falls is the assembly's to set
  _post_reach = max([for (p = post_pts) norm(p)]) + post_hole_diameter / 2;

  // --- lid seal ---
  _gasket_ir = head_gasket_inner_radius(vessel_opening_diameter, lip_arc_radius);
  _gasket_or = head_gasket_outer_radius(vessel_opening_diameter, vessel_wall_thickness, lip_arc_radius);
  _groove_r = head_plug_oring_groove_radius(vessel_opening_diameter, _build_plug_oring);
  _groove_w = head_plug_groove_width(vessel_opening_diameter, _build_plug_oring);

  _gasket_w = head_gasket_width(vessel_wall_thickness, lip_arc_radius);
  _lip_band = head_lip_contact_width(vessel_wall_thickness, lip_arc_radius, _gasket_sheet);
  _gasket_rim = head_gasket_rim_width(vessel_wall_thickness);
  _gasket_force = head_gasket_seating_force(vessel_opening_diameter, vessel_wall_thickness, _gasket_sheet, lip_arc_radius);

  // The ring's installed ID is the groove it is cut for; with no ring selected the groove is
  // quoted against the largest cord registered.
  _plug_ring = head_plug_oring_selected(vessel_opening_diameter, _build_plug_oring);
  _plug_cord_nominal = max([for (r = orings) oring_cross_section(r)]);
  _ring_id =
  is_undef(_plug_ring)
    ? vessel_opening_diameter - 2 * oring_gland_depth(_plug_cord_nominal, lid_plug_oring_squeeze)
    : _groove_r * 2;

  _plug_stretch =
  is_undef(_plug_ring) ? undef : oring_stretch(oring_inner_diameter(_plug_ring), _ring_id);

  _plug_fill = oring_gland_fill(
    oring_cross_section(_plug_ring),
    _groove_w,
    oring_gland_depth(oring_cross_section(_plug_ring), lid_plug_oring_squeeze)
  );

  // how much of the cord the groove holds, the check against it rolling out
  _plug_containment = oring_containment(
    oring_cross_section(_plug_ring),
    head_lid_plug_diameter(vessel_opening_diameter) / 2 - _groove_r
  );

  // ----- keying -----
  // A port carrying an orientation is only as true as its coupling is keyed.
  _oriented_at = [for (i = [0:_n - 1]) if (head_port_is_oriented(head_port_type(_ports[i]))) i];

  _unkeyed_at = [
    for (i = _oriented_at) if (!bayonet_is_keyed(head_port_interface(_ports[i]))) i,
  ];

  // By comprehension, since an assert's message is evaluated whether or not it fires.
  _unkeyed_detail = [
    for (i = _unkeyed_at) str(
      head_port_function(_ports[i]), " on ", bayonet_name(head_port_interface(_ports[i])),
      " (", bayonet_seating_count(head_port_interface(_ports[i])), " seatings, ",
      360 / bayonet_seating_count(head_port_interface(_ports[i])), " deg apart)"
    ),
  ];

  // The joint holding the mount down: inserts in the lid, screws through the mount's flange. The
  // screw head lands on the counterbore floor partway down that flange.
  _mm_grip = motor_mount_base_screw_grip(motor_mount_wall_thickness);

  // ===== checks and reports =====

  assert(
    !is_undef(_ports),
    str(
      "No registered port set fits a ", vessel_opening_diameter, " mm mouth. The full twelve wants ",
      "142 mm and the reduced six wants 77.6 - see docs/ports-layout.md."
    )
  );

  echo(str(
    "DO probe lean: ", _do_tilt, " deg of a ", _build_do_tilt_max, " deg ceiling",
    _do_tilt < _build_do_tilt_max ? str(", capped ", _build_do_tilt_max - _do_tilt, " deg short by the jar's internals") : ""
  ));

  echo(
    is_undef(_feasible)
      ? str("vessel fit: no mouth is feasible for a ", impeller_diameter, " mm impeller at these allowances")
      : str(
        "vessel fit: a ", impeller_diameter, " mm impeller is feasible in mouths ", _feasible[0], " to ",
        // an upper bound at the search ceiling is the search running out, not a constraint
        _feasible[1] >= head_feasible_mouth_sweep()[1] ? "unbounded" : str(_feasible[1], " mm"),
        "; this jar's is ", vessel_opening_diameter
      )
  );

  echo(str(
    "impeller: ", impeller_diameter, " mm in a ", _vessel_bore, " mm bore, D/T ", _impeller_ratio,
    " (band ", _ratio_band[0], "-", _ratio_band[1], ", axial ", _ratio_band_axial[0], "-",
    _ratio_band_axial[1], "); spacing ", impeller_spacing_factor, " D (band ", _spacing_band[0],
    "-", _spacing_band[1], ")"
  ));

  if (_swept != impeller_diameter)
    echo(str(
      "WARNING impeller: sweeps ", _swept, " mm but Po, D/T and the baffle clearance are computed on ",
      impeller_diameter, "; D/T is really ", stirred_tank_ratio(_swept, _vessel_bore), " and shaft power ",
      pow(_swept / impeller_diameter, 5), "x"
    ));

  echo(str(
    "impeller clearance: centreline ", _impeller_clearance, " mm off the floor = ",
    _clearance_ratio, " D (Oldshue allows ", _clearance_band[0], "-", _clearance_band[1], "), C/T ",
    _impeller_clearance / _vessel_bore, "; ", _sparger_room, " mm under the lower impeller and ",
    _impeller_coverage, " mm (", _coverage_ratio, " D) of culture over the upper"
  ));

  if (_coverage_ratio < stirred_tank_coverage_minimum())
    echo(str(
      "WARNING impeller coverage: ", _coverage_ratio, " D of liquid over the upper impeller, under the ",
      stirred_tank_coverage_minimum(), " D floor (Oldshue: fluidfoils short-circuit to a low distance ",
      "above themselves); lower impeller_clearance_factor"
    ));

  echo(str(
    "impeller count: 2 on ", _liquid_height / impeller_diameter, " impeller diameters of liquid (H/T ",
    _liquid_to_bore, "), where the spacing band allows ", _count_bounds[0], " < n < ", _count_bounds[1],
    stirred_tank_impeller_count_fits(2, _liquid_height, impeller_diameter)
      ? ""
      : str(" - short for a pair, which costs the coverage above: ", _coverage_ratio, " D against the ",
        stirred_tank_coverage_minimum(), " D floor")
  ));

  // Oldshue's 1-2 d is a permissive allowance for fluidfoils; what fits a pitched blade is Fořt,
  // who found hydraulic efficiency higher at C/D 1.0 than 0.5.
  if (!stirred_tank_in_band(_clearance_ratio, _clearance_band))
    echo(str(
      "impeller clearance: ", _clearance_ratio, " D is below Oldshue's ", _clearance_band[0], "-",
      _clearance_band[1], " D for fluidfoils; this is a ", impeller_name(head_impeller_type),
      ", where Fořt found efficiency higher at C/D 1.0 than 0.5, and coverage over the upper impeller binds at ",
      (vessel_punt_height + _liquid_height - impeller_spacing - impeller_height / 2
        - stirred_tank_coverage_minimum() * impeller_diameter) / impeller_diameter,
      " D (docs/agitation.md)"
    ));

  if (!stirred_tank_in_band(_impeller_ratio, _ratio_band))
    echo(str(
      "WARNING impeller: D/T of ", _impeller_ratio, " is outside the ", _ratio_band[0], "-", _ratio_band[1],
      " band; below it the impeller does not move enough fluid, above it an axial impeller loses its axial motion"
    ));

  if (!stirred_tank_in_band(impeller_spacing_factor, _spacing_band))
    echo(str(
      "WARNING impeller: spacing of ", impeller_spacing_factor, " D is outside the ", _spacing_band[0], "-",
      _spacing_band[1], " D band; too close costs up to 35% of the power imparted, too far mixes the zones poorly"
    ));

  // Which way the pair pumps, and therefore where gas belongs; the drawn parts do not show it.
  echo(str(
    "impeller pumping: shaft turns ", head_shaft_rotation > 0 ? "counter-clockwise" : "clockwise",
    " seen from above, so the lower impeller pumps ",
    stirred_tank_lower_pumps_up(head_shaft_rotation) ? "up and the upper down" : "down and the upper up",
    " and the pair ", stirred_tank_pair_converges(head_shaft_rotation) ? "converges on" : "diverges from",
    " the ", impeller_spacing - impeller_height - impeller_collar_height, " mm gap between them"
  ));

  if (!stirred_tank_pair_converges(head_shaft_rotation))
    echo(str(
      "WARNING impeller pumping: a diverging pair puts the discharges at opposite ends of the vessel, so no ",
      "single sparge ring sits in both (Birch & Ahmed); reverse head_shaft_rotation, see docs/agitation.md"
    ));

  echo(str(
    "impeller set screws: ", len(impeller_set_screw_at), " x ", set_screw_name(impeller_set_screw),
    " (", set_screw_part_number(impeller_set_screw), ") at ", impeller_set_screw_at, " deg, ",
    _set_screw_engagement, " mm of thread in a ", _set_screw_hole,
    " mm tap hole, through a ", impeller_collar_height, " mm collar above the blades"
  ));

  // The collar stands in the gap between the impellers.
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
      " mm hole; raise impeller_collar_height"
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
      "WARNING impeller set screws: the screw stands ", -_set_screw_reach, " mm proud of the hub; a shorter row or a hub of ",
      shaft_diameter(_shaft) / 2 + set_screw_length(impeller_set_screw), " mm sits flush"
    ));

  if (_set_screw_engagement < set_screw_diameter(impeller_set_screw))
    echo(str(
      "WARNING impeller set screws: ", _set_screw_engagement, " mm of thread is under one ",
      set_screw_diameter(impeller_set_screw), " mm diameter; in PETG the thread strips before the joint slips, grow impeller_hub_radius"
    ));

  echo(str(
    "culture: ", _culture_volume, " L standing ", _liquid_height, " mm deep, ",
    _culture_volume / _vessel_capacity * 100, "% of the ", _vessel_capacity, " L capacity and ",
    _liquid_height / vessel_internal_height * 100, "% of the ", vessel_internal_height, " mm internal height"
  ));

  // 0.8 of capacity is the usual headspace allowance; unsourced, so sat against rather than a band
  echo(str(
    "culture headspace: ", _vessel_capacity - _culture_volume, " L of gas space at ",
    _build_fill_fraction * 100, "% of capacity",
    _build_fill_fraction > 0.8 ? str(", above the usual 0.8 by ", (_build_fill_fraction - 0.8) * 100, " points") : ""
  ));

  if (_po_measured)
    echo(str(
      "impeller: ", impeller_name(head_impeller_type), " Po ", _impeller_po, ", measured",
      is_undef(impeller_power_number_tol(head_impeller_type))
        ? " (no uncertainty given)"
        : str(" +/- ", impeller_power_number_tol(head_impeller_type))
    ));

  if (_po_borrowed)
    echo(str(
      "impeller: ", impeller_name(head_impeller_type), " has no measured power number and no blade angle; borrowing ",
      _impeller_po, " from ", impeller_name(head_impeller_po_fallback), ", an over-estimate since twist lowers Po"
    ));

  if (_po_correlated)
    echo(str(
      "impeller: ", impeller_name(head_impeller_type), " Po ", _impeller_po,
      " and flow number ", _impeller_flow_number,
      " from Medek's correlation at ", impeller_blade_angle(head_impeller_type), " deg, ",
      len(_medek_departures) == 0
        ? "inside its validity envelope"
        : str("extrapolated on ", _medek_departures)
    ));

  if (len(_drive_speeds) == 0)
    echo(str("drive: ", dc_motor_name(_motor), " registers no output speed, so no Re or dissipation follows"));

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

  if (len(_tc_port) > 0) {
    _tc_probe = head_port_probe(_tc_port[0]);
    _tc_iface = head_port_interface(_tc_port[0]);
    _tc_reach = head_thermocouple_depth(_tc_probe, _tc_iface);
    _tc_floor = head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height);
    _tc_surface = _tc_floor - vessel_punt_height - _liquid_height;
    // Engagement is what the fitter does, so both bounds are checked.
    _tc_deepest = head_thermocouple_depth(_tc_probe, _tc_iface, 1);
    _tc_shallowest = head_thermocouple_depth(_tc_probe, _tc_iface, 0);

    echo(str(
      "thermocouple: ", thermocouple_probe_part_number(_tc_probe), " on ",
      npt_thread_name(thermocouple_probe_thread(_tc_probe)), ", tip ", _tc_reach, " mm below the lid at ",
      thermocouple_thread_engagement * 100, "% engagement, ", _tc_reach - _tc_surface, " mm under the surface with ",
      _tc_floor - _tc_reach, " mm to the floor; ", _tc_shallowest, " to ", _tc_deepest, " mm over the engagement range"
    ));

    assert(
      _tc_deepest < _tc_floor,
      str(
        "Thermocouple reaches ", _tc_deepest, " mm fully threaded but the floor is ", _tc_floor,
        " mm below the lid, so the tip would be ", _tc_deepest - _tc_floor, " mm through it."
      )
    );

    assert(
      _tc_shallowest > _tc_surface,
      str(
        "Thermocouple reaches ", _tc_shallowest, " mm not threaded in at all, and the culture starts ",
        _tc_surface, " mm below the lid, so the tip can sit in the headspace and read gas, not broth."
      )
    );
  }

  // The same two questions for the probes, which seat where their collets put them.
  for (i = [for (j = [0:_n - 1]) if (head_port_type(_ports[j]) == "probe") j])
    let (
      _p = head_port_probe(_ports[i]),
      _tilt = head_probe_tilt(_ports[i], _do_tilt),
      _reach = head_probe_reach(_p, lid_flange_height, _tilt),
      _floor = head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height),
      _surface = _floor - vessel_punt_height - _liquid_height
    ) {
      echo(str(
        "probe: ", head_port_function(_ports[i]), " carries ", atlas_probe_name(_p), ", reaching ",
        _reach, " mm, tip ", _reach - _surface, " mm under the surface with ", _floor - _reach,
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

  // ----- transfer -----
  // Blend time and kLa, from the specific power above; see utils/stirred_tank.scad for what each
  // correlation is worth.
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

  if (!is_undef(_pv_rated) && _pv_rated < _kla_band[0])
    echo(str(
      "transfer: kLa is van't Riet's air-water correlation, fitted over ", _kla_band[0], "-", _kla_band[1],
      " W/m3, and this vessel runs ", _pv_rated, "; an order of magnitude, not a number"
    ));

  if (_culture_volume / 1000 < _blend_band[0])
    echo(str(
      "transfer: blend time is Ruszkowski's, fitted on ", _blend_band[0], "-", _blend_band[1],
      " m3 fully baffled, and this is ", _culture_volume / 1000, " m3; it reproduces Hall's table at a tenth of that"
    ));

  if (is_undef(_encoder))
    echo(str("drive: ", dc_motor_name(_motor), " carries no encoder, so shaft speed is commanded, not measured"));
  else
    echo(str(
      "drive encoder: ", _encoder[0], " ppr x ", _encoder[1], " channels through ",
      gearbox_ratio(head_gearbox), ":1 = ", _encoder_counts, " counts per output turn, resolving ",
      60 / (_encoder_counts * encoder_speed_window), " rpm over ", encoder_speed_window * 1000, " ms"
    ));

  // ----- fit -----
  assert(
    impeller_spacing > impeller_height,
    str("Impellers overlap: ", impeller_spacing, " mm apart but ", impeller_height, " mm tall.")
  );

  // Below this the lower impeller hangs off the end of its own shaft.
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

  // Scaled off the bore, but it has to pass the opening.
  assert(
    head_mouth_passes_impeller(vessel_opening_diameter, impeller_diameter),
    str(
      "Impeller sweeps ", 2 * head_impeller_swept_radius(impeller_diameter), " mm, past the ",
      vessel_opening_diameter, " mm opening it has to pass through."
    )
  );

  assert(
    shaft_jar_punt_clearance >= 0,
    str("Shaft is drawn ", -shaft_jar_punt_clearance, " mm into the jar's floor.")
  );

  // What the shaft leaves above the lid for the coupling to grip.
  assert(
    shaft_protrusion >= head_shaft_min_protrusion(),
    str(
      "Shaft leaves ", shaft_protrusion, " mm above the lid's outer face and the ",
      sc_length(shaft_coupler), " mm coupling wants ", head_shaft_min_protrusion(),
      " to grip. No registered shaft is long enough for a ", vessel_internal_height,
      " mm vessel; the registry runs to ", max([for (t = shafts) shaft_length(t)]), " mm."
    )
  );

  echo(str(
    "shaft: ", shaft_name(_shaft), " (", shaft_part_number(_shaft), ") ",
    shaft_diameter_min(_shaft), "-", shaft_diameter_max(_shaft), " mm in a ",
    bb_bore(shaft_bearing), " mm bore: ", _fit_tightest, " to ", _fit_loosest, " mm"
  ));

  assert(
    sc_diameter1(shaft_coupler) == gearbox_output_shaft_dia(head_gearbox) &&
    sc_diameter2(shaft_coupler) == shaft_diameter(_shaft),
    str(
      "The ", shaft_coupling_name(shaft_coupler), " coupling bores ", sc_diameter1(shaft_coupler), " and ",
      sc_diameter2(shaft_coupler), " mm, for a ", gearbox_output_shaft_dia(head_gearbox),
      " mm gearbox shaft and a ", shaft_diameter(_shaft), " mm impeller shaft."
    )
  );

  if (_mount_slenderness > 3)
    echo(str(
      "WARNING motor mount: ", _mount_slenderness, " diameters tall; ",
      is_undef(_build_shaft)
        ? str("the shaft is already the shortest row that reaches (", shaft_length(_shaft), " mm against ",
          head_shaft_length_needed(lid_flange_height, vessel_internal_height), " needed) and the registry steps by 200")
        : str("head_shaft pins ", shaft_name(_shaft), " where undef would pick ",
          shaft_name(head_shaft_for(lid_flange_height, vessel_internal_height)))
    ));

  if (_mount_slenderness > 5)
    echo(str(
      "WARNING motor mount: ", motor_mount_height, " mm on a ", _mount_body_d, " mm body is ", _mount_slenderness,
      " diameters; a printed telescoping tube that slender will not hold a rigid coupling in alignment"
    ));

  echo(str("motor mount height: ", motor_mount_height / 10, " cm"));

  // --- motor mount joint ---
  assert(
    screw_radius(motor_mount_base_screw) * 2 == insert_screw_diameter(motor_mount_base_insert),
    str(
      "The motor mount takes an M", screw_radius(motor_mount_base_screw) * 2, " screw into an insert sized for M",
      insert_screw_diameter(motor_mount_base_insert), "."
    )
  );

  assert(
    _insert_floor >= lid_blind_pocket_floor_min,
    str(
      "A ", heat_set_insert_name(motor_mount_base_insert), " insert leaves ", _insert_floor, " mm of lid before the culture; ",
      lid_blind_pocket_floor_min, " mm is the least this lid keeps."
    )
  );

  assert(
    _bearing_floor >= lid_blind_pocket_floor_min,
    str(
      "A ", bb_name(shaft_bearing), " bearing leaves ", _bearing_floor, " mm of lid before the culture; ",
      lid_blind_pocket_floor_min, " mm is the least this lid keeps."
    )
  );

  assert(
    bearing_hole_allowance >= 0,
    str("Bearing hole allowance of ", bearing_hole_allowance, " mm is negative, so the pocket is cut under the bearing.")
  );

  assert(
    _bearing_seal_stretch >= 0,
    str(
      "The ", oring_name(bearing_oring), " bearing seal has an ID of ",
      oring_inner_diameter(bearing_oring), " mm on a ", bb_diameter(shaft_bearing),
      " mm bearing, so it would have to be compressed onto it rather than seated."
    )
  );

  // The groove has to sit inside the pocket with wall left either side.
  assert(
    head_bearing_gland_z() - head_bearing_gland_length() / 2 > 0
      && head_bearing_gland_z() + head_bearing_gland_length() / 2 < bb_width(shaft_bearing),
    str(
      "A ", head_bearing_gland_length(), " mm seal groove centred at ", head_bearing_gland_z(),
      " does not fit inside a ", bb_width(shaft_bearing), " mm pocket."
    )
  );

  assert(
    _insert_to_bearing > 0,
    str(
      "Motor mount inserts on a ", head_motor_mount_screw_radius(_mount_body_d) * 2, " mm circle overlap the bearing seal groove by ",
      -_insert_to_bearing, " mm."
    )
  );

  echo(str(
    "bearing seal: ", oring_name(bearing_oring), " on the ", bb_name(shaft_bearing), "'s ",
    bb_diameter(shaft_bearing), " mm rim at ", _bearing_seal_stretch * 100, "% stretch, in a groove to ",
    head_bearing_gland_diameter(), " mm, ",
    oring_rod_gland_squeeze(bb_diameter(shaft_bearing), head_bearing_gland_diameter(),
                  oring_cross_section(bearing_oring)) * 100,
    "% radial squeeze, ", _insert_to_bearing, " mm from the nearest mount insert"
  ));

  echo(str(
    "motor mount: 4 x ", heat_set_insert_name(motor_mount_base_insert), " inserts on a ", head_motor_mount_screw_radius(_mount_body_d) * 2,
    " mm circle, ", screw_length(motor_mount_base_screw, motor_mount_base_screw_grip(motor_mount_wall_thickness), 0, insert=motor_mount_base_insert),
    " mm M", insert_screw_diameter(motor_mount_base_insert), " screws, ", _insert_floor, " mm of lid left under them, ",
    _insert_to_bearing, " mm to the bearing pocket"
  ));

  assert(
    !_has_baffles || _baffle_width > 0,
    str(
      "A ", impeller_diameter, " mm impeller leaves no room for a baffle on a ",
      head_port_circle_radius(vessel_opening_diameter) * 2, " mm port circle at ",
      baffle_impeller_clearance, " mm clearance."
    )
  );

  echo(
    !_has_baffles
      ? "baffles: none on this lid, so the vessel is unbaffled and will swirl rather than mix"
      : str(
        "baffles: ", len(_baffle_at), " x ", _baffle_width, " x ", _baffle_length, " mm (",
        baffle_max_length, " mm clears the floor), ", _baffle_wetted, " mm submerged; ",
        _baffle_area_ratio, " of Oldshue's four-at-T/12 reference area"
      )
  );

  if (_has_baffles && _baffle_area_ratio < 0.9)
    echo(str(
      "WARNING baffles: ", _baffle_area_ratio, " of the reference projected area; ",
      _baffle_length < baffle_max_length
        ? str("hanging these ", len(_baffle_at), " to the full ", baffle_max_length, " mm would give ", _baffle_ratio_at_depth, ", ")
        : "depth is spent, ",
      len(_next_baffle_count) > 0
        ? str(_next_baffle_count[0], " plates (the next count that spaces equally on ", _n, " ports) would give ",
          stirred_tank_baffle_area_ratio(_vessel_bore, _liquid_height, _next_baffle_count[0], _baffle_width, _baffle_wetted))
        : str(len(_baffle_at), " is the most this port circle spaces equally"),
      "; see docs/agitation.md"
    ));

  if (_has_baffles)
    echo(str(
      "baffle plate: ", _baffle_load, " N each, deflecting ", _baffle_deflection, " mm at the tip",
      _baffle_segments < 2 ? "" : str(" (", _baffle_joint_deflection, " mm of it the joints)"),
      "; first mode ", _baffle_frequency, " Hz against ", stirred_tank_shaft_frequency(_baffle_rpm),
      " Hz shaft and ", stirred_tank_blade_frequency(_baffle_rpm, impeller_n_fins),
      " Hz blade passing at ", _baffle_rpm, " rpm (the mode is the solid plate's; the joints soften it)"
    ));

  if (_has_baffles)
    echo(str(
      "baffle print: ", _baffle_segments, " piece", _baffle_segments == 1 ? "" : "s",
      " of ", _baffle_length / _baffle_segments, " mm, tallest standing ", _baffle_piece_height,
      " mm against a ", baffle_segment_height_max, " mm slenderness cap",
      _baffle_piece_height > baffle_segment_height_max ? str(" (pinned at ", _baffle_segments, ", over the cap)") : "",
      _baffle_segments < 2
        ? ""
        : str("; the dovetail leaves ", baffle_joint_neck, " mm of ", baffle_thickness,
              " crossing each joint, ", head_baffle_joint_stiffness_ratio(), " of the plate's second moment")
    ));

  if (_has_baffles)
    echo(str(
      "baffle clearance: ", _baffle_gap, " mm nominal to the impeller, less ", _baffle_lean_at_lower,
      " mm the coupling's ", bayonet_allowance(head_interface_for("baffle", 0)),
      " mm of play allows at the lower impeller = ", _baffle_gap - _baffle_lean_at_lower, " mm running",
      _baffle_gap - _baffle_lean_at_lower < 0 ? " - the plate can reach the blades" : ""
    ));

  if (_has_baffles && _baffle_deflection > _baffle_width / 10)
    echo(str(
      "WARNING baffle plate: ", _baffle_deflection, " mm of tip deflection is over a tenth of the ",
      _baffle_width, " mm plate, so it bends away from the swirl rather than blocking it; thicken it (the lock bore allows ",
      bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance) > _baffle_width
        ? "more" : "no more", ")"
    ));

  if (_has_baffles)
    echo(str(
      "baffle resonance: the ", _baffle_frequency, " Hz mode is crossed by ",
      _baffle_crossings[0][0], " at ", _baffle_crossings[0][1], " rpm and by ",
      _baffle_crossings[1][0], " at ", _baffle_crossings[1][1], " rpm, against a ",
      _drive_rpm_lo, "-", _baffle_rpm, " rpm band; ",
      len(_baffle_crossings_in_band) == 0
        ? str("neither is a speed this drive is asked to hold, the nearest clears the band by ",
          _baffle_crossing_clearance * 100, "%")
        : "that is a speed it is asked to hold"
    ));

  if (_has_baffles && len(_baffle_crossings_in_band) > 0)
    echo(str(
      "WARNING baffle plate: ", _baffle_crossings_in_band[0][0], " crosses its ", _baffle_frequency,
      " Hz mode at ", _baffle_crossings_in_band[0][1], " rpm, inside the ", _drive_rpm_lo, "-", _baffle_rpm,
      " rpm the drive runs; thickness raises the crossing as t^1.5 and length lowers it as 1/L^2"
    ));

  // ----- sparge ring -----
  //
  // The feed comes down the air inlet, whose sector must have no baffle in it.
  assert(
    head_port_type(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) == "tube",
    str("the air_in port, ", head_sparge_feed_port(vessel_opening_diameter), ", is a \"", head_port_type(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]),
        "\", not a tube.")
  );

  assert(
    len(_support_bores) == 0 || min(_support_bores) * 2 >= steel_tube_od(sparge_riser_tube),
    str(
      "sparge support: ", [for (i = _sparge_support_ports) head_port_function(_ports[i])],
      " - the narrowest of those ports bores ",
      min(_support_bores) * 2, " mm and the support tube is ", steel_tube_od(sparge_riser_tube),
      " mm across, so it will not go through"
    )
  );

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
    " mm to the jar's mouth on the way in; a ", sparge_tube(), " mm tube reaching ",
    sparge_tube_extent(), " across its corners, on a ", sparge_bore(), " mm bore of ",
    PI / 4 * pow(sparge_bore(), 2), " mm2"
  ));

  sparger_report(
    radii=_sparge_radii, holes=_sparge_holes, hole_diameter=sparge_hole_diameter,
    tube=sparge_tube(), bore=sparge_bore(), gas_flow=_sparge_flow, paths=2
  );

  // `just check-holes` renders with -D sparge_hole_probes=true and probes each point in the mesh
  if (sparge_hole_probes)
    sparger_hole_probes(
      radii=_sparge_radii, holes=_sparge_holes, tube=sparge_tube(),
      section_facets=sparge_tube_facets, feed_angle=_sparge_feed_angle
    );

  echo(str(
    "sparge holes: ", sparge_hole_count, " x ", sparge_hole_diameter, " mm at ",
    PI * _sparge_ring_diameter / sparge_hole_count, " mm spacing; at ", sparge_design_vvm,
    " vvm that is ", _sparge_flow * 60000, " L/min through them at ", _sparge_velocity, " m/s"
  ));

  // The ratio is why even flow is not a design target here.
  echo(str(
    "sparge holes: capillary ", stirred_tank_capillary_pressure(sparge_hole_diameter),
    " Pa to launch a bubble against ", stirred_tank_orifice_pressure(_sparge_velocity),
    " Pa to push gas through, so the holes will not all flow evenly, which Rewatkar & Joshi find does not matter near the impeller"
  ));

  // The ring is placed to satisfy both gaps, so an assert on either would be dead; what is worth
  // reporting is what the placement cost.
  if (_has_baffles && head_baffle_ring_limit(vessel_opening_diameter) < 2 * (port_circle_radius - impeller_diameter / 2 - baffle_impeller_clearance)
    && head_baffle_ring_limit(vessel_opening_diameter) < bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance))
    echo(str(
      "sparge ring: the ring is what caps the baffles here, at ",
      head_baffle_ring_limit(vessel_opening_diameter),
      " mm, where they would otherwise be ",
      min(bayonet_baffle_width(head_interface_for("baffle", 0), baffle_thickness, baffle_bore_clearance),
        2 * (port_circle_radius - impeller_diameter / 2 - baffle_impeller_clearance)),
      " mm; room outside a baffle does not grow with the mouth"
    ));

  if (!stirred_tank_in_band(_sparge_ring_ratio, stirred_tank_sparge_ring_band()))
    echo(str(
      "WARNING sparge ring: ", _sparge_ring_ratio, " D is outside the ",
      stirred_tank_sparge_ring_band()[0], "-", stirred_tank_sparge_ring_band()[1],
      " D band; the mouth places it, so this jar's mouth and bore are too far apart for a ring that suits both"
    ));

  // Only pairs that share a height are reported.
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
            str(h[0], " runs through the ", o[0], " by ", -_gap, " mm radially, over the heights they share.")
          );
        }

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
            " mm/s mean and the probe needs ", _needed, " mm/s past its face, ", _v / _needed,
            "x; mean, not local"
          ));

      // Where the sensing face sits against the ring of bubbles; where the gas goes is not modelled
      let (
        _tip = head_probe_axis_at(
          vessel_opening_diameter, lid_flange_height,
          bayonet_probe_port_collet_drop(_do, probe_port_transition_length)
          + atlas_probe_body_height(_do) + atlas_probe_tip_height(_do),
          head_probe_tilt(_do_probe[0], _do_tilt)
        )
      )
      {
        echo(str(
          "DO probe in the gas: its face sits ", _tip[1] - (_floor_z + _sparge_ring_height),
          " mm above the sparge ring's centreline and ", abs(_tip[0] - _sparge_ring_radius),
          " mm off its radius; where the bubbles go is a bench question"
        ));

        if (abs(_tip[0] - _sparge_ring_radius)
          < sparge_tube_extent() / 2 + atlas_probe_tip_dia(_do) / 2)
          echo(str(
            "WARNING DO probe: its face overlaps the sparge ring's radius and hangs ",
            _tip[1] - (_floor_z + _sparge_ring_height), " mm over it; a galvanic probe reads high with a bubble ",
            "on the membrane and low with none moving past (TODO.md)"
          ));
      }
    }

  // ----- and does it fit through the mouth on the way in? -----
  //
  // The lid descends through the neck, so what matters is the widest the printed port ever gets;
  // the probes go in afterwards through the bore. The collet's bottom is the widest point.
  for (i = [for (j = [0:_n - 1]) if (head_port_type(_ports[j]) == "probe") j])
    let (
      _tilt = head_probe_tilt(_ports[i], _do_tilt),
      _collet = head_probe_runs(
        head_port_probe(_ports[i]), vessel_opening_diameter, lid_flange_height, _tilt
      )[0],
      _widest = meridian_max_radius(_collet),
      _mouth = vessel_opening_diameter / 2
    ) {
      echo(str(
        "port fit: ", head_port_function(_ports[i]), "'s collet reaches ", _widest,
        " mm from the axis leaning ", _tilt, " deg, and the mouth is ", _mouth, " mm, ",
        _mouth - _widest, " mm to spare on the way in"
      ));

      assert(
        _widest <= _mouth,
        str(
          head_port_function(_ports[i]), "'s collet reaches ", _widest,
          " mm from the axis and the jar's mouth is ", _mouth, " mm, so the lid cannot be lowered past it; ",
          "the lean has to give."
        )
      );
    }

  if (len(_sparge_support_angles) > 0)
    echo(str(
      "sparge support drilling: a support tube vents through a hole drilled between ",
      _riser_top_z + lid_thickness, " and ", _riser_top_z - _liquid_surface_z,
      " mm from its top end (past the lid's inner face, short of the culture); nearer the first is better"
    ));

  echo(str(
    "sparge support: ", 1 + len(_sparge_support_angles), " tubes at ",
    concat([_sparge_feed_angle], _sparge_support_angles), " deg; ", _riser_free, " mm of free support tube and ",
    _feed_free, " mm of feed, so a support is ", _riser_k, " N/mm, ", 1 / _riser_k, " mm of sway per newton against ",
    head_ring_baffle_gap(vessel_opening_diameter, impeller_diameter), " mm to the baffles"
  ));

  if (len(_sparge_support_angles) == 0)
    echo(str(
      "WARNING sparge support: the ring hangs on the feed riser alone; ",
      head_ring_baffle_gap(vessel_opening_diameter, impeller_diameter) * _feed_k, " N sideways closes its gap to the baffles"
    ));

  echo(str(
    "sparge riser: ", steel_tube_od(sparge_riser_tube), " x ", steel_tube_id(sparge_riser_tube), " mm tube; the feed is ",
    _sparge_feed_length, " mm and each support ", _sparge_riser_length, " mm (the feed socket sits ",
    _sparge_socket_top_feed - _sparge_socket_top, " mm higher); ", sparge_riser_proud, " mm proud of its port, ",
    sparge_riser_insertion, " mm inside the socket, ",
    head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2 - steel_tube_od(sparge_riser_tube),
    " mm of slack through the port's bore"
  ));

  assert(
    _riser_seal_stretch >= 0 && _riser_seal_stretch <= 0.05,
    str(
      "sparge riser seal: a ", oring_name(tube_port_riser_oring), " ring on a ",
      steel_tube_od(sparge_riser_tube), " mm tube is ", _riser_seal_stretch * 100,
      "% of stretch, outside the 0-5% a rod seal takes"
    )
  );

  echo(str(
    "sparge riser seal: ", oring_name(tube_port_riser_oring), " (", oring_part_number(tube_port_riser_oring),
    ") in each of ", 1 + len(_sparge_support_ports), " ports, at ", _riser_seal_stretch * 100,
    "% stretch and ", _riser_seal_squeeze * 100, "% squeeze; without it each port is a ",
    PI / 4 * (pow(_riser_port_bore, 2) - pow(steel_tube_od(sparge_riser_tube), 2)),
    " mm2 hole into the headspace"
  ));

  if (len(_dosing_ports) > 0)
    echo(str(
      "dosing: ", peri_pump_name(head_dosing_pump), " pulls ",
      _dosing_tube_id, " x ", peri_pump_tube_outer_diameter(head_dosing_pump), " mm tube over ",
      len(_dosing_ports), " risers of ", _riser_od, " mm, ", _riser_od - _dosing_tube_id,
      " mm of interference over ", sparge_riser_proud, " mm of stub"
    ));

  if (len(_dosing_ports) > 0 && _dosing_tube_id >= _riser_od)
    echo(str(
      "WARNING dosing: a ", _dosing_tube_id, " mm bore over a ", _riser_od,
      " mm riser is loose, and nothing else holds a dosing line on"
    ));

  echo(str(
    "sparge tube stock: ", steel_tube_part_number(sparge_riser_tube), ", ",
    steel_tube_material(sparge_riser_tube), " ", steel_tube_construction(sparge_riser_tube),
    ", ", steel_tube_temper(sparge_riser_tube), " temper; cut 1 x ", _sparge_feed_length,
    " mm and ", len(_sparge_support_angles), " x ", _sparge_riser_length, " mm = ", _riser_total, " mm",
    is_undef(_riser_stock)
      ? ", longer than any stock length"
      : str(" from a ", _riser_stock, " mm length, leaving ", _riser_stock - _riser_total, " mm spare")
  ));

  echo(str(
    "sparge back-pressure: ", _sparge_submergence, " mm of culture over the ring is ",
    _sparge_submergence / 1000 * stirred_tank_medium_density() * 9.81,
    " Pa, plus ", stirred_tank_capillary_pressure(sparge_hole_diameter),
    " Pa of capillary = ", _sparge_submergence / 1000 * stirred_tank_medium_density() * 9.81
    + stirred_tank_capillary_pressure(sparge_hole_diameter),
    " Pa the gas supply has to beat before anything bubbles"
  ));

  echo(str(
    "gas line losses: filter ", _gas_filter_drop, " Pa (extrapolated), check valve ", _gas_check_valve_drop,
    " Pa (", check_valve_cracking(sparge_check_valve), " to crack) and riser ", _gas_riser_drop,
    " Pa at ", _gas_band[1], " L/min, on top of the vessel's ", _gas_vessel_pressure,
    _gas_outlet_drop == 0 ? "" : str(" and ", _gas_outlet_drop, " Pa on the way back out"),
    "; the pump beats ", _gas_back_pressure, " Pa, and the filter alone is ",
    _gas_filter_drop / _gas_vessel_pressure, "x the vessel"
  ));

  echo(str(
    "gas supply: ", air_pump_name(head_air_pump), " settles at ", _gas_ceiling_flow,
    " L/min against this line, where ", _gas_band[1], " L/min is wanted, so a throttle has to drop ",
    gas_throttle_pressure(_gas_free_flow, _gas_dead_head, _gas_band[1], _gas_back_pressure),
    " Pa on top of the line's own (not the ", gas_pump_flow(_gas_free_flow, _gas_dead_head, _gas_back_pressure),
    " L/min a back pressure held at the design point suggests)"
  ));

  echo(
    is_undef(sparge_outlet_filter)
      ? str(
        "gas exhaust: nothing filters the way out; the headspace vents through a support tube to the room. ",
        "An outlet filter may cost at most ", _gas_outlet_budget, " kPa per L/min before ", _gas_band[1],
        " L/min stops being reachable, ", _gas_outlet_budget / gas_filter_drop_slope(sparge_inlet_filter),
        " of what the inlet filter costs"
      )
      : str(
        "gas exhaust: an outlet filter at ", gas_filter_drop_slope(sparge_outlet_filter),
        " kPa per L/min is in the line, against a budget of ", _gas_outlet_budget,
        " before ", _gas_band[1], " L/min stops being reachable"
      )
  );

  // Only where there is headroom to spend; a line the pump cannot beat gives a negative budget.
  if (len(_sparge_support_angles) > 0)
    echo(
      _gas_outlet_budget <= 0
        ? str(
          "gas exhaust slot: air_out's hand-cut vent has no size to meet, because the line already beats the pump at ",
          _gas_band[1], " L/min; see the throttle warning"
        )
        : str(
          "gas exhaust slot: a slot of the tube's own ", _vent_bore_area, " mm2 bore costs ", _vent_slot_drop,
          " Pa at ", _gas_band[1], " L/min, and the tube above it ", _vent_tube_drop[0], "-", _vent_tube_drop[1],
          " Pa over the ", _vent_run[0], "-", _vent_run[1], " mm drilling window, together ",
          (_vent_slot_drop + _vent_tube_drop[0]) / _vent_budget_pa * 100, "-",
          (_vent_slot_drop + _vent_tube_drop[1]) / _vent_budget_pa * 100, "% of the ", _vent_budget_pa,
          " Pa the exhaust has to spend; file past ", _vent_min_area, " mm2 (a ", _vent_min_diameter,
          " mm round hole), which the bore clears ", _vent_bore_area / _vent_min_area, "x over"
        )
    );

  if (_gas_throttle_drop > 0) {
    _gas_valve_cv = gas_valve_cv(_gas_band[1], _gas_throttle_drop, _gas_back_pressure);

    echo(str(
      "gas throttle: a valve of Cv ", _gas_valve_cv, " passes ", _gas_band[1],
      " L/min at that drop; sold Cv should be 2-4x it so the setting sits mid-travel"
    ));
  } else {
    echo(str(
      "WARNING gas throttle: nothing for a valve to do; the line already costs ", _gas_back_pressure,
      " Pa where the pump needs ", gas_pump_back_pressure_for(_gas_free_flow, _gas_dead_head, _gas_band[1]),
      " Pa to settle at ", _gas_band[1], " L/min, so it settles at ", _gas_ceiling_flow, " instead"
    ));
  }

  echo(str(
    "gas metering: ", sparge_vvm_band[0], "-", sparge_vvm_band[1], " vvm on ", _culture_volume,
    " L is ", _gas_band[0], "-", _gas_band[1], " L/min, ",
    is_undef(gas_meter_full_scale(_gas_band[0], _gas_band[1]))
      ? "which no single rotameter scale covers at 10% readability"
      : str("so a 0-", gas_meter_full_scale(_gas_band[0], _gas_band[1]), " L/min rotameter")
  ));

  // The pump's own numbers, checked against each other
  if (gas_pump_implied_efficiency(_gas_free_flow, _gas_dead_head, air_pump_power(head_air_pump)) > 0.5)
    echo(str(
      "gas supply: ", air_pump_name(head_air_pump), "'s free flow and dead head cannot be simultaneous, together ",
      gas_pump_implied_efficiency(_gas_free_flow, _gas_dead_head, air_pump_power(head_air_pump)) * 100,
      "% of its electrical input; they are read as the ends of its curve"
    ));

  echo(str(
    "gas against the impeller: ", impeller_pumping(head_impeller_type), " pumping needs ",
    stirred_tank_gas_power_ratio(impeller_pumping(head_impeller_type)),
    "x the gas stream's power to hold its flow pattern, which at ", _baffle_rpm,
    " rpm caps aeration at ", _gas_ceiling * 60000 / _culture_volume, " vvm"
  ));

  if (sparge_design_vvm > _gas_ceiling * 60000 / _culture_volume)
    echo(str(
      "WARNING gas: ", sparge_design_vvm, " vvm is above the ", _gas_ceiling * 60000 / _culture_volume,
      " vvm at which the gas stream negates this impeller's pumping; run faster, or a radial impeller would take ",
      stirred_tank_gas_flow_ceiling(stirred_tank_power(impeller_diameter, _baffle_rpm, _impeller_po), "radial", _liquid_height)
      * 60000 / _culture_volume, " vvm at the same power"
    ));

  assert(
    steel_tube_od(sparge_riser_tube) <= head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2,
    str(
      "Sparge riser is ", steel_tube_od(sparge_riser_tube), " mm across but the air_in port bores ",
      head_port_bore_radius(head_ports_for(vessel_opening_diameter)[head_sparge_feed_port(vessel_opening_diameter)]) * 2, " mm, so it cannot pass through the lid."
    )
  );

  assert(
    _port_gap >= lid_flange_gap,
    str(_n, " ports leave ", _port_gap, " mm between flanges on a ", port_circle_radius * 2, " mm circle; ", lid_flange_gap, " mm is the least this lid keeps between two of them.")
  );

  // The wall the lid keeps between bores, as against the air between flanges.
  assert(
    _bore_gap >= lid_holes_offset,
    str(_n, " ports leave ", _bore_gap, " mm of lid between neighbouring bores; ", lid_holes_offset, " mm is the least this lid keeps.")
  );

  echo(str(
    "port interfaces: ", _uniform ? str("all ", _n, " ports on ", _iface_names[0]) : str(_iface_names),
    _uniform ? ", so one face o-ring covers the lid and any port takes any function" : ", the smallest each will take on this mouth",
    "; the worst adjacent pair measures ", _port_gap, " mm against a ", lid_flange_gap, " mm floor"
  ));

  assert(
    _mount_to_ports >= lid_holes_offset,
    str(
      "Motor mount is ", _mount_body_d, " mm across and the port flanges reach in to r ",
      port_circle_radius - bayonet_flange_radius(head_widest_interface(_ports)), ", leaving ", _mount_to_ports,
      " mm between them; ", lid_holes_offset, " mm is the least this lid keeps."
    )
  );

  echo(str(
    "eccentricity: the mount leaves ", _eccentricity_room, " mm of offset, e/T ", _eccentricity_ratio,
    " against Hall's measured 0.2, worth ", 100 * stirred_tank_eccentric_gain(_eccentricity_ratio),
    "% of the centred blend time on Karcz's up-pumping branch, to an unbaffled vessel (this one carries ",
    len(_baffle_at), " baffles); extrapolated on ", _karcz_departures
  ));

  assert(
    joint_outer_diameter / 2 >= _post_reach + lid_holes_offset,
    str(
      "Joint bores reach r ", _post_reach, " on a flange of r ", joint_outer_diameter / 2,
      "; ", lid_holes_offset, " mm is the least this lid keeps."
    )
  );

  echo(str(
    "lid gasket: cut ", _gasket_ir * 2, " x ", _gasket_or * 2, " mm from ",
    gasket_sheet_name(_gasket_sheet), " (", gasket_sheet_thickness(_gasket_sheet),
    " mm), recess ", head_gasket_depth(_gasket_sheet), " mm deep (", lid_gasket_compression * 100, "% squeeze); ",
    gasket_sheet_yield(_gasket_sheet, _gasket_or * 2), " per ",
    gasket_sheet_size(_gasket_sheet)[0], " x ", gasket_sheet_size(_gasket_sheet)[1], " mm sheet"
  ));

  // What the gasket actually touches.
  echo(str(
    "lid lip: ",
    head_lip_is_flat(lip_arc_radius)
      ? str("ground flat, ", _gasket_rim, " mm of land once both margins are taken")
      : str(
        "crowned on a ", lip_arc_radius, " mm arc standing ", 2 * lip_arc_radius - vessel_wall_thickness,
        " mm proud of the wall, so the gasket covers the lip and the crown sinks ", head_gasket_travel(_gasket_sheet), " mm into it"
      ),
    "; ", _gasket_w, " mm of gasket, ", _lip_band, " mm of contact"
  ));

  // The only load in the reactor, over the contact band. Reported: the modulus is correlated from
  // hardness (utils/elastomer.scad).
  echo(str(
    "lid gasket load: ", _lip_band, " mm of contact, ", _gasket_force, " N to hold ",
    lid_gasket_compression * 100, "% squeeze, ",
    gasket_seat_stress(
      gasket_sheet_shore_a(_gasket_sheet), _lip_band,
      gasket_sheet_thickness(_gasket_sheet), lid_gasket_compression
    ), " MPa on the glass"
  ));

  if (_gasket_w < lid_gasket_width_min)
    echo(str(
      "WARNING lid gasket: ", _gasket_w, " mm wide, under the ", lid_gasket_width_min,
      " mm this lid wants; fiddly to cut and may not stay in its recess"
    ));

  if (_gasket_rim > lid_gasket_width_max)
    echo(str(
      "lid gasket: rim offers ", _gasket_rim, " mm but the gasket is held to ", lid_gasket_width_max,
      " mm; the whole rim would cost ",
      gasket_seating_force(
        gasket_sheet_shore_a(_gasket_sheet), _gasket_rim,
        gasket_sheet_thickness(_gasket_sheet), 2 * _gasket_ir + _gasket_rim,
        lid_gasket_compression
      ), " N instead of ", _gasket_force
    ));

  echo(str(
    is_undef(_plug_ring)
      ? str("plug o-ring: no registered ring suits this mouth; ")
      : str("plug o-ring: ", oring_name(_plug_ring), " at ", _plug_stretch * 100, "% stretch; "),
    "the groove takes ID ", _ring_id, " mm down to ", _ring_id / 1.05, " mm (0-5% stretch)"
  ));

  assert(
    !is_undef(_plug_ring),
    str(
      "No registered o-ring suits a ", vessel_opening_diameter, " mm mouth. Its groove wants a ring of ",
      _ring_id / 1.05, " to ", _ring_id, " mm free ID on a ", _plug_cord_nominal,
      " mm cord; register one in scad/purchased/orings.scad."
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
    head_gasket_depth(_gasket_sheet) < lid_flange_height,
    str("Gasket recess is ", head_gasket_depth(_gasket_sheet), " mm deep in a ", lid_flange_height, " mm flange.")
  );

  assert(
    head_gasket_depth(_gasket_sheet) > 0,
    str("Gasket recess is ", head_gasket_depth(_gasket_sheet), " mm deep at ", lid_gasket_compression * 100, "% squeeze.")
  );

  // the groove is cut from the bore, so a fatter cord walks inward toward the port bores
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

  // The same band the derivation selects on, applied to whatever ring is fitted: a designated
  // ring is fit-checked, not trusted.
  assert(
    is_undef(_plug_ring) || (_plug_stretch >= 0 && _plug_stretch <= 0.05),
    str(
      "The plug o-ring ", oring_name(_plug_ring), " sits at ", _plug_stretch * 100,
      "% stretch on this mouth; the band is 0 to 5. Leave plug_oring_name at \"auto\" to pick one inside it."
    )
  );

  assert(
    _plug_fill <= 0.90,
    str("The plug o-ring fills ", _plug_fill * 100, "% of its gland; over 90 leaves the squeeze nowhere to go.")
  );

  assert(
    _plug_containment >= 0.75,
    str("Only ", _plug_containment * 100, "% of the plug o-ring's section sits inside its groove; under 75 it rolls out.")
  );

  assert(
    !is_undef(bayonet_pin_angles(head_widest_interface(_ports))),
    "head: needs bayonet-lock-scad >= 0.11.0, for pin_angles and the keying functions"
  );

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

  // ===== geometry =====

  // One tube down each of the sparger's ports, whether it carries gas or only load.
  module _sparge_tube(top, length) {
    translate([port_circle_radius, 0, top - sparge_riser_insertion])
      difference() {
        cylinder(h=length, d=steel_tube_od(sparge_riser_tube));
        translate([0, 0, -z_fight])
          cylinder(h=length + 2 * z_fight, d=steel_tube_id(sparge_riser_tube));
      }
  }

  if (render_sparge_tubes || render_all)
    color("grey") {
      rotate([0, 0, _sparge_feed_angle])
        _sparge_tube(_sparge_socket_top_feed, _sparge_feed_length);
      for (a = _sparge_support_angles)
        rotate([0, 0, a])
          _sparge_tube(_sparge_socket_top, _sparge_riser_length);
    }

  if (render_sparger || render_all)
    color(prints2_color)
      translate([
          0, 0,
          -head_floor_depth(lid_flange_height, vessel_internal_height, vessel_punt_height)
          + _sparge_ring_height,
        ])
        sparger(
          radii=_sparge_radii,
          holes=_sparge_holes,
          hole_diameter=sparge_hole_diameter,
          tube=sparge_tube(),
          bore=sparge_bore(),
          section_facets=sparge_tube_facets,
          spoke_angles=sparge_ring_count > 1 ? _sparge_support_angles : [],
          feed_angle=_sparge_feed_angle,
          feed_radius=port_circle_radius,
          feed_bore=sparge_feed_bore,
          feed_height=sparge_feed_height(),
          socket_chamfer=sparge_socket_chamfer,
          support_angles=_sparge_support_angles,
          split_angle=sparge_split_angle,
          plug_tap_radius=set_screw_tap_radius(sparge_plug_screw)
        );

  // Every lock in the lid's bores; the bore is bayonet_port_hole_fudge narrower, so they union in.
  module lid_locks() {
    for (i = [0:_n - 1])
      head_port_at(i, vessel_opening_diameter)
        bayonet_port(type=head_port_interface(_ports[i]), part="lock", panel_thickness=lid_thickness);
  }

  // The lid: the blank, pocketed and bored, with its locks - one printed piece.
  if (render_lid || render_all) {
    color(prints2_color)
      union() {
        rotate([0, 180, 0])
          lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_wall_thickness, joint_outer_diameter, post_pts, post_hole_diameter, shaft_diameter(_shaft), _build_plug_oring, _gasket_sheet, lip_arc_radius, _mount_body_d);
        lid_locks();
      }
  }

  // the locks alone, for looking at the channels the assembled lid buries
  if (render_bayonet_lock && !(render_lid || render_all)) {
    color(prints2_color)
      lid_locks();
  }

  // The culture, revolved from the same clipped profile vessel_profile_litres() integrates. The
  // profile is in the jar's own frame, so it is dropped by the whole stack.
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

  // The templates the rim gasket is cut with, on the gasket's own numbers, at its plane.
  if (render_gasket_cutter)
    translate([0, 0, -lid_flange_height - (gasket_sheet_thickness(_gasket_sheet) - head_gasket_depth(_gasket_sheet))])
      gasket_cutter(_gasket_ir * 2, _gasket_or * 2, gasket_sheet_thickness(_gasket_sheet), part=gasket_cutter_part_to_render);

  // The EPDM, each at its free size on the diameter it is installed at, so it overlaps what it
  // seals against by its squeeze.
  if (render_seals || render_all) {
    // rim gasket, standing proud of the flange by what the recess squeezes out of it
    translate([0, 0, -lid_flange_height - (gasket_sheet_thickness(_gasket_sheet) - head_gasket_depth(_gasket_sheet))])
      sheet_gasket(_gasket_ir * 2, _gasket_or * 2, gasket_sheet_thickness(_gasket_sheet));

    // plug o-ring, stretched onto its groove and reaching past the plug into the glass
    translate([0, 0, -lid_flange_height - lid_plug_height / 2])
      oring(_plug_ring, id=_ring_id);

    // port o-rings, at free size, sitting on the groove's floor
    for (i = [0:_n - 1])
      let (_pi = head_port_interface(_ports[i]))
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, bayonet_gland_depth(_pi) - bayonet_oring_cs_diameter(_pi) / 2])
            oring(bayonet_oring(_pi));

    // the bearing's rim seal; the lid runs downward from the mount face at z 0
    translate([0, 0, -head_bearing_gland_z()])
      oring(bearing_oring);

    // the rod seal on each riser, in the groove that holds it captive
    for (i = [0:_n - 1])
      if (head_port_carries_riser(_ports[i]))
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, bayonet_bore_gland_centre(tube_port_riser_oring, lid_thickness)])
            oring(tube_port_riser_oring);
  }

  // Port pin halves, in the lock's datum; port_position turns each between locked and entry.
  if (port_to_render != "" || render_tube_pinlock || render_probe_pinlock || render_thermocouple_pinlock || render_baffle_pinlock || render_all) {
    for (i = [0:_n - 1]) {
      _port = _ports[i];
      _type = head_port_type(_port);
      _port_turn = (port_position == "entry")
        ? bayonet_entry_rotation(head_port_interface(_port))
        : 0;
      // naming one port selects it, whatever the type flags say
      _show = (port_to_render != "")
        ? port_to_render == head_port_export_name(_ports, i)
        : render_all || (_type == "tube" && render_tube_pinlock) || (_type == "probe" && render_probe_pinlock) || (_type == "thermocouple" && render_thermocouple_pinlock) || (_type == "baffle" && render_baffle_pinlock);

      if (_show)
        color(prints1_color)
          head_port_at(i, vessel_opening_diameter)
            rotate([0, 0, _port_turn])
              head_port(_port, lid_thickness, _baffle_width, _baffle_length, _baffle_segments, _do_tilt);
    }
  }

  // The probes, placed off the same numbers the port is built from. atlas_probe() draws tip-up
  // from its neck, so it is flipped and lifted by its neck height to seat the body.
  if (render_probes || render_all)
    for (i = [for (j = [0:_n - 1]) if (head_port_type(_ports[j]) == "probe") j])
      let (_p = head_port_probe(_ports[i]))
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, -head_lid_thickness(lid_flange_height)])
            rotate([0, -head_probe_tilt(_ports[i], _do_tilt), 0])
              translate([
                0, 0,
                atlas_probe_neck_height(_p)
                - bayonet_probe_port_collet_drop(_p, probe_port_transition_length),
              ])
                rotate([180, 0, 0])
                  atlas_probe(_p);

  // motor and shaft
  if (render_motor || render_all) {

    // Motor, flipped so it hangs off the top of the mount with the gearbox output face flush on it.
    translate([0, 0, motor_mount_height + dc_motor_length(_motor) + gearbox_length(head_gearbox)])
      rotate([0, 180, 0])
        dc_motor(_motor);
  }

  // motor mount; the module does not color itself, so all three telescoping parts take this one
  if (render_motor_mount || render_all) {
    color(prints1_color)
      motor_mount(
        height=motor_mount_height,
        body_diameter=_mount_body_d,
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

  // one placement for both halves of the joint, so a screw cannot land anywhere but in its insert
  module motor_mount_fastener_at() {
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([head_motor_mount_screw_radius(_mount_body_d), 0, 0])
          children();
  }

  // Separate flags: the insert stays in the lid, the screw comes out with the mount.
  if (render_motor_mount_inserts || render_all)
    motor_mount_fastener_at()
      insert(motor_mount_base_insert);

  if (render_motor_mount_screws || render_all)
    motor_mount_fastener_at()
      translate([0, 0, _mm_grip])
        screw(motor_mount_base_screw, screw_length(motor_mount_base_screw, _mm_grip, 0, insert=motor_mount_base_insert));

  // The bearing in its pocket; ball_bearing() draws itself centred.
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

  // Radial tap holes through the collar, at the screw's tap radius, opening into the bore. In the
  // collar rather than the hub because above the blades there are no fins at any angle.
  module head_impeller_set_screw_holes() {
    _r = set_screw_tap_radius(impeller_set_screw) + impeller_set_screw_allow;
    translate([0, 0, impeller_height / 2 + impeller_collar_height / 2])
      for (a = impeller_set_screw_at)
        rotate([0, 0, a])
          rotate([0, 90, 0])
            cylinder(r=_r, h=impeller_hub_radius + z_fight, $fn=32);
  }

  // The screws in those holes, placed from the same numbers, socket outward.
  module head_impeller_set_screws() {
    translate([0, 0, impeller_height / 2 + impeller_collar_height / 2])
      for (a = impeller_set_screw_at)
        rotate([0, 0, a])
          translate([impeller_hub_radius, 0, 0])
            rotate([0, 90, 0])
              screw(set_screw_screw(impeller_set_screw), set_screw_length(impeller_set_screw));
  }

  // The printed part and its screws at one impeller's position, so the mirror below catches both.
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
        // top ring tying the blade tips, inboard of the radius; off by default
        if (impeller_tip_ring)
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

      // Mirrored, not turned over, which is what makes the pair oppose each other.
      if (impeller_to_render != "lower")
        translate([0, 0, impeller_spacing])
          mirror([0, 1, 0])
            head_impeller_assembly();
    }
  }
}

// ----- standalone preview -----
// What the assembly chooses; everything below follows from them the way the assembly derives it.
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
  vessel=reactor_vessel,
  lid_flange_height=_preview_flange_height,
  joint_outer_diameter=frame_outer_diameter(vessel_diameter(reactor_vessel), _preview_wall_thickness),
  post_pts=_preview_post_pts,
  post_hole_diameter=frame_rod_hole_diameter()
);
