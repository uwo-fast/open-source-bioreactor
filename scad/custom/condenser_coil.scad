/**
 * @file condenser_coil.scad
 * @brief Coil (Dimroth-style) exhaust condenser: coolant in a tube coil hung in the exhaust
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Two printed parts and a length of soft tubing. The body is condenser_body with an outlet barb
 * under its rim and a bayonet lock in the rim. The head is the bayonet's pin: the tube's two ends
 * pass rod seals in it, and a cylinder hanging from it is the coil's former. The feed runs down
 * inside the former and turns out through a slot at its foot into the coil, which winds up its
 * outside, located by notched combs, to a window near the top where it turns back in to its seal.
 * In at the bottom, so the coil runs full and air is pushed out at the top.
 *
 * The former also closes the middle, so the gas has to pass the coil rather than go up past it.
 * Only the tubing holds water, so a porous print can leak gas, never coolant into the culture.
 * A quarter turn lifts head, former and coil out together, and the shell is a plain tube to clean.
 *
 *            in         out
 *             |          |
 *         ____|__________|_____
 *        |____|__________|_____|     head: the rim's bayonet pin, sealing on its face ring
 *         |   |          \    |
 *         | o |           o   |===   outlet barb, just under the rim
 *         | o |           o   |
 *         | o |           o   |      coil turns (o) wound on the head's former; the feed
 *         | o |           o   |      runs down inside it and out into the bottom turn
 *         | o |___________o   |
 *          \                 /       funnel
 *            \             /
 *              |         |           neck
 *            __|         |__
 *           |___         ___|        flange; z = 0 is the lid's outer face
 *              |         |           the coupling, in the lid's port
 *
 * The body prints standing on its rim, the head on its flange with the former rising from it.
 */

use <../utils/facets.scad>
use <../utils/section.scad>
use <bayonet_port.scad>
use <condenser_body.scad>
use <../purchased/aluminum_tubes.scad>
include <bayonet_interfaces.scad>

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// What the standalone file draws: the assembly, or one printed part in its print orientation
part = "assembly"; // [assembly, body, head]
// Cut the assembly's preview open to see inside; ignored on a render
cross_section_active = true;
// How much the cut leaves: 0.5 is a half, 0.75 removes a quarter
cross_section_keep = 0.5;

// example usage: the jar_10L lid's air_out port, which is std, and a 3/16 in aluminum coil
_tube_od = aluminum_tube_od(aluminum_tube_by_name("3/16x0.028"));
if (part == "body")
  translate([0, 0, condenser_coil_rim_top_z(bayonet_std)]) rotate([180, 0, 0]) condenser_coil_body(bayonet_std);
else if (part == "head")
  translate([0, 0, bayonet_flange_height(bayonet_xl)]) rotate([180, 0, 0])
    condenser_coil_head(tube_od=_tube_od, ring=oring_4p5x1p5_epdm);
else
  section(keep=cross_section_keep, size=400, active=cross_section_active && $preview)
    condenser_coil_assembly(bayonet_std, _tube_od, oring_4p5x1p5_epdm);
condenser_coil_report(bayonet_std, _tube_od);

// The defaults every module and helper below starts from, named once so the print, assembly and
// report helpers cannot drift from the parts they draw.
condenser_coil_bore = 12; // gas up, condensate down, through the pin and neck
condenser_coil_neck = 30; // straight neck above the flange
condenser_coil_shell = 38; // inside of the shell, a little over the coil
condenser_coil_shell_length = 175; // straight shell up to the rim
condenser_coil_rim = 10; // the rim, which is the head's panel
condenser_coil_port_offset = 7; // the tube ends' distance from the axis, inside the former
condenser_coil_former_wall = 1.6;
condenser_coil_pitch = 11;
condenser_coil_turns = 11.5;
condenser_coil_top_gap = 12; // coupling's bottom to the top turn's centre

// ----- the coil -----

// How long a coil of this many turns is along its axis, from the lowest turn's centre to the top one's.
function condenser_coil_height(turns, pitch) = turns * pitch;

