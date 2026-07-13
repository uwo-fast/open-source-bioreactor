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
reactor_vessel = jar_10L_220x305;

/* [Head Parameters - Coupling] */

// height of the lid flange, which is the distance 
// from the top of the vessel to the top of the lid
lid_flange_height = 8;

module dummy() {
  // stop the customizer detection from here onwards
}

// vessel
if (render_vessel || render_all) {
  vessel(reactor_vessel, angle=(cross_section_active ? 180 : 360));
}

if (render_frame || render_all) {
  frame(
    vessel_height=vessel_height(reactor_vessel),
    vessel_outer_diameter=vessel_diameter(reactor_vessel)
  );
}

if (render_head || render_all) {
  translate([0, 0, vessel_height(reactor_vessel) + lid_flange_height])
    head(
      lid_flange_height=lid_flange_height,
      vessel_outer_diameter=vessel_diameter(reactor_vessel),
      vessel_opening_diameter=vessel_opening_diameter(reactor_vessel),
      vessel_internal_height=vessel_internal_height(reactor_vessel)
    );
}
