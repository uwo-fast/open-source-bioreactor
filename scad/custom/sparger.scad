/**
 * @file sparger.scad
 * @brief Tube-based gas sparger: one ring, concentric rings, or a spider, from one module.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * WHAT THIS REPLACES, and why. The old sparge_ring was a sealed torus of rectangular section. It
 * rendered, it was manifold, and it could never be cleaned: the bore was a 1.6 x 7.6 mm slot whose
 * only openings were eight 3 mm holes, so nothing could be passed through it and nothing the
 * slicer left inside could ever come out. On a vessel growing algae that is not a detail.
 *
 * So this part is a TUBE. Round bore, open ends, and a split opposite the feed - pull the two
 * screws and a pipe cleaner goes straight through each half. Everything else follows from that
 * one decision.
 *
 * THE SECTION IS A POLYGON OUTSIDE AND A CIRCLE INSIDE, and the two have different jobs. The
 * outside is faceted so it prints without a curved crown and so each hole is drilled square to a
 * flat rather than into a curve. The bore is round so a brush can turn in it and so a screw can
 * self-tap into its end. Both are parameters: `section_facets` and `bore_facets`, and a bore_facets
 * of 0 means a smooth circle, which is the default and the reason the part exists.
 *
 * NO THREAD IS MODELLED ANYWHERE. The end plugs are stainless set screws that cut their own thread
 * in PETG, so what is drawn is a plain pilot at the screw's tap radius - the same convention
 * head.scad already uses for the impeller's set screws.
 *
 * WHAT DECIDES THE LAYOUT IS SEPARATED FROM WHAT DRAWS IT, but both live here, because a ring
 * count is a sparger question and belongs with the sparger. The functions in the first half take
 * a duty - a gas rate, an annulus to cover - and return radii and hole counts; the module in the
 * second half takes those as ARGUMENTS and knows nothing about where they came from. So a caller
 * can drive the geometry from the fluid dynamics, or override it and drive it by hand, and neither
 * path is the odd one out.
 *
 * What is NOT here is anything a sparger does not own. Bubble diameter, interfacial area and
 * whether a bore is a plenum are things gas does inside a vessel, so they live in
 * utils/stirred_tank.scad beside orifice velocity and capillary pressure - which is the boundary
 * utils/gas_supply.scad already draws at the inlet fitting.
 */

use <../utils/stirred_tank.scad>;

// No screw registry here on purpose. The end plug is described by ONE NUMBER - the radius a screw
// self-taps into - and the caller resolves which screw that is. Pulling set_screws.scad in would
// drag NopSCADlib's whole screw chain into a file that draws a tube, to learn a number the caller
// already knows.

z_fight = $preview ? 0.05 : 0;
$fn = $preview ? 48 : 96;

// ----- layout: what the duty asks for -----
//
// Pure functions. They decide where rings go and how many holes each carries, and they draw
// nothing - the module below takes their output as arguments.
//
// A multi-ring sparger exists to spread gas over the vessel's CROSS SECTION rather than release it
// all at one radius. "Evenly" means equal volumetric flow per unit of plan area, which is what
// makes superficial gas velocity and so holdup uniform - and an annulus grows with radius, so
// equally spaced rings are the wrong answer. An outer ring serves more vessel and must carry more.

// Band edges, count+1 of them, cutting the sparged annulus into equal AREAS.
function sparger_band_edges(count, r_outer, r_inner = 0) =
  [for (k = [0:count]) sqrt(pow(r_inner, 2) + (k / count) * (pow(r_outer, 2) - pow(r_inner, 2)))];

// The area-median radius of each band, which is where its ring goes. Not the arithmetic middle -
// area runs as r^2, and a ring at the middle of its band sits too far in.
function sparger_equal_area_radii(count, r_outer, r_inner = 0) =
  let (_e = sparger_band_edges(count, r_outer, r_inner))
    [for (k = [0:count - 1]) sqrt((pow(_e[k], 2) + pow(_e[k + 1], 2)) / 2)];

// Sums a list. OpenSCAD has no builtin and every file that needs one grows its own.
function sparger_sum(v, i = 0) = i >= len(v) ? 0 : v[i] + sparger_sum(v, i + 1);

