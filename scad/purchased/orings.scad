// parameters for physical realization of various elastomer o-rings
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// The ring is the purchased part, so a row is what the catalogue lists and nothing more. Where a
// ring sits and how hard it is squeezed belongs to the gland holding it, which derives from these
// numbers - see utils/oring_gland.scad. Two directions are in play and both are correct: the port
// glands are cut to fit their ring, while the lid plug's groove is cut to fit the jar's bore and
// the ring is stretched onto it.

//                     ["name"             [id,     cs  ], material, shore, colour ]

// McMaster 8785N383, water and steam resistant, -54 to 149 C, ASTM D2000 / SAE J200.
// Port face seals, one per bayonet port; the gland in bayonet_port.scad is cut for it.
oring_23x1p5_epdm    = ["23x1.5 EPDM",     [23,     1.5 ], "EPDM",   70,    "Black"];

// AS568-160, 5.237 in ID x 0.103 in cord. Centres the lid plug in the vessel neck; stretched
// onto a groove sized from the bore, so it installs larger than this - see head.scad.
oring_as568_160_epdm = ["AS568-160 EPDM",  [133.02, 2.62], "EPDM",   70,    "Black"];

orings = [oring_23x1p5_epdm, oring_as568_160_epdm];

use <oring.scad>;

// example usage - keep commented, this file is include'd and would emit a ring into every
// consumer (see 1a6df3d)
// oring(oring_23x1p5_epdm);
// translate([60, 0, 0]) oring(oring_as568_160_epdm);
