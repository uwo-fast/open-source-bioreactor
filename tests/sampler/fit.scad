// Checks on the sampler, each one empty when it holds. Run each with -D check="...".
//   walls:  the board's pocket grown by min_wall, outside the housing's body (a wall too thin)
//   board:  the board itself inside either part (it does not fit)
//   flange: the pin's flange outside the outline (it would overhang)
//   tube:   the clear tube, its seat to its top end, inside either part (its way is closed)
//   cover:  the actuator just behind its front face, outside the face (the face does not cover it)
//   insert: the board swept 20 straight down out of its seat, inside the top (it cannot go in)
//   proud:  either part outside its designed outer surface (a lip, step or stray solid)
//   key:    a 1.6 hex key shank at the inner screw, tilted 10 degrees outward, inside the top (out of reach)
//   bolts:  any screw or nut inside either part (a hole, seat or slot too small); the inserts are
//           left out, since a heat-set insert is meant to melt into its hole
include <../../scad/custom/sampler.scad>
part = "none";
check = "walls"; // [walls, board, flange, tube, cover, insert, proud, key, bolts]

if (check == "walls")
  difference() {
    board_place() probe(clr + min_wall);
    translate([0, 0, board_z + bot_b]) linear_extrude(top_b - bot_b) outline();
  }
else if (check == "board")
  intersection() {
    board_place() probe();
    union() { sampler_base(); sampler_top(); }
  }
else if (check == "flange")
  difference() {
    cylinder(r=neck_r, h=flange_h, $fn=128);
    translate([0, 0, -1]) linear_extrude(10) outline();
  }
else if (check == "tube")
  intersection() {
    translate([0, 0, clear_z0 + 0.05]) cylinder(d=tube_od, h=roof_z + tube_above_roof - clear_z0 - 0.05, $fn=96);
    union() { sampler_base(); sampler_top(); }
  }
else if (check == "cover")
  difference() {
    intersection() {
      actuator_place() body(act_body);
      translate([-100, -100, face_z + 0.05]) cube([200, 200, 0.5]);
    }
    translate([0, 0, face_z - 1]) linear_extrude(3) offset(delta=0.01) polygon(face_outline);
  }
else if (check == "insert")
  intersection() {
    minkowski() {
      board_place() probe();
      translate([0, 0, -20]) cylinder(r=0.001, h=20, $fn=4);
    }
    sampler_top();
  }
else if (check == "proud")
  union() {
    difference() {
      sampler_base();
      bayonet_port(type=bayonet_std, part="pin", panel_thickness=panel, center_bore_radius=0, catch_pockets=false);
      translate([0, 0, flange_h - 1.01]) cylinder(r=neck_r + 0.01, h=neck_h + 1.02, $fn=128);
      hull() {
        translate([0, 0, flange_h + neck_h]) cylinder(r=neck_r + 0.01, h=0.01, $fn=128);
        translate([0, 0, base_z0]) linear_extrude(split_z - base_z0 + 0.01) offset(delta=0.01) outline();
      }
    }
    difference() {
      sampler_top();
      hull() {
        translate([0, 0, split_z - 0.01]) linear_extrude(roof_z - split_z + 0.01) offset(delta=0.01) outline();
        translate([0, 0, roof_z + top_skirt_h]) cylinder(r=shroud_r + 0.01, h=0.01, $fn=128);
      }
      translate([0, 0, roof_z - 1]) cylinder(r=shroud_r + 0.01, h=plate_z0 - roof_z + 2, $fn=128);
      hull() {
        translate([0, 0, plate_z0 - flare_h - 0.01]) cylinder(r=shroud_r + 0.01, h=0.01, $fn=128);
        translate([0, 0, plate_z0]) linear_extrude(plate_t + 0.01) offset(delta=0.01) polygon(face_outline);
      }
    }
  }
else if (check == "key")
  intersection() {
    translate([inner_screw_x, 0, inner_head_z + 0.3]) rotate([0, -10, 0])
      cylinder(d=1.6, h=150, $fn=16);
    sampler_top();
  }
else if (check == "bolts")
  intersection() {
    sampler_fasteners(inserts=false, lift=0.01);
    union() { sampler_base(); sampler_top(); }
  }
