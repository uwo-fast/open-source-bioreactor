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
 *
 * A plate that hangs to a tall jar's floor is longer than a printer will stand, so it splits into
 * equal pieces joined by a sliding dovetail. The slide is along the plate's WIDTH, its longer
 * horizontal axis, and that is a load choice rather than a shape one: the swirl pushes on the
 * plate's face, so the working load bears on the dovetail's flanks and the one axis the joint
 * leaves free carries nothing but vibration. A blind end stops the slide and registers the pieces.
 */

use <bayonet_port.scad>
use <../utils/dovetail.scad>
include <bayonet_interfaces.scad>

$fn = $preview ? 64 : 128;

_bb_panel_thickness = 18; // Lid thickness at the port, for standalone preview

// ----- Design parameters -----
// Nothing here sets the plate's width. It has to drop through the bore of the lock it hangs from,
// so that bore and the plate's own thickness settle it; see bayonet_baffle_width().

_bb_length = 280; // How far the plate hangs below the port's bottom face - the 10 L jar's, so this preview splits
_bb_thickness = 9; // Plate thickness; also sets how far the bottom rounds off
_bb_transition_height = 10; // Height the port's round face blends out into the plate over
_bb_bore_clearance = 0.2; // Clearance to the lock's bore as the plate drops through it

// The joint. See bayonet_baffle_joint_depth() for how the first three settle the tail.
_bb_joint_lip = 1.6; // Material outboard of the socket, each side, across the plate's thickness
_bb_joint_neck = 4.2; // Material left crossing the joint plane, across the plate's thickness
_bb_joint_flare = 10; // Dovetail flare off vertical, degrees
_bb_joint_allowance = 0.1; // Slide fit between tail and socket
_bb_height_max = 170; // Tallest a piece may stand on the bed

