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

// Rod seal, not a face seal, and the only one here that is: the sparger's riser passes up the bore
// of its port and this closes the annulus around it. Its ID IS THE TUBE - 4 mm on 4 mm, so it seats
// at zero stretch - which is why the row cannot be chosen by the gland the way the ones above are.
// Same EPDM 70A line and the same -65 to 300 F as them, one size down the same catalogue page.
oring_4x1p5_epdm       = ["4x1.5 EPDM",    "8785N364",  [4,       1.5 ], "EPDM",   70,    "Black"];

// The rest of the 1.5 mm line, so a gland can name a size without a trip to the catalogue. Nothing
// consumes these yet: a row here is an option, and the part that picks one owes the assert that it
// suits. Same EPDM 70A, -65 to 300 F page as the seals above - a 1289N number differs from an
// 8785N one only in whether the row also lists SAE J200.
oring_11x1p5_epdm      = ["11x1.5 EPDM",   "1289N321",  [11,      1.5 ], "EPDM",   70,    "Black"];
oring_12x1p5_epdm      = ["12x1.5 EPDM",   "1289N322",  [12,      1.5 ], "EPDM",   70,    "Black"];
oring_14x1p5_epdm      = ["14x1.5 EPDM",   "1289N324",  [14,      1.5 ], "EPDM",   70,    "Black"];
oring_15x1p5_epdm      = ["15x1.5 EPDM",   "1289N325",  [15,      1.5 ], "EPDM",   70,    "Black"];
oring_16x1p5_epdm      = ["16x1.5 EPDM",   "1289N326",  [16,      1.5 ], "EPDM",   70,    "Black"];
oring_18x1p5_epdm      = ["18x1.5 EPDM",   "1289N327",  [18,      1.5 ], "EPDM",   70,    "Black"];
oring_20x1p5_epdm      = ["20x1.5 EPDM",   "1289N328",  [20,      1.5 ], "EPDM",   70,    "Black"];
oring_22x1p5_epdm      = ["22x1.5 EPDM",   "8785N382",  [22,      1.5 ], "EPDM",   70,    "Black"];
oring_24x1p5_epdm      = ["24x1.5 EPDM",   "1289N329",  [24,      1.5 ], "EPDM",   70,    "Black"];
oring_25x1p5_epdm      = ["25x1.5 EPDM",   "8785N384",  [25,      1.5 ], "EPDM",   70,    "Black"];
oring_28x1p5_epdm      = ["28x1.5 EPDM",   "8785N387",  [28,      1.5 ], "EPDM",   70,    "Black"];
oring_30x1p5_epdm      = ["30x1.5 EPDM",   "1289N33",   [30,      1.5 ], "EPDM",   70,    "Black"];

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

orings = [oring_4x1p5_epdm, oring_13x1p5_epdm, oring_17x1p5_epdm, oring_23x1p5_epdm,
           oring_11x1p5_epdm, oring_12x1p5_epdm, oring_14x1p5_epdm, oring_15x1p5_epdm,
           oring_16x1p5_epdm, oring_18x1p5_epdm, oring_20x1p5_epdm, oring_22x1p5_epdm,
           oring_24x1p5_epdm, oring_25x1p5_epdm, oring_28x1p5_epdm, oring_30x1p5_epdm,
           oring_as568_150_epdm, oring_as568_151_epdm, oring_as568_152_epdm,
           oring_as568_153_epdm, oring_as568_154_epdm, oring_as568_155_epdm, oring_as568_156_epdm,
           oring_as568_157_epdm, oring_as568_158_epdm, oring_as568_159_epdm, oring_as568_160_epdm,
           oring_as568_161_epdm, oring_as568_162_epdm, oring_as568_163_epdm, oring_as568_164_epdm,
           oring_as568_165_epdm, oring_as568_166_epdm, oring_as568_167_epdm, oring_as568_168_epdm,
           oring_as568_169_epdm, oring_as568_170_epdm, oring_as568_171_epdm];

use <oring.scad>; // oring() draws the torus these rows describe

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function oring_by_name(name) = registry_by_name(orings, name);

// example usage - keep commented, this file is include'd and would emit a ring into every
// consumer (see shaft_couplings.scad for the same note)
// oring(oring_23x1p5_epdm);
