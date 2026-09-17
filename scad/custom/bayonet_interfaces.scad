// parameters for the bayonet interface that every lid port mates to
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// One row is one interface: everything both halves must agree on, so a pin and a lock built from
// the same row always mate. Groups 1 and 4 are what bayonet-lock-scad's bayonet() needs; 2 and 3
// are this project's flange and o-ring. Accessors are in bayonet_port.scad. Pure data.

include <../purchased/orings.scad>;

// key brings the second pin back from even spacing so the coupling locks in one orientation, not
// n; 25 degrees clears the channel mouth's 7.4 degree half-width so a wrong seating jams.
//
// The row names the registered o-ring and the gland derives from it (utils/oring_gland.scad).
// flange_lip is the wall outboard of the groove the cord is pressed against - structural - and
// the flange radius follows from the two. std's lip is capped at 1.0 by jar_10L's twelve-port
// circle, where two std flanges share a 29.2466 mm chord and must leave lid_flange_gap of air.

//                ["name" [iface_r, shell_t, pin_r, allow], [flange_h, flange_lip], oring,             [n_pins, sweep, pin_dir, turn_dir, key]]
bayonet_std     = ["std", [10,      2.5,     1.2,   0.2  ], [5,        1.0       ], oring_23x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];

// std passes a 16 mm Atlas probe body with 2 mm of collet wall. The smaller two buy back mouth
// where it is tight: mini passes a 3 mm bore tube (flange r 9.30), midi a 1/8 NPT thermocouple
// mount (11.30), against std's 14.10. head_interface_for() gives every port std wherever the set
// still fits and falls back only where it does not; baffles stay std because the plate drops
// through the lock bore. See docs/ports-layout.md.
bayonet_mini    = ["mini",[5,       2.5,     1.2,   0.2  ], [5,        1.2       ], oring_13x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];
bayonet_midi    = ["midi",[7,       2.5,     1.2,   0.2  ], [5,        1.2       ], oring_17x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];

bayonet_interfaces = [bayonet_std, bayonet_midi, bayonet_mini];
