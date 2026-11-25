/**
 * @file condenser_coil.scad
 * @brief Coil (Dimroth-style) exhaust condenser: coolant flows through a tube coil in the exhaust
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Three printed parts, a length of soft tubing, and two printed tools to shape the tubing. The body
 * is condenser_body with an outlet barb under its rim and a bayonet lock in the rim. The head has
 * two pieces. The panel is the bayonet pin and holds a rod seal for each end of the tube. The
 * former hangs from the panel and fills the middle of the coil, so the gas must pass over the coil
 * instead of bypassing it up the centre.
 *
 * The former is also the arbor the coil is wound on. A coil whose bottom end returns up through
 * its own centre cannot be removed from a one-piece mandrel, because unscrewing it would sweep the
 * ridge through the leg. So the coil is wound on the part it stays on, and the ridges that set the
 * pitch remain between the turns. The bends at each end are formed on a puck, separately from the
 * part: the bottom end before winding and the top end after. Both ends are laid into channels open
 * to the outside instead of being threaded through. The panel goes on last, lowered onto the two
 * ends once they are vertical and parallel. Coolant enters at the bottom end and leaves at the top,
 * so the coil runs full and air is pushed out at the top.
 *
 * Only the tubing holds water, so a porous print can leak gas but never coolant into the culture.
 * A quarter turn removes the head, former and coil together, and the shell is a plain tube that is
 * easy to clean.
 *
 *            in         out
 *             |          |
 *         ____|__________|_____
 *        |____|__________|_____|     panel: bayonet pin in the rim, sealing on its face ring
 *         |   |          \    |
 *         | o |           o   |===   outlet barb, just under the rim
 *         | o |           o   |
 *         | o |           o   |      coil turns (o) around the former; the bottom end
 *         | o |           o   |      returns up inside them to its seal
 *         | o |___________o   |
 *          \                 /       funnel
 *            \             /
 *              |         |           neck
 *            __|         |__
 *           |___         ___|        flange; z = 0 is the outer face of the lid
 *              |         |           the coupling, in the lid port
 *
 * The body prints standing on its rim, the panel on its flange, the former upright on its chuck
 * stub with the coil end at the top, and the pucks flat.
 */

use <../utils/facets.scad>
use <../utils/section.scad>
use <bayonet-port-scad/custom/bayonet_port.scad>
use <condenser_body.scad>
use <../purchased/aluminum_tubes.scad>
include <bayonet-port-scad/custom/bayonet_interfaces.scad>

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// What this file draws on its own: the assembly, or one printed part in its print orientation
part = "assembly"; // [assembly, body, panel, former, coil, puck_bottom, puck_top]
// Cut the assembly preview open to show the inside; ignored on a render
cross_section_active = true;
// Fraction the cut keeps: 0.5 keeps half, 0.75 removes a quarter
cross_section_keep = 0.5;

// example usage: the air_out port on the jar_10L lid, which is std, and a 3/16 in aluminum coil
_tube_od = aluminum_tube_od(aluminum_tube_by_name("3/16x0.028"));
if (part == "assembly")
  section(keep=cross_section_keep, size=400, active=cross_section_active && $preview)
    condenser_coil_assembly(bayonet_std, _tube_od, oring_4p5x1p5_epdm);
else
  condenser_coil_part(part, bayonet_std, _tube_od, oring_4p5x1p5_epdm);
condenser_coil_report(bayonet_std, _tube_od);

