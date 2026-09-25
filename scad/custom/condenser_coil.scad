/**
 * @file condenser_coil.scad
 * @brief Coil (Dimroth-style) exhaust condenser: coolant in a tube coil hung in the exhaust
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Two printed parts, a length of soft tubing, and two printed tools to shape it. The body is
 * condenser_body with an outlet barb under its rim and a bayonet lock in the rim. The head is the
 * bayonet's pin: the tube's two ends pass rod seals in it, and a solid former hanging from it
 * fills the middle of the coil, so the gas has to pass the coil rather than go up past it.
 *
 * The coil is not wound on the head. It is wound on the mandrel, whose core is the former's
 * radius, and unscrewed off; each end then turns inward and up around the bending puck, both
 * bends in open space at a radius the tube takes. The two ends come out vertical and parallel, so
 * the finished coil slides up onto the former, the bottom end in an open groove along it, and both
 * ends into their seals. The head never takes a bending load. Coolant goes in the bottom end and
 * out the top, so the coil runs full and air is pushed out at the top.
 *
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
 *         | o |           o   |      coil turns (o) round the head's former; the bottom end
 *         | o |           o   |      comes back up inside them to its seal
 *         | o |___________o   |
 *          \                 /       funnel
 *            \             /
 *              |         |           neck
 *            __|         |__
 *           |___         ___|        flange; z = 0 is the lid's outer face
 *              |         |           the coupling, in the lid's port
 *
 * The body prints standing on its rim, the head on its flange with the former rising from it, the
 * mandrel standing on its end and the puck flat.
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
part = "assembly"; // [assembly, body, head, coil, mandrel, puck]
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
else if (part == "coil")
  // the formed tube alone, in the head's datum (the rim's top face at z = 0), bought, not printed
  condenser_coil_tubing(
    condenser_coil_mandrel_radius, _tube_od, condenser_coil_bend_radius, condenser_coil_pitch, condenser_coil_turns,
    -condenser_coil_rim - condenser_coil_top_gap, bayonet_flange_height(bayonet_xl) + 15
  );
else if (part == "mandrel")
  condenser_coil_mandrel(_tube_od);
else if (part == "puck")
  condenser_coil_puck(_tube_od);
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
condenser_coil_mandrel_radius = 13; // the coil's inside, and so the former's radius
condenser_coil_bend_radius = 9.5; // both end bends; about twice a 3/16 in tube's diameter
condenser_coil_pitch = 11;
condenser_coil_turns = 12; // whole, so both ends leave at the same angle and mirror each other
condenser_coil_top_gap = 16; // coupling's bottom to the top turn's centre, room for the top bends

// ----- the coil -----

// How long a coil of this many turns is along its axis, from the lowest turn's centre to the top one's.
function condenser_coil_height(turns, pitch) = turns * pitch;

// The coil's centreline, the tube wound on the mandrel's core.
function condenser_coil_radius(mandrel_radius, tube_od) = mandrel_radius + tube_od / 2;

// Where an end's vertical leg stands, in the frame where its turn leaves at angle 0: it carries on
// along the tangent, turns inward through a quarter circle, then up through another. side is -1
// for the bottom end, which leaves against the winding, and +1 for the top end, which leaves with it.
function condenser_coil_leg(mandrel_radius, tube_od, bend_radius, side) =
  [condenser_coil_radius(mandrel_radius, tube_od) - 2 * bend_radius, side * bend_radius];

// Tubing the coil takes: the turns, the two legs up to the head, and the four quarter bends.
function condenser_coil_tube_length(turns, coil_radius, pitch, legs, bend_radius) =
  turns * sqrt((2 * PI * coil_radius) ^ 2 + pitch ^ 2) + legs + 2 * PI * bend_radius;

// The rod seal's captive lip, as bayonet_port cuts it; a variable there, so read back through its
// centre function rather than restated.
function condenser_coil_gland_lip(ring) = bayonet_bore_gland_centre(ring, 0) - bayonet_bore_gland_length(ring) / 2;

// The bottom turn's centre, below the rim's top face.
function condenser_coil_bottom_z(rim, top_gap, turns, pitch) = -rim - top_gap - condenser_coil_height(turns, pitch);

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
 * @param head_type       Registered bayonet interface it locks with
 * @param rim             Rim thickness, the coupling's length
 * @param tube_od         Coolant tubing's outside diameter
 * @param ring            Registered o-ring sealing each tube end, its ID at or under tube_od
 * @param mandrel_radius  The coil's inside; the former is fit_clearance under it, so a wound coil
 *                        slides on even if it does not spring open at all
 * @param bend_radius     The end bends' radius, which sets where the legs stand
 * @param pitch           Rise per turn; at least twice the capillary length over the tube, so water
 *                        does not bridge between turns
 * @param turns           Turns of coil, whole
 * @param top_gap         From the coupling's bottom to the top turn's centre
 * @param fit_clearance   How far the former stands inside the coil
 */