// What fraction of the gas each ring should carry. Equal-area radii make this 1/count each, and it
// is computed rather than assumed so a hand-placed set of radii still gets an honest split: each
// ring serves out to the area-midpoint between it and its neighbours.
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

// How many holes the duty asks for at a chosen orifice velocity. Barbosa ran 0.4-5.4 m/s and
// established no critical velocity, so this targets a tested range rather than a limit;
// stirred_tank_orifice_velocity() is the same relation solved the other way.
function sparger_hole_count_for_velocity(gas_flow, hole_diameter, velocity) =
  gas_flow / (velocity * PI / 4 * pow(hole_diameter / 1000, 2));

// Split a total across rings by their share. Never below one - a ring with no holes is a ring that
// does nothing, which should be a count change rather than a silent no-op.
function sparger_holes_per_ring(total, shares) = [for (f = shares) max(1, round(total * f))];

// Centre-to-centre along a ring, and the same in hole diameters. The ratio is what matters: holes
// closer than a few diameters coalesce as they form, which undoes the bubble size the diameter was
// chosen for. No source held here gives the floor, so it is REASONED, NOT CITED, and reported.
function sparger_ring_pitch(radius, count) = 2 * PI * radius / count;
function sparger_pitch_ratio(radius, count, hole_diameter) =
  sparger_ring_pitch(radius, count) / hole_diameter;
function sparger_pitch_ratio_floor() = 3; // reasoned, not cited

// Where the holes sit on a ring, in degrees. Half a pitch off the feed, so the far side of the
// ring lands between two of them rather than on one. SHARED by the cut, the split assert and the
// breakthrough probe - three consumers that must agree about one set of angles.
function sparger_hole_angles(count, feed_angle = 0) =
  [for (j = [0:count - 1]) feed_angle + 180 / count + j * 360 / count];

// The radius of a ring's INNER face, which is what an inward hole has to get past. Faceted twice:
// the section is a polygon reaching across corners, and rotate_extrude chords the sweep so between
// vertices the face sits nearer the axis than nominal. Getting this wrong by a quarter millimetre
// is what left twenty blind holes, so it is one expression and the check below tests it.
function sparger_inner_face_radius(ring_radius, tube, section_facets, sweep_facets) =
  (ring_radius - sparger_face_distance(tube, section_facets, 180)) * cos(180 / sweep_facets);

// How many facets rotate_extrude will actually use, derived the way OpenSCAD derives it rather than
// read off $fn - which is zero unless something sets it, and a zero $fn means $fa and $fs decide.
function sparger_sweep_facets(outer_radius, tube, section_facets) =
  $fn > 0
    ? max($fn, 3)
    : ceil(max(
        min(360 / $fa, (outer_radius + sparger_across_corners(tube, section_facets) / 2) * 2 * PI / $fs),
        5
      ));

// [innermost, outermost] radius the tubes occupy. A tube sparger is ROUND, which is what the old
// flat section existed to avoid - the annulus between baffles and mouth is millimetres while the
// room above and below is tens - so the envelope is reported and the vessel decides.
//
// ACROSS CORNERS, because that is where the material actually is. Quoted across flats it
// under-reports by a quarter of a millimetre a side on a 6 mm octagon, and this is the number that
// has to clear 1.7 mm of baffle gap - a fit figure that flatters itself is worse than none.
function sparger_tube_envelope(radii, tube_diameter, facets = 8) =
  let (_ac = sparger_across_corners(tube_diameter, facets))
    [min(radii) - _ac / 2, max(radii) + _ac / 2];

// What this sparger violates, by NAME, the shape stirred_tank_medek_departures set. A caller told
// only "out of range" cannot tell a sparger that is merely coarse from one that cannot distribute.
function sparger_departures(orifice_velocity, pitch_ratio, open_area_ratio, bore_head, orifice_drop) =
  [
    if (!stirred_tank_in_band(orifice_velocity, [0.4, 5.4])) "orifice velocity",
    if (pitch_ratio < sparger_pitch_ratio_floor()) "hole pitch",
    if (open_area_ratio >= 1) "open area",
    if (bore_head >= 0.5 * orifice_drop) "bore velocity",
  ];

// ----- the tube's section -----
//
// Across FLATS, always. A polygon quoted across corners changes its wall every time the facet count
// moves, and the wall is what has to survive a hole being drilled through it.
function sparger_across_corners(across_flats, facets) = across_flats / cos(180 / facets);