// Defaults for every module and helper below, defined once so the print, assembly and report
// helpers cannot drift from the parts they draw.
condenser_coil_bore = 12; // bore through the pin and neck (gas up, condensate down)
condenser_coil_neck = 30; // straight neck above the flange
condenser_coil_shell = 38; // inside diameter of the shell, slightly larger than the coil
condenser_coil_shell_length = 175; // straight shell up to the rim
condenser_coil_rim = 10; // rim thickness, which is the head panel
condenser_coil_former_radius = 13; // the coil is wound on this, so it is the coil inside radius
// Bend radius at the bottom end. Its leg runs up a groove in the former, so the leg must finish
// inside the former radius, and the bend radius sets the leg radius (see the assert).
condenser_coil_bend_radius = 9.5; // about twice the diameter of a 3/16 in tube
// Bend radius at the top end, which only has to reach a seal. The bend is gentler and the leg ends
// further out, as far out as the coupling core allows a seal to sit.
condenser_coil_top_bend_radius = 11.25;
condenser_coil_pitch = 11;
condenser_coil_turns = 12; // a whole number, so both ends leave at the same angle
condenser_coil_top_gap = 16; // coupling bottom to top turn centre, room for the top bends
condenser_coil_seat_allow = 0.2; // between a turn and the ridges that set its pitch
condenser_coil_channel_allow = 0.4; // between the tube and its channel in the former
condenser_coil_socket_depth = 6; // depth the former spigot enters the panel
// Funnel under each bore that guides in a slightly misaligned end. It must stay shallower than the
// lip that holds the o-ring captive in its gland, or the pocket opens at the bottom and the o-ring
// pushes out (see the assert). It also limits the spigot diameter, because the bottom-end bore is
// the closer of the two to the axis.
condenser_coil_bore_lead = 0.4;
condenser_coil_screw_clear = 1.7; // M3 clearance; the head countersinks into the coupling
condenser_coil_screw_pilot = 1.25; // pilot hole for the screw in the spigot
condenser_coil_screw_head = 3.0; // counterbore that buries an M3 cap head
condenser_coil_screw_head_depth = 3.5;
// Height of the screw above the bottom of the socket. The pocket must contain the whole head, so
// the head radius sets this: any lower and the counterbore breaks through the underside of the
// panel. The asserts keep it between that face and the top of the socket.
condenser_coil_screw_rise = 3.8;
// Bore of the outlet barb: the narrowest point in the exhaust path, so the gas line pressure drop
// is calculated at it.
condenser_coil_outlet_bore = 4.5;
function condenser_coil_outlet_bore() = condenser_coil_outlet_bore;

// ----- the coil -----

// Axial length of a coil with this many turns, from the centre of the lowest turn to the top one.
function condenser_coil_height(turns, pitch) = turns * pitch;

// Radius of the coil centreline, with the tube wound on the former.
function condenser_coil_radius(former_radius, tube_od) = former_radius + tube_od / 2;

// Position of the vertical leg at one end, in the frame where its turn leaves at angle 0. The tube
// continues along the tangent, turns inward through a quarter circle, then up through another.
// side is -1 for the bottom end, which leaves against the winding direction, and +1 for the top
// end, which leaves with it.
function condenser_coil_leg(former_radius, tube_od, bend_radius, side) =
  [condenser_coil_radius(former_radius, tube_od) - 2 * bend_radius, side * bend_radius];

// Tubing length for the coil: the turns, the two legs up to the head, and the four quarter bends.
function condenser_coil_tube_length(turns, coil_radius, pitch, legs, bend_radius) =
  turns * sqrt((2 * PI * coil_radius) ^ 2 + pitch ^ 2) + legs + 2 * PI * bend_radius;

// Captive lip of the rod seal, as bayonet_port cuts it. It is a local variable there, so it is
// derived from the gland centre function instead of being restated.
function condenser_coil_gland_lip(ring) = bayonet_bore_gland_centre(ring, 0) - bayonet_bore_gland_length(ring) / 2;

// Centre of the bottom turn, below the top face of the rim.
function condenser_coil_bottom_z(rim, top_gap, turns, pitch) = -rim - top_gap - condenser_coil_height(turns, pitch);

// ----- body -----

// Height of the rim top face (the head panel) above the lid.
function condenser_coil_rim_top_z(
  type, bore_diameter = condenser_coil_bore, neck_height = condenser_coil_neck,
  shell_inner_diameter = condenser_coil_shell, shell_length = condenser_coil_shell_length, rim = condenser_coil_rim
) = condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, shell_length) + rim;

