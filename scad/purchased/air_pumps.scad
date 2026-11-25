// parameters for physical realization of aeration pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A diaphragm pump is specified by the two end points of its pressure-flow curve: free flow at
// zero back-pressure, and dead-head pressure at zero flow. The two never occur together. Flow is
// stored as a range because the listings give a range. The low end is the conservative value.

//                        ["name"       model                                supply [free_lo, free_hi] dead_head power]
air_pump_resun_35w      = ["ReSun 35W", "DC 12V aquarium aerator/compressor", 12,   [65,      70     ], 27000,    35];

// No part number: this is an Amazon listing with no stable identifier.

air_pumps = [air_pump_resun_35w];

function air_pump_name(type) = type[0];
function air_pump_model(type) = type[1];
function air_pump_supply_voltage(type) = type[2];
function air_pump_free_flow(type) = type[3]; // [low, high] L/min at zero back-pressure
function air_pump_free_flow_min(type) = type[3][0];
function air_pump_free_flow_max(type) = type[3][1];
function air_pump_dead_head(type) = type[4]; // Pa at zero flow
function air_pump_power(type) = type[5]; // W electrical input
