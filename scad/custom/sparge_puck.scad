/**
 * @file sparge_puck.scad
 * @brief A bench sparger: one printed outlet face over a plenum, to measure what a face costs and
 *        what it makes before any sparger in the reactor changes.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The reactor's sparger has one number nothing in this model can supply: what its outlet face
 * costs at a flow. Drilled holes are priced from the orifice equation and Tate's law; a printed
 * porous face is priced by nothing, and the one published printed membrane (Palfy et al. 2021)
 * gives a single point. This part exists to be printed several times, one outlet per print, and
 * put on the bench, so that number is measured rather than borrowed.
 *
 * The outlet face prints on the bed, where the first layers are flattest, and points DOWN in the
 * water, as the arm's holes do. The plenum's roof is a 45 deg cone, so nothing bridges.
 *
 * DATUM: z = 0 is the outlet face, +z up to the inlet.
 */

use <../utils/stirred_tank.scad>;
use <../utils/gas_supply.scad>;
use <sparger.scad>;
include <../purchased/steel_tubes.scad>;
include <../purchased/set_screws.scad>;
include <../purchased/air_pumps.scad>;

$fn = $preview ? 48 : 96;
// How far each cut runs past the face it opens through, in the render as in the preview: two cuts
// that meet exactly share a face, and the renderer keeps it as coincident triangles.
puck_eps = 0.01;

/* [Outlet] */

// What lets the gas out: drilled holes, or a solid face sliced to leak
outlet = "holes"; // [holes, porous]
// Hole diameter, in mm: the drill each hole is finished with after printing
hole_diameter = 3;
// How many holes; 0 takes the most that keeps every hole flowing at bench_flow (see puck_hole_count())
hole_count = 0;
// How far one finished hole may differ from the next, in mm. Reasoned, not cited: measure it
hole_scatter = 0.1;
// How many times the drop through a hole has to exceed what that scatter moves the launch
// pressure by, for every hole to flow. Reasoned, not cited
even_flow_margin = 4;
// Thickness of a drilled face, in mm
hole_face_thickness = 1;
// Layers in a porous face; Palfy et al. printed three
porous_layers = 3;
// Layer height the porous face is sliced at, in mm; Palfy et al. used 0.2
porous_layer_height = 0.2;
// Diameter of a porous face, in mm; 52.8 is the circle of Palfy's 46.8 mm square, 2190 mm2
porous_diameter = 52.8;
// Radial ribs under a porous face, standing in for the honeycomb Palfy's membrane printed on
porous_ribs = 8;

/* [Inlet] */

// What feeds it: the 4 mm steel riser into a socket, or a soft tube over a barb
inlet = "socket"; // [socket, barb]
// Inside diameter of the soft tube a barb takes, in mm; 4.7625 is the 3/16 in silicone the gas
// line runs after the rotameter (docs/build.md)
barb_tube_id = 4.7625;
// How far a barb's crest stretches that tube, as a fraction of its bore. Reasoned, not cited
barb_stretch = 0.15;
// Ridges on the barb
barb_ridges = 3;

/* [Duty] */

// The flow the bench runs at, in L/min; jar_10L's 0.5 vvm is 4.08517 (head.scad's report)
bench_flow = 4;
// Water over the outlet face, in mm; jar_10L's arm sits under 186.503 (head.scad's report)
bench_depth = 190;

/* [Hidden] */

// Emit the breakthrough probes check-holes tests. Off for a normal render.
sparge_hole_probes = false;

// The riser, the screw that grips it and the socket's fit are sparger.scad's, the ones the lid's
// spargers are bored to, so printing this is how the lid's socket gets bench-checked.
puck_riser = sparger_riser();
puck_set_screw = sparger_screw();
puck_socket_allow = sparger_socket_allow();
puck_socket_depth = sparger_socket_depth();
puck_socket_chamfer = sparger_socket_chamfer();
// The pump the bench is fed from: what it still pushes at the bench's flow is what a face may cost.
puck_pump = air_pump_resun_35w;

