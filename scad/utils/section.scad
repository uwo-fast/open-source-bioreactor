/**
 * @file section.scad
 * @brief Cut a wedge out of a model to show the inside
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description A viewing aid. It removes a wedge about an axis and keeps the rest. Keeping a half
 * gives the usual cross section, three quarters gives the quarter-removed view used in assembly
 * drawings, and a quarter keeps only a wedge.
 *
 * The cut is a boolean, so it is for previews only, not exports. A part exported to STL with a
 * wedge missing is wrong, and nothing downstream can detect it. `active` is a parameter rather
 * than an internal `$preview` test, because a module that silently does nothing on a render is
 * usually noticed only after a part is printed. The caller knows whether it is drawing a picture
 * or a part, so the caller decides.
 *
 * Sectioning a model directly is cheaper than cutting it (a revolved shape can be revolved through
 * a smaller angle), but only about its own axis and only from where its sweep starts. When both
 * methods are used in one scene they must match: the sector kept here runs from `turn` to
 * `turn + keep * 360`, which at `turn = 0` matches `rotate_extrude(angle = keep * 360)`.
 */

/**
 * @brief Keep a sector of the children and remove the rest.
 * @param keep   The fraction kept, 0 to 1. 0.5 keeps half, 0.75 removes a quarter.
 * @param axis   Axis of the wedge: "x", "y" or "z".
 * @param turn   Start angle of the kept sector, in degrees about that axis.
 * @param size   Reach of the cutter. Any value beyond the model extent works. It is required
 *               rather than defaulted because a cutter that is too small silently cuts nothing,
 *               which looks the same as a model with nothing inside.
 * @param active False passes the children through untouched.
 */
module section(keep = 0.5, axis = "z", turn = 0, size = undef, active = true) {
  assert(
    !is_undef(size),
    "section: give size - how far the cutter has to reach to clear the model"
  );
  assert(
    keep > 0 && keep <= 1,
    str("section: keep is the fraction left behind, 0 to 1, got: ", keep)
  );
  assert(
    axis == "x" || axis == "y" || axis == "z",
    str("section: axis must be \"x\", \"y\" or \"z\", got: ", axis)
  );

  // keep == 1 removes nothing, and a zero-angle rotate_extrude is degenerate rather than empty.
  if (!active || keep == 1)
    children();
  else
    difference() {
      children();
      // Rotated so the wedge starts where the kept sector ends, then swept the rest of the way
      // around. The profile touches the rotation axis, so the cut reaches the centre.
      rotate(axis == "x" ? [0, 90, 0] : axis == "y" ? [-90, 0, 0] : [0, 0, 0])
        rotate([0, 0, turn + keep * 360])
          rotate_extrude(angle = 360 - keep * 360, convexity = 10)
            translate([0, -size])
              square([size, size * 2]);
    }
}
