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
 * Cross-coupling:
 *
 * - vessel  <->  frame:     1) Outer diameter of vessel, and 
 *                           2) height of vessel.
 *
 * - vessel  <->  head:      1) Outer diameter of vessel, 
 *                           2) opening diameter of vessel, and 
 *                           3) internal height of vessel.
 *
 * - head    <->  frame:     1) lid_flange_height, 
 *                              note: the frame assumes the head 
 *                              presents a flat circular face the 
 *                              same diameter as the vessel, with
 *                              an edge at least the thickness of 
 *                              the vessel wall.
 *
 * From this we can determine which parameters much be passed from the top-level assembly:
 * - vessel:
 *   - vessel height
 *   - vessel diameter
 *   - vessel opening diameter
 * - head:
 *   - chosen lid flange height
 *   - vessel opening diameter
 *   - vessel outer diameter
 *   - vessel internal height
 * - frame:
 *   - vessel height
 *   - vessel diameter
 *   - lid flange height
 */

include <purchased/vessels.scad>;
include <purchased/strip_lights.scad>;

use <utils/bolt_pattern.scad>;

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

cross_section_active = true;

/* [Vessel Selection] */

// the registered vessel; every vessel dimension the head and frame are built against
// is read back out of this registration via the accessor functions (see purchased/vessel.scad)
reactor_vessel = jar_10L_220x305; // [generic_vessel, jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251]

/* [Light Strip Selection] */
// This should be made to be driven by the vessel for whatever is optimal; future TODO.

reactor_lights = rwntao_13in;

/* [Head Parameters - Coupling] */

// height of the lid flange, which is the distance 
// from the top of the vessel to the top of the lid
lid_flange_height = 8;

frame_wall_thickness = 37; // thickness of the frame walls, which is the distance from the outer edge of the vessel to the outer edge of the frame; also used in lid

/* [Head to Frame Joint] */

// tie rods running the assembly; they are also posts on the bolt circle, so the lid is bored for them
n_rods = 4;
// the fastener clamping the lid flange to the top base, its nut and clearance following from the type
joint_bolt = M8_hex_screw;
// gasket factor m for the lid seal, ASME VIII-1 Table 2-5.1: 0 o-ring, 0.5 silicone under 75A, 1.0 over
lid_gasket_factor = 0.5;

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
    lights_length=strip_light_length(reactor_lights),
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
      frame_wall_thickness=frame_wall_thickness,
      post_pts=bolt_pattern_pts(joint_posts, joint_bolt_circle),
      post_hole_diameter=joint_hole_diameter
    );
}
