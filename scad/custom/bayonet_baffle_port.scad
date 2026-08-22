/**
 * @file bayonet_baffle_port.scad
 * @brief Swirl baffle hung from a bayonet port
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A baffle is a flat plate standing in a plane through the vessel's axis. It is perpendicular to
 * the tangential swirl the impeller drags round with it, not to the axial flow, and it is that
 * swirl it trips back into the top-to-bottom circulation the impeller is trying to make.
 *
 * The standard arrangement is four plates at 90 degrees, T/10 to T/12 of the vessel diameter wide,
 * set about T/72 off the wall. Whether a vessel entered through a port ring can get anywhere near
 * that is the vessel's business, not this file's; see the caller.
 * https://myengineeringtools.com/references/pages/baffle_width_and_number_calculation.html
 */

use <bayonet_port.scad>
include <bayonet_interfaces.scad>

$fn = $preview ? 64 : 128;

_bb_panel_thickness = 18; // Lid thickness at the port, for standalone preview

// ----- Design parameters -----
// Nothing here sets the plate's width. It has to drop through the bore of the lock it hangs from,
// so that bore and the plate's own thickness settle it; see bayonet_baffle_width().

_bb_length = 100; // How far the plate hangs below the port's bottom face
_bb_thickness = 4; // Plate thickness; also sets how far the bottom rounds off
_bb_transition_height = 10; // Height the port's round face blends out into the plate over
_bb_bore_clearance = 0.2; // Clearance to the lock's bore as the plate drops through it

bayonet_baffle_port(
  type=bayonet_std,
  panel_thickness=_bb_panel_thickness,
  length=_bb_length,
  thickness=_bb_thickness,
  transition_height=_bb_transition_height,
  bore_clearance=_bb_bore_clearance
);

// ----- build -----
// This is a pin half by definition - the lock half is the same for every port, so the lid takes it
// straight from bayonet_port(). Shares bayonet_port's datum: the plate hangs off the bottom of the
// coupling, inside the vessel, and nothing passes up through the bore.

/**
 * @brief Widest plate that will still install, from its half diagonal against the lock's bore.
 *
 * Derived rather than chosen, so a width that cannot be assembled is not expressible. Callers that
 * need the number, to check it against the vessel it hangs in, read it back from here.
 *
 * @param type           Registered bayonet interface (see bayonet_interfaces.scad)
 * @param thickness      Plate thickness
 * @param bore_clearance Clearance held against the lock's bore
 * @return Plate width
 */
function bayonet_baffle_width(type, thickness, bore_clearance) =
  let (_bore = bayonet_lock_bore_radius(type) - bore_clearance)
    assert(
      thickness < _bore * 2,
      str("bayonet_baffle_width: a ", thickness, " mm plate will not pass a bore of ", _bore, " mm radius")
    ) // checked here, not at the call sites: a thicker plate makes the radicand negative and nan
    // propagates silently into whatever the caller measures next
    2 * sqrt(pow(_bore, 2) - pow(thickness / 2, 2));

/**
 * @brief Swirl baffle on a bayonet pin half.
 *
 * @param type              Registered bayonet interface (see bayonet_interfaces.scad)
 * @param panel_thickness   Thickness of the lid the port passes through
 * @param length            How far the plate hangs below the port's bottom face
 * @param thickness         Plate thickness; also sets how far the bottom rounds off
 * @param transition_height Height the port's round face blends out into the plate over
 * @param bore_clearance    Clearance to the lock's bore as the plate drops through it
 * @param width             Plate width; defaults to the widest the bore will pass. Narrower is
 *                          allowed because what the plate has to clear inside the vessel is not
 *                          this module's business, and wider cannot be assembled.
 */
module bayonet_baffle_port(
  type,
  panel_thickness,
  length,
  thickness,
  transition_height,
  bore_clearance,
  width = undef
) {
  _bore_width = bayonet_baffle_width(type, thickness, bore_clearance); // asserts the plate passes the bore
  _width = is_undef(width) ? _bore_width : width;

  assert(
    _width <= _bore_width,
    str("bayonet_baffle_port: a ", _width, " mm plate will not pass its lock; ", _bore_width, " mm is the widest that does")
  );
  _round = thickness / 2; // the most the bottom can round without thinning the plate
  _face_radius = bayonet_pin_face_radius(type);
  _seat = 0.01; // a real, if tiny, slice at that face so the hull has something to span from

  bayonet_port(
    type=type,
    part="pin",
    panel_thickness=panel_thickness,
    center_bore_radius=0,
    text_labels=true,
    // Not the bore, which is nothing on a blind port. What tells one of these from another is how
    // far the plate hangs, since they get printed progressively longer until one goes floppy.
    label=str("BAFF L", length)
  );

  // The slab the plate starts at. Both hulls below span from it, so they meet on a solid rather
  // than on a shared face, and neither can taper past it into the other's business.
  module _plate_top()
    translate([-_width / 2, -thickness / 2, -transition_height])
      cube([_width, thickness, _seat]);

  translate([0, 0, -panel_thickness]) {

    // blend the port's round face out to the plate's section, over the transition height only
    hull() {
      cylinder(h=_seat, r=_face_radius);
      _plate_top();
    }

    // The plate. The spheres' extremes land on its own faces, so the section stays constant the
    // whole way down and only the last _round of it rounds off, leaving no edge to trap growth.
    hull() {
      _plate_top();

      // $fn local to the spheres: at this radius the file default is a 0.05 mm facet, far below
      // anything a nozzle can lay down, and six of them at that resolution dominate the render
      for (sx = [-1, 1])
        translate([sx * (_width / 2 - _round), 0, -length + _round])
          sphere(r=_round, $fn=32);
    }
  }
}