// How far to turn the section so a FLAT lands on the bed instead of an edge. `circle($fn=n)` puts a
// vertex at 0 degrees, and rotate_extrude maps the section's -y to -z, so an unrotated octagon
// stands on a corner: the part balances on a line and the first layer is a knife edge. It also put
// a corner where every gas hole is drilled, against a header claiming each hole meets a flat.
//
// Solved so 270 degrees - straight down in the section's frame - is an EDGE MIDPOINT. Every facet
// count gets a bottom flat; a multiple of four gets flats on all four cardinals, so the holes get
// one too. A hexagon does not, and drills into a corner - which is a reason to prefer 8 over 6.
function sparger_section_rotation(facets) =
  facets == 0
    ? 0
    : let (_p = 360 / facets, _r = 270 - 180 / facets) _r - floor(_r / _p) * _p;

// How far the material reaches in a given direction. A polygon is not a circle: a corner reaches
// across_corners/2 and a flat only across_flats/2, and WHICH ONE a hole is aimed at decides how far
// it has to cut to break out. Using the corner distance for a hole that meets a flat overshoots
// harmlessly; using it to place a breakthrough probe puts the probe outside the part, where it is
// void whether the hole opened or not - a check that cannot fail.
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
//
// A ring, swept about the axis. convexity is set because a faceted annular section self-overlaps in
// preview otherwise.
module sparger_ring_solid(radius, across_flats, facets) {
  rotate_extrude(convexity = 6)
    translate([radius, 0])
      sparger_section(across_flats, facets);
}

// A straight run along +x, from r0 to r1 at a given bearing. Built as a prism rather than a
// cylinder so its section matches the ring's exactly - a spoke that was round where the ring is
// octagonal leaves a step inside the bore, which is where a brush snags.
//
// THE QUARTER TURN IS NOT DECORATION. rotate_extrude maps the section's -y to -z, but this
// extrusion maps the section's +x to -z instead - so the same section that sits flat on the bed as
// a ring stands on a corner as a spoke. Turning it 90 degrees puts the same flat underneath both.
module sparger_spoke_solid(r0, r1, angle, across_flats, facets) {
  rotate([0, 0, angle])
    translate([r0, 0, 0])
      rotate([0, 90, 0])
        linear_extrude(height = max(r1 - r0, 0.001))
          rotate(90)
            sparger_section(across_flats, facets);
}

