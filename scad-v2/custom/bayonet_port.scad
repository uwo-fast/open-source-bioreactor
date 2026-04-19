use <bayonet-lock-scad/bayonet_lock.scad>

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// What style of lock to produce, with the pin pointed inward ou outward?
bayonet_lock_pin_direction = "outer"; // ["inner", "outer"]

// What to render
bayonet_lock_part_render = "pin"; // ["pin", "lock"]

// Render the mechanism with 2 to 6 locks / pins
bayonet_lock_number_of_pins = 3;

// The angle of the path that the pin will follow
bayonet_lock_path_sweep_angle = 30;

// Direction of the lock
bayonet_lock_turn_direction = "CW"; // ["CW", "CCW"]

// inner radius of the lock
bayonet_lock_inner_radius = 7;

// outer radius of the lock
bayonet_lock_outer_radius = 12;

// the allowance or "gap" between the pin and the lock
bayonet_lock_allowance = 0.2;

// manual pin radius, if not set, it will be calculated based on the inner and outer radius
bayonet_lock_manual_pin_radius = 1.5;

// radius of the locking pin
bayonet_lock_pin_radius =
  (bayonet_lock_manual_pin_radius == 0) ? (bayonet_lock_outer_radius - bayonet_lock_inner_radius) / 4
  : bayonet_lock_manual_pin_radius;

// Height of the connector part
bayonet_lock_height = 10;

// height of the added neck to create a flange
bayonet_lock_neck_height = 5;

bayonet_lock_inner_radius_fill = 3;

bayonet_lock_oring_height = 1.6;
bayonet_lock_oring_height_interference = 0.1;

bayonet_lock_oring_neck_cut_height = bayonet_lock_oring_height - bayonet_lock_oring_height_interference;

// Render the lock
bayonet_port(
  part_to_render=bayonet_lock_part_render,
  pin_direction=bayonet_lock_pin_direction,
  number_of_pins=bayonet_lock_number_of_pins,
  path_sweep_angle=bayonet_lock_path_sweep_angle,
  turn_direction=bayonet_lock_turn_direction,
  inner_radius=bayonet_lock_inner_radius,
  outer_radius=bayonet_lock_outer_radius,
  pin_radius=bayonet_lock_pin_radius,
  allowance=bayonet_lock_allowance,
  part_height=bayonet_lock_height,
  neck_height=bayonet_lock_neck_height,
  inner_radius_fill=bayonet_lock_inner_radius_fill,
  oring_height=bayonet_lock_oring_height,
  oring_neck_cut_height=bayonet_lock_oring_neck_cut_height,
  catch_pockets=true,
  imprint_text=true,
  radius_string_override="DO"
);

module bayonet_port(
  part_to_render,
  pin_direction,
  number_of_pins,
  path_sweep_angle,
  turn_direction,
  inner_radius,
  outer_radius,
  pin_radius,
  allowance,
  part_height,
  neck_height,
  oring_neck_cut_height,
  inner_radius_fill,
  oring_height,
  oring_neck_cut_height,
  catch_pockets = true,
  imprint_text = false,
  radius_string_override = undef,
  diameter_string_override = undef
) {

  neck_h = (part_to_render == "lock") ? 0 : neck_height;
  neck_cut_h = (part_to_render == "lock") ? 0 : oring_neck_cut_height;
  neck_r_allow = (part_to_render == "lock") ? 0 : allowance;
  inner_r_fill = (part_to_render == "lock") ? 0 : inner_radius_fill;
  inner_h_fill = (part_to_render == "lock") ? 0 : neck_h + part_height;

  assert(!(!imprint_text && (!is_undef(radius_string_override) || !is_undef(diameter_string_override))), "If imprint_text is false, radius_string_override and diameter_string_override should not be set");

  // Calculate library parameters
  shell_thickness = (outer_radius - inner_radius) / 2;
  entry_depth = part_height * 0.5;

  difference() {
    union() {
      // Use correct library functions
      if (neck_h > 0) {
        bayonet_neck(neck_h, inner_radius, outer_radius)
          bayonet(
            half=part_to_render,
            inner_radius=inner_radius,
            shell_thickness=shell_thickness,
            allowance=allowance,
            part_height=part_height,
            entry_depth=entry_depth,
            number_of_pins=number_of_pins,
            pin_radius=pin_radius,
            sweep_angle=path_sweep_angle,
            pin_direction=pin_direction,
            turn_direction=turn_direction
          );
      } else {
        bayonet(
          half=part_to_render,
          inner_radius=inner_radius,
          shell_thickness=shell_thickness,
          allowance=allowance,
          part_height=part_height,
          entry_depth=entry_depth,
          number_of_pins=number_of_pins,
          pin_radius=pin_radius,
          sweep_angle=path_sweep_angle,
          pin_direction=pin_direction,
          turn_direction=turn_direction
        );
      }

      // Inner fill cylinder (creates sealing surface)
      if (inner_r_fill > 0) {
        tube(h=inner_h_fill, r_outer=inner_radius + allowance, r_inner=inner_r_fill);
      }
    }

    mid_radius_1 = (inner_radius + outer_radius) / 2 - allowance;

    // cut out the oring from +Z face of neck
    if (neck_h > 0) {
      color("red") translate([0, 0, neck_height - neck_cut_h]) 
        tube(h=neck_cut_h * 1.1, r_outer=outer_radius * 1.1, r_inner=mid_radius_1);
    }

    // outer allowance on neck
    if (neck_h > 0 && neck_r_allow > 0) {
      color("red") translate([0, 0, -zFite / 2]) 
        tube(h=neck_height, r_outer=outer_radius * 1.1, r_inner=outer_radius - neck_r_allow);
    }

    // cut holes to stick pliers to insert / rotate / remove the lock
    if (catch_pockets && neck_h > 0) {
      color("red") for (i = [0:1])
        rotate([0, 0, i * 180]) translate([inner_radius, 0, -zFite / 2])
          cylinder(h=neck_height / 2, d=outer_radius - inner_radius);
    }

    // Write the inner radius and diameter on the top for reference
    if (imprint_text && neck_h > 0) {
      radString = is_undef(radius_string_override) ? str("R", inner_radius_fill) : radius_string_override;
      diaString = is_undef(diameter_string_override) ? str("D", inner_radius_fill * 2) : diameter_string_override;

      translate([0, inner_radius, neck_height / 2 - zFite / 2]) color("green") {
          rotate([0, 180, 0]) linear_extrude(neck_height / 2)
              text(
                radString, size=outer_radius - inner_radius, halign="center", valign="center", font="sans",
                $fn=32
              );
        }
      translate([0, -inner_radius, neck_height / 2 - zFite / 2]) color("green") {
          rotate([0, 180, 0]) linear_extrude(neck_height / 2)
              text(
                diaString, size=outer_radius - inner_radius, halign="center", valign="center", font="sans",
                $fn=32
              );
        }
    }
  }
}
