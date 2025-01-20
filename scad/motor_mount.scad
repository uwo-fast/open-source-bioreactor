// ---------------------------------
// Global Parameters
// ---------------------------------
$fn = $preview ? 64 : 128;  // number of fragments for circles, affects render time
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

module motor_mount(height, width, thickness, motor_diameter, corner_cuts, base_screws_diameter, base_screws_cdist,
                   face_screws_diameter, face_screws_cdist)
{
    inner_dia = motor_diameter - 2 * thickness;
    ext_scale = motor_diameter / width;

    window_width = corner_cuts * 2;
    window_depth = thickness * 2;
    window_height = height * 0.8;

    difference()
    {

        // main body
        linear_extrude(height = height, scale = ext_scale) difference()
        {
            square([ width, width ], center = true);

            rotate([ 0, 0, 45 ]) difference()
            {
                square([ width * 2, width * 2 ], center = true);
                square([ width - corner_cuts, width - corner_cuts ], center = true);
            }
        }

        // central cut out where shafts couple
        translate([ 0, 0, -zFite / 2 ]) cylinder(h = height + zFite, d = inner_dia);

        // windows
        for (i = [0:3])
            rotate([ 0, 0, i * 90 ])
                translate([ width / 2 - window_width / 2, 0, window_height / 2 + (height - window_height) / 2 ])
                    cube([ window_depth, window_width, window_height ], center = true);

        // base screw holes
        for (i = [0:3])
            rotate([ 0, 0, i * 90 + 45 ]) translate([ base_screws_cdist / 2, 0, -zFite / 2 ])
            {
                cylinder(h = height + zFite, d = base_screws_diameter);
                translate([ 0, 0, thickness ]) cylinder(h = height - thickness + zFite, d = base_screws_diameter * 1.5);
            }

        // faceplate screw holes
        for (i = [0:3])
            rotate([ 0, 0, i * 90 ]) translate([ face_screws_cdist / 2, 0, -zFite / 2 ])
            {
                cylinder(h = height + zFite, d = face_screws_diameter);
                translate([ 0, 0, 0 ]) cylinder(h = thickness + zFite, d = face_screws_diameter * 1.5);
            }
    }
}
