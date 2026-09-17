// parameters for physical realization of sterile gas-line filters
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A filter is registered by what it costs the line: kPa per L/min, linear because membrane flow
// at these pressures is viscous (Darcy).

//                              ["name"        part_no     slope  micron  area_cm2]

// Slope EXTRAPOLATED, not measured: Cole-Parmer publish no curve, so 3.45 is a fit from an
// equivalent 0.2 um PTFE disc; area-correcting Pall's Acro 50 gives 3.02. A water manometer at the
// set flow would replace it (TODO.md).
gas_filter_cp_1594522        = ["Cole-Parmer 1594522", "1594522",  3.45,  0.2,    16.2    ];

gas_filters = [gas_filter_cp_1594522];

function gas_filter_name(type) = type[0];
function gas_filter_part_number(type) = type[1];
function gas_filter_drop_slope(type) = type[2]; // kPa per L/min
function gas_filter_micron(type) = type[3]; // absolute rating
function gas_filter_area(type) = type[4]; // cm2 of membrane

use <../utils/registries.scad>;
function gas_filter_by_name(name) = registry_by_name(gas_filters, name);
