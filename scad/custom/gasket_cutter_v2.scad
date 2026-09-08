// WORK IN PROGRESS CHECK BACK LATER

gasket_outer_diameter = 30;
gasket_material_thickness = 2;

blade_type = "11"; // currently only option is an 11 blade

function eleven_blade_profile() =
  [
    [0.0, 0.0],
    [0.0, 5.84],
    [8.0, 5.84],
    [13.5, 6.25],
    [39.88, 6.25],
    [20.0, -1.0],
    [14.0, -1.0],
    [9.0, 0.0],
  ];

linear_extrude(height=0.45 * 2)
  difference() {
    polygon(points=eleven_blade_profile());

    color("red")

      translate([6, 5.84 / 2, 0])
        union() {

          translate([-1.3, 0, 0]) circle(r=1.3, $fn=64);
          translate([1.3, 0, 0]) circle(r=1.3, $fn=64);
          square([2.2, 2.6], center=true);
        }
  }
