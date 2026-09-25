/**
 * @file gl_port_cap.scad
 * @brief A GL screw cap whose top carries bayonet locks, so tube ports fit a lab bottle
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The cap and its thread come from din168-thread-scad; this adds the locks. The top is the panel
 * the locks are sunk into, so its thickness is the ports' panel thickness, and the pins printed for
 * it are drawn with the same value. The bottle's rim seals on a sheet gasket against the top's
 * underside.
 *
 * DATUM: z = 0 is the cap's mouth. The top's outer face, where each port's own z = 0 lands, is at
 * gl_port_cap_top_z().
 *
 * First use: the inlet humidifier - air in down a steel dip tube, humid air out of the second port.
 */

use <din168-thread-scad/din168.scad>
use <../utils/facets.scad>
use <sheet_gasket.scad>
use <bayonet_port.scad>
include <bayonet_interfaces.scad>

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// example usage: a GL45 humidifier cap, its two tube pins beside it, and its rim gasket
_gl = din168_by_name("GL45");
gl_port_cap(_gl);
for (i = [0:1])
  translate([45 + i * 25, 0, 0])
    bayonet_port(
      bayonet_mini, part="pin", panel_thickness=10, center_bore_radius=2.2,
      bore_oring=oring_4x1p5_epdm, text_labels=true, label=i == 0 ? "IN" : "OUT"
    );
translate([0, 60, 0]) sheet_gasket(inner_diameter=34, outer_diameter=45, thickness=1.6);

// Where the top's outer face sits above the mouth.
function gl_port_cap_top_z(thread_length, liner_space, panel_thickness) =
  thread_length + liner_space + panel_thickness;

/**
 * @param size             Registered DIN 168 size, e.g. din168_by_name("GL45")
 * @param type             Registered bayonet interface for every port
 * @param panel_thickness  The top's thickness, and the ports' panel thickness
 * @param port_count       Ports, evenly round the axis
 * @param port_offset      Distance of each port from the axis
 * @param thread_length    Length of the cap's thread
 * @param liner_space      Plain wall between the thread and the top, where the gasket sits
 * @param wall             Wall outside the thread's root
 * @param clearance        Thread clearance, per flank and radially
 * @param ribs             Grip ribs round the outside; 0 for none
 */
module gl_port_cap(
  size,
  type = bayonet_mini,
  panel_thickness = 10,
  port_count = 2,
  port_offset = 10.5,
  thread_length = 12,
  liner_space = 2,
  wall = 2,
  clearance = 0.2,
  ribs = 36
) {
  _r_cap = din168_cap_radius(size, wall, clearance);
  _z_top = gl_port_cap_top_z(thread_length, liner_space, panel_thickness);
  _flange_r = bayonet_flange_radius(type);

  // Neighbouring flanges may not overlap, and each has to land on the top.
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
        translate([port_offset, 0, _z_top])
          children();
  }

  difference() {
    din168_cap(size, thread_length, liner_space, panel_thickness, wall, clearance, ribs);
    _at_ports()
      translate([0, 0, -panel_thickness - 1])
        cylinder(h=panel_thickness + 2, r=bayonet_port_hole_radius(type));
  }
  _at_ports()
    bayonet_port(type=type, part="lock", panel_thickness=panel_thickness);
}