/**
 * @param type                 Registered bayonet interface of the lid port
 * @param head_type            Registered bayonet interface the head locks with
 * @param bore_diameter        Bore through the pin and neck (gas up, condensate down)
 * @param neck_height          Straight neck above the flange
 * @param shell_inner_diameter Inside diameter of the shell, slightly larger than the coil so the
 *                             gas flows past it
 * @param shell_length         Straight shell up to the rim
 * @param wall                 Wall of the body
 * @param rim                  Rim thickness, which is the head panel
 * @param hose_inner_diameter  Inside diameter of the hose on the outlet barb
 * @param outlet_bore_diameter Bore of the outlet barb
 * @param outlet_drop          Distance of the outlet centre below the rim
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
  outlet_bore_diameter = condenser_coil_outlet_bore,
  outlet_drop = 14
) {
  _rs = shell_inner_diameter / 2;
  _z_shell = condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, shell_length);
  _hole_r = bayonet_port_hole_radius(head_type);
  _rim_r = max(bayonet_flange_radius(head_type), _hole_r + wall); // the head flange seats on it
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

      // Rim: the shell flares out at 45 degrees to carry the lock and seat the head flange
      translate([0, 0, _z_shell - _flare - 0.5])
        difference() {
          union() {
            cylinder(h=_flare + 0.5, r1=_rs + wall, r2=_rim_r);
            translate([0, 0, _flare + 0.5 - z_fight]) cylinder(h=rim + z_fight, r=_rim_r);
          }
          translate([0, 0, -1]) cylinder(h=_flare + rim + 3, r=_rs);
          // the lock hole, starting 0.5 above the rim face so the plain foot of the lock overlaps
          // the rim instead of resting on it face to face
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

// Path of one end, from where it leaves a turn to the top of its vertical leg: along the tangent,
// a quarter circle inward, a quarter circle up, then the leg. side is -1 for the bottom end, which
// leaves against the winding direction, and +1 for the top end, which leaves with it. The former
// channels are cut from the same points, so the tube and the channel cannot drift apart.
function condenser_coil_end_path(coil_radius, bend_radius, side, z_turn, z_leg_end, step = 5) =
  let (_r = bend_radius)
    concat(
      [for (f = [0:step:90]) [coil_radius - _r + _r * cos(f), side * _r * sin(f), z_turn]],
      [for (f = [step:step:90]) [coil_radius - _r - _r * sin(f), side * _r, z_turn + _r - _r * cos(f)]],
      [[coil_radius - 2 * _r, side * _r, z_leg_end]]
    );

/**
 * A channel along a path, open all the way out to out_radius. An end that was bent to shape while
 * the tube was straight is laid into it from the side. Nothing is threaded along it, because
 * threading is not possible once the coil is wound.
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
 * The top face is flat and sets the pitch: wind each turn by pushing it down onto the ridge below.
 * The underside is at 45 degrees, the steepest overhang a part printed upright can hold, and it
 * runs tangent to the turn below, so the channel fits as closely as an overhang allows. Each turn
 * is located from below and loose above. That clearance is the cost of printing the former
 * upright, and it is why the winding direction matters.
 */
function condenser_coil_ridge(former_radius, tube_od, pitch, seat = condenser_coil_seat_allow) =
  let (
    _rt = tube_od / 2,
    _root = former_radius - 0.5,
    _tip = former_radius + _rt,
    _over = sqrt(2) * (_rt + seat), // where a 45 degree tangent to the turn below meets the tip
    _top = pitch - (_rt + seat)
  )
    [[_root, _over - (_tip - _root)], [_tip, _over], [_tip, _top], [_root, _top]];

// Bottom face of the former, just below its lowest turn.
function condenser_coil_former_bottom_z(
  tube_od, rim = condenser_coil_rim, top_gap = condenser_coil_top_gap,
  turns = condenser_coil_turns, pitch = condenser_coil_pitch, chuck_length = 15
) = condenser_coil_bottom_z(rim, top_gap, turns, pitch) - tube_od / 2 - 1 - chuck_length;

// Screw height, used by both halves so they cannot drift apart.
function condenser_coil_screw_z(rim = condenser_coil_rim) = -rim + condenser_coil_screw_rise;

// Maximum radius of a seal in the coupling, which limits how far out the top end can reach.
function condenser_coil_seal_limit(head_type, ring) =
  bayonet_interface_radius(head_type) - bayonet_pin_radius(head_type) - bayonet_bore_gland_radius(ring) - 1;

