/**
 * @file elastomer.scad
 * @brief Compression stiffness of a rubber pad and the force needed to seat a gasket.
 *
 * The material and pad relations depend only on the rubber, not on the shape cut from it. The
 * seat relations below them are for an annular gasket, the only gasket shape in this reactor.
 *
 * ALL RESULTS ARE REPORTED, NEVER ASSERTED: the modulus is estimated from hardness, not measured,
 * so these values are for judging a design, not for sizing a part.
 * Sets no $fn.
 */

// Shore A to Young's modulus, MPa. Gent's relation; gives 3.61 MPa at 60A (book value 3.6).
function elastomer_youngs_modulus(shore_a) =
  0.0981 * (56 + 7.62336 * shore_a) / (0.137505 * (254 - 2.54 * shore_a));

// A bonded pad is stiffer than the bulk material because it cannot bulge sideways; the shape factor
// sets how much stiffer.
function elastomer_shape_factor(width, thickness) = width / (2 * thickness);
function elastomer_apparent_modulus(shore_a, width, thickness) =
  elastomer_youngs_modulus(shore_a) * (1 + 2 * pow(elastomer_shape_factor(width, thickness), 2));

// ---- annular gasket on a seat ----

function gasket_seat_area(mean_diameter, width) = PI * mean_diameter * width;
function gasket_seat_stress(shore_a, width, thickness, compression) =
  compression * elastomer_apparent_modulus(shore_a, width, thickness);
function gasket_seating_force(shore_a, width, thickness, mean_diameter, compression) =
  gasket_seat_stress(shore_a, width, thickness, compression)
  * gasket_seat_area(mean_diameter, width);
