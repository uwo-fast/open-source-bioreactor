/**
 * @brief What it costs to squeeze a flat elastomer gasket, and what that costs the glass.
 *
 * This is the only load path in the reactor. The joint's bolt COUNT comes from a spacing rule
 * (utils/bolt_pattern.scad) which says nothing about force, and the vessel runs at about a
 * kilopascal, so nothing else here pushes on anything. What the bolts actually work against is the
 * gasket refusing to be compressed.
 *
 * Everything below is REPORTED, never asserted on. The modulus is correlated from hardness rather
 * than measured, and the compression model is a standard elastomer approximation rather than a
 * fit to this sheet, so these are order-of-magnitude figures for judging a design - not numbers to
 * cut a part to. See docs/design-conventions.md on bands being reported rather than enforced.
 */

// Young's modulus from Shore A hardness. Gent's relation, which is the standard way to get one from
// the other and reproduces the usual tabulated values - 3.61 MPa at 60A against a book figure of
// 3.6. Derived rather than registered so the sheet's hardness stays the single statement of how
// soft it is.
function gasket_youngs_modulus(shore_a) =
  0.0981 * (56 + 7.62336 * shore_a) / (0.137505 * (254 - 2.54 * shore_a));

// Shape factor: loaded area over the area free to bulge. A pad much wider than it is thick has
// nowhere to go when squeezed, which is why a wide gasket is not simply a bigger version of a
// narrow one.
function gasket_shape_factor(width, thickness) = width / (2 * thickness);

// Compression modulus, which is what a constrained pad actually resists with. Ea = E(1 + 2S^2), so
// the stiffness grows with the SQUARE of the width while the area grows with the first power - a
// gasket twice as wide takes roughly eight times the force to squeeze the same fraction.
function gasket_apparent_modulus(shore_a, width, thickness) =
  gasket_youngs_modulus(shore_a) * (1 + 2 * pow(gasket_shape_factor(width, thickness), 2));

// Area of the annulus, from its mean diameter and width.
function gasket_seat_area(mean_diameter, width) = PI * mean_diameter * width;

// Force to hold the gasket at a given fractional compression, in newtons for mm and MPa inputs.
function gasket_seating_force(shore_a, width, thickness, mean_diameter, compression) =
  compression
  * gasket_apparent_modulus(shore_a, width, thickness)
  * gasket_seat_area(mean_diameter, width);

// The same force back as a pressure on whatever the gasket stands on. Here that is a glass rim,
// which is strong in compression and unforgiving of anything else, so it is worth watching.
function gasket_seat_stress(shore_a, width, thickness, compression) =
  compression * gasket_apparent_modulus(shore_a, width, thickness);

/**
 * @brief How far a nut turns to take the gasket to a given compression, in degrees past snug.
 *
 * The one figure here that does NOT depend on the modulus, and so the only one a builder should
 * work to. Force reaches a bolt through a friction coefficient nobody can measure on the bench -
 * across the 0.20 to 0.30 an unlubricated stainless nut plausibly spans, one preload is a 40 %
 * band of torque, and 18-8 galls, which is what makes the coefficient unpredictable in the first
 * place. A turn is geometry: thickness times compression is the travel, and the pitch converts it.
 *
 * It assumes everything else in the stack is rigid, which is worth checking rather than believing.
 * Steel is: at these loads an M8 post stretches under a thousandth of a millimetre, well under a
 * percent of the travel. Printed flanges are not, and they creep, so read this as the floor of
 * what the joint takes and expect to go back to it.
 */
function gasket_seating_turn(travel, thread_pitch) = 360 * travel / thread_pitch;
