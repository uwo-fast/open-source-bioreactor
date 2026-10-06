/**
 * @file heat_pad_mount.scad
 * @brief What holds a silicone heating pad against the jar: a curved plate the pad sits in, hung
 * behind a rib arc
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The pad goes on the glass bare and the plate goes behind it. The rib's inner face is recessed
 * to take pad and plate with a small fit clearance, and the rib arc between its rods is the spring
 * that keeps the pad on the glass: shim behind the plate until it is snug. The plate drops in
 * from the open band above the rib, its hook lands on the rib's top face and its two tabs ride
 * down the rib's empty light pockets, which locate it around the jar.
 *
 * Everything is placed about the jar's axis: angle 0 is the plate's centre, z = 0 the bottom face
 * of the rib arc it hangs behind. This file's render is a preview.
 */

include <../purchased/heat_pads.scad>;

$fn = $preview ? 64 : 256;

/* [Preview] */

// The pad the preview mounts
mount_pad_name = "20W 150x50"; // [20W 150x50]
// Radius of the jar's outside, in mm
mount_glass_radius = 110;
// Height of the rib arc the plate hangs behind, in mm
mount_rib_height = 10;
// Radius of the light pockets' back wall, in mm
mount_pocket_back = 118.7;
// Width of a light pocket, in mm
mount_pocket_width = 14.85;
// Angles of the pockets the tabs use, either side of the plate's centre, in degrees
mount_tab_angles = [-30, 30];
// Show the pad in place
mount_show_pad = true;

/* [Plate] */

// Thickness of the plate behind the pad, in mm
heat_pad_plate_thickness = 2;
// Radial clearance between the plate and the recess, which shims take up, in mm
heat_pad_fit_clearance = 0.2;
// Chamfer on the plate's lower back edge, leading it into the recess, in mm
heat_pad_lead_in = 1;
// Width of the wall that rings the pad, in mm
heat_pad_wall_width = 1.2;
// Height of that wall toward the glass, as a fraction of the pad's thickness
heat_pad_wall_fraction = 0.5;
// Gap between the pad's edge and its wall, each side, in mm
heat_pad_side_clearance = 0.5;
// Width of the lead notch through the end walls, in mm
heat_pad_lead_notch = 8;
// How far the hook reaches over the rib's top face past the pocket's back wall, in mm
heat_pad_hook_reach = 3;
// How deep the hook's and the tabs' stiffeners still stand at the plate's top edge, in mm
heat_pad_stiffener_top = 1;
// Angular width of the hook, as a fraction of the plate's
heat_pad_hook_fraction = 0.3;
// How far a tab stands behind the plate, in mm
heat_pad_tab_depth = 2.5;
// Clearance each side of a tab in its pocket, in mm
heat_pad_pocket_clearance = 0.4;
// Angular clearance each end between the plate and the recess, in degrees
heat_pad_recess_end_clearance = 1;

module dummy() {
  // stop the customizer detection from here onwards
}

// ----- radii, from the glass out -----

function heat_pad_plate_inner_radius(pad, glass_r) = glass_r + heat_pad_thickness(pad);
function heat_pad_plate_outer_radius(pad, glass_r) = heat_pad_plate_inner_radius(pad, glass_r) + heat_pad_plate_thickness;
function heat_pad_recess_radius(pad, glass_r) = heat_pad_plate_outer_radius(pad, glass_r) + heat_pad_fit_clearance;

// ----- sizes -----

// The pocket the pad sits in, then the plate around it.
function heat_pad_bay_length(pad) = heat_pad_length(pad) + 2 * heat_pad_side_clearance;
function heat_pad_bay_height(pad) = heat_pad_height(pad) + 2 * heat_pad_side_clearance;
function heat_pad_plate_length(pad) = heat_pad_bay_length(pad) + 2 * heat_pad_wall_width;
function heat_pad_plate_height(pad) = heat_pad_bay_height(pad) + 2 * heat_pad_wall_width;
// Arc lengths are laid out at the pad's own radius, the glass under it.
function heat_pad_angle(len, glass_r) = len / glass_r * 180 / PI;
function heat_pad_plate_span(pad, glass_r) = heat_pad_angle(heat_pad_plate_length(pad), glass_r);
function heat_pad_recess_span(pad, glass_r) = heat_pad_plate_span(pad, glass_r) + 2 * heat_pad_recess_end_clearance;
// The plate is centred on the rib arc's height.
function heat_pad_plate_bottom(pad, rib_h) = rib_h / 2 - heat_pad_plate_height(pad) / 2;

