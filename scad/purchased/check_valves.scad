// parameters for physical realization of gas-line check valves
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// TWO NUMBERS, and only one of them is ever quoted. A check valve costs a CRACKING pressure to open
// at all, and a flowing drop on top of that once it is open. Catalogue copy prints the cracking
// pressure and stops, which reads as though the valve were free thereafter. Both are needed to say
// what the line actually costs, so both are registered - see utils/gas_supply.scad.

//                              ["name"        part_no     cracking  cv  ]

// Cole-Parmer 5011521: 0.18 psi to crack, Cv 0.12 open. Both off the datasheet of the part on the
// purchase list, which is the point of the row - they were two literals beside the geometry before,
// stating a bought part's data anywhere but on its row.
check_valve_cp_5011521       = ["Cole-Parmer 5011521", "5011521",  1241,  0.12];

check_valves = [check_valve_cp_5011521];

function check_valve_name(type) = type[0]; // the row's identity, and the key a build designates it by
function check_valve_part_number(type) = type[1]; // what to order it by
function check_valve_cracking(type) = type[2]; // Pa to open at all; 1241 Pa is 0.18 psi
function check_valve_cv(type) = type[3]; // flow coefficient once open

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function check_valve_by_name(name) = registry_by_name(check_valves, name);
