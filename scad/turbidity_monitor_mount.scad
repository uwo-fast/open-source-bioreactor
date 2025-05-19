thickness = 2.8;

motor_diameter  = 28;
motor_diameter_allowance = 0.5;
motor_holes_center_to_center = 48;
motor_holes_diameter = 3.5;

turbidity_diameter = 28;
turdibidity_diameter_allowance = 0.5;
turbidity_edge_width = 4;

separation_center_to_center = 74;
offset_center_to_center = 8;

difference() {

    // base plate
    union() {
        hull()
        {

        motor_loc()
            cylinder(d = motor_holes_center_to_center+ motor_holes_diameter*2, h = thickness, center = true);
        turbidity_loc()
        union(){
            cylinder(d = turbidity_diameter + turbidity_edge_width*2, h = thickness, center = true);

        }

        }
                turbidity_loc()

            translate([0, -(turbidity_diameter + turbidity_edge_width*2)/4,0])
                cube([turbidity_diameter + turbidity_edge_width*2, (turbidity_diameter + turdibidity_diameter_allowance)*3/4, thickness], center = true);
}

    // motor cuts
    motor_loc()
        color("grey") 
        union() {
            cylinder(d = motor_diameter + motor_diameter_allowance, h = thickness *1.1, center = true);
            for(i=[0:3]){
                rotate([0, 0, i * 90])
                    translate([motor_holes_center_to_center / 2, 0, 0])
                        cylinder(d = motor_holes_diameter, h = thickness + 1, center = true, $fn = 100);
            }
        }

    // turbidity sensor cuts
    turbidity_loc()
            color("green")
                union() { 
                    cylinder(d = turbidity_diameter + turdibidity_diameter_allowance, h = thickness *1.1, center = true);
                                }
}
module motor_loc()
{
    translate([0, 0, separation_center_to_center/2])
        rotate([90, 0, 0])
            children();
}
module turbidity_loc()
{
    translate([-offset_center_to_center, 0, - separation_center_to_center/2])  
        rotate([90, 0, 0])
            children();
}
