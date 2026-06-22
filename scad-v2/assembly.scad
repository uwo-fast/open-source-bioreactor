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
 *   - vessel.scad: Contains the module for the vessel subassembly of the bioreactor.
 *
 * This is an interface-based design, where each component is designed to fit together based on defined interfaces. 
 * Therefore, this file contains only parameters that cross-couple between components, such as the diameter of the 
 * vessel and the corresponding dimensions of the frame and head.
 *
 * Preference or customization parameters that are specific to a single component are scoped to their respective
 * subassembly files (e.g., vessel.scad, head.scad, frame.scad) to maintain modularity and separation of concerns.
 *
 * The two internal lib directories (purchased and custom) are the actual source components, defined as fully
 * parameterized modules that are then used in the subassembly files.
 *
 * The _archive directory contains older versions of the components that are no longer in use, but are kept for reference and potential future use.
 * The _shelf directory contains components that are not currently in use, but may be used in the future or are kept for reference.
 *
 * Cross-coupling:
 *
 * - vessel  <->  frame:     1) Outer diameter, and 2) height of the vessel.
 *
 * - vessel  <->  head:      1) Outer diameter, and 2) opening diameter of the vessel.
 *
 * - head    <->  frame:     1) lid_flange_height, note: the frame assumes the head presents a flat  
 *                           circular face the same diameter as the vessel, with
 *                           an edge at least the thickness of the vessel wall.
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
 * - frame:
 *   - vessel height
 *   - vessel diameter
 *   - lid flange height
 */

use <vessel.scad>;
use <head.scad>;
use <frame.scad>;

/* [Part Render Selection] */

render_vessel = true;
render_head = false;
render_frame = false;
render_all = true;

/* [Rendering Parameters] */

cross_section_active = true;

/* [Vessel Parameters - Coupling] */

// height of the vessel
vessel_height = 305;
// diameter of the vessel
vessel_diameter = 220;
// diameter of the vessel opening — driven, derived in the section below from
// vessel_opening_diameter

/* [Vessel Parameters - Details] */

// thickness of the vessel
vessel_thickness = 5;
// height of the neck
vessel_neck_height = 25;
// radius of the shoulder-to-body transition
vessel_upper_corner_radius = 25;
// radius of the body-to-base transition
vessel_lower_corner_radius = 12.5;
// radius of the shoulder-to-neck transition
vessel_neck_corner_radius = 13.5;
// height of the punt from the bottom of the vessel
vessel_punt_height = 5;
// width/diameter of the punt
vessel_punt_width = 30;
// radius of the rim
vessel_rim_rad = 2;

module dummy() {
  // stop the customizer detection from here onwards
}

// Driven Parameters
// diameter of the vessel opening, derived from the vessel profile.
// Cross-coupled to the head (sets the lid plug / inner diameter).
vessel_opening_diameter = vessel_opening_diameter(
  diameter=vessel_diameter,
  corner_radius=vessel_upper_corner_radius,
  neck_corner_radius=vessel_neck_corner_radius
);

// vessel
if (render_vessel || render_all) {
  vessel(
    height=vessel_height,
    diameter=vessel_diameter,
    thickness=vessel_thickness,
    corner_radius=vessel_upper_corner_radius,
    corner_radius_base=vessel_lower_corner_radius,
    neck=vessel_neck_height,
    neck_corner_radius=vessel_neck_corner_radius,
    punt_height=vessel_punt_height,
    punt_width=vessel_punt_width,
    rim_rad=vessel_rim_rad,
    angle=(cross_section_active ? 180 : 360)
  );
}

if (render_frame || render_all) {
  frame(jar_height=vessel_height, jar_diameter=vessel_diameter);
}
