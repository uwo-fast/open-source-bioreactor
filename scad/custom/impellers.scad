// parameters for physical realization of various stirred-tank impellers
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Each row is one impeller TYPE: the blade geometry that defines it and the process numbers a
// stirred-tank calculation needs.
//   blade_angle  angle from the plane of rotation; undef for a twisted blade
//   twist        twist value passed to linear_extrude; undef for a flat blade
//   width_ratio  blade height (flat) or extrusion height (twisted) over D, only where sourced.
//                Fort's families are Czech Standards at h/D = 0.2. The twisted row is unsourced
//   Po           measured turbulent power number; undef rather than a guess
//   x            Grenville's peak-dissipation constant: Rushton 12, pitched 16, hydrofoil 17
//   pumping      flow direction the blade produces; mirroring the part reverses "axial"
//   Fl           primary flow number where a source lists one; undef where a correlation gives it
//   disc         [disc diameter, blade length] over D for a disc turbine; undef for other types
//   tank         standard layout of a stacked pair over the bore T: [D, lower clearance, spacing],
//                with clearance measured to the lower impeller centreline; undef if unsourced

//                           ["name"              [n_blades, blade_angle, width_ratio, twist], pumping,  [Po,   Po_tol], x,  [Fl,   Fl_tol], disc,         tank             ]

// Six-blade disc turbine, the reference radial impeller. Blades are D/5 high and D/4 long on a
// 3D/4 disc (Middleton & Ramshaw, US 5198156). Measured Np is 4.17 +/- 0.14 (Kaiser 2016);
// Grenville 2017 lists 5.0 as typical. Fl 0.65 is Grenville's typical value. Tank: the standard
// turbine layout is D = T/3 and E = T/3 off the floor (McCabe, Smith & Harriott 1993
// pp. 242-243, after Rushton, Costich & Everett 1950), with the lower impeller of a pair about one
// D up (p. 241). The upper impeller is a further T/3 above. That is at least the one D spacing
// that keeps the power of a pair additive (p. 253), and matches the equal thirds of Rutherford et
// al.'s merging flow at H = T (AIChE J 1996, as shown in Li et al. 2007 Fig. 1).
impeller_rushton_6         = ["rushton_6",        [6,        90,          0.2,         undef], "radial", [4.17, 0.14  ], 12, [0.65, undef], [0.75, 0.25], [1 / 3, 1 / 3, 1 / 3]];

// Four-blade 45 degree pitched blade turbine, the reference axial type. Po is undef on purpose:
// Medek's correlation calculates it from the geometry and states its valid range. h/D = 0.2 is
// from CVS 691020; Medek covers nB 2-8. Tank: this is the layout this project used, not a
// standard. D/T 0.45 is in the middle of Nienow's 0.4-0.5 for axial impellers. The lower impeller
// is 0.9 D off the floor, after Fořt's C/D 1.0 (0.405 T). The pair is 1.0 D apart, the bottom of
// Fitschen's 1-2 D (0.45 T).
impeller_pbt_45_4          = ["pbt_45_4",         [4,        45,          0.2,         undef], "axial",  [undef, undef], 16, [undef, undef], undef,        [0.45, 0.405, 0.45]];

// Folded-blade axial series at constant geometry, blade count varied (Jirout & Rieger, CTU Prague,
// after Fořt 2002). CVS 691010: s/D 1.5, folded at 67/25/48 degrees - not a flat plate at a pitch.
impeller_folded_axial_3    = ["folded_axial_3",   [3,        undef,       0.2,         undef], "axial",  [0.79, undef ], 16, [undef, undef], undef, undef];
impeller_folded_axial_4    = ["folded_axial_4",   [4,        undef,       0.2,         undef], "axial",  [0.99, 0.04  ], 16, [undef, undef], undef, undef];
impeller_folded_axial_6    = ["folded_axial_6",   [6,        undef,       0.2,         undef], "axial",  [1.34, undef ], 16, [undef, undef], undef, undef];

// Printed helicoid designed for this project, 55 degrees of twist (83 at the hub to 53 at the
// tip). Po is uncharacterised: it has not been measured, and Medek's range ends at 60 degrees.
impeller_twisted_paddle_4  = ["twisted_paddle_4", [4,        undef,       0.634921,    55   ], "axial",  [undef, undef], 16, [undef, undef], undef, undef];

impellers = [impeller_rushton_6, impeller_pbt_45_4,
             impeller_folded_axial_3, impeller_folded_axial_4, impeller_folded_axial_6,
             impeller_twisted_paddle_4];

use <../utils/registries.scad>;
function impeller_by_name(name) = registry_by_name(impellers, name, "slslnlLL");