bayonet_baffle_port(
  type=bayonet_std,
  panel_thickness=_bb_panel_thickness,
  length=_bb_length,
  thickness=_bb_thickness,
  transition_height=_bb_transition_height,
  bore_clearance=_bb_bore_clearance,
  joint_lip=_bb_joint_lip,
  joint_neck=_bb_joint_neck,
  joint_flare=_bb_joint_flare,
  joint_allowance=_bb_joint_allowance,
  segments=bayonet_baffle_segments(bayonet_std, _bb_panel_thickness, _bb_length, _bb_height_max)
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
 * @brief Height the port itself adds above the plate, which counts against the first piece.
 * @param type            Registered bayonet interface (see bayonet_interfaces.scad)
 * @param panel_thickness Thickness of the lid the port passes through
 */
function bayonet_baffle_stack_height(type, panel_thickness) =
  bayonet_flange_height(type) + panel_thickness;

/**
 * @brief How many pieces a plate of this length has to print in.
 *
 * The part stands on the bed in the port's own axis - the flange, the o-ring groove and the pins
 * all want that - so it is the printer's Z that bounds it and the port's stack counts against the
 * first piece. Equal pieces, which is what makes every middle one the same part.
 *
 * @param type            Registered bayonet interface (see bayonet_interfaces.scad)
 * @param panel_thickness Thickness of the lid the port passes through
 * @param length          How far the plate hangs below the port's bottom face
 * @param height_max      Tallest a piece may stand on the bed
 */
function bayonet_baffle_segments(type, panel_thickness, length, height_max) =
  let (_stack = bayonet_baffle_stack_height(type, panel_thickness))
    assert(
      height_max > _stack,
      str("bayonet_baffle_segments: ", height_max, " mm of bed height cannot take the port's own ", _stack, " mm")
    )
    ceil(length / (height_max - _stack));

// The dovetail's crown, from the wall the socket keeps outboard of it on each face.
function bayonet_baffle_joint_crown(thickness, lip) = thickness - 2 * lip;

/**
 * @brief How deep the tail runs, from the neck wanted at the joint plane.
 *
 * The neck is the parameter rather than the depth because the neck is the mechanics: it is the only
 * material crossing the joint plane, so it is what carries the plate below and what the section
 * modulus there is built on. Depth follows from it once the flare is chosen, and a shallow flare is
 * what buys engagement without eating the neck.
 *
 * @param thickness Plate thickness
 * @param lip       Material outboard of the socket, each side
 * @param neck      Material left crossing the joint plane
 * @param flare     Dovetail flare off vertical, degrees
 */
function bayonet_baffle_joint_depth(thickness, lip, neck, flare) =
  (bayonet_baffle_joint_crown(thickness, lip) - neck) / (2 * tan(flare));

/**
 * @brief Swirl baffle on a bayonet pin half.
 *
 * @param type              Registered bayonet interface (see bayonet_interfaces.scad)
 * @param panel_thickness   Thickness of the lid the port passes through
 * @param length            How far the plate hangs below the port's bottom face
 * @param thickness         Plate thickness; also sets how far the bottom rounds off
 * @param transition_height Height the port's round face blends out into the plate over
 * @param bore_clearance    Clearance to the lock's bore as the plate drops through it
 * @param joint_lip         Material outboard of the socket, each side, across the thickness
 * @param joint_neck        Material left crossing the joint plane, across the thickness
 * @param joint_flare       Dovetail flare off vertical, degrees
 * @param joint_allowance   Slide fit between tail and socket
 * @param segments          How many pieces the plate prints in; see bayonet_baffle_segments()
 * @param segment           Which piece to emit, 0 at the port. undef emits them all, interlocked,
 *                          which is the assembled part - one piece is what goes on a bed.
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
  joint_lip,
  joint_neck,
  joint_flare,
  joint_allowance,
  segments = 1,
  segment = undef,
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

  // ----- the split -----
  _seg = length / segments; // equal, so every piece between the port and the tip is the same part
  _crown = bayonet_baffle_joint_crown(thickness, joint_lip);
  _depth = bayonet_baffle_joint_depth(thickness, joint_lip, joint_neck, joint_flare);
  _stop = joint_lip; // blind end wall, the same wall the lips keep
  _tail_run = _width - _stop - joint_allowance;
  // Corner arcs, and how far the root's arc is sunk below the joint plane. Sinking it is what makes
  // the neck the neck: swept corners at the root would set the tail back where it meets the face,
  // and the section crossing the plane measured 2.65 mm of a nominal 4.2 before this. Buried, the
  // plane cuts straight flank, and the arc becomes a fillet inside the solid below it.
  _corner = 0.4; // one nozzle width - finer than a printer resolves, coarse enough to break the edge
  _sink = 2 * _corner;
  _poly_root = joint_neck - 2 * _sink * tan(joint_flare); // so the plane, not the polygon, carries the neck

  assert(
    joint_neck > 0 && joint_neck < _crown,
    str("bayonet_baffle_port: a ", joint_neck, " mm neck has no dovetail in a ", _crown, " mm crown")
  );
  assert(
    _tail_run > 0,
    str("bayonet_baffle_port: a ", _width, " mm plate leaves no room to slide a tail past a ", _stop, " mm stop")
  );
  // A joint inside the transition has no plate section to cut into, and one inside the rounded tip
  // has no full section either.
  assert(
    segments == 1 || (_seg > transition_height + _depth && _seg > _round),
    str("bayonet_baffle_port: ", segments, " pieces put a joint every ", _seg, " mm, which is inside the plate's ends")
  );
  assert(
    is_undef(segment) || (segment >= 0 && segment < segments),
    str("bayonet_baffle_port: there is no piece ", segment, " of ", segments)
  );

  _pieces = is_undef(segment) ? [for (i = [0:segments - 1]) i] : [segment];

  // The port rides on the first piece; the rest are plate and joint only.
  if (is_undef(segment) || segment == 0)
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

  // The whole plate, before it is cut into pieces.
  module _hanging() {
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

  // The tail at joint j, standing up off the piece below it into the socket of the piece above.
  // Rotated so the dovetail's crown lies across the plate's thickness and it extrudes along the
  // width, entering from -x and stopping _stop short of +x.
  module _dovetail_at(j, allowance, run)
    translate([-_width / 2 - allowance, 0, -j * _seg - _sink])
      rotate([90, 0, 90])
        dovetail(_crown, _depth + _sink, run, allowance=allowance, root_width=_poly_root, crown_radius=_corner);

  // The z band piece i occupies. Open at the port end and past the tip, so the plate's own ends
  // bound it rather than this.
  module _slab(i) {
    _hi = i == 0 ? _seat + 1 : -i * _seg;
    _lo = i == segments - 1 ? -length - 1 : -(i + 1) * _seg;
    _r = max(_width, 2 * _face_radius) + 2;
    translate([-_r, -_r, _lo]) cube([2 * _r, 2 * _r, _hi - _lo]);
  }

  module _piece(i) {
    difference() {
      union() {
        intersection() {
          _hanging();
          _slab(i);
        }
        if (i > 0) _dovetail_at(i, 0, _tail_run); // its own tail, on top
      }
      if (i < segments - 1) _dovetail_at(i + 1, joint_allowance, _width - _stop + joint_allowance);
    }
  }

  translate([0, 0, -panel_thickness])
    for (i = _pieces) _piece(i);
}