// Wall everywhere a printed boundary holds pressure, in mm: five 0.4 mm lines.
puck_wall = 2;
// Height of the plenum's straight side under the cone, in mm. Palfy's chamber was 3.6.
puck_plenum_height = 3;
// Clearance from a hole's edge to the plenum wall, in mm
puck_plenum_margin = 1.5;
// Wall round the socket that the set screw runs through, as the arm's boss
puck_boss_wall = sparger_boss_wall();
// Thinnest wall a barb's bore may leave under its shank, in mm: two 0.4 mm lines
puck_barb_min_wall = 0.8;
// Length of one barb ridge, in mm
puck_barb_ridge = 3;
// Solid PETG, kg/m^3; infill only makes a print lighter
puck_petg_density = 1270;

// ----- Palfy et al. 2021, the one printed membrane with a measured point -----
//
// HardwareX 9:e00192, Table 2: 14.7 L/h through a 46.8 x 46.8 mm membrane at 0.2 bar, with 50
// entry points, all within 838 mm2 of it. The paper does not say where the 0.2 bar was read, so
// it is taken as the whole cost of the face. One point, so scaling it is linear by assumption.
function palfy_flow() = 14.7 / 60; // L/min
function palfy_pressure() = 20000; // Pa
function palfy_area() = 2190; // mm2, the membrane

// Borrowed: Palfy's cost per unit flow per unit area, carried to another flow and area, Pa.
function puck_porous_pressure(flow, area) =
  palfy_pressure() * (flow / palfy_flow()) * (palfy_area() / area);

// ----- what the holes have to do -----
//
// A hole launches a bubble only once the plenum beats its capillary pressure, 4 sigma / d, and a
// smaller hole asks more. So among holes that differ by `scatter`, the largest opens first and
// takes the gas, unless the drop through each hole outweighs that difference: then a hole that
// opened early runs faster, costs more, and pushes the plenum up until the rest open too.

// What a scatter in hole size moves the launch pressure by, Pa.
function puck_capillary_spread(d, scatter) =
  stirred_tank_capillary_pressure(d) - stirred_tank_capillary_pressure(d + scatter);

// The most holes that keep the drop through each at margin times that spread: fewer holes, more
// drop each. At least one.
function puck_hole_count(flow, d, scatter, margin) =
  let (_area = stirred_tank_orifice_area(flow / 60000, margin * puck_capillary_spread(d, scatter)))
    max(1, floor(_area / (PI / 4 * pow(d / 1000, 2))));

function puck_holes(count, flow, d, scatter, margin) =
  count > 0 ? count : puck_hole_count(flow, d, scatter, margin);

// Holes on one circle, so every hole is the same distance from the feed, at the pitch floor
// centre to centre. One hole sits on the axis.
function puck_pitch(d) = sparger_pitch_ratio_floor() * d;
function puck_hole_circle(count, d) = count == 1 ? 0 : puck_pitch(d) / (2 * sin(180 / count));
function puck_hole_positions(count, d) =
  let (_r = puck_hole_circle(count, d))
    [for (j = [0:count - 1]) [_r * cos(360 * j / count), _r * sin(360 * j / count)]];

// ----- the part's section, named once -----

function puck_feed_bore() = steel_tube_id(puck_riser); // the riser's own bore, either inlet
function puck_face_thickness(kind) = kind == "porous" ? porous_layers * porous_layer_height : hole_face_thickness;
function puck_plenum_radius(kind, count, d) =
  kind == "porous" ? porous_diameter / 2 : max(puck_hole_circle(count, d) + d / 2 + puck_plenum_margin, puck_feed_bore());
function puck_socket_bore() = steel_tube_od(puck_riser) + puck_socket_allow;
function puck_boss_radius(kind) =
  kind == "socket" ? puck_socket_bore() / 2 + puck_boss_wall : barb_tube_id / 2 + puck_wall;