/**
 * @brief A quarter-turn elbow joining a vertical run at `x = r` to a horizontal run at z = 0.
 *
 * This is the corner the old part did not have. Its feed arm was a cube meeting a torus, so the gas
 * turned 90 degrees against a square shoulder and a brush would stop dead at it. A swept arc costs
 * nothing to print and is the difference between a bore you can pass something through and one you
 * cannot.
 *
 * The centre of curvature sits at (r + bend, 0, bend), which is the only point that is `bend` from
 * both tangent lines; the arc then runs from (r, 0, bend) on the vertical to (r + bend, 0, 0) on the
 * horizontal. Swept in the x-y plane and stood up, because rotate_extrude only revolves about Z.
 */
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
 * @param bore_facets     Facets in the bore. 0 is a true circle, which is the point of the part.
 * @param spoke_angles    Bearings of the radial arms tying the rings together.
 * @param spoke_bores     Which arms carry gas. EMPTY BY DEFAULT: an arm's job is to hold the rings
 *                        concentric, and boring it joins them at a second point, which turns the
 *                        gas path from a tree into a network and puts a branch in it that no brush
 *                        can turn into. Name an angle here only when that arm has to carry gas.
 * @param spoke_holes     Holes along EACH arm, placed at equal-area radii the same way the rings
 *                        are. 0 leaves the arms as plumbing. Non-zero turns the part into a
 *                        hub-and-spoke distributor, which is what a vessel with no impeller
 *                        wants - gas spread across the floor rather than released at one radius.
 * @param feed_angle      Bearing of the feed arm. Must be a sector with no baffle in it.
 * @param feed_radius     Where the socket sits - the lid's port circle, so the riser is straight.
 * @param feed_bore       Socket bore, sized to the riser it accepts.
 * @param feed_height     Length of the socket above the elbow's top - which is bend_radius above
 *                        the tube's centreline, not above its top face.
 * @param feed_wall       Wall around the socket bore.
 * @param socket_chamfer  45 deg lead-in at each socket mouth, feed and support alike. 0 leaves the
 *                        mouth square.
 * @param support_angles  Bearings of blind sockets that steady the part. ROUND, where the feed is
 *                        hexagonal - see below, it is the only thing that tells them apart.
 * @param split_angle     Total angle of the cleaning gap opposite the feed. 0 leaves it closed.
 * @param hole_overshoot  How far a hole cuts PAST the inner face. Free - it is cutting culture
 *                        by then - and it is what keeps breakthrough off floating point.
 * @param show_fluid_path Draw the gas path on its own instead of the part - the bore, the elbow,
 *                        the socket and every hole, in translucent blue. The same geometry the
 *                        part is cut with, so what you see is what the gas gets.
 * @param bend_radius     Centreline radius of the feed elbow. undef takes 1.5 tube diameters,
 *                        which is the standard pipe-bend minimum and comfortably clears the
 *                        tube's own corners.
 * @param plug_tap_radius Radius the end screw self-taps into. set_screw_tap_radius() gives it;
 *                        a pilot only, no thread is modelled. undef leaves the ends open.
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
  // The tube is quoted across FLATS and its material reaches across CORNERS. Everything that has to
  // clear it, cut it or measure it uses this, not tube - see the hole reach below for what happens
  // when it does not. Defined here because the asserts need it.
  _ac = sparger_across_corners(tube, section_facets);
  // And how low it actually SITS, which is not the same number: the section is turned so a flat
  // faces the bed, so the part rests at across_flats/2 while its corners reach across_corners/2
  // out to the sides.
  _bottom = sparger_face_distance(tube, section_facets, 270);
  // 1.5 tube diameters on the centreline, the usual floor for a pipe bend. It has to clear the
  // tube's own ACROSS-CORNERS half width or the swept profile crosses the axis and rotate_extrude
  // refuses the part - which is exactly what a bend of one bore radius did on the first render.
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
  // The socket has to hold the riser it accepts. Sizing the socket from the riser is what put a
  // ledge on the tube; sizing the tube from the riser is the same requirement, met once.
  // An arm with holes in it has to be an arm that carries gas. This is an ASSERT and not a check
  // because check-holes cannot see it: the probe tests that a hole breaks the OUTER surface, not
  // that it reaches the bore, so a hole drilled up into a solid arm opens into the culture,
  // connects to nothing, and passes.
  _unfed = [for (a = spoke_angles) if (len([for (b = spoke_bores) if (b == a) 1]) == 0) a];
  assert(
    spoke_holes == 0 || len(_unfed) == 0,
    str(
      "sparger: spoke_holes puts holes on the arm(s) at ", _unfed,
      " deg, which carry no gas - name them in spoke_bores or drop the holes"
    )
  );

  // sparger_hole_probes() walks RINGS only, so spoke holes reach check-holes' report as neither
  // passed nor failed - they are simply not counted. Said out loud here rather than left to the
  // probe module's own header, because this is where someone turning them on will be looking.
  // Gated the way the GEOMETRY is - spoke holes are cut only on a multi-ring sparger with arms to
  // cut them in, so warning on spoke_holes alone reports holes that were never emitted.
  if (spoke_holes > 0 && _n > 1 && len(spoke_angles) > 0)
    echo(str(
      "WARNING sparger: ", spoke_holes, " hole(s) per arm on ", len(spoke_angles),
      " arm(s) are NOT covered by check-holes - it probes rings only, so nothing tests that these ",
      "break out or reach a bore. The assert above covers only the unbored-arm case"
    ));

  // The chamfer eats the socket's wall where it is thinnest - at the mouth - so it is bounded by
  // what is left there, not by taste. Half the wall keeps as much again under it.
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
  // The hole opens through the tube wall into the bore. A hole wider than the bore does not make a
  // hole, it makes a slot with the tube's crown missing.
  assert(
    hole_diameter < bore,
    str("sparger: a ", hole_diameter, " mm hole does not open into a ", bore, " mm bore")
  );
  // The split has to land in a hole-free sector on every ring, and this is checked against WHERE
  // THE HOLES ACTUALLY ARE rather than against their pitch. A pitch bound looks sufficient and is
  // not: holes sit at half-pitch from the feed, so an ODD count puts one exactly at feed+180, dead
  // centre of the split, while the bound passes it comfortably - 9 holes give a 20 deg half-pitch
  // and a 14 deg split clears it on paper and eats a hole in fact. The part still renders, still
  // meshes, and quietly vents one hole fewer than the report claims it has.
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

  // And it has to miss every ARM. Nothing checked this until a spider put a support at the split's
  // own bearing and the cut went straight through it - the part still rendered, still meshed, and
  // had lost the tube that holds it up. Both lists are checked, because a spoke carries gas and a
  // support carries the part and losing either is silent.
  _arms = concat(spoke_angles, support_angles);
  _split_at = (feed_angle + 180) % 360;
  // An arm's own angular half-width, taken at the INNERMOST ring where a given tube subtends the
  // most angle. Using a fixed tolerance instead rejected arms 30 degrees clear of the split.
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

  // How deep a hole must cut to break through the inner wall EVERYWHERE, not only where a facet
  // vertex lands. A faceted bore sits at r*cos(180/facets) between vertices, which is closer to the
  // centre than the nominal radius - so a hole stopping at nominal leaves a skin. The old part
  // learned this the expensive way: blind holes on a component whose entire job is to let gas out.
  // A circular bore (bore_facets 0) still facets at $fn, so the same correction applies to it.
  //
  // TWO skins, not one, and the first is the one that bit. The tube's section is a POLYGON quoted
  // across FLATS, so its own surface reaches across CORNERS - tube/2 is 3.0 on a 6 mm tube where
  // the material actually reaches 3.247. A hole cut to tube/2 stops 0.25 mm inside the wall and
  // never breaks out: eight blind holes on a part whose whole job is to let gas out, which is the
  // same defect the ring this replaces carried, in a different disguise.
  //
  // The second is the sweep's. rotate_extrude facets the ring, so between vertices the inner
  // surface sits at r*cos(180/n) - nearer the axis than nominal, so the hole has further to go.
  // Per ring, because it depends on that ring's radius.
  _sweep_facets = sparger_sweep_facets(_outer, tube, section_facets);
  //
  // OVERSHOOT is deliberate and free: past the inner face the hole is cutting culture, not part.
  // Landing exactly ON the face leaves the breakthrough to floating point, which is not a thing to
  // leave it to on the one feature this component exists for.
  function _reach_at(r) =
    r - sparger_inner_face_radius(r, tube, section_facets, _sweep_facets) + hole_overshoot;

  // ----- the gas path, named once -----
  //
  // The bore is what makes the part a sparger and it was written four times as a subtrahend -
  // rings, spokes, the feed run, the holes - with no name for the whole. So there was no way to
  // ask for it: showing the flow meant a second copy of every one of them, which is the defect
  // this file's own header warns about. Named, it is subtracted to make the part and drawn on
  // its own to show what the gas does, from one expression.
  //
  // Nested, so it reads the enclosing scope rather than taking fifteen arguments that could each
  // be passed a different value from the ones the solid was built with.
  module _fluid_path() {
      // The bore, through every ring, spoke and elbow. One expression per feature, so a bore can
      // never disagree with the solid it runs inside.
      //
      // Where the ring is split, the bore stops SHORT of each cut face by plug_depth. That is what
      // leaves solid stock for the screw to bite into - material the ring already has, rather than a
      // boss added back on afterwards, which would have been a second expression of the same plug.
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

      // Only the arms NAMED as carrying gas. Boring every arm joined the rings at three points
      // instead of one, so the gas divided by the resistance of a looped network rather than by
      // the hole counts sparger_area_shares sized - a designed split the topology did not deliver
      // and nothing reported. It also put 31 mm of bore in branches a brush cannot turn into, on
      // a part whose reason for existing is that it can be cleaned.
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

      // Holes along the arms, at equal-area radii between the innermost and outermost ring - the
      // same rule that places the rings, for the same reason. Always downward: an arm is radial, so
      // there is no "inward" for it to point, and down is where a floor distributor wants gas.
      if (spoke_holes > 0 && _n > 1)
        for (a = spoke_angles)
          for (r = sparger_equal_area_radii(spoke_holes, _outer, _inner))
            rotate([0, 0, a])
              translate([r, 0, -_ac / 2 - z_fight])
                cylinder(h = _ac / 2 + 2 * z_fight, d = hole_diameter);

      // Gas holes. Inward at the impeller, or down at the floor - Birch & Ahmed discharged theirs
      // toward the turbine, which is the "in" case; a vessel with no impeller wants "down".
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

      // Spokes tie the rings into one part and carry gas between them. With one ring they are
      // decoration and are simply absent.
      if (_n > 1)
        for (a = spoke_angles)
          sparger_spoke_solid(_inner, _outer, a, tube, section_facets);

      // The feed: socket, elbow, and the run outward to the first ring it meets.
      rotate([0, 0, feed_angle]) {
        sparger_spoke_solid(_feed_r + _bend, _outer, 0, tube, section_facets);
        sparger_elbow_solid(_feed_r, _bend, tube, section_facets);

        // Socket. It is THE TUBE STANDING UP and takes the tube's own section - not a boss sized
        // to the riser, which is the same physical thing described twice and showed as a 0.2 mm
        // ledge all round where the two nearly agreed.
        //
        // FACETED where the supports below are ROUND, because that is the only thing that tells
        // them apart once the part is at the bottom of a jar. They are otherwise the same boss -
        // same bore, same height. The difference is inside, where this one opens into the tube and
        // a support's pocket is blind. Get it the wrong way round and the gas goes down a capped
        // tube and back out its own vent into the headspace, while the rotameter reads flow and
        // the culture gets nothing.
        translate([_feed_r, 0, _bend])
          linear_extrude(height = feed_height)
            sparger_section(tube, section_facets);
      }

      // Supports. Blind, round, and identical to the feed otherwise - nothing is bored through, so
      // the tube that drops in carries no gas and only stops the part swinging.
      for (a = support_angles)
        rotate([0, 0, a]) {
          sparger_spoke_solid(_feed_r, _outer, 0, tube, section_facets);
          // The tube's inscribed circle, so a support is the same size as the feed and differs
          // only in being ROUND. Written as `tube` rather than as the riser plus a wall, which
          // gives the same number today and would stop doing so the moment either moved.
          //
          // AND IT STARTS AT THE TUBE'S BOTTOM FACE, not at its corner radius. Dropped to -_ac/2
          // it hangs 0.26 mm below the flat the part now stands on, so the whole sparger rests on
          // its round bosses instead of on its rings. Measured, not guessed: the first-layer
          // footprint came back 32.1 mm2, which is this boss's disc exactly.
          translate([_feed_r, 0, -_bottom])
            cylinder(h = _bottom + _ac / 2 + feed_height, d = tube);
        }

    }

    // ---- everything below is removed ----

      _fluid_path();

    // A support's pocket stops at the tube's own top face, so the arm below stays solid and a tube
    // dropped in cannot vent into the bore.
    for (a = support_angles)
      rotate([0, 0, a])
        translate([_feed_r, 0, _ac / 2])
          cylinder(h = feed_height + z_fight, d = feed_bore);

    // Lead-in at every socket mouth. Each tube port drops a rigid tube, so on the full lid FIVE of
    // them have to find five sockets at once as the lid comes down, blind, at the bottom of a jar.
    // A square-edged mouth is not something a tube finds - it is something a tube catches on.
    //
    // It widens the mouth and does NOT open the socket up: the bore is unchanged below the chamfer,
    // so what holds the tube is the same 8 mm of engagement it always was. The two socket tops sit
    // at different heights - the feed's on the elbow, a support's on the section's own top face -
    // so each is taken from its own datum rather than from one number that would be wrong for one.
    if (socket_chamfer > 0)
      for (s = concat([[feed_angle, _bend]], [for (a = support_angles) [a, _ac / 2]]))
        rotate([0, 0, s[0]])
          translate([_feed_r, 0, s[1] + feed_height - socket_chamfer])
            cylinder(
              h = socket_chamfer + z_fight,
              d1 = feed_bore, d2 = feed_bore + 2 * socket_chamfer
            );

    // The cleaning gap, opposite the feed. A pie rather than a box, so both cut faces are radial
    // and a screw entering one is square to it.
    if (split_angle > 0)
      rotate([0, 0, feed_angle + 180 - split_angle / 2])
        rotate_extrude(angle = split_angle, convexity = 4)
          // Across CORNERS plus a margin, in both directions. Sized on across-flats it left a
          // 0.25 mm skin at the octagon's top and bottom corners and the ring never opened.
          translate([max(_inner - _ac, 0.01), -_ac / 2 - 1])
            square([_outer - _inner + 2 * _ac, _ac + 2]);

    // The pilot for each end screw, on the ring's tangent so the screw runs along the bore. No
    // thread is modelled - a 316 set screw cuts its own in PETG, which is what head.scad already
    // does at the impeller collar.
    if (split_angle > 0 && !is_undef(plug_tap_radius))
      for (i = [0:_n - 1])
        for (s = [-1, 1])
          rotate([0, 0, feed_angle + 180 + s * split_angle / 2])
            translate([radii[i], 0, 0])
              // -90*s, not +90*s. At the face on the HIGH side of the split, material lies toward
              // increasing angle - local +y - and the screw has to be driven from the gap into it.
              // The other sign drills both pilots out into the gap, where they hold nothing.
              rotate([-90 * s, 0, 0])
                cylinder(h = plug_depth + z_fight, r = plug_tap_radius);
    }
}

