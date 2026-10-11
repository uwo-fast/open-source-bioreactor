// The sampler's fits, each drawn as the material that should not exist: this renders empty while
// they all hold. `just check-sampler` fails on anything it draws.
include <../../scad/custom/sampler.scad>
part = "none";

module parts() { sampler_base(); sampler_top(); }

// the board inside either part
intersection() { board_place() probe(); parts(); }
// the board's pocket grown by min_wall, outside the housing: a wall too thin
difference() {
  board_place() probe(clr + min_wall);
  translate([0, 0, board_z + bot_b]) linear_extrude(top_b - bot_b) outline();
}
// the clear tube, from its seat to its top end with the barb's stretched length, inside either part
intersection() {
  union() {
    translate([0, 0, clear_z0 + 0.05]) cylinder(d=tube_od, h=tube_top_z - clear_z0 - 0.05, $fn=96);
    translate([0, 0, tube_top_z - barb_l]) cylinder(d=barb_od, h=barb_l, $fn=96);
  }
  parts();
}
// the board swept 20 straight down out of its seat, inside the top: it cannot go in
intersection() {
  minkowski() {
    board_place() probe();
    translate([0, 0, -20]) cylinder(r=0.001, h=20, $fn=4);
  }
  sampler_top();
}
// a 1.6 mm hex key's shank on the inner screw, tilted 10 degrees outward, inside the top: out of reach
intersection() {
  translate([inner_screw_x, 0, inner_head_z + 0.3]) rotate([0, -10, 0]) cylinder(d=1.6, h=150, $fn=16);
  sampler_top();
}
// a 2.5 mm hex key 50 mm up into each face screw's counterbore, inside either part: out of reach
intersection() {
  for (h = holes) translate([each to_port(h), face_z - face_clamp_t - screw_head_height(face_screw) - 50])
    cylinder(d=2.5, h=50, $fn=16);
  parts();
}
// any screw or nut inside either part, each head 0.01 off its seat; the inserts are left out, since
// a heat-set insert melts into its hole
intersection() { sampler_fasteners(inserts=false, lift=0.01); parts(); }
// the face screws' ends and nuts inside the actuator's frame or behind its front wall: no room for
// them there. Each nut has a flat to the body's side wall, 0.4 off it, which also stops it turning.
intersection() {
  sampler_fasteners(inserts=false);
  translate([0, 0, face_z - front_x(act)]) rotate([0, -90, 0]) translate([0, 0, -axis_z]) {
    frame(get(act, "frame"));
    difference() {
      body(act_body);
      translate([front_x(act) - 1, -100, -100]) cube([actuator_wall + 1, 200, 200]);
    }
  }
}
