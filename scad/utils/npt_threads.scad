// parameters for the NPT taper threads cut into printed parts
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// ASME B1.20.1. A row is the thread itself, not a fitting: the major diameter at the hand-tight
// plane and the pitch its TPI implies. Everything that cuts one of these reads it from here, so a
// port and the probe that screws into it cannot disagree about which thread they are.

// Pure data, no geometry, so the accessors live inline - see the note in design-conventions.md
// about registries that own no part.

//                ["name"      major_d, tpi, hex_af]
npt_1_8       = ["1/8 NPT",  10.287,  27,  14.3  ];
npt_1_4       = ["1/4 NPT",  13.716,  18,  17.5  ];
npt_3_8       = ["3/8 NPT",  17.145,  18,  20.6  ];
npt_1_2       = ["1/2 NPT",  21.336,  14,  26.0  ];

npt_threads = [npt_1_8, npt_1_4, npt_3_8, npt_1_2];

function npt_thread_name(type) = type[0]; // as it is called and as it is marked on the part
function npt_thread_major_diameter(type) = type[1]; // at the hand-tight plane, ASME B1.20.1
function npt_thread_tpi(type) = type[2]; // threads per inch
function npt_thread_pitch(type) = 25.4 / npt_thread_tpi(type); // derived, so the two cannot drift

// Across-flats of the hex a fitting of this size usually carries. BORROWED, not measured: it is
// drawn for preview only and nothing derives from it, so it is here to look right rather than to
// be built to. The 1/2 NPT figure is the one already registered against a real probe.
function npt_thread_hex_across_flats(type) = type[3];
