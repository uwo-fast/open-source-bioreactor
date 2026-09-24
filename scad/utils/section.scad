/**
 * @file section.scad
 * @brief Cut a model open on a wedge, to see inside it
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description A viewing aid. It removes a wedge about an axis and leaves the rest, so a half is
 * the usual cross section, three quarters is the quarter-removed view an assembly drawing uses,
 * and a quarter leaves the wedge itself.
 *
 * The cut is a boolean, so it belongs to the preview and not to anything exported: a part written
 * to STL with a wedge missing is silently wrong, and nothing downstream can tell. `active` is a
 * parameter rather than a `$preview` test inside, because a module that quietly does nothing on a
 * render is the kind of thing that is only noticed once a part is printed. The caller decides, and
 * the caller is the one that knows whether it is drawing a picture or a part.
 *
 * A model that sections itself is cheaper than one that is cut - a revolved shape can simply be
 * revolved less far - but only about its own axis and only from where its sweep starts. Where both
 * are in one scene they have to agree: the sector kept here runs from `turn` to
 * `turn + keep * 360`, which at `turn = 0` is what `rotate_extrude(angle = keep * 360)` leaves.
 */

/**
 * @brief Keep a sector of the children and remove the rest.
 * @param keep   The fraction that survives, 0 to 1. 0.5 is a half, 0.75 removes a quarter.
 * @param axis   Which way the wedge's spine points: "x", "y" or "z".
 * @param turn   Where the kept sector starts, in degrees about that axis.
 * @param size   How far the cutter reaches. Anything past the model's extent will do; it is
 *               required rather than defaulted because a cutter that is too small quietly cuts
 *               nothing, which looks exactly like a model with nothing inside it.
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
      // Turned so the wedge starts where the kept sector ends, then swept the rest of the way
      // round. The profile touches the rotation axis, which is what lets it reach the middle.
      rotate(axis == "x" ? [0, 90, 0] : axis == "y" ? [-90, 0, 0] : [0, 0, 0])
        rotate([0, 0, turn + keep * 360])
          rotate_extrude(angle = 360 - keep * 360, convexity = 10)
            translate([0, -size])
              square([size, size * 2]);
    }
}