module condenser_coil_head(
  head_type = bayonet_xl,
  rim = condenser_coil_rim,
  tube_od = 4.7625,
  ring = oring_4p5x1p5_epdm,
  mandrel_radius = condenser_coil_mandrel_radius,
  bend_radius = condenser_coil_bend_radius,
  pitch = condenser_coil_pitch,
  turns = condenser_coil_turns,
  top_gap = condenser_coil_top_gap,
  fit_clearance = 0.3
) {
  _fh = bayonet_flange_height(head_type);
  _former_r = mandrel_radius - fit_clearance;
  _rt = tube_od / 2;
  _rc = condenser_coil_radius(mandrel_radius, tube_od);
  _bottom_leg = condenser_coil_leg(mandrel_radius, tube_od, bend_radius, -1);
  _top_leg = condenser_coil_leg(mandrel_radius, tube_od, bend_radius, 1);
  _leg_r = norm(_bottom_leg);
  _z_top = -rim - top_gap;
  _z_bottom = condenser_coil_bottom_z(rim, top_gap, turns, pitch);
  _core_r = bayonet_interface_radius(head_type) - bayonet_pin_radius(head_type);
  _groove_r = _rt + 0.3;

  // The former: full radius where it carries the coil, from above the bottom end's up-bend to below
  // the top end's inward turn, then 45 degrees in to a neck the top bends clear.
  // the up-bend swings across the axis's own line at one bend radius from it, nearer than the leg
  _neck_r = min(_leg_r, bend_radius) - _rt - 0.4;
  _body_bottom = _z_bottom + bend_radius + _rt + 0.5;
  _cone_top = _z_top - _rt - 0.5;
  _body_top = _cone_top - (_former_r - _neck_r);

  assert(
    _rc + _rt < bayonet_pin_face_radius(head_type) - 0.5,
    str("condenser_coil_head: the coil, r ", _rc + _rt, ", will not pass the lock's bore")
  );
  assert(
    _leg_r + _rt + 0.3 <= mandrel_radius,
    str(
      "condenser_coil_head: a leg at r ", _leg_r, " rubs the coil's inside; bend_radius ", bend_radius,
      " is too large for a ", mandrel_radius, " mm mandrel"
    )
  );
  assert(
    bend_radius >= 1.8 * tube_od,
    str("condenser_coil_head: a ", bend_radius, " mm bend is under 1.8 x the tube's ", tube_od, " mm, too tight to form")
  );
  assert(
    oring_inner_diameter(ring) <= tube_od && 2 * (_rt + 0.2) > oring_inner_diameter(ring),
    str("condenser_coil_head: a ", oring_name(ring), " does not seal on a ", tube_od, " mm tube")
  );
  assert(
    _leg_r + bayonet_bore_gland_radius(ring) + 1 <= _core_r
    && norm(_top_leg - _bottom_leg) >= 2 * bayonet_bore_gland_radius(ring) + 1,
    str("condenser_coil_head: seals at r ", _leg_r, " break out of the coupling or into each other")
  );
  assert(turns == floor(turns), str("condenser_coil_head: ", turns, " turns leaves the ends at different angles"));
  assert(
    pitch - tube_od >= 2 * 2.7,
    str(
      "condenser_coil_head: a ", pitch - tube_od, " mm gap between turns is under twice water's 2.7 mm",
      " capillary length, so condensate bridges them"
    )
  );
  assert(_body_top > _body_bottom, "condenser_coil_head: too few turns to leave the former any length");

  difference() {
    union() {
      bayonet_port(type=head_type, part="pin", panel_thickness=rim, catch_pockets=false);
      rotate_extrude()
        polygon(
          [
            [0, _body_bottom],
            [_former_r, _body_bottom],
            [_former_r, _body_top],
            [_neck_r, _cone_top],
            [_neck_r, -rim + 0.5],
            [0, -rim + 0.5],
          ]
        );
    }

    // The bottom end's groove, open to the outside so the leg drops in as the coil slides on
    hull()
      for (r = [0, _former_r])
        translate(concat(_bottom_leg * (1 + r / _leg_r), [_body_bottom - 1]))
          cylinder(h=_cone_top - _body_bottom + 2, r=_groove_r);

    // The tube ends: bores through the head, rod seals near the coupling's bottom
    for (leg = [_bottom_leg, _top_leg])
      translate(concat(leg, [0])) {
        translate([0, 0, -rim - 1]) cylinder(h=rim + _fh + 2, r=_rt + 0.2);
        translate([0, 0, -rim + condenser_coil_gland_lip(ring)])
          cylinder(h=bayonet_bore_gland_length(ring), r=bayonet_bore_gland_radius(ring));
      }
  }
}

