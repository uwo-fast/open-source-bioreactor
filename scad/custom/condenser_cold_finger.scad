/**
 * @file condenser_cold_finger.scad
 * @brief Cold-finger exhaust condenser, one piece or with a removable well
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Exhaust rises from the funnel up the annulus between a shell and a well hung down its middle,
 * and leaves by a barb under the roof; condensate runs back down the funnel against it.
 *
 * `assembly = "monolithic"` is exhaust_condenser.scad's part, unchanged. `"split"` makes the well a
 * bayonet insert locking into the roof, so it lifts out to clean and reseals on its face ring; the
 * body does not widen for it, since the joint is the roof. Two inserts fit the same body:
 *
 *  - "open": the well's mouth is open at the top. Empty, it cools to the room; filled with ice or
 *    cold water, it is a cold finger below it.
 *  - "flow": a head over the mouth seals on a dip tube down its middle and carries an overflow barb,
 *    opposite the gas outlet. Coolant goes down the dip tube to the well's bottom and out over the
 *    top, so the well runs full.
 *
 * With "flow" the printed well is the only wall between coolant and gas: feed it by gravity, or
 * through a valve on the inlet with the outlet draining freely, never from a tap straight.
 *
 * The body prints standing on its roof, the insert on its flange ("open") or head ("flow").
 */

use <../utils/facets.scad>
use <../utils/section.scad>
use <bayonet_port.scad>
use <condenser_body.scad>
use <exhaust_condenser.scad>
include <bayonet_interfaces.scad>

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// One printed piece, or a body and a well insert
assembly = "split"; // [monolithic, split]
// The well insert: open at the top, or with a dip tube and overflow for flowing coolant
well_mode = "open"; // [open, flow]
// What the standalone file draws when split: the assembly, or one part in its print orientation
part = "assembly"; // [assembly, body, insert]
// Cut the assembly's preview open to see inside; ignored on a render
cross_section_active = true;
// How much the cut leaves: 0.5 is a half, 0.75 removes a quarter
cross_section_keep = 0.5;

// example usage: the jar_10L lid's air_out port, which is std
if (assembly == "monolithic")
  section(keep=cross_section_keep, size=300, active=cross_section_active && $preview)
    exhaust_condenser(bayonet_std);
else if (part == "body")
  translate([0, 0, condenser_cold_finger_roof_top_z(bayonet_std)])
    rotate([180, 0, 0]) condenser_cold_finger_body(bayonet_std);
else if (part == "insert")
  condenser_cold_finger_insert_printed(bayonet_std, well_mode);
else
  section(keep=cross_section_keep, size=300, active=cross_section_active && $preview)
    condenser_cold_finger_assembly(bayonet_std, well_mode);
if (assembly == "split")
  condenser_cold_finger_report(bayonet_std);

// ----- dimensions -----

// The rod seal's captive lip, as bayonet_port cuts it; a variable there, so read back through its
// centre function rather than restated.
function condenser_cold_finger_gland_lip(ring) = bayonet_bore_gland_centre(ring, 0) - bayonet_bore_gland_length(ring) / 2;

// The well is as wide as will drop through the lock.
function condenser_cold_finger_well_od(well_type) = 2 * bayonet_pin_face_radius(well_type);

// Where the roof's top face, the well's panel, stands above the lid.
function condenser_cold_finger_roof_top_z(
  type, bore_diameter = 12, neck_height = 30, shell_inner_diameter = 40, cooled_length = 150, roof = 10
) = condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, cooled_length) + roof;

// The well's tip, in the lid's datum: one gap off the funnel, measured normal to both cones.
function condenser_cold_finger_tip_z(type, bore_diameter, neck_height, shell_inner_diameter, well_od) =
  bayonet_flange_height(type) + neck_height - bore_diameter / 2
  + (shell_inner_diameter - well_od) / 2 * sqrt(2);

// ----- body -----

/**
 * @param type                 Registered bayonet interface the lid's port carries
 * @param well_type            Registered bayonet interface the well locks into
 * @param bore_diameter        Gas up, condensate down, through the pin and neck
 * @param neck_height          Straight neck above the flange
 * @param shell_inner_diameter Inside of the shell
 * @param cooled_length        Straight annulus between the funnel and the roof
 * @param wall                 Wall of the shell
 * @param roof                 Roof thickness, which is the well's panel
 * @param stub_height          Height of the ribs at the annulus's foot that keep the well's tip central
 * @param hose_inner_diameter  Hose the outlet barb takes
 * @param outlet_bore_diameter Bore of the outlet barb
 */