// Where the cone meets the plenum's side.
function puck_cone_base(kind) = puck_face_thickness(kind) + puck_plenum_height;
// Where the cone's inside reaches the feed bore.
function puck_cone_top(kind, count, d) =
  puck_cone_base(kind) + puck_plenum_radius(kind, count, d) - puck_feed_bore() / 2;
// Height of the boss above the cone's inside apex: the socket's depth plus a floor under it, or a
// collar the tube end butts on.
function puck_boss_height(kind) = kind == "socket" ? puck_socket_depth + puck_wall : puck_wall;
function puck_barb_crest() = barb_tube_id * (1 + barb_stretch);
function puck_barb_length() = barb_ridges * puck_barb_ridge;

// The outside, as an (r, z) polygon: the face, the side, the cone offset a wall above the plenum's,
// the boss, and on a barb the ridges, each widening downward so the tube catches on its shoulder.
// The inside is the plenum: the face's top, the side, the cone to the feed bore.
function puck_outer_profile(outlet_kind, inlet_kind, count, d) =
  let (
    _rp = puck_plenum_radius(outlet_kind, count, d),
    _rb = puck_boss_radius(inlet_kind),
    _R = max(_rp + puck_wall, _rb), // a boss wider than a small plenum's wall takes the side
    _zc = puck_cone_base(outlet_kind),
    _lift = puck_wall * sqrt(2), // the outer cone, a wall clear of the inner one along its normal
    _zb = max(_zc + _rp - _rb + _lift, _zc + _lift - puck_wall),
    _top = puck_cone_top(outlet_kind, count, d) + puck_boss_height(inlet_kind),
    _barb = inlet_kind != "barb" ? [] : [
      for (k = [0:barb_ridges - 1])
        each [[puck_barb_crest() / 2, _top + k * puck_barb_ridge], [barb_tube_id / 2, _top + (k + 1) * puck_barb_ridge]]
    ],
    _end = inlet_kind == "barb" ? _top + puck_barb_length() : _top
  )
    concat([[0, 0], [_R, 0], [_R, _zc + _lift - puck_wall], [_rb, _zb], [_rb, _top]], _barb, [[0, _end]]);

function puck_plenum_profile(outlet_kind, count, d) =
  let (
    _rp = puck_plenum_radius(outlet_kind, count, d),
    _t = puck_face_thickness(outlet_kind),
    _zc = puck_cone_base(outlet_kind)
  )
    [[0, _t], [_rp, _t], [_rp, _zc], [puck_feed_bore() / 2, puck_cone_top(outlet_kind, count, d)], [0, puck_cone_top(outlet_kind, count, d)]];

// Volume of an (r, z) polygon swept about the axis, mm3: Pappus, from its first moment about z.
function puck_swept_volume(p) =
  let (_n = len(p))
    abs(2 * PI / 6 * sparger_sum([
      for (i = [0:_n - 1])
        let (a = p[i], b = p[(i + 1) % _n])
          (a[0] + b[0]) * (a[0] * b[1] - b[0] * a[1])
    ]));

// ----- the part -----

module sparge_puck(outlet_kind = outlet, inlet_kind = inlet, count, d = hole_diameter) {
  _t = puck_face_thickness(outlet_kind);
  _apex = puck_cone_top(outlet_kind, count, d);
  _top = _apex + puck_boss_height(inlet_kind);
  _end = inlet_kind == "barb" ? _top + puck_barb_length() : _top;
  _rp = puck_plenum_radius(outlet_kind, count, d);

