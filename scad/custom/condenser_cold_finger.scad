/**
 * @file condenser_cold_finger.scad
 * @brief Cold-finger exhaust condenser, one piece or with a removable well
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Exhaust rises from the funnel through the annulus between a shell and a well hung down its
 * centre, and leaves through a barb under the roof. Condensate runs back down the funnel against
 * the gas flow.
 *
 * `assembly = "monolithic"` prints the shell, roof and well as one piece, with ribs joining the
 * well to the shell:
 *
 *             __       __
 *            |  |     |  |===     barb, just under the roof
 *            |  | well|  |        the well is open at the top and closed at the bottom. Empty, the
 *            |  |     |  |        shell and well both cool to room temperature; filled with cold
 *            |   \   /   |        water or ice, the well is a cold finger below room temperature
 *             \   \ /   /         funnel and well tip at 45 degrees, one gap apart
 *              \       /
 *               |     |           neck, lifting the shell clear of the neighbouring ports
 *             __|     |__
 *            |___     ___|        flange; z = 0 is the panel outer face, as for every bayonet_port
 *               |     |           the coupling, in the lid port
 *
 * It prints standing on its roof, well mouth down. For the same reason the barb must not extend
 * above the roof.
 *
 * `"split"` makes the well a bayonet insert that locks into the roof, so it can be lifted out for
 * cleaning and reseals on its face ring. The body does not need to be wider, because the joint is
 * in the roof. Two inserts fit the same body:
 *
 *  - "open": the well mouth is open at the top. Empty, it cools to room temperature; filled with
 *    ice or cold water, it is a cold finger below room temperature. A lid closes the mouth over the
 *    ice. It is vented so the meltwater never pressurises the well, and printed with sparse infill
 *    it also acts as insulation.
 *  - "flow": a head over the mouth seals on a dip tube down the centre and has an overflow barb
 *    opposite the gas outlet. Coolant flows down the dip tube to the bottom of the well and out
 *    over the top, so the well runs full.
 *
 * With "flow" the printed well is the only wall between coolant and gas. Feed it by gravity, or
 * through a valve on the inlet with the outlet draining freely. Never connect it directly to a tap.
 *
 * The body prints standing on its roof, the insert on its flange ("open") or head ("flow").
 */

use <../utils/facets.scad>
use <../utils/section.scad>
use <bayonet-port-scad/custom/bayonet_port.scad>
use <condenser_body.scad>
include <bayonet-port-scad/custom/bayonet_interfaces.scad>

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

// Tessellate by feature size - see utils/facets.scad.
$fn = 0;
$fa = facet_angle();
$fs = facet_size();

// One printed piece, or a body and a well insert
assembly = "split"; // [monolithic, split]
// The well insert: open at the top, or with a dip tube and overflow for flowing coolant
well_mode = "open"; // [open, flow]
// What this file draws: the assembly, or one part in its print orientation ("insert" only when split)
part = "assembly"; // [assembly, body, insert, lid]
// Cut the assembly preview open to show the inside; ignored on a render
cross_section_active = true;
// Fraction the cut keeps: 0.5 keeps half, 0.75 removes a quarter
cross_section_keep = 0.5;

// example usage: the air_out port on the jar_10L lid, which is std
if (assembly == "monolithic" && part == "body")
  translate([0, 0, condenser_body_top_z(
    bayonet_std, condenser_cold_finger_bore, condenser_cold_finger_neck, condenser_cold_finger_mono_shell,
    condenser_cold_finger_cooled
  ) + condenser_cold_finger_wall])
    rotate([180, 0, 0]) condenser_cold_finger_monolithic(bayonet_std);
else if (assembly == "monolithic")
  section(keep=cross_section_keep, size=300, active=cross_section_active && $preview)
    condenser_cold_finger_monolithic(bayonet_std);
else if (part == "body")
  translate([0, 0, condenser_cold_finger_roof_top_z(bayonet_std)])
    rotate([180, 0, 0]) condenser_cold_finger_body(bayonet_std);
else if (part == "insert")
  condenser_cold_finger_insert_printed(bayonet_std, well_mode);
else if (part == "lid")
  translate([0, 0, condenser_cold_finger_lid_thickness]) rotate([180, 0, 0]) condenser_cold_finger_lid(bayonet_large);
