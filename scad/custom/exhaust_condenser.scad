/**
 * @file exhaust_condenser.scad
 * @brief Cold-finger exhaust condenser on a bayonet pin, for a lid's gas outlet port
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The pin half of a bayonet port with a wide bore, and above it a shell with a closed well hung
 * down its middle. Exhaust rises through the bore into a funnel, then up the annulus between the
 * well and the shell, and leaves by a barb under the roof. Water condenses on both walls and runs
 * back down the funnel and the bore into the vessel, against the gas: the bore is sized so the gas
 * is slow enough for it to.
 *
 *      barb  ___________
 *        \  |  | well|  |      the well is open at the top and closed below: left empty the
 *         \ |  |     |  |      shell and the well both cool to the room; filled with cold water
 *           |  |     |  |      or ice, the well is a cold finger below room temperature
 *           |  |     |  |
 *           |   \   /   |
 *            \   \ /   /       funnel and well tip at 45 degrees, one gap apart
 *             \       /
 *              |     |         neck, lifting the shell clear of the neighbouring ports
 *            __|     |__
 *           |  flange   |      z = 0 is the panel's outer face, as for every bayonet_port
 *              |coupl|
 *
 * Every downward-facing surface is at 45 degrees or is the roof, so it prints standing on the
 * roof, well mouth down; the barb may not rise past the roof for the same reason.
 */

use <../utils/facets.scad>
use <../utils/section.scad>
use <bayonet_port.scad>
include <bayonet_interfaces.scad>

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// Cut the preview open to see inside; ignored on a render
cross_section_active = true;
// How much the cut leaves: 0.5 is a half, 0.75 removes a quarter
cross_section_keep = 0.5;

// example usage: the jar_10L lid's air_out port, which is std. The cut starts at 0 degrees, so its
// face runs through the outlet.
section(keep=cross_section_keep, size=300, active=cross_section_active && $preview)
  exhaust_condenser(bayonet_std);
exhaust_condenser_report(bayonet_std, flow_lpm=4.11);

// How far the body sinks into the flange, so the two overlap rather than meet face to face.
exhaust_condenser_flange_overlap = 0.5;

// The funnel's height: a 45 degree cone from the bore out to the shell.
function exhaust_condenser_funnel_height(bore_diameter, shell_inner_diameter) =
  (shell_inner_diameter - bore_diameter) / 2;

// The gap between well and shell, which is also the gap between the well's tip and the funnel.
function exhaust_condenser_gap(shell_inner_diameter, well_outer_diameter) =
  (shell_inner_diameter - well_outer_diameter) / 2;

// Gas flow area up the annulus, mm2.
function exhaust_condenser_annulus_area(shell_inner_diameter, well_outer_diameter) =
  PI / 4 * (shell_inner_diameter ^ 2 - well_outer_diameter ^ 2);

// Cold wall the gas passes over in the straight section: the shell's inside and the well's outside, mm2.
function exhaust_condenser_wall_area(shell_inner_diameter, well_outer_diameter, cooled_length) =
  PI * (shell_inner_diameter + well_outer_diameter) * cooled_length;

// How high the body stands above the panel's outer face.
function exhaust_condenser_height(type, bore_diameter, neck_height, shell_inner_diameter, cooled_length, wall) =
  bayonet_flange_height(type) + neck_height
  + exhaust_condenser_funnel_height(bore_diameter, shell_inner_diameter) + cooled_length + wall;

/**
 * @param type                 Registered bayonet interface the lid's port carries
 * @param panel_thickness      Thickness of the panel the pin passes through
 * @param bore_diameter        Gas up, condensate down, through the pin and neck
 * @param neck_height          Straight neck above the flange, before the funnel opens
 * @param shell_inner_diameter Inside of the shell
 * @param well_outer_diameter  Outside of the well; with the shell it sets the gap
 * @param cooled_length        Straight annulus above the funnel
 * @param wall                 Wall of the shell, the well, the neck and the roof
 * @param rib_count            Radial ribs tying the well to the shell; 0 for none
 * @param rib_thickness        Thickness of each rib
 * @param hose_inner_diameter  Hose the outlet barb takes
 * @param outlet_bore_diameter Bore of the outlet barb
 * @param outlet_angle         Direction of the barb about the port axis, in the port's locked frame
 * @param outlet_tilt          Barb above horizontal, degrees; negative points it down
 */