/**
 * The former: the arbor the coil is wound on, and afterwards the plug that fills the middle so the
 * gas must pass over the coil instead of bypassing it up the centre. It stays in the reactor, so
 * the ridges that set the pitch stay between the turns and hold them in place. They do not restrict
 * the flow, because they sit in the dead space between the former and the coil, which the former
 * already blocks.
 *
 * It is wound standing on its chuck stub, which is below everything the coil touches. The bottom
 * end is bent to shape and laid into its channel first, and the turns are wound over it.
 *
 * @param tube_od        Outside diameter of the coolant tubing
 * @param former_radius  Inside radius of the coil, which is the radius of this part
 * @param bend_radius    Bend radius at the bottom end, which its channel follows
 * @param pitch          Rise per turn
 * @param turns          Number of turns, a whole number
 * @param rim            Rim thickness, which is the coupling length
 * @param top_gap        From the bottom of the coupling to the centre of the top turn
 * @param chuck_length   Length of the stub below the coil that a chuck grips while winding
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

    // Pilot hole for the screw from the panel. The two ends passing through the panel already set
    // the orientation of the former, so this aligns with the clearance hole without indexing.
    translate([0, 0, condenser_coil_screw_z(rim)])
      rotate([0, 90, 0]) cylinder(h=2 * _spigot_r + 2, r=condenser_coil_screw_pilot, center=true);

    // Hole for a tie through the stub that holds the starting tail while the first turn is wound
    translate([0, 0, _foot - chuck_length / 2]) rotate([90, 0, 0]) cylinder(h=4 * chuck_radius, d=3.2, center=true);
  }
}

// ----- the panel -----

function condenser_coil_spigot_radius(tube_od, bend_radius, former_radius = condenser_coil_former_radius) =
  norm(condenser_coil_leg(former_radius, tube_od, bend_radius, -1))
  - (tube_od / 2 + 0.2) - condenser_coil_bore_lead - 0.6;

/**
 * The panel in the rim datum: z = 0 is the top face of the rim. It has the bayonet pin, the two
 * rod seals, and a socket for the former spigot.
 *
 * It is a separate part so it can be lowered onto the two ends once they are vertical and parallel.
 * Nothing is threaded into a hole, which is not possible once the coil is in the way. The o-ring
 * glands stay as complete bores and are never split across a joint that coolant could leak through.
 *
 * @param head_type    Registered bayonet interface it locks with
 * @param rim          Rim thickness, which is the coupling length
 * @param tube_od      Outside diameter of the coolant tubing
 * @param ring         Registered o-ring sealing each tube end, ID at or below tube_od
 * @param bend_radius  Bend radius at the bottom end, which sets the position of its leg and seal
 * @param top_bend_radius  Bend radius at the top end, which reaches further out
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
  _screw_z = condenser_coil_screw_z(rim);

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
    condenser_coil_screw_rise - condenser_coil_screw_head >= 0.6,
    str(
      "condenser_coil_panel: the screw's counterbore reaches ",
      condenser_coil_screw_head - condenser_coil_screw_rise, " mm past the panel's underside, so it",
      " opens through the face instead of burying the head"
    )
  );
  assert(
    condenser_coil_screw_rise + condenser_coil_screw_clear <= condenser_coil_socket_depth,
    str(
      "condenser_coil_panel: the screw at ", condenser_coil_screw_rise,
      " mm up runs out of the top of a ", condenser_coil_socket_depth, " mm socket, so it misses the spigot"
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

    // Socket for the former spigot, and the screw that holds it. The screw enters from outside at
    // the height where the coupling face is widest, so the countersink has a known surface to sit
    // in and the head ends up below that surface. The body bore has only 2.5 mm clearance, so a
    // proud head would catch on the way in. The screw crosses the wall, the socket and the spigot,
    // and stops in a blind relief instead of breaking out the far side.
    translate([0, 0, -rim - z_fight]) cylinder(h=condenser_coil_socket_depth + z_fight, r=_spigot_r + 0.25);
    translate([0, 0, _screw_z]) rotate([0, 90, 0]) let ($fn = facet_count(condenser_coil_screw_head)) {
      translate([0, 0, _spigot_r]) cylinder(h=_face_r - _spigot_r + 1, r=condenser_coil_screw_clear);
      // A counterbore, not a countersink: the face it sits on is a cylinder, so the head needs a
      // flat seat, and a bounded pocket cannot run on and cut into the flange the way a cone does.
      translate([0, 0, _face_r - condenser_coil_screw_head_depth])
        cylinder(h=condenser_coil_screw_head_depth + 1, r=condenser_coil_screw_head);
      // blind relief for the screw tip, on the far side
      translate([0, 0, -_spigot_r - 1.5]) cylinder(h=1.5 + z_fight, r=condenser_coil_screw_pilot + 0.2);
    }

    // The tube ends: a funnel that guides the tube into the bore, the bore, and the rod seal near
    // the bottom of the coupling. All three use the fragment count of the gland, the widest of
    // them, so their facets line up instead of crossing where one meets the next.
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
 * The bending puck, lying flat: a disc with a rim groove whose radius at the tube centre is the
 * bend radius, and a straight lead-in that holds the tube square while it is pulled around. Each
 * end gets two quarter bends around it, the first inward and the second up. The two ends bend at
 * different radii, so each has its own puck.
 *
 * The groove is a V that opens outward. It must be deep enough to take the tube up to its centre,
 * or the tube rides up and the radius comes out wrong. A 90 degree V holds a tube with its centre
 * sqrt(2) x its radius above the apex, and the mouth must be at least that much wider again.
 */
