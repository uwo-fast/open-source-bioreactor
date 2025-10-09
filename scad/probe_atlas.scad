// Upon observation, the atlas probes feature a similar geometry starting at the tip:
// 1. A medium diameter cylinder for the sensing tip
// 2. A larger diameter cylinder for the body
// 3. A smaller tapering cylinder for the neck
// 4. A very small diameter cylinder which is the cable

include <_config.scad>;
use <lib/trapezium.scad>;

// Creates a probe with customizable dimensions and colors
module atlas_probe(
  neck_d = 8,
  neck_h = 20,
  neck_taper_d = 6,
  body_d = 16,
  body_h = 40,
  tip_d = 12,
  tip_h = 15,
  wire_d = 4,
  wire_h = 25,
  colors = ["Black", "Red", "Black", "Yellow"],
  position_base = false
) {
  position_body(neck_h, body_h, position_base) union() {
      // Wire
      translate([0, 0, -wire_h]) color(colors[0]) cylinder(h=wire_h, d=wire_d, $fn=64);

      // Neck
      color(colors[1]) cylinder(h=neck_h, d2=neck_d, d1=neck_taper_d, $fn=64);

      // Body
      translate([0, 0, neck_h]) color(colors[2]) cylinder(h=body_h, d=body_d, $fn=64);

      depth = 6;
      thick = 2;
      curve_scale_y = 0.5;
      cut_size = tip_d / 3;
      curve_comp = cut_size * curve_scale_y * 0.5;

      // Sensing Tip
      translate([0, 0, neck_h + body_h]) color(colors[3], alpha=0.5) difference() {
            cylinder(h=tip_h, d=tip_d, $fn=64);

            translate([0, 0, tip_h - depth]) cylinder(h=depth + zFite, d=tip_d - thick * 2, $fn=64);

            for (i = [0:1])
              rotate([0, 0, 90 * i]) translate([0, tip_d, tip_h - depth + curve_comp + zFite])
                  rotate([90, 0, 0]) linear_extrude(tip_d * 2) union() {

                        trapezium(bottom_width=cut_size, top_width=cut_size - thick / 2, height=depth - curve_comp);
                        scale([1, curve_scale_y, 1]) circle(d=cut_size);
                      }
          }
    }
}

module position_body(neck, body, position_base = false) {
  if (position_base)
    translate([0, 0, neck + body]) rotate([0, 180, 0]) children();
  else
    children();
}
