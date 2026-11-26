/**
 * @file gl_port_cap.scad
 * @brief GL screw cap with bayonet locks in the top, for fitting tube ports to a lab bottle
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The cap and its thread come from din168-thread-scad; this file adds the locks. The top is the
 * panel the locks are sunk into, so its thickness is the port panel thickness, and the matching
 * pins are drawn with the same value. The bottle rim seals on a sheet gasket against the underside
 * of the top.
 *
 * DATUM: z = 0 is the seal plane, where the bottle rim meets the underside of the top, as in
 * din168_cap. The outer face of the top, where z = 0 of each port lands, is at z = panel_thickness.
 *
 * First use: the inlet humidifier. Air enters down a steel dip tube and humid air leaves through
 * the second port.
 */

use <din168-thread-scad/din168.scad>
use <../utils/facets.scad>
use <sheet_gasket.scad>
use <bayonet-port-scad/custom/bayonet_port.scad>
include <bayonet-port-scad/custom/bayonet_interfaces.scad>

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// example usage: a GL45 humidifier cap, with its two tube pins and rim gasket beside it
_gl = din168_by_name("GL45");
gl_port_cap(_gl);
for (i = [0:1])
  translate([45 + i * 25, 0, 0])
    bayonet_port(
      bayonet_mini, part="pin", panel_thickness=10, center_bore_radius=2.2,
      bore_oring=oring_4x1p5_epdm, text_labels=true, label=i == 0 ? "IN" : "OUT"
    );
translate([0, 60, 0]) sheet_gasket(inner_diameter=34, outer_diameter=45, thickness=1.6);

/**
 * @param size             Registered DIN 168 size, e.g. din168_by_name("GL45")
 * @param type             Registered bayonet interface for every port
 * @param panel_thickness  Thickness of the top, which is also the port panel thickness
 * @param port_count       Number of ports, evenly spaced around the axis
 * @param port_offset      Distance of each port from the axis
 * @param thread_length    Length of the cap thread; undef for the din168 default of five pitches
 * @param liner_space      Plain wall between the thread and the top, where the gasket sits
 * @param wall             Wall outside the thread root
 * @param clearance        Thread clearance, per flank and radially
 * @param ribs             Grip ribs around the outside; 0 for none
 * @param ring_band        Band at the mouth that clears a pouring ring, in mm; 0 for none
 */
module gl_port_cap(
  size,
  type = bayonet_mini,
  panel_thickness = 10,
  port_count = 2,
  port_offset = 10.5,
  thread_length = undef,
  liner_space = 2,
  wall = 2,
  clearance = 0.2,
  ribs = 36,
  ring_band = 0
) {
  _r_cap = din168_cap_radius(size, wall, clearance);
  _flange_r = bayonet_flange_radius(type);

  // Neighbouring flanges must not overlap, and each must fit on the top.
  assert(
    port_count < 2 || 2 * port_offset * sin(180 / port_count) >= 2 * _flange_r + 0.5,
    str(
      "gl_port_cap: ", port_count, " ports ", port_offset, " mm off the axis put their ",
      _flange_r * 2, " mm flanges under 0.5 mm apart"
    )
  );
  assert(
    port_offset + bayonet_gland_outer_radius(type) <= _r_cap,
    str(
      "gl_port_cap: a port ", port_offset, " mm off the axis puts its face seal past the cap's edge at r ",
      _r_cap
    )
  );

  module _at_ports() {
    for (i = [0:port_count - 1])
      rotate([0, 0, i * 360 / port_count])
        translate([port_offset, 0, panel_thickness])
          children();
  }

  difference() {
    din168_cap(size, thread_length, liner_space, panel_thickness, wall, clearance, ribs, ring_band);
    _at_ports()
      translate([0, 0, -panel_thickness - 1])
        cylinder(h=panel_thickness + 2, r=bayonet_port_hole_radius(type));
  }
  _at_ports()
    bayonet_port(type=type, part="lock", panel_thickness=panel_thickness);
}