// Tubing the coil takes, turns plus the straight feed down the middle and the two bends, roughly.
function condenser_coil_tube_length(turns, coil_diameter, pitch, feed_length) =
  turns * sqrt((PI * coil_diameter) ^ 2 + pitch ^ 2) + feed_length + PI * coil_diameter / 2;

// The former's inside clears the feed; its outside is the coil's inside.
function condenser_coil_former_inner_radius(port_offset, tube_od) = port_offset + tube_od / 2 + 0.5;
function condenser_coil_former_outer_radius(port_offset, tube_od, former_wall) =
  condenser_coil_former_inner_radius(port_offset, tube_od) + former_wall;

// The coil's centreline, the tube lying on the former.
function condenser_coil_radius(port_offset, tube_od, former_wall) =
  condenser_coil_former_outer_radius(port_offset, tube_od, former_wall) + tube_od / 2 + 0.2;

// Where each comb stands, clear of the slot at 0 degrees and the window at 180.
function condenser_coil_comb_angles() = [60, 180 + 60, 180 - 60];

// The rod seal's captive lip, as bayonet_port cuts it; a variable there, so read back through its
// centre function rather than restated.
function condenser_coil_gland_lip(ring) = bayonet_bore_gland_centre(ring, 0) - bayonet_bore_gland_length(ring) / 2;

// How far below the rim's top face the former ends: the head's coupling, the gap to the top turn,
// the coil, a pitch under it for the feed to turn out, and the tube's own half.
function condenser_coil_former_depth(rim, top_gap, turns, pitch, tube_od) =
  rim + top_gap + condenser_coil_height(turns, pitch) + pitch + tube_od / 2 + 1;

// ----- body -----

// Where the rim's top face, the head's panel, stands above the lid.
function condenser_coil_rim_top_z(
  type, bore_diameter = condenser_coil_bore, neck_height = condenser_coil_neck,
  shell_inner_diameter = condenser_coil_shell, shell_length = condenser_coil_shell_length, rim = condenser_coil_rim
) = condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, shell_length) + rim;

/**
 * @param type                 Registered bayonet interface the lid's port carries
 * @param head_type            Registered bayonet interface the head locks with
 * @param bore_diameter        Gas up, condensate down, through the pin and neck
 * @param neck_height          Straight neck above the flange
 * @param shell_inner_diameter Inside of the shell, a little over the coil so the gas passes it
 * @param shell_length         Straight shell up to the rim
 * @param wall                 Wall of the body
 * @param rim                  Rim thickness, which is the head's panel
 * @param hose_inner_diameter  Hose the outlet barb takes
 * @param outlet_bore_diameter Bore of the outlet barb
 * @param outlet_drop          Outlet's centre below the rim
 */
