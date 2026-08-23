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

// McMaster 8785N383, water- and steam-resistant EPDM, -65 to 300 F, ASTM D2000 / SAE J200.
// Port face seals, one per bayonet port; the gland in bayonet_port.scad is cut for it.
oring_23x1p5_epdm      = ["23x1.5 EPDM",   "8785N383",  [23,      1.5 ], "EPDM",   70,    "Black"];

// The lid plug's radial seal. NOT YET ORDERABLE - this row is written from the AS568 standard, which
// is why it has no part number. head_plug_oring_cord_limit() caps the cord at 3.05 mm, so the ring
// wanted is 3/32 in (2.62 mm) cord, EPDM 70A, free ID 130.7-137.2 mm for the 143 mm jar and roughly
// 78-176 mm to cover the registered family. McMaster's water- and steam-resistant line (8785N) lists
// its 3/32 in width empty and its 3 mm metric stops at ID 80 mm, so the family that supplies the
// port seal above cannot supply this one; it has to come from another line or another supplier.
oring_as568_160_epdm   = ["AS568-160",     "",          [133.02,  2.62], "EPDM",   70,    "Black"];

orings = [oring_23x1p5_epdm, oring_as568_160_epdm];

use <oring.scad>; // oring() draws the torus these rows describe

// example usage - keep commented, this file is include'd and would emit a ring into every
// consumer (see shaft_couplings.scad for the same note)
// oring(oring_23x1p5_epdm);