// A ring sector about z, centred on angle 0.
module heat_pad_sector(r0, r1, z0, z1, span) {
  rotate([0, 0, -span / 2])
    rotate_extrude(angle=span)
      translate([r0, z0]) square([r1 - r0, z1 - z0]);
}

/**
 * @brief The plate, as it sits with the pad behind it. Printed top edge down: the hook and the
 * tabs each carry a stiffener up to that edge, so each grows out of the bed with nothing overhung.
 */
module heat_pad_plate(pad, glass_r, rib_h, pocket_back, pocket_w, tab_angles) {
  _ri = heat_pad_plate_inner_radius(pad, glass_r);
  _ro = heat_pad_plate_outer_radius(pad, glass_r);
  _z0 = heat_pad_plate_bottom(pad, rib_h);
  _z1 = _z0 + heat_pad_plate_height(pad);
  _span = heat_pad_plate_span(pad, glass_r);
  _bay = heat_pad_angle(heat_pad_bay_length(pad), glass_r);
  _wall_r = _ri - heat_pad_wall_fraction * heat_pad_thickness(pad);
  _tab_w = pocket_w - 2 * heat_pad_pocket_clearance;
  _tab_r = _ro + heat_pad_tab_depth;
  _sink = heat_pad_plate_thickness / 2;

  union() {
    // the plate and the wall that rings the pad, one profile from the wall's face to the plate's back,
    // its lower back edge chamfered to lead it into the recess; then the pad's bay and the lead's way
    // out through both end walls at mid-height cut from it. One solid, so no two share a surface; each
    // cut overshoots the wall's face toward the glass, where there is nothing to keep.
    difference() {
      rotate([0, 0, -_span / 2])
        rotate_extrude(angle=_span)
          polygon([[_wall_r, _z0], [_ro - heat_pad_lead_in, _z0], [_ro, _z0 + heat_pad_lead_in], [_ro, _z1], [_wall_r, _z1]]);
      heat_pad_sector(_wall_r - 1, _ri, _z0 + heat_pad_wall_width, _z1 - heat_pad_wall_width, _bay);
      for (s = [-1, 1])
        rotate([0, 0, s * (_span + _bay) / 4])
          heat_pad_sector(_wall_r - 1, _ri, (_z0 + _z1) / 2 - heat_pad_lead_notch / 2, (_z0 + _z1) / 2 + heat_pad_lead_notch / 2, (_span - _bay) / 2 + 2);
    }
    // the hook, over the rib's top face, tapering up to the top edge
    rotate([0, 0, -_span * heat_pad_hook_fraction / 2])
      rotate_extrude(angle=_span * heat_pad_hook_fraction)
        polygon([
          [_ro - _sink, rib_h],
          [pocket_back + heat_pad_hook_reach, rib_h],
          [_ro + heat_pad_stiffener_top, _z1],
          [_ro - _sink, _z1],
        ]);
    // the tabs, the rib's height in its pockets, tapering up to the top edge
    for (a = tab_angles)
      rotate([0, 0, a])
        rotate([90, 0, 0])
          linear_extrude(_tab_w, center=true)
            polygon([
              [_ro - _sink, 0],
              [_tab_r, 0],
              [_tab_r, rib_h],
              [_ro + heat_pad_stiffener_top, _z1],
              [_ro - _sink, _z1],
            ]);
  }
}

// The pad, bent onto the glass.
module heat_pad_fitted(pad, glass_r, rib_h) {
  color(heat_pad_color())
    heat_pad_sector(glass_r, heat_pad_plate_inner_radius(pad, glass_r), rib_h / 2 - heat_pad_height(pad) / 2,
      rib_h / 2 + heat_pad_height(pad) / 2, heat_pad_angle(heat_pad_length(pad), glass_r));
}

_mount_pad = heat_pad_by_name(mount_pad_name);
heat_pad_plate(_mount_pad, mount_glass_radius, mount_rib_height, mount_pocket_back, mount_pocket_width, mount_tab_angles);
// shown, not rendered: it lies on the plate's bay floor and is not a printed part
if (mount_show_pad)
  %heat_pad_fitted(_mount_pad, mount_glass_radius, mount_rib_height);
