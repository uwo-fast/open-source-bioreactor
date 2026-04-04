include <_config.scad>;

use <motor_mount.scad>;

// ----- render controls -----

show_bottom = true;
show_middle = true;
show_top = true;

// ----- hardware params -----

base_screw_diameter = 3.1;

tube_screw_diameter = 3.1;

face_screw_diameter = 4.2;

bearing_diameter = 22.6;

shaft_diameter = 8.0;

motor_faceplate_diameter = 36.0;

motor_faceplate_screws_separation = 27.6;

motor_boss_diameter = 22.0;

nut_width = 2.5;

nut_dim = 8.0;

// ----- design selections -----

allowance_fit = 0.2; // clearance for printed parts

flange_height = 8;

raised_face_height = 10;

middle_height = 125;

facets = 20;

// ----- derived params -----

outer_diameter = bearing_diameter + (base_screw_diameter * 2) * 4;

wall_thickness = (outer_diameter - motor_boss_diameter) / 2;

bottom_top_hole_radius = (outer_diameter - wall_thickness / 2) / 2;

bottom_center_hole_diameter = shaft_diameter * 1.5;

middle_inner_diameter = outer_diameter - wall_thickness + allowance_fit;

middle_interface_hole_radius = bottom_top_hole_radius;

middle_interface_hole_diameter = base_screw_diameter * 2;

middle_interface_hole_depth = flange_height + zFite;

top_vertical_hole_depth = flange_height + raised_face_height + zFite;

bottom_vertical_hole_depth = flange_height + zFite;

// ----- build -----

if (show_bottom) {
  translate([0, 0, 0])
    color("slategrey")
      male_end(
        center_hole_diameter=bottom_center_hole_diameter,
        vertical_hole_radius=bottom_top_hole_radius,
        vertical_hole_diameter=base_screw_diameter,
        vertical_hole_depth=bottom_vertical_hole_depth,
        flange_height=flange_height,
        raised_face_height=raised_face_height,
        outer_diameter=outer_diameter,
        wall_thickness=wall_thickness,
        tube_screw_diameter=tube_screw_diameter,
        face_screw_diameter=face_screw_diameter,
        nut_width=nut_width,
        nut_dim=nut_dim,
        facets=facets,
        fit=zFite
      );
}

if (show_top) {
  translate([0, 0, middle_height + flange_height * 2])
    color("grey")
      rotate([0, 180, 0])
        male_end(
          center_hole_diameter=motor_boss_diameter,
          vertical_hole_radius=motor_faceplate_screws_separation / 2,
          vertical_hole_diameter=face_screw_diameter,
          vertical_hole_depth=top_vertical_hole_depth,
          flange_height=flange_height,
          raised_face_height=raised_face_height,
          outer_diameter=outer_diameter,
          wall_thickness=wall_thickness,
          tube_screw_diameter=tube_screw_diameter,
          face_screw_diameter=face_screw_diameter,
          nut_width=nut_width,
          nut_dim=nut_dim,
          facets=facets,
          fit=zFite
        );
}

if (show_middle) {
  color("slateblue")
    translate([0, 0, flange_height])
      middle_pipe(
        pipe_height=middle_height,
        inner_diameter=middle_inner_diameter,
        interface_hole_radius=middle_interface_hole_radius,
        interface_hole_diameter=middle_interface_hole_diameter,
        interface_hole_depth=middle_interface_hole_depth,
        flange_height=flange_height,
        raised_face_height=raised_face_height,
        outer_diameter=outer_diameter,
        tube_screw_diameter=tube_screw_diameter,
        facets=facets,
        fit=zFite
      );
}
