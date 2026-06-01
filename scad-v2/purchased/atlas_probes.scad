
/* [pH Probe Parameters] */

// Diameter of the neck
ph_probe_neck_diameter = 10;
// Height of the neck
ph_probe_neck_height = 26;
// Tapered diameter of the neck
ph_probe_neck_taper_diameter = 5;
// Diameter of the body
ph_probe_body_diameter = 15.6;
// Height of the body
ph_probe_body_height = 35;
// Diameter of the sensing tip
ph_probe_tip_diameter = 12;
// Height of the sensing tip
ph_probe_tip_height = 115;
// Diameter of the wire
ph_probe_wire_diameter = 3;
// Colors of the probe
ph_probe_color = "Red";




/* [DO Probe Parameters] */

// Diameter of the neck
do_probe_neck_diameter = 10;
// Tapered diameter of the neck
do_probe_neck_taper_diameter = 5;
// Height of the neck
do_probe_neck_height = 26;

// Diameter of the body
do_probe_body_diameter = 16;
// Height of the body
do_probe_body_height = 35;

// Diameter of the sensing tip
do_probe_tip_diameter = 12;
// Height of the sensing tip
do_probe_tip_height = 115;

// Diameter of the wire
do_probe_wire_diameter = 3;

// Colors of the probe
do_probe_color = "Goldenrod";


// parameters for physical realization of various atlas probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// TODO: make this more specific / granular since atlas has multiple variants
// of probes (mini vs standard vs research) with different dimensions but 
// largely the same shape

//   ["name"  [neck_d, neck_h, neck_taper_d], [body_d, body_h], [tip_d, tip_h], wire_d, accent_color]];   
ph = ["ph",  [10, 26, 5], [15.6, 35], [12, 115], 3, "Red"];
do = ["do",  [10, 26, 5], [16, 35], [12, 115], 3, "Goldenrod"];

strips_lights = [generic];

use <strip_light.scad>
