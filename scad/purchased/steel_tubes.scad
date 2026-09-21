// parameters for physical realization of stainless steel tubing
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rigid tube for what has to hold its shape inside the vessel. At 4 mm OD the catalogue offers
// 0.25, 0.4 and 0.5 mm walls. Welded, hard temper: McMaster's seamless metric straights are soft.
// 316 because wetted and chemically sterilised. Pressure rating is not registered, and ID is
// od - 2 * wall exactly.

//                          ["name"           part_no     [od, wall],  material, construction, temper]
steel_tube_welded_2x0p25  = ["welded_2x0.25", "50415K39", [2,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_2x0p4   = ["welded_2x0.4",  "50415K41", [2,  0.4  ], "316 SS", "welded",     "hard"];
steel_tube_welded_2x0p5   = ["welded_2x0.5",  "50415K42", [2,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_3x0p25  = ["welded_3x0.25", "50415K15", [3,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_3x0p4   = ["welded_3x0.4",  "50415K16", [3,  0.4  ], "316 SS", "welded",     "hard"];
steel_tube_welded_3x0p5   = ["welded_3x0.5",  "50415K17", [3,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_4x0p25  = ["welded_4x0.25", "50415K18", [4,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_4x0p4   = ["welded_4x0.4",  "50415K19", [4,  0.4  ], "316 SS", "welded",     "hard"];
steel_tube_welded_4x0p5   = ["welded_4x0.5",  "50415K21", [4,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_5x0p25  = ["welded_5x0.25", "50415K22", [5,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_5x0p4   = ["welded_5x0.4",  "50415K23", [5,  0.4  ], "316 SS", "welded",     "hard"];
steel_tube_welded_5x0p5   = ["welded_5x0.5",  "50415K24", [5,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_6x0p25  = ["welded_6x0.25", "50415K25", [6,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_6x0p4   = ["welded_6x0.4",  "50415K26", [6,  0.4  ], "316 SS", "welded",     "hard"];
steel_tube_welded_6x0p5   = ["welded_6x0.5",  "50415K27", [6,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_7x0p25  = ["welded_7x0.25", "50415K28", [7,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_7x0p5   = ["welded_7x0.5",  "50415K31", [7,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_8x0p25  = ["welded_8x0.25", "50415K32", [8,  0.25 ], "316 SS", "welded",     "hard"];
steel_tube_welded_8x0p4   = ["welded_8x0.4",  "50415K33", [8,  0.4  ], "316 SS", "welded",     "hard"];
steel_tube_welded_8x0p5   = ["welded_8x0.5",  "50415K34", [8,  0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_10x0p5  = ["welded_10x0.5", "50415K35", [10, 0.5  ], "316 SS", "welded",     "hard"];
steel_tube_welded_12x0p5  = ["welded_12x0.5", "50415K36", [12, 0.5  ], "316 SS", "welded",     "hard"];

// The gas ports are bored for the riser, so a wider tube costs flange, not reach: 2-5 mm OD sit
// on a mini, 6-8 on a midi, 10-12 on a std, and flange radius sets the smallest mouth a port set
// fits. The 1 mm OD row is absent (a 0.5 mm bore fouls on algae); 7 mm has no 0.4 wall in the
// catalogue.

steel_tubes = [
  steel_tube_welded_2x0p25, steel_tube_welded_2x0p4, steel_tube_welded_2x0p5,
  steel_tube_welded_3x0p25, steel_tube_welded_3x0p4, steel_tube_welded_3x0p5,
  steel_tube_welded_4x0p25, steel_tube_welded_4x0p4, steel_tube_welded_4x0p5,
  steel_tube_welded_5x0p25, steel_tube_welded_5x0p4, steel_tube_welded_5x0p5,
  steel_tube_welded_6x0p25, steel_tube_welded_6x0p4, steel_tube_welded_6x0p5,
  steel_tube_welded_7x0p25, steel_tube_welded_7x0p5,
  steel_tube_welded_8x0p25, steel_tube_welded_8x0p4, steel_tube_welded_8x0p5,
  steel_tube_welded_10x0p5, steel_tube_welded_12x0p5,
];

function steel_tube_name(type)          = type[0];
function steel_tube_part_number(type)   = type[1];
function steel_tube_od(type)            = type[2][0];
function steel_tube_wall(type)          = type[2][1];
function steel_tube_material(type)      = type[3];
function steel_tube_construction(type)  = type[4];
function steel_tube_temper(type)        = type[5];

// derived
function steel_tube_id(type) = steel_tube_od(type) - 2 * steel_tube_wall(type);
// Second moment of the annulus, mm^4; wall thickness is a stiffness choice here.
function steel_tube_second_moment(type) =
  PI / 64 * (pow(steel_tube_od(type), 4) - pow(steel_tube_id(type), 4));

// Young's modulus for austenitic stainless, MPa; temper moves yield, not stiffness.
function steel_tube_modulus() = 193000;

// Sold in 0.5, 1 and 2 m straights; the purchase list carries a stock length and a cut list.
function steel_tube_stock_lengths() = [500, 1000, 2000];

// The shortest stock length that yields `count` pieces of `length`, or undef if none does.
function steel_tube_stock_for(length, count) =
  let (_fit = [for (s = steel_tube_stock_lengths()) if (s >= length * count) s])
    len(_fit) == 0 ? undef : _fit[0];
