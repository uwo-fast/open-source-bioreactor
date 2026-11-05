/**
 * @file column_lid.scad
 * @brief A printed top lid for the lab's acrylic column reactors, carrying this repo's ports
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A SPIKE, kept apart from the reactor: it reads the bayonet port and NPT mount libraries and
 * changes nothing of theirs, and nothing of the reactor's reads it. `just column-lid` builds and
 * checks every variant; the repo's own checks skip scad/_spikes/.
 *
 * The column is a clear acrylic tube with a radially bolted flange at each end. Its own flange
 * carries the o-ring in a groove in its face, so this lid seals by clamping it: a flat flange the
 * bolts pass through, and under it a plain plug into the bore that centres it, as the jar lid's
 * plug does in the jar's mouth. The plate is the jar lid's 18 mm, an 8 mm flange and a 10 mm
 * plug, because the bayonet pins are cut for that panel, so the reactor's printed pins and blanks
 * fit these ports unchanged.
 *
 * A column is not always full: over a deep headspace, what hangs from a flat lid does not reach the
 * culture. pocket_depth sinks the ports' panel that far down the bore, as the floor of a cup with
 * a pocket_wall wall, open at the top so a hand reaches in to turn the pin. 0 is the flat lid.
 *
 * FRAME: z = 0 is the lid's top face, the face the bolt heads sit on; the flange and the plug run
 * down from it, the plug into the column's bore. The ports' panel has its top face at
 * z = -pocket_depth, which is the top face itself on a flat lid.
 */

include <../../custom/bayonet_interfaces.scad>;
use <../../custom/bayonet_port.scad>;
include <../../utils/npt_threads.scad>;
use <threads-scad/threads.scad>;

/* [Variant] */

// What the lid carries: a 1/2 NPT thread, one std bayonet port, or a ring of std ports round one, all in the middle
variant = "ring"; // [npt, centre, ring]
// The lid as it sits on the column, with a blank pin in each port, or turned as it prints
part = "lid"; // [lid, assembly, print]

/* [Column - measured] */

// Flange outer diameter, mm
flange_od = 160;
// Bolt circle diameter, centre to centre across, mm
bolt_circle = 139.5;
// Bolt holes, evenly spaced
bolt_count = 8;
// Bolt hole diameter, mm
bolt_hole = 10;
// The tube's bore, which the plug drops into, mm
tube_id = 100;

/* [Lid] */

// Flange thickness, the plate the bolts pass, mm
flange_thickness = 8;
// How far the plug drops into the bore, mm
plug_height = 10;
// Diametral clearance of the plug in the bore, the jar lid's, mm
plug_allowance = 0.4;
// Plastic left between a port's hole and the plug's edge, mm
port_wall = 2;
// Gap kept between neighbouring ports' flanges, mm
port_gap = 3;
// How far below the top face the ports' panel sinks into the bore, as a cup's floor; 0 is a flat lid, mm
pocket_depth = 0;
// The cup's wall, when there is one, mm
pocket_wall = 5;

/* [Hidden] */

$fn = $preview ? 64 : 128;
eps = 0.01;

port = bayonet_std;
npt = npt_thread_by_name("1/2 NPT");

plate = flange_thickness + plug_height; // the panel the bayonet pins are cut for
plug_r = (tube_id - plug_allowance) / 2;
hole_r = bayonet_port_hole_radius(port);
flange_r = bayonet_flange_radius(port);

pocketed = pocket_depth > 0;
pocket_r = plug_r - pocket_wall; // the cup's inside
floor_z = -pocket_depth; // the ports' panel's top face

// The ring: as far out as the plug lets a hole go, and as many as fit round it with port_gap
// between flanges. It has to clear the middle port's flange by the same gap. In a cup the pins'
// flanges sit on its floor, so they have to stay port_gap inside its wall too.
ring_r = pocketed
  ? min(pocket_r - port_wall - hole_r, pocket_r - port_gap - flange_r)
  : plug_r - port_wall - hole_r;
ring_n = floor(180 / asin((flange_r + port_gap / 2) / ring_r));

// Where each port sits, [x, y]; the first is the middle one.
ports =
  variant == "npt" ? []
  : variant == "centre" ? [[0, 0]]
  : concat([[0, 0]], [for (i = [0:ring_n - 1]) ring_r * [cos(i * 360 / ring_n), sin(i * 360 / ring_n)]]);

// The 1/2 NPT is cut straight through the plate, with no boss, so the top stays flat and every
// variant prints the same way, top face on the bed. The thread is the thermocouple mount's -
// npt_thread_mount()'s ScrewHole call and numbers - and like it is straight, not tapered. 18 mm
// of plate holds a 1/2 NPT fitting's 8.1 mm hand-tight and 13.6 mm made-up engagement (ASME
// B1.20.1 L1 and L2).
npt_allowance = 0.6; // the mount's

