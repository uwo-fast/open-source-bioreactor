/**
 * @file condenser_body.scad
 * @brief The lower half every exhaust condenser shares: port pin, neck, funnel and an open shell
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A bayonet pin with a wide bore, a neck lifting the rest clear of the neighbouring ports, a 45
 * degree funnel out to the shell, and a straight shell open at the top for whatever cools it.
 * Condensate runs back down the funnel and the bore against the gas, so the bore is sized for that
 * rather than for the flow alone.
 *
 * DATUM: z = 0 is the panel's outer face, as for every bayonet_port.
 */

use <../utils/facets.scad>
use <bayonet_port.scad>
include <bayonet_interfaces.scad>

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// How far the body sinks into the flange, so the two overlap rather than meet face to face.
condenser_body_flange_overlap = 0.5;

// Where the funnel meets the shell.
function condenser_body_funnel_top_z(type, bore_diameter, neck_height, shell_inner_diameter) =
  bayonet_flange_height(type) + neck_height + (shell_inner_diameter - bore_diameter) / 2;

// The shell's open top.
function condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, shell_length) =
  condenser_body_funnel_top_z(type, bore_diameter, neck_height, shell_inner_diameter) + shell_length;

/**
 * @param type                 Registered bayonet interface the lid's port carries
 * @param panel_thickness      Thickness of the panel the pin passes through
 * @param bore_diameter        Gas up, condensate down, through the pin and neck
 * @param neck_height          Straight neck above the flange, before the funnel opens
 * @param shell_inner_diameter Inside of the shell
 * @param shell_length         Straight shell above the funnel, open at its top
 * @param wall                 Wall of the neck, funnel and shell
 */
module condenser_body(
  type,
  panel_thickness = 18,
  bore_diameter = 12,
  neck_height = 30,
  shell_inner_diameter = 42,
  shell_length = 200,
  wall = 2
) {
  _fh = bayonet_flange_height(type);
  _fr = bayonet_flange_radius(type);
  _core_r = bayonet_interface_radius(type) - bayonet_pin_radius(type);

  _rb = bore_diameter / 2;
  _rs = shell_inner_diameter / 2;
  _z_neck = _fh + neck_height;
  _z_funnel = condenser_body_funnel_top_z(type, bore_diameter, neck_height, shell_inner_diameter);
  _z_top = _z_funnel + shell_length;

  // A 45 degree wall is w thick normal to itself when its faces are w * sqrt(2) apart along r - z.
  _slant = wall * (sqrt(2) - 1);
  _neck_r = _rb + wall;
  _gusset_top = _fh + (_fr - _neck_r); // 45 degree fillet from the flange's edge in to the neck

  assert(
    _rb + 2 <= _core_r,
    str(
      "condenser_body: a Ø", bore_diameter, " bore leaves under 2 mm of the pin's core, which is r ",
      _core_r, " on ", bayonet_name(type)
    )
  );
  assert(_neck_r <= _fr, str("condenser_body: the neck, r ", _neck_r, ", overhangs the flange, r ", _fr));
  assert(
    _z_neck - _slant >= _gusset_top,
    str(
      "condenser_body: a ", neck_height, " mm neck is shorter than the fillet under it; it needs at least ",
      _gusset_top + _slant - _fh
    )
  );

  difference() {
    union() {
      bayonet_port(
        type=type,
        part="pin",
        panel_thickness=panel_thickness,
        center_bore_radius=_rb,
        catch_pockets=false
      );

      rotate_extrude()
        polygon(
          [
            [0, _fh - condenser_body_flange_overlap],
            [_fr, _fh - condenser_body_flange_overlap],
            [_fr, _fh],
            [_neck_r, _gusset_top],
            [_neck_r, _z_neck - _slant],
            [_rs + wall, _z_funnel - _slant],
            [_rs + wall, _z_top],
            [0, _z_top],
          ]
        );
    }

    // Bore, funnel and shell, open at the top
    rotate_extrude()
      polygon(
        [
          [0, -panel_thickness - 1],
          [_rb, -panel_thickness - 1],
          [_rb, _z_neck],
          [_rs, _z_funnel],
          [_rs, _z_top + 1],
          [0, _z_top + 1],
        ]
      );
  }
}
