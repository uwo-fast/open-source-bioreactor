// parameters for physical realization of various stirred-tank impellers
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A row is one impeller TYPE, not one part. It carries the blade geometry that defines the type
// and the two process numbers a stirred-tank calculation needs. Po and x are properties of the
// shape, so they live here rather than in utils/stirred_tank.scad, which consumes them - the
// giveaway was that file having to name impellers in its own function names.

// blade_angle is measured from the plane of rotation and is undef on a twisted blade, where it
// varies with radius. twist is linear_extrude's pitch specifier and is undef on a flat blade. A
// type never carries both; see docs/agitation.md for why twist is a pitch and not an angle.

// width_ratio is the blade's own dimension over the impeller diameter - blade height for a flat
// turbine, extrusion height for a twisted one. Registered only where a source gives it. Both of
// Fort's families are Czech Standards and both carry h/D = 0.2, which is where every 0.2 below
// comes from; the twisted row's 0.634921 is this project's own blade and has no source.

// Po is the turbulent power number P/(rho N^3 D^5). Measured unless the row comment says
// otherwise, and undef rather than guessed where no measurement exists: stirred_tank.scad carries
// Medek's correlation for pitched blades inside its validity envelope. Po_tol is the reported
// uncertainty, undef when the source gives none.

// x is the impeller constant in Grenville's peak-dissipation correlation - Rushton 12, pitched
// blade 16, hydrofoil 17, trade press at +/-15%. It is a shape property, so it rides with the row.

// pumping is what the blade does to the fluid, not which way the shaft turns: "radial", or
// "axial" with the direction set by blade handedness. Mirroring a row's part reverses it.

//                           ["name"              [n_blades, blade_angle, width_ratio, twist], pumping,  [Po,   Po_tol], x ]

// Six-blade disc turbine. Geometry and Np are separately sourced: blade width and height both
// D/4 with D/T = 1/3 and four baffles at T/10 (Zhou 2003), Np measured at 4.17 +/- 0.14 under the
// standard definition (Kaiser 2016). The reference radial impeller.
impeller_rushton_6         = ["rushton_6",        [6,        90,          0.25,        undef], "radial", [4.17, 0.14  ], 12];

// Four-blade 45 degree pitched blade turbine, the reference axial type. Po is deliberately undef:
// Medek's correlation in stirred_tank.scad gives it as a function of n_B, C/D, T/D, H/T and blade
// angle, which is more useful than a single number and reports when the geometry leaves its
// envelope. Blade width is h/D = 0.2, from the Czech Standard CVS 691020 geometry Fort et al.
// tested; his simple PBTs are drawn at 3 and 6 blades and Medek's correlation spans nB 2-8, so a
// four-blade row sits inside the correlation without being literally one of his sketches.
impeller_pbt_45_4          = ["pbt_45_4",         [4,        45,          0.2,         undef], "axial",  [undef, undef], 16];

// Folded-blade axial series, measured at constant geometry with only blade count varied, so the
// three rows are comparable to each other: 3/4/6 blades give 0.79/0.99/1.34. Jirout & Rieger, CTU
// Prague, reproducing Fořt et al. 2002. Only the 4-blade row carries a reported tolerance. Blade
// width h/D = 0.2 as above, but note the blade is FOLDED - Czech Standard CVS 691010 puts it at
// s/D 1.5 with three angles, 67/25/48 degrees - so drawing one is not a flat plate at a pitch.
impeller_folded_axial_3    = ["folded_axial_3",   [3,        undef,       0.2,         undef], "axial",  [0.79, undef ], 16];
impeller_folded_axial_4    = ["folded_axial_4",   [4,        undef,       0.2,         undef], "axial",  [0.99, 0.04  ], 16];
impeller_folded_axial_6    = ["folded_axial_6",   [6,        undef,       0.2,         undef], "axial",  [1.34, undef ], 16];

// This project's printed blade: a constant-pitch helicoid, 55 degrees of twist over its height,
// so the blade angle runs 83 degrees at the hub to 53 at the tip. Po is UNCHARACTERISED - no
// measurement exists for this shape and none of the correlations reach it, since Medek's envelope
// stops at 60 degrees. head.scad currently borrows impeller_folded_axial_4's 0.99, the closest
// measured analogue, and Patwardhan and Kumaresan both find twist LOWERS Po, so that borrowing is
// an over-estimate and everything derived from it is conservative. A bench power-number
// measurement would settle it; see TODO.md.
impeller_twisted_paddle_4  = ["twisted_paddle_4", [4,        undef,       0.634921,    55   ], "axial",  [undef, undef], 16];

impellers = [impeller_rushton_6, impeller_pbt_45_4,
             impeller_folded_axial_3, impeller_folded_axial_4, impeller_folded_axial_6,
             impeller_twisted_paddle_4];

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function impeller_by_name(name) = registry_by_name(impellers, name);

// Accessors are in impeller.scad. Pure data - no geometry, so consumers can include it freely.
