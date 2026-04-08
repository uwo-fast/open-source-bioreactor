// ======================================================================
// Raspberry Pi 4 Model Case
// Original: George Onoufriou (Raven, GeorgeRaven, Archer) © 2019-06-30
// Modified from source repo: https://github.com/DreamingRaven/RavenSCAD
// ======================================================================

$fn = $preview ? 64 : 128; // resolution
z_fight = $preview ? 0.1 : 0; // z-fighting avoidance for preview

// ---------------------------------------------------------------
// --- Base Board + Case Parameters ---
// ---------------------------------------------------------------
board_thickness = 1.5; // PCB thickness
pin_space = 3; // clearance under board for through-hole components
inhibitionzone_height = 12; // top clearance for surface components
case_thickness = 2; // shell wall thickness
extension = 20; // extra offset for subtractive boolean operations

// --- Raspberry Pi 4 board geometry ---
pil = 85.5; // board length
pid = 56; // board width
pih = board_thickness;

// --- Derived heights ---
sd_height = pin_space + case_thickness + board_thickness;
mount_pin_height = 2 * board_thickness + 2 * case_thickness + pin_space + inhibitionzone_height;

// --- Fan mount parameters ---
fan_pin_diam = 3;
fan_position_x = 44.3;
fan_position_y = 14;
fan_pin_distance = 31.5;

// --- Preview Selector ---

show_top = true;
show_bottom = true;
show_full = false;
show_rpi_model = false;

// ---------------------------------------------------------------
// --- Assembly Views ---
// (Uncomment as needed for top/bottom/whole views)
// ---------------------------------------------------------------

// Top section
if (show_top)
  translate([0, 0, inhibitionzone_height + case_thickness + board_thickness])
    rotate([0, 180, 0])
      intersection() {
        rpi4_case();
        topSelector();
      }

// Bottom section
if (show_bottom)
  translate([30, 0, case_thickness])
    rotate([0, -90, 0])
      difference() {
        rpi4_case();
        topSelector();
      }

// Full case
if (show_full)
  translate([-pil, pid + 2 * case_thickness + 5])
    rpi4_case();

// Board-only model
if (show_rpi_model)
  translate([extension + 17.44, pid + 2 * case_thickness + 5, 0])
    color("red", 0.5)
      rpi4();

// ---------------------------------------------------------------
// --- Case Construction Modules ---
// ---------------------------------------------------------------

// -- Selects the top/bottom parts of the case with small lip for IO --
module topSelector() {
  difference() {
    translate([-case_thickness - z_fight / 2, 0, -z_fight / 2])
      cube([pil + 2 * case_thickness + z_fight, pid + z_fight, pin_space + inhibitionzone_height + case_thickness]);
    translate([-case_thickness, 0, 0])
      cube([case_thickness, pid, board_thickness]);
  }
}

// -- Core case shell minus Raspberry Pi model --
module rpi4_case() {
  difference() {
    // Outer case volume
    translate([-case_thickness, -case_thickness, -(case_thickness + pin_space)])
      cube(
        [
          pil + 2 * case_thickness,
          pid + 2 * case_thickness,
          pin_space + inhibitionzone_height + board_thickness + 2 * case_thickness,
        ]
      );

    // Subtract board + pin geometry
    union() {
      rpi4();
      pins();
    }
  }
}

