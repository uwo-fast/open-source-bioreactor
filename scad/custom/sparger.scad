/**
 * @file sparger.scad
 * @brief Tube-based gas sparger: one ring, concentric rings, or a spider, from one module.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A TUBE, so it can be cleaned: round bore, open ends, and a split opposite the feed so a pipe
 * cleaner goes through each half. The section is a polygon outside (prints flat, holes drilled
 * square to a flat) and a circle inside (a brush turns, a screw self-taps). No thread is modelled:
 * the end plugs are set screws in a pilot at their tap radius.
 *
 * The functions in the first half take a duty - a gas rate, an annulus to cover - and return
 * radii and hole counts; the module takes those as arguments and knows nothing of where they came
 * from. What gas does inside the vessel (bubble size, plenum behaviour) is utils/stirred_tank.scad.
 */

use <../utils/stirred_tank.scad>;

// The end plug is one number, the radius a screw self-taps into, and the caller resolves the screw.

z_fight = $preview ? 0.05 : 0;
$fn = $preview ? 48 : 96;

// ----- layout: what the duty asks for -----
//
// Pure functions. A multi-ring sparger spreads gas evenly over the cross section - equal flow per
// unit of plan area - and an annulus grows with radius, so an outer ring serves more and carries more.

// Band edges, count+1 of them, cutting the sparged annulus into equal AREAS.
function sparger_band_edges(count, r_outer, r_inner = 0) =
  [for (k = [0:count]) sqrt(pow(r_inner, 2) + (k / count) * (pow(r_outer, 2) - pow(r_inner, 2)))];

// The area-median radius of each band, where its ring goes.
function sparger_equal_area_radii(count, r_outer, r_inner = 0) =
  let (_e = sparger_band_edges(count, r_outer, r_inner))
    [for (k = [0:count - 1]) sqrt((pow(_e[k], 2) + pow(_e[k + 1], 2)) / 2)];

// Sums a list.
function sparger_sum(v, i = 0) = i >= len(v) ? 0 : v[i] + sparger_sum(v, i + 1);

// What fraction of the gas each ring should carry: each serves out to the area-midpoint between
// it and its neighbours, so a hand-placed set of radii still gets an honest split.
function sparger_area_shares(radii, r_outer, r_inner = 0) =
  let (
    _n = len(radii),
    _mid = [
      for (k = [0:_n])
        k == 0 ? r_inner
        : k == _n ? r_outer
        : sqrt((pow(radii[k - 1], 2) + pow(radii[k], 2)) / 2)
    ],
    _a = [for (k = [0:_n - 1]) pow(_mid[k + 1], 2) - pow(_mid[k], 2)]
  )
    [for (v = _a) v / sparger_sum(_a)];

// How many holes the duty asks for at a chosen orifice velocity (Barbosa ran 0.4-5.4 m/s).
function sparger_hole_count_for_velocity(gas_flow, hole_diameter, velocity) =
  gas_flow / (velocity * PI / 4 * pow(hole_diameter / 1000, 2));

// Split a total across rings by their share, never below one per ring.
function sparger_holes_per_ring(total, shares) = [for (f = shares) max(1, round(total * f))];

// Centre-to-centre along a ring, and the same in hole diameters: holes closer than a few diameters
// coalesce as they form.
function sparger_ring_pitch(radius, count) = 2 * PI * radius / count;
function sparger_pitch_ratio(radius, count, hole_diameter) =
  sparger_ring_pitch(radius, count) / hole_diameter;
function sparger_pitch_ratio_floor() = 3;

// Where the holes sit on a ring, half a pitch off the feed. Shared by the cut, the split assert
// and the breakthrough probe.
function sparger_hole_angles(count, feed_angle = 0) =
  [for (j = [0:count - 1]) feed_angle + 180 / count + j * 360 / count];

// The radius of a ring's inner face, faceted twice: the section reaches across corners, and the
// sweep chords between vertices. What an inward hole has to get past.
function sparger_inner_face_radius(ring_radius, tube, section_facets, sweep_facets) =
  (ring_radius - sparger_face_distance(tube, section_facets, 180)) * cos(180 / sweep_facets);

// How many facets rotate_extrude will use, derived the way OpenSCAD derives it.
function sparger_sweep_facets(outer_radius, tube, section_facets) =
  $fn > 0
    ? max($fn, 3)
    : ceil(max(
        min(360 / $fa, (outer_radius + sparger_across_corners(tube, section_facets) / 2) * 2 * PI / $fs),
        5
      ));

