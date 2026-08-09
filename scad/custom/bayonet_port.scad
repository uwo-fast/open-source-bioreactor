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

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size, not by a flat segment count. The coupling mixes a 12.5 mm
// shell with 1.2 mm locking pins, and a flat $fn spends the same 128 segments on both -
// a 0.06 mm chord on the pins, far finer than anything printable, and the cost of those
// spheres dominates the CGAL render. $fs holds the chord length instead, so the shell keeps
// its resolution and the small features get what they actually need. $fn must be 0 or it
// would take precedence over $fa/$fs, including a value inherited from a caller.
$fn = 0;
$fa = $preview ? 6 : 2;
$fs = $preview ? 1.2 : 0.6;

// Accessors for the registered bayonet interface (see bayonet_interfaces.scad).
//   ["name" [iface_r, shell_t, pin_r, part_h, allow], [flange_h, flange_r], [oring_cs, oring_intf], [n_pins, sweep, pin_dir, turn_dir]]
function bayonet_interface_radius(type)   = type[1][0]; // mating surface radius
function bayonet_shell_thickness(type)    = type[1][1]; // annulus thickness either side of the interface
function bayonet_pin_radius(type)         = type[1][2]; // locking pin radius
function bayonet_allowance(type)          = type[1][3]; // fit clearance between mating halves
function bayonet_flange_height(type)      = type[2][0]; // flange thickness (0 for no flange)
function bayonet_flange_radius(type)      = type[2][1]; // flange outer radius
function bayonet_oring_cs_diameter(type)  = type[3][0]; // o-ring cross section (undef to disable seal)
function bayonet_oring_interference(type) = type[3][1]; // o-ring squeeze; rebate depth is cs - this
function bayonet_number_of_pins(type)     = type[4][0]; // locking points around the coupling
function bayonet_sweep_angle(type)        = type[4][1]; // arc the pin travels when turning
function bayonet_pin_direction(type)      = type[4][2]; // "inner" or "outer"
function bayonet_turn_direction(type)     = type[4][3]; // "CW" or "CCW"

// Radial interference between the lid and the bayonet  
// lock to ensure a clean union without any gaps
bayonet_port_hole_fudge = 0.1;

// The clearance hole a port needs through the panel. Big enough to pass the pin half's
// coupling band on assembly, small enough that the lock still has a face to bear on.
function bayonet_port_hole_radius(type) = bayonet_interface_radius(type) + bayonet_shell_thickness(type) - bayonet_port_hole_fudge;

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
 * @param label              Top mark; defaults to the bore. Adapters whose real opening is
 *                           not the bore must pass their own (see bayonet_probe_port).
 */
module bayonet_port(
  type,
  part,
  panel_thickness,
  center_bore_radius = 0,
  entry_depth = undef,
  catch_pockets = true,
  text_labels = false,
  label = undef
) {

  // Unpack the shared bayonet interface into the scalars the body works in.
  interface_radius = bayonet_interface_radius(type);
  pin_radius = bayonet_pin_radius(type);
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

  difference() {
    union() {

      // The coupling, sitting below the panel. Both halves are authored in one frame by the
      // library, so this same placement puts them in the locked position.
      translate([0, 0, -panel_thickness])
        bayonet(
          half=part,
          interface_radius=interface_radius,
          shell_thickness=bayonet_shell_thickness(type),
          allowance=allowance,
          part_height=panel_thickness,
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
        translate([0, 0, -panel_thickness])
          cylinder(h= panel_thickness + _flange_h, r=interface_radius - pin_radius);

        // Flange, seating on the panel's outer face
        cylinder(h=_flange_h, r=flange_radius);
      }
    }

    // Center bore for the tube or probe. Cut against the finished body so it opens through
    // the flange as well as the core; triple-height and centered to clear both ends.
    if (part == "pin" && center_bore_radius > 0)
      cylinder(h=(panel_thickness + _flange_h) * 3, r=center_bore_radius, center=true);

    // O-ring rebate: an annular recess in the flange's panel-facing face
    if (_rebate_h > 0) {
      translate([0, 0, -z_fight])
      difference(){
          cylinder(h=_rebate_h , r=flange_radius + z_fight);
          cylinder(h=_rebate_h + z_fight, r=interface_radius - allowance);
          }
        
    }

    // Catch pockets (holes for pliers to grip and rotate), sunk into the outer face
    if (catch_pockets && _flange_h > 0) {
      for (i = [0:1])
        rotate([0, 0, i * 180])
          translate([interface_radius * 0.8, 0, _flange_h / 2])
            cylinder(h=_flange_h / 2 + z_fight, d=2 * interface_radius / 4);
    }

    // Text labels, sunk into the outer face
    if (text_labels && _flange_h > 0) {

      _boreString = is_undef(label) ? str("\u00d8", center_bore_radius * 2) : label; // \u00d8, not \u2300: every font has it
      _specString = str("B", interface_radius * 2, "-", pin_radius); // interface dia - pin r

      _engrave_depth = 0.6; // 3 layers at 0.2, 2 at 0.3

      // Shrink long labels so they stay inside the flange.
      _boreSize = min(interface_radius * 0.40, flange_radius * 2.0 / len(_boreString));
      _specSize = min(interface_radius / 3, flange_radius * 2.0 / len(_specString));

      translate([0, interface_radius * 0.7, _flange_h - _engrave_depth]) {
        linear_extrude(_engrave_depth + z_fight)
          text(
            _boreString, size=_boreSize,
            halign="center", valign="center", font="sans"
          );
      }

      translate([0, -interface_radius * 0.7, _flange_h - _engrave_depth]) {
        linear_extrude(_engrave_depth + z_fight)
          text(
            _specString, size=_specSize,
            halign="center", valign="center", font="sans"
          );
      }
      
    }
  }
}
