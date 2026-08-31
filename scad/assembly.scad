/**
 * @file assembly.scad
 * @brief Assembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * This file contains the assembly for the open-source-bioreactor project.
 *
 * The bioreactor is divided into three subassemblies:
 * - Vessel: Glass jar.
 * - Head: Closure with flange, rotational drive system, and I/O and instrumentation ports.
 * - Frame: Base plate, closure retaining plate with frame tie points, ribs, threaded rods, spacers, and nuts.
 *
 * Project structure:
 * - assembly.scad: This file, which contains the assembly of the bioreactor.
 *   - frame.scad: Contains the module for the frame subassembly of the bioreactor.
 *   - head.scad: Contains the module for the head subassembly of the bioreactor.
 *
 * The vessel is a purchased part rather than a designed subassembly, so it lives with the
 * other purchased components: purchased/vessel.scad holds the model and its accessors, and
 * purchased/vessels.scad registers the jars. This file selects one and reads the coupling
 * dimensions back out of it through those accessors.
 *
 * This is an interface-based design, where each component is designed to fit together based on defined interfaces. 
 * Therefore, this file contains only parameters that cross-couple between components, such as the diameter of the 
 * vessel and the corresponding dimensions of the frame and head.
 *
 * Preference or customization parameters that are specific to a single component are scoped to their respective
 * subassembly files (e.g., head.scad, frame.scad) to maintain modularity and separation of concerns.
 *
 * The two internal lib directories (purchased and custom) are the actual source components, defined as fully
 * parameterized modules that are then used in the subassembly files.
 *
 * The _archive directory contains older versions of the components that are no longer in use, but are kept for reference and potential future use.
 * The _shelf directory contains components that are not currently in use, but may be used in the future or are kept for reference.
 *
 * Cross-coupling. Every row is something two components must agree on, and every one of them is
 * derived once here and handed down, never derived twice:
 *
 * - vessel -> frame:   outer diameter, height.
 *
 * - vessel -> head:    outer diameter, opening diameter, wall thickness, internal height.
 *                      The wall thickness is what the rim gasket is cut to, so it arrived with
 *                      the seals and is not optional.
 *
 * - light  -> frame:   the registered strip light itself, not its length. The frame pockets it,
 *                      slots its cord and sizes its base floor from it, so it needs the row.
 *
 * - head  <-> frame:   the joint, which is one thing in four parts:
 *                        lid_flange_height        chosen here, both build to it
 *                        joint bolt circle        frame_bolt_circle_diameter(), the rod circle
 *                        joint bore               frame_rod_hole_diameter(), the rod's clearance,
 *                                                 which the bolt positions share deliberately
 *                        joint outer diameter     frame_outer_diameter(), the face the lid flange
 *                                                 closes and the frame's bases close
 *                      and the post pattern derived from the circle, which both are bored from.
 *
 * - head   -> here:    head_gasket_factor(). The head owns the registered gasket sheet, and the
 *                      sheet's hardness is what sets the joint's bolt count, so the count is read
 *                      back out of the head rather than entered here.
 *
 * The three frame_* accessors are read back out of frame.scad the same way the vessel's dimensions
 * are read out of its registration. head.scad calls them too, but only in its standalone preview,
 * which has nobody to hand it a joint.
 *
 * What each module is actually passed, which is the signatures in head.scad and frame.scad:
 * - vessel(type, angle)
 * - frame:  vessel_height, vessel_outer_diameter, vessel_corner_radius_base, light,
 *           wall_thickness, lid_flange_height, n_rods, bolt_pts, bolt_screw,
 *           collapse_spacer_z_allow
 * - head:   lid_flange_height, vessel_outer_diameter, vessel_opening_diameter,
 *           vessel_wall_thickness, vessel_internal_height, vessel_punt_height,
 *           joint_outer_diameter, post_pts, post_hole_diameter
 *
 * The frame no longer assumes anything about the face the head presents: it is handed
 * joint_outer_diameter and the head builds its flange to exactly that. That the bores land on the
 * flange with wall left around them is checked in head(), not assumed.
 */

include <purchased/vessels.scad>;
include <purchased/strip_lights.scad>;
include <purchased/printers.scad>;