// [innermost, outermost] radius the tubes occupy, across corners, where the material actually is.
function sparger_tube_envelope(radii, tube_diameter, facets = 8) =
  let (_ac = sparger_across_corners(tube_diameter, facets))
    [min(radii) - _ac / 2, max(radii) + _ac / 2];

// What this sparger violates, by name.
function sparger_departures(orifice_velocity, pitch_ratio, open_area_ratio, bore_head, orifice_drop) =
  [
    if (!stirred_tank_in_band(orifice_velocity, [0.4, 5.4])) "orifice velocity",
    if (pitch_ratio < sparger_pitch_ratio_floor()) "hole pitch",
    if (open_area_ratio >= 1) "open area",
    if (bore_head >= 0.5 * orifice_drop) "bore velocity",
  ];

// ----- the tube's section -----
//
// Quoted across flats, so the wall does not move with the facet count.
function sparger_across_corners(across_flats, facets) = across_flats / cos(180 / facets);

// Top face of a socket: feed_height above the elbow's top for the feed, above the section's
// across-corners half width for a support.
function sparger_socket_top(tube, facets, feed_height, kind, bend_radius = undef) =
  (kind == "feed" ? (is_undef(bend_radius) ? 1.5 * tube : bend_radius)
                  : sparger_across_corners(tube, facets) / 2)
  + feed_height;

// How far to turn the section so a flat lands on the bed: 270 degrees in the section's frame is an
// edge midpoint. A multiple of four facets gets flats on all four cardinals, so the holes get one.
function sparger_section_rotation(facets) =
  facets == 0
    ? 0
    : let (_p = 360 / facets, _r = 270 - 180 / facets) _r - floor(_r / _p) * _p;

// How far the material reaches in a given direction: a corner reaches across_corners/2 and a flat
// across_flats/2. A breakthrough probe placed at the wrong one sits outside the part and cannot fail.
function sparger_face_distance(across_flats, facets, direction) =
  facets == 0
    ? across_flats / 2
    : let (
        _p = 360 / facets,
        _normal = sparger_section_rotation(facets) + 180 / facets,
        _raw = direction - _normal,
        _off = _raw - floor(_raw / _p) * _p, // into [0, _p)
        _d = _off > _p / 2 ? _off - _p : _off // ... and then to the nearest flat
      )
        (across_flats / 2) / cos(_d);

// The 2D section, centred. facets = 0 asks for a circle, which is what the bore wants.
module sparger_section(across_flats, facets) {
  if (facets == 0) circle(d = across_flats);
  else
    rotate(sparger_section_rotation(facets))
      circle(d = sparger_across_corners(across_flats, facets), $fn = facets);
}

// ----- primitives -----

// A ring, swept about the axis.
module sparger_ring_solid(radius, across_flats, facets) {
  rotate_extrude(convexity = 6)
    translate([radius, 0])
      sparger_section(across_flats, facets);
}

// A straight run from r0 to r1 at a bearing, as a prism so its section matches the ring's. The
// quarter turn puts the same flat underneath the spoke as under the ring.
module sparger_spoke_solid(r0, r1, angle, across_flats, facets) {
  rotate([0, 0, angle])
    translate([r0, 0, 0])
      rotate([0, 90, 0])
        linear_extrude(height = max(r1 - r0, 0.001))
          rotate(90)
            sparger_section(across_flats, facets);
}

// A quarter-turn elbow joining a vertical run at x = r to a horizontal run at z = 0, so a brush
// gets round the corner. Centre of curvature at (r + bend, 0, bend).
module sparger_elbow_solid(r, bend, across_flats, facets) {
  translate([r + bend, 0, bend])
    rotate([90, 0, 0])
      rotate([0, 0, 180])
        rotate_extrude(angle = 90, convexity = 6)
          translate([bend, 0])
            sparger_section(across_flats, facets);
}

// ----- the part -----