module condenser_cold_finger_body(
  type,
  well_type = bayonet_large,
  bore_diameter = 12,
  neck_height = 30,
  shell_inner_diameter = 40,
  cooled_length = 150,
  wall = 2,
  roof = 10,
  stub_height = 15,
  hose_inner_diameter = 6.35,
  outlet_bore_diameter = 4.5
) {
  _rs = shell_inner_diameter / 2;
  _z_funnel = condenser_body_funnel_top_z(type, bore_diameter, neck_height, shell_inner_diameter);
  _z_shell = _z_funnel + cooled_length;
  _z_roof = _z_shell + roof;
  _well_r = condenser_cold_finger_well_od(well_type) / 2;
  _hole_r = bayonet_port_hole_radius(well_type);
  _barb_r = hose_inner_diameter / 2;
  _barb_length = hose_inner_diameter * 2.5;
  _outlet_r = outlet_bore_diameter / 2;
  _outlet_z = _z_shell - _outlet_r - wall;

  assert(
    bayonet_flange_radius(well_type) <= _rs + wall,
    str("condenser_cold_finger_body: the well's flange, r ", bayonet_flange_radius(well_type), ", overhangs the roof")
  );
  assert(
    _rs - _well_r >= 5,
    str("condenser_cold_finger_body: a ", _rs - _well_r, " mm gap round the well bridges with water and chokes the gas")
  );

  difference() {
    union() {
      condenser_body(type, 18, bore_diameter, neck_height, shell_inner_diameter, cooled_length, wall);

      // Roof: the panel the well locks into
      translate([0, 0, _z_shell - 0.5])
        difference() {
          cylinder(h=roof + 0.5, r=_rs + wall);
          translate([0, 0, -1]) cylinder(h=roof + 2.5, r=_hole_r);
        }
      translate([0, 0, _z_roof]) bayonet_port(type=well_type, part="lock", panel_thickness=roof);

      // Stubs at the annulus's foot, stopping short of the well, so its tip cannot wander
      for (a = [60, 180, 300])
        rotate([0, 0, a])
          translate([_well_r + 0.3, -0.6, _z_funnel])
            cube([_rs - _well_r - 0.3 + 0.1, 1.2, stub_height]);

      // Outlet barb, horizontal, just under the roof
      translate([_rs, 0, _outlet_z])
        rotate([0, 90, 0]) {
          cylinder(h=wall + 2, r=_outlet_r + wall);
          translate([0, 0, wall + 2])
            for (i = [0:2])
              translate([0, 0, i * _barb_length / 3])
                cylinder(h=_barb_length / 3, r1=_barb_r * 1.15, r2=_barb_r * 0.95);
        }
    }

    translate([_rs - wall, 0, _outlet_z])
      rotate([0, 90, 0])
        cylinder(h=_rs * 2, r=_outlet_r);
  }
}

// ----- insert -----

/**
 * The well insert in the roof's datum: z = 0 is the roof's top face, the flange above it and the
 * well hanging below.
 *
 * @param well_type   Registered bayonet interface it locks with
 * @param tip_z       The well's tip, in this datum
 * @param roof        Roof thickness, the coupling's length
 * @param wall        Well wall
 * @param well_mode   "open", or "flow" with a head sealing on a dip tube and an overflow barb
 * @param dip_ring    Registered o-ring sealing on the dip tube, whose ID is the tube
 * @param head_top    Thickness of the head's top, which carries the dip tube's rod seal
 * @param collar      Height of the collar between flange and head, where the overflow leaves
 * @param hose_inner_diameter  Hose the overflow barb takes
 * @param overflow_bore        Bore of the overflow barb
 */
