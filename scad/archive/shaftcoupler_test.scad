include <NopSCADlib/core.scad>
use <NopSCADlib/vitamins/shaft_coupling.scad>

//                    name              L       D        d1     d2     flex?
// SC_5x8_rigid  = [ "SC_5x8_rigid",    25,     12.5,    5,     8,     false ];

SC_8x8_rigid = ["SC_5x8_rigid", 25, 12.5, 8, 8, false];

type = SC_8x8_rigid;

shaft_coupling(type, colour="MediumBlue");

length = sc_length(type);
diameter = sc_diameter(type);
diameter1 = sc_diameter1(type);
diameter2 = sc_diameter2(type);
flexible = sc_flexible(type);

echo(
  "length = ", length, ", diameter = ", diameter, ", diameter1 = ", diameter1, ", diameter2 = ", diameter2,
  ", flexible = ", flexible
);
