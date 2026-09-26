/**
 * @file condenser_coil.scad
 * @brief Coil (Dimroth-style) exhaust condenser: coolant in a tube coil hung in the exhaust
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Three printed parts, a length of soft tubing, and two printed tools to shape it. The body is
 * condenser_body with an outlet barb under its rim and a bayonet lock in the rim. The head is two
 * pieces: a panel, which is the bayonet's pin and carries a rod seal for each end of the tube, and
 * a former, which hangs from it and fills the middle of the coil so the gas has to pass the coil
 * rather than go up past it.
 *
 * The former is also the arbor the coil is wound on. A coil whose bottom end runs back up its own
 * middle cannot come off a one-piece mandrel - to unscrew, the ridge has to sweep through the leg -
 * so the coil is wound where it stays, and the ridges that set the pitch stay between the turns.
 * Each end's bends are formed on a puck away from the part, the bottom end before winding and the
 * top end after, and both are laid into channels open to the outside rather than threaded along.
 * The panel goes on last, lowered onto two ends that are already vertical and parallel. Coolant
 * goes in the bottom end and out the top, so the coil runs full and air is pushed out at the top.
 *
 * Only the tubing holds water, so a porous print can leak gas, never coolant into the culture.
 * A quarter turn lifts head, former and coil out together, and the shell is a plain tube to clean.
 *
 *            in         out
 *             |          |
 *         ____|__________|_____
 *        |____|__________|_____|     panel: the rim's bayonet pin, sealing on its face ring
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
 * The body prints standing on its rim, the panel on its flange, the former standing on its chuck
 * stub with the coil's end uppermost, and the pucks flat.
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
part = "assembly"; // [assembly, body, panel, former, coil, puck_bottom, puck_top]
// Cut the assembly's preview open to see inside; ignored on a render
cross_section_active = true;
// How much the cut leaves: 0.5 is a half, 0.75 removes a quarter
cross_section_keep = 0.5;

// example usage: the jar_10L lid's air_out port, which is std, and a 3/16 in aluminum coil
_tube_od = aluminum_tube_od(aluminum_tube_by_name("3/16x0.028"));
if (part == "body")
  translate([0, 0, condenser_coil_rim_top_z(bayonet_std)]) rotate([180, 0, 0]) condenser_coil_body(bayonet_std);
else if (part == "panel")
  translate([0, 0, bayonet_flange_height(bayonet_xl)]) rotate([180, 0, 0])
    condenser_coil_panel(tube_od=_tube_od, ring=oring_4p5x1p5_epdm);
else if (part == "former")
  // standing on its foot, which is how it is wound and how it prints
  translate([0, 0, -condenser_coil_former_bottom_z(_tube_od)]) condenser_coil_former(_tube_od);
else if (part == "coil")
  // the formed tube alone, in the head's datum (the rim's top face at z = 0), bought, not printed
  condenser_coil_tubing(
    condenser_coil_former_radius, _tube_od, condenser_coil_pitch, condenser_coil_turns,
    -condenser_coil_rim - condenser_coil_top_gap, bayonet_flange_height(bayonet_xl) + 15
  );
else if (part == "puck_bottom")
  condenser_coil_puck(_tube_od, condenser_coil_bend_radius);
else if (part == "puck_top")
  condenser_coil_puck(_tube_od, condenser_coil_top_bend_radius);
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
condenser_coil_former_radius = 13; // the coil is wound on this, so it is the coil's inside
// The bottom end's bends. Its leg runs up a groove in the former, so the leg has to finish inside
// the former's radius, and the leg's radius is what the bend radius decides - see the assert.
condenser_coil_bend_radius = 9.5; // about twice a 3/16 in tube's diameter
// The top end's, which only has to reach a seal: a gentler bend, and it lands further out, which
// is as far as the coupling's core lets a seal sit.
condenser_coil_top_bend_radius = 11.25;
condenser_coil_pitch = 11;
condenser_coil_turns = 12; // whole, so both ends leave at the same angle
condenser_coil_top_gap = 16; // coupling's bottom to the top turn's centre, room for the top bends
condenser_coil_seat_allow = 0.2; // between a turn and the ridges that set its pitch
condenser_coil_channel_allow = 0.4; // between the tube and the channel in the former it lies in
condenser_coil_socket_depth = 6; // how far the former's spigot goes up into the panel
// The funnel under each bore that finds an end a little out of place. It has to stay shallower
// than the lip that holds the o-ring captive in its gland, or the pocket opens at the bottom and
// the ring pushes out - see the assert. It also sets how wide the spigot can be, since the bottom
// end's bore is the nearest of the two to the axis.
condenser_coil_bore_lead = 0.4;
condenser_coil_screw_clear = 1.7; // an M3's clearance; the head countersinks into the coupling
condenser_coil_screw_pilot = 1.25; // what it bites in the spigot
condenser_coil_screw_head = 3.0; // the counterbore that buries an M3 cap head
condenser_coil_screw_head_depth = 3.5;

// ----- the coil -----

// How long a coil of this many turns is along its axis, from the lowest turn's centre to the top one's.
function condenser_coil_height(turns, pitch) = turns * pitch;

// The coil's centreline, the tube wound on the former.
function condenser_coil_radius(former_radius, tube_od) = former_radius + tube_od / 2;

// Where an end's vertical leg stands, in the frame where its turn leaves at angle 0: it carries on
// along the tangent, turns inward through a quarter circle, then up through another. side is -1
// for the bottom end, which leaves against the winding, and +1 for the top end, which leaves with it.
function condenser_coil_leg(former_radius, tube_od, bend_radius, side) =
  [condenser_coil_radius(former_radius, tube_od) - 2 * bend_radius, side * bend_radius];

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


// ----- the two ends -----

// One end's path, from where it leaves a turn to the top of its vertical leg: on along the
// tangent, a quarter circle inward, a quarter circle up, then the leg. side is -1 for the bottom
// end, which leaves against the winding, and +1 for the top end, which leaves with it. The former
// is channelled from the same points, so the tube and the channel cannot drift apart.
function condenser_coil_end_path(coil_radius, bend_radius, side, z_turn, z_leg_end, step = 5) =
  let (_r = bend_radius)
    concat(
      [for (f = [0:step:90]) [coil_radius - _r + _r * cos(f), side * _r * sin(f), z_turn]],
      [for (f = [step:step:90]) [coil_radius - _r - _r * sin(f), side * _r, z_turn + _r - _r * cos(f)]],
      [[coil_radius - 2 * _r, side * _r, z_leg_end]]
    );

/**
 * A channel along a path, open all the way out to out_radius. An end bent to shape while the tube
 * was straight is laid into it from the side; nothing is threaded along it, which is the step that
 * cannot be done once the coil is wound.
 */