module condenser_cold_finger_insert(
  well_type,
  tip_z,
  roof = 10,
  wall = 2,
  well_mode = "open",
  dip_ring = oring_4x1p5_epdm,
  head_top = 6,
  collar = 14,
  hose_inner_diameter = 6.35,
  overflow_bore = 4.5
) {
  _fh = bayonet_flange_height(well_type);
  _fr = bayonet_flange_radius(well_type);
  _ro = condenser_cold_finger_well_od(well_type) / 2;
  _ri = _ro - wall;
  _mouth_r = bayonet_interface_radius(well_type) - bayonet_pin_radius(well_type) - 2; // 2 mm in the coupling
  _barb_r = hose_inner_diameter / 2;
  _barb_length = hose_inner_diameter * 2.5;

  assert(tip_z < -roof - _ro, str("condenser_cold_finger_insert: a tip at z ", tip_z, " leaves no well"));
  assert(
    well_mode == "open" || condenser_cold_finger_gland_lip(dip_ring) + bayonet_bore_gland_length(dip_ring) < head_top - 1,
    str("condenser_cold_finger_insert: a ", head_top, " mm head is too thin for the dip tube's seal")
  );

  difference() {
    union() {
      bayonet_port(type=well_type, part="pin", panel_thickness=roof, center_bore_radius=_mouth_r, catch_pockets=false);

      // The well, from the coupling down to a 45 degree tip
      rotate_extrude()
        polygon([[0, tip_z], [_ro, tip_z + _ro], [_ro, -roof + 0.5], [0, -roof + 0.5]]);

      if (well_mode == "flow") {
        // Collar and head over the mouth
        translate([0, 0, _fh - 0.5]) cylinder(h=collar + head_top + 0.5, r=_fr);
        // Overflow barb out of the collar, at 180 degrees so it is not mistaken for the gas outlet at 0
        rotate([0, 0, 180]) translate([_fr - 1, 0, _fh + collar / 2])
          rotate([0, 90, 0]) {
            cylinder(h=3, r=_barb_r * 1.15 + 1);
            translate([0, 0, 3])
              for (i = [0:2])
                translate([0, 0, i * _barb_length / 3])
                  cylinder(h=_barb_length / 3, r1=_barb_r * 1.15, r2=_barb_r * 0.95);
          }
      }
    }

    // The well's inside; 45 degrees up into the coupling's narrower mouth, and to a tip below
    rotate_extrude()
      polygon(
        [
          [0, tip_z + wall * sqrt(2)],
          [_ri, tip_z + wall * sqrt(2) + _ri],
          [_ri, -roof - (_ri - _mouth_r)],
          [_mouth_r, -roof],
          [_mouth_r, _fh + 1],
          [0, _fh + 1],
        ]
      );

    if (well_mode == "flow") {
      // The collar's inside, open to the well; the dip tube's bore and its rod seal, the seal's lip
      // toward the collar so the ring is captive; the overflow's bore
      translate([0, 0, _fh]) cylinder(h=collar, r=_mouth_r);
      translate([0, 0, _fh + collar - 1])
        cylinder(h=head_top + 2, r=oring_inner_diameter(dip_ring) / 2 + 0.2);
      translate([0, 0, _fh + collar + condenser_cold_finger_gland_lip(dip_ring)])
        cylinder(h=bayonet_bore_gland_length(dip_ring), r=bayonet_bore_gland_radius(dip_ring));
      rotate([0, 0, 180]) translate([_mouth_r - 1, 0, _fh + collar / 2])
        rotate([0, 90, 0])
          cylinder(h=_fr * 2, d=overflow_bore);
    }
  }
}

// The insert as it prints: on its flange ("open") or its head ("flow").
module condenser_cold_finger_insert_printed(type, well_mode, well_type = bayonet_large) {
  _tip = condenser_cold_finger_tip_z(type, 12, 30, 40, condenser_cold_finger_well_od(well_type))
    - condenser_cold_finger_roof_top_z(type);
  _top = bayonet_flange_height(well_type) + (well_mode == "flow" ? 14 + 6 : 0);
  translate([0, 0, _top]) rotate([180, 0, 0]) condenser_cold_finger_insert(well_type, _tip, well_mode=well_mode);
}

// Body and insert as assembled, in the lid's datum; the dip tube drawn for "flow".
module condenser_cold_finger_assembly(type, well_mode, well_type = bayonet_large) {
  _z_roof = condenser_cold_finger_roof_top_z(type);
  _tip = condenser_cold_finger_tip_z(type, 12, 30, 40, condenser_cold_finger_well_od(well_type));
  _fh = bayonet_flange_height(well_type);

  condenser_cold_finger_body(type, well_type);
  translate([0, 0, _z_roof]) {
    condenser_cold_finger_insert(well_type, _tip - _z_roof, well_mode=well_mode);
    if (well_mode == "flow")
      color("Silver")
        translate([0, 0, _tip - _z_roof + 6]) cylinder(h=_z_roof - _tip + 45, d=4);
  }
}

// What the split part's numbers come to.
module condenser_cold_finger_report(type, well_type = bayonet_large, flow_lpm = 4.11, shell_inner_diameter = 40, cooled_length = 150) {
  _od = condenser_cold_finger_well_od(well_type);
  _area = PI / 4 * (shell_inner_diameter ^ 2 - _od ^ 2);
  echo(
    str(
      "condenser cold finger (split): Ø", _od, " well on the ", bayonet_name(well_type), " interface, sealed by a ",
      oring_name(bayonet_oring(well_type)), "; ", (shell_inner_diameter - _od) / 2, " mm gap at ",
      flow_lpm / 60000 / (_area * 1e-6), " m/s over ", PI * (shell_inner_diameter + _od) * cooled_length / 100,
      " cm2 of cold wall; roof top ", condenser_cold_finger_roof_top_z(type), " mm above the lid"
    )
  );
}
