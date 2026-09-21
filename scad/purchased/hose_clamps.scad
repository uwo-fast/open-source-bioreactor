// parameters for physical realization of worm-drive hose clamps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Band width is the only dimension: the clamping range closes on tubing this model never sees.

//                        ["name"          part_no     band_w  material  ]
clamp_sae4_316_5p16 = ["SAE 4 316 5/16", "5011T141", 7.9375, "316 SS"];

// 5/16 in is the narrowest band McMaster offer, and SAE 4 (5.6-15.875 mm) reaches every joint.

hose_clamps = [clamp_sae4_316_5p16];

function hose_clamp_name(type)        = type[0];
function hose_clamp_part_number(type) = type[1];
function hose_clamp_band_width(type)  = type[2];
function hose_clamp_material(type)    = type[3];