module condenser_coil_open_channel(pts, tube_od, out_radius, allow = condenser_coil_channel_allow) {
  _r = tube_od / 2 + allow;
  for (i = [0:len(pts) - 2])
    hull()
      for (q = [pts[i], pts[i + 1]])
        let (_h = norm([q[0], q[1]]), _u = _h < 0.01 ? [1, 0] : [q[0], q[1]] / _h)
          for (o = [[q[0], q[1]], _u * max(_h, out_radius)])
            translate([o[0], o[1], q[2]]) sphere(r=_r, $fn=16);
}

// ----- the former -----

/**
 * The ridge between two turns, as an (r, z) section with z = 0 at the centre of the turn below it.
 *
 * The top face is flat, and it is what sets the pitch: wind pushing each turn down onto the ridge
 * under it. The underside is 45 degrees, which is all a part printed standing can hold, and it
 * runs tangent to the turn below, so the channel is as close as an overhang allows. A turn is
 * located from beneath and left loose above; that slack is the price of printing the former
 * upright, and the reason the winding direction matters.
 */
function condenser_coil_ridge(former_radius, tube_od, pitch, seat = condenser_coil_seat_allow) =
  let (
    _rt = tube_od / 2,
    _root = former_radius - 0.5,
    _tip = former_radius + _rt,
    _over = sqrt(2) * (_rt + seat), // where a 45 degree tangent to the turn below crosses the tip
    _top = pitch - (_rt + seat)
  )
    [[_root, _over - (_tip - _root)], [_tip, _over], [_tip, _top], [_root, _top]];

// The former's bottom face, just under the lowest turn it carries.
function condenser_coil_former_bottom_z(
  tube_od, rim = condenser_coil_rim, top_gap = condenser_coil_top_gap,
  turns = condenser_coil_turns, pitch = condenser_coil_pitch, chuck_length = 15
) = condenser_coil_bottom_z(rim, top_gap, turns, pitch) - tube_od / 2 - 1 - chuck_length;

