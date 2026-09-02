// parameters for physical realization of sheet gasket stock
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A row is the sheet as the catalogue lists it, and both numbers that matter are facts about the
// stock rather than choices: thickness sets the lid's recess depth, and hardness sets the gasket
// factor m the joint's bolt count is derived from. Cutting the gasket is custom/sheet_gasket.scad,
// so there is no geometry here and the accessors sit beside the rows.

// Sheet size is carried because the cut is large enough for it to matter - the lid's gasket is
// 145 x 151 mm, so a 12 in square yields four.

//                       ["name"           material  thickness  shore_a  [sheet_w, sheet_l]  part_no]

// Water- and steam-resistant EPDM, plain backing, ASTM D2000, black. The McMaster number is on
// the row rather than here, so there is one expression of it.
// -20 to 220 F, 800 psi. 1/16 in is 1.5875 mm, not the 1.5 this replaced: the round metric number
// was never the product, and the recess is cut from it.
sheet_epdm_1p6_60a   = ["EPDM 1/16 60A", "EPDM",   1.5875,    60,      [304.8,   304.8], "8525T65"];

gasket_sheets = [sheet_epdm_1p6_60a];

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function gasket_sheet_by_name(name) = registry_by_name(gasket_sheets, name);

function gasket_sheet_name(type) = type[0];
function gasket_sheet_material(type) = type[1];
function gasket_sheet_thickness(type) = type[2];
function gasket_sheet_shore_a(type) = type[3];
function gasket_sheet_size(type) = type[4];
function gasket_sheet_part_number(type) = type[5]; // what to order it by

// derived
// How many blanks of a given cut diameter come off one sheet, laid out in a plain grid - which is
// what repositioning a template gets you. Nesting would do better and this does not claim it. The
// registry carried the sheet size for exactly this and nothing read it, so the "yields four" in the
// note above was a hand figure rather than a derived one; now it is neither hand nor a comment.
function gasket_sheet_yield(type, cut_diameter) =
  floor(gasket_sheet_size(type)[0] / cut_diameter)
  * floor(gasket_sheet_size(type)[1] / cut_diameter);
