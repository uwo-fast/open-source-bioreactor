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
 * Preference or customization parameters that are specific to a single component are scoped to their respective
 * subassembly files (e.g., vessel.scad, head.scad, frame.scad) to maintain modularity and separation of concerns.
 * The two internal lib directories (purchased and custom) are the actual source components, defined as fully
 * parameterized modules that are then used in the subassembly files.
 */

use <vessel.scad>;
use <head.scad>;
use <frame.scad>;

// This will be something to the effect of:
/*
vessel_total_height = ...;
vessel_body_diameter = ...;
vessel_wall_thickness = ...;
vessel_neck_height = ...;
vessel_neck_diameter = ...;



*/


module dummy() {
  // stop the customizer detection from here onwards
}
