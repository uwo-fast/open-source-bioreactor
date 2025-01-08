use <FunctionalOpenSCAD/functional.scad>;

height = 500;
diameter = 300;
corner_radius = 50;
corner_radius_base = 30;
thickness = 5;
neck = 30;
flat_to_neck = 10;
punt = 5;

arcFn = 64;
rotextFn = 64;

show_pts = false;
show_2d = false;
show_3d = true;
pts_r = 2;

outerline = square([ diameter, height ], center = true);
innerline = square([ diameter - (2 * thickness), height - (2 * thickness) ], center = true);

if (show_pts)
    showPoints(outerline, r = pts_r, $fn = 16); // show the points of the resulting poly

function corners(outline, corner_rad, corner_rad_base = undef) = [for (i = [0:3])
        let(xfactor = outline[0][i][0] / abs(outline[0][i][0]), yfactor = outline[0][i][1] / abs(outline[0][i][1]),
            radius = is_undef(corner_rad_base) ? corner_rad : (i == 1 || i == 2 ? corner_rad_base : corner_rad),
            c_pt = [ outline[0][i][0] - (radius * xfactor), outline[0][i][1] - (radius * yfactor) ],
            corner = arc(r = radius, angle = 90, offsetAngle = 180 + (i * -90), c = c_pt, center = false,
                         internal = false, $fn = arcFn))([reverse(corner)])];

outer_punt = [[ 0, outerline[0][1][1] - punt ]];

if (show_pts)
    color("orange") showPoints(outer_punt, r = pts_r, $fn = 16);

inner_punt = [[ 0, innerline[0][1][1] - punt ]];

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

neck_poly_nxny = translate([ outerline[0][0][0] + corner_radius + flat_to_neck, outerline[0][0][1] - neck + thickness ],
                           [[thickness, neck], [thickness, 0], [0, 0], [0, neck - thickness]]); //

if (show_pts)
    color("brown") showPoints(neck_poly_nxny, r = pts_r, $fn = 16); // show the points of the resulting poly

neck_poly_pxny =
    translate([ outerline[0][3][0] - corner_radius - flat_to_neck, outerline[0][3][1] - neck + thickness ],
              mirror([ 1, 0 ], [ [ 0, neck - thickness ], [ 0, 0 ], [ thickness, 0 ], [ thickness, neck ] ]));

if (show_pts)
    color("brown") showPoints(neck_poly_pxny, r = pts_r, $fn = 16); // show the points of the resulting poly

result = concat(neck_poly_nxny, outerCorner_nxny, outerCorner_nxpy, outer_punt, outerCorner_pxpy, outerCorner_pxny,
                neck_poly_pxny, innerCorner_pxny, innerCorner_pxpy, inner_punt, innerCorner_nxpy, innerCorner_nxny);

// show the first and last point in pink and yellow
if (show_pts)
{
    color("pink") showPoints([result[0]], r = pts_r, $fn = 16);
    color("yellow") showPoints([result[len(result) - 1]], r = pts_r, $fn = 16);
}

if (show_2d)
    color("Aqua") poly2d(result);

result3d = rotate_extrude(angle = 180, poly = result, $fn = rotextFn);
if (show_3d)
    color("Azure", 0.5) translate([ diameter * 1.1, 0, 0 ]) rotate([ 0, 180, 0 ]) poly3d(result3d);