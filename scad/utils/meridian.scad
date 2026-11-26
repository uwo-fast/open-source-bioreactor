/**
 * @file meridian.scad
 * @brief Clearance checks between hardware hanging from the lid and parts rotating on the shaft.
 *
 * The obstructions in the vessel are AXISYMMETRIC, so this is arithmetic rather than solid
 * modelling. An impeller sweeps a full circle, so it occupies a cylinder and the blade angle is
 * irrelevant. A sparge ring is a circle, so it occupies an annulus. Neither depends on the azimuth
 * of a probe.
 *
 * A probe tilts only radially (the port tilts it within the plane containing its own axis), so it
 * stays in its meridian plane. The check therefore reduces to the (radius, height) half-plane with
 * no loss of information: over the heights the obstacle occupies, where is the probe?
 *
 * A RUN is a straight length of hanging hardware in that half-plane: [[r, z], [r, z], radius],
 * where radius is about its own axis. An OBSTACLE is an annulus: [r_inner, r_outer, z_low, z_high].
 *
 * NOT covered, because they are not axisymmetric: baffles, which stand at four angles, and the
 * sparger feed arm and support tubes, which stand at their own angles. Those need their azimuth,
 * which the meridian discards. Treating the ring as a full annulus is conservative for the ring
 * itself, which is what is wanted here.
 */

// Radius of a run axis at a given height. The run is straight, so this is a linear interpolation;
// it is only called for heights the run spans.
function meridian_radius_at(run, z) =
  let (_a = run[0], _b = run[1])
    _a[1] == _b[1]
      ? min(_a[0], _b[0])
      : _a[0] + (_b[0] - _a[0]) * (z - _a[1]) / (_b[1] - _a[1]);

// Range of radii the run AXIS covers between two heights, or undef if the run does not reach them.
// Radius is monotonic in height along a straight run, so the ends of the clipped span bound it.
function meridian_radii_between(run, z_low, z_high) =
  let (
    _lo = max(z_low, min(run[0][1], run[1][1])),
    _hi = min(z_high, max(run[0][1], run[1][1]))
  )
    _lo > _hi
      ? undef
      : let (_p = meridian_radius_at(run, _lo), _q = meridian_radius_at(run, _hi))
        [min(_p, _q), max(_p, _q)];

// Radial half-width of a run about its axis. The horizontal section of a tilted cylinder is an
// ellipse, so this is radius / cos(tilt), with the ratio taken from the two run end points.
function meridian_half_width(run) =
  let (_dr = run[1][0] - run[0][0], _dz = run[1][1] - run[0][1])
    _dz == 0 ? undef : run[2] * norm([_dr, _dz]) / abs(_dz);

// Maximum radius of a run, which must pass through the jar neck during insertion.
function meridian_max_radius(run) =
  max(run[0][0], run[1][0]) + meridian_half_width(run);

// Maximum radius of a run between two heights, or undef if the run does not reach them. An
// axisymmetric part outside the run must clear this radius over those heights.
function meridian_max_radius_between(run, z_low, z_high) =
  let (_band = meridian_radii_between(run, z_low, z_high))
    is_undef(_band) ? undef : _band[1] + meridian_half_width(run);

// Radial gap between a run and an axisymmetric obstacle over their common heights: positive is
// clearance, negative is interference, undef when they share no height.
function meridian_clearance(run, obstacle) =
  let (_band = meridian_radii_between(run, obstacle[2], obstacle[3]))
    is_undef(_band)
      ? undef
      : let (
        _w = meridian_half_width(run),
        _lo = _band[0] - _w,
        _hi = _band[1] + _w
      )
        _lo >= obstacle[1]
          ? _lo - obstacle[1] // clear, outside the obstacle
          : _hi <= obstacle[0]
            ? obstacle[0] - _hi // clear, inside the obstacle
            : -(min(_hi, obstacle[1]) - max(_lo, obstacle[0])); // overlap depth
