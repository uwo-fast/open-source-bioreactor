// Disc magnets, the rows NopSCADlib carries: MAG5x8 (8 x 5 solid), MAGRE6x2p5 (6 x 2.5),
// MAG8x4x4p2 and MAG484 (rings). The library draws them; this file only makes the rows a build
// can designate by name. No part number: any neodymium disc of the size does.
include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/magnets.scad>;

use <../utils/registries.scad>;
function magnet_by_name(name) = registry_by_name(magnets, name);
// The library's magnet_name() is the description ("Magnet"); the row's first field is what a
// build designates.
function magnet_designation(type) = type[0];