assert(
  variant == "npt" || variant == "centre" || variant == "ring",
  str("column_lid: no variant \"", variant, "\"; npt, centre or ring")
);
assert(
  bolt_circle / 2 + bolt_hole / 2 < flange_od / 2,
  str("column_lid: the bolt holes reach r ", bolt_circle / 2 + bolt_hole / 2, ", past the flange's ", flange_od / 2)
);
assert(
  bolt_circle / 2 - bolt_hole / 2 > plug_r,
  str("column_lid: the bolt holes come in to r ", bolt_circle / 2 - bolt_hole / 2, ", over the plug's ", plug_r)
);
assert(
  variant != "ring" || ring_r >= 2 * flange_r + port_gap,
  str(
    "column_lid: a ring at r ", ring_r, " leaves ", ring_r - 2 * flange_r,
    " mm between its flanges and the middle port's, under the ", port_gap, " wanted"
  )
);
assert(variant != "ring" || ring_n >= 1, "column_lid: no port fits on the ring");
assert(pocket_depth >= 0, str("column_lid: pocket_depth is how far down, not up; got ", pocket_depth));
assert(
  !pocketed || len(ports) == 0 || flange_r + port_gap <= pocket_r,
  str("column_lid: a pin's ", flange_r * 2, " mm flange does not sit in a ", pocket_r * 2, " mm cup")
);
assert(
  npt_thread_major_diameter(npt) / 2 < (pocketed ? pocket_r : plug_r) - port_wall,
  str("column_lid: the NPT thread, r ", npt_thread_major_diameter(npt) / 2, ", does not fit in the plug")
);

echo(str(
  "column lid: ", variant, "; ", flange_od, " mm across, ", bolt_count, " x ", bolt_hole, " mm holes on ",
  bolt_circle, " mm; a ", flange_thickness, " mm flange over a ",
  pocketed
    ? str(
      "cup of ", plug_r * 2, " mm in the ", tube_id, " mm bore, ", pocket_r * 2, " mm inside, its ", plate,
      " mm floor ", pocket_depth, " mm below the top face, ", pocket_r - flange_r,
      " mm round a pin's flange for the fingers; "
    )
    : str(plug_height, " mm plug of ", plug_r * 2, " mm in the ", tube_id, " mm bore; "),
  variant == "npt"
    ? str("a 1/2 NPT thread through the ", plate, " mm plate")
    : variant == "centre"
      ? "one std bayonet port in the middle"
      : str(
        ring_n, " std ports on a ", ring_r * 2, " mm ring and one in the middle, ",
        2 * ring_r * sin(180 / ring_n) - 2 * flange_r, " mm between ring flanges and ",
        ring_r - 2 * flange_r, " mm to the middle one"
      )
));

// The flange, and under it the plug - on a pocketed lid a cup down to the floor, hollowed above it.
module column_lid_blank() {
  difference() {
    union() {
      translate([0, 0, -flange_thickness])
        cylinder(d=flange_od, h=flange_thickness);
      translate([0, 0, floor_z - plate])
        cylinder(r=plug_r, h=plate - flange_thickness - floor_z + eps);
    }
    if (pocketed)
      translate([0, 0, floor_z])
        cylinder(r=pocket_r, h=pocket_depth + eps);
  }
}

module column_lid() {
  difference() {
    if (variant == "npt")
      ScrewHole(
        outer_diam=npt_thread_major_diameter(npt) - npt_allowance,
        height=plate * 1.1,
        position=[0, 0, floor_z - plate - plate * 0.05],
        rotation=[0, 0, 0],
        pitch=npt_thread_pitch(npt),
        tooth_angle=60,
        tolerance=0.4,
        tooth_height=npt_thread_pitch(npt) * 0.55
      ) column_lid_blank();
    else
      column_lid_blank();
    for (i = [0:bolt_count - 1])
      rotate([0, 0, i * 360 / bolt_count])
        translate([bolt_circle / 2, 0, -plate])
          cylinder(d=bolt_hole, h=plate * 3, center=true);
    for (p = ports)
      translate([p[0], p[1], floor_z - plate / 2])
        cylinder(r=hole_r, h=plate + 2 * eps, center=true);
  }

  // The coupling's lock half in each hole, as the jar lid carries them: one printed piece.
  for (p = ports)
    translate([p[0], p[1], floor_z])
      bayonet_port(type=port, part="lock", panel_thickness=plate);
}

// As it prints, with no supports but under a cup's flange: a flat lid on its top face, the plug
// up; a pocketed one on its floor, the cup rising and the flange's ledge supported.
if (part == "print")
  if (pocketed)
    translate([0, 0, plate - floor_z])
      column_lid();
  else
    rotate([180, 0, 0])
      column_lid();
else
  color("SlateBlue")
    column_lid();

if (part == "assembly")
  for (p = ports)
    color("DarkSlateGray")
      translate([p[0], p[1], floor_z])
        bayonet_port(type=port, part="pin", panel_thickness=plate, text_labels=true, label="BLANK");