module condenser_coil_body(
  type,
  head_type = bayonet_xl,
  bore_diameter = condenser_coil_bore,
  neck_height = condenser_coil_neck,
  shell_inner_diameter = condenser_coil_shell,
  shell_length = condenser_coil_shell_length,
  wall = 2,
  rim = condenser_coil_rim,
  hose_inner_diameter = 6.35,
  outlet_bore_diameter = 4.5,
  outlet_drop = 14
) {
  _rs = shell_inner_diameter / 2;
  _z_shell = condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, shell_length);
  _hole_r = bayonet_port_hole_radius(head_type);
  _rim_r = max(bayonet_flange_radius(head_type), _hole_r + wall); // the head's flange lands on it
  _flare = max(0, _rim_r - (_rs + wall));
  _barb_r = hose_inner_diameter / 2;
  _barb_length = hose_inner_diameter * 2.5;
  _outlet_r = outlet_bore_diameter / 2;
  _outlet_z = _z_shell - outlet_drop;

  assert(
    outlet_drop > _flare + _outlet_r + wall,
    str("condenser_coil_body: the outlet, ", outlet_drop, " mm under the rim, runs into the rim's flare")
  );

  difference() {
    union() {
      condenser_body(type, 18, bore_diameter, neck_height, shell_inner_diameter, shell_length, wall);

      // Rim: the shell flares out at 45 degrees to carry the lock and seat the head's flange
      translate([0, 0, _z_shell - _flare - 0.5])
        difference() {
          union() {
            cylinder(h=_flare + 0.5, r1=_rs + wall, r2=_rim_r);
            translate([0, 0, _flare + 0.5 - z_fight]) cylinder(h=rim + z_fight, r=_rim_r);
          }
          translate([0, 0, -1]) cylinder(h=_flare + rim + 3, r=_rs);
          // the lock's hole, starting 0.5 above the rim's face so the lock's plain foot overlaps
          // the rim rather than resting on it face to face
          translate([0, 0, _flare + 1]) cylinder(h=rim + 2, r=_hole_r);
        }
      translate([0, 0, _z_shell + rim]) bayonet_port(type=head_type, part="lock", panel_thickness=rim);

      // Outlet barb, horizontal, out through the shell
      translate([_rs, 0, _outlet_z])
        rotate([0, 90, 0]) {
          cylinder(h=wall + 2, r=_outlet_r + wall);
          translate([0, 0, wall + 2])
            for (i = [0:2])
              translate([0, 0, i * _barb_length / 3])
                cylinder(h=_barb_length / 3, r1=_barb_r * 1.15, r2=_barb_r * 0.95);
        }
    }

    translate([_rs - wall, 0, _outlet_z])
      rotate([0, 90, 0])
        cylinder(h=_rs * 2, r=_outlet_r);
  }
}

// ----- head -----

/**
 * The head in the rim's datum: z = 0 is the rim's top face, the flange above it and the former
 * hanging below the coupling.
 *
 * @param head_type    Registered bayonet interface it locks with
 * @param rim          Rim thickness, the coupling's length
 * @param tube_od      Coolant tubing's outside diameter
 * @param ring         Registered o-ring sealing each tube end, its ID at or under tube_od
 * @param port_offset  The two tube ends' distance from the axis, both inside the former
 * @param former_wall  Wall of the former
 * @param pitch        Rise per turn; at least twice the capillary length over the tube, so water
 *                     does not bridge between turns
 * @param turns        Turns of coil; a half over a whole number, so the coil starts at 0 degrees
 *                     at the slot and ends at 180 at the window
 * @param top_gap      From the coupling's bottom to the top turn's centre, where the top end
 *                     turns in through the window to its seal
 * @param comb_width   Tangential width of each comb
 */
