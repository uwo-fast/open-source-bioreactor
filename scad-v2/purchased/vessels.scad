// parameters for physical realization of various culture vessels (jars)
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// The mouth bore is a measured fact, so it is registered here; the shoulder-to-neck corner
// radius is the eyeballed value and is solved from it by vessel_neck_corner_radius().

//                 ["name"           [height, diameter, thickness], [opening_dia, neck], [corner_rad, corner_rad_base], [punt_h, punt_w], rim_rad]
generic_vessel   = ["generic",       [305,    220,      5        ], [143,         25  ], [25,         12.5           ], [5,      30    ], 2      ];

// Commodity 10 L airtight soda-lime glass jar (Alibaba, see purchased-parts.csv).
// The jar in the lab: 220 mm OD x 305 mm H with a 143 mm mouth. Corner radii and punt are
// fitted by eye to the real jar's profile; wall thickness is a nominal measurement.
jar_10L_220x305  = ["jar_10L_220x305", [305,  220,      5        ], [143,         25  ], [25,         12.5           ], [5,      30    ], 2      ];

vessels = [generic_vessel, jar_10L_220x305];

use <vessel.scad>

// example usage (open this file directly to preview)
// vessel(jar_10L_220x305, angle=180);                                     // registered set, cross section
// translate([250, 0, 0]) vessel(["custom", [100, 50, 2], [30, 20], [5, 5], [5, 10], 2]); // direct (inline type)
