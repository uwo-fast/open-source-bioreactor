// parameters for the bayonet interface that every lid port mates to
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// One row is one interface: the coupling itself, the flange it seats on, and the seal.
// Group 1 is exactly what bayonet-lock-scad's bayonet() takes, so it can be passed straight
// through; groups 2 and 3 are the bioreactor-specific flange and o-ring. Accessors live in
// bayonet_port.scad. Pure data - no geometry, so consumers can include it freely.

//                ["name" [iface_r, shell_t, pin_r, part_h, allow], [neck_h, neck_r], [oring_cs, oring_intf]]
bayonet_std     = ["std", [10,     2.5,     1.2,   10,     0.2  ], [5,      15    ], [1.6,      0.1       ]];

bayonet_interfaces = [bayonet_std];

// example usage (see bayonet_port.scad, which previews bayonet_std directly)
// bayonet_port(bayonet_std, part="pin", center_bore_radius=3, text_labels=true);