// The angular length a plug of `depth` occupies on a ring of `radius`.
function _plug_arc(radius, depth) = depth / radius * 180 / PI;

// ----- the breakthrough claim -----

/**
 * @brief Emit, per hole, the TWO points that must be void if that hole is a gas path.
 *
 * The failure this exists to catch: every hole on this part was once cut a quarter of a millimetre
 * short, so all twenty ended blind. The part still rendered. It was still a 2-manifold. check-mesh
 * passed it, because a blind hole is a perfectly good solid - and every picture of it looked right,
 * because a 1.2 mm hole is smaller than a pixel when you photograph a 180 mm ring.
 *
 * A hole is a path only if BOTH ends are open, and one probe could only ever test one end:
 *
 *   exit  just inside the discharge face on the hole's own axis - material if a skin remains,
 *         void if the hole is through. This is the end that was blind.
 *   feed  on the tube's own centreline at the same station, which is where the bore runs. Void if
 *         gas can reach the hole, material if it cannot.
 *
 * The feed probe is not hypothetical on a split ring: the bore stops SHORT of each cut face by
 * plug_depth, so a hole that lands in that dead arc breaks the surface perfectly and connects to
 * nothing. Exit alone calls that hole good.
 *
 * Both are derived from the same functions the cut is, so the claim cannot drift from the geometry
 * it describes. RING holes only - `spoke_holes` is unprobed either way, and its own failure (holes
 * on an arm carrying no gas) is refused by an assert in sparger() instead.
 */
