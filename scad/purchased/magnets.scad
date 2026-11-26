// Disc magnets from the NopSCADlib rows: MAG5x8 (8 x 5 solid), MAGRE6x2p5 (6 x 2.5),
// MAG8x4x4p2 and MAG484 (rings). The library draws them. This file only makes the rows selectable
// by name. No part number: any neodymium disc of the right size will do.
include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/magnets.scad>;

use <../utils/registries.scad>;
function magnet_by_name(name) = registry_by_name(magnets, name, "ssnnnn");
// The library's magnet_name() returns the description ("Magnet"). The first field of the row is
// the name a build selects it by.
function magnet_designation(type) = type[0];