/**
 * @brief Tube sparger.
 *
 * @param radii           Ring centreline radii, innermost first. One entry is a plain ring.
 * @param holes           Gas holes per ring, same length as radii - from sparger_holes_per_ring().
 * @param hole_diameter   Gas hole diameter.
 * @param hole_bearing    "in" points holes at the axis, "down" points them at the floor.
 * @param tube            Tube outside, across flats.
 * @param bore            Tube bore diameter.
 * @param section_facets  Facets on the outside. 8 is an octagon; 6 a hexagon.
 * @param bore_facets     Facets in the bore. 0 is a true circle.
 * @param spoke_angles    Bearings of the radial arms tying the rings together.
 * @param spoke_bores     Which arms carry gas. Empty by default: a bored arm joins the rings at a
 *                        second point and puts a branch in the path no brush can turn into.
 * @param spoke_holes     Holes along each arm at equal-area radii; 0 leaves the arms as plumbing.
 *                        Non-zero makes a hub-and-spoke floor distributor.
 * @param feed_angle      Bearing of the feed arm. Must be a sector with no baffle in it.
 * @param feed_radius     Where the socket sits - the lid's port circle, so the riser is straight.
 * @param feed_bore       Socket bore, sized to the riser it accepts.
 * @param feed_height     Length of the socket above the elbow's top.
 * @param feed_wall       Wall around the socket bore.
 * @param socket_chamfer  45 deg lead-in at each socket mouth. 0 leaves the mouth square.
 * @param support_angles  Bearings of blind sockets that steady the part. Round, where the feed is
 *                        faceted - the only thing that tells them apart.
 * @param split_angle     Total angle of the cleaning gap opposite the feed. 0 leaves it closed.
 * @param hole_overshoot  How far a hole cuts past the inner face, to keep breakthrough off
 *                        floating point.
 * @param show_fluid_path Draw the gas path on its own instead of the part, in translucent blue.
 * @param bend_radius     Centreline radius of the feed elbow. undef takes 1.5 tube diameters.
 * @param plug_tap_radius Radius the end screw self-taps into (set_screw_tap_radius()). undef
 *                        leaves the ends open.
 * @param plug_depth      How much solid each end carries for that screw to bite into.
 */