module sparger_hole_probes(
  radii, holes, tube, section_facets = 8, feed_angle = 0, hole_bearing = "in", margin = 0.05
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
        echo(str("HOLEPROBE|exit|", _pr * cos(a), "|", _pr * sin(a), "|", _pz));
        echo(str("HOLEPROBE|feed|", radii[i] * cos(a), "|", radii[i] * sin(a), "|", 0));
      }
}

// ----- reporting -----

/**
 * @brief Echo what this sparger does to the gas, and what it is extrapolating on.
 *
 * Separate from the module that draws it, so a caller can price a layout without rendering one -
 * and so head() can report the sparger it built without this file deciding what a render says.
 * Everything here is read back from the same arguments the geometry was given, so the report
 * cannot describe a part other than the one drawn.
 */
module sparger_report(radii, holes, hole_diameter, tube, bore, gas_flow, paths = 2, holdup = undef) {
  _n = len(radii);
  _total = sparger_sum(holes);
  _v = stirred_tank_orifice_velocity(gas_flow, _total, hole_diameter);
  _db = stirred_tank_bubble_diameter(hole_diameter);
  // PER SEGMENT, because one path count cannot describe the whole network. The FEED RUN carries the
  // entire flow through a single bore with every hole downstream of it; a RING carries only its own
  // share and is fed at one point, so that share goes `paths` ways. Priced with one number at
  // `paths` the feed comes out at half its velocity and a quarter of its head - and on a multi-ring
  // sparger each ring comes out inflated by the share it does not carry.
  //
  // The ring's share is read off its HOLE COUNT, which is what the holes were distributed by - see
  // sparger_holes_per_ring(). So the split the geometry was built to is the split priced here.
  _feed_v = stirred_tank_sparge_bore_velocity(gas_flow, bore, 1);
  _feed_open = stirred_tank_sparge_open_area_ratio(_total, hole_diameter, bore, 1);
  _ring_v = [
    for (i = [0:_n - 1])
      stirred_tank_sparge_bore_velocity(gas_flow * holes[i] / _total, bore, paths)
  ];
  _ring_open = [
    for (i = [0:_n - 1]) stirred_tank_sparge_open_area_ratio(holes[i], hole_diameter, bore, paths)
  ];

