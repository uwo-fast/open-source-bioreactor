// parameters for physical realization of various culture vessels (jars)
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// The mouth bore is measured; the shoulder-to-neck corner radius is eyeballed and solved from it
// by vessel_neck_corner_radius().

//                     ["name"                  [height,    diameter,   thickness], [opening_dia, neck], [corner_rad, corner_rad_base], [punt_h, punt_w], rim_rad]
generic_vessel       = ["generic",              [300,       200,        5        ], [150,         10  ], [10.0,        10.0          ], [10,      50    ], 2   ];

// Commodity 10 L airtight soda-lime glass jar — https://www.alibaba.com/product-detail/10-Liter-Glass-Jar-Airtight-Glass_10000010556695.html
// Mouth measured at 142.2.
jar_10L_220x305      = ["jar_10L_220x305",      [305,       220,        5        ], [142.2,       25  ], [25,         12.5           ], [5,      30    ], 2    ];

// Almcmy 1 gallon glass cookie jar — https://a.co/d/0387jpNx
jar_1gal_180x197     = ["jar_1gal_180x197",     [197,       180,        5        ], [148,         12.5], [10.0,        12.5          ], [7,     100   ], 2.5   ];

// Big Mouth Bubbler EVO 2, 6.5 gallon glass fermentor — OD and height are the listed 12 in
// and 18.5 in — https://www.northernbrewer.com/products/big-mouth-bubbler-evo-2-6-5-gallon
jar_6p5gal_305x470   = ["jar_6p5gal_305x470",   [18.5*25.4, 12*25.4,    12       ], [137,         50  ], [50.0,        50.0          ], [15,     160  ], undef ];

// Mainstays large straight-sided glass canister, 1.5 L
// https://www.walmart.ca/en/ip/Main-Stays-Glass-Canister-Large/6000199421846
jar_1p5L_109x215     = ["jar_1p5L_109x215",     [215,       109.22,     4        ], [87.5,        22.5], [6.0,         7.5           ], [7,     15    ], 0     ];

// Uline S-19317P, 1 gallon wide-mouth glass jar, 110/400 plastic cap
// https://www.uline.ca/Product/Detail/S-19317P/Jars/Clear-Wide-Mouth-Glass-Jars-1-Gallon-4-Opening-Plastic-Cap
// Opening is listed as 4" (101.6) but the bore below the lip measures 95.8. rim_rad 0: the lip
// rolls over in line with the wall, with no flat sealing face. The 110/400 threads are not
// modelled.
jar_1gal_155x251     = ["jar_1gal_155x251",     [251,       155.3,      3        ], [95.8,        30  ], [25,          14             ], [6,      73   ], 0    ];

// Only orderable rows are swept; generic_vessel stays defined and out of it.
vessels = [jar_10L_220x305, jar_1gal_180x197, jar_6p5gal_305x470, jar_1p5L_109x215, jar_1gal_155x251];

function vessel_by_name(name) = registry_by_name(vessels, name);

use <vessel.scad>;
use <../utils/registries.scad>;

// example usage (open this file directly to preview)
// vessel(jar_1gal_155x251, angle=180);                                     // registered set, cross section
// translate([250, 0, 0]) vessel(["custom", [100, 50, 2], [30, 20], [5, 5], [5, 10], 2]); // direct (inline type)
