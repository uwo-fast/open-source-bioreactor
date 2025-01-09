/*
neck_poly_nxny = translate([ outerline[0][0][0] + corner_radius + flat_to_neck, outerline[0][0][1] - neck + thickness ],
                           [[thickness, neck], [thickness, 0], [0, 0], [0, neck - thickness]]); //

if (show_pts)
    color("brown") showPoints(neck_poly_nxny, r = pts_r, $fn = 16); // show the points of the resulting poly

neck_poly_pxny =
    translate([ outerline[0][3][0] - corner_radius - flat_to_neck, outerline[0][3][1] - neck + thickness ],
              mirror([ 1, 0 ], [ [ 0, neck - thickness ], [ 0, 0 ], [ thickness, 0 ], [ thickness, neck ] ]));

if (show_pts)
    color("brown") showPoints(neck_poly_pxny, r = pts_r, $fn = 16); // show the points of the resulting poly
 */