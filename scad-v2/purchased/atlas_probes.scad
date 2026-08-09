// parameters for physical realization of various atlas probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// The pH line is four grades that share one cap and differ only below it. Cap diameter and
// height are caliper readings of the lab-grade unit on hand; the datasheets give a nominal
// 16 x 36.2 for all four, so the same cap is used across the pH rows. Shaft length and
// diameter and the cable diameter are from the datasheets.

// atlas_probe is not a real probe, but a placeholder to show the expected format of the parameters for a probe. 
//            ["name"     [neck_d, neck_h, neck_taper_d], [body_d, body_h], [tip_d, tip_h], wire_d, accent_color];
atlas_probe = ["generic", [10,     26,      5          ], [15.5,   36.0  ], [12,    115.0], 3,      "Pink"       ];

// https://atlas-scientific.com/probes/mini-ph-probe/
// https://files.atlas-scientific.com/Mini_pH_probe.pdf
ph_mini     = ["pH mini", [10,     26,      5          ], [15.6,   36.0  ], [12,    27.8 ], 2.6,    "Red"       ];

// https://atlas-scientific.com/probes/consumer-grade-ph-probe/
// https://files.atlas-scientific.com/consumer-grade-pH-probe.pdf
ph_consumer = ["pH con",  [10,     26,      5          ], [15.6,   36.0  ], [12,    116.3], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/ph-probe/
// https://files.atlas-scientific.com/pH_probe.pdf
ph_lab      = ["pH lab",  [10,     26,      5          ], [15.6,   36.0  ], [12,    115.0], 2.8,    "Red"       ];

// https://atlas-scientific.com/probes/research-grade-ph-probe/
// https://files.atlas-scientific.com/Research_grade_pH_probe.pdf
ph_research = ["pH res",  [10,     26,      5          ], [15.6,   36.0  ], [12,    113.1], 2.8,    "Red"       ];

// TODO: the DO probe is still a single unmeasured row - give it the same treatment as pH
do          = ["do",      [10,     26,      5          ], [16.0,   35.6  ], [12,    115  ], 3,      "Goldenrod" ];

atlas_probes = [ph_mini, ph_consumer, ph_lab, ph_research, do];

use <atlas_probe.scad>;

// example usage (open this file directly to preview)
// atlas_probe(ph_lab);                   // registered set
// translate([40, 0, 0]) atlas_probe(do); // registered set
// translate([80, 0, 0])                  // direct (inline type)
//   atlas_probe(["custom", [10, 26, 5], [15.6, 36], [12, 115], 3, "Cyan"]);