module sparger(
  radii,
  holes,
  hole_diameter,
  tube,
  bore,
  hole_bearing = "in",
  section_facets = 8,
  bore_facets = 0,
  spoke_angles = [],
  spoke_bores = [],
  spoke_holes = 0,
  feed_angle = 0,
  feed_radius = undef,
  feed_bore = 4,
  feed_height = 8,
  feed_wall = 1.2,
  socket_chamfer = 0.5,
  support_angles = [],
  bend_radius = undef,
  hole_overshoot = 0.5,
  show_fluid_path = false,
  split_angle = 0,
  plug_tap_radius = undef,
  plug_depth = 6
) {
  _n = len(radii);
  _outer = max(radii);
  _inner = min(radii);
  _feed_r = is_undef(feed_radius) ? _inner : feed_radius;
  _wall = (tube - bore) / 2;
  // where the material reaches, and how low the part sits on its bottom flat
  _ac = sparger_across_corners(tube, section_facets);
  _bottom = sparger_face_distance(tube, section_facets, 270);
  // 1.5 tube diameters, the usual floor for a pipe bend; it has to clear the tube's own corners
  _corner_r = sparger_across_corners(tube, section_facets) / 2;
  _bend = is_undef(bend_radius) ? 1.5 * tube : bend_radius;

  assert(
    len(holes) == _n,
    str("sparger: ", _n, " rings but ", len(holes), " hole counts - one per ring, innermost first")
  );
  assert(
    _wall > 0,
    str("sparger: a ", bore, " mm bore leaves no wall in a ", tube, " mm tube")
  );
  // An arm with holes has to carry gas. Asserted because check-holes probes the outer surface
  // only, so a hole into a solid arm passes it.
  _unfed = [for (a = spoke_angles) if (len([for (b = spoke_bores) if (b == a) 1]) == 0) a];
  assert(
    spoke_holes == 0 || len(_unfed) == 0,
    str(
      "sparger: spoke_holes puts holes on the arm(s) at ", _unfed,
      " deg, which carry no gas - name them in spoke_bores or drop the holes"
    )
  );

  // sparger_hole_probes() walks rings only, so spoke holes are unprobed. Gated as the geometry is.
  if (spoke_holes > 0 && _n > 1 && len(spoke_angles) > 0)
    echo(str(
      "WARNING sparger: ", spoke_holes, " hole(s) per arm on ", len(spoke_angles),
      " arm(s) are not probed by check-holes, which walks rings only"
    ));

  // The chamfer eats the socket's wall at the mouth; half the wall keeps as much again under it.
  assert(
    socket_chamfer <= (tube - feed_bore) / 4,
    str(
      "sparger: a ", socket_chamfer, " mm lead-in opens the socket mouth to ",
      feed_bore + 2 * socket_chamfer, " mm inside a ", tube, " mm section - that leaves ",
      (tube - feed_bore - 2 * socket_chamfer) / 2, " mm of wall at the mouth"
    )
  );

  assert(
    (tube - feed_bore) / 2 >= feed_wall,
    str(
      "sparger: a ", tube, " mm tube leaves ", (tube - feed_bore) / 2, " mm around a ", feed_bore,
      " mm riser, against a ", feed_wall, " mm wall - size the tube from the riser, not the socket"
    )
  );
  assert(
    _bend > _corner_r,
    str(
      "sparger: a ", _bend, " mm bend radius is inside the tube's own ", _corner_r,
      " mm corner radius, so the elbow sweeps through its own axis"
    )
  );
  assert(
    hole_diameter < bore,
    str("sparger: a ", hole_diameter, " mm hole does not open into a ", bore, " mm bore")
  );
  // The split has to land in a hole-free sector on every ring, checked against where the holes
  // are: an odd count puts one exactly at feed+180, whatever the pitch says.
  _split_half = split_angle / 2;
  _eaten = [
    for (i = [0:_n - 1])
      for (_raw = sparger_hole_angles(holes[i], 0))
        let (
          _a = _raw % 360,                                        // relative to the feed
          _d = abs(((_a - 180 + 180 + 720) % 360) - 180),          // ... from the split's centre
          _hw = asin(min(1, (hole_diameter / 2) / radii[i]))
        )
          if (_d < _split_half + _hw) [i, _a]
  ];
  assert(
    split_angle == 0 || len(_eaten) == 0,
    str(
      "sparger: the ", split_angle, " deg split removes hole(s) [ring, deg from feed] ", _eaten,
      " - an odd hole count always lands one at feed+180. Change the count or narrow the split"
    )
  );

  // And it has to miss every arm, spoke or support.
  _arms = concat(spoke_angles, support_angles);
  _split_at = (feed_angle + 180) % 360;
  // an arm's angular half-width at the innermost ring, where it subtends the most
  _arm_half = asin(min(1, (_ac / 2) / _inner));
  _fouled = [
    for (a = _arms)
      let (_d = abs(((a - _split_at + 180 + 720) % 360) - 180))
        if (_d < _split_half + _arm_half) a
  ];
  assert(
    split_angle == 0 || len(_fouled) == 0,
    str(
      "sparger: the split at ", _split_at, " deg cuts the arm(s) at ", _fouled,
      " deg - move the split, the feed, or those arms"
    )
  );

  // How deep a hole must cut to break through the inner wall everywhere: past the section's
  // corners, past the sweep's chords, and then some, so breakthrough is not left to floating point.
  _sweep_facets = sparger_sweep_facets(_outer, tube, section_facets);
  function _reach_at(r) =
    r - sparger_inner_face_radius(r, tube, section_facets, _sweep_facets) + hole_overshoot;

  // ----- the gas path, named once -----
  //
  // Subtracted to make the part and drawn on its own to show what the gas does. Nested, so it
  // reads the enclosing scope.
  module _fluid_path() {
      // The bore through every ring. Where the ring is split, the bore stops short of each cut
      // face by plug_depth, which is the stock the screw bites into.
      for (i = [0:_n - 1])
        if (split_angle == 0)
          sparger_ring_solid(radii[i], bore, bore_facets);
        else
          rotate([0, 0, feed_angle + 180 + split_angle / 2 + _plug_arc(radii[i], plug_depth)])
            rotate_extrude(
              angle = 360 - split_angle - 2 * _plug_arc(radii[i], plug_depth), convexity = 6
            )
              translate([radii[i], 0])
                sparger_section(bore, bore_facets);

      // Only the arms named as carrying gas; see spoke_bores.
      if (_n > 1)
        for (a = spoke_bores)
          sparger_spoke_solid(_inner - z_fight, _outer + z_fight, a, bore, bore_facets);

      rotate([0, 0, feed_angle]) {
        sparger_spoke_solid(_feed_r + _bend, _outer + z_fight, 0, bore, bore_facets);
        sparger_elbow_solid(_feed_r, _bend, bore, bore_facets);
        // and up the socket, meeting the elbow's top
        translate([_feed_r, 0, _bend])
          cylinder(h = feed_height + z_fight, d = feed_bore);
      }

      // Holes along the arms at equal-area radii, always downward.
      if (spoke_holes > 0 && _n > 1)
        for (a = spoke_angles)
          for (r = sparger_equal_area_radii(spoke_holes, _outer, _inner))
            rotate([0, 0, a])
              translate([r, 0, -_ac / 2 - z_fight])
                cylinder(h = _ac / 2 + 2 * z_fight, d = hole_diameter);

      // Gas holes, inward at the impeller (Birch & Ahmed) or down at the floor.
      for (i = [0:_n - 1])
        for (a = sparger_hole_angles(holes[i], feed_angle))
          rotate([0, 0, a])
            translate([radii[i], 0, 0])
              if (hole_bearing == "down")
                translate([0, 0, -_ac / 2 - z_fight])
                  cylinder(h = _ac / 2 + 2 * z_fight, d = hole_diameter);
              else
                rotate([0, -90, 0])
                  cylinder(h = _reach_at(radii[i]) + z_fight, d = hole_diameter);
  }

  if (show_fluid_path)
    color("lightblue", 0.5) _fluid_path();
  else
    difference() {
    union() {
      for (r = radii) sparger_ring_solid(r, tube, section_facets);

      // Spokes tie the rings into one part; with one ring there are none.
      if (_n > 1)
        for (a = spoke_angles)
          sparger_spoke_solid(_inner, _outer, a, tube, section_facets);

      // The feed: socket, elbow, and the run outward to the first ring it meets.
      rotate([0, 0, feed_angle]) {
        sparger_spoke_solid(_feed_r + _bend, _outer, 0, tube, section_facets);
        sparger_elbow_solid(_feed_r, _bend, tube, section_facets);

        // Socket: the tube standing up, with the tube's own section. Faceted where the supports
        // are round, which is the only thing that tells them apart at the bottom of a jar.
        translate([_feed_r, 0, _bend])
          linear_extrude(height = feed_height)
            sparger_section(tube, section_facets);
      }

      // Supports: blind, round, otherwise identical to the feed. The boss starts at the tube's
      // bottom flat, not its corner radius, so the part rests on its rings.
      for (a = support_angles)
        rotate([0, 0, a]) {
          sparger_spoke_solid(_feed_r, _outer, 0, tube, section_facets);
          translate([_feed_r, 0, -_bottom])
            cylinder(h = _bottom + _ac / 2 + feed_height, d = tube);
        }

    }

    // ---- everything below is removed ----

      _fluid_path();

    // A support's pocket stops at the tube's top face, so a tube dropped in cannot vent into the bore.
    for (a = support_angles)
      rotate([0, 0, a])
        translate([_feed_r, 0, _ac / 2])
          cylinder(h = feed_height + z_fight, d = feed_bore);

    // Lead-in at every socket mouth: five tubes have to find five sockets blind as the lid comes
    // down. The bore below the chamfer is unchanged. Each socket top is taken from its own datum.
    if (socket_chamfer > 0)
      for (s = concat([[feed_angle, _bend]], [for (a = support_angles) [a, _ac / 2]]))
        rotate([0, 0, s[0]])
          translate([_feed_r, 0, s[1] + feed_height - socket_chamfer])
            cylinder(
              h = socket_chamfer + z_fight,
              d1 = feed_bore, d2 = feed_bore + 2 * socket_chamfer
            );

    // The cleaning gap, opposite the feed, as a pie so both cut faces are radial.
    if (split_angle > 0)
      rotate([0, 0, feed_angle + 180 - split_angle / 2])
        rotate_extrude(angle = split_angle, convexity = 4)
          // across corners plus a margin, or a skin is left at the corners
          translate([max(_inner - _ac, 0.01), -_ac / 2 - 1])
            square([_outer - _inner + 2 * _ac, _ac + 2]);

    // The pilot for each end screw, on the ring's tangent so the screw runs along the bore.
    if (split_angle > 0 && !is_undef(plug_tap_radius))
      for (i = [0:_n - 1])
        for (s = [-1, 1])
          rotate([0, 0, feed_angle + 180 + s * split_angle / 2])
            translate([radii[i], 0, 0])
              // -90*s: the screw is driven from the gap into the material
              rotate([-90 * s, 0, 0])
                cylinder(h = plug_depth + z_fight, r = plug_tap_radius);
    }
}

