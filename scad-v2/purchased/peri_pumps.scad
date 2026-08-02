// parameters for physical realization of various peristaltic pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// The carrier diameter is a pump dimension, not a motor dimension. It sets how far the
// rollers sit from the shaft, and together with the roller offset it sets the occlusion
// diameter. It has to clear whichever motor drives the pump, but that is a coupling check
// made where the pump and motor meet, not a value registered here.

//                  ["name"     [carrier_dia, carrier_base_th, carrier_allowance], [roller_od, roller_id, roller_len, roller_n, roller_offset], [cassette_h, cassette_wall, cassette_allowance], tube_dia, shaft_bore]
generic_peri_pump = ["generic", [50,          4,               0.2              ], [20,        10,        20,         3,        -1.5         ], [28,         3,             0.3               ], 3,        4         ];

peri_pumps = [generic_peri_pump];

use <peri_pump.scad>

// example usage (open this file directly to preview)
// peri_pump(generic_peri_pump);
