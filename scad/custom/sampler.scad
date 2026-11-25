/**
 * @file sampler.scad
 * @brief Turbidity sampler on a lid port: the turbidity-sensor sampler case on a lid bayonet pin
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The case, its fits and its purchased parts come from turbidity-sensor
 * (hardware/sampler-case/sampler_case.scad). It is a flow cell around the probe board, with a
 * syringe actuator bolted on top that draws the sample through it. The case base takes a foot
 * passed in by the caller. Here the foot is the std bayonet pin, cut for this lid panel with the
 * riser bore and o-ring, and unioned into the base so the base stays a single print. The dip tube
 * is the sparge riser of the port, cut to end open at mid-depth of the culture, where the sample is
 * drawn, and bushed into the bottom of the clear tube.
 *
 * head.scad `use`s this file, which keeps the turbidity-sensor globals out of head.scad. The
 * include order follows OpenSCAD rules: the inputs to the foot dimensions are set before the
 * include, and the dimensions themselves after it, because a reassigned variable takes its last
 * value at the place it was first assigned.
 *
 * Port frame: origin on the port axis at the outer face of the lid, +z out of the vessel, +x
 * radially outward. The reactor dimensions below are copied for jar_10L only for the example in
 * this file. head.scad calculates the riser cut length for its own jar.
 */

use <bayonet-port-scad/custom/bayonet_port.scad>
include <bayonet-port-scad/custom/bayonet_interfaces.scad>

// head.scad: the lid is lid_flange_height 8 + lid_plug_height 10 thick
panel = 18;

include <turbidity-sensor/hardware/sampler-case/sampler_case.scad>

// turn off the turbidity-sensor preview; the preview for this file is below
part = "none";
// the foot: the std bayonet pin, dimensions from the port library
foot_flange_h = bayonet_flange_height(bayonet_std);
foot_neck_r = bayonet_flange_radius(bayonet_std);
foot_core_r = bayonet_interface_radius(bayonet_std) - bayonet_pin_radius(bayonet_std);
foot_gland_top_z = bayonet_bore_gland_centre(oring_4x1p5_epdm, panel) + bayonet_bore_gland_length(oring_4x1p5_epdm) / 2;

// head.scad, jar_10L: the riser extends 14.9375 above the top of its port. The culture surface
// is 88.4342 below the top end of a riser, and the culture is 229.503 deep
riser_proud = 14.9375;
surface_z = foot_flange_h + riser_proud - 88.4342;
culture_depth = 229.503;
// the dip tube ends open at mid-depth of the culture, where it draws the sample
sampler_riser_l = riser_top_z - (surface_z - culture_depth / 2);
line_ml = (sampler_riser_l * PI * pow(riser_id / 2, 2) + (window_z - riser_top_z) * PI * pow(tube_id / 2, 2)) / 1000;

// The foot: the std pin, cut for the panel, bored for the riser and sealed to it by the 4x1.5
// o-ring.
module sampler_foot() {
  bayonet_port(type=bayonet_std, part="pin", panel_thickness=panel, center_bore_radius=riser_bore,
               bore_oring=oring_4x1p5_epdm, catch_pockets=false);
}

// Interface for head.scad, in the port frame: the panel thickness the pin is cut for, the base as
// the port pin, both prints in place, and a single print in its orientation on the print bed.
function sampler_panel() = panel;
module sampler_pin() sampler_base_placed() sampler_foot();
module sampler_placed() {
  $fn = 64;
  sampler_base() sampler_foot();
  sampler_top();
}
module sampler_print(part) {
  $fn = 64;
  if (part == "base") translate([0, 0, split_z]) rotate([180, 0, 0]) sampler_base() sampler_foot();
  else if (part == "top") translate([0, 0, face_z]) rotate([180, 0, 0]) sampler_top();
  else assert(false, str("sampler_print: no part \"", part, "\""));
}

echo(str("sampler: on jar_10L, riser cut ", sampler_riser_l, ", its open end at the culture's mid-depth; ",
         line_ml, " mL from the riser's end to the window"));

color("orange") sampler_base() sampler_foot();
color("darkorange") sampler_top();
sampler_bought();
color("grey") translate([0, 0, riser_top_z - sampler_riser_l]) difference() {
  cylinder(d=riser_od, h=sampler_riser_l);
  translate([0, 0, -1]) cylinder(d=riser_id, h=sampler_riser_l + 2);
}