// The angular length a plug of `depth` occupies on a ring of `radius`.
function _plug_arc(radius, depth) = depth / radius * 180 / PI;

// ----- the breakthrough claim -----

// Emit, per ring hole, the two points that must be void if that hole is a gas path, for
// check-holes: `exit` just inside the discharge face on the hole's axis, `feed` on the tube's
// centreline at the same station. A blind hole is a perfectly good solid, so check-mesh cannot
// catch it; and on a split ring a hole in the dead arc beside a plug breaks out and connects to
// nothing, which is why both ends are probed. Derived from the same functions as the cut.
// `origin` is where the caller placed the part; a probe echoed in the part's own frame while the
// mesh sits elsewhere lands in empty space and cannot fail.
module sparger_hole_probes(
  radii, holes, tube, section_facets = 8, feed_angle = 0, hole_bearing = "in", margin = 0.05,
  origin = [0, 0, 0]
) {
  _sf = sparger_sweep_facets(max(radii), tube, section_facets);
  for (i = [0:len(radii) - 1])
    for (a = sparger_hole_angles(holes[i], feed_angle))
      let (
        _pr = hole_bearing == "down"
          ? radii[i]
          : sparger_inner_face_radius(radii[i], tube, section_facets, _sf) + margin,
        _pz = hole_bearing == "down"
          ? -sparger_face_distance(tube, section_facets, 270) + margin
          : 0
      ) {
        echo(str("HOLEPROBE|exit|", origin[0] + _pr * cos(a), "|", origin[1] + _pr * sin(a), "|", origin[2] + _pz));
        echo(str("HOLEPROBE|feed|", origin[0] + radii[i] * cos(a), "|", origin[1] + radii[i] * sin(a), "|", origin[2]));
      }
}