  // Judged on the WORST segment, because a departure names something the design violates somewhere.
  // Taken as a max rather than assumed to be the feed: it is the feed on every layout this file can
  // currently draw, but a ring fed at more points than the trunk would invert that.
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
    " mm - ", _total, " in all, at ", _v, " m/s through them"
  ));
  echo(str(
    "sparger bubbles: ", _db, " mm at formation, ", stirred_tank_bubble_rate(gas_flow, _db),
    " a second",
    is_undef(holdup)
      ? " (specific area needs a holdup)"
      : str(", giving ", stirred_tank_specific_area(holdup, _db), " 1/m of interface at ",
            holdup * 100, "% holdup")
  ));
  echo(str(
    "sparger feed run: ", bore, " mm bore at 1 path carrying ", _feed_v, " m/s; its ",
    stirred_tank_sparge_bore_head(_feed_v), " Pa of velocity head against ",
    stirred_tank_orifice_pressure(_v), " Pa at a hole, open area ratio ", _feed_open,
    " - every hole is downstream of this one bore"
  ));
  echo(str(
    "sparger rings: ", _ring_v, " m/s at ", paths, " path(s) each, open area ratio ", _ring_open,
    "; ", [for (v = _ring_v) stirred_tank_sparge_bore_head(v)], " Pa of velocity head",
    _worst_open >= 1
      ? str(" - open area reaches ", _worst_open, ", ABOVE 1, so the holes compete with their own ",
            "supply")
      : ""
  ));
  echo(str(
    "sparger envelope: r ", sparger_tube_envelope(radii, tube, 8),
    " mm, which is what has to clear the baffles and pass the mouth"
  ));
  echo(str(
    "sparger pitch: ", [for (i = [0:_n - 1]) sparger_pitch_ratio(radii[i], holes[i], hole_diameter)],
    " hole diameters between holes, against a ", sparger_pitch_ratio_floor(),
    " floor that is reasoned, not cited"
  ));
  if (len(_dep) > 0)
    echo(str("WARNING sparger: extrapolated on ", _dep));
}