  assert(outlet_kind == "holes" || outlet_kind == "porous", str("sparge_puck: no outlet called \"", outlet_kind, "\""));
  assert(inlet_kind == "socket" || inlet_kind == "barb", str("sparge_puck: no inlet called \"", inlet_kind, "\""));
  assert(
    inlet_kind == "socket" || (barb_tube_id - puck_feed_bore()) / 2 >= puck_barb_min_wall,
    str(
      "sparge_puck: a ", barb_tube_id, " mm barb shank round a ", puck_feed_bore(), " mm bore leaves ",
      (barb_tube_id - puck_feed_bore()) / 2, " mm of wall, under ", puck_barb_min_wall
    )
  );
  // The pilot runs from the boss's outside to the socket; it has to land inside the socket's depth.
  assert(
    inlet_kind == "barb" || set_screw_diameter(puck_set_screw) < puck_socket_depth,
    str("sparge_puck: an M", set_screw_diameter(puck_set_screw), " screw does not fit a ", puck_socket_depth, " mm socket")
  );

  difference() {
    rotate_extrude(convexity = 4) polygon(puck_outer_profile(outlet_kind, inlet_kind, count, d));

    // the plenum, and the feed bore up from its apex
    difference() {
      rotate_extrude(convexity = 4) polygon(puck_plenum_profile(outlet_kind, count, d));
      if (outlet_kind == "porous" && porous_ribs > 0)
        for (k = [0:porous_ribs - 1])
          rotate([0, 0, 360 * k / porous_ribs])
            // from clear of the feed out to the wall, so gas reaches every sector from the middle
            translate([puck_feed_bore(), -puck_wall / 4, _t - puck_eps])
              cube([_rp - puck_feed_bore() + puck_eps, puck_wall / 2, puck_plenum_height + 2 * puck_eps]); // past the cone's corner
    }
    // up to the socket's floor, or out through the barb's end
    translate([0, 0, _apex - puck_eps])
      cylinder(h = (inlet_kind == "socket" ? _top - puck_socket_depth : _end) - _apex + 2 * puck_eps, d = puck_feed_bore());

    if (outlet_kind == "holes")
      for (p = puck_hole_positions(count, d))
        translate([p[0], p[1], -puck_eps])
          cylinder(h = _t + 2 * puck_eps, d = d);

    if (inlet_kind == "socket") {
      translate([0, 0, _top - puck_socket_depth])
        cylinder(h = puck_socket_depth + puck_eps, d = puck_socket_bore());
      translate([0, 0, _top - puck_socket_chamfer])
        cylinder(h = puck_socket_chamfer + puck_eps, d1 = puck_socket_bore(), d2 = puck_socket_bore() + 2 * puck_socket_chamfer);
      // the set screw's pilot, radial at mid depth, to self-tap and grip the riser
      translate([0, 0, _top - puck_socket_depth / 2])
        rotate([-90, 0, 0])
          cylinder(h = puck_boss_radius(inlet_kind) + puck_eps, r = set_screw_tap_radius(puck_set_screw));
    }
  }
}

// For check-holes: per hole, a point at each end of the hole, just inside the outlet face and just
// under the plenum's floor. A point in the plenum itself is void whether the hole reaches it or
// not, so it cannot fail; these two are void only if the hole runs the face's whole thickness.
module sparge_puck_hole_probes(count, d, margin = 0.05) {
  for (p = puck_hole_positions(count, d)) {
    echo(str("HOLEPROBE|exit|", p[0], "|", p[1], "|", margin));
    echo(str("HOLEPROBE|feed|", p[0], "|", p[1], "|", hole_face_thickness - margin));
  }
}

// ----- what it does to the gas, from the same arguments -----