else
  section(keep=cross_section_keep, size=300, active=cross_section_active && $preview)
    condenser_cold_finger_assembly(bayonet_std, well_mode);
if (assembly == "split")
  condenser_cold_finger_report(bayonet_std);
else
  condenser_cold_finger_monolithic_report(bayonet_std, flow_lpm=4.11);

// ----- dimensions -----

// Defaults for every module and helper below, defined once so the print, assembly and report
// helpers cannot drift from the parts they draw.
condenser_cold_finger_bore = 12; // bore through the pin and neck (gas up, condensate down)
condenser_cold_finger_neck = 30; // straight neck above the flange
condenser_cold_finger_wall = 2;
condenser_cold_finger_cooled = 150; // straight annulus above the funnel
condenser_cold_finger_split_shell = 40; // inside diameter of the split body shell
condenser_cold_finger_roof = 10; // roof of the split body, which is the well panel
condenser_cold_finger_collar = 14; // collar of the flow head, where the overflow leaves
condenser_cold_finger_head_top = 6; // top of the flow head, which holds the dip tube seal
condenser_cold_finger_mono_shell = 44; // inside diameter of the one-piece shell
condenser_cold_finger_mono_well = 32; // outside diameter of the one-piece well

// Captive lip of the rod seal, as bayonet_port cuts it. It is a local variable there, so it is
// derived from the gland centre function instead of being restated.
function condenser_cold_finger_gland_lip(ring) = bayonet_bore_gland_centre(ring, 0) - bayonet_bore_gland_length(ring) / 2;

// The well is as wide as will pass through the lock.
function condenser_cold_finger_well_od(well_type) = 2 * bayonet_pin_face_radius(well_type);

// Height of the roof top face (the well panel) above the lid.
function condenser_cold_finger_roof_top_z(
  type, bore_diameter = condenser_cold_finger_bore, neck_height = condenser_cold_finger_neck,
  shell_inner_diameter = condenser_cold_finger_split_shell, cooled_length = condenser_cold_finger_cooled,
  roof = condenser_cold_finger_roof
) = condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, cooled_length) + roof;

// Height of the well tip in the lid datum: one gap from the funnel, measured normal to both cones.
function condenser_cold_finger_tip_z(type, bore_diameter, neck_height, shell_inner_diameter, well_od) =
  bayonet_flange_height(type) + neck_height - bore_diameter / 2
  + (shell_inner_diameter - well_od) / 2 * sqrt(2);

// ----- body -----

/**
 * @param type                 Registered bayonet interface of the lid port
 * @param well_type            Registered bayonet interface the well locks into
 * @param bore_diameter        Bore through the pin and neck (gas up, condensate down)
 * @param neck_height          Straight neck above the flange
 * @param shell_inner_diameter Inside diameter of the shell
 * @param cooled_length        Straight annulus between the funnel and the roof
 * @param wall                 Wall of the shell
 * @param roof                 Roof thickness, which is the well panel
 * @param stub_height          Height of the ribs at the annulus bottom that centre the well tip
 * @param hose_inner_diameter  Inside diameter of the hose on the outlet barb
 * @param outlet_bore_diameter Bore of the outlet barb
 */