// ----- the arm -----
//
// The ring's feed without the ring: a socket, the elbow, and one straight run with its holes
// underneath, closed at the end. In its own frame the socket stands on the z axis and the run
// goes out along +x at z = 0, so a caller turns it to point where it likes.

// `reach` is from the socket's axis to the closed end, which is what a caller places; the bored
// run is what is left after the elbow and the end.
function sparge_arm_bored(reach, bend, end_depth) = reach - bend - end_depth;
// Where the holes sit along the run, from the socket's axis: evenly over the bored length.
function sparge_arm_hole_positions(reach, holes, bend, end_depth) =
  [for (i = [0:holes - 1]) bend + (i + 0.5) * sparge_arm_bored(reach, bend, end_depth) / holes];
function sparge_arm_pitch(reach, holes, bend, end_depth) = sparge_arm_bored(reach, bend, end_depth) / holes;

/**
 * @brief One arm: socket, elbow, a straight bored run with holes down, a closed end.
 * @param reach           From the socket's axis to the closed end, along +x.
 * @param holes           Gas holes along the run.
 * @param hole_diameter   Gas hole diameter.
 * @param tube            Tube outside, across flats.
 * @param bore            Tube bore diameter.
 * @param section_facets  Facets on the outside.
 * @param feed_bore       Socket bore, sized to the riser it accepts.
 * @param feed_height     Length of the socket above the elbow's top.
 * @param socket_chamfer  45 deg lead-in at the socket mouth.
 * @param bend_radius     Centreline radius of the elbow. undef takes 1.5 tube diameters.
 * @param end_depth       Solid left at the closed end.
 * @param socket_boss     Diameter of a round boss round the socket, for a screw to bite through;
 *                        undef leaves the socket the tube's own section.
 * @param screw_tap_radius Radius of a radial pilot through that boss, at mid depth, for a set
 *                        screw to self-tap into and grip the riser; undef leaves none.
 * @param show_fluid_path Draw the gas path on its own.
 */