module condenser_coil_head(
  head_type = bayonet_xl,
  rim = condenser_coil_rim,
  tube_od = 4.7625,
  ring = oring_4p5x1p5_epdm,
  port_offset = condenser_coil_port_offset,
  former_wall = condenser_coil_former_wall,
  pitch = condenser_coil_pitch,
  turns = condenser_coil_turns,
  top_gap = condenser_coil_top_gap,
  comb_width = 2.4
) {
  _fh = bayonet_flange_height(head_type);
  _rt = tube_od / 2;
  _bore_r = _rt + 0.2;
  _fi = condenser_coil_former_inner_radius(port_offset, tube_od);
  _fo = condenser_coil_former_outer_radius(port_offset, tube_od, former_wall);
  _rc = condenser_coil_radius(port_offset, tube_od, former_wall);
  _comb_out = _rc + _rt + 0.2;
  _z_top_turn = -rim - top_gap;
  _h = condenser_coil_height(turns, pitch);
  _z_bottom = _z_top_turn - _h;
  _former_bottom = -condenser_coil_former_depth(rim, top_gap, turns, pitch, tube_od);
  _notch_h = tube_od + 0.4;
  _core_r = bayonet_interface_radius(head_type) - bayonet_pin_radius(head_type);
  _opening = tube_od + 1;

  assert(
    _comb_out < bayonet_pin_face_radius(head_type),
    str("condenser_coil_head: the coil, r ", _comb_out, ", will not pass the lock's bore")
  );
  assert(
    oring_inner_diameter(ring) <= tube_od && 2 * _bore_r > oring_inner_diameter(ring),
    str("condenser_coil_head: a ", oring_name(ring), " does not seal on a ", tube_od, " mm tube")
  );
  assert(
    port_offset + bayonet_bore_gland_radius(ring) + 1 <= _core_r
    && port_offset > bayonet_bore_gland_radius(ring) + 0.5,
    str("condenser_coil_head: seals at r ", port_offset, " break out of the coupling or into each other")
  );
  assert(
    turns - floor(turns) == 0.5,
    str("condenser_coil_head: ", turns, " turns ends the coil on the slot's side instead of at the window")
  );
  assert(
    pitch - tube_od >= 2 * 2.7,
    str(
      "condenser_coil_head: a ", pitch - tube_od, " mm gap between turns is under twice water's 2.7 mm",
      " capillary length, so condensate bridges them"
    )
  );

  difference() {
    union() {
      bayonet_port(type=head_type, part="pin", panel_thickness=rim, catch_pockets=false);

      // The former, from the coupling's bottom down past the feed's turn
      translate([0, 0, _former_bottom])
        difference() {
          cylinder(h=-rim - _former_bottom + 0.5, r=_fo);
          translate([0, 0, -1]) cylinder(h=-rim - _former_bottom + 2.5, r=_fi);
        }

      // Combs on the former, notched where the coil crosses each: the coil starts at 0 degrees and
      // rises a pitch per turn, so at this comb it is a/360 of a pitch above each whole turn
      for (a = condenser_coil_comb_angles())
        rotate([0, 0, a])
          difference() {
            translate([_fo - 0.5, -comb_width / 2, _former_bottom])
              cube([_comb_out - _fo + 0.5, comb_width, -rim - _former_bottom + 0.5]);
            for (k = [0:ceil(turns)])
              let (z = _z_bottom + (k + a / 360) * pitch)
                if (z < _z_top_turn + _notch_h / 2)
                  translate([_fo - 0.01, -comb_width, z - _notch_h / 2])
                    cube([_comb_out, comb_width * 2, _notch_h]);
          }
    }

    // Slot at 0 degrees, open at the former's foot, where the feed turns out into the coil
    translate([_fi - 1, -_opening / 2, _former_bottom - 1])
      cube([former_wall + 2, _opening, _z_bottom + _rt + 0.5 - _former_bottom + 1]);
    // Window at 180 degrees, where the top end turns back in to its seal
    rotate([0, 0, 180])
      translate([_fi - 1, -_opening / 2, _z_top_turn - _rt - 0.5])
        cube([former_wall + 2, _opening, 4 + tube_od + 1]);

    // The tube ends: bores through the head, rod seals near the coupling's bottom
    for (x = [port_offset, -port_offset])
      translate([x, 0, 0]) {
        translate([0, 0, -rim - 1]) cylinder(h=rim + _fh + 2, r=_bore_r);
        translate([0, 0, -rim + condenser_coil_gland_lip(ring)])
          cylinder(h=bayonet_bore_gland_length(ring), r=bayonet_bore_gland_radius(ring));
      }
  }
}

// ----- assembly -----

// A round tube wound on a helix: `turns` turns from angle 0 at z = 0, rising a pitch per turn.
// Swept as a polyhedron, its section a circle in the plane through the axis.
module condenser_coil_helix(radius, tube_od, pitch, turns) {
  _m = 16; // points round the section
  _n = ceil(turns * 72);
  _pts = [
    for (i = [0:_n])
      let (a = 360 * turns * i / _n, dz = pitch * turns * i / _n)
        for (j = [0:_m - 1])
          let (t = 360 * j / _m, r = radius + tube_od / 2 * cos(t))
            [r * cos(a), r * sin(a), dz + tube_od / 2 * sin(t)],
  ];
  _faces = concat(
    [[for (j = [_m - 1:-1:0]) j]],
    [[for (j = [0:_m - 1]) _n * _m + j]],
    [
      for (i = [0:_n - 1], j = [0:_m - 1])
        let (j1 = (j + 1) % _m, a = i * _m + j, b = i * _m + j1, c = (i + 1) * _m + j1, d = (i + 1) * _m + j)
          each [[a, b, c], [a, c, d]],
    ]
  );
  polyhedron(points=_pts, faces=_faces, convexity=4);
}

