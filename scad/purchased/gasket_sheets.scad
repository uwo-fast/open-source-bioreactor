// parameters for physical realization of sheet gasket stock
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Thickness sets the lid's recess depth and hardness sets the gasket factor the bolt count comes
// from. Sheet size is carried because a 12 in square yields one jar_10L gasket, not two.

//                       ["name"           material  thickness  shore_a  [sheet_w, sheet_l]  part_no]

// Water- and steam-resistant EPDM, plain backing, ASTM D2000, black, -20 to 220 F, 800 psi.
sheet_epdm_1p6_60a   = ["EPDM 1/16 60A", "EPDM",   1.5875,    60,      [304.8,   304.8], "8525T65"];

gasket_sheets = [sheet_epdm_1p6_60a];

use <../utils/registries.scad>;
function gasket_sheet_by_name(name) = registry_by_name(gasket_sheets, name);

function gasket_sheet_name(type) = type[0];
function gasket_sheet_material(type) = type[1];
function gasket_sheet_thickness(type) = type[2];
function gasket_sheet_shore_a(type) = type[3];
function gasket_sheet_size(type) = type[4];
function gasket_sheet_part_number(type) = type[5];

// Blanks of a given cut diameter off one sheet, in a plain grid; nesting would do better.
function gasket_sheet_yield(type, cut_diameter) =
  floor(gasket_sheet_size(type)[0] / cut_diameter)
  * floor(gasket_sheet_size(type)[1] / cut_diameter);
