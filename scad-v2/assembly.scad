/**
 * @file assembly.scad
 * @brief Assembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * This file contains the assembly for the open-source-bioreactor project.
 *
 * Project structure:
 * - assembly.scad: This file, which contains the assembly of the bioreactor.
 *   - frame.scad: Contains the module for the frame component of the bioreactor.
 *   - head.scad: Contains the module for the head component of the bioreactor.
 *   - vessel.scad: Contains the module for the vessel component of the bioreactor.
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
 */

use <vessel.scad>;
use <head.scad>;
use <frame.scad>;

/* [Part Render Selection] */

render_vessel = true;
render_head = false;
render_frame = false;
render_all = false;

/* [Rendering Parameters] */

vessel_x_sec = false;

/* [Vessel Parameters - Coupling] */

// height of the vessel
vessel_height = 305;
// diameter of the vessel
vessel_diameter = 220;
// thickness of the vessel
vessel_thickness = 5;
// height of the neck
vessel_neck_height = 25;

/* [Vessel Parameters - Customization] */

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
    angle=(vessel_x_sec ? 180 : 360)
  );
}
