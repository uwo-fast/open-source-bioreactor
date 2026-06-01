// A model of the Atlas Scientific probes, which have a distinctive and consistent shape
// across their ezo product line which varies in size but largely not in shape. 

use <../utils/trapezium.scad>;

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

//atlas_probe(  neck_d = 8,  neck_h = 20,  neck_taper_d = 6,  body_d = 16,  body_h = 40,  tip_d = 12,  tip_h = 15,  wire_d = 4,  wire_h = 25,  accent_color = undef,   position_base = false);

// Creates a probe with customizable dimensions and colors
// TODO: remove all the default arguments,
// except what isnt captured in registered params

/** 
* @brief Creates an Atlas Scientific probe with customizable dimensions and colors
* @param neck_d Diameter of the neck
* @param neck_h Height of the neck
* @param neck_taper_d Diameter of the neck at the taper start
* @param body_d Diameter of the body
* @param body_h Height of the body
* @param tip_d Diameter of the tip
* @param tip_h Height of the tip
* @param wire_d Diameter of the wire
* @param wire_h Height of the wire (arbitrary selection since its a straight model for visualization or difference cuts)
* @param accent_color Color used for the neck
* @param position_base If true, positions the probe from the base tip
*/
module atlas_probe(
  neck_d,
  neck_h,
  neck_taper_d,
  body_d,
  body_h,
  tip_d,
  tip_h,
  wire_d,
  wire_h = 10,
  accent_color = undef,
  position_base = false
) {
  // None of the atlas probes are pink, so we set this so its obvious
  // that the color is unset and will apply for custom probes by default
  accent_color_eff = is_undef(accent_color) ? "Pink" : accent_color;

  colors = ["Black", accent_color_eff, "Black", "Yellow"];

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


// TODO: this can be a function which is driven by new parameter registry
// values and figure out default positioning or rotated inline as needed
module position_body(neck, body, position_base = false) {
  if (position_base)
    translate([0, 0, neck + body]) rotate([0, 180, 0]) children();
  else
    children();
}
