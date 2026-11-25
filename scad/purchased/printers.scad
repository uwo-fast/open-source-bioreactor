// parameters for the 3D printers this design is meant to be buildable on
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Tooling, not a part: the printers builders own constrain the design. Build volume is the only
// field because nothing reads any other. Figures are from the manufacturers.

//                         ["name"              [x,    y,    z  ]]
printer_prusa_mk3s       = ["prusa_mk3s",       [250,  210,  210]];
printer_prusa_core_one   = ["prusa_core_one",   [250,  220,  270]];
printer_voron_250        = ["voron_250",        [250,  250,  250]];
printer_bambu_x1c        = ["bambu_x1c",        [256,  256,  256]];
printer_prusa_core_one_l = ["prusa_core_one_l", [300,  300,  330]];
printer_bambu_h2d        = ["bambu_h2d",        [325,  320,  325]];
printer_sovol_sv08       = ["sovol_sv08",       [350,  350,  345]];
printer_voron_350        = ["voron_350",        [350,  350,  350]];
printer_prusa_xl         = ["prusa_xl",         [360,  360,  360]];

// voron_250 covers the 2.4 and the Trident; the 350 row is the 2.4. bambu_x1c is also the P1S
// and X1E. bambu_h2d is the single-nozzle figure, not the 350 headline.
// A nominal bed is not all usable (purge towers, skirts, clamps); `just export-parts` reports each
// part's fit.

printers = [printer_prusa_mk3s, printer_prusa_core_one, printer_voron_250, printer_bambu_x1c,
            printer_prusa_core_one_l, printer_bambu_h2d, printer_sovol_sv08, printer_voron_350,
            printer_prusa_xl];

function printer_name(type)     = type[0];
function printer_build_x(type)  = type[1][0];
function printer_build_y(type)  = type[1][1];
function printer_build_z(type)  = type[1][2];

// Largest disc that fits the bed. Rotating a circle does not help on a bed narrower than it.
function printer_max_disc(type) = min(printer_build_x(type), printer_build_y(type));

// Whether a part bounding box fits the bed in either orientation, without tipping it over.
function printer_fits(type, size) =
  size[2] <= printer_build_z(type)
  && (
    (size[0] <= printer_build_x(type) && size[1] <= printer_build_y(type))
    || (size[1] <= printer_build_x(type) && size[0] <= printer_build_y(type))
  );

// The registered printers that can build a part of this size, by name.
function printers_fitting(size) =
  [for (p = printers) if (printer_fits(p, size)) printer_name(p)];
