/**
 * @file bayonet_port.scad
 * @brief Bayonet feedthrough port for a panel, with o-ring seal and mounting features
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Uses the bayonet-lock-scad library for the coupling itself and adds a flange, an o-ring seal,
 * catch pockets and text labels around it.
 *
 * DATUM: z = 0 is the panel's OUTER face and +z points outward (away from the vessel). Both
 * halves are emitted in that datum, already mated, so a consumer places a complete port with
 * a single translate() to the hole centre - no flips and no stack-up arithmetic:
 *
 *      +z    _________
 *            | flange |   z = [0, flange_h]      pin half, outside the vessel; the o-ring
 *       0  --|--------|--  panel OUTER face      groove is cut into its underside, and the
 *            |coupling|   z = [-panel, 0]        land either side of that groove seats here
 *  -panel  --|--------|--  panel INNER face      both halves, filling the panel's thickness
 *
 * The coupling fills the hole: part_height is the panel thickness. The lock is a radial
 * interference fit into the bore (bayonet_port_hole_fudge), so it unions into the panel. The lock
 * half is the same for every port, so the adapters below only build pin halves.
 */

use <bayonet-lock-scad/bayonet_lock.scad>
use <../utils/facets.scad>
use <../utils/oring_gland.scad>
include <bayonet_interfaces.scad>
use <cylindrical_flex_collet.scad>
use <threads-scad/threads.scad>
use <../utils/dovetail.scad>
use <../purchased/atlas_probe.scad>
use <../purchased/atlas_probes.scad>
use <../utils/npt_threads.scad>

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// Accessors for the registered bayonet interface (see bayonet_interfaces.scad).
//   ["name" [iface_r, shell_t, pin_r, allow], [flange_h, flange_lip], [oring_id, oring_cs], [n_pins, sweep, pin_dir, turn_dir, key]]
function bayonet_name(type)                = type[0]; // registered name, e.g. "std"
function bayonet_interface_radius(type)   = type[1][0]; // mating surface radius
function bayonet_shell_thickness(type)    = type[1][1]; // annulus thickness either side of the interface
function bayonet_pin_radius(type)         = type[1][2]; // locking pin radius
function bayonet_allowance(type)          = type[1][3]; // fit clearance between mating halves
function bayonet_flange_height(type)      = type[2][0]; // flange thickness (0 for no flange)
function bayonet_flange_lip(type)         = type[2][1]; // material outboard of the o-ring groove
function bayonet_oring(type)              = type[3]; // registered o-ring (undef to disable the seal)
function bayonet_oring_id(type)           = oring_inner_diameter(bayonet_oring(type));
function bayonet_oring_cs_diameter(type)  = oring_cross_section(bayonet_oring(type));
function bayonet_number_of_pins(type)     = type[4][0]; // locking points around the coupling
function bayonet_sweep_angle(type)        = type[4][1]; // arc the pin travels when turning
function bayonet_pin_direction(type)      = type[4][2]; // "inner" or "outer"
function bayonet_turn_direction(type)     = type[4][3]; // "CW" or "CCW"
function bayonet_key_angle(type)          = type[4][4]; // offset keying the pins; 0 spaces them evenly

// Where this interface's pins sit; evenly spaced when unkeyed.
function bayonet_pin_angles(type) =
  bayonet_key_angle(type) == 0
    ? [for (i = [0:bayonet_number_of_pins(type) - 1]) 360 / bayonet_number_of_pins(type) * i]
    : bayonet_keyed_pin_angles(bayonet_number_of_pins(type), bayonet_key_angle(type));

// How many ways a pin half can be locked; anything oriented below the coupling needs 1.
function bayonet_seating_count(type) = bayonet_pin_pattern_order(bayonet_pin_angles(type));
function bayonet_is_keyed(type) = bayonet_seating_count(type) == 1;

// A key only blocks a wrong seating when it throws the pins clear of the channel mouths.
function bayonet_key_margin(type) = bayonet_pin_pattern_margin(bayonet_pin_angles(type));
function bayonet_key_margin_needed(type) =
  bayonet_channel_half_angle(bayonet_interface_radius(type), bayonet_pin_radius(type), bayonet_allowance(type));

// Radial interference between the lid and the bayonet lock, for a clean union
bayonet_port_hole_fudge = 0.1;

