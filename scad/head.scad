/**
 * @file head.scad
 * @brief Head subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <utils/bolt_pattern.scad>;

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

include <custom/bayonet_interfaces.scad>;

include <NopSCADlib/core.scad>;
use <NopSCADlib/vitamins/shaft_coupling.scad>;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// -----

// Overrides all other render flags
render_all = true; // render all components
render_lid = false;

render_motor = false;
render_motor_mount = false;
motor_mount_part_to_render = "all"; // ["all", "base_plate", "face_plate", "middle_stand"]
render_shaft_coupler = false;
render_ext_shaft = false;
render_impeller = false;
render_bayonet_lock = false;
render_tube_pinlock = false;
render_thermocouple_pinlock = false;
render_probe_pinlock = false;
render_baffle_pinlock = false;

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
// number of holes for the first holes set
lid_holes_n = 12;
// minimum wall the lid keeps around a port bore, both to the plug's edge and to its neighbours
lid_holes_offset = 2.0;
// allowance for the bearing and shaft holes
bearing_hole_allowance = 0.2;

/* [Bearing Parameters] */

// diameter of the bearing (outer casing)
bearing_diameter = 22.6;
// height of the bearing
bearing_height = 7.5;

/* [Motor & Gearbox Selection] */

// the registered motor type; the gearbox is taken from the motor's registration
// (dc_motor_gearbox), and all motor/gearbox dimensions are derived from these via
// the accessor functions rather than re-entered here
head_motor = motor_36gp_3530_5p18;

/* [Shaft Parameters] */

// The distance between the bottom of the jar (punt) and the bottom of the shaft
shaft_jar_punt_clearance = 5;
// length of the shaft for the impeller
shaft_length = 400;
// diameter of the shaft
shaft_diameter = 8.0;
// adjust distance between the motor and the shaft coupling
shaft_shaft_coupling_offset = 0; // can be positive or negative
// reference, length, diameter, input diameter, output diameter, flex?
shaft_coupler_8x8_rigid = ["SC_8x8_rigid", 25, 12.5, 8, 8, false];

/* [Motor Mount Parameters] */

// outer diameter of the mount body
motor_mount_body_diameter = 56;
// wall thickness of the mount body; also sets the flange and raised face heights
motor_mount_wall_thickness = 10;
// clearance between the telescoping parts, for printed fit
motor_mount_coupling_allowance = 0.2;
// number of facets for the mount body (must be divisible by 4)
motor_mount_facets = 20;

/* [Impeller Parameters] */

