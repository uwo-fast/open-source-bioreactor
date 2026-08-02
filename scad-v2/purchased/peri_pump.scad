/**
 * @file peri_pump.scad
 * @brief Peristaltic pump model, driven off a motor shaft
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Work-in-progress!
 *
 * Note to self: revive and use uniTube project for
 * the tubing modelling? Here and in general? Save
 * for when approaching final design.
 */

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

function peri_pump_carrier_diameter(type) = type[1][0]; // diameter of the roller carrier
function peri_pump_carrier_base_thickness(type) = type[1][1]; // thickness of the carrier base plate
function peri_pump_carrier_allowance(type) = type[1][2]; // clearance cut around each roller in the carrier
function peri_pump_roller_outer_diameter(type) = type[2][0]; // outer diameter of a roller
function peri_pump_roller_inner_diameter(type) = type[2][1]; // bore of a roller, and the post it turns on
function peri_pump_roller_length(type) = type[2][2]; // length of a roller
function peri_pump_roller_count(type) = type[2][3]; // number of rollers, evenly spaced
function peri_pump_roller_offset(type) = type[2][4]; // radial offset of the rollers, sets the occlusion
function peri_pump_cassette_height(type) = type[3][0]; // internal height of the cassette
function peri_pump_cassette_wall_thickness(type) = type[3][1]; // wall thickness of the cassette and its cover
function peri_pump_cassette_allowance(type) = type[3][2]; // clearance between the carrier and the cassette bore
function peri_pump_tube_diameter(type) = type[4]; // outer diameter of the pumped tubing
function peri_pump_shaft_bore(type) = type[5]; // bore for the driving motor shaft

// driven dimensions
function peri_pump_cassette_inner_diameter(type) =
  peri_pump_carrier_diameter(type) + peri_pump_cassette_allowance(type);
function peri_pump_entry_channels_width(type) = peri_pump_tube_diameter(type) * 2;

/**
 * @brief Create a peristaltic pump from a registered type
 * @param type Registered parameter set (see peri_pumps.scad)
 *
 * Everything that is not the motor: the cassette, the roller subassembly and the cover.
 */
module peri_pump(type) {
  cassette_wall_thickness = peri_pump_cassette_wall_thickness(type);
  cassette_height = peri_pump_cassette_height(type);

  color("steelblue")
    pump_cassette(type);

  translate([0, 0, cassette_wall_thickness])
    roller_subassembly(type);

  translate([0, 0, cassette_height])
    color("lightblue")
      pump_cassette_cover(type);
}

module roller_carrier(type) {
  carrier_diameter = peri_pump_carrier_diameter(type);
  base_thickness = peri_pump_carrier_base_thickness(type);
  carrier_allowance = peri_pump_carrier_allowance(type);
  roller_outer_diameter = peri_pump_roller_outer_diameter(type);
  roller_inner_diameter = peri_pump_roller_inner_diameter(type);
  roller_length = peri_pump_roller_length(type);
  roller_count = peri_pump_roller_count(type);
  roller_offset = peri_pump_roller_offset(type);
  shaft_bore = peri_pump_shaft_bore(type);

  roller_radius = carrier_diameter / 2 - roller_outer_diameter / 2 + roller_offset;

  difference() {

    union() {
      // base plate
      cylinder(d=carrier_diameter, h=base_thickness);

      // collet protrusion for gripping the motor shaft
      translate([0, 0, base_thickness])
        cylinder(d1=carrier_diameter / 2, d2=carrier_diameter / 4, h=roller_length - base_thickness);
    }

    // remove material where rollers would interfere with the carrier center
    for (i = [0:roller_count - 1]) {
      rotate([0, 0, i * 360 / roller_count])
        translate([roller_radius, 0, base_thickness])
          cylinder(d=roller_outer_diameter + carrier_allowance, h=roller_length);
    }

    // center hole for motor shaft
    cylinder(d=shaft_bore, h=roller_length * 2, center=true);
  }

