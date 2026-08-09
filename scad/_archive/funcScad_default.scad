use <FunctionalOpenSCAD/functional.scad>;

// multiple nested function calls, with the results of a function passed as poly parameter for another
color("yellow") poly3d(translate([10, 0, 0], poly=scale([1, 2, 4], poly=sphere(1, $fn=30))));

r = 2;

// assigning function results to intermediate variables
shape = sphere(r=r, $fn=20);
moved_shape = translate([-10, 0, 0], poly=shape);
color("blue") poly3d(moved_shape);

// calculate properties of the geometry
echo(str("volume of blue: ", signed_volume(moved_shape), " mm^3"));
echo(str("volume of perfect sphere: V = 4/3*PI*r^3 = ", (4 / 3) * PI * pow(r, 3), " mm^3"));

// make a vector containing multiple shapes
shape_vector = [for (i = [-1:1]) translate([0, i * 10, 0], poly=cube(i * 2 + 4, center=true))];
color("green") poly3d(shape_vector);

// compute properties on lists
b = bounds(shape_vector);
echo(bounds=b);
volumes = [for (shape = shape_vector) signed_volume(shape)];
echo(volumes=volumes);
volumesum = signed_volume(shape_vector);
echo(volumesum=volumesum);

// show corner points of a bounding volume
color("red") showPoints(b, r=0.5, $fn=40);

// debug point locations
showPoints(shape_vector);
// echo(shape_vector=shape_vector);

// display the bounding volume
color([1, 1, 1, 0.1]) translate(b[0]) cube(b[1] - b[0]);
