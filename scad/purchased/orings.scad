// parameters for physical realization of various elastomer o-rings
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A row is what the catalogue lists; where a ring sits and how hard it is squeezed belongs to the
// gland (utils/oring_gland.scad).

//                        ["name"           part_no      [id,     cs  ], material, shore, colour ]

// The 1.5 mm cord line. All 70A, -65 to 300 F, ASTM D2000.
oring_13x1p5_epdm      = ["13x1.5 EPDM",   "1289N323",  [13,      1.5 ], "EPDM",   70,    "Black"];
oring_17x1p5_epdm      = ["17x1.5 EPDM",   "8785N378",  [17,      1.5 ], "EPDM",   70,    "Black"];
oring_23x1p5_epdm      = ["23x1.5 EPDM",   "8785N383",  [23,      1.5 ], "EPDM",   70,    "Black"];

// Seats at zero stretch on a 4 mm rod.
oring_4x1p5_epdm       = ["4x1.5 EPDM",    "8785N364",  [4,       1.5 ], "EPDM",   70,    "Black"];

// The rest of the 1.5 mm line, same page; a 1289N number differs from an 8785N one only in
// whether it also lists SAE J200.
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

// AS568 dash 150 to 171, 3/32 in (2.62 mm) cord, the same EPDM 70A line. IDs are the
// catalogue's inch value times 25.4;
// the dash number is the identity.

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

use <oring.scad>;

use <../utils/registries.scad>;
function oring_by_name(name) = registry_by_name(orings, name);
