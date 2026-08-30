// parameters for physical realization of worm-drive hose clamps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Registered because the MODEL READS ONE OF ITS DIMENSIONS. The sparge riser stands proud of its
// port so a clamp can land on it, and how far proud is the band's width plus lead-in either side -
// so the band is geometry here, not just a line on the purchase list. It was "about 9 mm" in a
// comment while the purchase list knew 7.938, which is one physical thing with two expressions and
// the defect docs/design-conventions.md names as this repo's recurring one.

// BAND WIDTH IS THE ONLY DIMENSION REGISTERED, and the omissions are deliberate.
//
//  - the CLAMPING RANGE selects nothing here. What a clamp closes on is flexible tubing over a
//    barb, and tubing is a commodity specified by bore: its outside diameter follows a wall this
//    model never sees. So a range would be a number nothing could compare against - the same
//    reasoning that keeps the pressure rating out of steel_tubes.scad. It decided which clamp to
//    buy, and that argument lives in docs/procurement.md where it belongs.
//  - MAXIMUM TORQUE is an assembly instruction rather than a dimension. 7.5 in-lbs is a galling
//    limit, austenitic screw in austenitic housing, and docs/build.md carries it beside the rest of
//    what a builder does with a tool in hand.
//  - the REJECTED GRADES are not registered either. McMaster sell this clamp with a zinc-plated,
//    410, 305 or 316 screw; why 316 is in procurement.md, and a row per grade would register four
//    parts to buy one.

//                        ["name"          part_no     band_w  material  ]
clamp_sae4_316_5p16 = ["SAE 4 316 5/16", "5011T141", 7.9375, "316 SS"];

// One row, and that is the whole registry rather than an oversight. The band width is what fixes
// the size: 5/16 in is the narrowest McMaster offer this clamp in, and its smallest range is the
// SAE 4 at 5.6-15.875 mm, which reaches every joint on this gas line. A second size would be a
// second part number to buy and stock for nothing.

hose_clamps = [clamp_sae4_316_5p16];

// Accessors live here rather than in a hose_clamp.scad, because there is no geometry to separate
// from them - the same split shafts.scad and steel_tubes.scad use.
function hose_clamp_name(type)        = type[0];
function hose_clamp_part_number(type) = type[1];
function hose_clamp_band_width(type)  = type[2];
function hose_clamp_material(type)    = type[3];

// example usage - keep commented, this file is include'd and a bare echo would fire in every
// consumer (see shaft_couplings.scad for the same note)
// echo(hose_clamp_band_width(clamp_sae4_316_5p16));
