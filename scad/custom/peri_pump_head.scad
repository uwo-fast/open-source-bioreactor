/**
 * @file peri_pump_head.scad
 * @brief A printed peristaltic pump head: cassette, roller carrier and cover
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * WORK IN PROGRESS, AND NOT WHAT THIS BUILD USES. The reactor doses with three bought Kamoer
 * NKP-DC-S10B pumps - see purchased/peri_pumps.scad, which is the part the assembly carries. This
 * is the stretch goal beside it: a head of our own that a small motor could drive, which is why it
 * sits in custom/ rather than purchased/. It started as a replica of the bought pump and may yet
 * become a design; it is drawn here so the idea has somewhere to live and gets rendered.
 *
 * ONE FILE, where the repo usually splits a registry from its geometry. The split exists so a
 * registry that gets include'd everywhere does not drag geometry in with it - steel_tubes.scad and
 * printers.scad say as much where they keep their accessors inline. Nothing includes this, and
 * there is one design rather than impellers.scad's two, so a second file would buy nothing.
 *
 * Every name here carries the peri_pump_head_ prefix, because purchased/peri_pump.scad owns
 * peri_pump_* for the bought unit and OpenSCAD has one flat namespace across includes.
 *
 * Note to self: revive and use uniTube project for the tubing modelling? Here and in general?
 * Save for when approaching final design.
 */

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// The carrier diameter is a pump dimension, not a motor dimension. It sets how far the rollers sit
// from the shaft, and together with the roller offset it sets the occlusion diameter. It has to
// clear whichever motor drives the head, but that is a coupling check made where the two meet, not
// a value registered here.

//                        ["name"     [carrier_dia, carrier_base_th, carrier_allowance], [roller_od, roller_id, roller_len, roller_n, roller_offset], [cassette_h, cassette_wall, cassette_allowance], tube_dia, shaft_bore]
peri_pump_head_generic = ["generic", [50,          4,               0.2              ], [20,        10,        20,         3,        -1.5         ], [28,         3,             0.3               ], 3,        4         ];

peri_pump_heads = [peri_pump_head_generic];

function peri_pump_head_name(type) = type[0];
function peri_pump_head_carrier_diameter(type) = type[1][0]; // diameter of the roller carrier
function peri_pump_head_carrier_base_thickness(type) = type[1][1]; // thickness of the carrier base plate
function peri_pump_head_carrier_allowance(type) = type[1][2]; // clearance cut around each roller in the carrier
function peri_pump_head_roller_outer_diameter(type) = type[2][0]; // outer diameter of a roller
function peri_pump_head_roller_inner_diameter(type) = type[2][1]; // bore of a roller, and the post it turns on
function peri_pump_head_roller_length(type) = type[2][2]; // length of a roller
function peri_pump_head_roller_count(type) = type[2][3]; // number of rollers, evenly spaced
function peri_pump_head_roller_offset(type) = type[2][4]; // radial offset of the rollers, sets the occlusion
function peri_pump_head_cassette_height(type) = type[3][0]; // internal height of the cassette
function peri_pump_head_cassette_wall_thickness(type) = type[3][1]; // wall thickness of the cassette and its cover
function peri_pump_head_cassette_allowance(type) = type[3][2]; // clearance between the carrier and the cassette bore
function peri_pump_head_tube_diameter(type) = type[4]; // outer diameter of the pumped tubing
function peri_pump_head_shaft_bore(type) = type[5]; // bore for the driving motor shaft

// driven dimensions
function peri_pump_head_cassette_inner_diameter(type) =
  peri_pump_head_carrier_diameter(type) + peri_pump_head_cassette_allowance(type);
function peri_pump_head_entry_channels_width(type) = peri_pump_head_tube_diameter(type) * 2;
// distance from the shaft axis to a roller axis; the carrier and the rollers must agree on it
function peri_pump_head_roller_radius(type) =
  peri_pump_head_carrier_diameter(type) / 2 - peri_pump_head_roller_outer_diameter(type) / 2
  + peri_pump_head_roller_offset(type);

// Example usage. Live rather than commented, because this is an entry file: it renders on its own
// and `just check-mesh` builds it, which is the only thing standing between a work in progress and
// a work that has quietly stopped building.
peri_pump_head(peri_pump_head_generic);