module exhaust_condenser(
  type,
  panel_thickness = 18,
  bore_diameter = 12,
  neck_height = 30,
  shell_inner_diameter = 44,
  well_outer_diameter = 32,
  cooled_length = 150,
  wall = 2,
  rib_count = 3,
  rib_thickness = 1.2,
  hose_inner_diameter = 6.35,
  outlet_bore_diameter = 4.5,
  outlet_angle = 0,
  outlet_tilt = 0
) {
  _fh = bayonet_flange_height(type);
  _fr = bayonet_flange_radius(type);
  _core_r = bayonet_interface_radius(type) - bayonet_pin_radius(type);

  _rb = bore_diameter / 2;
  _rs = shell_inner_diameter / 2;
  _rw = well_outer_diameter / 2;
  _gap = exhaust_condenser_gap(shell_inner_diameter, well_outer_diameter);

  _z_neck = _fh + neck_height; // top of the straight neck, where the funnel opens
  _z_funnel = _z_neck + exhaust_condenser_funnel_height(bore_diameter, shell_inner_diameter);
  _z_roof = _z_funnel + cooled_length; // underside of the roof
  _z_top = _z_roof + wall;

  // A 45 degree wall is w thick normal to itself when its faces are w * sqrt(2) apart along r - z.
  _slant = wall * (sqrt(2) - 1);
  _neck_r = _rb + wall;
  _gusset_top = _fh + (_fr - _neck_r); // 45 degree fillet from the flange's edge in to the neck

  // The well's tip sits one gap off the funnel, measured normal to both cones.
  _z_tip = _z_neck - _rb + _gap * sqrt(2);

  _barb_r = hose_inner_diameter / 2;
  _barb_length = hose_inner_diameter * 2.5;
  _outlet_r = outlet_bore_diameter / 2;
  _outlet_z = _z_roof - _outlet_r - wall; // just under the roof, where the gas is last
  _outlet_x = (_rw + _rs) / 2; // mid-gap, clear of the well
  _outlet_run = (_rs + wall - _outlet_x) / cos(outlet_tilt) + wall; // to clear the shell's outside
  _barb_top = _outlet_z + sin(outlet_tilt) * (_outlet_run + _barb_length) + _barb_r * 1.15 * cos(outlet_tilt);

  assert(
    _rb + 2 <= _core_r,
    str(
      "exhaust_condenser: a Ø", bore_diameter, " bore leaves under 2 mm of the pin's core, which is r ",
      _core_r, " on ", bayonet_name(type)
    )
  );
  assert(
    _neck_r <= _fr,
    str("exhaust_condenser: the neck, r ", _neck_r, ", overhangs the flange, r ", _fr)
  );
  assert(
    _z_neck - _slant >= _gusset_top,
    str(
      "exhaust_condenser: a ", neck_height, " mm neck is shorter than the fillet under it; it needs at least ",
      _gusset_top + _slant - _fh
    )
  );
  assert(
    _gap > _outlet_r * 2 && _gap >= 3,
    str(
      "exhaust_condenser: a ", _gap, " mm gap cannot take the Ø", outlet_bore_diameter,
      " outlet, or bridges with water under 3 mm"
    )
  );
  assert(
    _outlet_r < _barb_r - 0.6,
    str("exhaust_condenser: a Ø", outlet_bore_diameter, " outlet leaves the barb too thin a wall")
  );
  assert(
    _barb_top <= _z_top,
    str(
      "exhaust_condenser: a barb tilted ", outlet_tilt, " degrees reaches z ", _barb_top,
      ", above the roof at ", _z_top, " that the part prints standing on"
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

      // The body outside, turned: fillet, neck, funnel, shell, roof
      rotate_extrude()
        polygon(
          [
            [0, _fh - exhaust_condenser_flange_overlap],
            [_fr, _fh - exhaust_condenser_flange_overlap],
            [_fr, _fh],
            [_neck_r, _gusset_top],
            [_neck_r, _z_neck - _slant],
            [_rs + wall, _z_funnel - _slant],
            [_rs + wall, _z_top],
            [0, _z_top],
          ]
        );

      // Outlet barb, from under the roof
      rotate([0, 0, outlet_angle])
        translate([_outlet_x, 0, _outlet_z])
          rotate([0, 90 - outlet_tilt, 0]) {
            cylinder(h=_outlet_run, r=_outlet_r + wall);
            translate([0, 0, _outlet_run])
              for (i = [0:2])
                translate([0, 0, i * _barb_length / 3])
                  cylinder(h=_barb_length / 3, r1=_barb_r * 1.15, r2=_barb_r * 0.95);
          }
    }

    // The gas space: bore, funnel, annulus - less the well and the ribs, which stay solid
    difference() {
      rotate_extrude()
        polygon(
          [
            [0, -panel_thickness - 1],
            [_rb, -panel_thickness - 1],
            [_rb, _z_neck],
            [_rs, _z_funnel],
            [_rs, _z_roof],
            [0, _z_roof],
          ]
        );

      rotate_extrude()
        polygon(
          [
            [0, _z_tip],
            [_rw, _z_tip + _rw],
            [_rw, _z_top + 1],
            [0, _z_top + 1],
          ]
        );

      // In the straight annulus only, so the throat stays clear for the condensate
      if (rib_count > 0)
        for (i = [0:rib_count - 1])
          rotate([0, 0, outlet_angle + 180 / rib_count + i * 360 / rib_count])
            translate([_rw - 0.1, -rib_thickness / 2, _z_funnel])
              cube([_gap + 0.2, rib_thickness, cooled_length + 0.1]);
    }

    // The well's inside, open through the roof
    rotate_extrude()
      polygon(
        [
          [0, _z_tip + wall * sqrt(2)],
          [_rw - wall, _z_tip + wall * sqrt(2) + _rw - wall],
          [_rw - wall, _z_top + 1],
          [0, _z_top + 1],
        ]
      );

    // Outlet bore, from the annulus out through the barb - outward only, or it cuts into the well
    rotate([0, 0, outlet_angle])
      translate([_outlet_x, 0, _outlet_z])
        rotate([0, 90 - outlet_tilt, 0])
          cylinder(h=_rs * 4, r=_outlet_r);
  }
}

