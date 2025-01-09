use <FunctionalOpenSCAD/functional.scad>;

height = 305;
diameter = 220;
corner_radius = 25;
corner_radius_base = 12.5;
thickness = 5;
neck = 25;
neck_corner_radius = 10;
flat_to_neck = 0;
punt_height = 5;
punt_width = 30;

rim_rad = 4;

body_height = height - neck - neck_corner_radius;

arcFn = 64;
rotextFn = 64;

show_pts = false;
show_2d = false;
show_3d = true;
pts_r = 1;

outerline = square([ diameter, body_height ], center = true);
innerline = square([ diameter - (2 * thickness), body_height - (2 * thickness) ], center = true);

if (show_pts)
    showPoints(outerline, r = pts_r, $fn = 16); // show the points of the resulting poly

function corners(outline, corner_rad, corner_rad_base = undef) = [for (i = [0:3])
        let(xfactor = outline[0][i][0] / abs(outline[0][i][0]), yfactor = outline[0][i][1] / abs(outline[0][i][1]),
            radius = is_undef(corner_rad_base) ? corner_rad : (i == 1 || i == 2 ? corner_rad_base : corner_rad),
            c_pt = [ outline[0][i][0] - (radius * xfactor), outline[0][i][1] - (radius * yfactor) ],
            corner = arc(r = radius, angle = 90, offsetAngle = 180 + (i * -90), c = c_pt, center = false,
                         internal = false, $fn = arcFn))([reverse(corner)])];

outer_punt =
    [ [ -punt_width / 2, outerline[0][1][1] - punt_height ], [ punt_width / 2, outerline[0][1][1] - punt_height ] ];

if (show_pts)
    color("orange") showPoints(outer_punt, r = pts_r, $fn = 16);

inner_punt =
    [[punt_width / 2, innerline [0] [1] [1] - punt_height], [-punt_width / 2, innerline [0] [1] [1] - punt_height]];

if (show_pts)
    color("orange") showPoints(inner_punt, r = pts_r, $fn = 16);

outerCornersPoly = corners(outerline, corner_rad = corner_radius, corner_rad_base = corner_radius_base);

outerCorner_nxny = flatten(outerCornersPoly)[0];
outerCorner_nxpy = flatten(outerCornersPoly)[1];
outerCorner_pxpy = flatten(outerCornersPoly)[2];
outerCorner_pxny = flatten(outerCornersPoly)[3];

if (show_pts)
    color("red") showPoints(outerCornersPoly, r = pts_r, $fn = 16); // show the points of the resulting poly

innerCornersPoly = corners(innerline, corner_radius - thickness, corner_radius_base - thickness);

innerCorner_nxny = reverse(flatten(innerCornersPoly)[0]);
innerCorner_nxpy = reverse(flatten(innerCornersPoly)[1]);
innerCorner_pxpy = reverse(flatten(innerCornersPoly)[2]);
innerCorner_pxny = reverse(flatten(innerCornersPoly)[3]);

if (show_pts)
    color("blue") showPoints(innerCornersPoly, r = pts_r, $fn = 16); // show the points of the resulting poly

// neck corner

neck_outer_corner_nx =
    arc(r = neck_corner_radius - thickness, angle = 90, offsetAngle = 0,
        c = [ outerline[0][0][0] + corner_radius, outerline[0][0][1] - neck_corner_radius + thickness ], center = false,
        internal = false, $fn = arcFn);
neck_inner_corner_nx = arc(r = neck_corner_radius, angle = 90, offsetAngle = 0,
                           c = [ outerline[0][0][0] + corner_radius, innerline[0][0][1] - neck_corner_radius ],
                           center = false, internal = false, $fn = arcFn);

neck_outer_corner_px =
    arc(r = neck_corner_radius - thickness, angle = 90, offsetAngle = 90,
        c = [ outerline[0][3][0] - corner_radius, outerline[0][3][1] - neck_corner_radius + thickness ], center = false,
        internal = false, $fn = arcFn);
neck_inner_corner_px = arc(r = neck_corner_radius, angle = 90, offsetAngle = 90,
                           c = [ outerline[0][3][0] - corner_radius, innerline[0][3][1] - neck_corner_radius ],
                           center = false, internal = false, $fn = arcFn);

if (show_pts)
{
    color("green")
    {
        showPoints(neck_outer_corner_nx, r = pts_r, $fn = 16);
        showPoints(neck_outer_corner_px, r = pts_r, $fn = 16);
    }
    color("orange")
    {
        showPoints(neck_inner_corner_nx, r = pts_r, $fn = 16);

        showPoints(neck_inner_corner_px, r = pts_r, $fn = 16);
    }
}

// neck flat
neck_flat_nx = translate(
    [
        outerline[0][0][0] + corner_radius + neck_corner_radius - thickness, innerline[0][0][1] - neck -
        neck_corner_radius
    ],
    [ [ 0, 0 ], [ thickness, 0 ] ]);
neck_flat_px = translate(
    [ outerline[0][3][0] - corner_radius - neck_corner_radius, innerline[0][3][1] - neck - neck_corner_radius ],
    [ [ 0, 0 ], [ thickness, 0 ] ]);

if (show_pts)
{
    color("purple")
    {
        showPoints(neck_flat_nx, r = pts_r, $fn = 16);
        showPoints(neck_flat_px, r = pts_r, $fn = 16);
    }
}

// rim
rim_nx = arc(r = rim_rad, angle = 180, offsetAngle = 90,
             c =
                 [
                     outerline[0][0][0] + corner_radius + neck_corner_radius - thickness,
                     innerline[0][0][1] - neck - neck_corner_radius +
                     rim_rad
                 ],
             center = false, internal = false, $fn = arcFn);

rim_px = arc(r = rim_rad, angle = 180, offsetAngle = 270,
             c =
                 [
                     outerline[0][3][0] - corner_radius - neck_corner_radius + thickness,
                     innerline[0][3][1] - neck - neck_corner_radius +
                     rim_rad
                 ],
             center = false, internal = false, $fn = arcFn);

if (show_pts)
{
    color("teal")
    {
        showPoints(rim_nx, r = pts_r, $fn = 16);
        showPoints(rim_px, r = pts_r, $fn = 16);
    }
}

result = concat(neck_outer_corner_nx, outerCorner_nxny, outerCorner_nxpy, outer_punt, outerCorner_pxpy,
                outerCorner_pxny, neck_outer_corner_px, rim_px, reverse(neck_flat_px), reverse(neck_inner_corner_px),
                innerCorner_pxny, innerCorner_pxpy, inner_punt, innerCorner_nxpy, innerCorner_nxny,
                reverse(neck_inner_corner_nx), reverse(neck_flat_nx), reverse(rim_nx));
echo("result: ", result);

// show the first and last point in pink and yellow
if (show_pts)
{
    color("pink") showPoints([result[0]], r = pts_r, $fn = 16);
    color("yellow") showPoints([result[len(result) - 1]], r = pts_r, $fn = 16);
}

if (show_2d)
    color("Aqua") poly2d(result);

transformed_result = translate([ 0, body_height / 2 ], rotate(a = 180, v = [ 0, 1, 0 ], poly = result));

result3d = rotate_extrude(angle = 180, poly = transformed_result, $fn = rotextFn);
if (show_3d)
    color("Azure", 0.5) poly3d(result3d);