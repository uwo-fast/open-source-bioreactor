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
//
// flange_lip is STRUCTURAL, not trim - it is the wall the cord is pressed against - and 0.6 printed
// as a single extrusion at a 0.4 nozzle. mini and midi are at 1.2, three of them; std is at 1.0.
//
// std is the one with a ceiling, and it is the LID that sets it rather than the port: jar_10L's
// twelve-port circle puts two std flanges adjacent, so the pair shares a 29.2466 mm chord. What
// that chord has to leave is lid_flange_gap - AIR between two raised features - and not
// lid_holes_offset, which is the wall the lid keeps between the BORES underneath and measures
// 4.44655 mm there whatever the flange does. While one number did both jobs std was capped at r
// 13.7268 and could not have a second extrusion; separated, it reaches 14.1 with 1.0466 mm still
// between flanges. 1.2 would leave 0.6466, which is a gap rather than a margin.

//                ["name" [iface_r, shell_t, pin_r, allow], [flange_h, flange_lip], oring,             [n_pins, sweep, pin_dir, turn_dir, key]]
bayonet_std     = ["std", [10,      2.5,     1.2,   0.2  ], [5,        1.0       ], oring_23x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];

// std is sized for what has to pass through it: a 16 mm Atlas probe body with 2 mm of collet wall
// either side. Nothing else on the lid needs that, and where a mouth is tight these buy it back.
//
// WHERE THEY DO NOT: the twelve-port lid. Four baffles every third port leave no port that is not
// adjacent to one, so a probe must touch a baffle, both are std, and the worst pair is 14.1 + 14.1
// whatever the tubes take - jar_10L reads 1.0466 mm with mini tubes and 1.0466 mm without. So
// head_interface_for() gives every port std wherever the set still fits that way, and falls back to
// the smallest that will do only where it does not. Six ports all on std wants an 87.6 mm mouth and
// jar_1p5L_109x215 has 87.5, which is the one registered vessel that still takes these. See
// head_ports_uniform() and docs/ports-layout.md.
//
// The flange follows the seal rather than the bore, so a smaller interface is only worth having if
// a smaller ring can still stand outboard of its lock bore. These two can:
//   mini  passes a 3 mm bore tube with 2 mm of wall, flange r 9.30
//   midi  passes a 1/8 NPT thermocouple mount, flange r 11.30
// against std's 14.10. Both were checked at their own radius rather than assumed - the key margin
// is the constraint that tightens as the circle shrinks, and mini leaves 25 degrees against the
// 14.6 it needs. Baffles cannot use either: the plate drops through the lock bore, so a mini gives
// a 3.6 mm baffle. Baffles stay std.
bayonet_mini    = ["mini",[5,       2.5,     1.2,   0.2  ], [5,        1.2       ], oring_13x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];
bayonet_midi    = ["midi",[7,       2.5,     1.2,   0.2  ], [5,        1.2       ], oring_17x1p5_epdm, [3,      30,    "outer", "CW",     25 ]];

bayonet_interfaces = [bayonet_std, bayonet_midi, bayonet_mini];

// example usage (see bayonet_port.scad, which previews bayonet_std directly)
// bayonet_port(bayonet_std, part="pin", panel_thickness=18, center_bore_radius=3);
