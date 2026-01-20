include <_config.scad>;

rotate_xsection = 0; // [0:1:360]

// module to create a negative mold (for impeller casting)

module mould_negative(
  x_bound_dim,
  y_bound_dim,
  z_bound_dim,
  wall_thickness,
  hole_diameter_outer,
  hole_diameter_inner,
  corner_holes_diameter = 0
) {
  z_fight = 0.05; // small offset to avoid z-fighting
  // outer box
  difference() {
    translate([0, 0, 0]) {
      difference() {
        cube([x_bound_dim + wall_thickness * 2, y_bound_dim + wall_thickness * 2, z_bound_dim + wall_thickness * 2], center=true);
        // hole at top for pouring
        translate([0, 0, (z_bound_dim + wall_thickness) / 2])
          cylinder(h=wall_thickness + z_fight, d2=hole_diameter_outer, d1=hole_diameter_inner, center=true, $fn=128);
        // corner holes to screw in feet to let air / fluid drain
        if (corner_holes_diameter > 0) {
          for (x_sign = [-1, 1])
            for (y_sign = [-1, 1])
              translate([x_sign * (x_bound_dim / 2 + wall_thickness / 2), y_sign * (y_bound_dim / 2 + wall_thickness / 2), 0])
                cylinder(h=z_bound_dim + wall_thickness * 2 + z_fight, d=corner_holes_diameter, center=true, $fn=64);
        }
      }
    }

    children();
  }
}

module cross_section(x, y, z, rot = 0, active = true) {
  difference() {
    children();
    if (active) {
      rotate([0, 0, rot])
        translate([-x / 2, 0, -z / 2])
          cube([x, y, z]);
    }
  }
}

// test with impeller
use <impeller.scad>

// jar diameter
jar_diameter = 220;
// diameter of the shaft
shaft_diameter = 8.0;
// impeller diameter to tank diameter ratio
impeller_DT_factor = 0.45;
// impeller height
impeller_height = 60;
// number of fins
impeller_n_fins = 4;
// twist angle of each fin
impeller_twist_ang = 55;
// width of each fin blade
impeller_fin_width = 4;
// size of the center hub
impeller_hub_radius = 7.5;
// allowance for the shaft hole
impeller_shaft_allow = 0.1;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;

// Driven Parameters
// diameter of the impeller
impeller_diameter = jar_diameter * impeller_DT_factor;
// radius of the impeller
impeller_radius = impeller_diameter / 2;
// radius of the shaft hole in the impeller
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_allow) / 2;

bottom_drain_hole_diameter = 1;

module my_impeller() {
  union() {
    // impeller body
    impeller(
      radius=impeller_radius, height=impeller_height, fins=impeller_n_fins, twist=impeller_twist_ang,
      fin_width=impeller_fin_width, center_hub_radius=impeller_hub_radius,
      center_hole_radius=impeller_shaft_hole_radius, center_hole_radius_lower=impeller_shaft_hole_radius - impeller_shaft_radius_interference
    );

    // top ring to connect the fin tops for mechanical stability
    translate([0, 0, impeller_height / 2 - impeller_fin_width / 2])
      linear_extrude(impeller_fin_width, center=true) difference() {
          circle(r=impeller_radius + impeller_fin_width, $fn=64);
          circle(r=impeller_radius, $fn=64);
        }

    // ring of additional holes at the base of the impeller for air escape during casting
    hub_wall_thickness = (impeller_hub_radius * 2 - shaft_diameter) / 2;
    for (i = [0:7])
      rotate([0, 0, i * 45])
        translate([shaft_diameter / 2 + hub_wall_thickness / 2, 0, -impeller_height / 2 - wall_thickness])
          cylinder(h=wall_thickness + zFite, d2=hub_wall_thickness, d1=bottom_drain_hole_diameter, $fn=128);

    // line the bottom of the fins with holes for air escape during casting
    for (i = [0:impeller_n_fins - 1]) {
      rotate([0, 0, i * (360 / impeller_n_fins)])for (j = [1:5])
        translate([(impeller_radius) * (j / 6) + hub_wall_thickness, hub_wall_thickness / 2, -impeller_height / 2 - wall_thickness])
          cylinder(h=wall_thickness + zFite, d2=hub_wall_thickness, d1=bottom_drain_hole_diameter, $fn=128);
    }
  }
}

x_bound = impeller_diameter;
y_bound = impeller_diameter;
z_bound = impeller_height;

wall_thickness = 10;

hole_diameter_outer = 3;
hole_diameter_inner = impeller_hub_radius * 2;

corner_holes_diameter = 4.1;

show_xsection = false;

show_mould_negative = true;

if (show_mould_negative) {
  cross_section(x_bound * 2, y_bound * 2, z_bound * 2, rot=rotate_xsection, active=show_xsection)
    mould_negative(
      x_bound_dim=x_bound, y_bound_dim=y_bound, z_bound_dim=z_bound,
      wall_thickness=wall_thickness, hole_diameter_outer=hole_diameter_outer, hole_diameter_inner=hole_diameter_inner, corner_holes_diameter=corner_holes_diameter
    )
      my_impeller();
} else {
  my_impeller();
}
