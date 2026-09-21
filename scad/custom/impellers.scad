// parameters for physical realization of various stirred-tank impellers
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A row is one impeller TYPE: the blade geometry that defines it and the process numbers a
// stirred-tank calculation needs.
//   blade_angle  from the plane of rotation; undef on a twisted blade
//   twist        linear_extrude's pitch specifier; undef on a flat blade (docs/agitation.md)
//   width_ratio  blade height (flat) or extrusion height (twisted) over D; only where sourced.
//                Fort's families are Czech Standards at h/D = 0.2; the twisted row's is unsourced
//   Po           turbulent power number, measured; undef rather than guessed
//   x            Grenville's peak-dissipation constant: Rushton 12, pitched 16, hydrofoil 17
//   pumping      what the blade does to the fluid; mirroring the part reverses "axial"

//                           ["name"              [n_blades, blade_angle, width_ratio, twist], pumping,  [Po,   Po_tol], x ]

// Six-blade disc turbine, the reference radial impeller. Blade D/4 (Zhou 2003); Np 4.17 +/- 0.14
// (Kaiser 2016).
impeller_rushton_6         = ["rushton_6",        [6,        90,          0.25,        undef], "radial", [4.17, 0.14  ], 12];

// Four-blade 45 degree pitched blade turbine, the reference axial type. Po undef on purpose:
// Medek's correlation gives it from the geometry and reports its envelope. h/D = 0.2 from
// CVS 691020; Medek spans nB 2-8.
impeller_pbt_45_4          = ["pbt_45_4",         [4,        45,          0.2,         undef], "axial",  [undef, undef], 16];

// Folded-blade axial series at constant geometry, blade count varied (Jirout & Rieger, CTU Prague,
// after Fořt 2002). CVS 691010: s/D 1.5, folded at 67/25/48 degrees - not a flat plate at a pitch.
impeller_folded_axial_3    = ["folded_axial_3",   [3,        undef,       0.2,         undef], "axial",  [0.79, undef ], 16];
impeller_folded_axial_4    = ["folded_axial_4",   [4,        undef,       0.2,         undef], "axial",  [0.99, 0.04  ], 16];
impeller_folded_axial_6    = ["folded_axial_6",   [6,        undef,       0.2,         undef], "axial",  [1.34, undef ], 16];

// This project's printed helicoid, 55 degrees of twist (83 at the hub to 53 at the tip). Po is
// uncharacterised: no measurement, and Medek's envelope stops at 60 degrees.
impeller_twisted_paddle_4  = ["twisted_paddle_4", [4,        undef,       0.634921,    55   ], "axial",  [undef, undef], 16];

impellers = [impeller_rushton_6, impeller_pbt_45_4,
             impeller_folded_axial_3, impeller_folded_axial_4, impeller_folded_axial_6,
             impeller_twisted_paddle_4];

use <../utils/registries.scad>;
function impeller_by_name(name) = registry_by_name(impellers, name);
