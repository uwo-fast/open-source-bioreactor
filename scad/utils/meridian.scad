/**
 * @file meridian.scad
 * @brief Does something hanging from the lid clear something turning on the shaft?
 *
 * The vessel's obstructions are AXISYMMETRIC, and that is what makes this arithmetic rather than
 * solid modelling. An impeller sweeps a full circle, so the space it claims is a cylinder and a
 * blade's angle is irrelevant; a sparge ring IS a circle, so it claims an annulus. Neither cares
 * what azimuth a probe hangs at.
 *
 * A probe's tilt is purely radial - the port leans it within the plane its own axis lies in - so it
 * never leaves its meridian either. So the whole question collapses into the (radius, height)
 * half-plane with nothing lost, and it collapses into the sentence a person would use: over the
 * heights the obstacle occupies, where is the probe?
 *
 * A RUN is a straight length of hanging hardware in that half-plane: [[r, z], [r, z], radius],
 * where radius is about its own axis. An OBSTACLE is an annulus: [r_inner, r_outer, z_low, z_high].
 *
 * What this does NOT cover, because neither is axisymmetric: baffles, which stand at four angles,
 * and the sparger's feed arm and support tubes, which stand at their own. Those want the azimuth
 * they are at, and a meridian has thrown it away. Treating the ring as a full annulus is
 * conservative for the ring itself, which is what is wanted here.
 */

// Where a run's axis sits at a given height. Straight, so this is a plain interpolation, and it is
// only asked about heights the run actually spans.
function meridian_radius_at(run, z) =
  let (_a = run[0], _b = run[1])
    _a[1] == _b[1]
      ? min(_a[0], _b[0])
      : _a[0] + (_b[0] - _a[0]) * (z - _a[1]) / (_b[1] - _a[1]);

// The radii a run's AXIS covers between two heights, or undef where it never gets there. Radius is
// monotonic in height along a straight run, so the ends of the clipped span bracket it.
function meridian_radii_between(run, z_low, z_high) =
  let (
    _lo = max(z_low, min(run[0][1], run[1][1])),
    _hi = min(z_high, max(run[0][1], run[1][1]))
  )
    _lo > _hi
      ? undef
      : let (_p = meridian_radius_at(run, _lo), _q = meridian_radius_at(run, _hi))
        [min(_p, _q), max(_p, _q)];

// How far a run reaches either side of its axis MEASURED RADIALLY, which is not its radius unless
// it hangs straight. Cut a leaning cylinder with a horizontal plane and the section is an ellipse
// whose long axis lies in the lean, so the radial half-width is radius / cos(lean) - the run's own
// two ends give that ratio as length over rise. Small at the angles a port leans, and exact.
function meridian_half_width(run) =
  let (_dr = run[1][0] - run[0][0], _dz = run[1][1] - run[0][1])
    _dz == 0 ? undef : run[2] * norm([_dr, _dz]) / abs(_dz);

// The widest a run ever gets. Not where it ends up - what has to pass the jar's NECK is the widest
// point of the whole hanging assembly, because the lid descends through it and every part of the
// assembly is level with the neck at some moment on the way down.
function meridian_max_radius(run) =
  max(run[0][0], run[1][0]) + meridian_half_width(run);

/**
 * @brief Radial gap between a run and an axisymmetric obstacle, over the heights they share.
 *
 * Positive is clearance and negative is interference, the number being how far they overlap
 * radially either way. undef when the two never share a height at all - which is not a large
 * clearance and should not be reported as one, because nothing about the radii was compared.
 */
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
          ? _lo - obstacle[1] // clear outboard of it
          : _hi <= obstacle[0]
            ? obstacle[0] - _hi // clear inboard of it
            : -(min(_hi, obstacle[1]) - max(_lo, obstacle[0])); // through it, by this much
