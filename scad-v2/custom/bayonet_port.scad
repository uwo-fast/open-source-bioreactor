/**
 * @file bayonet_port.scad
 * @brief Bayonet feedthrough port for a panel, with o-ring seal and mounting features
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Uses the bayonet-lock-scad library for the coupling itself and adds what a bioreactor port
 * needs around it: a flange, an o-ring seal, catch pockets and text labels.
 *
 * DATUM: z = 0 is the panel's OUTER face and +z points outward (away from the vessel). Both
 * halves are emitted in that datum, already mated, so a consumer places a complete port with
 * a single translate() to the hole centre - no flips and no stack-up arithmetic:
 *
 *      +z    _________
 *            | flange |   z = [0, flange_h]                   pin half, outside the vessel
 *       0  --|--------|--  panel OUTER face, o-ring rebate cut into this face
 *            | shank  |   z = [-panel, 0]                     pin half, through the hole
 *  -panel  --|--------|--  panel INNER face, the lock bears here
 *            |coupling|   z = [-panel-part_h, -panel]         both halves, inside the vessel
 *
 * The lock half is the same for every port, which is why the adapters in this directory only
 * build pin halves and the lid takes its locks straight from here.
 */

use <bayonet-lock-scad/bayonet_lock.scad>
include <bayonet_interfaces.scad>

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// Accessors for the registered bayonet interface (see bayonet_interfaces.scad).
//   ["name" [iface_r, shell_t, pin_r, part_h, allow], [flange_h, flange_r], [oring_cs, oring_intf], [n_pins, sweep, pin_dir, turn_dir]]
function bayonet_interface_radius(type)   = type[1][0]; // mating surface radius
function bayonet_shell_thickness(type)    = type[1][1]; // annulus thickness either side of the interface
function bayonet_pin_radius(type)         = type[1][2]; // locking pin radius
function bayonet_part_height(type)        = type[1][3]; // height of the coupling band
function bayonet_allowance(type)          = type[1][4]; // fit clearance between mating halves
function bayonet_flange_height(type)      = type[2][0]; // flange thickness (0 for no flange)
function bayonet_flange_radius(type)      = type[2][1]; // flange outer radius
function bayonet_oring_cs_diameter(type)  = type[3][0]; // o-ring cross section (undef to disable seal)
function bayonet_oring_interference(type) = type[3][1]; // o-ring squeeze; rebate depth is cs - this
function bayonet_number_of_pins(type)     = type[4][0]; // locking points around the coupling
function bayonet_sweep_angle(type)        = type[4][1]; // arc the pin travels when turning
function bayonet_pin_direction(type)      = type[4][2]; // "inner" or "outer"
function bayonet_turn_direction(type)     = type[4][3]; // "CW" or "CCW"

// Radial clearance between the panel hole and the coupling's interface radius. Sets the hole
// size and the inner edge of the o-ring rebate, and leaves the lock a bearing land of
// (shell_thickness - this) against the panel's inner face.
bayonet_port_hole_clearance = 0.5;

// The clearance hole a port needs through the panel. Big enough to pass the pin half's
// coupling band on assembly, small enough that the lock still has a face to bear on.
function bayonet_port_hole_radius(type) = bayonet_interface_radius(type) + bayonet_port_hole_clearance;

// Rotation that takes a pin half from the locked position to the entry position, i.e. pins at
// the channel mouths before the turn.
function bayonet_entry_rotation(type) =
  (bayonet_turn_direction(type) == "CW") ? -bayonet_sweep_angle(type) : bayonet_sweep_angle(type);

// Example usage (open this file directly to preview)
bayonet_port(bayonet_std, part="pin", panel_thickness=18, center_bore_radius=3, text_labels=true);

/**
 * One half of a panel feedthrough port. See the datum diagram at the top of this file.
 *
 * @param type               Registered bayonet interface (see bayonet_interfaces.scad)
 * @param part               "pin" (carries the flange, fitted from outside) or "lock"
 * @param panel_thickness    Thickness of the panel the port passes through
 * @param center_bore_radius Through-bore up the middle of the pin half; 0 for solid
 * @param entry_depth        Insertion depth before the turn; the library defaults it
 */