module sparge_puck_report(outlet_kind, inlet_kind, count, d, flow, depth) {
  _q = flow / 60000;
  _head = stirred_tank_medium_density() * 9.81 * depth / 1000;
  _bore_v = stirred_tank_sparge_bore_velocity(_q, puck_feed_bore(), 1);
  // the pump's curve at this flow, from the conservative end of its free-flow band
  _avail = gas_pump_back_pressure_for(air_pump_free_flow_min(puck_pump), air_pump_dead_head(puck_pump), flow);
  // The swept profiles leave out the feed bore, which is air, and the ribs, which are plastic
  // standing in the plenum. The holes are left out: a few cubic millimetres of water.
  _bore = PI / 4 * pow(puck_feed_bore(), 2)
    * (inlet_kind == "socket" ? puck_boss_height(inlet_kind) - puck_socket_depth : puck_boss_height(inlet_kind) + puck_barb_length());
  _ribs = outlet_kind != "porous" ? 0
    : porous_ribs * (puck_wall / 2) * (puck_plenum_radius(outlet_kind, count, d) - puck_feed_bore()) * puck_plenum_height;
  _solid = puck_swept_volume(puck_outer_profile(outlet_kind, inlet_kind, count, d))
    - puck_swept_volume(puck_plenum_profile(outlet_kind, count, d)) - _bore + _ribs;
  _air = puck_swept_volume(puck_plenum_profile(outlet_kind, count, d)) + _bore - _ribs;

  if (outlet_kind == "holes") {
    _v = stirred_tank_orifice_velocity(_q, count, d);
    _drop = stirred_tank_orifice_pressure(_v);
    _cap = stirred_tank_capillary_pressure(d);
    _spread = puck_capillary_spread(d, hole_scatter);
    _db = stirred_tank_bubble_diameter(d);
    _open = stirred_tank_sparge_open_area_ratio(count, d, puck_feed_bore(), 1);
    _dep = sparger_departures(_v, puck_pitch(d) / d, _open, stirred_tank_sparge_bore_head(_bore_v), _drop);
    echo(str(
      "sparge puck: ", count, " holes of ", d, " mm", count > 1 ? str(" on a ", 2 * puck_hole_circle(count, d), " mm circle") : " on the axis",
      ", ", _v, " m/s each at ", flow, " L/min; ", _drop, " Pa through a hole, ", _drop / _spread,
      "x the ", _spread, " Pa a ", hole_scatter, " mm scatter moves the ", _cap, " Pa launch pressure by (want ", even_flow_margin, ")"
    ));
    echo(str(
      "sparge puck bubbles: ", _db, " mm at formation by Tate's law, a floor; ",
      stirred_tank_bubble_rate(_q, _db), " a second. Finish each hole with a ", d, " mm drill"
    ));
    // 4 sigma / d is the peak each bubble passes through as it launches, not a mean, so a damped
    // gauge reads between the drop alone and the drop with it.
    echo(str(
      "sparge puck gauge: under ", depth, " mm of water the plenum reads ", _head + _drop, " to ", _head + _cap + _drop,
      " Pa: ", _head, " of water, ", _drop, " through the hole, and up to ", _cap, " at each bubble's launch; what it reads over ",
      _head, " is the face's cost, once the feed's own loss at this flow is taken off"
    ));
    if (len(_dep) > 0)
      echo(str("WARNING sparge puck: extrapolated on ", _dep));
    if (_drop / _spread < even_flow_margin)
      echo(str("WARNING sparge puck: ", count, " holes leave ", _drop / _spread, "x the scatter's spread, under ", even_flow_margin, ", so expect the largest holes to take the gas"));
  } else {
    // the ribs stand on the face, so what they cover does not leak
    _ribbed = porous_ribs * (puck_wall / 2) * (porous_diameter / 2 - puck_feed_bore());
    _area = PI / 4 * pow(porous_diameter, 2) - _ribbed;
    _p = puck_porous_pressure(flow, _area);
    echo(str(
      "sparge puck: a ", puck_face_thickness(outlet_kind), " mm porous face, ", porous_layers, " layers of ",
      porous_layer_height, " mm, ", _area, " mm2 open between ", porous_ribs, " ribs that cover ", _ribbed, " mm2. Palfy's one point carried linearly to ",
      flow, " L/min and this area costs ", _p, " Pa (borrowed, one point, linear by assumption) against the ",
      _avail, " Pa ", air_pump_name(puck_pump), " still pushes at that flow"
    ));
    echo(str(
      "sparge puck gauge: under ", depth, " mm of water what the plenum reads over ", _head,
      " Pa is the face's cost; read it at three flows, since one point cannot say whether the face is linear"
    ));
    // Where the face's line, linear in flow, crosses the pump's falling one over the water's head.
    _k = puck_porous_pressure(1, _area); // Pa per L/min
    _ff = air_pump_free_flow_min(puck_pump);
    _dh = air_pump_dead_head(puck_pump);
    _passes = (_dh - _head) / (_k + _dh / _ff);
    if (_p + _head >= _avail)
      echo(str(
        "WARNING sparge puck: borrowed, ", _p + _head, " Pa of face and water is past the ", _avail,
        " Pa the pump pushes there, so ", flow, " L/min would not pass; flat out the pump would push ", _passes,
        " L/min through it, and the open area that would pass ", flow, " is ", puck_porous_area_for(flow, _avail - _head), " mm2"
      ));
  }

