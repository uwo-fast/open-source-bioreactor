// parameters for physical realization of various culture vessels (jars)
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// The mouth bore is a measured fact, so it is registered here; the shoulder-to-neck corner
// radius is the eyeballed value and is solved from it by vessel_neck_corner_radius().

//                     ["name"                  [height,    diameter,   thickness], [opening_dia, neck], [corner_rad, corner_rad_base], [punt_h, punt_w], rim_rad]
generic_vessel       = ["generic",              [300,       200,        5        ], [150,         10  ], [10.0,        10.0          ], [10,      50    ], 2   ];

// Commodity 10 L airtight soda-lime glass jar — https://www.alibaba.com/product-detail/10-Liter-Glass-Jar-Airtight-Glass_10000010556695.html
jar_10L_220x305      = ["jar_10L_220x305",      [305,       220,        5        ], [143,         25  ], [25,         12.5           ], [5,      30    ], 2    ];

// Almcmy 1 gallon glass cookie jar — https://a.co/d/0387jpNx
jar_1gal_180x197     = ["jar_1gal_180x197",     [197,       180,        5        ], [148,         12.5], [12.5,        12.5          ], [7,     100   ], 2.5     ];

// Big Mouth Bubbler EVO 2, 6.5 gallon glass fermentor — OD and height are the listed 12 in
// and 18.5 in — https://www.northernbrewer.com/products/big-mouth-bubbler-evo-2-6-5-gallon
jar_6p5gal_305x470   = ["jar_6p5gal_305x470",   [18.5*25.4, 12*25.4,    12       ], [137,         50  ], [50.0,        50.0          ], [15,     160   ], 0    ];

// Mainstays large straight-sided glass canister, 1.5 L
// https://www.walmart.ca/en/ip/Main-Stays-Glass-Canister-Large/6000199421846
jar_1p5L_109x215     = ["jar_1p5L_109x215",     [215,       109.22,     4        ], [87.5,        22.5], [7.5,         7.5           ], [7,     15    ], 0    ];

vessels = [generic_vessel, jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215];

use <vessel.scad>;

// example usage (open this file directly to preview)
//vessel(generic_vessel, angle=180);                                     // registered set, cross section
// translate([250, 0, 0]) vessel(["custom", [100, 50, 2], [30, 20], [5, 5], [5, 10], 2]); // direct (inline type)
