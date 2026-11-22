/**
 * @file sampler.scad
 * @brief The turbidity sampler on a lid port: turbidity-sensor's sampler case on this lid's bayonet pin
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The case, its fits and its bought parts are turbidity-sensor's (hardware/sampler-case/sampler_case.scad):
 * a flow cell round the probe's board, drawn through by a syringe actuator bolted on top. Its base
 * stands on a foot it is given; here the foot is the std bayonet pin, cut for this lid's panel with
 * the riser's bore and o-ring, and unioned into the base so the base stays one print. The dip tube
 * is the port's own sparge riser, cut to end open at the culture's mid-depth, where the sample is
 * drawn, and bushed into the clear tube's bottom.
 *
 * head.scad `use`s this file, so turbidity-sensor's globals stay out of it. The include order is
 * OpenSCAD's: what the foot figures are computed from is set before the include, and the figures
 * themselves after it, since a reassigned variable takes its last value where it was first assigned.
 *
 * Port frame: origin on the port's axis at the lid's outer face, +z out of the vessel, +x radially
 * outward. The reactor's figures below are restated for jar_10L only for this file's own example;
 * head.scad derives the riser's cut for its own jar.
 */

use <bayonet-port-scad/custom/bayonet_port.scad>
include <bayonet-port-scad/custom/bayonet_interfaces.scad>

// head.scad: the lid is lid_flange_height 8 + lid_plug_height 10 thick
panel = 18;

include <turbidity-sensor/hardware/sampler-case/sampler_case.scad>

// turbidity-sensor's own preview off; this file's is below
part = "none";
// the foot: the std bayonet pin, read from the port library
foot_flange_h = bayonet_flange_height(bayonet_std);
foot_neck_r = bayonet_flange_radius(bayonet_std);
foot_core_r = bayonet_interface_radius(bayonet_std) - bayonet_pin_radius(bayonet_std);
foot_gland_top_z = bayonet_bore_gland_centre(oring_4x1p5_epdm, panel) + bayonet_bore_gland_length(oring_4x1p5_epdm) / 2;

// head.scad, jar_10L: the riser stands 14.9375 over its port's top; the culture's surface is 88.4342
// from a riser's top end, and the culture stands 229.503 deep
riser_proud = 14.9375;
surface_z = foot_flange_h + riser_proud - 88.4342;
culture_depth = 229.503;
// the dip tube ends open at the culture's mid-depth, where it draws
sampler_riser_l = riser_top_z - (surface_z - culture_depth / 2);
line_ml = (sampler_riser_l * PI * pow(riser_id / 2, 2) + (window_z - riser_top_z) * PI * pow(tube_id / 2, 2)) / 1000;

// The foot: the std pin, cut for the panel, bored for the riser and sealed on it by the 4x1.5 ring.
module sampler_foot() {
  bayonet_port(type=bayonet_std, part="pin", panel_thickness=panel, center_bore_radius=riser_bore,
               bore_oring=oring_4x1p5_epdm, catch_pockets=false);
}

// What head.scad reads that needs the foot, in the port frame: the panel the pin is cut for, the
// base as its port's pin, both prints in place, and one print as it lies on the bed.
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