module bayonet_port(
  type,
  part,
  panel_thickness,
  center_bore_radius = 0,
  entry_depth = undef,
  catch_pockets = true,
  text_labels = false
) {

  // Unpack the shared bayonet interface into the scalars the body works in.
  interface_radius = bayonet_interface_radius(type);
  pin_radius = bayonet_pin_radius(type);
  part_height = bayonet_part_height(type);
  allowance = bayonet_allowance(type);
  flange_radius = bayonet_flange_radius(type);
  oring_cs_diameter = bayonet_oring_cs_diameter(type);
  oring_interference = bayonet_oring_interference(type);

  // `part`, `entry_depth` and `shell_thickness` are validated and defaulted by the library.
  assert(
    oring_cs_diameter == undef || oring_interference < oring_cs_diameter,
    "bayonet_port: oring_interference must be < oring_cs_diameter (the rebate would have no depth)"
  );

  // The flange and its seal belong to the pin half; the lock is bare coupling.
  _flange_h = (part == "lock") ? 0 : bayonet_flange_height(type);
  _oring_enabled = !is_undef(oring_cs_diameter) && part != "lock";
  _rebate_h = _oring_enabled ? oring_cs_diameter - oring_interference : 0;

  // Bottom of the coupling band, i.e. the deepest point of the whole port.
  _band_z = -panel_thickness - part_height;

  // The flange leaves a short spigot that pilots into the panel hole, so the port stays
  // centred while it is turned. Set one allowance under the hole so it is a clearance fit,
  // and cut the o-ring rebate outside it, which keeps the seal on panel material rather
  // than overhanging the hole.
  _spigot_radius = bayonet_port_hole_radius(type) - allowance;

  difference() {
    union() {

      // The coupling, sitting below the panel. Both halves are authored in one frame by the
      // library, so this same placement puts them in the locked position.
      translate([0, 0, _band_z])
        bayonet(
          half=part,
          interface_radius=interface_radius,
          shell_thickness=bayonet_shell_thickness(type),
          allowance=allowance,
          part_height=part_height,
          entry_depth=entry_depth,
          number_of_pins=bayonet_number_of_pins(type),
          pin_radius=pin_radius,
          sweep_angle=bayonet_sweep_angle(type),
          pin_direction=bayonet_pin_direction(type),
          turn_direction=bayonet_turn_direction(type)
        );

      if (part == "pin") {

        // Core: fills the middle of the coupling, then carries on up the shank through the
        // panel and into the flange.
        translate([0, 0, _band_z])
          cylinder(h=part_height + panel_thickness + _flange_h, r=interface_radius - pin_radius);

        // Flange, seating on the panel's outer face
        cylinder(h=_flange_h, r=flange_radius);
      }
    }

    // Center bore for the tube or probe. Cut against the finished body so it opens through
    // the flange as well as the core; triple-height and centered to clear both ends.
    if (part == "pin" && center_bore_radius > 0)
      cylinder(h=(part_height + panel_thickness + _flange_h) * 3, r=center_bore_radius, center=true);

    // O-ring rebate: an annular recess in the flange's panel-facing face, running from the
    // spigot out to the flange edge. The o-ring seats here and is squeezed against the
    // panel; its depth is the cross section less the interference.
    if (_rebate_h > 0) {
      translate([0, 0, -z_fight])
        difference() {
          cylinder(h=_rebate_h + z_fight, r=flange_radius + z_fight);
          cylinder(h=_rebate_h + z_fight, r=_spigot_radius);
        }
    }

    // Catch pockets (holes for pliers to grip and rotate), sunk into the outer face
    if (catch_pockets && _flange_h > 0) {
      for (i = [0:1])
        rotate([0, 0, i * 180])
          translate([interface_radius * 0.8, 0, _flange_h / 2])
            cylinder(h=_flange_h / 2 + z_fight, d=2 * interface_radius / 4);
    }

    // Text labels (radius and diameter markings), sunk into the outer face
    if (text_labels && _flange_h > 0) {

      // Radius and diameter of the center bore, marked on the flange face
      _radString = str("R", center_bore_radius);
      _diaString = str("D", center_bore_radius * 2);

      // Top (+Y) string impression
      translate([0, interface_radius * 0.8, _flange_h / 2]) {
        linear_extrude(_flange_h / 2 + z_fight)
          text(
            _radString, size=interface_radius / 2,
            halign="center", valign="center", font="sans", $fn=32
          );
      }

      // Bottom (-Y) string impression
      translate([0, -interface_radius * 0.8, _flange_h / 2]) {
        linear_extrude(_flange_h / 2 + z_fight)
          text(
            _diaString, size=interface_radius / 2,
            halign="center", valign="center", font="sans", $fn=32
          );
      }
    }
  }
}