// ----- example usage -----
//
// This file is an entry and must emit geometry. The numbers are jar_10L's duty put through
// utils/sparger.scad rather than typed: 8.23207 L at 0.5 vvm, sparged out to 0.95 of the
// impeller's own radius. head.scad passes its own when it drives this.
//
// They CANNOT be derived here the way the conventions ask - head.scad uses this file, so including
// it would close a cycle. Check them against head()'s echo before trusting a render.
_ex_radii = sparger_equal_area_radii(2, 90, 58); // outboard of the 56.9 port circle, so the feed crosses both
_ex_flow = 4.11604 / 60000; // m^3/s, 0.5 vvm on 8.23207 L
// 1.2 mm holes at 3 m/s. The diameter is the lever - it sets bubble size, and bubble size sets
// kLa - and 3 m/s sits mid-way in the 0.4-5.4 Barbosa actually ran. Both numbers were chosen by
// reading sparger_report() rather than by taste: 1.5 mm holes at 1.5 m/s wanted 26 of them, which
// put the open area ratio at 3.7 and made the bore compete with its own holes.
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
  // M4's tap radius, which is what set_screw_tap_radius(set_screw_m4x6_316) returns. Quoted here
  // because this file deliberately does not import the screw registry; head.scad passes the real one.
  plug_tap_radius = 1.65,
  show_fluid_path = false
);

sparger_hole_probes(
  radii = _ex_radii, holes = _ex_holes, tube = 4 + 2 * 1.2, feed_angle = 240
);

sparger_report(
  radii = _ex_radii, holes = _ex_holes, hole_diameter = 1.2, tube = 4 + 2 * 1.2, bore = 4,
  gas_flow = _ex_flow, paths = 2, holdup = 0.01 // fed at one point, so gas goes both ways round
);