use <utils/bolt_pattern.scad>;
use <utils/gasket_load.scad>;

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/screws.scad>; // M8_hex_screw type

use <head.scad>;
use <frame.scad>;

/* [Part Render Selection] */

render_vessel = true;
render_head = false;
render_frame = false;
render_all = true;

/* [Rendering Parameters] */

// Every other entry file sets this and assembly.scad was the one that did not, which is not a
// quality preference here but a correctness one. $fn is ZERO unless something assigns it, and a
// module reached through `use` may be handed the caller's - so from this file the whole assembly
// was drawn to $fa/$fs instead of the 64/128 that head.scad and frame.scad ask for, and anything
// dividing by $fn got a division by zero. sparge_ring did.
$fn = $preview ? 64 : 128;

cross_section_active = true;

/* [Vessel Selection] */

// the registered vessel; every vessel dimension the head and frame are built against
// is read back out of this registration via the accessor functions (see purchased/vessel.scad)
// Which jar this build is for, chosen BY NAME so a customizer parameter set can carry it - a .json
// holds values, not references, so it cannot name the variable. `just json` writes one set per
// registered vessel from this same registry.
reactor_vessel_name = "jar_10L_220x305"; // [generic, jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]
reactor_vessel = vessel_by_name(reactor_vessel_name);

assert(
  !is_undef(reactor_vessel),
  str("No registered vessel is named \"", reactor_vessel_name, "\". See scad/purchased/vessels.scad.")
);

/* [Light Strip Selection] */
// This should be made to be driven by the vessel for whatever is optimal; future TODO.

// Which strip light this build carries. undef derives it from the culture the vessel holds: the
// shortest registered light that still covers the liquid. A longer one is not free - the base drops
// by whatever the light overhangs the jar, which put 152 mm of empty base under a 197 mm vessel.
reactor_lights = undef;

/* [Head Parameters - Coupling] */

// height of the lid flange, which is the distance 
// from the top of the vessel to the top of the lid
lid_flange_height = 8;

// wall the frame carries outboard of its jar pocket. The lid flange closes on the same outer face,
// so it is handed frame_outer_diameter() rather than being given this and rebuilding it
frame_wall_thickness = 37;

/* [Head to Frame Joint] */

// tie rods running the assembly; they are also posts on the bolt circle, so the lid is bored for them
n_rods = 4;
// The fastener clamping the lid flange to the top base, its nut and clearance following from the
// type. M8 is the CAP, not just the current pick: NopSCADlib stops there, and nothing in this design
// asks for more. The joint's only load is seating the lid gasket, which the echo below reports - a
// few hundred newtons a post on the jars that build, about 1.7 kN on the widest gasket in the
// family. An M8 in the softest common class carries that many times over, so going bigger would mean
// hand-writing screw and nut rows for a size no vessel needs. If a jar ever does need more, the
// gasket width is the first thing to look at, not the bolt - see head.scad's lid_gasket_width_max.
joint_bolt = M8_hex_screw;
// gasket factor m for the lid seal, read back from the registered sheet the head is built around
// rather than entered here - a harder sheet wants more bolts and nothing else would say so
lid_gasket_factor = head_gasket_factor();

_reactor_light = is_undef(reactor_lights)
  ? strip_light_for(head_liquid_height(vessel_internal_height(reactor_vessel), vessel_inner_profile(reactor_vessel)))
  : reactor_lights;

assert(
  !is_undef(_reactor_light),
  "No strip light is registered, so nothing can light the vessel. See scad/purchased/strip_lights.scad."
);

module dummy() {
  // stop the customizer detection from here onwards
}

// the joint is derived once here, since the top base and the lid flange have to be bored from the
// same pattern or the holes will not line up; the lid flange is the thinner of the two, so it governs
joint_bolt_circle = frame_bolt_circle_diameter(vessel_diameter(reactor_vessel));
// Every post is bored to the rod's clearance, bolts included. The rods are what needs it - four of
// them thread through three plates at once - and the plug locates the lid radially, not the bolts,
// so the bolt positions are deliberately loose rather than fitted to the screw.
joint_hole_diameter = frame_rod_hole_diameter();
// The face the joint presents, which the head builds its flange to exactly. Named here rather than
// computed inline at the call below, because the printer report further down needs the same number
// and two expressions of one diameter is how they drift.
joint_outer_diameter = frame_outer_diameter(vessel_diameter(reactor_vessel), frame_wall_thickness);
joint_posts = bolt_post_count(n_rods, screw_radius(joint_bolt) * 2, joint_bolt_circle, lid_flange_height, lid_gasket_factor);

