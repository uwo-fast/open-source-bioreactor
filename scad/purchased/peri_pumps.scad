// parameters for physical realization of peristaltic dosing pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A BOUGHT UNIT, drawn as an envelope rather than modelled. The Kamoer is a complete pump - head,
// motor and gearbox in one body with a snap-in head - so there is nothing here for the model to
// design. What it needs from the pump is where it sits, what it displaces and what tube it takes.
//
// custom/peri_pump_head.scad is the other half of this story: a printed head of our own, which is
// a stretch goal rather than this build. It began as a replica of this part and keeps its own
// prefix so the two can never collide.

// FOUR FIELDS, AND EACH ONE DOES SOMETHING. The catalogue also gives 5.2-90 mL/min, 12 V, 0.25 A
// and 5 W, and none of them are here: nothing in this model doses, so a flow range would select
// and reject nothing. That is the same reason steel_tubes.scad leaves out its pressure rating.
// They live on the purchase list, where a person reads them.
//
// THE ENVELOPE IS THE CATALOGUE'S, NOT A MEASUREMENT, and it is an outside rather than a shape:
// 67 x 55 x 41 is the box the pump fits in. Drawn as that box, because a prettier guess at the
// body would be a shape nobody has checked - see docs/design-conventions.md on reporting a
// departure rather than dressing it up. Measure one and this row can carry the real thing.

//                        ["name"                part_no          [l,  w,  h ], [tube_id, tube_od]]
peri_pump_kamoer_nkp   = ["Kamoer NKP-DC-S10B", "NKP-DC-S10B",   [67, 55, 41], [3,       5      ]];

peri_pumps = [peri_pump_kamoer_nkp];

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function peri_pump_by_name(name) = registry_by_name(peri_pumps, name);

use <peri_pump.scad>; // peri_pump() draws the envelope these rows describe

// example usage - keep commented, this file is include'd and a bare call would draw a pump into
// every consumer (see shaft_couplings.scad for the same note)
// peri_pump(peri_pump_kamoer_nkp);
