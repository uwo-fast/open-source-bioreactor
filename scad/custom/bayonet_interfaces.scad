// parameters for the bayonet interface that every lid port mates to
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// One row is one interface: the coupling's dimensions, the flange it seats on, the seal, and
// the coupling pattern. Groups 1 and 4 together are what bayonet-lock-scad's bayonet() needs;
// groups 2 and 3 are the bioreactor-specific flange and o-ring. Everything both halves must
// agree on lives here, so a pin and a lock built from the same row always mate. Accessors are
// in bayonet_port.scad. Pure data - no geometry, so consumers can include it freely.

include <../purchased/orings.scad>;

// key is how far the second pin is brought back from even spacing. Evenly spaced pins (key 0)
// repeat every 360/n, so the coupling locks in n orientations and nothing tells them apart -
// fine for a tube, wrong for a baffle plate or a tilted probe, which would lock pointing
// anywhere. 25 degrees clears the channel mouth's 7.4 degree half-width, so a wrong seating
// jams rather than mates. See head.scad's assert and the library's keying section.

// The o-ring is a purchased part, so the row names the registered ring rather than transcribing
// its numbers, and the gland derives from that (see utils/oring_gland.scad). flange_lip is the
// material left outboard of the groove; the flange radius follows from the two together, so a
// flange too small for its own seal is not expressible. Note the ring has to encircle the
// coupling's Ø20.19 opening, which is why 20 mm ID is too small however thin the cord.

//                ["name" [iface_r, shell_t, pin_r, allow], [flange_h, flange_lip], oring,             [n_pins, sweep, pin_dir, turn_dir, key]]
bayonet_std     = ["std", [10,      2.5,     1.2,   0.2  ], [5,        0.6       ], oring_23x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];

bayonet_interfaces = [bayonet_std];

// example usage (see bayonet_port.scad, which previews bayonet_std directly)
// bayonet_port(bayonet_std, part="pin", panel_thickness=18, center_bore_radius=3);