/** Design guidelines for impeller:
 * - The impeller radius (radius) should be 1/3 to 1/2 of the tank radius for bioreactors
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

// impeller diameter to tank diameter ratio
impeller_impeller_vessel_outer_diameter_factor = 0.45;
// impeller height
impeller_height = 60;
// number of fins
impeller_n_fins = 4;
// twist angle of each fin
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
_preview_bolt_circle = 238.8; // the frame's rod circle for jar_10L_220x305
_preview_post_pts = bolt_pattern_pts(bolt_post_count(4, 8, _preview_bolt_circle, 8, 0.5), _preview_bolt_circle);

// The lid is one part in two sections: a flange landing on the vessel rim that carries the joint,
// and a plug entering the mouth that carries the ports. Both sections are bored for the ports, so
// the ring is set by how far out a bore can sit and still leave lid_holes_offset to the plug's
// edge. Derived here rather than in each consumer, so the holes and the couplings cannot drift.
function head_lid_thickness(lid_flange_height) = lid_flange_height + lid_plug_height;
function head_lid_plug_diameter(vessel_opening_diameter) = vessel_opening_diameter - lid_radial_allowance;
function head_port_circle_radius(vessel_opening_diameter) =
  head_lid_plug_diameter(vessel_opening_diameter) / 2 - bayonet_port_hole_radius(head_bayonet) - lid_holes_offset;

// Place children at port i, on the ring and turned to face out.
module head_port_at(i, vessel_opening_diameter) {
  rotate([0, 0, i * 360 / lid_holes_n])
    translate([head_port_circle_radius(vessel_opening_diameter), 0, 0])
      children();
}

module lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, frame_wall_thickness, post_pts, post_hole_diameter) {

  _thickness = head_lid_thickness(lid_flange_height);

  // the rods run through the flange alongside the bolts, so every post on the circle is bored
  bolt_pattern_bores(post_pts, post_hole_diameter, lid_flange_height + z_fight, -z_fight / 2)
    difference() {
      // flange, then the plug that enters the vessel opening
      union() {
        cylinder(d=vessel_outer_diameter + frame_wall_thickness, h=lid_flange_height);
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
            cylinder(d=bearing_diameter + bearing_hole_allowance, h=bearing_height + z_fight);
        }

      // Motor mount base holes
      // #for (i = [0:3])
      //   rotate([0, 0, i * 90])
      //     translate([motor_mount_screw_distance, 0, -z_fight / 2])
      //       cylinder(d=gearbox_screw_diameter(head_motor), h=lid_flange_height + z_fight);

      // cut out the entry holes for the probes and tubes; the port sizes its own hole so the
      // lock keeps a bearing land against the lid's underside
      for (i = [0:lid_holes_n - 1])
        head_port_at(i, vessel_opening_diameter)
          translate([0, 0, _thickness / 2])
            cylinder(r=bayonet_port_hole_radius(head_bayonet), h=_thickness + z_fight, center=true);
    }
}

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

module head(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_internal_height, frame_wall_thickness, post_pts, post_hole_diameter) {

  // the gearbox carried by the selected motor - single source for gearbox dims
  head_gearbox = dc_motor_gearbox(head_motor);

  // Impeller Driven Parameters
  // diameter of the impeller (see TODO.md: scaled off the outer diameter, unguarded)
  impeller_diameter = vessel_outer_diameter * impeller_impeller_vessel_outer_diameter_factor;
  impeller_radius = impeller_diameter / 2; // radius of the impeller

  // radius of the shaft hole in the impeller
  impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_allow) / 2;

  impeller_spacing = impeller_diameter * impeller_spacing_factor;

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

  // Motor and shaft driven parameters
  shaft_protrusion = shaft_length - (vessel_internal_height - shaft_jar_punt_clearance);

  // the height that the motor coupling assembly requires
  motor_mount_height = gearbox_output_shaft_length(head_gearbox) + shaft_protrusion + shaft_shaft_coupling_offset;
  echo("motor mount height: ", motor_mount_height / 10, " cm");

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

  // the ring is sized against the plug's edge, so what it does not settle is whether that many
  // bores still clear each other on it
  _port_gap = 2 * port_circle_radius * sin(180 / lid_holes_n) - bayonet_port_hole_radius(head_bayonet) * 2;

  assert(
    _port_gap >= lid_holes_offset,
    str(lid_holes_n, " ports leave ", _port_gap, " mm between bores on a ", port_circle_radius * 2, " mm circle; ", lid_holes_offset, " mm is the least this lid keeps.")
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
          lid_pocketed(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, frame_wall_thickness, post_pts, post_hole_diameter);
        lid_locks();
      }
  }

  // the locks alone, for looking at the channels the assembled lid buries
  if (render_bayonet_lock && !(render_lid || render_all)) {
    color(prints2_color)
      lid_locks();
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
        shaft_diameter=shaft_diameter,
        motor_faceplate_screws_separation=gearbox_faceplate_screws_cdist(head_gearbox),
        motor_boss_diameter=gearbox_out_boss(head_gearbox)[0],
        coupling_allowance=motor_mount_coupling_allowance,
        facets=motor_mount_facets,
        part_render=motor_mount_part_to_render
      );
  }

  // shaft coupling
  if (render_shaft_coupler || render_all) {

    translate(
      [0, 0, shaft_protrusion + shaft_shaft_coupling_offset / 2]
    )

      shaft_coupling(type=shaft_coupler_8x8_rigid, colour="MediumBlue");
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

head(
  lid_flange_height=8,
  vessel_outer_diameter=vessel_diameter(reactor_vessel),
  vessel_opening_diameter=vessel_opening_diameter(reactor_vessel),
  vessel_internal_height=vessel_internal_height(reactor_vessel),
  frame_wall_thickness=37,
  post_pts=_preview_post_pts,
  post_hole_diameter=9.2
);
