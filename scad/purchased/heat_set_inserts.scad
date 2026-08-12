// parameters for physical realization of heat-set threaded inserts
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rows carry NopSCADlib's insert schema so its insert(), insert_hole_radius() and
// insert_hole_length() work on them unchanged - inserts.scad states that copying a row of the
// same thread size and changing only the length is sufficient, which is what this is. Registered
// here rather than taken from that library because none of its rows is a part we can buy, and it
// is the hole the lid gets printed with that has to match the tin.

//        length  outer_d  hole_d  screw  barrel_d  ring1_h  ring2_d  ring3_d

// McMaster 97163A152, 18-8 stainless, ASTM A380, M4 x 0.7. The lid's mount screws land in four of
// these. Stainless over the brass 94180A351: this face sees condensation, splash and wipe-downs,
// the brass carries a RoHS 6(c) lead exemption and is not REACH compliant, and for a single lid
// the pack of 10 is the cheaper buy outright. It conducts heat far worse than brass, so it wants
// a hotter iron and a longer dwell to bond rather than just melt a socket for itself.
//
// The catalogue gives installed length and hole, not a profile: it is tapered and knurled where
// the ring diameters below describe NopSCADlib's straight three-ring body. Length and hole are
// therefore the real part and the rings are nominal, which is the right way round, because the
// hole is what gets printed. McMaster's own note makes the taper optional - drill straight, then
// taper the top half only if you want the insert to self-align going in.
//
// Hole: a 2 Ga drill is 5.6134 mm and the catalogue's maximum is 5.7404, so the 5.6 below sits
// just under the size it is specified against.
insert_m4x4p7_ss = ["M4x4.7 18-8", 4.7,  6.3,     5.6,    4,     5.15,     1.0,     6.0,     5.55];

heat_set_inserts = [insert_m4x4p7_ss];
