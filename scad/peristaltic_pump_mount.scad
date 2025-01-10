// Mount for holding and fixing a peristaltic pump in place by its base.
// derived from: https://www.printables.com/model/857120-peristaltic-pump-mount
// Cameron K. Brooks 2025
// Changes: applied formatting, modularized parts, reduced parameter set, added args, added comments, added example
// usage, added z-fighting avoidance

module peri_mount(inner_diameter, outer_diameter, body_height, mount_height, mount_width, pump_thread_diameter,
                  base_thread_diameter, base_head_diameter, body_opening)
{
    bore_distance = sqrt(outer_diameter ^ 2 + body_height ^ 2);

    difference()
    {
        union()
        {
            cylinder(d = outer_diameter, h = body_height);
            translate([ 0, 0, body_height - mount_height ])
                mounts(mount_height, pump_thread_diameter, pump_thread_diameter, bore_distance, mount_width);
            rotate([ 0, 0, 45 ])
            {
                mounts(mount_height, base_thread_diameter, base_head_diameter, bore_distance, mount_width);
            }
            rotate([ 0, 0, -45 ])
            {
                mounts(mount_height, base_thread_diameter, base_head_diameter, bore_distance, mount_width);
            }
        }

        // body_opening in the middle
        translate([ 0, 0, -zFite / 2 ]) cylinder(d = inner_diameter, h = body_height + zFite);

        rotate([ 0, 90, 0 ])
        {
            cylinder(d = body_opening, h = outer_diameter, center = true);
        }
        rotate([ 0, 90, 90 ])
        {
            cylinder(d = body_opening, h = outer_diameter, center = true);
        }
    }
}

module mounts(mount_height, bore1, bore2, bore_distance, mount_width)
{
    difference()
    {
        hull()
        {
            translate([ -bore_distance / 2, 0, 0 ])
            {
                cylinder(d = mount_width, h = mount_height);
            }
            translate([ bore_distance / 2, 0, 0 ])
            {
                cylinder(d = mount_width, h = mount_height);
            }
        }
        translate([ -bore_distance / 2, 0, -zFite / 2 ])
        {
            cylinder(d1 = bore1, d2 = bore2, h = mount_height + zFite);
        }
        translate([ bore_distance / 2, 0, -zFite / 2 ])
        {
            cylinder(d1 = bore1, d2 = bore2, h = mount_height + zFite);
        }
    }
}

$fn = $preview ? 16 : 64;


// Example usage:
body_thickness = 5;
body_height = 26;
inner_diameter = 40;
outer_diameter = inner_diameter + body_thickness;
body_opening = 25;

mount_height = 5;
mount_width = 10;

pump_thread_diameter = 2.5;
base_thread_diameter = 3.5;
base_head_diameter = 5;

peri_mount(inner_diameter, outer_diameter, body_height, mount_height, mount_width, pump_thread_diameter,
           base_thread_diameter, base_head_diameter, body_opening);