// How far out a seal can sit in the coupling, which is what limits the top end's reach.
function condenser_coil_seal_limit(head_type, ring) =
  bayonet_interface_radius(head_type) - bayonet_pin_radius(head_type) - bayonet_bore_gland_radius(ring) - 1;

/**
 * The former: the arbor the coil is wound on, and the plug that fills the middle afterwards so the
 * gas has to pass the coil rather than go up past it. It stays in the reactor, so the ridges that
 * set the pitch stay between the turns and hold them there - they cost nothing in flow, sitting in
 * the dead space between the former and the coil that the former already blocks.
 *
 * Wound standing on its chuck stub, which is below everything the coil touches. The bottom end is
 * laid into its channel first, bent to shape, and the turns go on over it.
 *
 * @param tube_od        Coolant tubing's outside diameter
 * @param former_radius  The coil's inside, which is this part's radius
 * @param bend_radius    The bottom end's bends, which its channel follows
 * @param pitch          Rise per turn
 * @param turns          Turns of coil, whole
 * @param rim            Rim thickness, the coupling's length
 * @param top_gap        From the coupling's bottom to the top turn's centre
 * @param chuck_length   The stub below the coil that a chuck grips while winding
 */
module condenser_coil_former(
  tube_od,
  former_radius = condenser_coil_former_radius,
  bend_radius = condenser_coil_bend_radius,
  top_bend_radius = condenser_coil_top_bend_radius,
  pitch = condenser_coil_pitch,
  turns = condenser_coil_turns,
  rim = condenser_coil_rim,
  top_gap = condenser_coil_top_gap,
  chuck_length = 15,
  chuck_radius = 6
) {
  _rt = tube_od / 2;
  _rc = condenser_coil_radius(former_radius, tube_od);
  _z_top = -rim - top_gap;
  _z_bottom = condenser_coil_bottom_z(rim, top_gap, turns, pitch);
  _foot = _z_bottom - _rt - 1;
  _body_top = _z_top + _rt + 1;
  _spigot_r = condenser_coil_spigot_radius(tube_od, bend_radius, former_radius);
  _cone_top = _body_top + (former_radius - _spigot_r); // 45 degrees, so it prints unsupported
  _spigot_top = -rim + condenser_coil_socket_depth;
  _bottom_path = condenser_coil_end_path(_rc, bend_radius, -1, _z_bottom, _spigot_top, 10);
  _top_path = condenser_coil_end_path(_rc, top_bend_radius, 1, _z_top, _spigot_top, 10);

  assert(
    _cone_top < _spigot_top,
    str("condenser_coil_former: no room between the top turn and the panel for the cone and spigot")
  );

  difference() {
    union() {
      rotate_extrude()
        polygon(
          [
            [0, _foot - chuck_length],
            [chuck_radius, _foot - chuck_length],
            [chuck_radius, _foot],
            [former_radius, _foot],
            [former_radius, _body_top],
            [_spigot_r, _cone_top],
            [_spigot_r, _spigot_top],
            [0, _spigot_top],
          ]
        );
      // The ridges, one between each pair of turns, starting above the lowest
      translate([0, 0, _z_bottom])
        condenser_coil_helix_sweep(condenser_coil_ridge(former_radius, tube_od, pitch), pitch, turns - 1);
    }

    // Both ends lie in channels open to the outside, so a bent end drops in sideways
    condenser_coil_open_channel(_bottom_path, tube_od, former_radius + 1);
    condenser_coil_open_channel(_top_path, tube_od, former_radius + 1);

    // The screw from the panel bites here. The two ends passing through the panel already fix
    // which way round the former sits, so this lines up with the clearance hole unindexed.
    translate([0, 0, -rim + condenser_coil_socket_depth / 2])
      rotate([0, 90, 0]) cylinder(h=2 * _spigot_r + 2, r=condenser_coil_screw_pilot, center=true);

    // A tie through the stub holds the starting tail while the first turn goes on
    translate([0, 0, _foot - chuck_length / 2]) rotate([90, 0, 0]) cylinder(h=4 * chuck_radius, d=3.2, center=true);
  }
}

// ----- the panel -----