module sparge_arm(
  reach, holes, hole_diameter, tube, bore, section_facets = 8, feed_bore = 4, feed_height = 8,
  socket_chamfer = 0.5, bend_radius = undef, end_depth = 4, socket_boss = undef,
  screw_tap_radius = undef, show_fluid_path = false
) {
  _ac = sparger_across_corners(tube, section_facets);
  _bend = is_undef(bend_radius) ? 1.5 * tube : bend_radius;
  _bored = sparge_arm_bored(reach, _bend, end_depth);
  _boss = is_undef(socket_boss) ? tube : socket_boss;

  assert(
    is_undef(screw_tap_radius) || !is_undef(socket_boss),
    "sparge_arm: a screw pilot needs a socket_boss to run through"
  );

  assert(
    hole_diameter < bore,
    str("sparge_arm: a ", hole_diameter, " mm hole does not open into a ", bore, " mm bore")
  );
  assert(
    _bored > holes * hole_diameter,
    str("sparge_arm: ", holes, " holes of ", hole_diameter, " mm do not fit along ", _bored, " mm of bore")
  );
  assert(
    socket_chamfer <= (tube - feed_bore) / 4,
    str("sparge_arm: a ", socket_chamfer, " mm lead-in leaves too little wall at the socket mouth of a ", tube, " mm section")
  );

  module _fluid_path() {
    sparger_spoke_solid(_bend - z_fight, _bend + _bored, 0, bore, 0);
    sparger_elbow_solid(0, _bend, bore, 0);
    translate([0, 0, _bend])
      cylinder(h = feed_height + z_fight, d = feed_bore);
    for (x = sparge_arm_hole_positions(reach, holes, _bend, end_depth))
      translate([x, 0, -_ac / 2 - z_fight])
        cylinder(h = _ac / 2 + 2 * z_fight, d = hole_diameter);
  }

  if (show_fluid_path)
    color("lightblue", 0.5) _fluid_path();
  else
    difference() {
      union() {
        sparger_spoke_solid(_bend, reach, 0, tube, section_facets);
        sparger_elbow_solid(0, _bend, tube, section_facets);
        translate([0, 0, _bend])
          if (is_undef(socket_boss))
            linear_extrude(height = feed_height)
              sparger_section(tube, section_facets);
          else
            cylinder(h = feed_height, d = _boss);
      }
      _fluid_path();
      if (socket_chamfer > 0)
        translate([0, 0, _bend + feed_height - socket_chamfer])
          cylinder(h = socket_chamfer + z_fight, d1 = feed_bore, d2 = feed_bore + 2 * socket_chamfer);
      // the pilot, radial through the boss to the side of the run, so the screw is reachable
      if (!is_undef(screw_tap_radius))
        translate([0, 0, _bend + feed_height / 2])
          rotate([-90, 0, 0])
            cylinder(h = _boss / 2 + z_fight, r = screw_tap_radius);
    }
}

// The arm's probes for check-holes, in the mesh's frame: the arm at `origin`, its run turned
// `bearing` degrees from +x.
module sparge_arm_hole_probes(
  reach, holes, tube, section_facets = 8, bend_radius = undef, end_depth = 4, margin = 0.05,
  origin = [0, 0, 0], bearing = 0
) {
  _bend = is_undef(bend_radius) ? 1.5 * tube : bend_radius;
  _pz = -sparger_face_distance(tube, section_facets, 270) + margin;
  for (x = sparge_arm_hole_positions(reach, holes, _bend, end_depth)) {
    echo(str("HOLEPROBE|exit|", origin[0] + x * cos(bearing), "|", origin[1] + x * sin(bearing), "|", origin[2] + _pz));
    echo(str("HOLEPROBE|feed|", origin[0] + x * cos(bearing), "|", origin[1] + x * sin(bearing), "|", origin[2]));
  }
}

// What the arm does to the gas, from the same arguments the geometry was given.
module sparge_arm_report(reach, holes, hole_diameter, tube, bore, gas_flow, bend_radius = undef, end_depth = 4) {
  _bend = is_undef(bend_radius) ? 1.5 * tube : bend_radius;
  _v = stirred_tank_orifice_velocity(gas_flow, holes, hole_diameter);
  _db = stirred_tank_bubble_diameter(hole_diameter);
  _bore_v = stirred_tank_sparge_bore_velocity(gas_flow, bore, 1);
  _open = stirred_tank_sparge_open_area_ratio(holes, hole_diameter, bore, 1);
  _pitch = sparge_arm_pitch(reach, holes, _bend, end_depth) / hole_diameter;
  _dep = sparger_departures(_v, _pitch, _open, stirred_tank_sparge_bore_head(_bore_v), stirred_tank_orifice_pressure(_v));

  echo(str(
    "sparge arm: ", holes, " holes of ", hole_diameter, " mm along ", sparge_arm_bored(reach, _bend, end_depth), " mm at ",
    _pitch, " hole diameters, ", _v, " m/s each; bubbles ", _db, " mm at formation, ",
    stirred_tank_bubble_rate(gas_flow, _db), " a second; the ", bore, " mm bore carries ", _bore_v,
    " m/s, open area ratio ", _open
  ));
  if (len(_dep) > 0)
    echo(str("WARNING sparge arm: extrapolated on ", _dep));
}

// ----- reporting -----

