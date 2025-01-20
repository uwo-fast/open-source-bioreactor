use <lib/peristaltic_pump_mount.scad>;

peri_mount_thickness =
    3; // thickness of the body; this is largely arbitrary just dont make it too thin or it will be weak
// and too thick and it will be heavy/wasteful
peri_mount_height =
    50; // height of the body; this is the motor body length measured from the faceplate to base with some
// extra to let terminals out
peri_pump_diameter = 30; // inner diameter of the body; this is the measurement of your pumps diameter

// based on the desired attachment point of the pump
peri_base_mount_height = 5;         // height of the base mount
peri_base_screw_distance = 45;      // distance between the screw holes on the base of the pump
peri_base_screwhead_diameter = 5.4; // diameter of the screw head on the base of the pump
peri_base_thread_diameter = 3.5;    // diameter of the screw thread on the base of the pump
peri_base_mount_taper_scale = 0.95; // 1 is no taper (square edges), 0 is a lot of taper (fully smoothed); this is
// superficial and can be changed to your liking

// based on the faceplate of the pump
peri_faceplate_mount_height = 20; // height of the faceplate mount
peri_faceplate_screw_distance = 47.5;
peri_faceplate_thread_diameter = 3;
peri_faceplate_mount_taper_scale =
    0.50; // for printing keep 0.5 - 1 as 0.5 results in 45 degree taper, 1 results in no taper

peri_mounts_width =
    peri_base_screwhead_diameter *
    2; // width of the mounting bars; largely arbitrary, must be greater than mounting holes, ideally 2*screwhead

// Calculated values
peri_mount_outer_diameter =
    peri_pump_diameter + peri_mount_thickness; // outer diameter of the body; this is the outside diameter of the body
peri_mount_opening_dim = (peri_pump_diameter) / 2;
peri_mount_body_opening = [ peri_mount_opening_dim * 4, peri_mount_opening_dim, peri_mount_outer_diameter ];

peri_mount(inner_diameter = peri_pump_diameter, outer_diameter = peri_mount_outer_diameter,
           body_height = peri_mount_height, base_mount_height = peri_base_mount_height,
           base_mount_scale = peri_base_mount_taper_scale, pump_mount_height = peri_faceplate_mount_height,
           pump_mount_scale = peri_faceplate_mount_taper_scale, mount_width = peri_mounts_width,
           base_bore_distance = peri_base_screw_distance, pump_thread_diameter = peri_faceplate_thread_diameter,
           pump_bore_diatance = peri_faceplate_screw_distance, base_thread_diameter = peri_base_thread_diameter,
           base_head_diameter = peri_base_screwhead_diameter, body_opening = peri_mount_body_opening);