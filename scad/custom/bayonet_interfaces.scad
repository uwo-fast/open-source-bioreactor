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
// Not a lid port: the condenser's removable well. Ring ID less the interface diameter is 3, as on std,
// so the land and the channel mouth's reach into the gland match std's.
bayonet_large   = ["large",[13.5,   2.5,     1.2,   0.2  ], [5,        1.0       ], oring_30x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];
// Not a lid port either: the condenser coil's head, whose bore the coil drops through. A 2 mm
// ring, the 1.5 mm line stopping at 30; at 19 its lock's entry channels stop short of the groove.
bayonet_xl      = ["xl",  [19,      2.5,     1.2,   0.2  ], [5,        1.0       ], oring_42x2_epdm,   [3,      30,    "outer", "CW",     25 ]];

bayonet_interfaces = [bayonet_std, bayonet_midi, bayonet_mini];