// -- Simplified geometric representation of the Raspberry Pi 4 --
module rpi4() {
  difference() {
    translate([0, 0, board_thickness]) {

      // --- Board volume ---
      translate([0, 0, -board_thickness])
        cube([pil, pid, board_thickness]);

      // --- Component geometry ---
      translate([-(2.81 + extension), 2.15, 0])
        cube([21.3 + extension, 16.3, 13.6]);
      // Ethernet port

      translate([-(2.81 + extension), 22.6, 0])
        cube([17.44 + extension, 13.5, 15.6]);
      // USB 3.0

      translate([-(2.81 + extension), 40.6, 0])
        cube([17.44 + extension, 13.5, 15.6]);
      // USB 2.0

      translate([27.36, 1, 0])
        cube([50.7, 5.0, 8.6 + extension]);
      // GPIO header

      translate([21, 7.15, 0])
        cube([5.0, 5.0, 8.6 + extension]);
      // PoE pins

      translate([48.0, 16.3, 0])
        cube([15.0, 15.0, 2.5]);
      // CPU

      translate([67.5, 6.8, 0])
        cube([10.8, 13.1, 1.8]);
      // Wi-Fi module

      translate([79, 17.3, 0])
        cube([2.5, 22.15, 5.4 + extension]);
      // Display connector

      translate([37.4, 34.1, 0])
        cube([2.5, 22.15, 5.4 + extension]);
      // CSI camera

      translate([26.9, 43.55, 0])
        cube([8.5, 14.95 + extension, 6.9]);
      // Audio jack

      translate([55.0, 50, 0])
        cube([7.95, 7.8 + extension, 3.9]);
      // Micro HDMI0

      translate([41.2, 50, 0])
        cube([7.95, 7.8 + extension, 3.9]);
      // Micro HDMI1

      translate([69.1, 50, 0])
        cube([9.7, 7.4 + extension, 3.6]);
      // USB Type-C power

      translate([85, 22.4, -(board_thickness + sd_height)])
        cube([2.55 + extension, 11.11, sd_height]);
      // SD card slot

      // --- Fan mounts ---
      for (x_off = [0, fan_pin_distance])
        for (y_off = [0, fan_pin_distance])
          translate([fan_position_x + x_off, fan_position_y + y_off, 0])
            cylinder(extension, d=fan_pin_diam, center=false);

      // Fan air hole
      translate(
        [
          fan_position_x + 0.5 * fan_pin_distance,
          fan_position_y + 0.5 * fan_pin_distance,
          0,
        ]
      )
        cylinder(extension, d=fan_pin_distance + fan_pin_diam, center=false);

      // --- Underside air holes ---
      translate([53, 7.8, 0])
        scale([10, 1, 1])for (offset = [0:10:40])
          translate([0, offset, -extension - board_thickness - pin_space])
            cylinder(h=extension + z_fight, d=5, center=false);

      // --- Board mount zones ---
      difference() {
        union() {
          cube([pil, pid, inhibitionzone_height]);
          translate([0, 0, -(pin_space + board_thickness)])
            cube([pil, pid, pin_space]);
        }
        mounts();
      }
    }
    // End of translation cancel
    pins();
  }
}

// -- Solid pillars under the board (for fastening) --
module mounts() {
  translate([1.25, 1.25, 0.5 * mount_pin_height - (board_thickness + case_thickness + pin_space)]) {
    translate([22.2, 2, 0]) cylinder(mount_pin_height, d=5.9, center=true); // top-right
    translate([22.2, 51.1, 0]) cylinder(mount_pin_height, d=5.9, center=true); // bottom-right
    translate([80.2, 2, 0]) cylinder(mount_pin_height, d=5.9, center=true); // top-left
    translate([80.2, 51.1, 0]) cylinder(mount_pin_height, d=5.9, center=true); // bottom-left
  }
}

// -- Screw holes through the mounts --
module pins() {
  translate([1.25, 1.25, 0.5 * mount_pin_height - (board_thickness + case_thickness + pin_space)]) {
    translate([22.2, 2, 0]) cylinder(mount_pin_height, d=2.5, center=true);
    translate([22.2, 51.1, 0]) cylinder(mount_pin_height, d=2.5, center=true);
    translate([80.2, 2, 0]) cylinder(mount_pin_height, d=2.5, center=true);
    translate([80.2, 51.1, 0]) cylinder(mount_pin_height, d=2.5, center=true);
  }
}