/**
 * @brief Create a peristaltic pump from a registered type
 * @param type Registered parameter set (see peri_pumps.scad)
 *
 * Everything that is not the motor: the cassette, the roller subassembly and the cover.
 */
module peri_pump_head(type) {
  cassette_wall_thickness = peri_pump_head_cassette_wall_thickness(type);
  cassette_height = peri_pump_head_cassette_height(type);

  color("steelblue")
    peri_pump_head_cassette(type);

  translate([0, 0, cassette_wall_thickness])
    peri_pump_head_rollers(type);

  translate([0, 0, cassette_height])
    color("lightblue")
      peri_pump_head_cover(type);
}

module peri_pump_head_carrier(type) {
  carrier_diameter = peri_pump_head_carrier_diameter(type);
  base_thickness = peri_pump_head_carrier_base_thickness(type);
  carrier_allowance = peri_pump_head_carrier_allowance(type);
  roller_outer_diameter = peri_pump_head_roller_outer_diameter(type);
  roller_inner_diameter = peri_pump_head_roller_inner_diameter(type);
  roller_length = peri_pump_head_roller_length(type);
  roller_count = peri_pump_head_roller_count(type);
  shaft_bore = peri_pump_head_shaft_bore(type);

  roller_radius = peri_pump_head_roller_radius(type);

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

module peri_pump_head_roller(type) {
  roller_outer_diameter = peri_pump_head_roller_outer_diameter(type);
  roller_inner_diameter = peri_pump_head_roller_inner_diameter(type);
  roller_length = peri_pump_head_roller_length(type);

  difference() {
    cylinder(d=roller_outer_diameter, h=roller_length);
    translate([0, 0, -z_fight / 2]) // z-fighting avoidance
      cylinder(d=roller_inner_diameter, h=roller_length + z_fight);
  }
}

module peri_pump_head_rollers(type) {
  base_thickness = peri_pump_head_carrier_base_thickness(type);
  roller_count = peri_pump_head_roller_count(type);

  roller_radius = peri_pump_head_roller_radius(type);

  color("forestgreen")
    peri_pump_head_carrier(type);

  color("beige")
    translate([0, 0, base_thickness])for (i = [0:roller_count - 1]) {
      rotate([0, 0, i * 360 / roller_count])
        translate([roller_radius, 0, 0])
          peri_pump_head_roller(type);
    }
}

module peri_pump_head_bore_profile(type) {
  cassette_inner_diameter = peri_pump_head_cassette_inner_diameter(type);
  entry_channels_width = peri_pump_head_entry_channels_width(type);

  union() {
    circle(d=cassette_inner_diameter);

    for (i = [0:1])
      mirror([i, 0, 0])
        translate([cassette_inner_diameter / 2 - entry_channels_width * 2, 0, 0])
          polygon(points=[[-cassette_inner_diameter / 2, 0], [entry_channels_width, 0], [entry_channels_width, cassette_inner_diameter / 2], [0, cassette_inner_diameter / 2]]);
  }
}

module peri_pump_head_tube_profile(type) {
  cassette_inner_diameter = peri_pump_head_cassette_inner_diameter(type);
  entry_channels_width = peri_pump_head_entry_channels_width(type);
  tube_diameter = peri_pump_head_tube_diameter(type);

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

module peri_pump_head_cassette(type) {
  cassette_wall_thickness = peri_pump_head_cassette_wall_thickness(type);
  cassette_height = peri_pump_head_cassette_height(type);
  shaft_bore = peri_pump_head_shaft_bore(type);

  difference() {
    linear_extrude(height=cassette_height)
      offset(cassette_wall_thickness)
        peri_pump_head_bore_profile(type);

    translate([0, 0, cassette_wall_thickness])
      linear_extrude(height=cassette_height)
        union() {
          peri_pump_head_bore_profile(type);
          peri_pump_head_tube_profile(type);
        }

    // center hole for motor shaft
    cylinder(d=shaft_bore, h=cassette_wall_thickness * 2, center=true);
  }
}

module peri_pump_head_cover(type) {
  cassette_wall_thickness = peri_pump_head_cassette_wall_thickness(type);

  linear_extrude(height=cassette_wall_thickness)
    offset(cassette_wall_thickness)
      peri_pump_head_bore_profile(type);
}
