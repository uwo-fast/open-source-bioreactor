/**
 * @file impeller.scad
 * @brief Highly customizable impeller module
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * This file contains a customizable impeller module, it was inspired by the following article:
 * https://infinityplays.com/3d-part-design-with-openscad-57-a-universal-propeller-impeller-design-module/.
 *
 *
 */

// ----- registry accessors -----
//
// One impeller TYPE from impellers.scad. The registry holds what defines the shape and what a
// stirred-tank calculation needs; the module below draws whatever it is handed.

function impeller_name(type) = type[0];
function impeller_blades(type) = type[1][0]; // number of blades
function impeller_blade_angle(type) = type[1][1]; // degrees from the plane of rotation, undef when twisted
function impeller_width_ratio(type) = type[1][2]; // blade dimension / impeller diameter, undef when unsourced
function impeller_twist(type) = type[1][3]; // linear_extrude pitch specifier, undef on a flat blade
function impeller_pumping(type) = type[2]; // "radial" or "axial"
function impeller_power_number(type) = type[3][0]; // turbulent Po, undef when unmeasured
function impeller_power_number_tol(type) = type[3][1]; // reported uncertainty, undef when the source gives none
function impeller_dissipation_factor(type) = type[4]; // x in Grenville's peak-dissipation correlation

// A twisted blade has no single angle, so callers that need one ask whether the type is twisted
// rather than testing the angle field for undef.
function impeller_is_twisted(type) = !is_undef(impeller_twist(type));

// Po is the one number a caller is most likely to need and most likely to be missing. Reporting
// the substitute rather than silently borrowing is the whole point of registering the type.
function impeller_has_power_number(type) = !is_undef(impeller_power_number(type));

// What the blade occupies ALONG THE SHAFT, which is not its registered width. width_ratio is the
// blade's own dimension; a flat blade set at an angle projects only sin(angle) of it onto the axis,
// a vertical one (90 degrees) projects all of it, and a twisted blade's extrusion height IS the
// axial span already. So the same registry field means the same physical thing on every row and
// this is where it gets turned into a height.
//
// A TILTED PLATE IS NOT A LINE. Its thickness leans too, adding thickness * cos(angle) - a fifth of
// the span at 45 degrees, split evenly above and below - so a caller that omits it gets an envelope
// the drawn blade breaks out of at both ends. thickness is a printed dimension rather than a
// property of the type, which is why it arrives as an argument. It defaults to zero, which is the
// bladeless-plate idealisation the correlations are written on. Twisted rows ignore it: their
// extrusion height already bounds the solid.
function impeller_axial_span(type, impeller_diameter, thickness = 0) =
  let (_angle = impeller_blade_angle(type), _width = impeller_width_ratio(type) * impeller_diameter)
    is_undef(_angle) ? _width : _width * sin(_angle) + thickness * cos(_angle);

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

/**
 * Module: impeller
 *
 * Generates a 3D impeller model with customizable parameters.
 *
 * Parameters:
 *   radius (float): The radius of the impeller.
 *   height (float): The height of the impeller.
 *   fins (int): The number of fins on the impeller.
 *   twist (float): The twist angle of each fin.
 *   fin_scale (vector, default=[1,2,0.2]): Scale factors for the fins.
 *   fin_rotate (vector, default=[0,0,120]): Rotation angles for the fins.
 *   fin_width (float, default=1): The width of each fin blade.
 *   center_hub_radius (float, default=25): The size of the center hub.
 *   center_hub_type (string, default="sphere"): Type of the center hub (sphere or cylinder).
 *   center_hole_radius (float, default=5): The size of the center hole.
 *   hub_scale (vector, default=[1,1,1]): Scale factors for the center hub.
 *   hub_fn (int, default=$fn): The number of facets for the center hub.
 *   twist_slices (int, default=90): Steps used to sweep each twisted fin. 90 holds the blade
 *     surface within about 27 um of a 360-slice sweep, well under what the process can hold,
 *     and renders around seven times faster. Raise it for a smoother blade.
 *
 * Description:
 *   This module generates a 3D impeller model with customizable parameters.
 *   The impeller is composed of multiple fins, a center hub, and a center hole.
 *   Each fin is twisted and scaled according to the provided parameters.
 *   The center hub is scaled and positioned at the center of the impeller.
 *   The center hole is subtracted from the impeller to create a hollow effect.
 */
