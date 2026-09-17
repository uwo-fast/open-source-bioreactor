/**
 * @file impeller.scad
 * @brief Highly customizable impeller module
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Inspired by
 * https://infinityplays.com/3d-part-design-with-openscad-57-a-universal-propeller-impeller-design-module/.
 */

// ----- registry accessors, for impellers.scad -----

function impeller_name(type) = type[0];
function impeller_blades(type) = type[1][0]; // number of blades
function impeller_blade_angle(type) = type[1][1]; // degrees from the plane of rotation, undef when twisted
function impeller_width_ratio(type) = type[1][2]; // blade dimension / impeller diameter, undef when unsourced
function impeller_twist(type) = type[1][3]; // linear_extrude pitch specifier, undef on a flat blade
function impeller_pumping(type) = type[2]; // "radial" or "axial"
function impeller_power_number(type) = type[3][0]; // turbulent Po, undef when unmeasured
function impeller_power_number_tol(type) = type[3][1]; // reported uncertainty, undef when the source gives none
function impeller_dissipation_factor(type) = type[4]; // x in Grenville's peak-dissipation correlation

function impeller_is_twisted(type) = !is_undef(impeller_twist(type));
function impeller_has_power_number(type) = !is_undef(impeller_power_number(type));

// What the blade occupies along the shaft: a flat blade at an angle projects sin(angle) of its
// width plus cos(angle) of its thickness; a twisted blade's extrusion height is the span already.
// thickness defaults to 0, the idealisation the correlations are written on.
function impeller_axial_span(type, impeller_diameter, thickness = 0) =
  let (_angle = impeller_blade_angle(type), _width = impeller_width_ratio(type) * impeller_diameter)
    is_undef(_angle) ? _width : _width * sin(_angle) + thickness * cos(_angle);

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// Fins around a hub with a centre hole. Twisted fins are extruded with `twist` (twist_slices = 90
// holds the surface within ~27 um of a 360-slice sweep); a flat plate at `blade_pitch` degrees
// is drawn instead when it is given, with `blade_width` across the blade.
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

  _pitched = !is_undef(blade_pitch);
  _blade_w = is_undef(blade_width) ? height : blade_width;

  center_hole_radius_lower_eff = (center_hole_radius_lower < 0) ? center_hole_radius : center_hole_radius_lower;

  // taper of the centre hole over the height
  center_hole_scale = center_hole_radius_lower_eff / center_hole_radius;

  difference() {
    union() {
      // Loop through each fin
      for (i = [1:fins]) {
        rotate([0, 0, (360 / fins) * i])
        if (_pitched)
          // Flat plate hinged about its own radius, so the pitch stays exact. A tilted rectangle's
          // extreme points are its corners, so both ends are solved for the corners: outboard on
          // the diameter the power number is defined on, inboard buried in the hub (a plate whose
          // inner face sits at the hub radius is tangent to it, a non-manifold joint).
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

// example usage
impeller(
  radius=80, height=50, fins=4, twist=90, fin_width=2, center_hub_radius=10, center_hole_radius=5,
  center_hub_type="cylinder", fin_scale=[1, 1, 1], fin_rotate=[0, 0, 120], hub_scale=[1, 1, 1],
  round=false, hub_fn=128
);
