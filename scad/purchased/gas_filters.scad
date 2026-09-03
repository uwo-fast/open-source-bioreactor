// parameters for physical realization of sterile gas-line filters
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A filter is registered by what it COSTS THE LINE, not by what it is made of. The design cares
// about one number - the pressure drop per unit flow - because that is what the throttle has to be
// sized around, and it is the number a catalogue is least likely to give you.
//
// The slope is kPa per L/min, and it is linear on purpose. Membrane flow at these pressures is
// viscous, so Darcy makes drop proportional to flow; a curve would be the wrong shape as well as
// unavailable.

//                              ["name"        part_no     slope  micron  area_cm2]

// EXTRAPOLATED, NOT MEASURED, and that is the whole caveat on this row. Cole-Parmer publish no
// curve for 1594522, so 3.45 is a linear fit taken from an equivalent 0.2 um PTFE disc of
// near-identical dimensions. It is corroborated rather than invented: area-correcting Pall's
// Acro 50 from 19.6 to this filter's 16.2 cm2 gives 3.02, so 3.45 sits 14 % conservative of the
// best-documented comparable part.
//
// It matters more than its size suggests - at the design flow it is 14.1 kPa against the vessel's
// own 1.1, so it takes over half of what the throttle would otherwise have had. Worth replacing
// with a measured number; a water manometer across it at the set flow is enough. See TODO.md.
gas_filter_cp_1594522        = ["Cole-Parmer 1594522", "1594522",  3.45,  0.2,    16.2    ];

gas_filters = [gas_filter_cp_1594522];

function gas_filter_name(type) = type[0]; // the row's identity, and the key a build designates it by
function gas_filter_part_number(type) = type[1]; // what to order it by
function gas_filter_drop_slope(type) = type[2]; // kPa per L/min, EXTRAPOLATED on the row above
function gas_filter_micron(type) = type[3]; // absolute rating
function gas_filter_area(type) = type[4]; // cm2 of membrane, which is what the slope scales with

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function gas_filter_by_name(name) = registry_by_name(gas_filters, name);
