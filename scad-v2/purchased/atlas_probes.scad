// parameters for physical realization of various atlas probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// TODO: make this more specific / granular since atlas has multiple variants
// of probes (mini vs standard vs research) with different dimensions but 
// largely the same shape

//   ["name" [neck_d, neck_h, neck_taper_d], [body_d, body_h], [tip_d, tip_h], wire_d, accent_color];   
ph = ["ph",  [10,     26,      5          ], [15.6,   35    ], [12,      115], 3,      "Red"       ];
do = ["do",  [10,     26,      5          ], [16,     35    ], [12,      115], 3,      "Goldenrod" ];

atlas_probes = [ph, do];

use <atlas_probe.scad>;