assert(
  bolt_post_spacing(joint_posts, joint_bolt_circle) >= screw_radius(joint_bolt) * 5, // 2.5x nominal, enough to get a wrench in
  str("Bolt spacing of ", bolt_post_spacing(joint_posts, joint_bolt_circle), " mm is too tight to get a wrench on.")
);

// Loose is a choice; too small is not. The bore never reads the screw, so tightening the rod's
// allowance or thinning the rod takes the bolt holes down with it, silently.
assert(
  joint_hole_diameter >= screw_clearance_radius(joint_bolt) * 2,
  str(
    "The joint is bored ", joint_hole_diameter, " mm from the rod's allowance, but an M",
    screw_radius(joint_bolt) * 2, " bolt needs ", screw_clearance_radius(joint_bolt) * 2, " mm to pass."
  )
);

echo("joint: ", joint_posts, " posts at ", bolt_post_spacing(joint_posts, joint_bolt_circle), " mm on a ", joint_bolt_circle, " mm circle");

// The rod and the bolt are set in different files and neither reads the other, yet every post is
// bored to the ROD's clearance - so moving the rod up a size leaves the bolts rattling in their own
// holes, and moving it down is caught only by the assert above. Same size for both is the sane
// default; this says so rather than enforcing it, because a deliberately loose bolt in a rod-sized
// bore is what this joint already does on purpose.
_rod_d = frame_rod_diameter();
_bolt_d = screw_radius(joint_bolt) * 2;
if (_rod_d != _bolt_d)
  echo(str(
    "WARNING joint: M", _rod_d, " rod but M", _bolt_d, " bolts, and every post is bored ",
    joint_hole_diameter, " mm from the rod. That leaves the bolts ",
    joint_hole_diameter - screw_clearance_radius(joint_bolt) * 2,
    " mm of slop where a matching bolt would have ",
    joint_hole_diameter - _rod_d - (screw_clearance_radius(joint_bolt) * 2 - _bolt_d),
    " mm. Suggest running the bolts at M", _rod_d, " to match."
  ));

// What the bolts are actually holding. The head owns the gasket so it owns the force; the count is
// this file's, so the division happens here. Reported only - see utils/gasket_load.scad.
_seating_force = head_gasket_seating_force(
  vessel_opening_diameter(reactor_vessel), vessel_thickness(reactor_vessel)
);
echo(str(
  "joint load: ", _seating_force, " N of gasket seating over ", joint_posts, " posts = ",
  _seating_force / joint_posts, " N each, on M", _bolt_d, " bolts and M", _rod_d, " rods"
));

// What a builder actually does at the bench, which is not the line above. Force reaches a fastener
// through a friction coefficient nobody can measure here - 18-8 galls, so the 0.20 to 0.30 an
// unlubricated nut spans makes one preload a 40% band of torque - and the figure is a fortieth of
// this bolt's own rated torque anyway, because what limits this joint is the GLASS. The turn is
// geometry instead: the gasket's travel over the thread's pitch, no modulus and no friction in it.
_joint_pitch = bolt_coarse_pitch(_bolt_d);

assert(
  !is_undef(_joint_pitch),
  str("No coarse pitch is listed for an M", _bolt_d, " joint bolt - see utils/bolt_pattern.scad.")
);

echo(str(
  "joint tightening: ", gasket_seating_turn(head_gasket_travel(), _joint_pitch),
  " deg past snug on each of the ", joint_posts, " nuts, all of which sit on top of the lid - ",
  head_gasket_travel(), " mm of gasket travel on a ", _joint_pitch,
  " mm pitch. The printed flange takes a little more and then creeps, so go back to them."
));