// ----- tools -----

// A section in (r, z) swept along a helix: `turns` turns from angle 0 at z = 0, rising a pitch per turn.
module condenser_coil_helix_sweep(section, pitch, turns, steps_per_turn = 72) {
  _m = len(section);
  _n = ceil(turns * steps_per_turn);
  _pts = [
    for (i = [0:_n])
      let (a = 360 * turns * i / _n, dz = pitch * turns * i / _n)
        for (p = section) [p[0] * cos(a), p[0] * sin(a), p[1] + dz],
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

/**
 * The winding mandrel, standing on its foot: a core at the coil's inside radius, and a helical ridge
 * between the turns that sets the pitch. The ridge's underside is 45 degrees, so it prints standing.
 * Wind with a straight tail at each end, then unscrew the coil off. A hex on top takes a spanner or
 * a drill chuck; the cross hole near the foot takes a tie that holds the starting tail.
 */
module condenser_coil_mandrel(
  tube_od,
  mandrel_radius = condenser_coil_mandrel_radius,
  pitch = condenser_coil_pitch,
  turns = condenser_coil_turns,
  grip = 16
) {
  _rt = tube_od / 2;
  _length = condenser_coil_height(turns, pitch) + 2 * pitch;
  _w = pitch - tube_od - 0.4; // the ridge's root, leaving the tube 0.4 of play
  _ridge = [
    [mandrel_radius - 0.5, -_w / 2],
    [mandrel_radius + _rt, -_w / 2 + _rt + 0.5],
    [mandrel_radius + _rt, _w / 2],
    [mandrel_radius - 0.5, _w / 2],
  ];

  difference() {
    union() {
      cylinder(h=_length, r=mandrel_radius);
      // The ridge sits half a pitch off the tube's centreline, from one pitch up to one from the top
      translate([0, 0, pitch * 1.5]) condenser_coil_helix_sweep(_ridge, pitch, turns - 1);
      translate([0, 0, _length - 0.5]) cylinder(h=grip + 0.5, d=grip / cos(30), $fn=6);
    }
    translate([0, 0, pitch]) rotate([90, 0, 0]) cylinder(h=mandrel_radius * 3, d=3.2, center=true);
  }
}

/**
 * The bending puck, lying flat: a disc whose rim groove is the bend radius at the tube's centre, and
 * a straight lead-in that holds the tube square while it is pulled round. Both ends of the coil take
 * two quarter bends round it, the first inward, the second up.
 */
module condenser_coil_puck(tube_od, bend_radius = condenser_coil_bend_radius, lead = 30) {
  _rt = tube_od / 2;
  _h = tube_od + 4;

  difference() {
    union() {
      cylinder(h=_h, r=bend_radius + _rt * 0.6);
      translate([0, -bend_radius - _rt * 0.6, 0]) cube([lead, 2 * (bend_radius + _rt * 0.6), _h]);
    }
    // The groove: a 90 degree V round the rim and along the lead-in, which prints without support
    // and holds the tube on two lines
    translate([0, 0, _h / 2])
      rotate([0, 0, 90]) // round the disc's free half only, not through the lead-in
        rotate_extrude(angle=180) translate([bend_radius, 0]) rotate(45) square(tube_od * 0.75, center=true);
    translate([0, -bend_radius, _h / 2]) rotate([0, 90, 0]) rotate(45) cube([tube_od * 0.75, tube_od * 0.75, lead * 3], center=true);
  }
}

// ----- assembly -----

// Tube along a chain of points, for the picture and the clash check.
module condenser_coil_chain(pts, tube_od) {
  for (i = [0:len(pts) - 2])
    hull() {
      translate(pts[i]) sphere(d=tube_od);
      translate(pts[i + 1]) sphere(d=tube_od);
    }
}

// The coil as it is formed: the turns, and at each end the inward and upward quarter bends to a
// vertical leg reaching z_ends.
module condenser_coil_tubing(mandrel_radius, tube_od, bend_radius, pitch, turns, z_top_turn, z_ends) {
  _rc = condenser_coil_radius(mandrel_radius, tube_od);
  _r = bend_radius;
  _z_bottom = z_top_turn - condenser_coil_height(turns, pitch);

  color("LightSkyBlue", 0.8) {
    translate([0, 0, _z_bottom])
      condenser_coil_helix_sweep([for (j = [0:15]) [_rc + tube_od / 2 * cos(22.5 * j), tube_od / 2 * sin(22.5 * j)]], pitch, turns);
    for (end = [[-1, _z_bottom], [1, z_top_turn]])
      let (s = end[0], z = end[1])
        condenser_coil_chain(
          concat(
            [for (f = [0:5:90]) [_rc - _r + _r * cos(f), s * _r * sin(f), z]],
            [for (f = [5:5:90]) [_rc - _r - _r * sin(f), s * _r, z + _r - _r * cos(f)]],
            [[_rc - 2 * _r, s * _r, z_ends]]
          ),
          tube_od
        );
  }
}

// Body, head and tubing as assembled, in the lid's datum.
module condenser_coil_assembly(
  type, tube_od, ring, head_type = bayonet_xl, rim = condenser_coil_rim, top_gap = condenser_coil_top_gap,
  turns = condenser_coil_turns, pitch = condenser_coil_pitch, mandrel_radius = condenser_coil_mandrel_radius,
  bend_radius = condenser_coil_bend_radius
) {
  _z_rim = condenser_coil_rim_top_z(type);

  condenser_coil_body(type, head_type);
  translate([0, 0, _z_rim]) {
    condenser_coil_head(head_type, rim, tube_od, ring, mandrel_radius, bend_radius, pitch, turns, top_gap);
    condenser_coil_tubing(
      mandrel_radius, tube_od, bend_radius, pitch, turns, -rim - top_gap, bayonet_flange_height(head_type) + 15
    );
  }
}

// Coil geometry and the tubing to buy.
module condenser_coil_report(
  type, tube_od, head_type = bayonet_xl, pitch = condenser_coil_pitch, turns = condenser_coil_turns,
  rim = condenser_coil_rim, top_gap = condenser_coil_top_gap, mandrel_radius = condenser_coil_mandrel_radius,
  bend_radius = condenser_coil_bend_radius
) {
  _rc = condenser_coil_radius(mandrel_radius, tube_od);
  _z_rim = condenser_coil_rim_top_z(type);
  _z_funnel = condenser_body_funnel_top_z(type, condenser_coil_bore, condenser_coil_neck, condenser_coil_shell);
  _z_bottom = _z_rim + condenser_coil_bottom_z(rim, top_gap, turns, pitch);
  _legs = (_z_rim + bayonet_flange_height(head_type) + 15 - (_z_bottom + bend_radius))
    + (bayonet_flange_height(head_type) + 15 + rim + top_gap - bend_radius);
  echo(
    str(
      "condenser coil: ", turns, " turns of ", tube_od, " mm tubing on a Ø", 2 * mandrel_radius, " mandrel (centreline bend ",
      _rc / tube_od, " x OD) at ", pitch, " mm pitch, the ends bent at ", bend_radius, " mm (", bend_radius / tube_od,
      " x OD); about ", round(condenser_coil_tube_length(turns, _rc, pitch, _legs, bend_radius) / 10) / 100,
      " m of tubing with 15 mm tails; head sealed by a ", oring_name(bayonet_oring(head_type)), "; rim ", _z_rim,
      " mm above the lid, the tube's lowest point ", _z_bottom - tube_od / 2 - _z_funnel, " mm above the funnel"
    )
  );
}