  // carrier posts
  for (i = [0:roller_count - 1]) {
    rotate([0, 0, i * 360 / roller_count])
      translate([roller_radius, 0, base_thickness / 2])
        cylinder(d=roller_inner_diameter, h=roller_length);
  }
}

module roller(type) {
  roller_outer_diameter = peri_pump_roller_outer_diameter(type);
  roller_inner_diameter = peri_pump_roller_inner_diameter(type);
  roller_length = peri_pump_roller_length(type);

  difference() {
    cylinder(d=roller_outer_diameter, h=roller_length);
    translate([0, 0, -z_fight / 2]) // z-fighting avoidance
      cylinder(d=roller_inner_diameter, h=roller_length + z_fight);
  }
}

module roller_subassembly(type) {
  carrier_diameter = peri_pump_carrier_diameter(type);
  base_thickness = peri_pump_carrier_base_thickness(type);
  roller_outer_diameter = peri_pump_roller_outer_diameter(type);
  roller_count = peri_pump_roller_count(type);
  roller_offset = peri_pump_roller_offset(type);

  roller_radius = carrier_diameter / 2 - roller_outer_diameter / 2 + roller_offset;

  color("forestgreen")
    roller_carrier(type);

  color("beige")
    translate([0, 0, base_thickness])for (i = [0:roller_count - 1]) {
      rotate([0, 0, i * 360 / roller_count])
        translate([roller_radius, 0, 0])
          roller(type);
    }
}

module cassette_inner_profile(type) {
  cassette_inner_diameter = peri_pump_cassette_inner_diameter(type);
  entry_channels_width = peri_pump_entry_channels_width(type);

  union() {
    circle(d=cassette_inner_diameter);

    for (i = [0:1])
      mirror([i, 0, 0])
        translate([cassette_inner_diameter / 2 - entry_channels_width * 2, 0, 0])
          polygon(points=[[-cassette_inner_diameter / 2, 0], [entry_channels_width, 0], [entry_channels_width, cassette_inner_diameter / 2], [0, cassette_inner_diameter / 2]]);
  }
}

module cassette_tube_path_profile(type) {
  cassette_inner_diameter = peri_pump_cassette_inner_diameter(type);
  entry_channels_width = peri_pump_entry_channels_width(type);
  tube_diameter = peri_pump_tube_diameter(type);

  color("red")
    difference() {

      union() {
        circle(d=cassette_inner_diameter);
        for (i = [0:1])
          mirror([i, 0, 0])
            translate([cassette_inner_diameter / 2 - entry_channels_width * 2, cassette_inner_diameter / 4, 0])
              polygon(points=[[0, 0], [entry_channels_width, 0], [entry_channels_width, cassette_inner_diameter / 2], [0, cassette_inner_diameter / 2]]);
      }

      circle(d=cassette_inner_diameter - tube_diameter * 4);
      translate([0, cassette_inner_diameter / 4, 0])
        square([2 * (cassette_inner_diameter / 2 - entry_channels_width * 2), cassette_inner_diameter / 2], center=true);
    }
}

module pump_cassette(type) {
  cassette_wall_thickness = peri_pump_cassette_wall_thickness(type);
  cassette_height = peri_pump_cassette_height(type);
  shaft_bore = peri_pump_shaft_bore(type);

  difference() {
    linear_extrude(height=cassette_height)
      offset(cassette_wall_thickness)
        cassette_inner_profile(type);

    translate([0, 0, cassette_wall_thickness])
      linear_extrude(height=cassette_height)
        union() {
          cassette_inner_profile(type);
          cassette_tube_path_profile(type);
        }

    // center hole for motor shaft
    cylinder(d=shaft_bore, h=cassette_wall_thickness * 2, center=true);
  }
}

module pump_cassette_cover(type) {
  cassette_wall_thickness = peri_pump_cassette_wall_thickness(type);

  linear_extrude(height=cassette_wall_thickness)
    offset(cassette_wall_thickness)
      cassette_inner_profile(type);
}
