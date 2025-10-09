use <FunctionalOpenSCAD/functional.scad>;

animate = false; // set to true to animate, false to use fixed angle
static_angle = 125; // static angle in degrees

// use time step to animate angle 0-360 with 0.1 degree increments
angle = animate ? $t * 360 : static_angle; // angle in degrees

// angle = 165;                             // angle in degrees
n_pts = 8; // number of points
fn = floor((n_pts - 1) * (360 / angle)); // fraction number based on desired angle and number of points

echo("fn=", fn); // print to console

poly = arc(
  r=1, angle=angle, offsetAngle=0, c=[0, 0], center=false, internal=false,
  $fn=fn
); // result assigned to variable

echo("poly: ", poly); // result printed to console
echo("len poly", len(poly)); // result printed to console

color("blue") poly2d(poly); // poly result passed as parameter to poly2d module

showPoints(poly, r=0.1, $fn=16); // show the points of the resulting poly
