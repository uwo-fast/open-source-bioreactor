/**
 * @file elastomer.scad
 * @brief What a rubber pad does under compression, and what it costs to seat one.
 *
 * The material and pad relations are properties of the rubber, not of anything cut from it; the
 * seat relations below them are for an annular gasket, which is the only shape this reactor seats.
 *
 * ALL OF IT IS REPORTED, NEVER ASSERTED ON: the modulus is correlated from hardness rather than
 * measured, so these judge a design rather than cut a part. See docs/design-conventions.md.
 * Sets no $fn.
 */

// Shore A to Young's modulus, MPa. Gent's relation; 3.61 MPa at 60A against a book 3.6.
function elastomer_youngs_modulus(shore_a) =
  0.0981 * (56 + 7.62336 * shore_a) / (0.137505 * (254 - 2.54 * shore_a));

// A bonded pad is stiffer than the bulk material by how much of it cannot bulge sideways.
function elastomer_shape_factor(width, thickness) = width / (2 * thickness);
function elastomer_apparent_modulus(shore_a, width, thickness) =
  elastomer_youngs_modulus(shore_a) * (1 + 2 * pow(elastomer_shape_factor(width, thickness), 2));

// ---- an annular gasket on a seat ----

function gasket_seat_area(mean_diameter, width) = PI * mean_diameter * width;
function gasket_seat_stress(shore_a, width, thickness, compression) =
  compression * elastomer_apparent_modulus(shore_a, width, thickness);
function gasket_seating_force(shore_a, width, thickness, mean_diameter, compression) =
  gasket_seat_stress(shore_a, width, thickness, compression)
  * gasket_seat_area(mean_diameter, width);