// Echo what this sparger does to the gas and what it is extrapolating on, from the same arguments
// the geometry was given.
module sparger_report(radii, holes, hole_diameter, tube, bore, gas_flow, paths = 2, holdup = undef) {
  _n = len(radii);
  _total = sparger_sum(holes);
  _v = stirred_tank_orifice_velocity(gas_flow, _total, hole_diameter);
  _db = stirred_tank_bubble_diameter(hole_diameter);
  // Per segment: the feed run carries the whole flow in one bore; a ring carries its share (read
  // off its hole count) `paths` ways.
  _feed_v = stirred_tank_sparge_bore_velocity(gas_flow, bore, 1);
  _feed_open = stirred_tank_sparge_open_area_ratio(_total, hole_diameter, bore, 1);
  _ring_v = [
    for (i = [0:_n - 1])
      stirred_tank_sparge_bore_velocity(gas_flow * holes[i] / _total, bore, paths)
  ];
  _ring_open = [
    for (i = [0:_n - 1]) stirred_tank_sparge_open_area_ratio(holes[i], hole_diameter, bore, paths)
  ];

  // Judged on the worst segment.
  _worst_open = max(concat([_feed_open], _ring_open));
  _worst_head = max(concat([stirred_tank_sparge_bore_head(_feed_v)],
                           [for (v = _ring_v) stirred_tank_sparge_bore_head(v)]));
  _dep = sparger_departures(
    _v,
    min([for (i = [0:_n - 1]) sparger_pitch_ratio(radii[i], holes[i], hole_diameter)]),
    _worst_open,
    _worst_head,
    stirred_tank_orifice_pressure(_v)
  );

  echo(str(
    "sparger: ", _n, " ring(s) at ", radii, " mm carrying ", holes, " holes of ", hole_diameter,
    " mm, ", _total, " in all at ", _v, " m/s"
  ));
  echo(str(
    "sparger bubbles: ", _db, " mm at formation, ", stirred_tank_bubble_rate(gas_flow, _db),
    " a second",
    is_undef(holdup)
      ? ""
      : str(", ", stirred_tank_specific_area(holdup, _db), " 1/m of interface at ", holdup * 100, "% holdup")
  ));
  echo(str(
    "sparger feed run: ", bore, " mm bore carrying ", _feed_v, " m/s, ",
    stirred_tank_sparge_bore_head(_feed_v), " Pa of velocity head against ",
    stirred_tank_orifice_pressure(_v), " Pa at a hole, open area ratio ", _feed_open
  ));
  echo(str(
    "sparger rings: ", _ring_v, " m/s at ", paths, " path(s) each, open area ratio ", _ring_open,
    ", ", [for (v = _ring_v) stirred_tank_sparge_bore_head(v)], " Pa of velocity head",
    _worst_open >= 1 ? str(" - open area ", _worst_open, " is above 1, so the holes compete with their supply") : ""
  ));
  echo(str("sparger envelope: r ", sparger_tube_envelope(radii, tube, 8), " mm, to clear the baffles and pass the mouth"));
  echo(str(
    "sparger pitch: ", [for (i = [0:_n - 1]) sparger_pitch_ratio(radii[i], holes[i], hole_diameter)],
    " hole diameters between holes (floor ", sparger_pitch_ratio_floor(), ", reasoned, not cited)"
  ));
  if (len(_dep) > 0)
    echo(str("WARNING sparger: extrapolated on ", _dep));
}

// ----- example usage -----
//
// 8.23207 L at 0.5 vvm, quoted.
_ex_radii = sparger_equal_area_radii(2, 90, 58);
_ex_flow = 4.11604 / 60000; // m^3/s, 0.5 vvm on 8.23207 L
// 1.2 mm holes at 3 m/s, chosen by reading sparger_report()
_ex_holes = sparger_holes_per_ring(
  sparger_hole_count_for_velocity(_ex_flow, 1.2, 3),
  sparger_area_shares(_ex_radii, 90, 58)
);

sparger(
  radii = _ex_radii,
  holes = _ex_holes,
  hole_diameter = 1.2,
  // the tube is the riser's bore plus a wall, because the feed socket IS this tube standing up
  tube = 4 + 2 * 1.2,
  bore = 4,
  spoke_angles = [90, 270],
  feed_angle = 240,
  feed_radius = 56.9,
  support_angles = [0],
  split_angle = 14,
  plug_tap_radius = 1.65, // an M4 tap
  show_fluid_path = false
);

sparger_hole_probes(
  radii = _ex_radii, holes = _ex_holes, tube = 4 + 2 * 1.2, feed_angle = 240
);

sparger_report(
  radii = _ex_radii, holes = _ex_holes, hole_diameter = 1.2, tube = 4 + 2 * 1.2, bore = 4,
  gas_flow = _ex_flow, paths = 2, holdup = 0.01 // fed at one point, so gas goes both ways round
);
