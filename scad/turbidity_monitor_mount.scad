
height  = 130;
width = 60;
thickness = 5;

motor_diameter  = 27.8;
motor_holes_center_to_center = 48;
turbidity_diameter = 28;
separation_center_to_center = 74;

difference() {
cube([width, thickness, height], center = true);
translate([0, 0, height / 2])
{
    {

            // motor
            translate([0, 0, -height / 2 + separation_center_to_center/2])
                rotate([90, 0, 0])
                    color("grey") union() {
                        cylinder(d = motor_diameter, h = thickness + 1, center = true);
                        for(i=[0:3]){
                            rotate([0, 0, i * 90])
                                translate([motor_holes_center_to_center / 2, 0, 0])
                                    cylinder(d = 3.5, h = thickness + 1, center = true, $fn = 100);
                        }
                        }

            // turbidity
            translate([0, 0, -height / 2 - separation_center_to_center/2])  
                rotate([90, 0, 0])
                    color("green") cylinder(d = turbidity_diameter, h = thickness + 1, center = true);
            
        
    }
}}