// The clearance hole a port needs through the panel.
function bayonet_port_hole_radius(type) = bayonet_interface_radius(type) + bayonet_shell_thickness(type) - bayonet_port_hole_fudge;

// The face seal, squeezed between the flange's underside and the panel's outer face; all of it
// follows from the registered ring (utils/oring_gland.scad). oring_gland_od is the sealing wall,
// so the cut is opened by an allowance or a moulded ring will not go in.
bayonet_gland_allowance = 0.2;
function bayonet_gland_outer_radius(type) =
  (oring_gland_od(bayonet_oring_id(type), bayonet_oring_cs_diameter(type)) + bayonet_gland_allowance) / 2;
function bayonet_gland_width(type) = oring_gland_width(bayonet_oring_cs_diameter(type));
function bayonet_gland_inner_radius(type) = bayonet_gland_outer_radius(type) - bayonet_gland_width(type);
function bayonet_gland_depth(type) = oring_gland_depth(bayonet_oring_cs_diameter(type));

// Material the gland below has to leave outboard of itself, inside the coupling's own wall.
bayonet_bore_gland_wall = 1;

// The rod gland, on ports a rigid tube passes up: the ring closes the annulus around the tube,
// and its ID is the tube, so the gland follows from the ring alone.
function bayonet_bore_gland_radius(ring) =
  oring_rod_gland_diameter(oring_inner_diameter(ring), oring_cross_section(ring)) / 2;
// Table A's width, used as the groove's height.
function bayonet_bore_gland_length(ring) = oring_gland_width(oring_cross_section(ring));

// Material below the groove that makes the ring captive; the ring is folded and pushed past it.
// 6 layers at 0.2 mm.
bayonet_bore_gland_lip = 1.2;

// Where the groove's centre sits, in the port's datum, so a caller can draw the ring in it.
function bayonet_bore_gland_centre(ring, panel_thickness) =
  -panel_thickness + bayonet_bore_gland_lip + bayonet_bore_gland_length(ring) / 2;

// Derived, not registered: a flange narrower than its own groove is not expressible.
function bayonet_flange_radius(type) =
  is_undef(bayonet_oring_id(type))
    ? bayonet_interface_radius(type) + bayonet_shell_thickness(type) + bayonet_flange_lip(type)
    : bayonet_gland_outer_radius(type) + bayonet_flange_lip(type);

// The two mating surfaces, the allowance split evenly. The lock bore is the gate anything hung
// below the coupling has to drop through on assembly.
function bayonet_pin_face_radius(type) = bayonet_interface_radius(type) - bayonet_allowance(type) / 2;
function bayonet_lock_bore_radius(type) = bayonet_interface_radius(type) + bayonet_allowance(type) / 2;

// Rotation from the locked position back to entry - the undo of the turn, so opposite in sign.
function bayonet_entry_rotation(type) =
  (bayonet_turn_direction(type) == "CW") ? bayonet_sweep_angle(type) : -bayonet_sweep_angle(type);

// example usage, reaching all four variants so check-mesh sees each
bayonet_port(bayonet_std, part="pin", panel_thickness=18, center_bore_radius=3, bore_oring=oring_4x1p5_epdm, text_labels=true);
translate([60, 0, 0]) bayonet_probe_port(bayonet_std, atlas_probe_by_name("pH lab g2"));
translate([120, 0, 0]) bayonet_thermocouple_port(bayonet_std, thread=npt_thread_by_name("1/2 NPT"));
translate([200, 0, 0])
  bayonet_baffle_port(bayonet_std, segments=bayonet_baffle_segments(bayonet_std, 18, 280, 170));

// A registry name as an engraved label: upper case, underscores to spaces.
function bayonet_label_text(s, i = 0) =
  i >= len(s)
    ? ""
    : str(
      s[i] == "_" ? " " : (ord(s[i]) >= 97 && ord(s[i]) <= 122) ? chr(ord(s[i]) - 32) : s[i],
      bayonet_label_text(s, i + 1)
    );