module impeller(
  radius,
  height,
  fins,
  twist,
  fin_width = 1,
  center_hub_radius = 25,
  center_hole_radius = 5,
  center_hole_radius_lower = -1,
  center_hole_scale = 1,
  center_hub_type = "cylinder",
  fin_scale = [1, 1, 1],
  fin_rotate = [0, 0, 0],
  hub_scale = [1, 1, 1],
  round = false,
  hub_fn = 64,
  twist_slices = 90,
  blade_pitch = undef,
  blade_width = undef
) {

  // A flat blade set at blade_pitch degrees from the plane of rotation - a pitched blade turbine.
  // Drawn rather than extruded because the extrude path below sweeps a profile up the axis, which
  // makes paddles and helicoids and cannot tilt a plate; and because resize() would then distort
  // the angle, which is the one number the correlations are keyed on.
  _pitched = !is_undef(blade_pitch);
  _blade_w = is_undef(blade_width) ? height : blade_width;

  center_hole_radius_lower_eff = (center_hole_radius_lower < 0) ? center_hole_radius : center_hole_radius_lower;

  // single number; calculate the required scale factor for the center hole taper to go from center_hole_radius to center_hole_radius_lower_eff over the height of the impeller
  center_hole_scale = center_hole_radius_lower_eff / center_hole_radius;

  difference() {
    union() {
      // Loop through each fin
      for (i = [1:fins]) {
        rotate([0, 0, (360 / fins) * i])
        if (_pitched)
          // Flat plate, hinged about its own radius so the pitch stays exact - resize() would
          // distort it, and the angle is the one number the correlations are keyed on.
          //
          // BOTH ends are solved, not (radius - hub). A tilted rectangle's extreme points are its
          // CORNERS, offset _half from the plane its faces lie on, so it is the corners that have
          // to land on a circle. Outboard that is the diameter every power number is defined on:
          // running the plate out to radius would sweep wider than the model claims. Inboard it is
          // the hub, and there it decides whether the blade is ATTACHED. A plate whose inner face
          // sits at center_hub_radius is tangent to the hub - they meet along a line of zero width,
          // which is a non-manifold solid and a joint with no cross-section. _root buries the inner
          // corners in the hub instead; it falls back to the axis where the hub is too narrow to
          // bury them, which is a wide blade on a big jar.
          let (
            _half = _blade_w / 2 * cos(blade_pitch) + fin_width / 2 * sin(blade_pitch),
            _tip = sqrt(pow(radius, 2) - pow(_half, 2)),
            _root = center_hub_radius > _half ? sqrt(pow(center_hub_radius, 2) - pow(_half, 2)) : 0
          )
          translate([_root, 0, 0])
            rotate([blade_pitch, 0, 0])
              translate([0, -_blade_w / 2, -fin_width / 2])
                cube([_tip - _root, _blade_w, fin_width]);
        else
          // Scale and extrude the fin blade
          scale(fin_scale) resize([radius, radius, height]) intersection() {
                translate([0, 0, -radius / 2]) linear_extrude(radius, twist=twist, slices=twist_slices, convexity=10)
                    rotate(fin_rotate) square([radius, fin_width], center=false);
                if (round)
                  sphere(d=radius, $fn=128);
              }
      }
      // Create the center hub
      scale(hub_scale) {
        if (center_hub_type == "cylinder")
          resize([center_hub_radius * 2, center_hub_radius * 2, height])
            cylinder(r=center_hub_radius, h=radius, center=true, $fn=hub_fn);
        else if (center_hub_type == "sphere")
          scale([1, 1, radius / (center_hub_radius)]) sphere(r=center_hub_radius, $fn=hub_fn);
        else
          echo("Invalid center_hub_type: ", center_hub_type);
      }
    }
    // Subtract the center hole
    rotate([0, 180, 0])
      linear_extrude(height + z_fight, center=true, scale=center_hole_scale)
        circle(r=center_hole_radius, $fn=128);
  }
}

// Example call to the impeller module with required parameters and some default values
// impeller(radius = 80, height = 50, fins = 6, twist = 90, fin_width = 1, center_hub_radius = 20);

// Example call to the impeller module with all parameters specified
impeller(
  radius=80, height=50, fins=4, twist=90, fin_width=2, center_hub_radius=10, center_hole_radius=5,
  center_hub_type="cylinder", fin_scale=[1, 1, 1], fin_rotate=[0, 0, 120], hub_scale=[1, 1, 1],
  round=false, hub_fn=128
);
