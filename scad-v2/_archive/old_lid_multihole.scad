

// probe mount
// width of the probe mount
entry_mount_width = 20;
// height of the probe mount
entry_mount_height = 8;
// thickness of the probe mount
entry_mount_cuts_allow = 0.1;
// diameter of the probe mount hole
entry_mount_screw_hole_diameter = 3;

// number of holes for the first holes set
entry_1_n = 4;
// diameter of the holes for the first holes set
entry_1_diameter = ph_probe_clamp_rod_diameter;

// number of holes for the second holes set
entry_2_n = 4;
// diameter of the holes for the second holes set
entry_2_diameter = ph_probe_clamp_rod_diameter;

// number of holes for the third holes set
entry_3_n = 4;
// diameter of the holes for the third holes set
entry_3_diameter = ph_probe_clamp_rod_diameter;

// Intermediate calculations
// total number of holes to make
entry_tot_n = entry_1_n + entry_2_n + entry_3_n;
// angular shift between the holes
lid_holes_angular_shift = 360 / entry_tot_n;
// offsets for the holes, this can be cleaner in the future
entry_1_offset = 0;
entry_2_offset = lid_holes_angular_shift * entry_1_n;
entry_3_offset = entry_2_offset + lid_holes_angular_shift * entry_2_n;
entry_1_specs = [entry_1_n, entry_1_diameter, entry_1_offset];
entry_2_specs = [entry_2_n, entry_2_diameter, entry_2_offset];
entry_3_specs = [entry_3_n, entry_3_diameter, entry_3_offset];
entry_specs = [entry_1_specs, entry_2_specs, entry_3_specs];

// lid
if (render_lid || render_all) {
  cut_height = lid_height * 2 * 1.1;

  translate([0, 0, lid_z_pos]) rotate([0, 180, 0]) {

      color(prints2_color) difference() {
          // create the lid
          lid(
            outer_diameter=jar_diameter, inner_diameter=opening_diameter, height=lid_height,
            allowance=lid_rad_allow, rod_hole_diameter=threaded_rod_diameter, nut_dia=nut_diameter,
            nut_h=nut_height
          );

          // cut out the bearing and shaft hole
          translate([0, 0, -zFite / 2]) union() {
              cylinder(d=threaded_rod_diameter, h=lid_height * 2 + zFite);
              rotate([0, 0, 30]) cylinder(d=bearing_diameter, h=bearing_height + zFite);
            }

          // cut off corners to reduce material and allow space for lights
          translate([0, 0, lid_height]) rotate([0, 0, 45]) difference() {
                cube([jar_diameter * 1.1, jar_diameter * 1.1, cut_height], center=true);
                cube([jar_diameter - lid_cuts, jar_diameter - lid_cuts, cut_height * 1.1], center=true);
              }

          // cut out the entry holes for the probes and tubes
          for (i = [0:len(entry_specs) - 1]) {
            entry_n = entry_specs[i][0];
            entry_diameter = entry_specs[i][1];
            entry_offset = entry_specs[i][2];

            for (j = [0:entry_n - 1]) {
              hole_rot = j * lid_holes_angular_shift + entry_offset;
              rotate([0, 0, hole_rot]) translate([jar_diameter / 4, 0, lid_height]) {
                  cylinder(d=entry_diameter, h=cut_height, center=true);
                }
            }
          }
        }
    }
}