function condenser_coil_spigot_radius(tube_od, bend_radius, former_radius = condenser_coil_former_radius) =
  norm(condenser_coil_leg(former_radius, tube_od, bend_radius, -1))
  - (tube_od / 2 + 0.2) - condenser_coil_bore_lead - 0.6;

/**
 * The panel in the rim's datum: z = 0 is the rim's top face. The bayonet's pin, the two rod seals,
 * and a socket the former's spigot plugs into.
 *
 * It is a separate part so it can be lowered onto two ends that are already vertical and parallel.
 * Nothing is threaded into a hole - which is the step that fails once a coil is in the way - and
 * the o-ring glands stay whole bores, never split across a joint that coolant could weep through.
 *
 * @param head_type    Registered bayonet interface it locks with
 * @param rim          Rim thickness, the coupling's length
 * @param tube_od      Coolant tubing's outside diameter
 * @param ring         Registered o-ring sealing each tube end, its ID at or under tube_od
 * @param bend_radius  The bottom end's bends, which put its leg and so its seal
 * @param top_bend_radius  The top end's, which reach further out
 */
module condenser_coil_panel(
  head_type = bayonet_xl,
  rim = condenser_coil_rim,
  tube_od = 4.7625,
  ring = oring_4p5x1p5_epdm,
  former_radius = condenser_coil_former_radius,
  bend_radius = condenser_coil_bend_radius,
  top_bend_radius = condenser_coil_top_bend_radius,
  pitch = condenser_coil_pitch,
  turns = condenser_coil_turns
) {
  _fh = bayonet_flange_height(head_type);
  _rt = tube_od / 2;
  _rc = condenser_coil_radius(former_radius, tube_od);
  _bottom_leg = condenser_coil_leg(former_radius, tube_od, bend_radius, -1);
  _top_leg = condenser_coil_leg(former_radius, tube_od, top_bend_radius, 1);
  _bore_r = _rt + 0.2;
  _spigot_r = condenser_coil_spigot_radius(tube_od, bend_radius, former_radius);
  _lead = condenser_coil_bore_lead;
  _face_r = bayonet_pin_face_radius(head_type);
  _screw_z = -rim + condenser_coil_socket_depth / 2;

  assert(
    _rc + _rt < bayonet_pin_face_radius(head_type) - 0.5,
    str("condenser_coil_panel: the coil, r ", _rc + _rt, ", will not pass the lock's bore")
  );
  assert(
    norm(_bottom_leg) + _rt + 0.3 <= former_radius,
    str(
      "condenser_coil_panel: the bottom leg at r ", norm(_bottom_leg), " will not lie inside the coil;",
      " bend_radius ", bend_radius, " is wrong for a ", former_radius, " mm former"
    )
  );
  for (b = [bend_radius, top_bend_radius])
    assert(
      b >= 1.8 * tube_od,
      str("condenser_coil_panel: a ", b, " mm bend is under 1.8 x the tube's ", tube_od, " mm, too tight to form")
    );
  assert(
    oring_inner_diameter(ring) <= tube_od && 2 * (_rt + 0.2) > oring_inner_diameter(ring),
    str("condenser_coil_panel: a ", oring_name(ring), " does not seal on a ", tube_od, " mm tube")
  );
  for (leg = [_bottom_leg, _top_leg])
    assert(
      norm(leg) <= condenser_coil_seal_limit(head_type, ring),
      str(
        "condenser_coil_panel: a seal at r ", norm(leg), " breaks out of the coupling, which takes one to r ",
        condenser_coil_seal_limit(head_type, ring)
      )
    );
  assert(
    norm(_top_leg - _bottom_leg) >= 2 * bayonet_bore_gland_radius(ring) + 1,
    str("condenser_coil_panel: the two seals, ", norm(_top_leg - _bottom_leg), " mm apart, run into each other")
  );
  assert(
    condenser_coil_gland_lip(ring) - _lead >= 0.8,
    str(
      "condenser_coil_panel: a ", _lead, " mm lead-in leaves ", condenser_coil_gland_lip(ring) - _lead,
      " mm of the ", condenser_coil_gland_lip(ring), " mm lip that holds the o-ring captive; under 0.8",
      " and the gland opens at the bottom and the ring pushes out"
    )
  );
  assert(
    _spigot_r >= 4,
    str("condenser_coil_panel: a ", _spigot_r, " mm spigot is too slight to carry the former")
  );
  assert(turns == floor(turns), str("condenser_coil_panel: ", turns, " turns leaves the ends at different angles"));
  assert(
    pitch - tube_od >= 2 * 2.7,
    str(
      "condenser_coil_panel: a ", pitch - tube_od, " mm gap between turns is under twice water's 2.7 mm",
      " capillary length, so condensate bridges them"
    )
  );
  assert(
    pitch > (1 + sqrt(2)) * (tube_od / 2 + condenser_coil_seat_allow),
    str("condenser_coil_panel: a ", pitch, " mm pitch leaves no room for a ridge that prints standing")
  );

  difference() {
    bayonet_port(type=head_type, part="pin", panel_thickness=rim, catch_pockets=false);

    // The socket the former's spigot plugs into, and the screw that holds it there. The screw goes
    // in from outside at the height where the coupling's face is widest, so the countersink has a
    // known surface to sit in and the head finishes under it - the body's bore is only 2.5 mm
    // clear, so a proud head would foul on the way in. It crosses the wall, the socket and the
    // spigot, and stops in a blind relief rather than breaking out the far side.
    translate([0, 0, -rim - z_fight]) cylinder(h=condenser_coil_socket_depth + z_fight, r=_spigot_r + 0.25);
    translate([0, 0, _screw_z]) rotate([0, 90, 0]) let ($fn = facet_count(condenser_coil_screw_head)) {
      translate([0, 0, _spigot_r]) cylinder(h=_face_r - _spigot_r + 1, r=condenser_coil_screw_clear);
      // A counterbore, not a countersink: the face it lands on is a cylinder, so the head wants a
      // flat seat, and a bounded pocket cannot run on and scoop the flange the way a cone does.
      translate([0, 0, _face_r - condenser_coil_screw_head_depth])
        cylinder(h=condenser_coil_screw_head_depth + 1, r=condenser_coil_screw_head);
      // the tip's relief, on the far side, blind
      translate([0, 0, -_spigot_r - 1.5]) cylinder(h=1.5 + z_fight, r=condenser_coil_screw_pilot + 0.2);
    }

    // The tube ends: a funnel to find the bore, the bore, and the rod seal near the coupling's
    // bottom. All three share the gland's fragment count, which is the widest of them, so their
    // facets meet instead of crossing where one runs into the next.
    for (leg = [_bottom_leg, _top_leg])
      translate(concat(leg, [0]))
        let ($fn = facet_count(bayonet_bore_gland_radius(ring))) {
          translate([0, 0, -rim - 1]) cylinder(h=rim + _fh + 2, r=_bore_r);
          translate([0, 0, -rim - z_fight]) cylinder(h=_lead, r1=_bore_r + _lead, r2=_bore_r);
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
 * The bending puck, lying flat: a disc whose rim groove is the bend radius at the tube's centre,
 * and a straight lead-in that holds the tube square while it is pulled round. Each end takes two
 * quarter bends round it, the first inward and the second up, and the two ends bend at different
 * radii, so there is a puck for each.
 *
 * The groove is a V that opens outward, and it has to be deep enough to take the tube to its
 * centre or the tube rides up and the radius comes out wrong: a 90 degree V holds a tube with its
 * centre sqrt(2) x its radius above the apex, and the mouth has to be at least that wide again.
 */
module condenser_coil_puck(tube_od, bend_radius = condenser_coil_bend_radius, lead = 30) {
  _rt = tube_od / 2;
  _v = sqrt(2) * _rt; // a 90 degree V holds a tube with its centre this far above the apex
  _apex_r = bend_radius - _v; // so the tube's centre lands on bend_radius, not short of it
  _disc_r = bend_radius + 0.5; // the rim just past the tube's centre, so the V holds it
  _reach = _disc_r - _apex_r + 1; // the flanks carried past the rim, so the mouth is never pinched
  _h = 2 * (_reach + 2); // enough shoulder over the V that the tool is not two slabs
  _vee = [[0, 0], [_reach, _reach], [_reach, -_reach]];

  difference() {
    union() {
      cylinder(h=_h, r=_disc_r);
      translate([0, -_disc_r, 0]) cube([lead, 2 * _disc_r, _h]);
    }
    // Round the rim, over the free half the tube is pulled around
    translate([0, 0, _h / 2])
      rotate([0, 0, 90])
        rotate_extrude(angle=180) translate([_apex_r, 0]) polygon(_vee);
    // and on along the lead-in, which holds the tube square while it is pulled
    translate([0, 0, _h / 2])
      rotate([0, 90, 0])
        linear_extrude(height=3 * lead, center=true)
          polygon([[0, -_apex_r], [-_reach, -_apex_r - _reach], [_reach, -_apex_r - _reach]]);
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
// vertical leg reaching z_ends. The two ends bend at different radii - the bottom one has to
// finish inside the coil, the top one only has to reach its seal.
module condenser_coil_tubing(
  former_radius, tube_od, pitch, turns, z_top_turn, z_ends,
  bend_radius = condenser_coil_bend_radius, top_bend_radius = condenser_coil_top_bend_radius
) {
  _rc = condenser_coil_radius(former_radius, tube_od);
  _z_bottom = z_top_turn - condenser_coil_height(turns, pitch);

  color("LightSkyBlue", 0.8) {
    translate([0, 0, _z_bottom])
      condenser_coil_helix_sweep([for (j = [0:15]) [_rc + tube_od / 2 * cos(22.5 * j), tube_od / 2 * sin(22.5 * j)]], pitch, turns);
    condenser_coil_chain(condenser_coil_end_path(_rc, bend_radius, -1, _z_bottom, z_ends), tube_od);
    condenser_coil_chain(condenser_coil_end_path(_rc, top_bend_radius, 1, z_top_turn, z_ends), tube_od);
  }
}

// Body, head and tubing as assembled, in the lid's datum.
module condenser_coil_assembly(
  type, tube_od, ring, head_type = bayonet_xl, rim = condenser_coil_rim, top_gap = condenser_coil_top_gap,
  turns = condenser_coil_turns, pitch = condenser_coil_pitch, former_radius = condenser_coil_former_radius,
  bend_radius = condenser_coil_bend_radius
) {
  _z_rim = condenser_coil_rim_top_z(type);

  condenser_coil_body(type, head_type);
  translate([0, 0, _z_rim]) {
    condenser_coil_panel(head_type, rim, tube_od, ring, former_radius, bend_radius);
    color("Gainsboro") condenser_coil_former(tube_od, former_radius, bend_radius);
    condenser_coil_tubing(
      former_radius, tube_od, pitch, turns, -rim - top_gap, bayonet_flange_height(head_type) + 15
    );
  }
}

// Coil geometry and the tubing to buy.
module condenser_coil_report(
  type, tube_od, head_type = bayonet_xl, pitch = condenser_coil_pitch, turns = condenser_coil_turns,
  rim = condenser_coil_rim, top_gap = condenser_coil_top_gap, former_radius = condenser_coil_former_radius,
  bend_radius = condenser_coil_bend_radius
) {
  _rc = condenser_coil_radius(former_radius, tube_od);
  _z_rim = condenser_coil_rim_top_z(type);
  _z_funnel = condenser_body_funnel_top_z(type, condenser_coil_bore, condenser_coil_neck, condenser_coil_shell);
  _z_bottom = _z_rim + condenser_coil_bottom_z(rim, top_gap, turns, pitch);
  _top_bend = condenser_coil_top_bend_radius;
  _legs = (_z_rim + bayonet_flange_height(head_type) + 15 - (_z_bottom + bend_radius))
    + (bayonet_flange_height(head_type) + 15 + rim + top_gap - _top_bend);
  echo(
    str(
      "condenser coil: ", turns, " turns of ", tube_od, " mm tubing on a Ø", 2 * former_radius, " former (centreline bend ",
      _rc / tube_od, " x OD) at ", pitch, " mm pitch, the ends bent at ", bend_radius, " mm (", bend_radius / tube_od,
      " x OD) and ", _top_bend, " mm (", _top_bend / tube_od,
      " x OD); about ", round(condenser_coil_tube_length(turns, _rc, pitch, _legs, (bend_radius + _top_bend) / 2) / 10) / 100,
      " m of tubing with 15 mm tails; head sealed by a ", oring_name(bayonet_oring(head_type)), "; rim ", _z_rim,
      " mm above the lid, the tube's lowest point ", _z_bottom - tube_od / 2 - _z_funnel, " mm above the funnel"
    )
  );
}
