// parameters for the bayonet interface that every lid port mates to
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// One row is one interface, so a pin and a lock built from the same row always mate. The first
// and last groups are bayonet-lock-scad's; the flange and the o-ring are this project's, and the
// gland derives from the ring. Accessors are in bayonet_port.scad.

include <../purchased/orings.scad>;

//                ["name" [iface_r, shell_t, pin_r, allow], [flange_h, flange_lip], oring,             [n_pins, sweep, pin_dir, turn_dir, key]]
bayonet_std     = ["std", [10,      2.5,     1.2,   0.2  ], [5,        1.0       ], oring_23x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];
bayonet_mini    = ["mini",[5,       2.5,     1.2,   0.2  ], [5,        1.2       ], oring_13x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];
bayonet_midi    = ["midi",[7,       2.5,     1.2,   0.2  ], [5,        1.2       ], oring_17x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];

bayonet_interfaces = [bayonet_std, bayonet_midi, bayonet_mini];
