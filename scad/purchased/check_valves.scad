// parameters for physical realization of gas-line check valves
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A check valve costs a cracking pressure to open and a flowing drop (Cv) once open; catalogues
// quote only the first. See utils/gas_supply.scad.

//                              ["name"        part_no     cracking  cv  ]

// Cole-Parmer 5011521: 0.18 psi to crack, Cv 0.12 open, from the datasheet.
check_valve_cp_5011521       = ["Cole-Parmer 5011521", "5011521",  1241,  0.12];

check_valves = [check_valve_cp_5011521];

function check_valve_name(type) = type[0];
function check_valve_part_number(type) = type[1];
function check_valve_cracking(type) = type[2]; // Pa
function check_valve_cv(type) = type[3];

use <../utils/registries.scad>;
function check_valve_by_name(name) = registry_by_name(check_valves, name);