module condenser_cold_finger_body(
  type,
  well_type = bayonet_large,
  bore_diameter = condenser_cold_finger_bore,
  neck_height = condenser_cold_finger_neck,
  shell_inner_diameter = condenser_cold_finger_split_shell,
  cooled_length = condenser_cold_finger_cooled,
  wall = condenser_cold_finger_wall,
  roof = condenser_cold_finger_roof,
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

      // Stubs at the bottom of the annulus, stopping short of the well, so its tip stays centred
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
 * The well insert in the roof datum: z = 0 is the top face of the roof, with the flange above it
 * and the well hanging below.
 *
 * @param well_type   Registered bayonet interface it locks with
 * @param tip_z       Height of the well tip, in this datum
 * @param roof        Roof thickness, which is the coupling length
 * @param wall        Well wall
 * @param well_mode   "open", or "flow" with a head sealing on a dip tube and an overflow barb
 * @param dip_ring    Registered o-ring sealing on the dip tube; its ID matches the tube
 * @param head_top    Thickness of the top of the head, which holds the dip tube rod seal
 * @param collar      Height of the collar between flange and head, where the overflow leaves
 * @param hose_inner_diameter  Inside diameter of the hose on the overflow barb
 * @param overflow_bore        Bore of the overflow barb
 */
module condenser_cold_finger_insert(
  well_type,
  tip_z,
  roof = condenser_cold_finger_roof,
  wall = condenser_cold_finger_wall,
  well_mode = "open",
  dip_ring = oring_4x1p5_epdm,
  head_top = condenser_cold_finger_head_top,
  collar = condenser_cold_finger_collar,
  hose_inner_diameter = 6.35,
  overflow_bore = 4.5
) {
  _fh = bayonet_flange_height(well_type);
  _fr = bayonet_flange_radius(well_type);
  _ro = condenser_cold_finger_well_od(well_type) / 2;
  _ri = _ro - wall;
  _mouth_r = bayonet_interface_radius(well_type) - bayonet_pin_radius(well_type) - 2; // 2 mm inside the coupling
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

    // Inside of the well: 45 degrees up into the narrower mouth of the coupling, and down to a tip
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
      // Inside of the collar, open to the well; the dip tube bore and its rod seal, with the seal
      // lip toward the collar so the o-ring is captive; the overflow bore
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

// Lid for the open well, and the vent through it. The vent is the smallest hole that still prints
// open, so melting ice and warming water push air out instead of pressurising the well.
condenser_cold_finger_lid_thickness = 8;
condenser_cold_finger_lid_vent = 1.5;

/**
 * Lid for the open well, in the flange datum: z = 0 is the top of the insert flange. The lid rests
 * on it with a spigot down into the mouth.
 *
 * @param well_type  Registered bayonet interface of the insert it closes
 * @param spigot     Depth the spigot extends down into the mouth
 * @param clearance  Radial clearance of the spigot in the mouth
 */
module condenser_cold_finger_lid(well_type, spigot = 6, clearance = 0.25) {
  _fr = bayonet_flange_radius(well_type);
  _mouth_r = bayonet_interface_radius(well_type) - bayonet_pin_radius(well_type) - 2; // same as the insert

  difference() {
    union() {
      cylinder(h=condenser_cold_finger_lid_thickness, r=_fr);
      translate([0, 0, -spigot]) cylinder(h=spigot + 0.5, r=_mouth_r - clearance);
    }
    translate([0, 0, -spigot - 1]) cylinder(h=spigot + condenser_cold_finger_lid_thickness + 2, d=condenser_cold_finger_lid_vent);
  }
}

// The insert in print orientation: on its flange ("open") or its head ("flow").
module condenser_cold_finger_insert_printed(type, well_mode, well_type = bayonet_large) {
  _tip = condenser_cold_finger_tip_z(
    type, condenser_cold_finger_bore, condenser_cold_finger_neck, condenser_cold_finger_split_shell,
    condenser_cold_finger_well_od(well_type)
  )
    - condenser_cold_finger_roof_top_z(type);
  _top = bayonet_flange_height(well_type)
    + (well_mode == "flow" ? condenser_cold_finger_collar + condenser_cold_finger_head_top : 0);
  translate([0, 0, _top]) rotate([180, 0, 0]) condenser_cold_finger_insert(well_type, _tip, well_mode=well_mode);
}

// Body and insert as assembled, in the lid datum; the dip tube is drawn for "flow".
module condenser_cold_finger_assembly(type, well_mode, well_type = bayonet_large) {
  _z_roof = condenser_cold_finger_roof_top_z(type);
  _tip = condenser_cold_finger_tip_z(
    type, condenser_cold_finger_bore, condenser_cold_finger_neck, condenser_cold_finger_split_shell,
    condenser_cold_finger_well_od(well_type)
  );
  _fh = bayonet_flange_height(well_type);

  condenser_cold_finger_body(type, well_type);
  translate([0, 0, _z_roof]) {
    condenser_cold_finger_insert(well_type, _tip - _z_roof, well_mode=well_mode);
    if (well_mode == "flow")
      color("Silver")
        translate([0, 0, _tip - _z_roof + 6]) cylinder(h=_z_roof - _tip + 45, d=4);
    else
      translate([0, 0, _fh]) condenser_cold_finger_lid(well_type);
  }
}

// Reports the derived figures for the split version.
module condenser_cold_finger_report(
  type, well_type = bayonet_large, flow_lpm = 4.11, shell_inner_diameter = condenser_cold_finger_split_shell,
  cooled_length = condenser_cold_finger_cooled
) {
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

// ----- monolithic -----

// Gap between well and shell, which is also the gap between the well tip and the funnel.
function condenser_cold_finger_gap(shell_inner_diameter, well_outer_diameter) =
  (shell_inner_diameter - well_outer_diameter) / 2;

/**
 * Shell, roof and well in one piece, in the lid datum.
 *
 * @param type                 Registered bayonet interface of the lid port
 * @param panel_thickness      Thickness of the panel the pin passes through
 * @param bore_diameter        Bore through the pin and neck (gas up, condensate down)
 * @param neck_height          Straight neck above the flange, below the funnel
 * @param shell_inner_diameter Inside diameter of the shell
 * @param well_outer_diameter  Outside diameter of the well; with the shell it sets the gap
 * @param cooled_length        Straight annulus above the funnel
 * @param wall                 Wall of the shell, the well, the neck and the roof
 * @param rib_count            Number of radial ribs joining the well to the shell; 0 for none
 * @param rib_thickness        Thickness of each rib
 * @param hose_inner_diameter  Inside diameter of the hose on the outlet barb
 * @param outlet_bore_diameter Bore of the outlet barb
 * @param outlet_angle         Direction of the barb about the port axis, in the locked port frame
 * @param outlet_tilt          Barb above horizontal, degrees; negative points it down
 */
module condenser_cold_finger_monolithic(
  type,
  panel_thickness = 18,
  bore_diameter = condenser_cold_finger_bore,
  neck_height = condenser_cold_finger_neck,
  shell_inner_diameter = condenser_cold_finger_mono_shell,
  well_outer_diameter = condenser_cold_finger_mono_well,
  cooled_length = condenser_cold_finger_cooled,
  wall = condenser_cold_finger_wall,
  rib_count = 3,
  rib_thickness = 1.2,
  hose_inner_diameter = 6.35,
  outlet_bore_diameter = 4.5,
  outlet_angle = 0,
  outlet_tilt = 0
) {
  _rs = shell_inner_diameter / 2;
  _rw = well_outer_diameter / 2;
  _gap = condenser_cold_finger_gap(shell_inner_diameter, well_outer_diameter);
  _z_funnel = condenser_body_funnel_top_z(type, bore_diameter, neck_height, shell_inner_diameter);
  _z_roof = _z_funnel + cooled_length; // underside of the roof
  _z_top = _z_roof + wall;
  _z_tip = condenser_cold_finger_tip_z(type, bore_diameter, neck_height, shell_inner_diameter, well_outer_diameter);

  _barb_r = hose_inner_diameter / 2;
  _barb_length = hose_inner_diameter * 2.5;
  _outlet_r = outlet_bore_diameter / 2;
  _outlet_z = _z_roof - _outlet_r - wall; // just under the roof, the end of the gas path
  _outlet_x = (_rw + _rs) / 2; // mid-gap, clear of the well
  _outlet_run = (_rs + wall - _outlet_x) / cos(outlet_tilt) + wall; // to clear the outside of the shell
  _barb_top = _outlet_z + sin(outlet_tilt) * (_outlet_run + _barb_length) + _barb_r * 1.15 * cos(outlet_tilt);

  assert(
    _gap > _outlet_r * 2 && _gap >= 3,
    str(
      "condenser_cold_finger_monolithic: a ", _gap, " mm gap cannot take the Ø", outlet_bore_diameter,
      " outlet, or bridges with water under 3 mm"
    )
  );
  assert(
    _outlet_r < _barb_r - 0.6,
    str("condenser_cold_finger_monolithic: a Ø", outlet_bore_diameter, " outlet leaves the barb too thin a wall")
  );
  assert(
    _barb_top <= _z_top,
    str(
      "condenser_cold_finger_monolithic: a barb tilted ", outlet_tilt, " degrees reaches z ", _barb_top,
      ", above the roof at ", _z_top, " that the part prints standing on"
    )
  );

  difference() {
    union() {
      condenser_body(type, panel_thickness, bore_diameter, neck_height, shell_inner_diameter, cooled_length, wall);

      // Roof over the annulus, overlapping the top of the shell instead of resting on it
      translate([0, 0, _z_roof - 0.5])
        difference() {
          cylinder(h=wall + 0.5, r=_rs + wall);
          translate([0, 0, -1]) cylinder(h=1.5, r=_rs);
        }

      // The well, from a 45 degree tip up into the roof
      rotate_extrude()
        polygon([[0, _z_tip], [_rw, _z_tip + _rw], [_rw, _z_top], [0, _z_top]]);

      // Ribs in the straight annulus only, so the throat stays clear for the condensate
      if (rib_count > 0)
        for (i = [0:rib_count - 1])
          rotate([0, 0, outlet_angle + 180 / rib_count + i * 360 / rib_count])
            translate([_rw - 0.1, -rib_thickness / 2, _z_funnel])
              cube([_gap + 0.2, rib_thickness, cooled_length + 0.1]);

      // Outlet barb from under the roof, trimmed so it does not intrude into the annulus it vents
      difference() {
        rotate([0, 0, outlet_angle])
          translate([_outlet_x, 0, _outlet_z])
            rotate([0, 90 - outlet_tilt, 0]) {
              cylinder(h=_outlet_run, r=_outlet_r + wall);
              translate([0, 0, _outlet_run])
                for (i = [0:2])
                  translate([0, 0, i * _barb_length / 3])
                    cylinder(h=_barb_length / 3, r1=_barb_r * 1.15, r2=_barb_r * 0.95);
            }
        translate([0, 0, _z_funnel]) cylinder(h=cooled_length, r=_rs);
      }
    }

    // Inside of the well, open through the roof
    rotate_extrude()
      polygon(
        [
          [0, _z_tip + wall * sqrt(2)],
          [_rw - wall, _z_tip + wall * sqrt(2) + _rw - wall],
          [_rw - wall, _z_top + 1],
          [0, _z_top + 1],
        ]
      );

    // Outlet bore from the annulus out through the barb, outward only so it does not cut the well
    rotate([0, 0, outlet_angle])
      translate([_outlet_x, 0, _outlet_z])
        rotate([0, 90 - outlet_tilt, 0])
          cylinder(h=_rs * 4, r=_outlet_r);
  }
}

// Reports gas velocities at a given flow, compared with the flooding limit for a falling film.
module condenser_cold_finger_monolithic_report(
  type,
  flow_lpm,
  bore_diameter = condenser_cold_finger_bore,
  neck_height = condenser_cold_finger_neck,
  shell_inner_diameter = condenser_cold_finger_mono_shell,
  well_outer_diameter = condenser_cold_finger_mono_well,
  cooled_length = condenser_cold_finger_cooled,
  wall = condenser_cold_finger_wall
) {
  _q = flow_lpm / 60000; // m3/s
  _bore_area = PI / 4 * bore_diameter ^ 2; // mm2
  _annulus_area = PI / 4 * (shell_inner_diameter ^ 2 - well_outer_diameter ^ 2);

  // Wallis counter-current flooding in a vertical tube, C = 0.725, air on water.
  _flood_v = 0.725 ^ 2 * sqrt(9.81 * bore_diameter / 1000 * (1000 - 1.2) / 1.2);

  echo(
    str(
      "condenser cold finger (monolithic): Ø", bore_diameter, " bore at ", _q / (_bore_area * 1e-6), " m/s against ",
      _flood_v, " m/s a falling film drains against; ",
      condenser_cold_finger_gap(shell_inner_diameter, well_outer_diameter), " mm gap at ",
      _q / (_annulus_area * 1e-6), " m/s over ",
      PI * (shell_inner_diameter + well_outer_diameter) * cooled_length / 100, " cm2 of cold wall; stands ",
      condenser_body_top_z(type, bore_diameter, neck_height, shell_inner_diameter, cooled_length) + wall,
      " mm above the lid"
    )
  );
}