/**
 * One half of a panel feedthrough port. See the datum diagram at the top of this file.
 *
 * @param type               Registered bayonet interface (see bayonet_interfaces.scad)
 * @param part               "pin" (carries the flange, fitted from outside) or "lock"
 * @param panel_thickness    Thickness of the panel the port passes through
 * @param center_bore_radius Through-bore up the middle of the pin half; 0 for solid
 * @param bore_oring         Registered ring sealing on a rigid tube in that bore; undef for none
 * @param entry_depth        Insertion depth before the turn; the library defaults it
 * @param label              Top mark; defaults to the bore. Adapters whose real opening is
 *                           not the bore must pass their own (see bayonet_probe_port).
 */
module bayonet_port(
  type,
  part,
  panel_thickness,
  center_bore_radius = 0,
  bore_oring = undef,
  entry_depth = undef,
  catch_pockets = true,
  text_labels = false,
  label = undef,
  pins_at_locked = true
) {

  // Unpack the shared bayonet interface into the scalars the body works in.
  interface_radius = bayonet_interface_radius(type);
  pin_radius = bayonet_pin_radius(type);
  allowance = bayonet_allowance(type);
  flange_radius = bayonet_flange_radius(type);
  oring_cs_diameter = bayonet_oring_cs_diameter(type);

  // `part`, `entry_depth` and `shell_thickness` are validated and defaulted by the library.

  // The groove has to stand on the land, not straddle the opening it seals around.
  assert(
    is_undef(bayonet_oring_id(type)) || bayonet_gland_inner_radius(type) > bayonet_lock_bore_radius(type),
    str(
      "bayonet_port: a ", bayonet_oring_id(type), " x ", oring_cs_diameter, " o-ring puts the groove's",
      " inner wall at r ", bayonet_gland_inner_radius(type), ", inside the lock's ",
      bayonet_lock_bore_radius(type), " bore - the seal would sit over the opening"
    )
  );

  // The wrong ring for the port: a bore narrower than the ring's ID passes no tube, and a gland no
  // wider than the bore has no shoulder. Guarded by an if because a message is built whether or
  // not its assert fires.
  if (!is_undef(bore_oring)) {

    assert(
      center_bore_radius * 2 > oring_inner_diameter(bore_oring)
      && bayonet_bore_gland_radius(bore_oring) > center_bore_radius,
      str(
        "bayonet_port: a ", oring_inner_diameter(bore_oring), " x ", oring_cross_section(bore_oring),
        " o-ring seals on a ", oring_inner_diameter(bore_oring), " mm tube and wants a gland out to r ",
        bayonet_bore_gland_radius(bore_oring), ", against a bore of r ", center_bore_radius
      )
    );

    // The groove is enclosed, so it has to fit between the two faces.
    assert(
      bayonet_bore_gland_lip + bayonet_bore_gland_length(bore_oring) < panel_thickness,
      str(
        "bayonet_port: a ", bayonet_bore_gland_lip, " mm lip under a ",
        bayonet_bore_gland_length(bore_oring), " mm groove needs more than ", panel_thickness,
        " mm of panel - the groove would open through the outer face"
      )
    );

    assert(
      bayonet_bore_gland_radius(bore_oring) + bayonet_bore_gland_wall <= bayonet_pin_face_radius(type),
      str(
        "bayonet_port: that gland reaches r ", bayonet_bore_gland_radius(bore_oring),
        " and the coupling's wall starts at ", bayonet_pin_face_radius(type),
        " - it would leave under ", bayonet_bore_gland_wall, " mm of material"
      )
    );
  }

  // Containment and fill are not checked: width and depth both derive from the cord, so neither
  // fraction can reach its limit whatever ring is fitted.

  // Without the keying helpers the coupling renders with no pins or channels, on warnings alone.
  assert(
    !is_undef(bayonet_pin_angles(type)),
    "bayonet_port: needs bayonet-lock-scad >= 0.11.0, for pin_angles and the keying functions"
  );

  assert(
    bayonet_key_angle(type) == 0 || bayonet_key_margin(type) > bayonet_key_margin_needed(type),
    str(
      "bayonet_port: a key angle of ", bayonet_key_angle(type), " leaves a wrong seating only ",
      bayonet_key_margin(type), " degrees off the channel mouths, which are ",
      bayonet_key_margin_needed(type), " degrees wide either side - it would still go in"
    )
  );

  // The flange and its seal belong to the pin half; the lock is bare coupling.
  _flange_h = (part == "lock") ? 0 : bayonet_flange_height(type);
  _oring_enabled = !is_undef(bayonet_oring_id(type)) && part != "lock";
  _gland_h = _oring_enabled ? bayonet_gland_depth(type) : 0;

  difference() {
    union() {

      // The coupling, below the panel. The library draws both halves in the ENTRY frame, so a pin
      // half as drawn is the part as it goes in and turns by the sweep to lock - which puts any
      // oriented body (baffle, tilted probe, engraving) that many degrees off. pins_at_locked moves
      // the pins back by the sweep instead, so the body's frame is the locked one.
      translate([0, 0, -panel_thickness])
        bayonet(
          half=part,
          interface_radius=interface_radius,
          shell_thickness=bayonet_shell_thickness(type),
          allowance=allowance,
          part_height=panel_thickness,
          entry_depth=entry_depth,
          pin_angles=(part == "pin" && pins_at_locked)
            ? [for (a = bayonet_pin_angles(type)) a - bayonet_entry_rotation(type)]
            : bayonet_pin_angles(type),
          pin_radius=pin_radius,
          sweep_angle=bayonet_sweep_angle(type),
          pin_direction=bayonet_pin_direction(type),
          turn_direction=bayonet_turn_direction(type)
        );

      if (part == "pin") {

        // Core: fills the coupling and carries on up through the panel into the flange
        translate([0, 0, -panel_thickness])
          cylinder(h= panel_thickness + _flange_h, r=interface_radius - pin_radius);

        // Flange, seating on the panel's outer face
        cylinder(h=_flange_h, r=flange_radius);
      }
    }

    // Centre bore for the tube or probe, through flange and core
    if (part == "pin" && center_bore_radius > 0)
      cylinder(h=(panel_thickness + _flange_h) * 3, r=center_bore_radius, center=true);

    // Rod gland: an enclosed groove near the panel's inner face, as low as the lip allows.
    if (part == "pin" && !is_undef(bore_oring))
      translate([0, 0, -panel_thickness + bayonet_bore_gland_lip])
        cylinder(
          h=bayonet_bore_gland_length(bore_oring),
          r=bayonet_bore_gland_radius(bore_oring)
        );

    // O-ring groove in the flange's panel-facing face; the face either side lands on the panel,
    // so the squeeze is the groove's depth
    if (_gland_h > 0) {
      translate([0, 0, -z_fight])
        difference() {
          cylinder(h=_gland_h + z_fight, r=bayonet_gland_outer_radius(type));
          cylinder(h=(_gland_h + z_fight) * 3, r=bayonet_gland_inner_radius(type), center=true);
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

      _boreString = is_undef(label) ? str("\u00d8", center_bore_radius * 2) : label; // \u00d8: every font has it
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

// ----- probe port -----

// How far the collet's origin hangs below the port's underside; the tilt wedge is as deep as the
// body it carries.
function bayonet_probe_port_collet_drop(probe, transition_length) =
  transition_length + atlas_probe_body_dia(probe) / sqrt(3);

// A pin half with a flex collet hanging off the coupling, inside the vessel; the connector passes
// up through the bore. Shares bayonet_port's datum.
module bayonet_probe_port(
  type,
  probe,
  panel_thickness = 18,
  center_bore_radius = 3,
  collet_wall_thickness = 1.2,
  collet_body_allowance = 0.6,
  collet_connector_allowance = 0.6,
  collet_tab_gap = 1.0,
  collet_tab_internal_deflection = 0.5,
  tilt_degrees = 4.5,
  transition_length = 25
) {

  interface_radius = bayonet_interface_radius(type);
  allowance = bayonet_allowance(type);

  probe_body_diameter = atlas_probe_body_dia(probe);
  probe_body_length = atlas_probe_body_height(probe);

  // the collet's neck houses the probe's strain relief boot
  boot_cap_diameter = atlas_probe_neck_dia(probe);
  boot_cord_diameter = atlas_probe_neck_taper_dia(probe);
  boot_length = atlas_probe_neck_height(probe);

  // The connector passes up a hex, so size it across the flats to clear a round connector.
  _hex_diameter = (atlas_probe_connector_dia(probe) + collet_connector_allowance) / cos(30);

  // The transitions mate to the bayonet at its interface (mating) surface, less the allowance.
  _bayonet_diameter = 2 * interface_radius - allowance;
  _transition_length = bayonet_probe_port_collet_drop(probe, transition_length);

  union() {

    // Bayonet connector
    difference() {
      bayonet_port(
        type=type,
        part="pin",
        panel_thickness=panel_thickness,
        center_bore_radius=center_bore_radius,
        text_labels=true,
        // which probe the collet is cut for, not the bore
        label=str(bayonet_label_text(atlas_probe_name(probe)), " Ø", probe_body_diameter)
      );

      // Cut hexagonal hole for connector
      cylinder(h=1000, d=_hex_diameter, center=true, $fn=6);
    }

    translate([0, 0, -panel_thickness]) {

    // Tilt wedge, on the side the probe leans AWAY from - it fills the trailing gap - so it is
    // the mirror of the lean and the two flip together. The hex cut has no side.
    difference() {
      mirror([1, 0, 0])
        rotate([-90, 0, 0]) {
          rotate_extrude(angle=tilt_degrees, convexity=10)
            difference() {
              circle(d=_bayonet_diameter);
              translate([-_bayonet_diameter / 2, 0, 0])
                square([_bayonet_diameter, _bayonet_diameter * 2], center=true);
            }
        }
      cylinder(h=1000, d=_hex_diameter, center=true, $fn=6);
    }

    // Probe holder, leaning toward +X: a point L below the pivot lands at +L*sin(tilt)
    rotate([0, -tilt_degrees, 0]) {
      difference() {
        union() {
          // Transition segment with larger diameter to mate with bayonet bottom to collet tail
          translate([0, 0, -_transition_length])
            cylinder(
              h=_transition_length,
              d1=probe_body_diameter + collet_wall_thickness * 2,
              d2=_bayonet_diameter
            );

          difference() {
            // Flexible pinch clamp
            translate([0, 0, -_transition_length])
              cylindrical_flex_collet(
                body_length=probe_body_length,
                body_diameter=probe_body_diameter,
                tail_diameter_start=boot_cap_diameter,
                tail_diameter_end=boot_cord_diameter,
                tail_len=boot_length,
                end_diameter=_hex_diameter,
                shell_wall=collet_wall_thickness,
                allowance=collet_body_allowance,
                flex_tab_clearance=collet_tab_gap,
                flex_tab_offset=collet_tab_internal_deflection
              );
            cylinder(h=probe_body_length + boot_length, d=probe_body_diameter * 2);
          }
        }

        // Cut hexagonal hole for connector
        cylinder(h=1000, d=_hex_diameter, center=true, $fn=6);
      }
    }
    }
  }
}

// ----- thermocouple port -----

// A pin half with an NPT thread mount standing on the flange; the thermocouple passes down the
// bore. thread is a registered NPT thread (utils/npt_threads.scad).
module bayonet_thermocouple_port(
  type,
  panel_thickness = 18,
  center_bore_radius = 3,
  mount_height = 20,
  thread
) {
  // text_labels off: the mount covers the flange, so the marks go on the mount wall
  bayonet_port(
    type=type,
    part="pin",
    panel_thickness=panel_thickness,
    center_bore_radius=center_bore_radius
  );

  // NPT thread mount the thermocouple screws into, standing on the flange's outer face
  translate([0, 0, bayonet_flange_height(type)])
    npt_thread_mount(
      thread=thread,
      height=mount_height,
      lower_diameter=bayonet_flange_radius(type) * 2,
      marks=[
        npt_thread_name(thread), // what screws in
        str("Ø", center_bore_radius * 2), // bore the probe tip passes down
        str("B", bayonet_interface_radius(type) * 2, "-", bayonet_pin_radius(type)) // coupling
      ]
    );
}

// Text laid around a cylinder, reading from outside; difference() it out of the wall to engrave.
module wrapped_text(s, radius, size, depth, angle = 0) {
  step = 2 * asin(size * 0.8 / (2 * radius)); // angular advance per character, ~0.8 em to avoid crowding

  for (i = [0:len(s) - 1])
    rotate([0, 0, angle - (len(s) - 1) * step / 2 + i * step])
      translate([radius - depth, 0, 0])
        rotate([90, 0, 90])
          linear_extrude(depth * 2) // overshoots the surface so the cut opens cleanly
            text(s[i], size=size, halign="center", valign="center", font="sans");
}

// Wall the mount keeps outside its thread.
function npt_mount_wall() = 2;

module npt_thread_mount(thread, height, wall_thickness = npt_mount_wall(), lower_diameter = undef, marks = []) {
  major_diameter = npt_thread_major_diameter(thread);
  allowance = 0.6;
  diameter = major_diameter + wall_thickness * 2;
  lower_diameter_eff = is_undef(lower_diameter) ? diameter : lower_diameter;

  difference() {
    ScrewHole(
      outer_diam=major_diameter - allowance, // Major diameter at the hand-tight plane
      height=height * 1.1, // Depth of threading
      position=[0, 0, 0], // Center of hole
      rotation=[0, 0, 0], // Orientation
      pitch=npt_thread_pitch(thread), // from the row's TPI
      tooth_angle=60, // NPT standard thread angle
      tolerance=0.4, // Small clearance for fitting
      // scales with the pitch: a tooth taller than the pitch is self-intersecting
      tooth_height=npt_thread_pitch(thread) * 0.55
    ) cylinder(d1=lower_diameter_eff, d2=diameter, h=height);

    // Marks around the outer wall, in the upper half where the taper leaves the most material
    if (len(marks) > 0) {
      _mark_z = height * 0.65;
      _mark_r = (lower_diameter_eff + (diameter - lower_diameter_eff) * 0.65) / 2;

      for (i = [0:len(marks) - 1])
        translate([0, 0, _mark_z])
          wrapped_text(
            marks[i], radius=_mark_r, size=3.5, depth=0.8,
            angle=i * 360 / len(marks)
          );
    }
  }
}

// ----- baffle port -----

// Widest plate that will still install, from its half diagonal against the lock's bore.
function bayonet_baffle_width(type, thickness, bore_clearance) =
  let (_bore = bayonet_lock_bore_radius(type) - bore_clearance)
    assert(
      thickness < _bore * 2,
      str("bayonet_baffle_width: a ", thickness, " mm plate will not pass a bore of ", _bore, " mm radius")
    ) // here, not at the call sites: a thicker plate makes the radicand negative and nan is silent
    2 * sqrt(pow(_bore, 2) - pow(thickness / 2, 2));

// Height the port itself adds above the plate, which counts against the first piece.
function bayonet_baffle_stack_height(type, panel_thickness) =
  bayonet_flange_height(type) + panel_thickness;

// How many equal pieces a plate of this length prints in, standing in the port's axis, with the
// port's stack counting against the first.
function bayonet_baffle_segments(type, panel_thickness, length, height_max) =
  let (_stack = bayonet_baffle_stack_height(type, panel_thickness))
    assert(
      height_max > _stack,
      str("bayonet_baffle_segments: ", height_max, " mm of bed height cannot take the port's own ", _stack, " mm")
    )
    ceil(length / (height_max - _stack));

// The dovetail's crown, from the wall the socket keeps outboard of it on each face.
function bayonet_baffle_joint_crown(thickness, lip) = thickness - 2 * lip;

// How deep the tail runs, from the neck wanted at the joint plane - the neck is the only material
// crossing the plane, so it is the parameter and the depth follows.
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
  panel_thickness = 18,
  length = 280,
  thickness = 9,
  transition_height = 10,
  bore_clearance = 0.2,
  joint_lip = 1.6,
  joint_neck = 4.2,
  joint_flare = 10,
  joint_allowance = 0.1,
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
  // The root's arc is sunk below the joint plane so the plane cuts straight flank and the neck
  // measures what it is meant to.
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

  // The slab the plate starts at; both hulls span from it so they meet on a solid
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

    // The plate, rounded off over the last _round so there is no edge to trap growth
    hull() {
      _plate_top();

      for (sx = [-1, 1])
        translate([sx * (_width / 2 - _round), 0, -length + _round])
          sphere(r=_round, $fn=32);
    }
  }

  // The tail at joint j, crown across the thickness, extruded along the width from -x to _stop
  // short of +x
  module _dovetail_at(j, allowance, run)
    translate([-_width / 2 - allowance, 0, -j * _seg - _sink])
      rotate([90, 0, 90])
        dovetail(_crown, _depth + _sink, run, allowance=allowance, root_width=_poly_root, crown_radius=_corner);

  // The z band piece i occupies, open past both ends of the plate
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
