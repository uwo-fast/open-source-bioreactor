// parameters for the 3D printers this design is meant to be buildable on
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A printer is TOOLING, not a part - the same status as the tube cutter and the deburring tool,
// which the purchase list already carries. Nothing here ends up in the reactor. What it is for is
// that the model prints its own parts, so what a builder owns is a real constraint on the design,
// and until this file existed that constraint was a comment guessing at what "anyone building this
// owns". Exporting the parts and measuring them showed the guess was wrong in the direction that
// matters: the lid did not fit the machine the guess was about.
//
// BUILD VOLUME IS THE ONLY FIELD, because it is the only one any of this reads. Speed, chamber,
// nozzle and material range decide whether a print comes out well; they cannot decide whether it
// fits, and a field that does no work is a field that goes stale unnoticed. See
// docs/design-conventions.md on numbers that do not do anything.
//
// Figures are the manufacturers' own. Two carry a caveat and both are noted on the row.

//                          ["name"             [x,    y,    z  ]]
printer_prusa_core_one   = ["prusa_core_one",   [250,  220,  270]];
printer_voron_250        = ["voron_250",        [250,  250,  250]];
printer_bambu_x1c        = ["bambu_x1c",        [256,  256,  256]];
printer_prusa_core_one_l = ["prusa_core_one_l", [300,  300,  330]];
printer_bambu_h2d        = ["bambu_h2d",        [325,  320,  325]];
printer_sovol_sv08       = ["sovol_sv08",       [350,  350,  345]];
printer_voron_350        = ["voron_350",        [350,  350,  350]];
printer_prusa_xl         = ["prusa_xl",         [360,  360,  360]];

// voron_250 covers both the 2.4 and the Trident at that size; they share a 250 mm cube. The 350
// row is the 2.4, whose Z matches its bed - a Trident 350 is 350 x 350 x 250 and would be its own
// row if anyone wanted it.
//
// bambu_x1c is also the P1S and the X1E, which share the frame and the plate.
//
// bambu_h2d is the SINGLE-NOZZLE figure. The headline 350 x 320 x 325 is the volume reachable
// across BOTH nozzles, which no single part can use; one part gets 325 x 320 x 325, and dual-nozzle
// printing gets 300. Registered at what one part can actually have.
//
// A NOMINAL BED IS NOT ALL USABLE. Purge towers, skirts and the plate's own clamps take some of it,
// and how much is a slicer setting rather than a property of the machine. So these are the printer's
// numbers and a part that only just fits one is a part to look at twice - printer_z_margin in
// head.scad is the only place this project puts a number on that.

printers = [printer_prusa_core_one, printer_voron_250, printer_bambu_x1c, printer_prusa_core_one_l,
            printer_bambu_h2d, printer_sovol_sv08, printer_voron_350, printer_prusa_xl];

// Accessors live here rather than in a printer.scad, because there is no geometry to separate from
// them - the same split shafts.scad and steel_tubes.scad use.
function printer_name(type)     = type[0];
function printer_build_x(type)  = type[1][0];
function printer_build_y(type)  = type[1][1];
function printer_build_z(type)  = type[1][2];

// derived
//
// The largest DISC a bed takes, which is the test a lid needs: a circle has the same width at every
// angle, so it cannot be turned to fit a bed narrower than itself. This is why the y of a
// 250 x 220 machine is what rules it out and not its x.
function printer_max_disc(type) = min(printer_build_x(type), printer_build_y(type));

// Whether a part's bounding box fits, allowed to sit either way round on the bed but not tipped:
// laying a tall part down changes which faces meet the plate, which is a decision about the print
// rather than about whether it fits, and this file does not get to make it.
function printer_fits(type, size) =
  size[2] <= printer_build_z(type)
  && (
    (size[0] <= printer_build_x(type) && size[1] <= printer_build_y(type))
    || (size[1] <= printer_build_x(type) && size[0] <= printer_build_y(type))
  );

// The registered printers that can build a part of this size, by name. Empty is the answer that
// matters: it means the part cannot be made on anything this project claims to support.
function printers_fitting(size) =
  [for (p = printers) if (printer_fits(p, size)) printer_name(p)];

// example usage - keep commented, this file is include'd and a bare echo would fire in every
// consumer (see shaft_couplings.scad for the same note)
// echo(printers_fitting([252, 252, 18]));
