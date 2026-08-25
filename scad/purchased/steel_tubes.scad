// parameters for physical realization of stainless steel tubing
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rigid metal tube, for anything that has to hold its own shape inside the vessel - today the
// sparge ring's feed riser and the support tube that steadies it, both of which are structure as
// much as fluid path. Flexible tubing is a different part and is not registered here.

// WELDED, not seamless, and that is a considered choice rather than a saving by default.
//
//  - the bore does not decide it. The riser is 187 mm of 3 mm bore carrying about 4 L/min, which
//    costs a few hundred pascals; head() already says the metering valve has to burn 24 kPa. A
//    weld bead is lost in that.
//  - the crevice does not decide it either, though it was the reason to hesitate. The support tube
//    is capped at the ring and takes a drilled side port, so its bore is a DEAD LEG by design -
//    a far worse cleaning problem than a longitudinal ridge, and one both constructions share. If
//    that matters it wants fixing at the dead leg, not at the bead.
//  - TEMPER decides it, and it points at welded. These are HARD temper where McMaster's seamless
//    metric straights are SOFT. Temper does not move the elastic modulus, so bending stiffness is
//    the same either way - what it moves is whether a tube takes a permanent set, and a support
//    tube that stays where it is put is the whole point. Soft is what a BENT sparger would want.
//  - and 4 x 0.5 mm welded is $22.72/m against $181.42/m for the nearest seamless, which is also a
//    1 mm wall and so a 2 mm bore rather than 3.
//
// 316 rather than 304 for the same reason as the shaft: these are wetted, and the reactor is
// chemically sterilised rather than autoclaved, so they meet hypochlorite rather than steam.

// The catalogue lists a maximum pressure per row - 3000 or 4000 psi. It is not registered. This
// vessel's gas path works at about 1 kPa, four orders of magnitude below the weakest row, so the
// number could never select or reject anything and would be a dead field. See
// docs/design-conventions.md on numbers that do not do any work.

// ID is not registered either: it is od - 2 * wall exactly, on every row in the catalogue.

//                              ["name"        part_no      [od, wall], material, construction, temper]
steel_tube_welded_2x0p25  = ["welded_2x0.25", "50415K39", [2,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_2x0p4   = ["welded_2x0.4",  "50415K41", [2,  0.4  ], "316 SS", "welded", "hard"];
steel_tube_welded_2x0p5   = ["welded_2x0.5",  "50415K42", [2,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_3x0p25  = ["welded_3x0.25", "50415K15", [3,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_3x0p4   = ["welded_3x0.4",  "50415K16", [3,  0.4  ], "316 SS", "welded", "hard"];
steel_tube_welded_3x0p5   = ["welded_3x0.5",  "50415K17", [3,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_4x0p25  = ["welded_4x0.25", "50415K18", [4,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_4x0p4   = ["welded_4x0.4",  "50415K19", [4,  0.4  ], "316 SS", "welded", "hard"];
steel_tube_welded_4x0p5   = ["welded_4x0.5",  "50415K21", [4,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_5x0p25  = ["welded_5x0.25", "50415K22", [5,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_5x0p4   = ["welded_5x0.4",  "50415K23", [5,  0.4  ], "316 SS", "welded", "hard"];
steel_tube_welded_5x0p5   = ["welded_5x0.5",  "50415K24", [5,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_6x0p25  = ["welded_6x0.25", "50415K25", [6,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_6x0p4   = ["welded_6x0.4",  "50415K26", [6,  0.4  ], "316 SS", "welded", "hard"];
steel_tube_welded_6x0p5   = ["welded_6x0.5",  "50415K27", [6,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_7x0p25  = ["welded_7x0.25", "50415K28", [7,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_7x0p5   = ["welded_7x0.5",  "50415K31", [7,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_8x0p25  = ["welded_8x0.25", "50415K32", [8,  0.25 ], "316 SS", "welded", "hard"];
steel_tube_welded_8x0p4   = ["welded_8x0.4",  "50415K33", [8,  0.4  ], "316 SS", "welded", "hard"];
steel_tube_welded_8x0p5   = ["welded_8x0.5",  "50415K34", [8,  0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_10x0p5  = ["welded_10x0.5", "50415K35", [10, 0.5  ], "316 SS", "welded", "hard"];
steel_tube_welded_12x0p5  = ["welded_12x0.5", "50415K36", [12, 0.5  ], "316 SS", "welded", "hard"];

// What is REACHABLE today is only the first half of that. A tube has to pass the bore of the port
// it hangs from, and the widest tube bore either registered port set carries is air_in and air_out
// at 3 mm radius - so 6 mm OD and under. 7 to 12 are registered anyway, for the same reason
// shafts.scad carries 600 and 800 mm: they are the same part in another size, and what excludes
// them is a NUMBER IN A PORT TABLE, which a harvest or drain line on a bigger jar would simply
// change. That is the opposite of the twenty-five plug o-rings that were discarded - those were
// shut out by a derived cord ceiling that no edit could move.
//
// The catalogue's 1 mm OD row is deliberately absent: a 0.5 mm bore fouls on algae and nothing
// grips a 1 mm tube.

// The catalogue's 7 mm OD comes in 0.25 and 0.5 wall only - there is no 0.4, and that is the
// catalogue's gap rather than an omission here.

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

// Accessors live here rather than in a steel_tube.scad, because there is no geometry to separate
// from them - the same split shafts.scad and set_screws.scad use.
function steel_tube_name(type)          = type[0];
function steel_tube_part_number(type)   = type[1];
function steel_tube_od(type)            = type[2][0];
function steel_tube_wall(type)          = type[2][1];
function steel_tube_material(type)      = type[3];
function steel_tube_construction(type)  = type[4];
function steel_tube_temper(type)        = type[5];

// derived
function steel_tube_id(type) = steel_tube_od(type) - 2 * steel_tube_wall(type);
// Second moment of the annulus, mm^4. What makes a tube structure rather than plumbing, and the
// reason wall thickness is a stiffness choice here and not a pressure one.
function steel_tube_second_moment(type) =
  PI / 64 * (pow(steel_tube_od(type), 4) - pow(steel_tube_id(type), 4));

// Young's modulus for austenitic stainless, MPa. Same for every row - temper moves yield, not
// stiffness - so it is a property of the material rather than of a row.
function steel_tube_modulus() = 193000;

// Sold in 0.5, 1 and 2 m straights, so anything this model asks for is a cut from stock and the
// purchase list carries a stock length and a cut list rather than a quantity of parts.
function steel_tube_stock_lengths() = [500, 1000, 2000];

// The shortest stock length that yields `count` pieces of `length`, or undef if none does.
function steel_tube_stock_for(length, count) =
  let (_fit = [for (s = steel_tube_stock_lengths()) if (s >= length * count) s])
    len(_fit) == 0 ? undef : _fit[0];
