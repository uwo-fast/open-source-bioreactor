// parameters for physical realization of various atlas probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Three product lines, each a set of grades sharing one cap and differing only below it -
// pH in four, DO in two, EC in five. Cap diameter and height on the pH and DO rows are
// caliper readings of the units on hand; everything else, and every EC number, is from the
// datasheets. Atlas's stated totals are cap + shaft and exclude the strain relief boot,
// which is what neck models - only the 8 cm EC sheet dimensions it, at the 26 mm used here.
// The DO shafts are stepped and this schema holds one segment, so tip_h is their sum: mini
// 15.5 + 23.5, lab 61.6 + 7.5. The lab's last 7.5 mm is a 16.4 mm end cap, not 12 mm.
// EC K 0.1 and K 1.0 are identical in every dimension the schema carries; they differ only
// in sensing area, 36 mm against 15.5 mm, which is not registered.

// atlas_probe is not a real probe, but a placeholder showing the expected format.
//            ["name"          [neck_d, neck_h, neck_taper_d], [body_d, body_h], [tip_d, tip_h], wire_d, accent_color];
atlas_probe = ["generic",      [10,     26,     5           ], [15.5,   36.0  ], [12,    115.0], 3,      "Pink"      ];

// https://atlas-scientific.com/probes/mini-ph-probe/
// https://files.atlas-scientific.com/Mini_pH_probe.pdf
ph_mini     = ["pH mini",      [10,     26,     5           ], [15.6,   36.0  ], [12,    27.8 ], 2.6,    "Red"       ];

// https://atlas-scientific.com/probes/consumer-grade-ph-probe/
// https://files.atlas-scientific.com/consumer-grade-pH-probe.pdf
ph_consumer = ["pH con",       [10,     26,     5           ], [15.6,   36.0  ], [12,    116.3], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/ph-probe/
// https://files.atlas-scientific.com/pH_probe.pdf
ph_lab      = ["pH lab",       [10,     26,     5           ], [15.6,   36.0  ], [12,    115.0], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/research-grade-ph-probe/
// https://files.atlas-scientific.com/Research_grade_pH_probe.pdf
ph_research = ["pH res",       [10,     26,     5           ], [15.6,   36.0  ], [12,    113.1], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/mini-d-o-probe/
// https://files.atlas-scientific.com/Mini_DO_probe.pdf
do_mini     = ["DO mini",      [10,     26,     5           ], [16.0,   35.6  ], [12,    39.0 ], 2.6,    "Goldenrod" ];

// https://atlas-scientific.com/probes/dissolved-oxygen-probe/
// https://files.atlas-scientific.com/LG_DO_probe.pdf
do_lab      = ["DO lab",       [10,     26,     5           ], [16.0,   35.6  ], [12,    69.1 ], 2.6,    "Goldenrod" ];

// https://atlas-scientific.com/probes/mini-e-c-probe-k-1-0/
// https://files.atlas-scientific.com/Mini_EC_K_1.0_probe.pdf
ec_mini_k1  = ["EC mini K1.0", [10,     26,     5           ], [16.0,   36.5  ], [12,    47.5 ], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/conductivity-probe-k-0-1/
// https://files.atlas-scientific.com/EC_K_0.1_probe.pdf
ec_k0p1     = ["EC K0.1",      [10,     26,     5           ], [16.0,   37.6  ], [12,    112.7], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/conductivity-probe-k-1-0/
// https://files.atlas-scientific.com/EC_K_1.0_probe.pdf
ec_k1       = ["EC K1.0",      [10,     26,     5           ], [16.0,   37.6  ], [12,    112.7], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/conductivity-probe-k-10/
// https://files.atlas-scientific.com/EC_K_10_probe.pdf
ec_k10      = ["EC K10",       [10,     26,     5           ], [16.0,   37.6  ], [12,    115.7], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/8cm-k01/
// https://files.atlas-scientific.com/l-EC_K_0.1_probe.pdf
// body_d is not on this sheet; 16.0 assumed from the rest of the family
ec_k0p1_8cm = ["EC K0.1 8cm",  [10,     26,     5           ], [16.0,   35.5  ], [12,    110.0], 2.6,    "SeaGreen"  ];

atlas_probes = [
  ph_mini,
  ph_consumer,
  ph_lab,
  ph_research,
  do_mini,
  do_lab,
  ec_mini_k1,
  ec_k0p1,
  ec_k1,
  ec_k10,
  ec_k0p1_8cm
];

use <atlas_probe.scad>;

// example usage (open this file directly to preview)
// atlas_probe(ph_lab);                       // registered set
// translate([40, 0, 0]) atlas_probe(do_lab); // registered set
// translate([80, 0, 0])                      // direct (inline type)
//   atlas_probe(["custom", [10, 26, 5], [15.6, 36], [12, 115], 3, "Cyan"]);
