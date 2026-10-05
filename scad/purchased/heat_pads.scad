// parameters for physical realization of silicone heating pads
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Silicone rubber over a nichrome element, run from the reactor's 12 V rail and held bare against
// the jar's outside. No built-in thermostat: whatever switches the rail controls them. Size,
// thickness, cold resistance and lead length are measured on a delivered pad; volts and watts are
// the listing's. At 12 V the measured resistance is what sets the power, not the watts column.

//                       ["name",       part_no,      [length, height, thickness], [volts, watts], ohms, lead]
// Generic 4-pack, 12 V 20 W, 150 x 50 mm - https://www.amazon.ca/dp/B0C4GX3F76
// Measured 2026-10-04: 7.6 ohm cold, so 18.9 W at 12 V; 320 mm leads.
heat_pad_20w_150x50 = ["20W 150x50", "B0C4GX3F76", [150,    50,     1.85     ], [12,    20   ], 7.6,  320 ];

// MECCANIXITY 2-pack, 12 V 30 W, 150 x 50 mm - https://www.amazon.ca/dp/B0GWNFH6LH
// Pending delivery: registered once measured. The listing gives only the 150 x 50, and its cold
// resistance should come in near 12^2 / 30 = 4.8 ohm.
// heat_pad_30w_150x50 = ["30W 150x50", "B0GWNFH6LH", [150,    50,     undef    ], [12,    30   ], undef, undef];

heat_pads = [heat_pad_20w_150x50];

use <../utils/registries.scad>;
function heat_pad_by_name(name) = registry_by_name(heat_pads, name);

use <heat_pad.scad>

// example usage - keep commented, this file is include'd
// heat_pad(heat_pad_20w_150x50);