module condenser_coil_puck(tube_od, bend_radius = condenser_coil_bend_radius, lead = 30) {
  _rt = tube_od / 2;
  _v = sqrt(2) * _rt; // a 90 degree V holds a tube with its centre this far above the apex
  _apex_r = bend_radius - _v; // so the tube centre lands on bend_radius, not short of it
  _disc_r = bend_radius + 0.5; // rim just past the tube centre, so the V holds it
  _reach = _disc_r - _apex_r + 1; // flanks extend past the rim, so the mouth is never pinched
  _h = 2 * (_reach + 2); // enough material above and below the V that the tool is not two slabs
  _vee = [[0, 0], [_reach, _reach], [_reach, -_reach]];

  difference() {
    union() {
      cylinder(h=_h, r=_disc_r);
      translate([0, -_disc_r, 0]) cube([lead, 2 * _disc_r, _h]);
    }
    // Around the rim, over the free half the tube is pulled around
    translate([0, 0, _h / 2])
      rotate([0, 0, 90])
        rotate_extrude(angle=180) translate([_apex_r, 0]) polygon(_vee);
    // and continuing along the lead-in, which holds the tube square while it is pulled
    translate([0, 0, _h / 2])
      rotate([0, 90, 0])
        linear_extrude(height=3 * lead, center=true)
          polygon([[0, -_apex_r], [-_reach, -_apex_r - _reach], [_reach, -_apex_r - _reach]]);
  }
}

// ----- assembly -----

// Tube along a chain of points, for the preview and the clash check.
module condenser_coil_chain(pts, tube_od) {
  for (i = [0:len(pts) - 2])
    hull() {
      translate(pts[i]) sphere(d=tube_od);
      translate(pts[i + 1]) sphere(d=tube_od);
    }
}

// The formed coil: the turns, and at each end the inward and upward quarter bends to a vertical
// leg ending at z_ends. The two ends bend at different radii: the bottom end must finish inside
// the coil, and the top end only has to reach its seal.
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

// Body, head and tubing as assembled, in the lid datum.
// One part in its print orientation, or the formed tube in the head datum (rim top face at
// z = 0), which is purchased, not printed.
module condenser_coil_part(part, type, tube_od, ring, head_type = bayonet_xl) {
  if (part == "body")
    translate([0, 0, condenser_coil_rim_top_z(type)]) rotate([180, 0, 0]) condenser_coil_body(type, head_type);
  else if (part == "panel")
    translate([0, 0, bayonet_flange_height(head_type)]) rotate([180, 0, 0])
      condenser_coil_panel(head_type, tube_od=tube_od, ring=ring);
  else if (part == "former")
    // standing on its foot, the orientation for both winding and printing
    translate([0, 0, -condenser_coil_former_bottom_z(tube_od)]) condenser_coil_former(tube_od);
  else if (part == "coil")
    condenser_coil_tubing(
      condenser_coil_former_radius, tube_od, condenser_coil_pitch, condenser_coil_turns,
      -condenser_coil_rim - condenser_coil_top_gap, bayonet_flange_height(head_type) + 15
    );
  else if (part == "puck_bottom")
    condenser_coil_puck(tube_od, condenser_coil_bend_radius);
  else if (part == "puck_top")
    condenser_coil_puck(tube_od, condenser_coil_top_bend_radius);
  else
    assert(false, str("condenser_coil_part: no part \"", part, "\""));
}

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

// Reports the coil geometry and the tubing to buy.
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
