// parameters for physical realization of various atlas probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Four product lines - pH in four grades, DO in two, EC in five, ORP in four. Within a line
// the upper end is common and the grades differ below it. Cap diameter and height on the pH
// and DO rows are caliper readings of the units on hand; the rest is from the datasheets.
//
// Atlas states totals as cap + shaft, leaving out the strain relief boot that neck models.
// Only three sheets dimension that boot - the 8 cm EC and the two full size ORP - all at the
// 26 mm used here. Those same three are built as boot + black body rather than a 16 mm cap
// and give no width for the body, so 16.0 is assumed and flagged on each row.
//
// Detail this schema does not carry: the DO stepped shafts, where tip_h is the sum of the
// two segments and the lab's last 7.5 mm is really a 16.4 mm end cap; EC sensing area; and
// ORP electrode material. That leaves ec_k0p1 / ec_k1 and orp_consumer / orp_lab identical
// apart from their names. Some sheets also state a total their own components do not sum to
// - pH lab by 1.8 mm, ORP consumer and lab by 0.6 mm - and the components are registered.

// atlas_probe is not a real probe, but a placeholder showing the expected format.
//             ["name"          [neck_d, neck_h, neck_taper_d], [body_d, body_h], [tip_d, tip_h], wire_d, accent_color];
atlas_probe  = ["generic",      [10,     26,     5           ], [15.5,   36.0  ], [12,    115.0], 3,      "Pink"      ];

// https://atlas-scientific.com/probes/mini-ph-probe/
// https://files.atlas-scientific.com/Mini_pH_probe.pdf
ph_mini      = ["pH mini",      [10,     26,     5           ], [15.6,   36.0  ], [12,    27.8 ], 2.6,    "Red"       ];

// https://atlas-scientific.com/probes/consumer-grade-ph-probe/
// https://files.atlas-scientific.com/consumer-grade-pH-probe.pdf
ph_consumer  = ["pH con",       [10,     26,     5           ], [15.6,   36.0  ], [12,    116.3], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/ph-probe/
// https://files.atlas-scientific.com/pH_probe.pdf
ph_lab       = ["pH lab",       [10,     26,     5           ], [15.6,   36.0  ], [12,    115.0], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/research-grade-ph-probe/
// https://files.atlas-scientific.com/Research_grade_pH_probe.pdf
ph_research  = ["pH res",       [10,     26,     5           ], [15.6,   36.0  ], [12,    113.1], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/mini-d-o-probe/
// https://files.atlas-scientific.com/Mini_DO_probe.pdf
do_mini      = ["DO mini",      [10,     26,     5           ], [16.0,   35.6  ], [12,    39.0 ], 2.6,    "Goldenrod" ];

// https://atlas-scientific.com/probes/dissolved-oxygen-probe/
// https://files.atlas-scientific.com/LG_DO_probe.pdf
do_lab       = ["DO lab",       [10,     26,     5           ], [16.0,   35.6  ], [12,    69.1 ], 2.6,    "Goldenrod" ];

// https://atlas-scientific.com/probes/mini-e-c-probe-k-1-0/
// https://files.atlas-scientific.com/Mini_EC_K_1.0_probe.pdf
ec_mini_k1   = ["EC mini K1.0", [10,     26,     5           ], [16.0,   36.5  ], [12,    47.5 ], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/conductivity-probe-k-0-1/
// https://files.atlas-scientific.com/EC_K_0.1_probe.pdf
ec_k0p1      = ["EC K0.1",      [10,     26,     5           ], [16.0,   37.6  ], [12,    112.7], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/conductivity-probe-k-1-0/
// https://files.atlas-scientific.com/EC_K_1.0_probe.pdf
ec_k1        = ["EC K1.0",      [10,     26,     5           ], [16.0,   37.6  ], [12,    112.7], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/conductivity-probe-k-10/
// https://files.atlas-scientific.com/EC_K_10_probe.pdf
ec_k10       = ["EC K10",       [10,     26,     5           ], [16.0,   37.6  ], [12,    115.7], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/8cm-k01/
// https://files.atlas-scientific.com/l-EC_K_0.1_probe.pdf
// body_d is not on this sheet; 16.0 assumed from the rest of the family
ec_k0p1_8cm  = ["EC K0.1 8cm",  [10,     26,     5           ], [16.0,   35.5  ], [12,    110.0], 2.6,    "SeaGreen"  ];

// https://atlas-scientific.com/probes/mini-orp-probe/
// https://files.atlas-scientific.com/mini-orp-probe.pdf
orp_mini     = ["ORP mini",     [10,     26,     5           ], [16.0,   36.2  ], [12,    28.9 ], 2.6,    "SteelBlue" ];

// https://atlas-scientific.com/probes/consumer-grade-orp-probe/
// https://files.atlas-scientific.com/consumer-grade-ORP-probe.pdf
// body_d is not on this sheet; 16.0 assumed from the rest of the family
orp_consumer = ["ORP con",      [10,     26,     5           ], [16.0,   35.0  ], [12,    115.0], 2.8,    "SteelBlue" ];

// https://atlas-scientific.com/probes/orp-probe/
// https://files.atlas-scientific.com/orp_probe.pdf
// body_d is not on this sheet; 16.0 assumed from the rest of the family
orp_lab      = ["ORP lab",      [10,     26,     5           ], [16.0,   35.0  ], [12,    115.0], 2.8,    "SteelBlue" ];

// https://atlas-scientific.com/probes/lab-grade-gold-orp-probe/
// https://files.atlas-scientific.com/ENV-40-ORP-G.pdf
orp_gold     = ["ORP gold",     [10,     26,     5           ], [16.0,   36.2  ], [12,    113.8], 2.8,    "SteelBlue" ];

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
  ec_k0p1_8cm,
  orp_mini,
  orp_consumer,
  orp_lab,
  orp_gold
];

use <atlas_probe.scad>;

// example usage (open this file directly to preview)
// atlas_probe(ph_lab);                       // registered set
// translate([40, 0, 0]) atlas_probe(do_lab); // registered set
// translate([80, 0, 0])                      // direct (inline type)
//   atlas_probe(["custom", [10, 26, 5], [15.6, 36], [12, 115], 3, "Cyan"]);
