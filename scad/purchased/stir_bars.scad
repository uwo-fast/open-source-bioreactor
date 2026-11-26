// parameters for physical realization of magnetic stir bars
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// PTFE-coated alnico bars, plain cylindrical type. No part number yet: any bar of the right size
// will do and none has been bought, so the purchase list does not include these rows.

//                 ["name"    part_no  [length, diameter]]
stir_bar_25x8    = ["25x8",   undef,   [25,     8       ]];
stir_bar_38x8    = ["38x8",   undef,   [38,     8       ]];
stir_bar_50x8    = ["50x8",   undef,   [50,     8       ]];

stir_bars = [stir_bar_25x8, stir_bar_38x8, stir_bar_50x8];

use <../utils/registries.scad>;
function stir_bar_by_name(name) = registry_by_name(stir_bars, name, "sSl");

use <stir_bar.scad>