// The assembled reactor's envelope, for anything that has to make room for one - cart.scad is the
// only such thing today. Composed here because the reactor is what this file assembles: the frame
// sets the width and the depth below the jar, the head's drive stack sets the top. Measured
// against a mesh export of the whole assembly at 257.400 x 571.250 mm.
function reactor_envelope_diameter() = joint_outer_diameter; // the flange circle IS the envelope
function reactor_envelope_height() =
  frame_floor_depth(vessel_height(reactor_vessel), _reactor_light)
  + vessel_height(reactor_vessel) + lid_flange_height
  + head_stack_height(lid_flange_height, vessel_internal_height(reactor_vessel));

echo("reactor envelope: ", reactor_envelope_diameter(), " mm dia x ", reactor_envelope_height(), " mm tall");

// WHAT CAN PRINT THIS, reported rather than designed to.
//
// The lid and the frame's two bases are all one disc of the joint's outer diameter, and they are
// the widest printed parts in the build by a long way - nothing else comes near, so this one number
// decides what a builder has to own. It is reported here because this is the only file that sees
// both halves: head.scad cannot see the frame's bases, which is exactly how a per-part export came
// to say the reactor fitted a 256 mm machine while two 257.40 mm parts sat in the other file.
//
// A DISC, so min(x, y) is the test and printer_fits() is the wrong one - that allows a rectangle
// the 90 degree turn a circle does not get. It is why a 250 x 220 bed is ruled out by its 220.
//
// Height is not checked here and does not need to be: every registered printer has at least 250 mm
// of Z, against a tallest piece of about 163. `just export-parts` measures each part and reports
// its fit, which is the fine-grained version of this.
_widest_printed = joint_outer_diameter;
_printers_fitting = [for (p = printers) if (printer_max_disc(p) >= _widest_printed) printer_name(p)];

echo(str(
  "printers: the widest printed part is a ", _widest_printed, " mm disc - the lid, and the frame's ",
  "base and top base - so this build wants a bed that takes a disc that wide. Registered printers ",
  "that do: ", _printers_fitting
));

if (len(_printers_fitting) == 0)
  echo(str(
    "WARNING printers: no registered printer takes a ", _widest_printed,
    " mm disc, so nothing in scad/purchased/printers.scad can build this reactor. Either the joint ",
    "has grown or the registry is short a machine."
  ));

// The vessel sections itself by revolving through 180 degrees, which keeps the +y half. Cut the
// head to that same half so the two read as one section: almost everything the head seals with
// is buried - the o-ring glands, the bayonet channels, the gasket recess - and a section is the
// only way to look at them in place.
// Sectioning is for looking, never for making: a mesh export is how parts are taken out of this
// file, and a part exported half-cut would be silently wrong. $preview is false in exactly that
// case, so the section is confined to it.
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

// vessel
if (render_vessel || render_all) {
  vessel(reactor_vessel, angle=(_section_active ? 180 : 360));
}

if (render_frame || render_all) {
  frame(
    vessel_height=vessel_height(reactor_vessel),
    vessel_outer_diameter=vessel_diameter(reactor_vessel),
    vessel_corner_radius_base=vessel_corner_radius_base(reactor_vessel),
    light=_reactor_light,
    wall_thickness=frame_wall_thickness,
    lid_flange_height=lid_flange_height,
    n_rods=n_rods,
    bolt_screw=joint_bolt,
    bolt_pts=bolt_pattern_pts(joint_posts, joint_bolt_circle, n_rods),
    collapse_spacer_z_allow=true
  );
}

if (render_head || render_all) {
  cross_section(_section_active)
  translate([0, 0, vessel_height(reactor_vessel) + lid_flange_height])
    head(
      lid_flange_height=lid_flange_height,
      vessel_outer_diameter=vessel_diameter(reactor_vessel),
      vessel_opening_diameter=vessel_opening_diameter(reactor_vessel),
      vessel_wall_thickness=vessel_thickness(reactor_vessel),
      vessel_internal_height=vessel_internal_height(reactor_vessel),
      vessel_punt_height=vessel_punt_height(reactor_vessel),
      joint_outer_diameter=joint_outer_diameter,
      post_pts=bolt_pattern_pts(joint_posts, joint_bolt_circle),
      post_hole_diameter=joint_hole_diameter,
      vessel_profile=vessel_inner_profile(reactor_vessel)
    );
}
