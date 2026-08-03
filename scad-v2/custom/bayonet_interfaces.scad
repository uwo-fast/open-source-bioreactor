// parameters for the bayonet interface that every lid port mates to
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// One row is one interface: the coupling's dimensions, the flange it seats on, the seal, and
// the coupling pattern. Groups 1 and 4 together are what bayonet-lock-scad's bayonet() needs;
// groups 2 and 3 are the bioreactor-specific flange and o-ring. Everything both halves must
// agree on lives here, so a pin and a lock built from the same row always mate. Accessors are
// in bayonet_port.scad. Pure data - no geometry, so consumers can include it freely.

//                ["name" [iface_r, shell_t, pin_r, part_h, allow], [flange_h, flange_r], [oring_cs, oring_intf], [n_pins, sweep, pin_dir, turn_dir]]
bayonet_std     = ["std", [10,     2.5,     1.2,   10,     0.2  ], [5,        15      ], [1.6,      0.1       ], [3,      30,    "outer", "CW"    ]];

bayonet_interfaces = [bayonet_std];

// example usage (see bayonet_port.scad, which previews bayonet_std directly)
// bayonet_port(bayonet_std, part="pin", panel_thickness=18, center_bore_radius=3);