  echo(str(
    "sparge puck feed: ", puck_feed_bore(), " mm bore carrying ", _bore_v, " m/s, ",
    stirred_tank_sparge_bore_head(_bore_v), " Pa of velocity head; ",
    inlet_kind == "socket"
      ? str(
          puck_socket_bore(), " mm socket, ", puck_socket_allow, " mm over the ", steel_tube_od(puck_riser),
          " mm riser, ", puck_socket_depth, " mm deep, gripped by one ", set_screw_name(puck_set_screw),
          " (", set_screw_part_number(puck_set_screw), ")"
        )
      : str(barb_ridges, " ridges cresting at ", puck_barb_crest(), " mm in a ", barb_tube_id, " mm tube")
  ));

  // A socket hangs from the riser; a barb hangs from a soft tube, which cannot hold it down.
  _net = (_solid * puck_petg_density - (_solid + _air) * stirred_tank_medium_density()) * 1e-6; // g, + sinks
  if (inlet_kind == "barb")
    echo(str(
      _net >= 0 ? "" : "WARNING ",
      "sparge puck buoyancy: ", _solid, " mm3 of solid PETG round ", _air, " mm3 of air ",
      _net >= 0 ? str("sinks by ", _net, " g, as solid; infill makes it lighter, so weigh a print")
                : str("floats by ", -_net, " g even as solid; tie on more than that to keep it down")
    ));
}

// The area a porous face needs for a flow at a pressure, mm2: Palfy's point turned round.
function puck_porous_area_for(flow, pressure) = palfy_area() * (palfy_pressure() / pressure) * (flow / palfy_flow());

// ----- the part, as set above -----

// What cannot be built at all, before anything divides by it.
assert(
  hole_count >= 0 && hole_count == floor(hole_count),
  str("sparge_puck: hole_count is ", hole_count, "; a whole number of holes, or 0 for the most that all flow")
);
assert(
  outlet != "holes" || hole_scatter > 0 && even_flow_margin > 0,
  str("sparge_puck: no hole count follows from a ", hole_scatter, " mm scatter and a margin of ", even_flow_margin, "; both are over 0")
);
// the ribs run out from the feed bore, so the face has to reach past it
assert(
  outlet != "porous" || porous_diameter / 2 > puck_feed_bore(),
  str("sparge_puck: a ", porous_diameter, " mm porous face does not reach past the ", puck_feed_bore(), " mm the ribs start at")
);

_count =puck_holes(hole_count, bench_flow, hole_diameter, hole_scatter, even_flow_margin);
sparge_puck(outlet, inlet, _count, hole_diameter);
if (sparge_hole_probes && outlet == "holes")
  sparge_puck_hole_probes(_count, hole_diameter);
sparge_puck_report(outlet, inlet, _count, hole_diameter, bench_flow, bench_depth);