// What a given flow sees: velocities against the limit a falling film can drain against.
module exhaust_condenser_report(
  type,
  flow_lpm,
  bore_diameter = 12,
  neck_height = 30,
  shell_inner_diameter = 44,
  well_outer_diameter = 32,
  cooled_length = 150,
  wall = 2
) {
  _q = flow_lpm / 60000; // m3/s
  _bore_area = PI / 4 * bore_diameter ^ 2; // mm2
  _annulus_area = exhaust_condenser_annulus_area(shell_inner_diameter, well_outer_diameter);

  // Wallis counter-current flooding in a vertical tube, C = 0.725, air on water.
  _flood_v = 0.725 ^ 2 * sqrt(9.81 * bore_diameter / 1000 * (1000 - 1.2) / 1.2);

  echo(
    str(
      "exhaust condenser: Ø", bore_diameter, " bore at ", _q / (_bore_area * 1e-6), " m/s against ",
      _flood_v, " m/s a falling film drains against; ",
      exhaust_condenser_gap(shell_inner_diameter, well_outer_diameter), " mm gap at ",
      _q / (_annulus_area * 1e-6), " m/s over ",
      exhaust_condenser_wall_area(shell_inner_diameter, well_outer_diameter, cooled_length) / 100,
      " cm2 of cold wall; stands ",
      exhaust_condenser_height(type, bore_diameter, neck_height, shell_inner_diameter, cooled_length, wall),
      " mm above the lid"
    )
  );
}
