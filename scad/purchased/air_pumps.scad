// parameters for physical realization of aeration pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A diaphragm pump is specified by the two ENDS of its curve, never by a point on it: free flow at
// zero back-pressure, and dead-head pressure at zero flow. Catalogue copy prints them side by side
// as though they were simultaneous, which is what this registry exists to stop being misread - the
// product of the two is a pneumatic power the pump does not have. utils/gas_supply.scad checks it.

// Flow is a BAND because that is how these are sold. There is no tolerance behind it and no
// measurement; it is two numbers in a listing, and the low end is what anything conservative uses.

//                        ["name"       model                                supply [free_lo, free_hi] dead_head power]
air_pump_resun_35w      = ["ReSun 35W", "DC 12V aquarium aerator/compressor", 12,   [65,      70     ], 27000,    35];

// No part number: bought from an Amazon listing rather than a catalogue, so there is nothing stable
// to register. That is a procurement gap, not a schema one - see docs/procurement.md.

air_pumps = [air_pump_resun_35w];

function air_pump_name(type) = type[0];
function air_pump_model(type) = type[1];
function air_pump_supply_voltage(type) = type[2];
function air_pump_free_flow(type) = type[3]; // [low, high] L/min at zero back-pressure
function air_pump_free_flow_min(type) = type[3][0];
function air_pump_free_flow_max(type) = type[3][1];
function air_pump_dead_head(type) = type[4]; // Pa at zero flow
function air_pump_power(type) = type[5]; // W electrical input
