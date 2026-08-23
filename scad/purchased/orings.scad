// parameters for physical realization of various elastomer o-rings
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A row is what the catalogue lists and nothing more. Where a ring sits and how hard it is squeezed
// belongs to the gland holding it, which derives from these numbers - see utils/oring_gland.scad.
// Two directions are in play and both are correct: the port glands are cut to fit their ring, while
// the lid plug's groove is cut to fit the jar's bore and the ring is stretched onto it.

// Every row carries the number to ORDER it by, because a ring cannot be chosen by measuring the one
// already fitted: nobody can measure a jar they have not bought, and a second builder cannot measure
// this bench at all. A row without a number is a hole in the bill of materials, not a part.

//                        ["name"           part_no      [id,     cs  ], material, shore, colour ]

// Port face seals, one per bayonet port; the gland in bayonet_port.scad is cut for whichever the
// interface names. All 70A, -65 to 300 F, ASTM D2000. Each has to encircle its coupling's opening
// and still stand on the land outboard of the lock bore, which is what sets the ID: the rule is
// ID >= 2*(lock_bore_r + land + cs/2), and bayonet_port() asserts it rather than trusting the row.
oring_13x1p5_epdm      = ["13x1.5 EPDM",   "1289N323",  [13,      1.5 ], "EPDM",   70,    "Black"];
oring_17x1p5_epdm      = ["17x1.5 EPDM",   "8785N378",  [17,      1.5 ], "EPDM",   70,    "Black"];
oring_23x1p5_epdm      = ["23x1.5 EPDM",   "8785N383",  [23,      1.5 ], "EPDM",   70,    "Black"];

// The lid plug's radial seal, AS568 dash 150 to 171, all 3/32 in (2.62 mm) cord. That width is not
// a preference: head_plug_oring_cord_limit() caps the cord at 3.05 mm, because the groove and the
// port bores are cut into the same wall of the plug. The 1/8 in cord the same catalogue stocks is
// 0.48 mm over that ceiling and fouls the bores on every vessel in the family, so it is not an
// option for this seal on any jar - only for something with no ports beside the groove.
//
// Same water- and steam-resistant line as the port seal above: EPDM 70A, -65 to 300 F, ASTM D2000 /
// SAE AS568 / SAE J200. That covers autoclaving at 121 C with room to spare. The Parker E0603 line
// (9557K...) lists the identical sizes but only to 250 F, which is the autoclave temperature with
// no margin at all, and at three times the price.
//
// Together these seal a mouth anywhere from 77 to 217 mm, so every registered vessel resolves and
// most substitutions will too. IDs are the catalogue's inch value times 25.4; the DASH NUMBER is
// the authoritative identity, so the millimetres here stay checkable against any AS568 table.

oring_as568_150_epdm   = ["AS568-150",     "8785N626",  [72.695,  2.62], "EPDM",   70,    "Black"];
oring_as568_151_epdm   = ["AS568-151",     "8785N627",  [75.870,  2.62], "EPDM",   70,    "Black"];
oring_as568_152_epdm   = ["AS568-152",     "8785N628",  [82.220,  2.62], "EPDM",   70,    "Black"];
oring_as568_153_epdm   = ["AS568-153",     "8785N629",  [88.570,  2.62], "EPDM",   70,    "Black"];
oring_as568_154_epdm   = ["AS568-154",     "8785N631",  [94.920,  2.62], "EPDM",   70,    "Black"];
oring_as568_155_epdm   = ["AS568-155",     "8785N632",  [101.270, 2.62], "EPDM",   70,    "Black"];
oring_as568_156_epdm   = ["AS568-156",     "8785N633",  [107.620, 2.62], "EPDM",   70,    "Black"];
oring_as568_157_epdm   = ["AS568-157",     "8785N634",  [113.970, 2.62], "EPDM",   70,    "Black"];
oring_as568_158_epdm   = ["AS568-158",     "8785N635",  [120.320, 2.62], "EPDM",   70,    "Black"];
oring_as568_159_epdm   = ["AS568-159",     "8785N636",  [126.670, 2.62], "EPDM",   70,    "Black"];
oring_as568_160_epdm   = ["AS568-160",     "8785N637",  [133.020, 2.62], "EPDM",   70,    "Black"];
oring_as568_161_epdm   = ["AS568-161",     "8785N638",  [139.370, 2.62], "EPDM",   70,    "Black"];
oring_as568_162_epdm   = ["AS568-162",     "8785N639",  [145.720, 2.62], "EPDM",   70,    "Black"];
oring_as568_163_epdm   = ["AS568-163",     "8785N641",  [152.070, 2.62], "EPDM",   70,    "Black"];
oring_as568_164_epdm   = ["AS568-164",     "8785N642",  [158.420, 2.62], "EPDM",   70,    "Black"];
oring_as568_165_epdm   = ["AS568-165",     "8785N643",  [164.770, 2.62], "EPDM",   70,    "Black"];
oring_as568_166_epdm   = ["AS568-166",     "8785N644",  [171.120, 2.62], "EPDM",   70,    "Black"];
oring_as568_167_epdm   = ["AS568-167",     "8785N645",  [177.470, 2.62], "EPDM",   70,    "Black"];
oring_as568_168_epdm   = ["AS568-168",     "8785N646",  [183.820, 2.62], "EPDM",   70,    "Black"];
oring_as568_169_epdm   = ["AS568-169",     "8785N647",  [190.170, 2.62], "EPDM",   70,    "Black"];
oring_as568_170_epdm   = ["AS568-170",     "8785N648",  [196.520, 2.62], "EPDM",   70,    "Black"];
oring_as568_171_epdm   = ["AS568-171",     "8785N649",  [202.870, 2.62], "EPDM",   70,    "Black"];

orings = [oring_13x1p5_epdm, oring_17x1p5_epdm, oring_23x1p5_epdm, oring_as568_150_epdm, oring_as568_151_epdm, oring_as568_152_epdm,
           oring_as568_153_epdm, oring_as568_154_epdm, oring_as568_155_epdm, oring_as568_156_epdm,
           oring_as568_157_epdm, oring_as568_158_epdm, oring_as568_159_epdm, oring_as568_160_epdm,
           oring_as568_161_epdm, oring_as568_162_epdm, oring_as568_163_epdm, oring_as568_164_epdm,
           oring_as568_165_epdm, oring_as568_166_epdm, oring_as568_167_epdm, oring_as568_168_epdm,
           oring_as568_169_epdm, oring_as568_170_epdm, oring_as568_171_epdm];

use <oring.scad>; // oring() draws the torus these rows describe

// example usage - keep commented, this file is include'd and would emit a ring into every
// consumer (see shaft_couplings.scad for the same note)
// oring(oring_23x1p5_epdm);