// The coolant tubing, for the picture and the clash check: the feed down inside the former, the
// coil from 0 degrees, the top end in and up from 180.
module condenser_coil_tubing(port_offset, coil_radius, tube_od, pitch, turns, z_top_turn, z_ends) {
  _h = condenser_coil_height(turns, pitch);
  _z_bottom = z_top_turn - _h;

  color("LightSkyBlue", 0.8) {
    translate([port_offset, 0, _z_bottom - pitch]) cylinder(h=z_ends - _z_bottom + pitch, d=tube_od);
    hull() {
      translate([port_offset, 0, _z_bottom - pitch]) sphere(d=tube_od);
      translate([coil_radius, 0, _z_bottom]) sphere(d=tube_od);
    }
    translate([0, 0, _z_bottom]) condenser_coil_helix(coil_radius, tube_od, pitch, turns);
    hull() {
      translate([-coil_radius, 0, z_top_turn]) sphere(d=tube_od);
      translate([-port_offset, 0, z_top_turn + 4]) sphere(d=tube_od);
    }
    translate([-port_offset, 0, z_top_turn + 4]) cylinder(h=z_ends - z_top_turn - 4, d=tube_od);
  }
}

// Body, head and tubing as assembled, in the lid's datum.
module condenser_coil_assembly(
  type, tube_od, ring, head_type = bayonet_xl, rim = condenser_coil_rim, top_gap = condenser_coil_top_gap,
  turns = condenser_coil_turns, pitch = condenser_coil_pitch, port_offset = condenser_coil_port_offset,
  former_wall = condenser_coil_former_wall
) {
  _z_rim = condenser_coil_rim_top_z(type);

  condenser_coil_body(type, head_type);
  translate([0, 0, _z_rim]) {
    condenser_coil_head(head_type, rim, tube_od, ring, port_offset, former_wall, pitch, turns, top_gap);
    condenser_coil_tubing(
      port_offset, condenser_coil_radius(port_offset, tube_od, former_wall), tube_od, pitch, turns, -rim - top_gap,
      bayonet_flange_height(head_type) + 15
    );
  }
}

// Coil geometry and the tubing to buy.
module condenser_coil_report(
  type, tube_od, head_type = bayonet_xl, pitch = condenser_coil_pitch, turns = condenser_coil_turns,
  rim = condenser_coil_rim, top_gap = condenser_coil_top_gap, port_offset = condenser_coil_port_offset,
  former_wall = condenser_coil_former_wall
) {
  _rc = condenser_coil_radius(port_offset, tube_od, former_wall);
  _h = condenser_coil_height(turns, pitch);
  _z_rim = condenser_coil_rim_top_z(type);
  _z_funnel = condenser_body_funnel_top_z(type, condenser_coil_bore, condenser_coil_neck, condenser_coil_shell);
  echo(
    str(
      "condenser coil: ", turns, " turns of ", tube_od, " mm tubing on a Ø", 2 * _rc, " centreline (bend radius ",
      _rc / tube_od, " x OD) at ", pitch, " mm pitch, ", _h, " mm of coil; about ",
      round(condenser_coil_tube_length(turns, 2 * _rc, pitch, _h + 60) / 10) / 100,
      " m of tubing with the feed and tails; head sealed by a ", oring_name(bayonet_oring(head_type)),
      "; rim ", _z_rim, " mm above the lid, the former ending ",
      _z_rim - condenser_coil_former_depth(rim, top_gap, turns, pitch, tube_od) - _z_funnel, " mm above the funnel"
    )
  );
}
