# Changelog

All notable changes to this project are documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `dev/decisions.md` records, under Settled, that the gas line and the electronics in
  `purchased-parts.csv` stay off the CAD: neither has geometry to check against the vessel, head or
  frame. The gas line is bought parts joined by tubing routed at the bench, whose losses `head()`
  already echoes, and the electronics reach the reactor by cable with nothing drawn mounting them.

### Changed

- turbidity-sensor is pinned to `v0.2.0`, which pins syringe-actuator `v0.1.1`, whose lid gains a
  tab closing the barrel's slot in the front wall, flush with the front face. Only the drawn
  actuator changes; the sampler's prints export byte-identical.
- turbidity-sensor is pinned to `v0.3.0`, which renames the sampler housing the sampler case, at
  `hardware/sampler-case/sampler_case.scad`; the adapter changes only its include path, the prints
  are unchanged, and the README, `LICENSING.md`, `docs/build.md` and `dev/decisions.md` call it
  the sampler case.
- CI also runs `just check` and `just test` on apt's OpenSCAD 2021.01, the oldest version
  supported, and fails if anything but `check-clash` and `check-baffle-cage`, which need the
  manifold backend, prints SKIP there. It runs when `test` does.

### Fixed

- `docs/ports-layout.md` said the lid carries twelve bayonet locks; that is the twelve-port lid,
  and a jar whose mouth is under the 142 mm those need (`jar_1p5L`, `jar_1gal_155` and
  `jar_6p5gal`, at 88.4, 95.8 and 137 mm) takes the six-port lid, with six locks 60° apart.
- The DO plume echo and its "DO probe in the gas" warning were silenced whenever the upper impeller
  had no flow number, as `impeller_folded_axial_3`, `_4` and `_6` have none; the flow number now
  gates only the feed-past-the-face echo. Every echo transcript is unchanged.
- Four stale figures in the docs: `jar_1gal_180x197`'s DO lean ceiling is the full 4.5°, not
  nearer 2.5°; `docs/references.md` names `do_probe_port_tilt_max`, not
  `do_probe_port_tilt_degrees`, and calls 4.5° a bench-limit ceiling the geometry can only lower;
  `docs/agitation.md`'s ring figures come from `jar_10L` with `baffle_name = "lid"` (132.773 mm,
  1.90 D, 105 mm off the floor); and `purchased-parts.csv` gives the filter's drop as 6.8208 times
  the vessel back-pressure (14093.9 against 2066.3 Pa), not twelve.

### Removed

- `dose_3` from `head.scad`'s `dosing_pump_functions`, a name no port has carried since the
  sampler took its port; nothing changes.

## [0.1.0] - 2026-11-22

### Added

- `README.md` with the project title.
- The original bioreactor design files, imported from OSF: the bill of materials
  `BOM_Bioreactor.ods`, and FreeCAD models with printable STLs in `models3d/` for the impeller,
  lid stencil, motor mount, O2 probe mount, pH probe mount, thermocouple mount and the pump stand
  (side and top). STL, STEP and FCStd files are stored with Git LFS.
- Data from the 19 November 2024 microalgae experiment (`microalgae_Nov19th2pm_raw.csv` and three
  cleaned stages) with its cleaning and plotting scripts: `clean_temps1.py` drops temperature
  readings outside 20-45 °C, `clean_start2.py` drops pH readings below 7 taken while the probe
  settled, `plot_sensors.py` plots rolling averages of temperature, dissolved oxygen and pH, and
  `plot_actuators.py` plots the on/off state of the stirring motor and sample pump.
- Light analysis in `analysis/light_analysis/`: spectrometer irradiance data for an LED at 1 cm,
  a fluorescent lamp at 1 cm and a fluorescent lamp at 90 µW peak; `clean_spectro.py`, which blanks
  negative irradiance values; and `plot_spectro.py`, which plots absolute irradiance against
  wavelength over 300-800 nm, with the plot for each condition.
- `plot_spectro_all.py`, which overlays the three light conditions in one figure
  (`combined_irradiance_plot.png`).
- An OpenSCAD rebuild of the CAD in `scad/`, starting with `jar.scad`, which draws the culture jar
  as a 2D outline with rounded corners, a neck and a punt and rotates it into a solid (uses the
  FunctionalOpenSCAD library), plus FunctionalOpenSCAD example sketches in `scad/funcSCAD_proto/`.
- `scad/impeller.scad`, a parametric impeller module (radius, fin count, twist, fin scale and
  rotation, blade width, sphere or cylinder hub, shaft hole), tuned to the current impeller: radius
  45 mm, 3 fins, 100° twist, 2 mm blades, 80 mm tall, 7.5 mm cylinder hub, 4.3 mm hole radius, with
  an outer ring around the blades.
- `scad/peristaltic_pump_mount.scad`, a mount that holds a peristaltic pump by its base, derived
  from Printables model 857120.
- `scad/base.scad`, the base the jar sits in, with four threaded-rod bosses and hex nut traps
  (300 mm jar, 20 mm high, 8 mm wall, 5 mm floor, 10 mm rods).
- `scad/assembly.scad`, which puts the jar in the base, an inverted half-height top base over it,
  and four threaded rods between them (8.5 mm rod, 0.2 mm hole tolerance, size 6 nut of 14.5 mm,
  threads optionally drawn with threads-scad).
- `scad/lid.scad`, a lid that sits in the top base with a plug sized to the jar opening (0.4 mm
  radial and 0.2 mm height tolerance); render flags in `assembly.scad` for each part; first print
  files `base_v1` and `impeller_v1` (STL and 3MF) in `scad/stls/`.
- Print files for impeller v2 (`impeller_v2.stl`, `impeller.3mf`).
- Print files for the top base (`top_base_v1.stl`, `top_base.3mf`).
- Ribs between the bases: `base()` takes `rods` (2-4) to make a partial ring spanning that many
  rods. The lid gets a centre shaft hole and a 22.6 x 5 mm bearing pocket. Print files `lid_v1.stl`,
  `lid.3mf`, `rib_v1.stl` and `rib.3mf`.
- Strip grow lights: `scad/strip_light.scad` models one light, and `scad/utils.scad` adds
  `circular_pattern()`; the assembly places 6 lights (336 x 14.1 x 9 mm) around the jar. The
  impeller is placed in the assembly at 0.45 of the jar diameter with an 8.2 mm shaft hole, with
  placeholders for the 300 x 8 mm shaft and the motor. Print file
  `peri_pump_mount_NKP-DC-S10B_v1` (STL and 3MF).
- `scad/probe_mount.scad`, a rounded square plate for a long cylindrical sensor with a probe
  pocket, an entry hole and four screw holes; the assembly places one for a 10 mm probe with a 4 mm
  entry on a 20 x 4 mm plate with 3 mm screws.
- Motor drive parts: `scad/dcmotor.scad` (DC motor and gearbox models), `scad/motor_mount.scad`
  (tapered mount with windows, 50 mm high and 42 mm wide, 3.5 mm base screws at 32 mm and 4 mm
  face screws at 30 mm), and an 8 x 8 mm rigid shaft coupling from NopSCADlib, all placed in the
  assembly.
- `scad/peri_NKP-DC-S10B.scad`, the peristaltic pump mount configured for the NKP-DC-S10B pump.
- Rod spacers between the bases and ribs (2 mm wall, 0.2 mm bore and 0.4 mm height tolerance).
- Lid flat cuts to clear the lights, and probe holes in the lid: 4 of 5 mm, 4 of 7.5 mm and 2 of
  20 mm.
- A `render_all` flag and OpenSCAD Customizer sections in `assembly.scad`.
- Print files for the motor mount (`motor_mount_v1`), the ribs (`rib_cut_v2.stl`, `rib_sld_v2.stl`,
  `ribs_v2.3mf`) and the rod spacers (`rod_spacer_low_v1.stl`, `rod_spacer_up_v1.stl`,
  `rod_spacers_v1.3mf`), and an `export_cut` switch in `assembly.scad` that renders a single rib,
  with or without the light cut, for export.
- Print files `base_v2` (STL and 3MF, plus `base_v2_simple.3mf`), a base printed without
  horizontal layers, and `rib_v2`; the rib files were then renamed `rib_v3`, with `ribs_v3.3mf`
  replacing `ribs_v2.3mf`.
- Nuts drawn on the threaded rods below and on top of the base in the assembly.
- `scad/_config.scad`, shared preview settings (0.1 mm z-fighting offset in preview, 32 facets in
  preview and 128 in a full render) included by the part files, and `scad/lib/trapezium.scad`, a
  trapezium shape module.
- Probe models: `scad/probe_atlas.scad` (`atlas_probe()`, an Atlas-style probe with sensing tip,
  body, tapered neck and cable) and `scad/probe_thermocouple.scad` (`threaded_thermocouple()`,
  with hex flats and a body optionally threaded at 14 TPI for 1/2" NPT). The assembly places a pH
  probe, a DO probe and the thermocouple at the lid under a `render_probes` flag, with their
  dimensions as Customizer parameters.
- `scad/probe_clamp.scad`, a split collar that clamps around a probe: a 30 mm collar that opens to
  32 mm, 15 mm tall, with 3 mm walls, two tabs with 3.2 mm screw holes and a 6 mm rod mount; the
  opening animates with `$t`.
- `probe_pinch_collar()` in `probe_clamp.scad`. The assembly holds the pH and DO probes in pinch
  collars on 4.6 mm rods, 90 mm long and reaching 10 mm into the lid, with `animate_probe_clamp`
  and `shut_probe_clamp` flags and Customizer sections for each probe and its clamp.
- `scad/tube_lock.scad`, a bayonet connector for probes and tubes in the lid (uses
  Bayonet-Lock-SCAD), rendering either the lock or the pin: 3 pins, 30° sweep, clockwise, 7 mm
  inner and 12 mm outer radius, 0.2 mm allowance, 1.5 mm pins, 10 mm tall with a 5 mm neck and an
  O-ring groove for a 1.6 mm O-ring. A `render_tube_pinlock` flag renders a pin in the assembly.
  The pins print with 0.1 mm O-ring interference, an allowance on the neck, two holes for pliers
  to insert, turn and remove them, and the bore engraved into the neck (`R`/`D`); print files
  `tube_mount_pins_d6mm` and `tube_mount_pins_r3mm-d6mm` (STL and 3MF).
- Print file `base_split_mk3.3mf`.
- `scad/thermocouple_lock.scad`, a bayonet pin with a 1/2" NPT threaded mount (21.34 mm, 14 TPI,
  20 mm tall) for the thermocouple, rendered in the assembly by `render_thermocouple_pinlock`; print
  files `thermocouple_mount_pins_v1` and `tube_mount_pins_others.3mf` (`tube_mount_pins_r0-d0`,
  `tube_mount_pins_r2p4mm-d4p8mm`, `tube_mount_pins_r3p8mm-d7p6mm`).
- `scad/turbidity_monitor_mount.scad`, a first rough plate (60 x 5 x 130 mm) holding a 27.8 mm
  motor with four 3.5 mm screw holes 48 mm apart and a 28 mm turbidity sensor, 74 mm apart; print
  file `turbidity_monitor_mount` (STL and 3MF).
- `scad/lib/rpi4_case.scad`, a Raspberry Pi 4 case modified from RavenSCAD by George Onoufriou,
  with top, bottom and full views.
- A first peristaltic pump side mount in `assembly.scad`: an insert block that fits a strip-light
  pocket (15 mm tall) with a 2.4 mm plate that holds the pump motor by its face screws; print file
  `pump_side_mount_v0` (STL and 3MF).
- `docs/procurement.md`, with the bearing selection: 8 mm shaft, sealed single-row ball bearing,
  grease lubricated, stainless steel balls (McMaster-Carr 6153K71).
- `scad/peri_pump_side_mount.scad`, the side mount as a module, `peri_pump_side_mount()`: a
  14.1 x 7.6 x 15 mm insert, a 2 mm bridge and a 2.4 mm flange 5 mm wide with 4 mm screws 48 mm
  apart. The assembly places side mounts in the middle light gaps of the upper ribs under
  `render_peri_side_mount`.
- `scad/mould_negative.scad`, a negative mould for casting the impeller: a box with 10 mm walls
  around the impeller, a pour hole at the top tapering from the 15 mm hub diameter to 3 mm,
  4.1 mm corner holes for feet, and 1 mm drain holes under the hub and along the bottom of each fin
  to let air escape, with a rotatable cross-section view; print file `impeller_mould_negative`
  (STL and 3MF).
- Print files `base_mk3.3mf`, `top_base_mk3.3mf`, and the lid and tube lock pins reprinted in PC
  (`lid_PC_XL.3mf`, `lid_PC_mk3.3mf`, `tube_mount_pins_PC.3mf`).
- `TODO.md`, starting with the idea of a curve in the bayonet connector holes to grip tubes better.
- `scad/motor_mount_new.scad`, a three-part motor mount concept that is easier to assemble and
  service: a base with a 4 mm flange screwed to the lid with four 3.1 mm screws and a 10 mm collar,
  a 100 mm tube that slides over the collars, is cross-screwed (3.1 mm) to both ends with nut traps
  and has four windows for reaching the faceplate screws, and a 6 mm top that takes the motor
  faceplate screws (4.2 mm, 27.6 mm apart) around the 22 mm motor boss; 0.15 mm fit allowance.
  Print files `motor_mount_new_base`, `motor_mount_new_middle` and `motor_mount_new_top` (STL and
  3MF).
- Print file `impeller_PP.3mf`.
- `scad/phdo_pinch.scad`, a pinch sleeve that grips a pH or DO probe: a shell of two 0.6 mm walls
  around the 35.6 mm x 16.3 mm probe body and its tail (8.7 mm tapering to 4.3 mm over 24.5 mm),
  with pinch tabs cut from a window 80% of the body length and separated from the shell by a
  0.8 mm gap, and the tail shell cut halfway so it flexes; print file `phdo_pinch_v0` (STL and
  3MF).
- `scad/phdo_lock.scad`, a bayonet pin for a pH/DO probe port, with the thermocouple lock's pin
  parameters and no threaded mount.
- `scad/generic_bayolock_port.scad`, `generic_lock()`: the bayonet pin or lock with neck, O-ring
  groove and inner fill, without a thread; `phdo_lock.scad` renders through it.
- `animate_pinch` in `phdo_pinch.scad` and a `pinch_offset` argument to `phdo_pinch()`, which
  animate the pinch tabs opening and closing with `$t`; off, the pinch renders closed for printing.
- A second OpenSCAD tree, `scad-v2/`, for splitting the design into three subassemblies: vessel,
  head and frame. It starts with `vessel.scad` (the jar as `vessel()`), empty `head.scad` and
  `frame.scad`, an `assembly.scad` header, a `_config.scad` with 64 facets in preview and 128 in a
  full render, and copies of the current parts in `custom/` (base, generic bayonet port, impeller, a
  plain two-cylinder lid, motor mount, peristaltic pump side mount, pH/DO lock and pinch,
  thermocouple and tube locks) and `purchased/` (DC motor, Atlas probe, thermocouple, strip light).
- `scad-v2/assembly.scad` renders the vessel, with `render_vessel`, `render_head`, `render_frame`
  and `render_all` flags, `vessel_x_sec` for a 180° cross section, and the vessel dimensions as
  Customizer parameters split into coupling (305 mm high, 220 mm diameter, 5 mm wall, 25 mm neck)
  and customization (corner radii 25 and 12.5 mm, neck corner 13.5 mm, punt 5 x 30 mm, rim 2 mm).
- `scad-v2/_shelf/probe_clamp.scad`, the probe clamp kept on the shelf in the new tree.
- `cylindrical_flex_tab.scad` documents the part shape it expects in a diagram: body diameter and
  length, tail major and minor diameters and tail length, and end diameter.
- `scad-v2/frame.scad` defines `frame(jar_height, jar_diameter)`, a first frame subassembly: the
  strip lights, the lower and upper bases with light pockets, two levels of ribs with peristaltic
  pump frame mounts on the upper ribs, and rod spacers, with render flags and Customizer parameters
  (six 336 x 14.1 x 7.6 mm lights, 8.5 mm rods, 25 mm lower and 10 mm upper base). Opened on its
  own it renders everything around a 305 x 220 mm jar.
- `scad-v2/purchased/atlas_probe.scad` with the `atlas_probe()` model, and `atlas_probes.scad`, a
  first set of registered dimensions: a pH probe (10 mm neck tapering to 5 mm over 26 mm,
  15.6 x 35 mm body, 12 x 115 mm tip, 3 mm wire) and a DO probe (the same with a 16 mm body), each
  with its colours.
- `scad-v2/purchased/strip_lights.scad`, registered strip light dimensions as
  `[name, [width, depth, length, radius]]` rows, starting with a `generic` light of
  14.1 x 7.6 x 336 mm with a 0.5 mm radius.
- `scad-v2/purchased/thermocouple_probe.scad` and `thermocouple_probes.scad`, registered
  thermocouple dimensions, starting with a `generic` probe: 10 x 12 mm neck, 26 x 5 mm flats,
  21 x 20 mm body, 3.5 x 115 mm tip and 3 x 10 mm wire.
- `scad-v2/purchased/peri_pump.scad`, a work-in-progress peristaltic pump model, with a
  `peri_pumps.scad` registry for pump types (no entries yet). `peri_pump_head()` assembles
  everything but the motor: a `pump_cassette()` 28 mm high with 3 mm walls, a path for a 3 mm tube
  with two entry channels and a 4 mm motor shaft hole; a roller carrier as wide as the 50 mm motor
  with a tapered collet that grips the shaft and three rollers (10 mm bore, 20 mm outer diameter,
  20 mm long) on posts; and a `pump_cassette_cover()`.
- A first registered DC motor in `scad-v2/purchased/dc_motors.scad`: `generic`, a 34 x 30 mm motor
  with a 36 x 26 mm gearbox and an 8 x 20 mm gearbox shaft.
- Getter functions for registered parameters: `atlas_probe_neck_dia()`, `atlas_probe_neck_height()`,
  `atlas_probe_neck_taper_dia()`, `atlas_probe_body_dia()`, `atlas_probe_body_height()`,
  `atlas_probe_tip_dia()`, `atlas_probe_tip_height()`, `atlas_probe_wire_dia()` and
  `atlas_probe_accent_color()`, and `dc_motor_diameter()`, `dc_motor_length()`,
  `gearbox_diameter()`, `gearbox_length()`, `gearbox_shaft_diameter()` and
  `gearbox_shaft_length()`.
- `scad-v2/_shelf/nopscadlib_m8_rod_and_nut.scad`, an example that draws a 100 mm M8 threaded rod
  and an M8 nut with NopSCADlib and echoes the nut's across-flats, across-corners and height.
- `scad-v2/head.scad` starts from the head parts of the `scad/` assembly, copied as they were:
  render flags, lid parameters (0.4 mm radial and 0.2 mm height allowance, 22.6 x 7.5 mm bearing),
  impeller parameters (0.45 of the jar diameter, 60 mm tall, 4 fins, 55° twist), motor, shaft and
  motor mount parameters, bayonet lock parameters, the lid with its twelve bayonet lock holes, and
  the tube and thermocouple pin locks.
- `vessel_opening_diameter(diameter, corner_radius, neck_corner_radius)` in `scad-v2/vessel.scad`,
  the vessel's opening as the diameter less twice the shoulder and neck corner radii; `vessel()`
  uses it and asserts that it matches the neck geometry.
- `scad-v2/electronics_stand.scad`, a first electronics stand: three 200 mm 2020 aluminium
  extrusions (NopSCADlib), one along each of X, Y and Z, joined by a 3D corner bracket with grub
  screws. Nothing is mounted on it yet.
- `purchased-parts.csv`, a list of the purchased parts with category, model, part number, quantity,
  source, link, unit price (with a confidence) and key specifications: LED grow light strips, a
  36 mm planetary gear motor, an air pump, the Atlas Scientific DO (ENV-40-DOX) and pH (ENV-40-PH)
  probes, a Mean Well LRS-150-12 power supply, PETG filament, the 10 L glass jar, the McMaster-Carr
  6153K71 bearing, the shaft coupling and shaft, M8 threaded rods, a silicone gasket, EPDM O-rings,
  peristaltic pumps, an inline air filter, a Raspberry Pi 4B, the Slice_DCMT, Slice_RLHT and
  Slice_PHDO boards, and a Type K thermocouple.
- `scad-v2/cart.scad`, an idea for a two-tier rolling cart holding four bioreactors, two per tier
  one in front of the other: 3030 extrusion posts tied by three rectangles of rails with 3D corner
  brackets, on four swivel castors, sized from the bioreactor envelope (220 mm diameter, 450 mm
  tall, 20 mm side clearance, 60 mm tier gap) and drawing translucent envelopes to check the fit.
  The castor is a new purchased part, `castor(type, swivel)` in `scad-v2/purchased/castor.scad`,
  with a `castors.scad` registry: `generic_castor` has a 60 x 60 mm plate with 6 mm bolt holes
  46 mm apart, a 75 mm mount height and a 50 x 22 mm wheel.
- A registered thermocouple for the McMaster-Carr 3872K117 Type K probe (1/2" NPT male, 9 in x
  1/8 in probe, 4 ft fiberglass cable), `mcmaster_3872K117_thermocouple_probe`, with a
  3.175 x 228.6 mm tip and a 21.3 mm body; the fitting dimensions are still approximate. It is the
  thermocouple in `purchased-parts.csv` and is described in `docs/procurement.md`, and
  `thermocouple_probes.scad` opened on its own renders the generic and 3872K117 probes.
- `docs/procurement.md` notes the motor currently in the lab: the 36GP-3530 planetary gear DC
  motor (12 V, 1154 RPM, 50 kg torque).
- A `print_corner` flag in `scad-v2/electronics_stand.scad` renders the 3D corner bracket alone,
  without grub screws, for printing (the stand preview draws it translucent); print file
  `electronics_stand_corner_bracket_v1` (STL and 3MF).
- Three more registered jars in `scad-v2/purchased/vessels.scad`: `jar_1gal_180x197` (Almcmy
  1 gallon glass cookie jar, 197 mm high, 180 mm diameter, 148 mm opening, 12.5 mm neck, 7 x 100 mm
  punt, 2.5 mm rim), `jar_6p5gal_305x470` (Big Mouth Bubbler EVO 2 6.5 gallon glass fermentor,
  18.5 in high and 12 in diameter, 12 mm wall, 137 mm opening, 50 mm neck and corners) and
  `jar_1p5L_109x215` (Mainstays 1.5 L glass canister, 215 mm high, 109.22 mm diameter, 4 mm wall,
  87.5 mm opening, 7 x 15 mm punt, no rim radius), each with its product link. `generic_vessel`
  is 300 x 200 mm with a 150 mm opening, a 10 mm neck, 10 mm corners and a 10 x 50 mm punt.
- The head renders the port pins in its twelve bayonet locks again. A `head_ports` table gives
  each lock a type and bore radius: one thermocouple port, two probe ports, and three tube ports
  each of 3, 2.4 and 1.5 mm bore. Tube ports are the generic `bayonet_port()` with its bore set
  and labelled; probe ports take new Probe Port Parameters (35.6 mm body length, 15.9 mm body,
  tail 8.7 to 4.3 mm over 24.5 mm, 10 mm connector, 1.2 mm collet wall, 0.6 mm allowance, 1.0 mm
  tab gap, 0.5 mm deflection, 7° tilt, 25 mm transition); `render_tube_pinlock`,
  `render_probe_pinlock` and `render_thermocouple_pinlock` select them. The head adds
  `bayonet_shell_thickness` (2.5 mm) and `bayonet_oring_interference` (0.1 mm).
- `scad-v2/bottle_holder.scad`, a square sleeve that holds a bottle (62.6 mm bottle, 130 mm tall,
  sleeve 0.3 of its height, 6 mm walls, 0.2 mm allowance), with dovetail tails on two faces and
  sockets on the other two so holders stack in a grid; print file `bottle_holder_v1.stl`.
- `scad-v2/utils/dovetail.scad`: `dovetail_pts()`, a dovetail cross section with its crown corners
  rounded, and `dovetail()`, a prism of it grown by an `allowance` for sockets. The bottle holder
  uses it, and its sockets are now grown by the 0.2 mm allowance.
- Print files `bottle_holder.3mf` and `bottle_holder_v2.stl`.
- Telemetry from the July 2026 _Chlorella vulgaris_ CCPC 90 run in
  `analysis/experiment/chlorella-ccpc90-2026-07/`: the full export from 2026-07-23 to 2026-07-31
  (about 8.7 days, 29 signals, 587,061 rows in `signals_raw_long.csv`), per-signal CSVs, export
  manifests and `export_index.tsv`, with a README giving the culture, export provenance, schema,
  a signal glossary and the run timeline: an impeller failure on 07-23, two reboots, and a
  roughly 12 h power outage from 07-30 to 07-31 that left mis-stamped post-boot data.
- Reproducible analysis pipelines: each run and method has a `pipeline.py` that rebuilds its
  derived data into a git-ignored `derived/` and its plots into `figures/`, and checks its output
  with `--verify` (the 2024 run against recorded sha256 digests, the 2026 run against the
  exporter's row counts, the light method against the count of dropped below-floor samples). The
  2024 pipeline reconstructs the old `cleaned0/1/2` files and also writes `derived/tidy.csv`,
  aligned on real timestamps; the 2026 pipeline writes per-signal splits and a 1-minute
  `pivoted_1min.csv`. `analysis/lib/rawio.py` reads both raw formats. A `justfile` adds
  `analysis-setup`, `analysis`, `analysis-run <name>` and `analysis-method <name>`, and
  `analysis/pyproject.toml` pins pandas and matplotlib (Python 3.11 or later).
- `analysis/README.md` (layout, running the pipelines, and the rule that raw data is committed and
  never edited while everything derived is regenerated), and READMEs for the 2024 microalgae run
  and the light-irradiance method. The 2024 README records that the organism, medium and vessel
  were never noted, and that the old cleaning stacked channels by row although each has its own
  clock, so figures from that run show pH about 2.5 min and actuator state about 5 min behind
  their timestamps on average, by up to ±16 min.
- `TODO.md` adds giving `gearbox_36pg_5p18` an input recess for the motor's boss (8 x 3 mm) and
  shaft (2 x 8 mm), which currently intersect the gearbox body.
- A registered replacement gearmotor, the E-S Motor 36D (RobotShop RM-ESMO-16Q), for when the
  36GP-3530 is unavailable: `motor_36pg_3429_5p2` (34 x 29.4 mm) on `gearbox_36pg_3429_5p2`
  (36 x 26.5 mm, 8 x 20 mm output shaft, four M3 faceplate screws on a 28 mm bolt circle). The
  registry notes what its schema cannot hold: the output shaft's D-flat (15 mm long, 7 mm across)
  and the undimensioned input bore, registered undef. `gearboxes.scad` notes that
  `faceplate_cdist` is a bolt-circle diameter.
- A registered Uline S-19317P 1 gallon wide-mouth jar, `jar_1gal_155x251`, measured off the jar:
  251 mm high, 155.3 mm diameter, 3 mm wall, a 95.8 mm opening (listed as 4") with a 30 mm neck,
  a 25 mm shoulder corner (leaving a 4.75 mm neck corner), an 8 mm base corner, a 6 x 73 mm punt
  and no rim radius, since its 110/400 threaded finish ends in a flat sealing face.
- Gearbox bosses: registered gearbox rows take an optional output boss `[d, l]` (a pilot register
  standing off the output face, with the output shaft on top of it) and input boss (a recess in
  the input face, with the input bore sunk past it), read with `gearbox_out_boss()` and
  `gearbox_in_boss()`, so a motor's boss and shaft seat in the gearbox instead of intersecting
  it. Both registered gearboxes have a 22 x 3 mm output boss and an 8 x 3 mm input boss, and the
  input pockets are opened by a 0.2 mm `gearbox_input_render_allowance`. `TODO.md` drops the
  input recess item.
- A registered McMaster-Carr 1245N31 thermocouple (Type K, 1/2" NPT male, 6 in x 1/8 in probe),
  `mcmaster_1245N31_thermocouple_probe`, with a 152.4 mm tip, for shorter vessels.
- Engraved marks on the ports, on the face seen once installed: tube ports mark the bore
  (`Ø6`), probe ports the probe and the collet bore they are cut for (such as `PH Ø15.6`), and
  all carry the coupling designation, interface diameter and pin radius (`B20-1.2`).
  `bayonet_port()` takes an optional `label` to replace the bore mark, shrinks long labels to stay
  inside the flange, and engraves 0.6 mm deep. The thermocouple port wraps `1/2NPT`, its bore and
  the coupling mark around the upper half of its NPT mount wall instead, since the mount covers
  the flange face. `atlas_probe_name()` reads a probe's registered name.
- Print file `thermocouple_mount_pins_v2.stl`, a print of the new thermocouple port;
  `thermocouple_mount_pins.3mf` updated.
- `docs/ports-layout.md` and a `docs/ports_layout.drawio` diagram, giving the reasoning behind the
  lid's port layout: three baffles 120° apart, the air input as far as practical from the DO and
  pH probes, the air output away from the air input and the splash and foam region, acid and base
  dosing near the air input and mixing sector but away from the pH probe, the temperature probe
  beside the DO probe it compensates, and the remaining ports spread with clearance.
- `head.scad` previews the lid's 24 bayonet halves as bare shells, without their pins and
  channels, under `fast_bayonet_preview` (on by default), through bayonet-lock-scad 0.10.0's
  `$bayonet_shell_only`. The preview's normalized CSG drops from 1005 to 577 elements in
  `head.scad` and from 1192 to 764 in `assembly.scad`; renders are unaffected.
- **Breaking:** The Atlas pH probe is registered in its four grades from the datasheets, each with
  its product page and datasheet link: `ph_mini`, `ph_consumer`, `ph_lab` and `ph_research`
  (shafts 27.8, 116.3, 115.0 and 113.1 mm; 2.6 mm cable on the mini, 2.8 mm on the rest). They
  share the measured 15.6 x 36.0 mm cap, so only the port's engraved mark differs between them.
  `ph` is removed; `head.scad` and the probe port preview use `ph_lab`, the grade in the lab, and
  `atlas_probe` is a `generic` placeholder row showing the format.
- **Breaking:** The Atlas DO probe is registered in its two grades, `do_mini` and `do_lab`
  (stepped shafts registered as their sum, 39.0 and 69.1 mm; 2.6 mm cable), sharing the measured
  16.0 x 35.6 mm cap, with product page and datasheet links. `do` is removed and `head.scad` uses
  `do_lab`.
- Five Atlas conductivity probes in the registry, with product page and datasheet links:
  `ec_mini_k1`, `ec_k0p1`, `ec_k1`, `ec_k10` and the 8 cm `ec_k0p1_8cm`, whose body diameter is
  assumed at 16.0 mm since its sheet gives none. The file header records that Atlas states totals
  as cap plus shaft, without the strain relief boot.
- Four Atlas ORP probes in the registry: `orp_mini`, `orp_consumer`, `orp_lab` and `orp_gold`,
  with product page and datasheet links; the consumer and lab rows assume a 16.0 mm body and are
  identical apart from their names, since electrode material is not registered. The header lists
  the detail the schema does not carry.
- `scad/purchased/strip_lights.scad` registers four strip lights as products, with their links:
  `rwntao_13in` (14.1 x 7.6 x 330 mm, 3 tubes per cord), `grow_13in` (14.25 x 330 mm),
  `grow_16in` (14.30 x 400 mm) and `grow_8p6in` (14.15 x 217 mm), the last three 4 per cord and
  reusing the RWNTAO depth and radius. `generic_strip_light` is a format placeholder
  (14.2 x 7.6 x 330 mm) no longer in `strip_lights`. `frame.scad` selects the light to pocket the
  base for with `frame_light` (`rwntao_13in`); the RWNTAO length is 330 mm instead of 336 mm, which
  moves no geometry, and `purchased-parts.csv` agrees. `TODO.md` adds registering lights per cord
  and driving the frame from it.
- The frame cuts a radial channel from each light pocket out through the wall, the light's width
  and depth in section, so the light's cord can escape once the light is seated.
- A `double_ribs` flag in `frame.scad`, on by default, stacks a second pair of ribs at each level
  turned 90°, closing the gaps the 90° rib arcs leave in the ring, at twice the rib height per
  level.
- `scad/utils/bolt_pattern.scad`, a bolt circle helper for flanged joints whose tie rods already
  take some positions: `bolt_post_count()` sizes the count from the ASME VIII-1 Appendix 2 maximum
  bolt spacing, 2a + 6t/(m + 0.5), rounded up to a multiple of the rods; `bolt_post_spacing()`
  gives the spacing to check for wrench room; `bolt_pattern_pts()` places the posts, optionally
  leaving out the rods; and `bolt_pattern_bores()` and `bolt_pattern_bolts()` bore and draw them
  (NopSCADlib screws). It sets no `$fn`.
- **Breaking:** The lid flange is bolted to the top base on one shared bolt circle of twelve posts,
  the four tie rods among them: bolt heads bear under the top base and nuts land on the lid, and
  the rods take a nut on top of the lid too. `assembly.scad` derives the pattern under a new Head
  to Frame Joint section (`n_rods` 4, `joint_bolt` `M8_hex_screw`, `lid_gasket_factor` 0.5),
  asserts the bolt spacing is at least 2.5x the bolt diameter for a wrench, and reads the circle
  and hole size from the frame's new `frame_bolt_circle_diameter()` and
  `frame_rod_hole_diameter()`. `frame()` takes `lid_flange_height`, `n_rods`, `bolt_pts` and
  `bolt_screw`, and `head()` takes `post_pts` and `post_hole_diameter`; the rod loops follow
  `n_rods`.
- A second impeller on the shaft above the first, mirrored so it pumps against the lower one,
  spaced by `impeller_spacing_factor` (1.0 impeller diameters). `head.scad` asserts the two do not
  overlap and the upper one stays inside the vessel, and its design notes cover impeller spacing
  and why the upper one is mirrored rather than turned over.
- `bayonet_pin_face_radius()` and `bayonet_lock_bore_radius()` in `bayonet_port.scad`: the
  coupling's two mating surfaces, the interface radius less and plus half the allowance.
- Swirl baffles hung from their own bayonet ports: `scad/custom/bayonet_baffle_port.scad` adds
  `bayonet_baffle_port()`, a pin half carrying a flat plate through the vessel axis, blended from
  the port face over `transition_height` and rounded at the bottom, labelled `BAFF L<length>`. Its
  width is derived by `bayonet_baffle_width()` as the widest plate that drops through the lock's
  bore (19.4 mm on the lid). `head.scad` adds a `baffle` port type and replaces one 3 mm, one
  2.4 mm and one 1.5 mm tube port with three evenly spaced baffles, with Baffle Parameters
  (100 mm long, 4 mm thick, 10 mm transition, 0.2 mm bore, 2 mm impeller and 1.5 mm neck
  clearance), a `render_baffle_pinlock` flag, and asserts that the baffles are evenly spaced, stop
  above the upper impeller and stay inside the jar's neck.
- `scad/utils/oring_gland.scad`, the rules for a static face-seal gland from Apple Rubber's static
  seal table, derived from the purchased ring: `oring_gland_od()` (the ring's own outer diameter),
  `oring_gland_width()` (1.5x the cord), `oring_gland_depth()` (0.75x the cord at the default 25%
  squeeze) and `oring_gland_fill()`.
- **Breaking:** The lid seals to the jar. The pressure boundary is a flat gasket cut from 1.5 mm
  EPDM sheet, sitting in a recess in the flange's glass-facing face and squeezed 25%
  (`lid_gasket_compression`) on the flat land on top of the rim, with 1.0 mm left at each edge
  (`lid_gasket_land_margin`) for the flange to bottom on, so the flange lands where it did. A
  2.62 mm o-ring in a groove round the middle of the 10 mm plug (`lid_plug_oring_squeeze` 0.18)
  centres the plug in the neck; it is not a second pressure boundary. `head()` takes
  `vessel_wall_thickness`, echoes the gasket cut and the plug ring's ID range, and asserts the
  recess, the groove width, the gland fill and the 2.0 mm wall between the groove and the port
  bores. `oring_gland_width()` steps its ratio at the cords the table lists (1.5 up to 1.78 mm,
  down to 1.273 above 5.33 mm), and `oring_stretch()` gives a ring's stretch onto a groove.
- Models of the seals: `scad/purchased/oring.scad` draws `oring(type, id)` from an `orings.scad`
  registry holding `oring_23x1p5_epdm` (23 x 1.5 mm, the port seal) and `oring_as568_160_epdm`
  (133.02 x 2.62 mm, the plug ring), and `scad/custom/sheet_gasket.scad` cuts `sheet_gasket()`.
  The head draws the rim gasket, plug ring and port rings under `render_seals`, each at its free
  size on the diameter it is installed at, so it overlaps what it seals against by its squeeze.
  `bayonet_std` names its registered ring and the head takes `lid_plug_oring` instead of a cord
  size, asserting the plug ring stretches 0-5% onto its groove (4.27% for the AS568-160).
  `cross_section_active` now cuts the head in half as well as the vessel, in preview only.
- `oring_containment()` in `oring_gland.scad`, the share of a cord's section held inside its
  groove, and an assert that at least 75% of the plug o-ring's section sits in its groove (79.7%
  now). The port glands are not checked, since their fixed 0.75 depth always holds 80.4%.
- **Breaking:** The motor mount fastens to the lid with heat-set inserts: four blind insert holes
  in the lid, on the same screw circle the mount's flange reads, take an M4 cap screw
  (`motor_mount_base_screw`) into an F1BM4 insert (`motor_mount_base_insert`), drawn under
  `render_motor_mount_fasteners`. `motor_mount()` takes `base_screw_hole_diameter`, so the base
  screws are sized by the lid joint instead of the gearbox's `screws_diameter`, and each end plate
  counterbores its own screw. The head asserts the screw matches the insert and at least 3.0 mm
  of lid is left under it (`motor_mount_insert_floor_min`); the mount asserts a positive middle
  height and a body wide enough for the gearbox screws' counterbores.
- A registered insert, `insert_m4x4p7_ss` in `scad/purchased/heat_set_inserts.scad`: McMaster-Carr
  97163A152, 18-8 stainless, M4, 4.7 mm installed length in a 5.6 mm hole, picked over the brass
  94180A351 in `docs/procurement.md`. It replaces F1BM4, so the lid's insert holes are 4.75 mm
  deep with 13.25 mm of lid left under them and the screw is an M4x8 instead of 12 mm long.
  `render_motor_mount_inserts` and `render_motor_mount_screws` replace
  `render_motor_mount_fasteners`, the head asserts the inserts clear the bearing pocket (6.85 mm),
  and `TODO.md` adds the fastener rows to the BOM.
- `just check` and `just check-scad`, which evaluate every SCAD file outside `_archive/` and
  `_shelf/` (`OPENSCAD` picks the binary) and fail on an `ERROR` on stderr, on a listed entry file
  that renders nothing, or on any other file that emits geometry into the files that include it.
- Nine asserts on inputs that used to build wrong geometry without a word: a bearing pocket
  leaving less than 3.0 mm of lid (`lid_blind_pocket_floor_min`, which replaces
  `motor_mount_insert_floor_min`), a shaft ending below the lid's outer face, a shaft drawn into
  the jar's floor, an impeller whose top ring is wider than the opening, a `head_ports` count
  that differs from `lid_holes_n`, a negative gasket recess, a negative bearing allowance, a nut
  pocket deeper than the top base, and a stack that leaves no gap between the lid and the top
  base. `jar_6p5gal_305x470` (137 mm mouth, 145.16 mm impeller) now fails the impeller assert.
- `assembly.scad` asserts the joint bore, sized from the rod's allowance, clears the joint bolt
  (a `threaded_rod_hole_allowance` of 0.2 mm fails). The plug o-ring assert names the ring as the
  wrong one for the bore and quotes the ID window the groove takes.
- A registered rim gasket sheet, `sheet_epdm_1p6_60a` in `scad/purchased/gasket_sheets.scad`:
  McMaster-Carr 8525T65 EPDM, 1/16 in (1.5875 mm), 60A, 12 x 12 in, described in
  `docs/procurement.md`. `lid_gasket_sheet` replaces `lid_gasket_thickness` (1.5 mm), so the
  recess is cut from the real thickness. `head_gasket_factor()` derives the ASME VIII-1 gasket
  factor from its hardness (0.5 under 75A, 1.0 at or over), and `assembly.scad` reads
  `lid_gasket_factor` from it, so a 75A sheet would bolt the joint with 16 posts instead of 12.
- The head asserts the joint bores keep `lid_holes_offset` (2.0 mm) inside the flange's outer
  edge.
- `purchased-parts.csv` rows for every part the model calls for: the rim gasket sheet (8525T65,
  replacing the 142 mm ID silicone gasket row, which could not pass over the 142.6 mm plug), 8
  M8x30 joint bolts, 20 M8 nuts, the 97163A152 heat-set inserts, 4 M4x8 socket head screws and
  the AS568-160 plug o-ring, each quoting what the model echoes; the threaded rod cut length is
  322 mm instead of about 324.5 mm. Four fastener rows still need part numbers, which `TODO.md`
  now lists as the open BOM item.
- `scad/utils/stirred_tank.scad`, the stirred-tank relations with their cited bands (D/T 0.3-0.5,
  0.4-0.5 for axial impellers in cell culture, and the impeller spacing band); `head()` echoes the
  impeller's D/T and spacing against them and prints a `WARNING` line when either falls outside,
  without asserting. `docs/agitation.md`, `docs/references.md` and `docs/design-conventions.md`
  record the agitation design basis, its sources and the conventions the model is built to, and
  `TODO.md` gains a drive and aeration section: naming the faceplate bolt circle, registering
  the drive's speed and ratio, deciding the drive motor, designing the sparger, and
  characterising the blade twist and height.
- Drive speeds and ratio: `dc_motors.scad` rows take `[no_load_out_rpm, rated_out_rpm]` at the
  gearbox output (`dc_motor_no_load_output_rpm()`, `dc_motor_rated_output_rpm()`), 1154 rpm
  no-load for the 36GP-3530 (rated left undef) and 1400/950 rpm for the 36PG-3429, and
  `gearboxes.scad` rows take the reduction as a number (`gearbox_ratio()`, 5.18 and 5.2).
  `stirred_tank.scad` adds Reynolds number, tip speed, shaft power, culture volume and mean and
  peak dissipation for water at 20 °C, with Po 0.99 (measured on a 4-blade folded axial blade) and
  Grenville's pitched-blade factor of 16 as named borrowed constants. `head()` echoes them for each
  registered speed, or says when a motor registers none; nothing asserts and there is no tip-speed
  limit. A new `culture_fill_fraction` (0.8, 8.17 L in the 10 L jar) sets the culture volume.
- A registered encoder gearmotor, the E-S Motor 36PG-555PM-14-EN (RobotShop RM-ESMO-071):
  `motor_36pg_555pm_14_en` (36 x 57 mm, 420 rpm no-load, 320 rpm rated) on `gearbox_36pg_555pm_14`
  (14:1, 36 x 34.5 mm, 4 mm screws on a 28 mm bolt circle), spanning the 255-410 rpm band
  `docs/agitation.md` sets. Motor rows register rated output torque in N m
  (`dc_motor_rated_output_torque()`: 0.4903 for this motor, 0.0637 for the 36PG-3429), and `head()`
  echoes the impeller pair's torque against it. The gearbox length (taken from the 36PG-3429 at
  14:1) and the encoder's length are inferred, as `docs/procurement.md` and `purchased-parts.csv`
  say; the parts list carries this motor instead of the RM-ESMO-16Q.
- Motor rows register a fitted encoder as `[ppr, channels]`, counted per channel at the motor shaft
  (`dc_motor_encoder()`), and `dc_motor_encoder_counts_per_output_rev()` derives counts per output
  turn through the gearbox: 672 for the 36PG-555PM-14-EN (12 x 2 edges x 2 channels x 14). `head()`
  echoes the speed this resolves over `encoder_speed_window` (0.1 s, 0.89 rpm), or says when a
  motor has no encoder.
- `docs/references.bib`, the bibliography as BibTeX for import into a reference manager: 33
  entries, the 26 with a DOI taken from Crossref, each with a note carrying the grade and
  verification status `references.md` tracks. Every DOI in `docs/references.md` is a link, and
  Contreras 1998 gains its DOI.
- `scad/custom/impellers.scad`, a registry of impeller types, rows
  `[name, [n_blades, blade_angle, width_ratio, twist], pumping, [Po, Po_tol], x]`, read with
  accessors in `impeller.scad` (`impeller_blades()`, `impeller_power_number()`,
  `impeller_dissipation_factor()` and others): `rushton_6` (Po 4.17 ± 0.14), `pbt_45_4` (Po left
  to Medek's correlation), `folded_axial_3`, `folded_axial_4` and `folded_axial_6` (Po 0.79, 0.99
  and 1.34), and `twisted_paddle_4`, the printed blade, with no measured Po. Nothing reads it yet.
- Further relations in `stirred_tank.scad`: off-bottom clearance (1-2 impeller diameters for
  fluidfoils, Oldshue 1997 p. 192), sparge ring diameter (1.0-2.0 impeller diameters), baffle
  width derived from the count against Oldshue's four at T/12 with an area ratio, and Medek's
  correlations for power and flow number, with `stirred_tank_medek_departures()` naming the
  envelope conditions a geometry falls outside. Nothing reads them yet.
- `head()` reports the baffles' total projected area against Oldshue's reference and warns below
  0.9, naming what one more plate would give: 0.83 on this build, 1.11 with a fourth plate.
- **Breaking:** `head()` reports the off-bottom clearance, from the impeller centreline to the
  vessel floor, in impeller diameters against Oldshue's 1-2 D band for fluidfoils (0.42 D on this
  build), and warns outside it, naming its coupling to shaft length. `head()` takes
  `vessel_punt_height`, which `assembly.scad` passes.
- **Breaking:** `scad/purchased/shafts.scad` registers the impeller shafts: McMaster-Carr 316
  stainless rotary shafts, 8 mm (-0.005/0 mm), in 200, 400, 600 and 800 mm cuts
  (`shaft_8x200_316` to `shaft_8x800_316`, 1265K64, K66, K67 and K68). `head.scad` selects
  `head_shaft` (`shaft_8x400_316`) in place of `shaft_length` and `shaft_diameter`, echoes the
  shaft's fit in the bearing bore (-0.007 to 0.005 mm), and checks the motor mount's slenderness,
  warning above 3 diameters and refusing above 5 (2.3 now). `purchased-parts.csv` lists the
  1265K66 instead of an unspecified 8 mm rod.
- `docs/procurement.md` records from the 6153K71 bearing's datasheet that it is a press fit on the
  shaft, with 0.002-0.013 mm radial clearance, that its 440C race and Buna-N seals weaken in bleach,
  a conflict with chemical sterilisation flagged for the sterilisation protocol, and that its 240 F
  limit is a third reason the assembly cannot be autoclaved. `purchased-parts.csv` adds the
  bearing's tolerances and ratings.
- `scad/purchased/set_screws.scad`, 316 stainless cup-tip set screws bound to NopSCADlib grub
  screw types: `set_screw_m4x6_316` (McMaster-Carr 92029A142, two per impeller at 120°),
  `set_screw_m4x8_316` (92029A144) and `set_screw_m3x6_316` (92029A103). The impeller hub had no
  grip on the shaft by design; `docs/procurement.md` gives the reasoning and `purchased-parts.csv`
  lists a pack of 50 M4x6.
- `docs/references.md` and `docs/references.bib` add Birch & Ahmed 1997 and Rewatkar & Joshi 1993,
  the basis for `stirred_tank_sparge_ring_band()`, with Rewatkar's scale caveat (0.57-1.5 m vessels
  and a downflow PBT, against 0.21 m and an up-pumping lower impeller here). The Oldshue entry
  records the coverage caveat (p. 191-192), the eight-to-ten-times gas criterion for axial
  impellers (p. 228) and the gassing-out method (p. 226), restates its 1-2 d band as an allowance,
  and marks its p. 214 80% sparge ring superseded by the two papers.
- `impeller()` draws flat blades at a pitch: `blade_pitch` (degrees from the plane of rotation)
  and `blade_width` draw each blade as a flat plate hinged about its own radius, its length solved
  so the outer corners sweep exactly the impeller diameter. `impeller_axial_span()` gives what a
  blade occupies along the shaft, its width times the sine of its blade angle. Nothing selects a
  pitched blade yet.
- `head_shaft_rotation` (+1, counter-clockwise from the motor end) declares which way the shaft
  turns, and `head()` derives the pumping from it, since a pitched blade reverses with the shaft:
  at +1 the lower impeller pumps up and the upper down, so the flows converge on the 73.1 mm gap
  between them; a diverging pair warns. `stirred_tank.scad` adds `stirred_tank_lower_pumps_up()`
  and `stirred_tank_pair_converges()`.
- The sparge ring is registered and reported before it is drawn: 1.44 D (`sparge_ring_ratio`), a
  4 x 10 mm radial-by-axial section (`sparge_ring_section`) with a 1.2 mm wall, at half the height
  of the inter-impeller gap, and eight 3 mm holes reported at `sparge_design_vvm` (0.5).
  `head()` reports the orifice velocity and the capillary (96 Pa) against orifice (2.4 Pa)
  pressure, and asserts the ring clears the baffles (1.49 mm) and the jar's mouth (1.46 mm).
  `stirred_tank.scad` adds gas flow, orifice velocity, capillary and orifice pressure functions.
- `scad/custom/sparge_ring.scad`, `sparge_ring()`: the hollow ring with its holes pointing
  radially inward and a feed arm running inboard along the air inlet's 240° sector, between the
  baffles at 210° and 300°, to a vertical socket under the lid port. The head draws it under
  `render_sparger`, names the feed port with `sparge_feed_port` (8) and `sparge_feed_bore` (4 mm),
  and asserts that port is a tube; `docs/ports-layout.md` records which port is the air inlet and
  why it has to stay between baffles. `just check` renders the new file as an entry.
- The sparge riser: a straight 4 x 2.5 mm tube 166.7 mm from the lid's outer face into the ring's
  socket (`sparge_riser_od`, `sparge_riser_id`, 8 mm `sparge_riser_insertion`), drawn with the
  sparger. `head()` reports its slack through the port's bore and the back-pressure the gas
  supply has to beat: 104.7 mm of culture over the ring is 1025 Pa, plus 96 Pa capillary, 1121 Pa.
  `TODO.md` adds registering the riser as a 316 stainless purchased part and sealing its 2 mm of
  slack through the 6 mm port.
- `docs/procurement.md` sizes the gas metering from the pump's specification: its 65-70 L/min and
  27 kPa are the two ends of its curve, not a simultaneous rating; it delivers over 60 L/min into
  every registered vessel, so a metering valve has to drop 24.3 kPa to hold 4.09 L/min; and a
  0-5 L/min rotameter reads 0.82-4.09 L/min on the 10 L jar at 16-82% of scale, while no single
  range covers the vessel family. `TODO.md` adds a BOM completeness check before the rebuild
  purchase, re-checking every row against the current geometry.
- `scad/purchased/air_pumps.scad` registers the air pump, `air_pump_resun_35w` (12 V, 65-70 L/min
  free flow, 27000 Pa dead-head, 35 W), and `scad/utils/gas_supply.scad` derives the pump's flow
  against a back-pressure, the throttle drop for a target flow, its implied efficiency, and the
  rotameter scale (1-50 L/min, readable from 10%) that covers a range. `head()` reports them for
  `head_air_pump` over `sparge_vvm_band` (0.1-0.5 vvm): 62.3 L/min against 1121 Pa, a 24181 Pa
  throttle and a 0-5 L/min meter, and flags the ReSun's two figures as curve ends (83.6% implied
  efficiency). `stirred_tank.scad` encodes Oldshue's gas criterion, 8x the gas stream's power for
  an axial impeller and 3x for a radial one, which caps aeration at 1.53 vvm at 420 rpm here;
  `head()` warns above it.
- `docs/design-conventions.md` writes down the method behind the rules: every number is graded as
  measured, correlated, borrowed or reasoned-not-cited; a check reports by name the validity
  conditions it departs from; a fit is reported before the part is built, with the sparge ring as
  the case; and the model should be able to catch its author.
- `just check-vessels`, part of `just check`, renders `head.scad` against every registered vessel
  and keeps a `broken` list of the vessels that fail, each with the first assert it hits (five of
  six now). It fails both when an unlisted vessel breaks and when a listed one builds.
  `vessel_name()` reads a vessel's name.
- `head()` reports the window of mouth diameters a jar has to fall in for its impeller, such as
  140.25 to 144.25 mm for the 94.5 mm impeller against the 10 L jar's 143 mm. Across the registry
  the windows are 3.5 to 10.25 mm wide and only the 10 L jar falls inside its own. The asserts
  check the same fit functions the window is swept from.
- `head_plug_oring_cord_limit()` caps the plug o-ring's cord at what the port bores leave in the
  plug wall: the plug's fit clearance plus the step from the bayonet's port hole down to its lock
  bore, 2.5 mm of groove depth or 3.05 mm of cord, the same on every vessel. Plug ring selection
  skips any ring over it. No geometry changes.
- Twenty-two plug o-rings in `orings.scad`, AS568 dash 150 to 171 (`oring_as568_150_epdm` to
  `oring_as568_171_epdm`, McMaster-Carr 8785N626 to 8785N649), all 2.62 mm (3/32 in) cord EPDM 70A
  rated -65 to 300 F, from the same water- and steam-resistant line as the port seal, together
  sealing mouths from 77 to 217 mm. `AS568-160` carries its part number, 8785N637, correcting the
  note that this line could not supply the plug ring; the Parker E0603 line was passed over (250 F,
  three times the price). `generic` and `jar_1gal_180x197` now resolve a plug ring and fail on
  baffle length instead; the 10 L jar keeps `AS568-160` at 4.27% stretch.
- `scad/utils/npt_threads.scad`, the NPT taper threads from ASME B1.20.1 (`npt_1_8`, `npt_1_4`,
  `npt_3_8`, `npt_1_2`, rows `[name, major_d, tpi, hex_af]`, the pitch derived from the TPI), and 18
  registered McMaster-Carr Type K thermocouples with their part numbers: eight on 1/8 NPT (3872K127
  to 3872K134) and ten on 1/2 NPT (the 1245N parts, 3872K117 and 3872K118), 3 to 12 in reach with
  1/8 in or 3/16 in sheaths. `bayonet_thermocouple_port()` takes a `thread` (default `npt_1_2`)
  and reads the mount's diameter, pitch and engraved mark from it.
- `docs/references.md` gains a section on unbaffled vessels and eccentric agitation, since mouths
  under about 98 mm cannot hold four baffles beside two 16 mm probes: Montante 2006, Galletti 2009,
  Scargiali 2014, Busciglio 2016 and Labík 2018, all unread, with BibTeX entries. It notes that the
  centred 56 mm motor mount leaves little room to move the shaft off-centre (e/T at most 0.070 on
  `jar_10L`, against the 0.1-0.4 the literature works in) and overlaps the port flanges on
  `jar_1p5L` and `jar_1gal_155`.
- `head()` asserts the motor mount clears the port flanges by `lid_holes_offset`; on `jar_1p5L` and
  `jar_1gal_155` they overlapped by 12.45 and 8.30 mm without a word. No registered vessel changes
  its verdict.
- Five more references, read or from their abstracts, with BibTeX entries: Hall 2004 (45° pitched
  blades in 60 and 88 mm vessels at 168 W/m3: 1.98 s to blend baffled, 2.80 s unbaffled centred,
  1.78 s unbaffled at e = 0.2 T), Karcz 2005 (mixing time correlated against eccentricity), Cabaret
  2008 (sparged unbaffled mixers), Scarsella 2012 and Michels 2015 (microalgal shear). Scarsella
  finds _C. vulgaris_ the weaker of its two algae, undamaged by an air-lift at 31 W/kg, against
  30.5 W/kg peak here at the rated 320 rpm, so the note that Chlorella is generally robust is
  withdrawn. Karcz's correlation, applied per vessel, puts e = 0.2 T out of reach on every
  registered vessel: the vessels with room to off-centre the shaft are the ones wide enough for
  baffles.
- `docs/ports-layout.md` records why one port table cannot serve the family: the port circle is
  limited by the worst adjacent pair of flanges, a flange is sized by its face seal rather than its
  bore (13.6 mm on `std`, 10.6 mm on a proposed midi and 8.6 mm on a mini interface), and baffles
  need `std`. It proposes a full twelve-port set and a reduced six (both probes, temperature, air in
  and out, media; no baffles, no acid and base), assigns the two narrow jars to the reduced set, and
  records that off-centring the shaft cannot stand in for baffles on them.
- `head.scad` reports the lid gasket's seating load from the new `scad/utils/gasket_load.scad`
  (Young's modulus from Shore A hardness by Gent's relation, 3.61 MPa at 60A; shape factor; force
  and stress on the glass), and warns when the gasket is narrower than `lid_gasket_width_min` (3
  mm), as on `jar_1gal_155`'s 1 mm rim. `assembly.scad` reports the load per joint post (3502 N over
  12 posts, 292 N each, on the 10 L jar) and warns, suggesting a match, when the rod and the joint
  bolt differ in size, since every post is bored for the rod; `frame.scad` exports
  `frame_rod_diameter()`. Nothing asserts.
- Blend time and kLa: `stirred_tank.scad` adds Ruszkowski's blend-time correlation as given in Hall
  2004 (reproducing Hall's 1.9 and 2.6 s within 0.06 s), superficial gas velocity, and van't
  Riet's coalescing and non-coalescing kLa. `head()` reports them for each registered speed, 4.58 s
  to 95% and 0.0098 1/s coalescing at the rated 320 rpm, and says each is used outside its fitted
  range (500-10000 W/m3 against 209 here; 0.01-10 m3 against 0.0082). Cooke's correlation is left
  out, since it did not reproduce Hall's figures. Both sources are added to the references.
- Two smaller bayonet interfaces in `bayonet_interfaces.scad`: `bayonet_mini` (5 mm interface
  radius, 8.60 mm flange, a 3 mm bore tube with 2 mm of wall) and `bayonet_midi` (7 mm, 10.60 mm,
  a 1/8 NPT thermocouple mount), against `std`'s 13.60 mm, with their port seals registered:
  `oring_13x1p5_epdm` (McMaster-Carr 1289N323) and `oring_17x1p5_epdm` (8785N378). Both render
  clean; the mini keeps a 25° key margin against the 14.6° it needs. Baffles cannot use them (a
  mini leaves a 3.6 mm plate). Nothing selects them yet.
- `bayonet_name()` reads a bayonet interface's registered name.
- **Breaking:** A vessel is chosen by name: `reactor_vessel_name` (default `jar_10L_220x305`)
  replaces the `reactor_vessel` Customizer parameter in `assembly.scad` and `head.scad`, read
  through the new `vessel_by_name()` in `vessels.scad`, with an assert naming an unknown vessel; a
  Customizer parameter file could not carry a reference to a registry variable. `just json` writes
  `scad/assembly.json` and `scad/head.json`, one parameter set per registered vessel, selectable
  with `openscad -p <file>.json -P <vessel>`, and checks each file's drop-down against the
  registry; `just check-json`, part of `just check`, fails when either file is stale.
- `docs/design-conventions.md` records that a CSG diff cannot show a change to the bayonet pins,
  channels or notches, since `head.scad` previews the bayonets as bare shells and CSG export runs
  in preview, and why `just check-scad` fails on a `WARNING`.
- A second sparger tube holds the ring: `sparge_support_functions` (`["air_out"]`) drops a support
  tube through each listed port into a blind socket on the ring, so the ring no longer hangs from
  the feed riser alone; the support tube carries load, not gas. `air_out` is the one tube port both
  port sets place 120° from `air_in`. `sparge_ring()` takes `support_angles`, and `head()` reports
  each tube's free span and stiffness (140.7 mm, 2.21 N/mm; 3.76 N closes the gap to the baffles)
  and warns when the ring hangs on the riser alone.
- `just check-bom`, part of `just check`, fails when a part the model selects for the reference
  build (plug and port o-rings, thermocouple, impeller shaft, impeller set screw) has no row with
  that `part_number` in `purchased-parts.csv`. It compares the part number column rather than the
  whole file, and only covers the registries that carry part numbers.
- Baffles print in pieces: `baffle_segment_height_max` (170 mm, counting the port's 23 mm against
  the first piece) caps how tall a piece stands on the bed, and `baffle_segments` (undef derives
  the count, a number pins it) splits the plate into equal pieces joined by a blind sliding
  dovetail along the plate's width (`baffle_joint_lip` 1.6 mm, `baffle_joint_neck` 4.2 mm,
  `baffle_joint_flare` 10°, `baffle_joint_allowance` 0.1 mm). Every registered vessel comes out in
  two pieces. `bayonet_baffle_port()` takes the joint arguments, `segments` and `segment` (one
  piece for the bed; undef draws them interlocked), sized by `bayonet_baffle_segments()` and
  `bayonet_baffle_stack_height()`; `dovetail_root_width()` gives the root for a flare angle.
  `head()` reports the pieces and adds each joint's deflection from
  `stirred_tank_baffle_joint_deflection()` to the tip deflection, which puts `jar_10L`'s plate past
  the tenth-of-width warning; `docs/agitation.md` records the cost, and `TODO.md` adds deciding
  `jar_10L`'s plate deflection and running clearance together.
- `purchased-parts.csv` adds a tube cutter for the sparger riser stock, McMaster-Carr 2764A101
  (USD 12.30), rated for stainless, 1/8 to 7/8 in OD. It does not deburr, so deburring the riser's
  3 mm bore stays a separate assembly step.
- `head()` draws the lid's 608 bearing under `render_bearing` and the impeller set screws under
  `render_set_screws`, both in `render_all`. Each impeller is drawn with its screws by
  `head_impeller_assembly()`, so the mirrored upper impeller carries its own (0° and 240°), and
  `TODO.md` closes the item on parts registered but never drawn.
- `scad/custom/gasket_cutter.scad`, `gasket_cutter()`: a two-stage printed template pair for
  cutting the rim gasket, taking the same cut diameters and stock thickness as `sheet_gasket()`.
  The `outer` part is a solid disc at the outer diameter to cut a blank round, its bed edge drawn
  under size and flared up so a squashed first layer cannot stand proud of the guide face; the
  `inner` part is a plate bored at the inner diameter over a counterbore that holds the blank
  concentric for the second cut (8 mm guide height, 12 mm rim, 0.4 mm grip, 4.5 mm pin holes). Both
  print flat without support. `head()` draws it from the derived cut under `render_gasket_cutter`,
  which is not in `render_all`, and `just check` renders it as an entry file.
  `gasket_sheet_yield()` derives how many blanks a registered sheet gives, and the head's gasket
  echo reports it.
- `vessel.scad` returns the jar's section as data: `vessel_inner_profile()` (the wetted boundary),
  `vessel_outer_profile()` and `vessel_section()`. The section is now drawn upright from one centre
  per corner; all six registered vessels render to the same mesh as before.
- `render_culture` in `head.scad` draws the culture as a translucent solid at the fill line it is
  reported for, revolved from the same clipped profile the volume is integrated over. It is not in
  `render_all`. `TODO.md` records that the fill line is still a fraction of height rather than a
  working volume.
- `culture_working_volume` states the fill as a working volume in litres; the fill height is solved
  back from the jar's own profile by bisection (`head_fill_height_for()`), and
  `head_liquid_height()` takes the profile. Left undef, the fill still derives from
  `culture_fill_fraction`. The culture echo says whether the fill was derived or pinned, and warns
  when a pinned volume exceeds what the jar holds, holding the line at the rim.
- `render_probes` (in `render_all`) draws the Atlas pH and DO probes hanging in their collets.
  `head()` reports each probe's reach and asserts its tip ends in the culture and above the floor,
  allowing for the tilted tip's low corner; `bayonet_probe_port_collet_drop()` is exported so the
  drawing and the check read one number. `jar_1gal_180x197` is the tightest, with 3.17 mm between
  the pH probe and its floor; every other jar has 40 mm or more.
- `head()` checks that parts hung from the lid clear the impellers and the sparge ring: the probes'
  collets and tips and the thermocouple are compared, in radius and height, against each impeller's
  swept cylinder and the ring's annulus, reporting the radial room over the heights they share and
  asserting it is positive. `scad/utils/meridian.scad` carries the comparison. The baffles, the
  sparger's feed arm and its support tubes are not covered.
- `head()` reports whether the vessel keeps the galvanic DO probe fed: the vessel's bulk
  circulation velocity (`stirred_tank_circulation_velocity()`) against the 8.84 mm/s that Atlas's
  60 mL/min (`do_probe_flow_requirement`) gives over the probe's face, 16x at the rated 320 rpm and
  22x at no load. It also reports where the probe's face sits over the sparge ring (20.6 mm above
  its centreline, 0.87 mm off its radius) and warns when it overlaps the ring's radius, since a
  bubble on the membrane reads high and still liquid reads low.
- `purchased-parts.csv` makes the gas line orderable with nine rows: Clippard 11792-4-BLK barb
  fittings for the needle valve, McMaster-Carr 5121K371 and 5121K381 barbed adapters for the
  rotameter's inlet and outlet, 5047K26 and 5047K25 acetal reducers from the pump's 10 mm outlet
  down to 1/8 in, the upstream tubing, platinum-cure silicone tubing for the sterile side, 14
  stainless hose clamps and a NOGA RC1000 deburring tool. The gas back-pressure now counts the check
  valve (`sparge_check_valve_cracking` 1241 Pa plus its flow drop at `sparge_check_valve_cv` 0.12,
  from the new `gas_valve_pressure_drop()`): the line rises from 15.46 to 17.41 kPa and the required
  Cv to 0.0333.
- `just check-mesh` builds the entry files into solids and fails on a non-manifold, an `ERROR` or
  an empty render; `just check-mesh <file>` builds one. The five multi-part files (`assembly`,
  `cart`, `electronics_stand`, `frame` and `head`) are skipped by default and say so. It is not part
  of `just check`. `just check-scad` runs every file a second time with `$fn` forced to 0, so a file
  that divides by `$fn` fails as it would on a newer OpenSCAD.
- `head()` reports where to drill a sparger support tube to vent it: between 38 and 87.9 mm from its
  top end on `jar_10L`, past the lid's inner face and short of the culture.
- The sparger riser is sealed where it passes the lid: a rod gland at the lid's inner face of each
  port that carries a riser holds an `oring_4x1p5_epdm` (McMaster-Carr 8785N364, 4 x 1.5 mm EPDM
  70A) at 0% stretch and 18% radial squeeze. `bayonet_port()` takes `bore_oring` and asserts the
  gland fits the bore and leaves wall; `oring_rod_gland_diameter()` sizes it; `head()` asserts the
  ring's stretch on the tube is 0-5% and reports the open annulus it closes. `purchased-parts.csv`
  adds the ring, and `TODO.md` closes the riser item and opens one for an outlet filter.
- `docs/build.md`, the build instructions: what to print, what to cut, the fits made at the bench,
  the order the lid goes together, closing the joint, the gas line, commissioning and what to
  record. The joint is closed by turning each of its 12 nuts (8 bolts and 4 tie rods) 114.3° past
  snug, which `assembly.scad` now echoes from `gasket_seating_turn()`, `head_gasket_travel()`
  (0.397 mm) and the ISO 261 coarse pitch from `bolt_coarse_pitch()`, rather than to a torque. The
  README indexes the docs. `TODO.md` closes the assembly torque item.
- Selectors that render one printed part from `head.scad`: `impeller_to_render` (`lower`, `upper`),
  `port_to_render` (a port by its function), `baffle_segment_to_render` and
  `gasket_cutter_part_to_render`, each defaulting to the previous view. `head_print_parts()` lists
  every printed part of a build with its quantity and the flags that render it alone; it varies
  with the vessel, and on `jar_10L` gives 19 parts and 25 pieces.
- `just export-parts [vessel] [out]` writes each printed part as its own STL with a
  `print-list.md` beside it, CGAL-rendering every one and reporting each part's bounding box, and
  fails when the model resolves a different vessel than was named. `just check-parts`, part of
  `just check`, fails when a render flag reaches no row of the print manifest without being
  declared as not printed, or when a declared one is in the manifest. `docs/build.md` corrects its
  claim that the baffles were the only parts too big for a small bed: the lid is 257 x 257 mm, and
  `TODO.md` adds reconciling the 170 mm baffle cap with it.
- `scad/purchased/printers.scad` registers eight printers by build volume, as tooling:
  `prusa_core_one`, `voron_250`, `bambu_x1c`, `prusa_core_one_l`, `bambu_h2d` (single-nozzle
  325 x 320 x 325 mm), `sovol_sv08`, `voron_350` and `prusa_xl`, with `printer_max_disc()`,
  `printer_fits()` and `printers_fitting()`. `assembly.scad` reports the widest printed part (the
  lid and both frame bases, a 257.40 mm disc) and the printers that take it, `prusa_core_one_l`,
  `bambu_h2d`, `sovol_sv08`, `voron_350` and `prusa_xl`, and warns when none does.
  `just export-parts` reports which printers take every exported part and fails on a part no
  printer fits.
- `scad/purchased/hose_clamps.scad` registers the gas line's hose clamp, `clamp_sae4_316_5p16`
  (McMaster-Carr 5011T141, SAE 4, 5.6-15.875 mm, 316 stainless band and screw), with its
  7.9375 mm band width as the only registered dimension. `sparge_riser_proud` derives from the band
  plus `sparge_riser_clamp_lead_in` (3.5 mm) either side, 14.9375 mm instead of 15 mm, so each
  sparger tube is 186.637 mm instead of 186.7 mm. `just check-bom` checks the clamp's part number,
  and `purchased-parts.csv` buys 2 packs of 10 for the line's 14 joints in place of the commodity
  row; `docs/procurement.md` gives why 316, and `docs/build.md` notes that 3/8 in line in a 1/8 in
  wall is exactly the clamp's 15.875 mm limit.
- `just export-parts` exports the frame's printed parts as well, from `frame_print_parts()` in
  `frame.scad`: the base, the top base, the rib (one part, eight off) and the rod spacer (twelve
  off), 47 pieces across 23 parts with the head's. `rib_to_render` and `rodspacer_to_render` render
  a single rib or spacer. Both manifests are read through `assembly.scad`, and `just check-parts`
  scans both files. The frame is always built at `jar_10L`, which `TODO.md` records.
- `head()` reports where the air pump settles against the gas line (`gas_operating_flow()`,
  crossing the pump's curve with the line's secant across the aeration band): 6.05 L/min on this
  build. It also budgets an exhaust filter, left unchosen (`sparge_outlet_filter_drop_slope` undef):
  at most 1.91 kPa per L/min, 55% of the inlet filter's slope, since a second inlet filter on the
  exhaust would put the line at 31.8 kPa against the pump's 27 kPa dead head and settle the reactor
  at 3.27 L/min. `gas_line_secant()` and `gas_filter_slope_budget()` join `gas_supply.scad`, and a
  flow target the pump cannot reach warns in words instead of reporting a nan Cv.
- Strip light rows register how many tubes one cord drives (`strip_light_per_cord()`: 3 for
  `rwntao_13in`, 4 for the three grow lights), and `frame()` reports the cords a layout needs, such
  as 6 tubes, 3 in each of 2 quadrants, on 2 cords with nothing spare. It reports and does not set
  the light count. `purchased-parts.csv` cites the figure and `TODO.md` closes the item.
- `just stats` reports lines of code, comment and blank per language with cloc, counting only
  tracked files and leaving out `_archive/`, `_shelf/` and CSV data, and refuses with a message
  when cloc is not installed. It is not part of `just check`. The SCAD tree is 3,852 lines of
  comment to 4,907 of code, 44%.
- `scad/purchased/printers.scad` registers the Prusa MK3S, `prusa_mk3s` (250 x 210 x 210 mm), the
  machine the parts were printed on beside the XL; it is the smallest registered and cannot take
  the 257.4 mm lid.
- `head()` takes a `build` list of `[name, value]` pairs, which `head_build()` resolves against
  `head.scad`'s own parameters, so a build's choices reach the head from `assembly.scad`; an empty
  list renders what `head.scad` renders on its own. `assembly.scad` gains a Build section declaring
  `culture_working_volume`, `culture_fill_fraction`, `head_shaft`, `lid_plug_oring` and
  `do_probe_port_tilt_degrees`, and passes them as `reactor_build`. Only `culture_fill_fraction`
  can be carried by a parameter set: the four that default to undef are invisible to the
  customizer and reachable with `-D` only, as the section and `TODO.md` say. The liquid height
  takes the fill fraction as an argument as well as the working volume, so `assembly.scad` and
  `head()` cannot disagree about the fill line.
- `scad/utils/registries.scad`, `registry_by_name(rows, name)`, which returns the row of that name,
  or undef on a miss or a duplicated name and leaves the assert to the caller; `vessel_by_name()`
  uses it. Nine more registries answer to a name through it: `impeller_by_name()`,
  `atlas_probe_by_name()`, `dc_motor_by_name()`, `gasket_sheet_by_name()`, `oring_by_name()`,
  `peri_pump_by_name()`, `shaft_by_name()`, `strip_light_by_name()` and
  `thermocouple_probe_by_name()`. `dc_motors.scad` and `atlas_probes.scad` name the rows that are
  real but not orderable and stay swept, and the Atlas note records that the two probe generations
  are not interchangeable in a printed collet (pH 15.6 x 36.0 against 16.0 x 30.2 mm on a 0.6 mm
  grip fit).
- Name accessors for seven registries that had none: `castor_name()`, `dc_motor_name()`,
  `gearbox_name()`, `heat_set_insert_name()`, `shaft_coupling_name()`, `strip_light_name()` and
  `thermocouple_probe_name()`, which `head.scad` reads instead of indexing the row.
  `shaft_coupling_part_number()` returns undef, since uxcell publish no number for the coupling.
- Part numbers in the registries: `heat_set_insert_part_number()` (97163A152, with
  `heat_set_insert_material()` 18-8 SS and `heat_set_insert_pack()` 10), placed past NopSCADlib's
  insert fields, whose thread pitch and chamfer slots stay undef; `gasket_sheet_part_number()`
  (8525T65); `dc_motor_part_number()` (RM-ESMO-16Q for the 36PG-3429-5.2 and RM-ESMO-071 for the
  36PG-555PM-14-EN, undef for the discontinued 36GP-3530-5.18 and for `12v_5w`, which arrives fitted
  to the pump head); and `atlas_probe_part_number()` (ENV-40-PH on both pH lab generations and
  ENV-40-DOX on both DO rows, since Atlas sell a product line under one SKU whichever generation
  arrives; the other thirteen Atlas rows are undef).
- `do_probe_name` and `ph_probe_name` in `assembly.scad` designate the probes by name (`"auto"`
  keeps the port table's), resolved through `atlas_probe_by_name()` into the head's port table, so
  the collet and the reach, immersion and mouth checks follow the probe named, either Atlas
  generation included; an unregistered name fails naming `atlas_probes.scad`. Any Atlas row is
  accepted, though the DO reports assume a galvanic DO probe. The thermocouple cannot be designated
  this way yet, as the code notes.
- `just check-designations`, part of `just check`, fails when a designation stops reaching the
  model. `differs` rows (`shaft_name` `8x600_316`, `strip_light_name` `grow 16in`, `do_probe_name`
  `DO lab g1`, `ph_probe_name` `pH lab g1`) must change the geometry; `builds` rows
  (`plug_oring_name` `AS568-160`, which cannot move geometry since every registered AS568 ring
  shares a 2.62 mm cord) must resolve and render; and every row must fail on a name nothing is
  registered under. Each row is driven through a generated parameter set rather than `-D`, so a
  value has to travel the build list to be seen, and `number` rows check that
  `do_probe_port_tilt_max` and `culture_fill_fraction` change the geometry.
- `gasket_sheet_name` in `assembly.scad` designates the lid's rim gasket sheet by name (`"auto"`
  keeps `head.scad`'s own), resolved through `gasket_sheet_by_name()`. The gasket factor, and the
  joint's bolt count derived from it, follow the sheet named: `head_gasket_factor()`,
  `head_gasket_depth()`, `head_gasket_travel()` and `head_gasket_seating_force()` take the sheet as
  an argument. The reference build still reports 12 posts.
- `motor_name` in `assembly.scad` designates the drive motor by name (`"auto"` keeps `head.scad`'s
  own), resolved through `dc_motor_by_name()`. The gearbox comes with the motor, so it moves the
  mount height and the drive stack, and `head_motor_mount_height()` and `head_stack_height()` take
  the motor so the reactor envelope follows it: `36PG-3429-5.2` takes it from 571.25 to 535.65 mm.
  Both designations are in the `check-designations` matrix.
- `frame.scad` takes the same `reactor_vessel_name` selector as `assembly.scad` and `head.scad`,
  with the same by-name lookup and assert, in place of a private `_preview_vessel` the Customizer
  could not see. `just json` writes `scad/frame.json` beside the other two parameter sets, and
  `just check-json` checks it for staleness too.
- `scad/purchased/gas_filters.scad` and `scad/purchased/check_valves.scad` register the gas train's
  bought parts: `gas_filter_cp_1594522` (Cole-Parmer 1594522, 3.45 kPa per L/min, 0.2 µm, 16.2 cm²
  of membrane; the slope is extrapolated from an equivalent 0.2 µm PTFE disc, not measured, as the
  row says) and `check_valve_cp_5011521` (Cole-Parmer 5011521, 1241 Pa to crack, Cv 0.12).
  `sparge_inlet_filter`, `sparge_outlet_filter` (undef, none chosen) and `sparge_check_valve` in
  `head.scad` replace the literals `sparge_filter_drop_slope`, `sparge_outlet_filter_drop_slope`,
  `sparge_check_valve_cracking` and `sparge_check_valve_cv`; every echo is unchanged.
  `just check-bom` checks both part numbers.
- `head()` reports whether the vessel wants two impellers: the liquid's H/T against the convention
  of adding a second impeller above about 1.2 and, when the column is short for a pair, the
  coverage over the upper impeller that costs. Three of the five swept jars are short
  (`jar_10L_220x305` H/T 1.124, `jar_1gal_180x197` 0.918, `jar_6p5gal_305x470` 1.158). It only
  echoes, since 1.2 is convention, and `TODO.md`'s coverage item becomes one about the impeller
  count.
- `stirred_tank_eccentric_theta()` and `stirred_tank_eccentric_gain()` in `stirred_tank.scad` encode
  Karcz 2005 eq. (6), blend time against shaft eccentricity, with M +0.32 up-pumping and -0.32
  down-pumping and e/T converted to the paper's e/R inside, returned as a ratio against the centred
  case rather than a mixing time. `stirred_tank_eccentric_departures()` names the conditions a
  geometry departs from the paper's envelope by (e/T 0-0.285, Re 2e4-8e4 among them).
- `head()` reports the offset the motor mount leaves room for, its e/T and what Karcz's
  correlation says it is worth, saying on every render that the gain applies only to an unbaffled
  vessel: 13.3 mm, e/T 0.0633 and 24.70% on `jar_10L_220x305`. `docs/references.md`'s eccentricity
  table cites the echo, which moves `jar_6p5gal_305x470`'s gain today from 17% to 16%.
- `docs/agitation.md` records why each vessel agitates the way it does. `jar_1p5L_109x215` and
  `jar_1gal_155x251` are under the roughly 98 mm mouth below which no baffle fits beside two 16 mm
  probes; `jar_6p5gal_305x470`'s mouth is small against its bore (0.488), so its port circle falls
  inside the impeller's sweep, and the eccentricity question belongs to it (10.3 mm today worth
  16%, 25.3 mm at the mount's floor worth 31%); and the two narrow jars are better served by gas,
  as an airlift rather than a bubble column. It notes that Uyar 2024's five-fold kLa spread came
  from bubble size, against this ring's eight 3 mm holes.
- `scad/custom/sparger.scad`, `sparger()`, a tube sparger that can be cleaned: a round bore in an
  octagonal tube, split opposite the feed with a solid plug at each cut face and a pilot for a 316
  set screw, so a pipe cleaner passes through each half; a swept elbow where the feed turns into
  the ring; one to N rings on equal-area radii (`sparger_equal_area_radii()`,
  `sparger_area_shares()`); and spokes that can carry holes. It asserts the split falls between
  holes on every ring and misses every arm. `sparger_report()` reports what it does to the gas,
  and `stirred_tank.scad` adds bubble diameter at formation, interfacial area, bubble rate and the
  bore's velocity head, with surface tension no longer a literal inside the capillary pressure:
  3 mm holes give 5.10 mm bubbles and 1.2 mm holes 3.76 mm, 36% more interfacial area. `head()`
  still builds the old ring, as `TODO.md` records.
- `just check-holes [file] [flags]` fails on a blind gas hole: a part echoes, per hole, a point that
  must be void if the hole opened (`sparger_hole_probes()`), and the recipe tests each against the
  built mesh, rendering `head.scad` with `render_all=false` and `render_sparger=true` by default. It
  is not part of `just check`, since it needs a CGAL render.
- A `show_fluid_path` argument to `sparger()` draws the gas path (the bore, elbow, socket and every
  hole) in translucent blue instead of the part; the part is unchanged.
- `render_baffle_coupon` in `head.scad` renders a 45 mm (`baffle_coupon_diameter`) disc of the real
  lid cut around the first baffle port, on the print manifest as `baffle_port_coupon`, to measure
  how far the baffle tilts in its port without printing a 257 mm lid; it asserts on a lid that
  hangs no baffles. `TODO.md` measures the sterile filter at two points, 1 and 2 L/min (35 and
  71 cm of water), instead of at the set flow, which would take 1.46 m of water column.
- `docs/decisions.md`, split out of `TODO.md`: a ledger of settled decisions and why, and a log of
  corrections that keeps each superseded reading in full. Moving the ledger corrected an entry that
  still refused the enclosed rod gland the ports now have. `TODO.md` goes from 732 to 525 lines and
  32 to 28 open items, drops three completed items, and gains a section for the airlift and
  magnetic drive and a long-term section.
- `just check-customizer`, part of `just check`, fails when a parameter the Customizer offers in
  `assembly.scad`, `head.scad` or `frame.scad` has no comment line directly above it, or when a
  `/* [Hidden] */` marker does not say what it hides. 46 parameters that showed the previous line
  of code as their description get one, mostly by moving their trailing comment above them, and
  `frame.scad` gains a Part Render Selection section. About 54 still show the last line of a
  multi-line block, as `TODO.md` records.
- `sparger()` warns that holes on its arms (`spoke_holes`) are not covered by `just check-holes`,
  which probes rings only.
- Twelve more 1.5 mm EPDM o-rings in `orings.scad`, 11, 12, 14, 15, 16, 18, 20, 22, 24, 25, 28 and
  30 mm ID (`oring_11x1p5_epdm` to `oring_30x1p5_epdm`, McMaster-Carr 1289N and 8785N parts), from
  the same line as the port and rod seals. Nothing consumes them yet, and every jar keeps its plug
  ring. The 1.5 mm group in `plug_oring_name`'s dropdown is in ascending size order.
- A 0.5 mm 45° lead-in chamfer at every sparger socket mouth, feed and support alike
  (`socket_chamfer`), so a tube dropped in blind finds its socket; `sparger()` asserts it takes no
  more than half the socket wall, leaving 0.7 mm at the mouth. The three dosing stubs take hose
  clamps, 17 on the parts list instead of 14. `TODO.md` records that the 4.0 mm socket bore has no
  clearance on the 4.0 mm tube.
- The bearing is sealed on its rim, the last unsealed path out of the lid: an `oring_22x1p5_epdm`
  (`bearing_oring`, McMaster-Carr 8785N382) sits at 0% stretch on the 22 mm bearing's outer race,
  which does not turn, in a groove cut to 24.46 mm over 2.25 mm and centred in the 7 mm pocket.
  `head()` asserts the stretch and that the groove fits the pocket, echoes the seal, draws it under
  `render_seals`, and measures the motor mount inserts' clearance to the groove (6.02 mm, down from
  7.15 mm to the pocket). `purchased-parts.csv` adds the ring, and `just check-bom` checks it and
  the riser rod seal.
- `scad/custom/gasket_cutter_v2.scad`, a work-in-progress stub of a gasket cutter built around a
  #11 blade, previewed as an entry file and declared as reaching no print list.
- `head()` prices the hand-cut vent slot in `air_out`'s support tube against the exhaust budget:
  what a slot of the tube's 7.07 mm² bore costs, what the tube above it costs across the drilling
  window, and the smallest slot that does not spend the whole budget (0.995 mm², a 1.126 mm hole,
  on `jar_10L`; 0.283 mm² on `jar_1gal_180x197`). On `jar_6p5gal_305x470`, whose line already
  beats the pump, it says the slot has no size to meet. `stirred_tank_orifice_area()` is the
  orifice pressure solved for area. `TODO.md` and `docs/build.md` correct the outlet budget from
  1.885 to 1.92464 kPa per L/min.
- `just test` runs `check-mesh` and `check-holes`, the checks that need a CGAL render; `just fmt`,
  `just fmt-check` and `just lint` run pinned prettier, markdownlint-cli2 and ruff, with `fmt-check`
  and `lint` first in `just check`; and `just clean` removes what the recipes build.
- `.github/workflows/check.yml`, a GitHub Actions workflow that runs `just check`, `just test` and
  `just stats` (cloc's table in the job summary) on pushes and pull requests to `main`.
- `just setup` installs the four OpenSCAD libraries the model needs, pinned in
  `openscad-libraries.txt` (NopSCADlib v21.41.1, and bayonet-lock-scad, FunctionalOpenSCAD and
  threads-scad at commits), cloning them into `.openscad-libraries/` with
  `scripts/install-libraries.sh`, over SSH with HTTPS as the fallback. The justfile points
  `OPENSCADPATH` there alone, so a render uses the pinned libraries or fails, instead of whatever a
  machine has installed.
- `just check-recipes`, part of `just check`, fails when a recipe's description is not the first
  line of its comment block, since `just --list` shows only the line above a recipe.
- `just check-echo`, part of `just check`, compares everything `assembly.scad`, `head.scad` and
  `frame.scad` echo on each of the five registered vessels with transcripts in `tests/echo/` (707
  lines), failing cells included; `just check-echo-update` rewrites them. The gate goes from 211 s
  to 277 s.
- `docs/architecture.md`, a normative account of where a number may come from: a layer table
  (`bioreactor`, `head` and `frame`, `custom`, `purchased`, `utils`, and `support` around them)
  saying what each holds, may import and may not, and eight rules, among them that decisions flow
  down and interfaces are read back, that an argument is the narrowest coherent interface, and
  that analysis and geometry are separate. The audit of where the tree breaks them is a `TODO.md`
  item.
- `head()` reports the port layout: 12 ports on a 113 mm circle with a 29.2466 mm chord on
  `jar_10L`, and the smallest mouth the full set fits (142.025 mm) and the reduced set fits
  (78.0017 mm mixed, 87.6038 mm on `std` throughout), against the jar's 142.2 mm.
- A magnetic drive, `drive_name = "magnetic"` in `bioreactor.scad` (the default stays `shaft`):
  `frame.scad` hangs a PC fan in a printed carrier in the base bore, a cup the fan drops into with
  an ear that lands on shoulders beside a wire groove, so it hangs from the base. The fan is picked
  by rule from NopSCADlib's rows (`scad/purchased/fans.scad`, `fan_for()`: `fan80x25` on
  `jar_10L`, `fan40x11` on `jar_1p5L`, none where the floor is 2 mm), and the carrier's height
  holds the magnet faces 1 mm under the punt. `scad/custom/magnet_hub_cap.scad` pockets the
  magnets on the fan hub. `stir_bar_name` (`scad/purchased/stir_bars.scad`: 25x8, 38x8 and 50x8
  bars) and `stir_magnet_name` (`scad/purchased/magnets.scad`: `MAG5x8`, `MAGRE6x2p5`,
  `MAG8x4x4p2`, `MAG484`) default to a 38 x 8 bar and two `MAG5x8`. Under it `head.scad` draws the
  lid without the shaft bore, bearing pocket or insert holes and no drive stack, and checks the bar
  on the punt against the sparge ring and baffles; the shaft drive's checks run only under the
  shaft drive. The print manifest check covers both drives and `check-designations` exercises the
  drive, bar and magnet names; `docs/build.md` has the assembly.
- One T-slot in the base at an empty light position, the cord notch's profile carried across the
  floor ring to the bore with the carrier ear's notch above it, cut under both drives so one base
  serves either. The frame reports where the light pockets end against the ribs and the top base.
- Builds in `scad/bioreactor.json`: a parameter set is a build, starting with `jar_10L_magnetic`
  (the vessel and `drive_name`). `just export-parts <build>` exports one and refuses a set name the
  file does not have instead of falling back to the defaults; `just export-part <part> <build>`
  renders one manifest row alone in a few seconds. `bioreactor.scad` echoes a `build:` line (vessel,
  drive, fill and every designation not left `auto`) that opens the print list, replacing the
  script's own list of designations, which had missed the motor, gasket sheet, drive, bar and
  magnets. `check-json` holds the stir bar and magnet dropdowns to their registries. The shaft build
  exports 23 parts in 8:47, the magnetic build 20 in 8:00.
- `.github/workflows/export.yml`, which exports the STLs as CI artifacts: one job per build running
  `just export-parts <build>` on `workflow_dispatch` (default `jar_10L_220x305 jar_10L_magnetic`)
  and on `v*` tags, uploading `output/<build>` with its print list as `stl-<build>`, and failing on
  a part that does not build, is not a 2-manifold or fits no registered printer. `docs/build.md`
  points to it for anyone without OpenSCAD.
- `frame()` echoes the threaded rod length (322 mm on `jar_10L`).
- `scad/custom/bearing_blank.scad`, so the lid is one print under either drive: a magnetic build's
  lid keeps its bearing pocket, shaft bore and insert holes, and the blank plugs them with a boss
  the bearing's size sealed by the pocket's own 22 x 1.5 ring in its groove (18% squeeze), a pin
  the shaft's size filling the bore to the lid's underside, and a flange bolted to the four inserts
  with the mount's 8 mm M4 screws. `head()` lists `bearing_blank` in place of the mount and
  impellers under a non-shaft drive and reports it, and the pocket's checks run under either drive.
  The pin is 8.0 mm in the 8.2 mm bore, the same 0.1 mm annulus the bearing leaves.
- The sparger is a build choice: `sparger_name` in `bioreactor.scad` takes `ring` or `cap`, and
  `auto` is the arm under either drive. `sparge_arm()` in `scad/custom/sparger.scad` (printed as
  `sparge_cap`) is the ring's feed without the ring, the same socket and elbow with one run turned
  in from the port circle to end 5 mm short of the shaft, closed at the end, with holes pointing
  down 10 mm under the lower impeller: on `jar_10L` from r 56.5 to r 9, 3 x 3 mm holes at 3.8
  diameters, 3.23 m/s. `head()` places, checks and lists whichever is named, the ring's checks run
  only for the ring, and the gas line follows the arm's height (1783 Pa back-pressure, 680 Pa more
  than the ring, 69 mm lower). Under the default the DO probe takes its full 4.5° lean, so
  `port_do_probe` prints differently, and the baffles keep the ring's 10.35 mm width under either
  sparger; `docs/build.md` and `docs/agitation.md` say so.
- `just check-seams`, part of `just test`: `scripts/stl-seams.sh` checks that every edge of an
  exported STL is used by exactly two triangles and no triangle appears twice, `just export-parts`
  asks it of every file it writes and fails on anything unaccounted for or on any hole, and
  `tests/seams.txt` pins the seams the model cannot close, rewritten by `just check-seams-update`.
  Six are pinned over seven builds, all of zero volume: the lids', from the bayonet-lock library's
  entry transition, and the probe ports', where the transition meets the collet. `TODO.md` carries
  both with the reproduction.
- `TODO.md` adds three tooling items: the port lettering asks for the fontconfig alias `sans`
  rather than a face, so its glyphs follow the host and the CI artifact's differed from the
  bench's; `jar_1gal_180x197` takes the magnetic drive but has no parameter set to export it by;
  and `just test` roughly doubled, by about twenty minutes, when `check-seams` joined it.
- A third gasket cutter part, `base`, printed once and the same for every gasket: the cutting
  surface the blade comes through the rubber into, holding three M4 nuts in channels under the
  clamp slots and a fourth in a hex pocket at the centre for stage 1's single screw, with both
  stages screwed to it. It is a hub, three spokes and a ring 8 mm thick rather than a disc (220 cm3
  against 296), and asserts stop a gasket whose cut would reach the slots or the bore. The inner
  plate's counterbore mouth is flared 1.5 mm (`seat_lead`), so the plate is lowered onto a blank
  lying on the base instead of the pair being turned over onto a board. The clamp screws sit on a
  fixed 92 mm radius (`gasket_cutter_clamp_radius`, 5 mm of slot travel) instead of following the
  cut, so every inner plate is 208 mm across, against 175 to 189 mm before; both fit a 250 mm bed.
  `head_print_parts()` lists `gasket_cutter_base`, and `docs/build.md` gives the cutting steps.
- `scad/utils/section.scad`, `section(keep, axis, turn, size, active)`, which cuts a model open on
  a wedge. The preview's cross section in `bioreactor.scad` uses it, with `cross_section_keep`
  setting what is left (0.5 a half, 0.75 removes a quarter) and the vessel revolving through the
  same fraction, and the frame is now cut with the vessel and head where the preview showed it
  whole. Exported parts are unchanged.
- Exhaust condensers for the `air_out` port, printed from their own files and not yet placed by
  `head()`: `scad/custom/condenser_body.scad`, the lower half every variant shares (the `std` pin
  that locks into `jar_10L`'s `air_out` socket, a neck, a 45° funnel and an open shell, with a
  12 mm bore in which condensate drains back against 0.61 m/s of gas at 4.11 L/min, under the
  5.2 m/s Wallis limit); `condenser_cold_finger.scad`, a well hung down the shell's middle,
  `monolithic` or `split` with a bayonet insert in the roof that is either an open well or a flow
  head sealing on a dip tube with an overflow barb; and `condenser_coil.scad`, a Dimroth-style coil
  of 3/16 in soft aluminium tube (11.5 turns, about 1.25 m) on a former hung from a head that locks
  into the body's rim. New bayonet rows `large` (r 13.5, on the 30 x 1.5 ring) and `xl` (r 19, on a
  42 x 2 ring) stay out of the lid's interfaces; `scad/purchased/aluminum_tubes.scad` registers
  McMaster-Carr seamless 3003 soft coil tubing from 1/8 to 5/8 in (5177K61 to K74); and
  `oring_42x2_epdm` (8785N431) and `oring_4p5x1p5_epdm` (1289N315) are registered outside `orings`.
  Nothing has been printed.
- `scad/custom/gl_port_cap.scad`, `gl_port_cap()`: a GL45 screw cap for an inlet humidifier bottle
  whose 10 mm top carries two `mini` bayonet locks, for a steel dip tube and an outlet pin, sealing
  on the bottle's rim with a sheet gasket whose 34 mm bore is an estimate. The thread comes from
  `din168-thread-scad`, newly pinned in `openscad-libraries.txt` at `654f97d`, and the cap renders
  in about 18 s on OpenSCAD 2021.01. `just check` evaluates it and the two condenser variants as
  entry files.
- `TODO.md` adds an exhaust condenser and humidifier section: bench-testing the condensers (a fixed
  flow for 48 h, 1 mm of level being 34.6 mL) and placing the one that works, water-testing the
  flow insert, and fitting the humidifier cap's gasket to its bottle and setting it against the
  condenser. It notes that a culture may want 0.1-1 vvm, where this pump and filter reach about
  0.7 on `jar_10L`.
- `condenser_cold_finger_lid()` (`part = "lid"`), a push-in lid for the cold finger's open well: an
  8 mm disc resting unsealed on the insert's flange with a 6 mm spigot into the mouth, and a 1.5 mm
  vent so melting ice and warming water push air out rather than pressurising the well.
- `docs/build.md` gains a section on the exhaust condenser: bodies and the flow insert printed
  hot, with four or more walls, 0.15 mm layers and about 105 % flow, and the flow insert
  water-tested; the open well's lid printed sparse in honeycomb or cubic infill, its vent kept
  open; and the aluminium coil kept out of the vessel's bleach step. It also gives the coil's
  winding: on the mandrel, the ends formed on the puck, the head's holes used as a gauge rather
  than a form, and from fresh tube rather than one bent back and forth.
- `TODO.md` adds designations for the air pump and inlet filter if builds start to differ, and a
  shape check for registry rows, which are read by position. `docs/design-conventions.md` adds that
  a clash check on a stand-in shape proves only the stand-in, and that a bent or wound part has to
  be formable, at a radius the material takes.
- `facet_count(r)` in `scad/utils/facets.scad`, the fragment count the facet policy gives a circle
  of radius r, so coaxial shapes can share one `$fn` and their facets line up: a 2.58 mm bore, its
  2.98 mm lead-in and a 3.48 mm gland came out at 14, 14 and 19 segments. Nothing reads it yet.
- A build with no drive: `drive_name = "none"` (`head_drive` in `head.scad`) leaves out the motor,
  mount, shaft, impellers, bearing and stir bar, makes the ring the sparger's `auto`, and builds the
  frame as for the shaft. `lid_center_name` (`auto`, `bearing`, `plain`) chooses a lid with the
  bearing pocket and mount inserts or a plain one; `auto` is plain under no drive and bearing
  otherwise, a shaft on a plain lid is refused, and the bearing blank is listed, reported and drawn
  on any bearing lid off the shaft.
- `scad/bioreactor.json` registers eight builds that resolve: the shaft drive on `jar_10L`,
  `jar_1gal_180` and `jar_6p5gal`; magnetic on `jar_10L` and a new `jar_1gal_180_magnetic`;
  `jar_1p5L_magnetic` on a plain lid; and no drive on `jar_1p5L_109x215` and `jar_1gal_155x251`,
  whose sets were shaft builds that failed. `just check-builds`, part of `just check`, fails when a
  registered set hits an assert or its render says nothing about the build, and
  `check-designations` can compare a row against a base build. `TODO.md` records what each vessel
  cannot take yet and five findings from the work, among them that no gate catches a build that
  resolves with the wrong content.
- Blank ports: a pin with no bore, labelled `BLANK`, that closes an empty port while the reactor is
  cleaned, tested or serviced, with the same lock and face seal as the port it replaces.
  `head_print_parts()` lists one per interface the port table uses (`port_blank_std`, and
  `port_blank_mini` as well on `jar_1p5L`), `blank_port_to_render` draws one, and naming an
  interface the lid does not use is refused.
- `just export-parts` with no build exports every registered build to `build/<vessel>/`: `common/`
  for the parts every build of that vessel prints the same (same quantity and geometry, and not
  one drive's own), and `stirred/`, `magnetic/` or `bubble/` for what each build type adds. Each
  distinct part renders once, and each vessel's folder is staged and swapped in whole. The eight
  registered builds export in 581 s against 1057 s one at a time. With a build named it still
  writes `output/<build>` as before; both modes share `scripts/export-lib.sh`.
- An airlift drive: `drive_name = "airlift"` is the no-drive build plus a printed draft tube
  (`scad/custom/draft_tube.scad`) standing on three feet on the jar floor, sparged inside by the
  ring, which is drawn in to sit 1.25 mm inside the tube's wall and centres it. The bore clears
  the hanging probes, thermocouple and risers by 2 mm (`draft_tube_hardware_clearance`), the gaps
  under and over the tube give the turning flow the downcomer's own area, each foot meets the
  tube through a 6 mm fillet (`draft_tube_foot_fillet`), and the DO probe hangs straight. `head()`
  reports Ad/Ar, the bottom loss K_B and the riser's superficial gas velocity, takes the reach
  checks with the tube shifted, and refuses an airlift on a baffled lid. On `jar_1p5L_112x215` the
  tube is 80.7/84.7 mm, 151.5 mm long, Ad/Ar 0.54; on `jar_1gal_155x251` 89/93 mm, 113.7 mm long,
  Ad/Ar 1.72. Both jars' sets in `bioreactor.json` and `head.json` are now airlifts in place of the
  bubble column, `export-parts` writes `airlift/` where it wrote `bubble/`, and `check-parts` and
  `check-designations` cover it. `docs/references.md` gains an airlift section (`references.bib`
  goes from 49 to 56 entries), and `docs/agitation.md`, `docs/build.md`, `docs/decisions.md` and
  `TODO.md` record the choice, the assembly and the open bench work.
- `frame_stir_riser`, a printed riser in `scad/frame.scad` that a magnetic build stands on when
  its fan wants more floor than `carrier_floor_lift_max` gives, so the base, carrier and lights stay
  the same parts across drives: 3 mm walls (`riser_wall`) in four rings tied by four spokes, a
  block carrying the base's groove and ear notch for the carrier, and keys filling the lights'
  12 cord notches to centre it on the base. An assert refuses a riser shorter than the carrier's
  ear (23.8 mm). `jar_1gal_155x251` now builds as a magnetic reactor on a 36 mm riser, registered
  as `jar_1gal_155_magnetic` on a plain lid with a 60 x 25 fan; `jar_6p5gal_305x470`'s magnetic
  build now builds on a 35 mm riser but is not registered. `frame_print_parts` gains a `riser`
  flag.
- An assert that a draft tube spans at least `draft_tube_span_min` (0.5, a judgement) of the
  liquid depth, so `jar_6p5gal_305x470` is refused as an airlift (a 73 mm tube in 325 mm of
  culture, 0.22) while `jar_1p5L` (0.91) and `jar_1gal_155` (0.60) build.
- `check-echo` pins a transcript, `tests/echo/build__<set>.txt`, for every set in
  `scad/bioreactor.json` that names more than its vessel, rendered from `bioreactor.scad`: the four
  magnetic builds and the two airlifts, which had no pinned report stream.
- `lights_per_quadrant` is a build setting in `bioreactor.scad` (3 by default, 1-6), passed into
  `frame()`, where it was the frame's own global that no registered build could reach;
  `check-designations` covers it.
- A registered heating pad: `scad/purchased/heat_pads.scad` and `heat_pad.scad` (accessors,
  `heat_pad_by_name()` and a flat drawing) hold `20W 150x50`, measured on a delivered pad at
  150 x 50 x 1.85 mm, 7.6 ohm cold, 320 mm leads, and listed at 12 V 20 W; the measured resistance
  gives 18.9 W at 12 V. A 30 W pad of the same size is written in as a commented-out row until one
  is delivered and measured.
- Heating pads held on the glass: a build names one with `heat_pad_name` (`none` by default), and
  each pad lies bare on the jar in an unlit quadrant at the lower rib level, held by a printed
  plate (`scad/custom/heat_pad_mount.scad`) that hangs behind the rib arc, whose inner face is
  recessed to take pad and plate with 0.2 mm to spare. The plate rings the pad with notches for the
  leads, hooks over the rib's top, locates on two tabs in the outermost light pockets and prints
  top edge down. The 10 L builds name the 20 W pad, two of them, 37.9 W at 12 V, which the frame
  reports. `frame_print_parts` lists `heat_pad_plate`, one per unlit quadrant, `render_heat_pads`
  draws the pads, and `purchased-parts.csv` lists them.
- A turbidity sampler for a lid port, `scad/custom/sampler.scad`, printed from its own file and not
  yet placed by `head()`: a flow cell round the turbidity probe's bare board in two prints, a base
  with a std bayonet pin and a top whose shroud flares into a face a syringe actuator bolts to,
  drawing culture up a clear tube between the board's two heads from the port's sparge riser,
  drilled as the dip tube. The halves close on two M3 screws into heat-set inserts and one M2
  countersunk screw. `openscad-libraries.txt` pins turbidity-sensor `1f45d9b` and syringe-actuator
  `ea8b221`; `just check-sampler`, under `just test`, renders `tests/sampler/fit.scad`, six fits
  that must come out empty; `docs/build.md` gains a sampler section; and `TODO.md` carries placing
  it on `dose_4`'s port.
- Registered heat-set inserts McMaster-Carr 97163A150 (M3) and 97163A124 (M2), in
  `heat_set_inserts.scad`, and `purchased-parts.csv` rows for them and the sampler's screws and
  nuts.
- A two-piece box for a 22 mm panel-mount e-stop, `scad/support/estop_box.scad` (`part = "base"`
  and `part = "lid"`): the lid screws into the base's four corner posts, the e-stop's neck passes
  the lid's centre bore and its nut clamps the lid, and the two channels' four wires leave by one
  hole in a wall. Its first four parameters are the e-stop's body height, width and length and its
  neck cutout; the box is square on the body's wider side with `wire_space` (10 mm) round and below
  it, and an assert refuses a `wire_space` that puts the posts into the body. The defaults (a
  38 x 30 x 45 mm body, a 22 mm neck through a 22.5 mm bore) give a box 62.8 x 62.8 x 60.4 mm
  closed. `purchased-parts.csv` gains the e-stop and four M3 x 10 mm self-tapping lid screws, both
  without part numbers, and `docs/build.md` a section on measuring the e-stop and fitting the box.
- A bench sparge puck, `scad/custom/sparge_puck.scad`, to measure what an outlet face costs: one
  face over a plenum with a 45° cone roof, printed face down. `outlet = "holes"` drills one circle
  of holes at the 3-diameter pitch floor, and `hole_count = 0` takes the most that keep each hole's
  drop at `even_flow_margin` (4) times what a `hole_scatter` (0.1 mm) size difference does at
  `bench_flow`; `outlet = "porous"` is a solid face of Pálfy et al. 2021's thickness and area over
  8 ribs, sliced to leak. `inlet = "socket"` takes the 4 mm riser and M4 set screw, `inlet = "barb"`
  3/16 in silicone, with a report of whether the puck floats. At 4 L/min under 190 mm of water the
  render reports 3 holes and a 5.1 mm bubble floor for the 3 mm face, 13 and 3.3 mm for 0.8 mm, and
  22 and 2.8 mm for 0.5 mm. `docs/build.md` gains the bench procedure, and `references.md` and
  `references.bib` add Pálfy et al. 2021. No reactor sparger changes.
- A pigtail loop sparger, `sparger_name = "loop"` (`sparge_loop()` in `sparger.scad`): one tube
  from the air inlet's riser on the arm's socket, hooked round into a C about the shaft, running
  300° (`sparge_loop_sweep`) 10 mm under the lower impeller's blades with the ring's eight 3 mm
  holes drilled down and the ring's plug screw in its end. It sits inside the baffle plates by both
  their lean and its riser's at its height plus 1.25 mm, capped at 1.4 D, by the mouth and by its
  hook (`sparge_loop_largest()`), and `head()` names the bound that set it: on `jar_10L`
  75.95 mm (1.085 D), set by the baffles, with the hook 3.15 mm off the nearest plate. The smaller
  jars take it under the 1-2 D band with a warning (0.64-0.76 D). `head()` places, checks, reports
  and lists it (`sparge_loop`), warns that it hangs on its riser alone, and `check-designations`
  covers it; no registered build takes it. The arm's boss and screw pilot become
  `sparger_socket_solid()` and `sparger_socket_pilot()`, and `head_baffle_lean_at(height)` and
  `head_coupling_lean_at()` are new.
- A coil condenser on `air_out`: a new designation `condenser_name` (`auto`, `none` or `coil`),
  where `auto` is the coil unless the sparger is the ring, whose supports include `air_out`'s tube,
  so the airlift builds do not move. The condenser's body is `air_out`'s pin, so that port carries
  no tube and riser. The gas line prices the coil's 4.5 mm outlet barb as an orifice (30.5 Pa at
  4.09 L/min on `jar_10L`), and the outlet-filter budget goes from 1.663 to 1.707 kPa per L/min.
  `head()` lists the body, panel, former and both forming pucks, through the new
  `condenser_coil_part()`. `purchased-parts.csv` adds the 3/16 in aluminium tube (5177K62), the
  4.5x1.5 end seals (1289N315) and the xl head's 42x2 ring (8785N431), prices to come, and
  `check-bom` enrols all three.
- A wall baffle cage, `scad/custom/baffle_cage.scad`, and `baffle_name` (`auto` | `lid` | `wall`),
  with `jar_10L_220x305` naming `wall`: four blades at T/12, T/72 off the wall and floor to
  surface, each hung on radial bars that slide in dovetail channels in two C-shaped hoops of
  r 64-70 that pass the mouth flat. Each bar's outer end is closed to stop it after 30.58 mm of
  slide, three 0.5 mm detents hold a blade out and in, the top hoop stands 1 mm over the culture and
  its arm catches the air inlet's riser, and the bottom hoop sits on a derived footing. Under it the
  lid moves pH from 120° to 30° and blanks 120°, 150° and 270° (`head_ports_walled()`). `head()`
  echoes the cage, asserts its clearances, refuses it on magnetic, airlift and ring builds, and
  lists `baffle_cage_hoop_top`, `baffle_cage_hoop_bottom`, four `baffle_cage_blade` (238.7 mm) and
  four `port_blank_std`. `jar_10L`'s baffle area goes from 0.713 of Oldshue's four-at-T/12
  reference to 1.00.
- Registry lookups check every row's field count: each `_by_name` wrapper passes its row's count,
  or the counts allowed (`[7, 8]` for the Atlas probes, whose part number is optional), and a row
  that has lost a field fails with `registry rows [...] do not carry N fields` instead of an undef
  warning on the one build that read it. `fan_by_name` is left out.
- `just check-clash` (`scripts/check-clash.sh`), under `just test`: for every build in
  `bioreactor.json` it intersects the condenser and the sampler, locked and at entry, with the
  probes, port pins, motor, motor mount and each other, and fails on any overlap, a part that
  renders nothing or a logged error. It needs the manifold backend and prints SKIP on OpenSCAD
  2021.01. `head.scad` turns both parts by their bayonet's entry rotation under
  `port_position="entry"`.
- `just check-baffle-cage` (`scripts/check-baffle-cage.sh`), under `just test`: on every build whose
  `head()` echoes a wall cage, it slides the 0° blade along its bar against both hoops and checks
  where it must run free and where the detents and closed end must meet them, that the cage
  clears the glass and everything hung from the lid, and that the hoops turned 2° meet the air
  inlet's riser. A build that does not echo its baffles fails. Like `check-clash` it needs the
  manifold backend and skips without it. `baffle_cage()` takes in-place parts `"hoops"` and
  `"blades"` beside `"cage"`.
- `docs/future-work.md`, holding the ideas nobody has planned with their evidence, and
  `TODO.md` cut to the 16 open items before the paper, down from 46; the rest moved there, to
  issues, or to `docs/decisions.md`, or closed on bench evidence. `docs/build.md` says to seat the
  rod seal with a small flat screwdriver.
- The three Kamoer dosing pumps hang on the frame, each on its printed mount, in the places
  `dosing_pump_places` names (a Customizer list; two in quadrant 2 and one in quadrant 4 by
  default): an unlit quadrant's light pocket on the top rib level, the flange on the rib and the
  motor down through the bore. `peri_pumps.scad` links the NKP-DC-S10B to `motor_12v_5w`, and
  `peri_pump()` draws its 55 x 41 head and the Ø27.5 x 38 mm motor. `frame()` refuses a place
  outside the unlit pockets, two pumps closer than 60 mm, and a motor wider than the mount's bore,
  and `frame_print_parts()` lists `peri_pump_frame_mount` x 3.
- `just check-openscad` (`scripts/check-openscad.sh`), run first by `just check` and `just test` and
  by `export-parts`: it prints which OpenSCAD the gates run on
  (`note <binary> is OpenSCAD <version>`) and fails when that binary gives no version or is older
  than `OPENSCAD_MIN` (2021.01). `docs/decisions.md` records that `check-scad`'s `-D '$fn=0'` pass
  is the only way to render on 2021.01 what a current OpenSCAD renders by default, so it stays. The
  recipe's comment, its FAIL message and `docs/references.md` call 2021.01 the oldest version
  supported locally, and name 2026.10.15 as the snapshot CI runs.
- `just export-accessories` (`scripts/export-accessories.sh`) writes the bench's printed parts to
  `output/accessories/` with a print list, judged and printer-checked like the reactor's parts:
  three `bottle_holder` (for the 86.1 mm round bottle), `estop_box_base`, `estop_box_lid` and
  `stand_corner`, which prints in place of NopSCADlib's bought bracket, all listed by
  `accessory_print_parts()` in the new `scad/support/accessories.scad`. The cart, which prints
  nothing and was never built, moves to `docs/future-work.md`.
- A licence: the design, docs, pipelines and tooling are `GPL-3.0-or-later`, and the raw data and
  figures under `analysis/*/*/raw/` and `analysis/*/*/figures/` are `CC-BY-4.0`, set out in
  `LICENSE`, `LICENSES/` and `LICENSING.md`, with a `CITATION.cff` and a licence section in the
  README. turbidity-sensor is pinned at `4be431f`, which relicenses it `GPL-3.0-or-later`.
- `just render [filter] [build]` (`scripts/render-views.sh`) draws the rows of `scad/views.tsv` to
  `output/figures/<build>/` as orthographic previews cropped to the model, with views `iso`,
  `iso_back`, `front`, `back`, `right`, `left`, `top` and `bottom` or a rotation copied from the
  GUI; it starts with 20 rows on `jar_10L_220x305`. `just render-parts [build]` draws every part
  on the build's print list on its own. `bioreactor.scad` gains `show_vessel`, `show_head` and
  `show_frame`, all `true` by default, so the head alone can be drawn.
- `just cost [rate]` (`scripts/bom-cost.py`) totals `purchased-parts.csv` by scope and currency,
  converting at a given CAD/USD rate, and `just check-prices`, under `just check`, fails on a row
  that cannot be summed.
- `explode` in `head.scad`, the step in mm between neighbouring pieces of the drive stack and the
  lid's ports, which move along the vessel's axis while the lid stays put (the motor 8 steps up,
  the lower impeller 2 down); 0, the default, draws the assembly unchanged. `scad/views.tsv` gains
  `drive_exploded_iso`, `drive_exploded_front`, `lid_exploded_iso` and `lid_exploded_front` at
  40 mm.
- A spike in `scad/_spikes/column_lid/`: a printed top lid for acrylic column reactors, a Ø160 x 8
  mm flange with 8 x Ø10 mm holes on Ø139.5 mm, a Ø99.6 x 10 mm plug for the Ø100 mm bore and an
  18 mm plate that takes the reactor's std pins and blanks. `variant` is `npt` (a 1/2 in NPT
  thread), `centre` (one std bayonet port) or `ring` (one centre port and 6 on a Ø70.8 mm ring,
  the count derived); `pocket_depth` sinks the ports' panel down the bore in a cup, and
  `part = "print"` turns each lid as it prints. `just column-lid` builds them to
  `output/column_lid/`, and `check-scad` skips `_spikes/`. `centre_pocket` at 100 mm is printed
  and in use.
- A Citation section in the README, pointing to `CITATION.cff`.
- `sampler_bought()` draws the turbidity sampler's bought parts in place, on the head under
  `render_all` or `sampler_part_to_render = "assembly"` and in `sampler.scad`'s own assembly, where
  they were `%` ghosts no render showed: the turbidity board in its pocket, the clear FEP tube over
  the barb, the silicone sleeve, the luer-to-barb fitting (as its barb and hub), the inserts, screws
  and nuts from `sampler_fasteners()`, and the syringe actuator with its syringe and motor from the
  pinned syringe-actuator library, through the new `scad/custom/sampler_actuator.scad`. The print
  exports do not change, and `check-clash` now tests the actuator.

### Changed

- The experiment data and scripts moved into `analysis/experiment/`.
- The original FreeCAD models and STLs moved from `models3d/` to `archive/models3d/`.
- `peristaltic_pump_mount.scad` renders with 16 facets in preview and 64 in a full render, and it
  and `impeller.scad` apply the z-fighting offset only in preview.
- `jar.scad` resized to the real jar: 305 mm high, 220 mm diameter, corner radii 25 mm and
  12.5 mm, and a punt 5 mm high and 30 mm wide instead of a point.
- `jar.scad` matched to the lab jar: a 25 mm neck with rounded neck corners and a rounded rim, with
  the body height excluding the neck.
- The base and jar aligned: the base fits a 220 mm jar with 0.4 mm tolerance, 8.5 mm threaded rods
  and nut traps 1.7x the rod diameter; the jar neck corner radius is 12.5 mm and the rim radius
  2 mm, and `jar.scad` echoes the resulting opening diameter.
- `base()` and `jar()` take their dimensions as module arguments, so `assembly.scad` sets them.
- The base wall is 6 mm and the floor 3 mm; nut traps are rotated 30°; impeller twist is 120°.
- `jar.scad` draws one quadrant of the outline and revolves it, which renders faster; `jar()` takes
  named arguments and an `angle`, so `jar_x_sec` renders a 180° cross section.
- The base is 25 mm high and its nut traps 1.8x the rod diameter and 7 mm deep; `base_v1` reprinted.
- Impeller v2: diameter 0.45 of the jar's inner diameter, 4 fins, 55° twist, 4 mm blades, 60 mm
  tall, set by a new height parameter, with the ring outside the blades and sizing guidance in the
  file. `base_v1.3mf` renamed `base.3mf`.
- The impeller module is simpler (height and fin width arguments), `base()` asserts 2-4 rods, the
  peristaltic pump mount has separate base and faceplate mounts, each with its own height, screw
  spacing and taper scale, the SCAD files carry parameter documentation, and parts render with 32
  facets in preview and 128 in a full render.
- The peristaltic pump mount sits on the top base in the assembly under `render_peris`, sized by
  the assembly's parameters (base screws 3.5 mm with 5.4 mm heads at 45 mm, faceplate screws 3 mm
  at 47.5 mm), and `peristaltic_pump_mount.scad` no longer renders an example of its own; the
  lights are rotated 45°.
- `jar.scad` opened on its own renders a small example jar (100 x 50 mm) instead of the lab jar.
- Ribs finished: `rib()` cuts slots for the strip lights (twice the light depth plus 0.4 mm), with
  walls 1.5x the light depth on each side; four ribs alternate at 1/3 and 2/3 of the height, and the
  lights occupy 67.5°.
- The base wall is three times the light depth, the top base is 10 mm high and the nut trap
  15.4 mm.
- `jar.scad` and `peristaltic_pump_mount.scad` moved to `scad/lib/`, the print files moved from
  `scad/stls/` to `stls/`, and old prototypes moved to `scad/archive/`.
- `scad/dcmotor.scad` renamed `scad/dc_motor.scad`.
- The motor mount face screws are 31 mm apart, and the motor, shaft and coupling are left out of
  the assembly render.
- Light pockets on all four sides: the base, the top base and every rib cut a second set of light
  pockets rotated 90°. The strip lights are 7.6 mm deep with a 0.2 mm tolerance.
- Print files moved from `stls/` to `printing/`.
- Ribs are 10 mm high (`rib_base_height`) and sit at two levels, at 1/3 and 2/3 of the span
  between the base nuts and the top base, each level a pair of opposing two-rod ribs; the rod
  spacers fill the gaps between nuts and ribs. Nuts are 6.4 mm high, the motor mount 8 mm thick
  with face screws back at 30 mm, and the motor, shaft and coupling are back in the assembly.
  `render_all` and every render flag default to off, and `render_top_base` is renamed
  `render_upper_base`.
- Print files `lid_v2`, `motor_mount_v2`, `rod_spacer_v2` and `top_base_v2` are added and the
  `base_v1`, `lid_v1`, `motor_mount_v1`, `rib_v1` and `top_base_v1` STLs removed (the
  `rod_spacer_low_v1` and `rod_spacer_up_v1` STLs stay); `base.3mf` holds base v2, and the 3MF
  files drop their version suffix (`motor_mount.3mf`, `rod_spacers.3mf`, `ribs.3mf`);
  `rib_cut_v2.stl` and `rib_sld_v2.stl` are removed, and so is the `export_cut` switch.
- **Breaking:** The motor mount is redesigned: an octagonal body with eight elongated-octagon
  windows, a 4 mm floor, a 20 mm bore for the motor boss and 7 mm pillars. `motor_mount()` takes
  `wall_thickness`, `floor_thickness`, `inner_dia` and `pillar_width` instead of `thickness`,
  `motor_diameter` and `corner_cuts`. In the assembly its height follows the gearbox shaft, shaft
  protrusion and coupling gap (24, 24 and 5 mm), it sits on the lid, and it has its own
  `render_mmount` flag. Print file `motor_mount_v3`.
- The threaded rod holes have 0.6 mm allowance, the lid bearing pocket is 7.5 mm deep, the
  assembly echoes the rod length in cm, and printed parts are drawn in two colours
  (`prints1_color`, `prints2_color`); `rib_v3.stl` reprinted.
- `jar.scad` moved back from `scad/lib/` to `scad/`.
- The probe clamp is sized for the 15.6 mm pH probe body: 1 mm expansion, 2 mm collar and a
  4.6 mm rod hole tapered by 10%, with `render_export` and `export_angle_factor` to export it
  part-open; print file `probe_clamp_v0` (STL and 3MF). The pH probe body is 15.6 mm.
- The motor mount bore is 22 mm and the face screws 27.6 mm apart; print file `motor_mount_v4`.
- `assembly.scad` parameter comments are written so the Customizer shows them; nuts are drawn on
  top of the lid, the impeller sits on the shaft, and the impeller shaft tolerance is 0.1 mm.
- `probe_clamp.scad` opened on its own renders an animated test collar (20 mm nominal, 22 mm
  expanded, 10 mm tall); `probe_clamp.3mf` updated.
- `probe_pinch_collar()` takes `debug` and prints its echoes only when it is set.
- The lid has twelve holes in three sets of four, sized to the 4.6 mm clamp rods, instead of the
  5, 7.5 and 20 mm probe holes; the probe mounts are 8 mm high and sit on the lid on both sides.
  Probe cables are drawn 10 mm long, and `arc_points()` moved to `scad/lib/arc_points.scad`.
- **Breaking:** The lid has a bayonet lock socket in each of its twelve holes, a universal
  connector for probes and tubes, and the plain-hole lid is kept as
  `scad/archive/old_lid_multihole.scad`; print file `lid_v3`. `probe_mount.scad` is renamed
  `tube_mount.scad` (`tube_mount()`), the probe mounts leave the assembly, and tolerances are
  renamed allowances: `lid()` and `tube_mount()` take `allowance`, and the assembly's `*_tol`
  parameters are now `*_allow`.
- The gearbox shaft is 20 mm and the coupling gap 1 mm, which shortens the motor mount; print file
  `motor_mount_v5`. The tube lock pin drawn in the assembly is solid, with no bore, by default.
- **Breaking:** `tube_mount()` holds a flexible tube: a through hole tapered for a snug fit,
  separate tube and screw allowances, and an optional tapered neck. Opened on its own it renders a
  4 mm hole in a 20 mm wide, 2 mm plate with 2.2 mm screws and an 8 mm neck 3 mm tall; print file
  `tube_mount` (STL and 3MF). Parts render with 64 facets in preview.
- The turbidity monitor mount is a 2.8 mm plate hulled around a 28 mm motor and the sensor, offset
  8 mm, with 0.5 mm allowances; the first print is renamed `turbidity_monitor_mount_v0`, with print
  file `turbidity_monitor_mount_v1` (STL and 3MF).
- The turbidity monitor mount fits a 30 mm motor with screws 47.8 mm apart, has a 12 mm edge and a
  slot beside the sensor hole; print files `turbidity_monitor_mount_v2`, `_v3` and `_v3_XL.3mf`.
- The thermocouple pin lock is no longer rendered by default; `render_thermocouple_pinlock` is
  with the other render flags.
- **Breaking:** `scad/lib/peristaltic_pump_mount.scad` is renamed
  `scad/lib/peristaltic_pump_standing_mount.scad` and `peri_mount()` is `peri_pump_stand_mount()`;
  `peri_NKP-DC-S10B.scad` moved to `scad/archive/peri_pump_mount_NKP-DC-S10B.scad`. In
  `assembly.scad` the `mmount_*` parameters are `motor_mount_*`, `render_mmount` is
  `render_motor_mount`, `mmount_face_screws_cdist` is `motor_face_screws_separation`,
  `render_probemounts` is removed, and a `render_bayonet_lock` flag controls the lid's bayonet
  locks.
- The shaft is 400 mm and runs uncut from 5 mm above the jar punt (`shaft_jar_punt_clearance`);
  the motor mount height follows from how far the shaft rises above the lid, so printed parts scale
  with it. The shaft and coupling have their own `render_ext_shaft` and `render_shaft_coupler`
  flags, the lid position is set from the jar height, base floor and lid height, and the Customizer
  stops after the colour parameters.
- `motor_mount()` takes `draft_scale` (flares the base and spreads the base screws to match) and
  `cross_bars` (splits the windows); the assembly uses 1.5 and 1, with 10 mm walls, and screw
  counterbores are 1.75x the screw diameter. Print file `motor_mount_v6`.
- `jar()` subtracts the rim radius from the body height.
- **Breaking:** `impeller()` takes `center_hole_radius` instead of `center_hole_size`, and
  `center_hole_radius_lower` tapers the shaft hole; the assembly narrows it by 0.2 mm toward the
  bottom. Print files `impeller_PC.3mf`, `impeller_PC_XL.3mf` and `impeller_v3.stl`.
- Impeller v4: the shaft hole narrows by 0.3 mm in radius toward the bottom; print file
  `impeller_v4.stl`, and `impeller_PC_XL.3mf` reprinted with it.
- `mould_negative.scad` moved to `scad/archive/`.
- The impeller shaft hole allowance is 0.4 mm and its taper back to 0.2 mm; `impeller_v4.stl` and
  `impeller_PC_XL.3mf` reprinted.
- The motor mount base screws sit in four new flanges at the floor outside the body, turned 45° to
  line up with the flanges and 44 mm apart instead of 32 mm, so a screwdriver can reach them;
  print file `motor_mount_v7`.
- The motor mount floor opening is 0.75 of the bore, so it retains the bearing in the lid below,
  with the full bore starting above the floor; print file `motor_mount_v8`.
- The motor mount base screw flanges are removed again and the base screws are 32 mm apart.
- New motor mount: the parts total 125 mm with the tube between the base and top, the tube has
  counterbores for the screw heads at both ends and narrower windows (0.4 of the diameter, from
  0.5), the base centre hole is 1.5x the 8 mm shaft so it retains the bearing, nut traps are 2.5 x 8
  mm and the fit allowance 0.2 mm; `assembly.scad` echoes the motor mount height in cm. Print files
  `motor_mount_new_middle_v2.stl` and `motor_mount_new_base_v2.stl`.
- New motor mount ends have an 8 mm flange and a 10 mm raised face, the outer diameter is the
  22.6 mm bearing plus eight base screw diameters, the tube is 125 mm, the top is the base turned
  over with counterbores for the faceplate screws, the parts are drawn in colour with a `separate`
  flag to space them apart, and `assembly.scad` includes `motor_mount_new.scad`.
- The new motor mount top's cross screw holes and nut traps sit at the middle of its raised face;
  print files `motor_mount_new_base_v3`, `motor_mount_new_middle_v3` and `motor_mount_new_top_v3`.
- The new motor mount base has counterbores over its lid screws and the `separate` flag is gone;
  `motor_mount_new_top.3mf` updated. `assembly.scad` no longer includes the new motor mount.
- `tube_mount.scad` moved to `scad/shelf/` and out of the assembly; `render_peri_side_mount`
  defaults to off, the assembly echoes `lid_holes_radius`, and `thermocouple_lock.scad` renders
  the pin by default.
- `TODO.md` is a checklist: integrate the motor mount on top of the lid, a bayonet-style pH/DO
  pinch holder for the new probe holder and its place in the assembly, and archiving deprecated
  parts to `shelf/`.
- The pH/DO pinch's inner tail cavity tapers from the body diameter to 8.7 mm, and the pinch
  window and tabs are flipped to widen toward the top; print file `phdo_pinch_v1` (STL, 3MF
  updated).
- **Breaking:** `scad/motor_mount.scad` holds the new motor mount as modules, `male_end()` and
  `middle_pipe()`, and `scad/motor_mount_test.scad` renders the three parts with them;
  `motor_mount_new.scad` is removed. The previous `motor_mount()` moved to
  `scad/motor_mount_old.scad`, which the assembly now uses.
- The pH/DO pinch's third iteration: the tail cavity tapers 8.7 to 4.3 mm again, the tail shell is
  no longer cut, a sleeve for the connector rises from halfway up the tail, and a 9 mm hex hole
  runs through for the SMA connector; print file `phdo_pinch_v2`.
- `tube_lock.scad` renders the pin by default.
- The pH/DO pinch is a `phdo_pinch()` module and the connector hex is 9.3 mm.
- The pinch window is set by `height_pinch_ratio` (0.8 of the body length) and
  `width_pinch_ratio` (0.7 of the shell's outer diameter) instead of one ratio; print files
  `phdo_pinch_v3` and `phdo_pinch_v4`.
- The pH/DO pinch has a 10 mm connector pocket whose sleeve wall is one full shell thick (was half),
  the body cavity is no longer recessed by one wall, `phdo_pinch()` takes `render_supports` for a
  built-in support inside the body with a 0.2 mm Z contact distance (`render_optional_supports`, on
  by default), and a `cross_section()` view; print file `phdo_pinch_v5`.
- Print file `phdo_pinch_v6`, the first print that grips the probe well.
- `phdo_lock.scad` builds the complete pH/DO pinch lock port: the bayonet pin turned over on top,
  a draft from the pinch shell to the lock over the tail length plus 5 mm, the pinch below, and a
  10 mm hex hole through for the connector, with a 1.0 mm pinch gap; print file `phdo_lock_v1`
  (STL and 3MF). The pinch's connector sleeve runs the full tail length and its built-in support
  is a hollow ring with a 0.25 mm contact distance.
- `scad/archive/` is renamed `scad/_archive/`, and `scad/_shelf/` holds the parts not in use:
  `tube_mount.scad` (from `scad/shelf/`), `turbidity_monitor_mount.scad`, and
  `peristaltic_pump_standing_mount.scad` and `rpi4_case.scad` from `scad/lib/`.
- `TODO.md` is split into a critical path and nice-to-haves, and plans scoping vendored hardware
  parameters in their own files, splitting the design into vessel, head and frame subassemblies,
  bayonet connector parameters that map plainly onto the connector geometry, and a layered design
  of bayonet connector library, generic port and specific ports, with the tube interface as a
  generic port with a centre bore and its size printed on the part.
- **Breaking:** `scad/motor_mount.scad` renders the three-part motor mount itself through
  `motor_mount()`, choosing parts with `part_to_render` (`all`, `base_plate`, `face_plate`,
  `middle_stand`), and `scad/motor_mount_test.scad` is removed. `male_end()` and `middle_pipe()` no
  longer take `fit`, and their screw holes run through by the preview z-fighting offset.
- In `scad-v2/`, each part sets its own preview settings instead of including `_config.scad`, which
  is removed; `arc_points.scad` and `trapezium.scad` are in `scad-v2/utils/`; `vessel.scad` holds
  the lab jar's dimensions while the jar model moves to `scad-v2/purchased/jar.scad` as `jar()`;
  and `assembly.scad` describes the interface-based layout, keeping only parameters shared between
  subassemblies.
- `scad-v2/utils/trapezium.scad` no longer renders example trapezia when opened on its own.
- `_archive/` and `_shelf/` moved from `scad/` to `scad-v2/`, with `motor_mount_old.scad` added to
  the archive; `vessel()` is defined in `scad-v2/vessel.scad`, with 64 fragments for arcs and the
  revolve by default, and `scad-v2/purchased/jar.scad` is removed. `generic_bayolock_port.scad`,
  `motor_mount.scad`, `phdo_lock.scad` and `phdo_pinch.scad` are removed from `scad/` and kept only
  in `scad-v2/custom/`.
- The pH/DO lock in `scad-v2/` has a 1.0 mm wall and a pinch window 60% of the probe body length
  instead of 80%.
- **Breaking:** `scad-v2/custom/phdo_pinch.scad` is renamed `cylindrical_flex_tab.scad` and
  `phdo_pinch()` is `cylindrical_flex_tab()`, with `pinch` renamed `flex_tab` in its arguments
  (`height_flex_tab_ratio`, `width_flex_tab_ratio`, `flex_tab_clearance`, `flex_tab_offset`). The
  tabs are offset 0.5 mm inward, the wall is 1.0 mm, the window 60% of the body length, and the
  built-in support is no longer drawn. Print files `phdo_lock_v2` and `phdo_lock_v3`;
  `phdo_lock.3mf` updated.
- Shelved and archived parts in `scad-v2/` load `utils/` and set their own preview settings;
  `mould_negative.scad` is renamed `impeller_mould_negative.scad`; the thermocouple model renders
  when opened on its own, with new defaults: 10 x 12 mm neck, 26 mm flats, 21 x 20 mm body,
  3.5 x 115 mm tip and 3 x 10 mm wire.
- The pH/DO lock tilts the probe 3° off the bayonet pin's axis so bubbles do not get trapped on the
  sensor face, with a wedge filling the gap the tilt opens; the flex tabs are shortened by twice
  the clearance. Print files `phdo_lock_v4` and `phdo_lock_v5`; `phdo_lock.3mf` updated.
- Print file `phdo_lock_v6`, trying a 5° probe tilt; `phdo_lock.3mf` updated.
- **Breaking:** The ports in `scad-v2/custom/` are renamed around one shared bayonet port:
  `tube_lock.scad` is `bayonette_port.scad` (`bayonette_port()`), which can leave out the pockets
  for pliers (`catch_pockets`) and embosses the bore only with `imprint_text`, optionally with
  custom strings (`radius_string_override`, `diameter_string_override`; the file's own render
  shows `DO`); `phdo_lock.scad` is `bayonette_probe_port.scad`, with a 5° tilt;
  `thermocouple_lock.scad` is `bayonette_thermocouple_port.scad`, built on `bayonette_port()`; and
  `peri_pump_side_mount.scad` is `peri_pump_frame_mount.scad` (`peri_pump_frame_mount()`).
  `generic_bayolock_port.scad` is removed.
- The probe port tilts the probe 7°; print files `bayonette_probe_port_v0` (formerly
  `phdo_lock_v6`), `bayonette_probe_port_v1` and `bayonette_probe_port.3mf`.
- The probe port fits a 15.9 mm probe body, for soft-backed probes (16.3 mm for hard-backed);
  print files `bayonette_probe_port_15p9_v1` and `bayonette_probe_port_PP.3mf`, with
  `bayonette_probe_port_v1` renamed `bayonette_probe_port16p3__v1`.
- The probe port has an `internal_allowance` of 0.3 mm that widens the connector hex hole, the
  probe body is back to 16.3 mm, and the port's supports flag is removed.
- Parts in `scad-v2/` use a 0.01 mm z-fighting offset in preview; the bayonet port's inner fill
  cylinder reaches the inner radius plus the allowance instead of plus 0.1 mm;
  `cylindrical_flex_tab()` takes `allowance`, which widens the probe body cavity, and no longer
  takes `render_supports`. Print files `bayonette_probe_port_15p9_a0p3_v1`,
  `bayonette_probe_port_16p3_a0p3_v1` and `bayonette_probe_port_PC.3mf`;
  `bayonette_probe_port16p3__v1` renamed `bayonette_probe_port16p3_v1`.
- The probe port allowance is 0.5 mm, for PC prints, and the probe body 15.9 mm.
- Print files `bayonette_probe_port_15p9_a0p5_v1` and `bayonette_probe_port_16p3_a0p5_v1` replace
  the 0.3 mm allowance prints; `bayonette_probe_port_PC.3mf` updated.
- `cylindrical_flex_tab()` takes `flex_tab_keep_ratio` (default 0.75) and cuts the top off the
  tabs, keeping that share of their height from the foot, which is the part that contacts the
  probe; the tabs are shortened by one clearance instead of two. The probe port keeps half the tab
  height (`flex_tab_keep_ratio` 0.5) and has a 1.5 mm wall. Print file
  `bayonette_probe_port_15p9_a0p5_v2`; `bayonette_probe_port_PC.3mf` updated.
- The probe port allowance is 0.6 mm and its wall 1.2 mm; print file
  `bayonette_probe_port_15p9_a0p6_v3`, and `bayonette_probe_port_PC.3mf` updated.
- **Breaking:** `bayonette_port()` and `bayonette_thermocouple_port()` are renamed `bayonet_port()`
  and `bayonet_thermocouple_port()`, and the probe port is a `bayonet_probe_port()` module that its
  file no longer calls. The probe and thermocouple ports `use <bayonet_port.scad>`, while the file
  is still named `bayonette_port.scad`. The files are then renamed to match: `bayonet_port.scad`,
  `bayonet_probe_port.scad` and `bayonet_thermocouple_port.scad`.
- **Breaking:** `cylindrical_flex_tab()` takes `end_diameter` and `end_fn` (the part above the tail,
  cut through with `end_fn` facets, 6 for the hex SMA connector) instead of `connector_diameter` and
  `connector_facets`, and no longer takes `support_z_contact_distance`. `height_flex_tab_ratio`
  (0.6), `width_flex_tab_ratio` (0.7) and `flex_tab_keep_ratio` (0.5, was 0.75) have defaults,
  `flex_tab_clearance` defaults to the shell wall, and the probe port no longer passes the tab
  height, width and keep ratios, and renders itself again when opened. Opened on its own, the flex
  tab file renders without the animation or cross-section options. `shell_wall` defaults to 1.0 mm
  and `allowance` to 0, and the helper modules are internal (`_flex_tab_profile()`,
  `_part_outer_body()`, `_part_negative_space()`).
- `bayonet_port.scad` loads the lock library from `bayonet-lock-scad/` instead of
  `Bayonet-Lock-SCAD/`. It builds on the library's `bayonet()` and `bayonet_neck()` modules, with a
  shell thickness of half the gap between inner and outer radius and an entry depth of half the
  part height; the O-ring groove, neck allowance, plier pockets and bore text are cut only on parts
  with a neck, and the cuts are no longer coloured in preview.
- **Breaking:** `bayonet_port()` has a new interface: `part` (`pin` or `lock`, checked) replaces
  `part_to_render`; `shell_thickness` replaces `outer_radius`, which is now the inner radius plus
  two shell thicknesses; `center_bore_radius` replaces `inner_radius_fill`; `sweep_angle` replaces
  `path_sweep_angle`; `oring_height` and `oring_interference` (both or neither, the groove cut only
  when set) replace `oring_neck_cut_height`; and `text_labels`, `text_radius_override` and
  `text_diameter_override` replace `imprint_text`, `radius_string_override` and
  `diameter_string_override`. `allowance` (0.2), `number_of_pins` (3), `sweep_angle` (30°),
  `pin_direction` (`outer`), `turn_direction` (`CW`) and `entry_depth` (half the part height) have
  defaults. Opened on its own it renders a pin labelled `R3`/`D6` instead of `DO`.
  `bayonet_probe_port()` and `bayonet_thermocouple_port()` take the same bayonet arguments,
  defaulting to a pin with 7 mm inner radius, 2.5 mm shell, 10 mm part, 5 mm neck, 1.5 mm pins,
  3 mm bore and a 1.6 mm O-ring with 0.1 mm interference (and a 20 mm `mount_height` for the
  thermocouple port, which loads threads-scad).
- **Breaking:** `cylindrical_flex_tab.scad` is renamed `cylindrical_flex_collet.scad` and the module
  `cylindrical_flex_collet()`. `bayonet_probe_port()` takes `bayonet_shell_thickness` instead of
  `shell_thickness`, and it and `bayonet_thermocouple_port()` no longer default their bayonet
  arguments (the thermocouple port still defaults `part` to `pin`); their files pass them
  explicitly. In the probe port file `wall_thickness` is `collet_wall_thickness` and
  `probe_body_lenth` is `probe_body_length`.
- `motor_mount()` in `scad-v2/custom/motor_mount.scad` defaults `facets` to 20 and asserts that it
  is divisible by 4, so the screws placed every 90° line up.
- In `bayonet_probe_port.scad`, `internal_allowance`, `flex_tab_gap` and `flex_tab_offset` are
  `collet_internal_allowance`, `collet_tab_gap` and `collet_tab_internal_deflection`, and
  `animate_flex_tab` and `extra_length` are removed.
- `rpi4_case.scad` moved from `scad-v2/_shelf/` to `scad-v2/dev/`, and previews the Raspberry Pi
  model alone by default instead of the case top and bottom.
- **Breaking:** `bayonet_port()` follows the current bayonet-lock-scad interface: it takes
  `interface_radius` instead of `inner_radius` and `shell_thickness`, `neck_radius` for a plain
  cylindrical neck, and `oring_cs_diameter` instead of `oring_height` and `oring_interference`;
  `center_bore_radius` defaults to 0, which fills the core solid. The neck's O-ring groove and
  outer allowance are no longer cut, and the plier pockets and labels sit at 0.8 of the interface
  radius and scale with it. Opened on its own it renders a 12 mm interface with a 15 mm neck and a
  1.6 mm O-ring.
- **Breaking:** `bayonet_probe_port()` takes the probe dimensions and collet design values as
  required arguments (`probe_body_length` through `tilt_degrees` and `transition_length`), with
  no defaults, instead of reading file-level variables.
- `rpi4_case.scad` moved back from `scad-v2/dev/` to `scad-v2/_shelf/`.
- `scad-v2/frame.scad` no longer defines the strip light length, width, depth and window radius,
  which are registered in `strip_lights.scad`, but it does not load them from there, so the frame's
  lights and the base wall thickness derived from the light depth are undefined.
- `TODO.md` adds a top level: review the open items, and replace `generic` parameter registrations
  with the actual hardware, such as McMaster-Carr part numbers.
- **Breaking:** `atlas_probe()` takes one `accent_color` for the neck instead of a `colors` list,
  drawing the neck pink when it is unset so an uncoloured probe stands out, and `atlas_probes.scad`
  gives each probe one colour (red for pH, goldenrod for DO); `TODO.md` notes optional end styles
  (sensor gland) for the Atlas probes. The neck, body, tip and wire diameter dimensions no longer
  have defaults (`wire_h` defaults to 10 mm), and `atlas_probes.scad` holds the probes as registry
  rows
  `[name, [neck_d, neck_h, neck_taper_d], [body_d, body_h], [tip_d, tip_h], wire_d, accent_color]`
  in `atlas_probes = [ph, do]` instead of Customizer variables.
- `README.md` describes the project as a composable, modular and extensible bioreactor design
  under development, explains `scad/` (the original files) and `scad-v2/` (the main path going
  forward, after which `scad/` will be archived), and lists the OpenSCAD libraries used:
  Bayonet-Lock-SCAD, FunctionalOpenSCAD and NopSCADlib.
- In `scad-v2/purchased/`, `circular_pattern()` moved from `strip_light.scad` to
  `scad-v2/utils/circular_patterm.scad` and `surround_lights()` is removed, so the frame draws no
  lights; `atlas_probe()` no longer positions the probe from its base (`position_base` has no
  effect).
- `frame()` no longer draws the strip lights or cuts light pockets in the bases and ribs, and
  loads `strip_lights.scad`; `dc_motor.scad` opened on its own renders an example gearbox.
- **Breaking:** `dcmotor()` in `scad-v2/purchased/dc_motor.scad` is renamed `dc_motor()`.
- **Breaking:** The purchased part models take a registered type: `atlas_probe(type, wire_h)`,
  `strip_light(type)` (with `strip_light_width()`, `strip_light_depth()`, `strip_light_length()`
  and `strip_light_radius()`), and `threaded_thermocouple()` is `thermocouple_probe(type, ...)`
  (with `thermocouple_probe_*()` getters), which no longer renders when its file is opened. The
  registry lists are `strip_lights` and `thermocouple_probes` instead of `strips_lights` and
  `thermocouples_probes`, and `atlas_probes.scad` opened on its own previews the pH, DO and an
  inline custom probe.
- **Breaking:** The gearbox is its own model, `gearbox(type)` in
  `scad-v2/purchased/gearbox.scad`, with a `gearboxes.scad` registry: `generic_gearbox` is
  36 x 26 mm with an 8 x 20 mm output shaft, a 22 x 3 mm input bore, and 4.2 mm faceplate screws
  27.6 mm apart. `gearbox_shaft_diameter()` and `gearbox_shaft_length()` are
  `gearbox_output_shaft_dia()` and `gearbox_output_shaft_length()`. `dc_motor(type)` takes a
  registered type with an optional bare shaft `[d, l]` and an optional gearbox type, drawn on the
  motor face; `dc_motors.scad` rows are `[name, [motor_dia, motor_len], shaft, gearbox]`, and
  `generic` uses `generic_gearbox`.
- The frame places its strip lights by quadrant: `light_quadrants` ([1, 3]), `lights_per_quadrant`
  (3) and `occupy_angle` (65° of each 90° quadrant), drawing the `generic` light. The peristaltic
  pump frame mounts leave the frame, with their parameters kept as comments in
  `peri_pump_frame_mount.scad`.
- `base()` cuts a nut pocket on both faces of each rod hole when nut dimensions are given, instead
  of only the lower one.
- The frame cuts light pockets again: the base, upper base and ribs are cut by the lights in all
  four quadrants. The lights occupy 60°, a single light per quadrant sits at 45°, and the ribs and
  rod spacers are positioned without the base floor and nut heights.
- The frame draws four M8 threaded rods (NopSCADlib `studding()`) with nuts at the bottom, on top
  of the base and on top of the lid, under `render_rods`, and needs NopSCADlib. The threaded rod is
  8.0 mm with a 1.2 mm hole allowance (was 8.5 and 0.6 mm), and the `render_lid`,
  `render_bayonet_lock` and `render_peri_side_mount` flags are removed from the frame.
- **Breaking:** `scad-v2/assembly.scad` renders the frame around the vessel's height and diameter,
  `render_all` is on by default, and `vessel_x_sec` is `cross_section_active`, on by default. The
  frame derives its dimensions from its arguments, sits with the vessel bottom at the origin, and
  opened on its own renders around a 305 x 220 mm jar; its nut pockets are the NopSCADlib M8 nut
  across corners plus `nut_pocket_allowance` (0.4 mm), and the nut height is the M8 nut's, instead
  of 15.4 and 6.4 mm.
- `scad/thermocouple_lock.scad` and `scad/tube_lock.scad` load the lock library from
  `bayonet-lock-scad/` instead of `Bayonet-Lock-SCAD/`, and `README.md` links the library under
  that name.
- `scad-v2/assembly.scad`'s header lists the three subassemblies (vessel: the glass jar; head:
  closure with flange, rotational drive and I/O and instrumentation ports; frame: base plate,
  closure retaining plate with tie points, ribs, threaded rods, spacers and nuts) and their
  cross-coupling: vessel and frame share the vessel's outer diameter and height, vessel and head its
  outer and opening diameters, and head and frame `lid_flange_height`, with the frame assuming the
  head presents a flat face of the vessel's diameter. It lists the parameters each subassembly
  receives from the top level. The vessel Customizer sections are Coupling (height, diameter) and
  Details. `head.scad` has a `temp_lid_flange_height` (10 mm) placeholder.
- `scad-v2/assembly.scad` derives `vessel_opening_diameter` from the vessel diameter and corner
  radii.
- `vessel()` can be driven by its opening: it takes exactly two of `corner_radius`,
  `neck_corner_radius` and `opening_diameter`, solves the missing radius, and asserts that two are
  given and that neither radius comes out negative.
- The frame's light pockets are boxes the light's width and depth plus `light_allow`, now 0.4 mm
  (was 0.2 mm), instead of the light's own shape.
- `TODO.md` drops the completed items (archiving to the shelf, the motor mount on the lid, the
  bayonet probe pinch holder and its place in the assembly, scoping hardware parameters, and the
  subassembly split) and the review task, adds finishing the peristaltic pump model and integrating
  it with a motor, and a second hardware revision: a cheaper 300 mm impeller shaft instead of the
  400 mm one, and printed parts instead of the threaded rods. Longer rationale is on sub-bullets.
- `scad-v2/assembly.scad` sets `vessel_opening_diameter` (143 mm) and passes it to `vessel()`,
  which solves the neck corner radius; `vessel_neck_corner_radius` is removed from the assembly.
  The geometry is unchanged.
- `scad-v2/assembly.scad` computes `vessel_internal_height` (the vessel height less the punt and
  wall), for placing the impeller and sizing the motor mount and shaft protrusion, though nothing
  reads it yet; the header lists
  it as a vessel-head coupling and a head input, and a `render_head` block is stubbed in that
  renders nothing yet.
- `scad-v2/frame.scad` stops the Customizer after the colour parameters.
- **Breaking:** `lid()` in `scad-v2/custom/lid.scad` takes `height_od` (the flange) and `height_id`
  (the plug into the vessel opening) instead of one `height`, and no longer takes the unused
  `rod_hole_diameter`, `nut_dia` and `nut_h`.
- `scad-v2/head.scad` is rebuilt on the `scad-v2/` parts as a `head()` module, drawn from the top of
  the vessel at the origin and rendering everything by default (`render_all`). The lid is turned
  over onto the vessel, with an 8 mm flange and a 10 mm plug (`lid_plug_height`), a shaft hole, a
  22.6 x 7.5 mm bearing pocket with 0.2 mm `bearing_hole_allowance`, and twelve port holes; the
  bayonet locks in them render separately under `render_bayonet_lock`, from new bayonet parameters
  (10 mm interface radius, 1.2 mm pins, 10 mm part, 5 mm neck of 15 mm radius, 3 mm bore, 1.6 mm
  O-ring). The motor is a registered type, `head_motor` (`generic_dc_motor`), which draws its own
  gearbox and supplies the gearbox dimensions and faceplate screws. The motor mount is the
  three-part `motor_mount()` (3.5 mm base and 3.1 mm tube screws, 22 mm motor boss, 8 mm flanges,
  10 mm raised faces, 20 facets), its middle tube the gearbox output shaft plus the shaft
  protrusion less the two flanges. The shaft protrusion and the shaft's position follow
  `vessel_internal_height`, and the shaft coupling is drawn with NopSCADlib. `lid_rad_allow` and
  `lid_h_allow` are `lid_radial_allowance` and `lid_vertical_allowance`, `impeller_DT_factor` is
  `impeller_impeller_vessel_diameter_factor`, `render_probes` is replaced by
  `render_probe_pinlock` and `render_phdo_probes`, and the tube and thermocouple pin locks are left
  out for now.
- **Breaking:** `gearboxes.scad` registers the generic gearbox as `generic` instead of
  `generic_gearbox`. `dc_motors.scad` still names `generic_gearbox`, so the generic motor is drawn
  without its gearbox.
- **Breaking:** Registered purchased parts are named per registry, so they no longer collide when
  several registries are included together: `generic_dc_motor`, `generic_gearbox`,
  `generic_strip_light` and `generic_thermocouple_probe` instead of `generic`. This also defines
  the `generic_gearbox` that `dc_motors.scad` refers to again.
- `motor_mount()` in `scad-v2/custom/motor_mount.scad` no longer colours its three parts (slate
  grey, grey and slate blue), so the caller sets the colour; the head draws it in `prints1_color`.
- `TODO.md` adds making the bayonet connector geometry cheaper to compute, since a lid with several
  of them is slow in the viewer.
- **Breaking:** `scad-v2/assembly.scad` renders the head:
  `head(lid_flange_height, vessel_outer_diameter, vessel_opening_diameter, vessel_internal_height)`
  takes its cross-coupled inputs as arguments and sits at the vessel height plus the lid flange
  height, set by a new `lid_flange_height` Customizer parameter (8 mm). `vessel_diameter` is
  `vessel_outer_diameter`, `frame()` takes `vessel_height` and `vessel_outer_diameter` instead of
  `jar_height` and `jar_diameter`, and the head's impeller factor is
  `impeller_impeller_vessel_outer_diameter_factor`. `head.scad` opened on its own renders for a 220
  mm vessel with a 143 mm opening, 295 mm internal height and an 8 mm flange.
- `arc_points.scad` moved from `scad-v2/utils/` to `scad-v2/_shelf/`, beside the probe clamp that
  uses it, and `thermocouple_probe.scad` no longer loads `trapezium.scad`.
- `TODO.md` drops the item on bayonet connector parameters mapping plainly onto the geometry, and
  its interface-based design item names the probe holder and thermocouple as specific ports.
- `.gitattributes` sets a line-ending policy: text is stored with LF line endings (CRLF for
  `.bat`, `.cmd` and `.ps1`), common binary formats (images, archives, CAD and print files) are
  marked binary, and STL, STEP and FCStd files stay in Git LFS.
- `purchased-parts.csv` lists RWNTAO 13" LED grow light bars (3000K, 144 LEDs, about 330 mm per
  tube, matching the 336 mm CAD pocket) instead of 8.6" strips.
- `purchased-parts.csv` lists the motor as the E-S Motor 36D planetary gear motor RM-ESMO-16Q
  (36PG-3429-5.2: 12 V, 5.2:1, rated 950 RPM; motor 34 x 29.4 mm, gearbox 36 x 26.5 mm, 8 x 20 mm
  D-shaped shaft), gives the light bars' power (at most 15 W for both on 5 V/3 A USB), and the
  Slice_RLHT's two relays (air pump at 12 V, LEDs at 5 V).
- `purchased-parts.csv` gives the bearing as 440C stainless, 22 x 8 x 7 mm (the CAD pocket is
  22.6 mm for shrinkage and allowance), the shaft coupling as a uxcell 8-to-8 mm rigid coupling
  25 x 14 mm, and the peristaltic pumps as the Kamoer NKP-DC-S10B (12 V, 5.2-90 mL/min, 3 x 5 mm
  silicone tube).
- `TODO.md` adds reconciling `bayonet_port()`'s parameters (`interface_radius`,
  `oring_cs_diameter`) with the probe and thermocouple port calls (`inner_radius`,
  `shell_thickness`, `oring_height`, `oring_interference`) and confirming that `head.scad` and all
  12 ports generate without error.
- `purchased-parts.csv` lists the culture vessel as a commodity 10 L airtight soda-lime glass jar
  from Alibaba (USD 11.49) instead of the Anchor Hocking jar, with the same 220 x 305 mm size and
  143 mm opening.
- **Breaking:** The vessel is a purchased part: `scad-v2/vessel.scad` moved to
  `scad-v2/purchased/vessel.scad`, with a `vessels.scad` registry whose rows are
  `[name, [height, diameter, thickness], [opening_dia, neck], [corner_rad, corner_rad_base], [punt_h, punt_w], rim_rad]`.
  `vessel(type, angle)` takes a registered type, solves the neck corner radius from the opening
  (`vessel_neck_corner_radius()`), and asserts that there is room for it and that both corner radii
  exceed the wall; accessors such as `vessel_height()`, `vessel_diameter()`,
  `vessel_opening_diameter()` and `vessel_internal_height()` read a type. The registry holds
  `generic_vessel` and the lab jar `jar_10L_220x305` (305 x 220 mm, 143 mm opening).
  `scad-v2/assembly.scad` selects `reactor_vessel = jar_10L_220x305` instead of its vessel
  Customizer parameters and passes the frame and head the dimensions read from it.
- **Breaking:** `bayonet_port()` no longer takes `text_radius_override` or
  `text_diameter_override`; its labels are always the bore radius and diameter.
- The probe port builds its probe holder only on the pin half; the lock half is the bare bayonet.
- **Breaking:** `dovetail()` rounds every corner of the profile with an arc of `crown_radius`
  (default a quarter of the height) instead of taking `corner_setback` and `corner_fn`, and
  `dovetail_pts()` no longer takes them either: it returns the plain dovetail outline with sharp
  corners. Both take `root_width` (default two thirds of the crown width) to set the flare;
  `dovetail.scad` no longer loads `trapezium.scad`, and `trapezium()` draws from
  `trapezium_pts()`.
- The bottle holder is sized for an 86.1 mm round bottle instead of the 62.6 mm square one; print
  file `bottle_holder_duran` (STL and 3MF).
- `impeller.scad` opened on its own renders an example with 4 fins of 2 mm instead of 6 of 1 mm.
- `TODO.md` marks the interface-based bayonet port design done.
- **Breaking:** The bayonet interface is one vector,
  `[name, [iface_r, shell_t, pin_r], [part_h, neck_h, neck_r], [oring_cs, oring_intf], allow]`, read
  with accessors in `bayonet_port.scad` (`bayonet_interface_radius()` through
  `bayonet_allowance()`). `bayonet_port()`, `bayonet_probe_port()` and `bayonet_thermocouple_port()`
  take it as `bayonet` instead of the separate interface, pin, neck, O-ring and allowance arguments,
  and `head.scad` defines it as `bayonet` in place of its `bayonet_*` parameters. In `head_ports`
  the thermocouple port has a 3 mm bore and the probe ports none.
- The analysis data is reorganised into `analysis/runs/<date>-<subject>/` and
  `analysis/methods/<name>/`, each with its untouched export in `raw/`: the 2024 data is
  `runs/2024-11-19-microalgae/raw/microalgae_raw.csv`, the July 2026 export is in
  `runs/2026-07-23-chlorella-ccpc90/raw/`, and the light data is
  `methods/light-irradiance/raw/spectroscopy_data.csv`. The old committed plots are removed.
- `analysis/lib/` is removed; each `pipeline.py` carries its own raw-format readers.
- **Breaking:** `scad-v2/purchased/peri_pump.scad` draws a registered pump, `peri_pump(type)`, read
  through accessors (`peri_pump_carrier_diameter()` and others), instead of file-level globals and
  `peri_pump_head()`. Rows are
  `[name, [carrier_dia, carrier_base_th, carrier_allowance], [roller_od, roller_id, roller_len, roller_n, roller_offset], [cassette_h, cassette_wall, cassette_allowance], tube_dia, shaft_bore]`,
  so the roller count is registered; the carrier diameter is a pump dimension rather than the motor
  diameter. The geometry is unchanged.
- **Breaking:** The motor and gearbox are registered by part number: `generic_dc_motor` is
  `motor_36pg_3530_5p18` (36PG-3530-5.18, 34 x 30 mm, 2 x 8 mm shaft, 8 x 3 mm boss) and
  `generic_gearbox` is `gearbox_36pg_5p18` (36PG-5.18, 5.18:1, its dimensions unchanged), which the
  head uses. A second motor, `motor_12v_5w` (27.5 x 38 mm, 2.3 x 20 mm shaft, 10 x 3 mm boss, 2 mm
  face screws 15.75 mm apart), is the bare motor on the peristaltic pump head. Motor rows add a
  shaft boss and face screws (`dc_motor_boss()`, `dc_motor_face_screws()`); `dc_motor()` draws the
  boss and the shaft from its end.
- The peristaltic pump frame mount bores for its own motor, `mount_motor = motor_12v_5w`
  (27.5 mm), instead of 34 mm, asserts that the motor fits within the flange span, and drops the
  commented-out parameter block.
- **Breaking:** `bayonet_probe_port()` and `bayonet_thermocouple_port()` no longer take `part`;
  they always build a pin half. `bayonet_port()` leaves the entry depth and shell thickness
  defaults to bayonet-lock-scad.
- **Breaking:** The bayonet interface is registered as `bayonet_std` in
  `scad-v2/custom/bayonet_interfaces.scad`, regrouped as
  `[name, [iface_r, shell_t, pin_r, part_h, allow], [neck_h, neck_r], [oring_cs, oring_intf]]`; the
  modules and accessors take it as `type` instead of `bayonet`, and `head.scad` selects it with
  `head_bayonet`. Opened on their own, the port files preview `bayonet_std` (10 mm interface, 1.2 mm
  pins), the interface the lid builds, instead of 9.5 mm with 1.5 mm pins, which could not mate with
  it.
- **Breaking:** `bayonet_port()` builds both halves already mated around the panel: z = 0 is the
  panel's outer face, it takes `panel_thickness` and draws a shank through the panel, and the
  pin's flange keeps a spigot one allowance under the hole with the O-ring rebate cut outside it.
  The neck is called the flange (`bayonet_flange_height()`, `bayonet_flange_radius()`), the pin
  count, sweep, pin direction and turn direction move into the registered row (3, 30°, `outer`,
  `CW`) instead of being module arguments, and `bayonet_port_hole_radius()` (interface radius plus
  0.5 mm) sizes the lid holes. The probe and thermocouple ports take `panel_thickness`, and
  `port_position` in `head.scad` draws the ports `locked` or at `entry`
  (`bayonet_entry_rotation()`).
- `bayonet_port.scad` tessellates by feature size (`$fa`/`$fs`) instead of a flat 64/128 `$fn`,
  so the 1.2 mm locking pins are no longer drawn at a 0.06 mm chord. A lock half renders in 1.7 s
  instead of 29.6 s and a pin half in 6.9 s instead of 61.2 s; the shell and bore keep their
  resolution (0.004 mm chord error).
- `impeller()` sweeps each twisted fin in `twist_slices` steps, default 90, instead of a fixed 360,
  holding the blade surface within about 27 µm; the impeller renders in 10.0 s instead of 68.4 s.
- `TODO.md` drops the finished bayonet interface items and the item on bayonet render cost.
- `README.md` lists threads-scad, which the thermocouple port and probe need, among the libraries;
  `bottle_holder.scad` stops the Customizer after its parameters.
- Parts in `scad-v2/` all use a 0.05 mm z-fighting offset in preview (was 0.01 mm in most).
- `TODO.md` adds rethinking how the impeller diameter is driven (it scales off the vessel's outer
  diameter, and nothing asserts it fits through the opening) and aligning the assembly,
  subassembly and part parameter interfaces, and notes that the gearbox's 22 mm input bore may
  belong to the output face.
- `TODO.md` adds carrying the probe tail and connector dimensions in `atlas_probes.scad`, which are
  now entered again in `head.scad` and `bayonet_probe_port.scad`, with a proposed row shape and
  the open question of which body diameter to register.
- `jar_1gal_155x251` has a 14 mm base corner radius instead of 8 mm.
- `head.scad` selects which motor mount part to render with `motor_mount_part_to_render`, and
  `motor_mount()`'s `render` argument is `part_render`.
- `gearbox_36pg_3429_5p2` takes the 36GP gearbox's input bore (same brand and interface) instead
  of none.
- **Breaking:** The bayonet coupling spans the lid: its band is the panel thickness tall, starting
  at the panel's inner face, so the registered interface row no longer carries a part height
  (`[iface_r, shell_t, pin_r, allow]`) and `bayonet_part_height()` is removed. Port holes are the
  interface radius plus the shell thickness less 0.1 mm, so the lock unions cleanly with the lid,
  and `bayonet_std`'s flange radius is 14 mm instead of 15 mm.
- **Breaking:** `motor_mount()` is driven by the motor and gearbox it carries. It takes `height`
  (overall), `body_diameter`, `wall_thickness` (which also sets the flange and raised face heights),
  one `screws_diameter`, `shaft_diameter`, `motor_faceplate_screws_separation`,
  `motor_boss_diameter` and `coupling_allowance`, with `vertical_hole_allowance` (1.1 mm) and
  `horizontal_hole_allowance` (0.1 mm), instead of separate base, tube and face screws, bearing
  diameter, flange, raised face and middle heights. The base screws sit at the body diameter less
  three screw diameters, the counterbores are twice the screw clearance hole's diameter, and the
  tube no longer has vertical holes; opened on its own the file renders a 141 mm mount with a 56 mm
  body. In `head.scad` the mount is `motor_mount_body_diameter` (56 mm),
  `motor_mount_wall_thickness` (10 mm) and `motor_mount_coupling_allowance` (0.2 mm), takes its
  screws from the gearbox and its boss from the gearbox's output boss, and is as tall as the gearbox
  output shaft plus the shaft protrusion and coupling offset, with the gearbox face flush on top.
- `motor_mount()` takes `boss_allowance` (0.4 mm) and sizes the faceplate's boss hole so the
  faceted hole's inscribed circle clears the boss by it.
- `bayonet_std`'s flange radius is 13.4 mm, still covering the O-ring.
- The generic thermocouple has a 10 x 10 mm neck, 24 x 4 mm flats, a 22 x 18 mm body and a 2.5 mm
  wire.
- **Breaking:** Each probe port is cut for its registered Atlas probe: `head_ports` entries for
  probes take a third slot naming the probe (`ph`, `do`), and `bayonet_probe_port()` takes `probe`
  and reads the body diameter from it instead of `probe_body_diameter`, so the ports are 15.6 mm
  for pH and 16.0 mm for DO instead of a shared 15.9 mm. `head.scad` opened on its own reads the
  vessel from `reactor_vessel` instead of hardcoded 10 L jar dimensions, and `reactor_vessel` is a
  Customizer drop-down of the registered vessels.
- **Breaking:** The probe port reads the probe body length from the registered probe, so
  `bayonet_probe_port()` no longer takes `probe_body_length` and `head.scad` drops
  `probe_port_body_length`. The registered pH body is 36.0 mm long (was 35) and the DO body
  35.6 mm, as measured.
- The `atlas_probes.scad` header says that the body diameter is the registered number that reaches
  printed geometry, so a probe should be measured before printing a port for a row that is not a
  caliper reading; the 16.3 mm body in `cylindrical_flex_collet.scad`'s preview is commented as
  the hard-backed probe variant.
- **Breaking:** The probe's tail and connector dimensions are registered: Atlas probe rows take a
  tail group `[tail_maj_d, tail_min_d, tail_h, conn_d]` at index 4 (8.7, 4.3, 24.5 and 10 mm),
  moving `wire_d` and `accent_color` to 5 and 6, read with `atlas_probe_tail_major_dia()`,
  `atlas_probe_tail_minor_dia()`, `atlas_probe_tail_length()` and `atlas_probe_connector_dia()`.
  `bayonet_probe_port()` no longer takes `tail_major_diameter`, `tail_minor_diameter`,
  `tail_length` or `connector_part_diameter`, and `head.scad` drops its `probe_port_tail_*` and
  `probe_port_connector_diameter` parameters. The printed port is unchanged. The registry header
  and `TODO.md` record that the tail group and `neck` describe the same strain relief boot and
  disagree, with where each reading came from and how to settle it with a printed port.
- **Breaking:** The `scad/` tree is the former `scad-v2/`, renamed now that the original tree is
  gone; `README.md` describes one source tree.
- **Breaking:** Each Atlas probe row holds one group per physical feature: `neck` the strain relief
  boot, `body` the cap, `tip` the shaft, and `conn_d` the cord-end connector (8 mm, from the
  datasheets) in place of the tail group, whose accessors are removed. The probe port sizes the
  collet's neck section from the boot and cuts the connector hex as (`conn_d` + allowance) /
  cos(30) instead of 10 mm plus the allowance; its envelope is unchanged and its internal cavities
  change. `TODO.md` drops the neck/tail conflict and adds putting the pH and DO caps on their
  datasheet values.
- **Breaking:** Every Atlas probe row is the product as its datasheet gives it: the pH and DO caps
  are 16.0 x 36.2 mm instead of the caliper readings (15.6 x 36.0 mm pH, 16.0 x 35.6 mm DO), which
  widens the probe port's bore by 0.4 mm and lengthens its grip by 0.2 mm. The collet's
  `collet_internal_allowance` is split into `collet_body_allowance` (the cap grip) and
  `collet_connector_allowance` (the connector hex), both 0.6 mm, in `bayonet_probe_port()` and
  as `probe_port_collet_body_allowance` and `probe_port_collet_connector_allowance` in
  `head.scad`.
- `TODO.md` records that the 15.9 mm soft-backed and 16.3 mm hard-backed probe variants are not
  tracked, since no datasheet mentions them, and `cylindrical_flex_collet.scad` no longer comments
  its 16.3 mm preview body as one.
- **Breaking:** The lab pH and DO probes are registered in two generations: `ph_lab_g1` and
  `do_lab_g1` (no longer sold but still in use in the lab; `ph_lab_g1` is the earlier measured set
  with a 15.6 x 36.0 mm cap, `do_lab_g1` a 16.1 x 36.2 mm cap and 64.0 mm shaft) and the current
  `ph_lab_g2` and `do_lab_g2`, which replace `ph_lab` and `do_lab` and which `head.scad` and the
  probe port preview use. The g2 and other pH rows split the 36.2 mm cap into a 30.2 mm body and a
  6 mm neck (9 mm to 8 mm), from measurement, which shortens the port's grip by 6 mm and its neck
  section by 20 mm.
- **Breaking:** The frame sizes its base from the light and the rod: `frame()` takes
  `lights_length`, `wall_thickness` and `rod_length`. The base floor is how far the light, 1.5 nut
  heights and the upper base overrun the vessel (at least 2 mm) instead of a fixed 3 mm, the lower
  base is the floor plus a 25 mm wall, `total_height` no longer includes the top base, and an
  assert requires the wall to clear both the light pocket and four rod hole diameters. The rod and
  its nuts move up with the floor, one of the rod's three nuts is dropped since the lower base
  pockets its own, and the nut pocket allowance is
  0.6 mm (was 0.4 mm). `assembly.scad` adds `reactor_lights` (`rwntao_13in`) and
  `frame_wall_thickness` (37 mm) and passes a rod as long as the vessel plus the lid flange and
  8 mm.
- **Breaking:** `scad/custom/base.scad` and `scad/custom/lid.scad` are removed, their shapes drawn
  in place in `frame.scad` and `head.scad`: the lower base keeps its floor ring, the top base is a
  hollow ring, and only the ribs keep the rod bosses. The lid's flange is the vessel diameter plus
  the frame wall thickness, so `head()` and `lid_pocketed()` take `frame_wall_thickness`, which
  `assembly.scad` passes. The geometry is unchanged.
- `frame()` takes `collapse_spacer_z_allow` (on by default and in `assembly.scad`, off in the
  standalone preview): the ribs and spacers butt down from the lower base and the stack's whole
  2.4 mm of spacer allowance shows as one gap under the top base, which drops with its nut by that
  amount, instead of being spread across the six joints.
- `TODO.md` adds tooling plans: scripts to export a parameter set as STL files with a print list
  and BOM, `tokei` code statistics in CI, and the Just the Docs OpenSCAD setup with its web
  preview.
- `TODO.md` adds the sealing parts and head-to-frame joint fasteners missing from the BOM (8 M8
  bolts and 20 M8 nuts, with the bolt length held until the lid gap is settled), and calipering the
  jar rim, whose flat land the gasket recess is cut to is derived rather than measured.
- `lid_holes_n` counts the `head_ports` list instead of restating 12, so a 13th row reaches the
  port spacing assert instead of being dropped.
- `scad/assembly.scad`'s header describes the interfaces as the code has them: every parameter
  `head()` and `frame()` take, the head-to-frame joint in four parts, the lights-to-frame coupling,
  and which accessors are read back from `frame.scad` and `head.scad`.
- `scad/custom/motor_mount.scad` marks its standalone values as an example, not the bioreactor's
  mount, which is exported from `head.scad`.
- `BOM_Bioreactor.ods` is renamed `BOM_Bioreactor_1p5L_legacy.ods`, since it describes the 1.5 L
  predecessor.
- **Breaking:** The impeller is sized against the vessel's wetted bore: `impeller_bore_ratio`
  (0.45) replaces `impeller_impeller_vessel_outer_diameter_factor`, which multiplied the outer
  diameter and let the real ratio drift from 0.468 to 0.489 across the registered vessels. The
  impeller is 94.5 mm instead of 99 mm, and `jar_6p5gal_305x470` builds again (it binds at 0.4594).
  The twist angle and blade height are marked uncharacterised.
- **Breaking:** `gearbox_faceplate_screws_cdist()` is `gearbox_faceplate_bolt_circle_dia()` and
  `motor_mount()`'s `motor_faceplate_screws_separation` is `motor_faceplate_bolt_circle_dia`, since
  the value is a bolt circle diameter, not a span between two screws. The geometry is unchanged.
- `head_motor` is the encoder gearmotor `motor_36pg_555pm_14_en` instead of `motor_36gp_3530_5p18`.
  The drive stack grows 35.5 mm, the reactor envelope from 543.75 to 579.25 mm and the cart from
  1312.5 to 1383.5 mm.
- **Breaking:** `head.scad` drives the impeller from a registered type, `head_impeller_type`
  (`impeller_twisted_paddle_4`), instead of the `impeller_height`, `impeller_n_fins` and
  `impeller_twist_ang` parameters: blade count, twist and blade height come off the row, the
  height as a width ratio of the diameter (0.634921, the 60 mm of 94.5 mm), so it scales with the
  impeller. With no measured Po of its own, the type borrows `folded_axial_4`'s 0.99
  (`head_impeller_po_fallback`) and `head()` echoes that it does and that the figures derived from
  it are conservative. A type without a width ratio fails with a message naming it.
  `stirred_tank_power_number_folded_axial_4()` and
  `stirred_tank_dissipation_factor_pitched_blade()` are removed. The geometry is unchanged.
- The baffles pass the impellers instead of stopping above them: `head_baffle_width()` takes the
  narrower of the widest plate the lock bore passes and the room outside the impeller sweep at
  `baffle_impeller_clearance`, 15.3 mm at D/T 0.45 instead of 19.39 mm, and `head()` refuses to
  build when no plate fits (past D/T 0.54). `baffle_max_length` is set by the floor
  (`baffle_floor_clearance`, 10 mm) instead of the upper impeller, 280 mm instead of 123.5 mm;
  `baffle_length` stays 100 mm. `bayonet_baffle_port()` takes an optional `width`, asserted to pass
  the lock.
- The impeller hub is 10 mm in radius instead of 7.5 mm, so it can take set screws: tap holes for
  `impeller_set_screw` (`set_screw_m4x6_316`) at 0° and 120° (`impeller_set_screw_at`), cut as plain
  holes at NopSCADlib's tap radius with no thread modelled. `head()` warns when the screw does not
  reach the shaft or engages less than one screw diameter, and `docs/agitation.md` records that the
  hub buries 6.3% more blade span.
- `TODO.md` notes that the `BB608` bearing and the impeller set screws are registered but never
  drawn.
- The off-bottom clearance is a parameter, `impeller_clearance_factor` (0.4233 D, the previous
  placement), instead of following from where the shaft ends: the shaft runs past the impeller to
  the punt, so the motor mount holds at 122 mm from 0.4233 to 1.2328 D. `head()` asserts the
  shaft still reaches the lower impeller's bore and the upper impeller stays below the liquid
  surface.
- `impeller_clearance_factor` is 0.6 D (C/T 0.27), raising the impellers 16.7 mm and the room under
  the lower one from 10 to 26.7 mm. `head()` reports the culture's coverage over the upper impeller
  and warns below 0.5 D, and `docs/agitation.md` records why Oldshue's 1-2 D band and his coverage
  requirement cannot both be met in this vessel.
- `head()` reports Oldshue's 1-2 D fluidfoil clearance, and why this vessel cannot reach it, as a
  plain line instead of a `WARNING`, since the band is permissive; the coverage warning stays.
  `docs/agitation.md` marks the C/T quarter-to-third convention as uncited.
- The lid carries four baffles instead of three, at every third port (30°, 120°, 210° and 300°),
  and `head_ports` is laid out around them: air out at 0°, DO at 60°, the thermocouple beside it
  at 90°, pH at 150°, a 1.5 mm media/spare tube at 180°, air in at 240° (180° from DO), acid at
  270° and base at 330°. One 1.5 mm tube port is dropped. `docs/ports-layout.md` gains the
  index-to-function map. The baffle area ratio goes from 0.14 to 0.19, and the warning names the
  next count that spaces equally on the port circle instead of one more plate.
- The baffles hang 280 mm, the floor limit, instead of 100 mm, and are 8 mm thick instead of 4 mm,
  raising the baffle area ratio from 0.19 to 0.856. `stirred_tank.scad` adds the plate load, tip
  deflection and first bending mode (counting the entrained water's added mass) and the shaft and
  blade-passing frequencies; `head()` reports them for printed PETG (`baffle_modulus` 1800 MPa,
  `baffle_density` 1270 kg/m³) and warns at a deflection over a tenth of the plate width or a mode
  within 30% of either excitation. A 4 mm plate this long would sit at 5.4 Hz, shaft rotation at
  the rated 320 rpm; at 8 mm the mode is 13.3 Hz and the tip deflects 1.1 mm.
- `docs/references.md` and `docs/agitation.md` record that Leupold 2013's band (1.26 m/s optimum,
  2.03 m/s break-even) is the rim speed of a spinning plate with skirt in a 1.75 L microcosm, not
  an impeller tip speed: its shear comes from the plate-to-wall gap, the quoted Pa figures are the
  secondary bottom stress, and direct calibration stops at 250 rpm. The design still uses the
  band, now stated as an assumption.
- `impeller_pbt_45_4` and the three folded-axial rows register a blade width ratio of 0.2, from
  the Czech Standards Fořt's blades are drawn to (CVS 691020 and CVS 691010), instead of undef,
  leaving `impeller_twisted_paddle_4`'s 0.634921 the only unsourced width. `docs/references.md`
  records Fořt's H/T of 1.0 against 1.124 here, and that the folded blade's Po 0.99 does not
  transfer to a flat 45° plate.
- `head()` takes the power number from one of three sources and says which: MEASURED from the row,
  CORRELATED from Medek's correlation when the row carries a blade angle, or BORROWED from
  `head_impeller_po_fallback`.
- `head_impeller_type` is `impeller_pbt_45_4`, a four-blade 45° pitched blade turbine, instead of
  the hand-drawn `impeller_twisted_paddle_4`, with Po 1.602 and flow number 0.806 from Medek's
  correlation. Every power, dissipation and torque figure rises about 62%, and the baffles are
  9 mm thick instead of 8 mm to keep their deflection under a tenth of the plate width. Each blade
  projects 13.4 mm onto the shaft instead of 60 mm, so the pair spans 107.9 mm instead of
  154.5 mm, the room under the lower impeller grows from 26.7 to 50.0 mm and the coverage over the
  upper one from 0.63 to 0.88 D. `docs/agitation.md` records why an axial blade was kept.
- `impeller_clearance_factor` is 0.9 D instead of 0.6 D, after Fořt's finding that a pitched
  blade's hydraulic efficiency is higher at C/D 1.0 than at 0.5; circulation per watt is 18.5%
  better than at 0.6 D, and the impellers rise 28.35 mm (clearance 56.7 to 85.05 mm). `head()`
  reports Oldshue's 1-2 D as context, since it is for fluidfoils, and names the guidance that fits
  the blade; the 0.5 D coverage floor stays, put down to air entrainment near the surface.
- `TODO.md` adds a gas supply section, and the ReSun air pump row in `purchased-parts.csv` states
  the mismatch: the reactor needs 0.82-4.09 L/min at 1.12 kPa (0.1-0.5 vvm on 8.17 L), 16-80x
  less flow and 24x less pressure than the pump's rating, with no flowmeter, regulator or check
  valve in the BOM to set or hold it; and air at 425 ppm CO2 supports about 0.09 g/L/day at
  0.5 vvm, where 1 g/L/day would want about 0.47% CO2. The item is then narrowed to measuring the
  gas flow: vvm moves no geometry, enrichment happens upstream of the sterile filter, and what
  stands is a rotameter, a check valve and the filter's uncounted pressure drop; the pump row
  calls the CO2 limit an operating choice resting on a 30% utilisation assumption. `TODO.md`
  records that the July 2026 run grew _Chlorella vulgaris_ CCPC 90 for 8.7 days on air alone
  without pH control, which settles the CO2 question for growing Chlorella, and that its medium
  was 0.2 g/L Miracle-Gro, whose urea carbon is worth about 0.035 g/L of biomass in all.
- `TODO.md` closes the sparger design item, recording that its position and non-round section
  were derived, and marks Oldshue's 80% ring and a sparger under the lower impeller superseded;
  demotes characterising the twisted blade, which the build no longer uses; and closes the 300 mm
  shaft item, since no 300 mm cut exists, 200 mm cannot reach the 295 mm vessel, and the mount
  holds at 122 mm on the 400 mm shaft.
- `TODO.md` records that five of the six registered vessels fail an assert in `head()`, which went
  unseen because only the selected vessel is rendered: the port circle scales with the mouth and
  the impeller with the bore, and only the 10 L jar's mouth suits both. The 6.5 gal jar fails
  separately, on its fixed shaft.
- The sparge ring sits at the outermost radius the jar's mouth allows, keeping
  `sparge_ring_clearance` (1.25 mm) to the baffles and the mouth, instead of at a fixed
  `sparge_ring_ratio`, which is removed; `head_baffle_width()` takes the ring as a third bound, so
  the baffles give way to it. The ratio is reported against the 1-2 D band, inside it on every
  registered vessel (1.03 to 1.85). The 10 L jar's baffles stay 15.30 mm and its ring moves
  0.21 mm out; `generic` and `jar_1gal_180x197` lose 8.1% of baffle width. The two ring fit
  asserts are removed, and three vessels move on to their next failure.
- `head_shaft` defaults to undef and resolves to the shortest registered shaft that reaches the
  vessel, with a row still able to pin one, and the shaft has to stand at least half the
  coupling's length (12.5 mm) proud of the lid instead of any amount. `jar_6p5gal_305x470` takes
  `shaft_8x600_316` and fails next on baffle room, and the slenderness warning says the excess
  length comes from the registry's 200 mm steps. `lid_pocketed()` takes `shaft_diameter`.
- `lid_plug_oring` defaults to undef and resolves to any registered ring whose groove, computed
  for that ring, lands it at 0-5% stretch, with a row still able to pin one. When none fits, the
  assert names the free ID range and cord the mouth needs, such as 136.86 to 143.703 mm on a
  2.62 mm cord for a 148 mm mouth. The 10 L jar keeps the AS568-160 at 4.27%.
- `TODO.md` lists the plug o-ring each registered mouth needs, blocked until AS568 catalogue data
  is at hand, and asks whether a metric series would land closer.
- **Breaking:** O-ring rows carry the number to order the ring by,
  `[name, part_number, [id, cs], material, hardness, colour]`, read with `oring_part_number()`:
  8785N383 for the port seal, and empty for the plug ring, now named `AS568-160`, which was written
  from the standard rather than a listing.
- **Breaking:** Every `head_ports` row leads with the port's function,
  `[function, type, bore_radius]` with the probe in slot 4 (`air_out`, `baffle`, `do_probe`,
  `temperature`, `ph_probe`, `media`, `air_in`, `acid`, `base`), read with `head_port_function()`,
  `head_port_type()`, `head_port_bore_radius()` and `head_port_probe()`. `head_port_index()` finds a
  port by function and fails unless exactly one matches, and `head_sparge_feed_port()` asks for
  `air_in`, replacing `sparge_feed_port = 8`. The geometry is unchanged.
- **Breaking:** Thermocouple rows are
  `[name, part_no, thread, [neck_d, neck_h, flats_h, body_h, tip_d, tip_h, wire_d, wire_h]]`, read
  with the new `thermocouple_probe_part_number()` and `thermocouple_probe_thread()`; the hex
  across-flats and body diameter are derived from the thread instead of registered. The 1/2 NPT
  mount's major diameter is 21.336 mm (was 21.34 mm) and its mark reads `1/2 NPT`.
- `TODO.md` parks an airlift variant with no impeller, a draft tube giving a defined riser and
  downcomer, and records why the small jars' incidental mixing by the air alone is not to be relied
  on.
- `TODO.md` adds the port-size work the vessel family needs: spreading the big ports so no two are
  adjacent, registering mini and midi bayonet interfaces, making the port table a property of the
  vessel, and revisiting the 56 mm motor mount diameter.
- The lid gasket is no wider than `lid_gasket_width_max` (6 mm), sitting against the rim's inner
  edge, instead of taking the whole rim: `jar_6p5gal_305x470`'s 12 mm wall asked for a 10 mm gasket
  and 87.9 kN of seating force, and now takes 6 mm and 20.1 kN, about 1.7 kN a post. No other
  registered vessel reaches the cap, so their geometry is unchanged.
- `TODO.md` adds reporting a mixing time and kLa, and deciding whether light penetration belongs in
  the model; `assembly.scad` records that M8 is the joint bolt's cap, since the gasket is its only
  load.
- `TODO.md` closes the mixing time and kLa items with the figures the model reports and drops the
  light penetration item.
- Each port in `head.scad` takes its own bayonet interface (`head_interface_for()`): the lid's
  bores, locks, face seals, pins and entry rotation per port, the port circle and plug groove from
  the widest interface on the lid, and the baffle width from the baffle port's. The port spacing
  assert measures the worst adjacent pair of flanges, and keying is checked on each oriented port's
  own interface. Every port is still `std`, so the geometry is unchanged.
- **Breaking:** Each port takes the smallest bayonet interface that fits what it carries: probes
  and baffles stay `std`, and the five tubes and the thermocouple go to `bayonet_mini`, so the lid's
  tube bores drop from 12.4 to 7.4 mm in radius. Bores need 2 mm of wall (`port_bore_wall`); an NPT
  mount needs flange to stand on. The temperature port names its probe, the 1/8 NPT
  `mcmaster_3872K131_thermocouple_probe` (9 in, 1/8 in sheath). The twelve-port lid's smallest mouth
  does not change, since every probe sits beside a baffle; a six-port lid with mini tubes wants a
  77.6 mm mouth instead of 87.6 mm.
- `TODO.md` closes the mini and midi interface item and retires spreading the big ports, which the
  four equally spaced baffles make impossible.
- `just check-scad` fails on any `WARNING` as well as an `ERROR`, since that is how OpenSCAD reports
  an undef reaching arithmetic or a parse error in a `use`d file.
- **Breaking:** The port table is chosen per vessel: `head_port_set_full` (the twelve) and
  `head_port_set_reduced` (six at 60°: DO probe, air out, media, air in, pH probe and thermocouple,
  the two probes opposite each other) are registered, and `head_port_set_for()` picks the fullest
  set whose flanges clear on the mouth. `head_ports` is an override, undef by default, and
  `lid_holes_n` is gone; `head_port_index()` and `head_sparge_feed_port()` take the mouth diameter.
  `jar_6p5gal_305x470` takes the reduced set and builds; `jar_1p5L` and `jar_1gal_155` now fail on
  the motor mount overlapping their port flanges. The 10 L jar keeps the twelve, unchanged.
- `docs/ports-layout.md` and `TODO.md` record that both port sets are registered and chosen by the
  mouth, and that `jar_6p5gal` builds on the reduced set; a three-baffle set stays unregistered.
- `head.scad` records why the motor mount stays 56 mm across: 42 mm is the floor before its base
  inserts meet the bearing pocket, it would raise the slenderness on the 10 L jar from 2.3 to 2.9,
  and the narrow jars are 6.6 and 14.9 mm of diameter short of that floor.
- `TODO.md` closes the motor mount diameter item, adds settling how the narrow jars are agitated,
  and adds exploring a magnetic drive: a DC fan under the jar turning a magnet rotor inside it that
  pivots on the punt.
- `TODO.md` records the JSON parameter sets as done and what the STL and BOM export still needs.
- `TODO.md` rewrites the vessel item as four of six vessels not building for two causes, and
  closes registering plug o-rings for the other mouths; `purchased-parts.csv` gives the AS568-160
  plug o-ring its part number, 8785N637.
- `baffle_length` defaults to undef, hanging each baffle to its own jar's floor limit, instead of
  280 mm for every jar: the three baffled vessels take 275, 280 and 172 mm, and a number still pins
  it. `generic` and `jar_1gal_180x197` build, so four of six registered vessels build; the 10 L jar
  is unchanged.
- `TODO.md` records two of six registered vessels not building, for one cause: `jar_1p5L_109x215`
  and `jar_1gal_155x251` cannot carry a top-entry drive, since their port flanges leave 27.1 and
  35.4 mm where the motor mount's floor is 42 mm. That waits on the narrow-jar agitation question.
- `reactor_lights` defaults to undef and resolves to the shortest registered strip light that
  covers the culture (`strip_light_for()` in `strip_lights.scad`, falling back to the longest),
  with a row still able to pin one, and `frame.scad`'s preview chooses the same way. Short jars
  stop carrying base under an overhanging light: `jar_1gal_180x197` takes the 217 mm light and its
  base goes from 152.75 to 39.75 mm, `jar_1p5L` from 134.75 to 21.75 mm and `jar_1gal_155` from
  98.75 to 2 mm, while `jar_6p5gal` takes the 400 mm light, covering 113% of its culture instead of
  93%. `generic` and the 10 L jar keep the 330 mm light, unchanged. `head_liquid_height()` is
  exported for it.
- Each port set carries its own thermocouple: the twelve-port set goes back to 1/2 NPT with the
  6 in `mcmaster_1245N31_thermocouple_probe`, and the six-port set keeps 1/8 NPT, as the
  6 in `mcmaster_3872K129_thermocouple_probe`, so its thermocouple can sit beside DO. The 9 in
  probe both sets carried overshot `jar_1gal_180x197`'s floor by 28.6 mm. `head()` reports the
  thermocouple's reach and asserts its tip ends above the floor and below the culture surface;
  every registered vessel puts it 55.8 to 107.4 mm under the surface.
- `TODO.md` adds three sparger tube items: the tubes end inside their port with nothing to push a
  hose over, nothing marks which socket feeds gas, and nothing states where a support tube's
  drilled hole or slit goes.
- **Breaking:** The sparge riser is a registered tube: `scad/purchased/steel_tubes.scad` registers
  22 McMaster-Carr 316 welded metric tubes, 2 to 12 mm OD, with part numbers, read with
  `steel_tube_od()`, `steel_tube_id()`, `steel_tube_second_moment()`, `steel_tube_part_number()` and
  others. `sparge_riser_tube` (`steel_tube_welded_4x0p5`, 50415K21, 4 x 0.5 mm, hard temper)
  replaces `sparge_riser_od` and `sparge_riser_id`, since a 4 x 2.5 mm tube is not sold, and
  `sparge_feed_bore` derives from its OD. `head()` reports the stock length to cut the tubes from,
  `just check-bom` checks the tube's part number, and `purchased-parts.csv` lists one 1 m length
  of 50415K21 (USD 22.72) cut into two 186.7 mm tubes. The support tube's stiffness is 1.79 N/mm.
- `purchased-parts.csv` identifies the commodity fasteners by standard instead of `TODO`:
  `ISO 4017 M8x30 A2-70`, `ISO 4032 M8 A2`, `ISO 4762 M4x8 A2-70` and `DIN 975 M8 A2`, all 18-8
  stainless. The threaded rod is one stock length cut into four (4 x 322 mm on the 10 L jar), and
  `TODO.md` closes the fastener part number item.
- `TODO.md` records that no assembly torque is specified: the joint bolts are preload-limited by
  the soda-lime jar (291.8 N per post, about 0.6 N m on M8, against 20-24 N m for A2-70), and
  whether the 1.19 mm gasket recess is meant to bottom out is undecided. It also notes that the
  sparge back-pressure leaves out the riser's own drop.
- `BOM_Bioreactor_1p5L_legacy.ods` is replaced by `purchased-parts_1p5L_legacy.csv`.
- The gas back-pressure counts the line, not only the vessel: `head()` adds the sterile filter's
  drop (`sparge_filter_drop_slope`, 3.45 kPa per L/min, extrapolated rather than measured) and the
  riser's, from `gas_filter_pressure_drop()` and the Darcy-Weisbach `gas_tube_pressure_drop()` in
  `gas_supply.scad`. At the design flow the filter is 14.1 kPa and the riser 116 Pa, so the pump
  beats 15.3 kPa instead of 1121 Pa, the throttle's drop falls from 24.2 to 9.96 kPa, and
  `head()` reports the metering valve Cv it needs (`gas_valve_cv()`, 0.030). `purchased-parts.csv`
  registers the filter as Cole-Parmer 1594522, priced in CAD.
- `purchased-parts.csv` names the check valve: Cole-Parmer 5011521, a polypropylene and Viton
  miniature check valve with a 3/16 in barb (CAD 7.37), 0.18 psi cracking and 0.014 psi closing.
- The baffle plates are 10 mm thick instead of 9 mm: the tip deflects 1.296 mm instead of
  1.635 mm, inside a tenth of the 15.3 mm plate, while blade passing crosses the plate's first mode
  at 264 rpm, below the 320 rpm rated speed (11 and 12 mm would fire the resonance warning). The
  running clearance stays -0.28 mm.
- `TODO.md` records open questions about the impeller: its tip ring is 86.7% unsupported with a
  61.6 mm longest bridge, the drawn blade departs from the correlated shape (the ring, and a 4 mm
  plate at t/D 0.042), and nothing in `just check` renders a solid, since `.csg` export never runs
  CGAL.
- `purchased-parts.csv` closes the gas metering rows: a Dwyer VFA-23 rotameter without a valve
  (0.6-5 L/min, CAD 86.22) and a Clippard MNV-4K2 needle valve (Cv 0.090, USD 13.99) upstream of
  it, at 33% of travel at the design point.
- `TODO.md` records the chosen gas parts and why the filter's drop moved the valve from MNV-2 to
  MNV-4K2, and makes the baffle running clearance a measurement to take first: print a baffle port
  and one segment and measure the lean, with four candidate fixes listed by cost.
- `TODO.md` records that the rim gasket's recess cannot be the stop: it holds three quarters of the
  gasket's section (3.57 against 4.76 mm2), so the flange would bottom on extruded rubber, and the
  free-bulge shape factor behind the 291.8 N per post does not describe a confined pad.
- `TODO.md` records that the solved neck corner radius is smaller than the wall on
  `jar_1gal_180x197` (3.5 against 5 mm) and `jar_1p5L_109x215` (3.36 against 4 mm), leaving a notch
  round the neck root, as part of the rim caliper item.
- **Breaking:** The culture volume is integrated over the jar's own profile
  (`vessel_swept_volume()`, `vessel_profile_litres()`) instead of a cylinder on its bore, which read
  low by 1.31% on `jar_10L` and up to 2.76% on `jar_1p5L`. `head()` takes `vessel_profile`, which
  `assembly.scad` passes, and reports the jar's brim-full capacity (9.573 L for `jar_10L`) and what
  a cylinder would have said; `stirred_tank_volume()` is removed. Every per-volume figure moves
  slightly: the required throttle Cv goes from 0.0296 to 0.0303 and the vvm band to
  0.828-4.14 L/min.
- This build's working volume is pinned at 8.25 L (`culture_working_volume`), 235.1 mm deep, 79.7%
  of the internal height, keeping 0.555 impeller diameters of culture over the upper impeller where
  8.0 L would leave 0.479. `just check-vessels` sweeps the registry with the volume unset.
- `purchased-parts.csv` refreshes the filter, rotameter and metering valve rows for the 8.25 L
  volume: filter 14.23 kPa, design point at 82.5% of the rotameter's scale, Cv 0.0301 at
  4.125 L/min. No part changes.
- `TODO.md` marks the sparger tubes' hose item done and records that CI's OpenSCAD 2021.01 resolves
  a `use`d module's `$fn` differently from newer builds, so a green suite does not prove the desk
  is clean.
- The metering valve is the Clippard MNV-3KP (3° needle, #10-32 ports, USD 15.11) instead of the
  MNV-4K2, whose 20° needle is the coarsest of the range; both are rated 5 scfm at 100 psig, and the
  MNV-3KP sits at 2.8x the required Cv and 35% of travel.
- The sparger's feed boss is a hex where the support bosses are round, so the feed socket can be
  told apart, and tube ports engrave their function as well as their bore (such as `AIR IN Ø6` and
  `ACID Ø4.8`), since `air_in` and `air_out`, and `acid` and `base`, carried the same mark.
  `bayonet_label_text()` in `bayonet_port.scad` formats both tube and probe labels.
- `docs/agitation.md`, `docs/procurement.md`, `docs/ports-layout.md` and
  `docs/design-conventions.md` refresh their figures for the pinned 8.25 L and the counted gas line:
  Np 1.602 to 1.498 with every dissipation column about 7% lower, peak dissipation at the rated
  speed 3.0e4 W/m3, per-vessel volumes from each jar's profile, and the filter's 14.2 kPa, which
  `docs/procurement.md` had called immaterial. They record why the baffle plate is 10 mm, the gasket
  cutting fixture, support riser drilling, the hex feed boss, the port labels, why only the DO probe
  leans, and the mesh and `$fn` checks.
- `just check-vessels` and `TODO.md` record that `jar_1gal_155x251` now fails first on a vertical
  DO probe running 6.29 mm through the upper impeller, before its motor mount.
- `TODO.md` drops its 34 completed items, going from 771 to 334 lines, splits out four open points
  that were inside them, brings the gas flow item to current numbers, and adds a ledger of settled
  decisions.
- The gas ports `air_in` and `air_out` are bored for the riser (`tube_port_riser_bore`, its OD plus
  0.2 mm) instead of a 3 mm hose radius, taking the riser's slack from 2 mm to 0.4 mm; the interface
  and port circle do not change. `head()` asserts each support port's bore passes the tube, and
  every registered steel tube now resolves (2-5 mm on a mini flange, 6-8 on a midi, 10-12 on std).
- `baffle_segment_height_max` is a print-quality cap on a piece's slenderness instead of a literal
  170 mm bed: twelve times the width of the widest plate the baffle port's bore passes
  (`baffle_brim_spread` 3 times `baffle_slenderness` 4), 205.07 mm on `jar_10L` against a 163 mm
  tallest piece, under a
  ceiling of the shortest registered printer's Z less 10 mm (`baffle_segment_height_ceiling`). The
  baffles still print as two 140 mm pieces. `TODO.md`'s ledger records that the lid follows the
  frame's 257.40 mm outer diameter and that the cap is not to be derived from a printer again.
- **Breaking:** The peristaltic pump registry carries the pump the build buys,
  `peri_pump_kamoer_nkp` (Kamoer NKP-DC-S10B, a 67 x 55 x 41 mm envelope, 3 x 5 mm tube), drawn by
  `peri_pump.scad` as a box; `generic_peri_pump` is removed. The printed pump head moves to
  `scad/custom/peri_pump_head.scad`, an entry file now, with its names prefixed `peri_pump_head_`.
  `head.scad` selects `head_dosing_pump` for the `acid` and `base` ports, reports the tube's
  interference in their bore (5 mm in 4.8 mm, 0.2 mm) and warns if the tube would be loose;
  `just check-bom` checks the pump's part number. `TODO.md` adds a bracket for the bought pumps.
- `just check-parts` accounts for every entry file: each is either walked by `just export-parts`
  or declared with a reason, and it fails on a file in neither list or in both. The print list and
  `docs/build.md` say they cover the reactor's own parts and not the cart, electronics stand,
  bottle holder or peri pump mount, and `TODO.md` adds giving those manifests.
- `head()` finds the feasible mouth window by bisecting the same sample grid in 11 evaluations
  instead of walking all 1441 samples, with the same result, and walks the full sweep when the
  upper bound binds. `just check` goes from 10 min to 25 s and `just export-parts` from about
  25 min to 6 min 18 s.
- `head.scad` tessellates by feature size (`$fa` 6/2, `$fs` 1.2/0.6 mm in preview/render) instead
  of a flat `$fn` of 128: the lid renders in 107 s instead of 150 s, with 22586 triangles instead
  of 27082, its flange gaining facets (128 to 180) while its small bores lose them (at worst
  0.0156 mm undersize on the M4 insert hole). No other exported part changes.
- `TODO.md` records that `just check-mesh scad/head.scad` cannot pass, since the head defaults to
  `render_all` and unions the motor, bearing, probes, seals and culture into one mesh; the printed
  parts pass one by one in `just export-parts`.
- `docs/design-conventions.md` extends its rule against one fact stated twice to documents, and
  makes a corrected figure keep its predecessor, labelled "(Superseded - kept for the record.)"
  with what it was and what made it wrong.
- `docs/build.md` and the print list call for food-grade clear PETG for parts the culture touches
  and grey PETG for structure, instead of transparent PETG.
- `rod_thread_proud` derives from two coarse pitches of the rod's diameter (`bolt_coarse_pitch()`,
  2.5 mm on M8) instead of a literal, so it follows a change of rod. Output is unchanged.
- The gasket factor is read from ASME BPVC.VIII.1-2019 itself, Table 2-5.1 p.399, which confirms
  the figures `head_gasket_factor()` encodes (m 0.50 below 75A Shore, 1.00 at or above, 0 for
  o-rings). The table's minimum seating stress `y` is 0 psi for the 60A sheet, so there is no
  seating minimum to check, and its own note calls the values suggested, not mandatory. The
  standard joins `docs/references.bib` as read (49 entries), the trade-press summary stays as the
  secondary source, and `TODO.md` drops the item.
- `just check-vessels` sweeps `head.scad`, `assembly.scad` and `frame.scad` against every vessel,
  each at its own defaults instead of with the working volume and probe leans forced, and keys
  `broken` by file and vessel; a listed cell the sweep never reaches fails too. Eighteen renders
  take 37 s. The `broken` list gives `jar_1gal_155x251`'s blocker as a vertical pH probe running
  6.29 mm through the lower impeller.
- `docs/design-conventions.md` describes a third kind of parameter, the build designation (which
  registered jar, motor or probe, and what fill fraction), and where each kind lives: a designation
  travels as a name resolved by a by-name lookup, "auto" means derive it, only departures travel,
  and pinning reports what derivation would have chosen rather than switching the checks off. It
  records what OpenSCAD was found to allow: `-D` reaches a `use`d file's globals and `-p`/`-P` do
  not, an undef default is invisible to the customizer, a flat vector travels only as a string
  and a nested table not at all, `-p` beats `-D` silently, and `openscad -o /dev/null` renders
  nothing. `assembly.scad`'s header states the two kinds of parameter and the designation surface,
  and no longer claims `head.scad` asks for `$fn` 64/128; `TODO.md` records the decisions left in
  code.
- `TODO.md` records what the fill-fraction change left open: `jar_1gal_180x197` builds with
  10.94 mm of culture over its upper impeller (0.143 D against the 0.5 D floor), because the
  impeller spacing and clearance factors are single globals; documents still quoting the 8.25 L
  figures (a 571.25 mm envelope, not 579.25, and an 8.2807 L line giving 0.82807-4.14035 L/min);
  and `motor_mount_body_diameter` (56) restating the gearbox plus two walls. Its ledger entry
  pinning the working volume at 8.25 L is marked superseded.
- The motor mount's slenderness limit of 5 diameters warns instead of refusing, since it was
  reasoned and not cited; the warning above 3 is unchanged.
- **Breaking:** `generic_vessel` leaves the swept `vessels` list and stays defined, so it is no
  longer in the `reactor_vessel_name` dropdowns or in `assembly.json` and `head.json` (5 sets
  instead of 6), and `just check-vessels` sweeps 15 cells over 5 vessels instead of 18 over 6.
- `docs/design-conventions.md` splits the swept-list rule: a placeholder stays defined and out of
  the list, while a discontinued or bundled real part stays swept with the deviation noted beside
  it. `generic_thermocouple_probe` leaves `thermocouple_probes` (19 rows to 18), and
  `castors.scad` notes that `generic_castor` is a placeholder kept until a real castor is
  registered.
- `just check-bom` checks the motor mount's heat-set insert, and fails on a registry row whose part
  number is empty instead of skipping it. Its header names everything it checks and why the gasket
  sheet and the drive motor are left out.
- **Breaking:** `assembly.scad` designates the shaft, plug o-ring and strip light by name:
  `shaft_name`, `plug_oring_name` and `strip_light_name`, strings defaulting to `"auto"`, replace
  the row-valued `head_shaft`, `lid_plug_oring` and `reactor_lights`, so a parameter set can carry
  them. Each resolves through its registry's by-name lookup, an unregistered or duplicated name
  fails naming the registry file, and pinning a part keeps its fit checks on.
- `just check-json` verifies every designation declared with a dropdown against its registry, from
  a table of designations and whether `"auto"` is allowed for each, instead of the vessel's alone.
  `shaft_name` and `strip_light_name` gain dropdowns; `plug_oring_name` stays a free field.
- `TODO.md` brings four items up to date: two of five vessels fail to build, both on the drive,
  with the sweep covering three files; the refused set-screw rewraps and port-table threading are
  recorded with their reasons; the hoisting item is down to the parameters a build still cannot
  carry; and the export item is down to the four printed parts that have no manifest.
- **Breaking:** `do_probe_port_tilt_degrees` is removed, and the DO probe's lean is always derived.
  `do_probe_port_tilt_max` (4.5°), the ceiling on it, moves into `assembly.scad`'s Build section
  and travels in `reactor_build`, so a parameter set can carry it (2 gives a 2° lean). At a
  ceiling of 8 on `jar_10L` the model reports the 4.62° the jar takes rather than refusing.
  `head.scad` keeps its own ceiling for rendering on its own.
- `docs/design-conventions.md` lists the eccentricity figures measured against the glass, after
  the model had been corrected for the impeller ratio, among the instances of one physical thing
  stated two ways.
- **Breaking:** `head()` builds the tube sparger in place of the sparge ring. `sparge_tube_extent()`
  (the octagon across its corners) feeds the mouth, baffle, meridian and probe-reach checks, and
  the bore and tube derive from the riser tube (`sparge_bore()`, `sparge_tube()`, with
  `sparge_wall` 1.2 mm), replacing `sparge_ring_section` and `sparge_ring_wall`; new parameters are
  `sparge_tube_facets` (8), `sparge_ring_count` (1), `sparge_inner_fraction` (0.35),
  `sparge_split_angle` (14°), `sparge_plug_screw` (`set_screw_m4x6_316`) and
  `sparge_hole_probes`. It reports on every render an open area ratio of 2.25 for eight 3 mm holes
  on a 4 mm bore, and a bore velocity head of 4.54 Pa against 2.48 Pa at a hole, as true of the old
  ring; `TODO.md` records fixing it as a decision against the settled 8 x 3 mm hole spec.
- The sparger's arms are structural by default: `spoke_bores` names the arms that carry gas and is
  empty unless set, so the feed alone joins the rings, instead of two loops dividing the gas by the
  network's resistance and 31.4 mm of bore a brush cannot reach. `sparger()` asserts that an arm
  with holes is fed. The reactor's sparger, one ring with no arms, does not change.
- `just check-holes` checks that each gas hole is fed as well as that it breaks out: every hole
  declares an `exit` point inside its discharge face and a `feed` point on the tube's centreline,
  both must be void, and a failure names which. A ring bore swept 180° instead of 360° fails 5 of
  20 holes, all on `feed`; the probe catches a hole landing in the dead arc where the ring bore
  stops short of each cut face.
- The motor mount's body diameter is derived from its gearbox, the gearbox diameter plus two walls
  (`head_motor_mount_body_diameter()`), instead of the literal `motor_mount_body_diameter` (56 mm),
  so it follows a designated motor.
- `head()` sets its own tessellation (`$fn` 0, with `$fa` and `$fs` from `head_fa()` and
  `head_fs()`), so the head renders the same opened on its own or through `assembly.scad`.
- `just check-parts` gives `cart.scad` and `electronics_stand.scad` as printing nothing original
  (bought parts, and a printed stand-in for a NopSCADlib bracket) and `bottle_holder.scad` as the
  one accessory with printed geometry. `TODO.md` corrects three items whose premises were wrong,
  among them that the sparger's lever is its bore rather than its hole size (an 8.5 mm bore clears
  with the settled 8 x 3 mm holes).
- Every tube port drops a 316 stainless tube to the sparger, where `air_out` alone did, so the ring
  is held at five points on the twelve-port lid and three on the six-port jars. The support ports
  are derived from the port table as every tube port but the feed, replacing the named
  `sparge_support_functions` list, and every tube port is bored for the riser. The risers are
  188.174 mm, five from the 1 m stock with 59.13 mm spare. The dosing lines now slide over the
  riser stub, 1 mm of interference over 14.9375 mm, instead of pushing into the bore, and the echo
  says so; `docs/build.md`, `docs/procurement.md` and `purchased-parts.csv` follow.
- The impeller's 4 x 4 mm tip ring is off by default (`impeller_tip_ring`), since it prints over
  open span and nothing structural needs it: dropping it removes 4328 mm³, a fifth of the impeller,
  and leaves the swept 94.5 mm diameter unchanged. `true` reproduces the old part.
  `docs/decisions.md` records the decision.
- `TODO.md` records that the probe collet's connector hex (8.6 mm across flats, 64.05 mm²) opens
  through the probe bore and is closed only by the probe body's grip, and that the fix is more
  likely a temporary seal than CAD.
- Ports take one interface across the lid where it can afford it: `head_ports_uniform()` asks
  whether every port fits on `std`, and `head_interface_for()` uses it where it does, falling back
  to the smallest interface that fits. Five of six registered vessels come out uniform;
  `jar_1p5L_109x215` keeps `mini`. `head_ports_for()` returns rows with the interface pinned in a
  fifth field. On `jar_10L` any port takes any function and the lid needs one face o-ring, the
  23 x 1.5 (12 instead of 7, the 13 x 1.5 leaving the reference build); the lid and the five tube
  ports change, and all twelve flange gaps are now 1.0466 mm.
- The recipes that were programs move out of the justfile into `scripts/` (`check-bom.sh`,
  `check-designations.sh`, `check-holes.sh`, `check-json.sh`, `check-mesh.sh`, `check-parts.sh`,
  `check-scad.sh`, `check-vessels.sh`, `check_customizer.py`, `export-parts.sh` and
  `gen-parameter-json.sh`) with the same output, and ruff lints `scripts/` as well as `analysis/`.
- **Breaking:** `scad/utils/gasket_load.scad` is replaced by `scad/utils/elastomer.scad`, holding
  the rubber pad relations (`elastomer_youngs_modulus()`, `elastomer_shape_factor()`,
  `elastomer_apparent_modulus()`) and the annular seat ones (`gasket_seat_area()`,
  `gasket_seat_stress()`, `gasket_seating_force()`), while `oring_gland.scad` keeps the groove
  geometry, gains `oring_rod_gland_squeeze()` and holds its width ratios as a `[cord, ratio]` table.
  `gasket_seating_turn()` and `head_lip_sink()` are removed. Every printed part renders identically.
- **Breaking:** The probe, baffle and thermocouple ports merge into `scad/custom/bayonet_port.scad`
  (`bayonet_probe_port.scad`, `bayonet_baffle_port.scad` and `bayonet_thermocouple_port.scad` are
  gone), whose preview renders all four variants. Every port tessellates by feature size from
  `scad/utils/facets.scad` (`facet_angle()` and `facet_size()`, replacing `head_fa()` and
  `head_fs()`) instead of each file's own `$fn`, which had built one part at three resolutions. 5 of
  19 parts retessellate, shifting by at most 0.0030 mm and 0.0129% in volume, and the parts total
  169234 triangles instead of 180068.
- **Breaking:** `scad/assembly.scad` is `scad/bioreactor.scad` (with `bioreactor.json` and the
  `tests/echo/bioreactor__*` transcripts), and the bottle holder, electronics stand and cart move
  to `scad/support/`, the cart as `equipment_cart.scad`.
- **Breaking:** The parameter-set files beside each entry file are written by hand instead of
  generated: one set per registered vessel, holding only what that build changes from the file's
  defaults. `just check-json` (`scripts/check-json.py`) checks without writing that every vessel
  has a set, that every parameter in a set is one the file offers and that every dropdown matches
  its registry, where it used to regenerate the files and overwrite a set saved from the
  Customizer. `just json` is removed, and `just json-prune` strips the restated defaults the
  Customizer writes on every save. Prettier no longer formats `scad/*.json`.
- **Breaking:** `bayonet_thermocouple_port()` requires its `thread` instead of defaulting to
  `npt_1_2`, and `bayonet_port.scad` reads the probe and NPT registries with `use` instead of
  `include`; `npt_thread_by_name()` looks a thread up by name.
- **Breaking:** `head()` and `frame()` take the registered vessel row as `vessel` and read its
  fields once, instead of the vessel's dimensions as separate arguments.
- Every echo is one line giving quantity, value, band and source, with no number added or changed;
  the numbers dropped are duplicates and unit conversions. Comments in `scad/` say what a number is
  and why (4,858 comment lines to 2,490), every Customizer parameter shows a whole description
  line, the `justfile` goes from 343 to 188 lines, and `TODO.md` is cut to what is open (633 to
  278 lines). The inline "Superseded" blocks in the docs are folded into `docs/decisions.md`.
- npm and uv cache into `.cache/` in the repository, so `just check` runs the same with a read-only
  home directory, and prettier and markdownlint run over the tracked files of their types instead
  of the whole tree.
- `docs/agitation.md` section 6 states the design basis as it stands instead of a chronological
  log: one bullet per fact for the sparger, impeller and baffles, with the figures `head()`
  reports for `jar_10L` and the source of each. What the log recorded and the model has since
  moved becomes three Corrections in `docs/decisions.md`, and splitting the baffle plate for
  printing moves to `docs/build.md`.
- The peristaltic pump frame mount's insert has half-round ribs down its side faces that press it
  into the light pocket, sized from the light row and the frame's pocket allowance.
- The gas line prices the way out, the vent slot and tube and the outlet filter once one is set,
  so the pump's ceiling on `jar_10L` is 5.97 L/min instead of 6.05 and the outlet budget 1.88 kPa
  per L/min instead of 1.93; a negative budget says no filter fits instead of quoting one. The
  envelope height follows the drive.
- `just export-parts` renders the parts in parallel (`JOBS`, every core by default) and then judges
  each in manifest order: the magnetic build exports in 2:26 instead of 8:00 on 12 cores.
- The pump frame mount's insert hangs below its flange and drops into an empty light pocket from
  above, with a half-round detent (0.4 mm) across its outer face near the bottom to catch under
  the rib in place of the side ribs, and its flange is one ellipse hulled to the insert's
  footprint, so the bridge lands on the insert's back face. It takes plain numbers (14.1 x 7.6 mm
  insert, 48 mm screw separation) instead of reading the frame and registries.
- The jar pocket is `frame_jar_cut_diameter()`, which the bolt circle, outer diameter and `frame()`
  build on, and `base_jar_fit_allow` is 0.6 mm instead of 0.4, since the printed top base came out
  tight on the jar. Every ring, the bolt circle and the lid's joint move 0.2 mm with it.
- Every sparger socket is bored 0.2 mm over the riser, a slip fit, with the tube 6.4 mm across
  flats. The arm's socket is 12 mm deep in a round boss, and the ring's M4x6 316 plug screw
  self-taps into a pilot through it and bites the tube by 3 mm; the ring rests on its tubes.
- **Breaking:** The impeller bore is straight at 8.4 mm, so an impeller slides to its height and
  the set screws are the whole joint: `impeller_shaft_draft` (diametral, 0) replaces
  `impeller_shaft_radius_interference` (0.2 mm on the radius), which tapered the bore to a driven
  fit at its narrow end. `head()` reports the slack (0.4 to 0.405 mm over the 7.995-8 mm shaft) and
  asserts the bore cannot close on the shaft; `docs/build.md` gives the fit.
- The fan is bolted into its carrier with its own screws down through its corner holes into nuts
  under the carrier (4 x M4 x 35 mm on `jar_10L`), solid under the fan, where it was self-tapped
  into a lip over a hollow skirt. The fan is turned 45° to put a flat on the slot, and its lead
  leaves by an 8 mm notch (`carrier_lead_width`) that splits the ear in two legs, past a pocket
  wall relieved above a 3 mm seat (`carrier_fan_seat`). `carrier_lip` is 6 mm instead of 2 to
  reserve the nut, `carrier_fan_recess` (0) can sink the fan under the rim, and `fan_for()` also
  wants a hub wide enough to carry the magnets, warning when a jar cannot take a usable fan.
  `jar_1p5L_109x215` loses its carrier: no registered fan clears its 57.82 mm pocket in the
  7.75 mm left, as `TODO.md` records.
- The fan joint's nut trap is a hex pocket cut to the larger of a nut and a cap head of the same
  size (7.21 mm across flats by 4.2 mm deep on M4), so the joint can run head down off the same
  print; `carrier_fastener_allow` replaces `carrier_nut_trap_allow`. A new echo reports the
  head-down build: an M4 x 35 leaves 0.39 mm to the glass on `jar_10L` and is 0.59 mm into it on
  `jar_1gal_180x197`.
- The base floor is sunk for the fan: `frame_base_floor()` takes the deeper of what the light stack
  leaves (`frame_light_floor()`, formerly `frame_floor_depth()`) and what a magnetic drive wants,
  whatever drive the build names, so the base stays one print. `carrier_floor_lift_max` (10 mm)
  caps what the drive may add, and `jar_6p5gal_305x470` and `jar_1gal_155x251` are held there with
  a warning naming the floor each would need. `fan_for()` sorts on the hub and takes an optional
  depth. `jar_1p5L_109x215` gets a carrier on a floor 3.78 mm deeper and a `jar_1p5L_magnetic`
  parameter set.
- The gasket cutter base has a second ring of clamp slots at r 61 mm
  (`gasket_cutter_clamp_inner_radius`, 3 mm travel), in the 17.6 mm gap between the small jars'
  cuts (r 43.75 to 51.9) and the large jars' (r 69.5 to 82.5). A gasket whose blank clears it
  clamps there, so `jar_1p5L`'s inner plate is 146 mm instead of 208, while the large jars keep the
  outer ring. Both rings are asserted clear of the cut being built.
- The docs describe the sterilisation as it is done: 7.5 % hydrogen peroxide for everything but the
  pH and DO probes, which are cleaned by hand, and bleach or chlorite only on the glass vessel. The
  bearing note keeps its caution against oxidisers, keeps the bearing out of the vessel's bleach
  step, and records that how 440C and Buna-N stand repeated peroxide is not known.
- The condenser coil is wound on a printed mandrel (`part = "mandrel"`) and unscrewed off, and each
  end is formed round a printed puck (`part = "puck"`) at a 9.5 mm bend, about twice the tube's
  diameter, turning inward and then up so both finish vertical and parallel. The head is a solid
  former the coil slides onto, with a groove for the bottom end, and takes no bending load; the coil
  has 12 turns instead of 11.5, and `part = "coil"` draws the formed tube alone. The first head
  asked for bends no tube can make, and cracked at its window's corner.
- The condenser coil is wound on the former it stays on, chucked by a stub, with ridges between the
  turns holding the pitch; the mandrel is gone, since a coil whose bottom end runs back up its own
  middle cannot come off one. The head is split into a `former` and a `panel` lowered onto the two
  vertical ends, so the o-ring glands stay whole bores; an M3 x 14 cap head goes radially through
  the panel's coupling into the former's spigot. The ends are formed on `puck_bottom` and
  `puck_top` and laid into channels open to the outside. A ridge now seats a turn at its own height
  in a 6.23 mm channel, where its chamfer left 8.04 mm for the 4.76 mm tube; the puck's V groove
  opens outward, 7.74 mm at the mouth instead of 2.19; the top end bends at 11.25 mm
  (`condenser_coil_top_bend_radius`) to land at r 13.31 instead of 10.17; and an assert holds the
  end's lead-in under the lip that keeps the o-ring in its gland. `docs/build.md` gives the order
  this takes (bend the bottom end while the tube is straight, lay it in from the side, wind, bend
  the top end in open air, lower the panel on), and `docs/design-conventions.md` says a part a tube
  is formed against has to be built to carry it.
- `just check-mesh` skips `condenser_coil.scad`, whose preview stands the coil on the former it is
  wound on, so the two touch; its parts build from `part =`.
- `din168-thread-scad` is pinned at `2b60fdd`, which cuts the thread to DIN 168-1:1998-04 (crests
  rounded to R1, roots to R2) and no longer fills the cap's groove root with a cylinder faceted
  0.13 mm off on GL45. The GL45 cap's diameters are unchanged; its mesh goes from 17852 to 36122
  triangles, still manifold.
- A magnetic build with no fan that clears its pocket is an assert instead of a warning, and baffle
  loading and resonance are reported under the shaft drive only.
- `check-echo`, `check-builds`, `check-designations` and `check-scad` render their cases in
  parallel (`JOBS`, every core unless set) and then judge them in the same order, with the same
  output; a case that never rendered fails. On 12 cores the four go from 479 s to 107 s.
- The six-port lid alternates tubes and instruments: DO, air_out, temperature, air_in, pH, media.
  The sparge ring hangs from tubes at 60, 180 and 300 degrees instead of all at 60-180, and the
  thermocouple sits one port from DO; the set's floors (78.0 mm mixed, 87.6 mm uniform) are
  unchanged. `docs/ports-layout.md` records it.
- The base floor is at least 4 mm where the light stack left a bare 2 mm, so `jar_1gal_155x251`
  and `jar_6p5gal_305x470` are each 2 mm taller and their risers 2 mm shorter.
- `frame.scad` previews the drive named by its own `drive_name` (shaft by default), where it
  always previewed the shaft drive.
- The probe collet's flex tab ends its slots in 1 mm relief holes
  (`probe_port_collet_tab_relief`), costing about 0.25 mm of the tab root each side, and its window
  is cut with 2 mm rounded top corners (`probe_port_collet_window_radius`), with an assert refusing
  a radius the window cannot take. Both pass through `bayonet_probe_port()`.
- `TODO.md` is brought up to date with the model: stale figures corrected, the sparge socket and
  eccentricity items removed, and the airlift, draft tube and magnetic items extended.
- **Breaking:** The humidifier cap follows `din168-thread-scad` `f544e68`: `gl_port_cap` puts
  z = 0 at the seal plane, where the bottle's rim meets the top's underside, instead of at the
  mouth, so its ports sit at `z = panel_thickness`, and `gl_port_cap_top_z` is removed. A `skirt`
  argument adds plain wall below the thread, one pitch on the drawn cap. The drawn cap spans
  z = -18 to +10, so an exported STL no longer starts at z = 0.
- `docs/build.md` and `magnet_hub_cap.scad` say the hub cap can be stuck to the fan's hub with
  double-sided foam tape as well as glued.
- The magnet hub cap grows a solid floor up into the punt's void where the carrier cannot rise,
  until the magnets reach their 1 mm clearance or the cap's rim reaches its own: on `jar_10L` the
  cap is 8.39 mm tall instead of 6 and the magnets sit 1.24 mm under the punt instead of 3.64.
  Other registered jars are unchanged.
- The `jar_10L` builds carry the lights the built reactor has: `grow 13in`, four in each lit
  quadrant, 8 tubes on 2 cords, and `purchased-parts.csv`'s light row follows. The base and rib
  pockets move, and on the magnetic build the fan turns 55° instead of 45° to follow a middle
  light's cord notch.
- **Breaking:** `gl_port_cap` takes `din168-thread-scad`'s default thread length, five pitches,
  instead of its own 12 mm, after `openscad-libraries.txt` pins `7ea65c3`: the GL45 humidifier
  cap is threaded 20 mm and stands 32 mm (z = -22 to 10). `skirt` is replaced by `ring_band` (mm,
  default 0), a band at the mouth that clears a pouring ring.
- Each rib arc ends in a round end centred on its rod (9.2 mm radius, 4.6 mm of wall round the
  hole) instead of a 37 mm boss centred on the jar's inner edge, which reached 18.5 mm past the rod
  across the next quadrant's light pocket on the smaller jars. Every rib is a reprint.
- **Breaking:** The dosing ports are numbered instead of named: `media`, `acid` and `base` are
  `dose_1` to `dose_3` on the twelve-port lid and `dose_1` on the six-port one, engraved `DOSE 1`
  to `DOSE 3`, and `dosing_pump_functions` lists them. The dosing pump now feeds every dose port,
  three on the twelve-port lids and one on the six-port, where the line read "1 risers".
- The twelve-port lid carries three baffles, at 30°, 150° and 270°, giving the fourth baffle's
  port to `dose_4` at 330° for a sampling line; pH moves from 150° to 120°. The baffles are now
  0.433 of Oldshue's reference projected area on `jar_10L` (was 0.577) and 0.516 on `jar_1gal_180`
  (was 0.688), which `head()` warns of; each plate takes a third of the torque (1.03 N, 2.44 mm at
  the tip on `jar_10L`), and the sparge ring hangs from six tubes rather than five. The docs and
  the draw.io sketch follow.
- The sparge ring's bound on baffle width applies only where the ring is built; a baffled lid with
  the ring or no drive still stops at 10.3454 mm. Under the arm the impeller sets the width, and
  `baffle_impeller_clearance` is a running clearance, 1 mm to the blades after the worst-case lean
  the coupling allows (was 2 mm nominal), computed once by `head_baffle_lean()`. Magnetic builds
  keep the shaft build's plates. `jar_10L`'s plates go from 10.3454 to 11.9456 mm (0.433 to 0.499
  of the reference area) and `jar_1gal_180`'s to 17.0892 mm (0.847), the widest the port's lock
  bore passes.
- The turbidity sampler is easier to assemble: the clear tube drops in from above, snug only
  between the heads and opening at 45° above them, with its top placed by the barb's stretched
  end; it runs 16 mm over the riser instead of 6, its seat going from z 11.5 to 1.5, cut 44.6 mm,
  with asserts on the pin's core and the riser's o-ring gland; and four M3 x 10 socket head screws
  stand up out of counterbores under the face for the actuator to drop onto, nutted from inside.
  The face rises 10.8 mm, to 97.6 mm over the lid. `openscad-libraries.txt` pins turbidity-sensor
  `0fb80f9`, which puts the optical axis 10.8 mm from the arms' root instead of 11.4, so the
  clear tube moves 0.6 mm toward the connector. `purchased-parts.csv` adds the clear FEP tube, a
  luer-to-barb fitting and the silicone sleeve, and `check-sampler` grows to ten fits.
- **Breaking:** The reference build runs two six-blade Rushton turbines at the standard turbine of
  McCabe, Smith & Harriott 1993: D = T/3, the lower T/3 off the floor, the upper a further T/3 up,
  blades D/5 by D/4 on a 3D/4 disc, in place of two pitched blades. `head_impeller_type` is
  replaced by `head_impeller_lower_type` and `head_impeller_upper_type`; each impeller row carries
  its standard tank layout, and `impeller_bore_ratio`, `impeller_clearance_factor` and
  `impeller_spacing_factor` are undef until set, a number being echoed as a departure. The Rushton
  prints as two halves split at the disc, pinned on 1.75 mm filament, two M4x6 set screws per half
  (`impeller_to_render` gains `lower_half` and `upper_half`). On `jar_10L` at 320 rpm: 70 mm
  impellers, 1.06 W per impeller, 0.5 vvm held down to 242 rpm. `docs/baseline.md` is new, and
  `docs/decisions.md` corrects two claims made for the pitched pair.
- `docs/agitation.md`, `docs/ports-layout.md` and `TODO.md` note that culture photos show buildup
  high in the culture, the headspace and the lid, not on the sparger and probes.
- **Breaking:** The sparge arm is named `arm`: `head_sparger` and `sparger_name` take `ring`, `arm`
  or `loop`, a set naming `cap` stops on an assert, and the print is `sparge_arm` instead of
  `sparge_cap`. The riser socket's dimensions are functions in `sparger.scad`
  (`sparger_riser()`, `sparger_socket_depth()` and others) that `head.scad` and the sparge puck
  read, `sparger.scad` previews the ring, arm and loop side by side, and the ring's lone-riser
  warning uses the loop's lever stiffness.
- An airlift takes the ring, which centres its draft tube: `head()` refuses the arm or the loop
  on an airlift.
- The sparger's feed socket seals the riser under its set screw: the screw moves up to 2 mm under
  the mouth and an enclosed groove for the lid port's 4x1.5 EPDM ring sits 6.3 to 8.55 mm down, on
  the ring, the arm and the loop, with the ring's feed socket taking the arm's boss.
  `sparger_socket_gland()` asserts the groove's wall, and `head()` echoes where it is.
- The ring and the loop drill 16 x 1 mm holes instead of 8 x 3 mm, for bubbles of 3.53 mm at
  formation instead of 5.10; the arm fits 10 on `jar_10L` at 8.67 m/s and warns. Capillary
  pressure rises from 96 to 288 Pa, and the bore is no longer a departure.
- `jar_10L_220x305` runs the loop sparger; `auto` stays the arm on every other stirred build.
  Under the cage the loop is 76.54 mm, set by its own hook, with 16 holes at 5.42 m/s.
- `head()` places the turbidity sampler on the twelve-port lid as a `sampler` port at 300°, port
  10, in `dose_3`'s place, since at 330° it ran into the coil condenser; the dosing ports keep
  their numbers 1, 2 and 4, and dosing goes from 4 risers to 3. The port's riser is the dip tube,
  its cut and drilling derived (on `jar_10L` 217.036 mm, drilled 125.997 mm from its top end,
  40 mm under the surface), and `sampler_base` and `sampler_top` join the print list.
- `docs/decisions.md`, `docs/agitation.md`, `docs/references.md`, `docs/design-conventions.md`
  and `TODO.md` record the wall cage's design history and turning load (63 N·mm on the riser at
  320 rpm), the baffle insert prior art, and open items, and `baffle_cage.scad` notes what a blade
  shares with its hoops.
- The sampler's clear tube is McMaster-Carr 9369T961 in `purchased-parts.csv`, confirmed against
  its order.
- `baffle_name = "auto"` takes the wall cage on every stirred build it fits
  (`head_wall_cage_fits()`): a shaft or magnetic drive, not the ring, a lid with baffle ports, and
  at least `baffle_cage_travel_min()` (10.4 mm) of blade travel; the lid plates elsewhere. Both
  `jar_10L` builds now carry the cage, `jar_10L_magnetic` gaining it. `head()` refuses the cage on
  the 1 gal jars, whose blades slide 8.24 mm, and allows it on the magnetic drive, measuring from
  the stir bar's sweep.
- The sampler `use`s the heat-set insert registry and picks its two inserts by name through the
  new `heat_set_insert_by_name()`, instead of including the registry; its renders are unchanged.
- Registry lookups check each field's type as well as the row's length: each registry passes a
  signature, one letter a field (`s`, `n`, `l`, `b`, capitalised where undef is allowed), and a
  row with a list where a number goes fails with `registry rows [...] do not fit ...`.
  `fan_by_name` is checked too, through the new `registry_checked()`. A bare count still checks the
  length alone.
- `docs/decisions.md` settles `bayonet_port.scad` receiving every o-ring as a global, and
  `docs/future-work.md` takes splitting `head()` by subsystem and passing the sampler its inserts.
- The e-stop is the one in use, a RuoFeng 22 mm latching mushroom, 1 NO + 1 NC, 10 A at 660 V
  (`B07HBN45Q9`, 11.88 CAD for 2), in place of an unspecified two-channel switch, since the loop it
  breaks is a single one. `docs/build.md` records the wall cage's bench result: both hoops at
  0.10 mm, the bars at 0.15, 10 min at 320 rpm with no blade creeping, and the bottom bars in a
  hand's reach 240 mm down.
- The Kamoer dosing pump is drawn as its head, from a new `head` field on its registry row that
  marks each figure measured or estimated: the 54.6 x 40.5 x 3 faceplate with holes 48 apart, the
  cassette behind a Ø34 cover 20 mm deep, the tube block with two barbs 18 apart, and the latches,
  61 mm long in all, in place of the catalogue's 55 x 41 box.
- bayonet-lock-scad is pinned to its `v0.12.0` tag instead of commit `95953cc`; it adds checks on
  `sweep_angle` and the channel's depth, and no geometry or echo transcript changes.
- **Breaking:** `purchased-parts.csv` is reshaped so it sums: `scope` (reactor, sampler, bench,
  tooling), `qty` as a whole number of purchase units, `unit`, `need`, `price`, `currency`,
  `price_confidence` and `price_date`, defined in `docs/procurement.md`. Prices were re-read on
  2026-11-01 (pH probe 99.99 USD, DO probe 249.99 USD, air pump 99.28 CAD), fasteners and tubing
  specified by standard are priced at one McMaster number (`representative`), the Slice boards
  take Hafting et al. 2023's figures (RLHT 68.26, DCMT 84.55 CAD), and EZO-pH (45.99 USD) and
  EZO-DO (53.99 USD) are new rows.
- The docs cut history and duplicated arguments, keeping each argument in one place with a link
  from the others, and are written in plain ASCII (x, deg, dia; `Ø` stays only in engraved
  marks). The README indexes every docs page and gains "What you need" and "Build it" sections,
  `procurement.md` takes one section per part, and the 36PG ratio tables move to a comment in
  `scad/purchased/gearboxes.scad`.
- Commissioning moves from `docs/build.md` to `docs/commissioning.md`, the sparge puck bench
  protocol to `analysis/methods/sparge-test-pucks/README.md`, the eccentricity analysis from
  `references.md` to an "Eccentric mounting" subsection of `agitation.md`, and `decisions.md`,
  `future-work.md` and `architecture.md` from `docs/` to `dev/`, which the README lists under "For
  contributors".
- **Breaking:** The OpenSCAD libraries are installed by scadman: `scadman.toml` declares the
  seven libraries at the same pins, as full SHAs, and `scadman.lock` records each commit and a
  content hash, replacing `openscad-libraries.txt`. `just setup` fetches scadman v0.1.0-alpha.6
  into `.cache/scadman/` (checked against its sha256) on Linux x86_64 and macOS, or uses one on
  `PATH`, and the libraries land in `.scadman/env/`, the justfile's new `OPENSCADPATH`. The README
  keeps a table of the libraries and pins for installing without scadman.
- CI renders with a pinned OpenSCAD 2026.10.15 snapshot instead of apt's 2021.01, so
  `check-clash` and `check-baffle-cage` run there; `check-mesh` and the export judge pass
  `--backend=CGAL` wherever the binary offers a backend, since only CGAL prints the
  2-manifold warning they fail on. `test` runs on a pull request only when `scad/`, `scripts/`,
  `tests/`, the justfile, the scadman pins or the workflow change. `just test` on CI goes from
  1605 s to 602 s.
- The README's first line says what the project is: a parametric OpenSCAD bioreactor on glass jars
  from 1.5 L to 6.5 gal, stirred by a shaft or magnetic drive or run as an airlift.
- The export workflow installs the same pinned OpenSCAD 2026.10.15 snapshot as the checks, so the
  published STLs come from the renderer the checks passed on, not apt's.
- din168-thread-scad is pinned to its `v0.1.0` tag instead of commit `7ea65c3`; `din168.scad` is
  the same file at both, so the GL45 cap does not change.
- The sampler's dip tube ends open at half the culture's depth, cut to length, instead of drawing
  through a hole drilled 40 mm under the surface while its open bottom end, run on to the ring's
  socket depth, drew too. The `sampler:` echo gives the cut: 200.748 mm on the `jar_10L` builds,
  was 217.036, ending 114.752 mm under the surface, and 133.821 mm on the 1 gal builds, was
  129.036. The head draws the dip tube with the other steel tubes under `render_sparge_tubes` or
  `render_all`, and the `jar_10L` tube cut list goes from 1046.2 to 1029.9 mm.
- syringe-actuator is pinned to its `v0.1.0` tag, and the sampler reads its `5ml-gnr2` syringe
  layout instead of `5ml`, which brings the actuator's face down from 97.6063 to 83.7813 mm over
  the lid. A 3.287 mm groove runs down `sampler_top`'s side under each face screw so a 2.5 mm hex
  key still reaches the screws from below, with an assert keeping `min_wall` beside the board's
  pocket; `sampler_top` goes from 47131.121 to 45297.451 mm3, and no other print changes.
- **Breaking:** The bayonet ports, their interface records, the flex collet, the o-ring and Atlas
  probe registries, the o-ring gland, NPT threads, dovetail and trapezium come from the
  bayonet-port-scad library, pinned at `v0.1.0`; the 11 files that held them
  (`bayonet_port.scad`, `bayonet_interfaces.scad`, `cylindrical_flex_collet.scad`, `oring.scad`,
  `orings.scad`, `atlas_probe.scad`, `atlas_probes.scad`, `oring_gland.scad`, `npt_threads.scad`,
  `dovetail.scad` and `trapezium.scad`) are gone, and the includes name the library's paths.
  bayonet-lock-scad leaves `scadman.toml`, coming in through bayonet-port-scad at the same
  revision. Every print part of `jar_10L_220x305` exports as the same mesh, and the echo
  transcripts are unchanged.
- `just setup` installs scadman v0.1.0-alpha.9 instead of alpha.6, the first that resolves a
  dependency's own `scadman.toml`.
- **Breaking:** The sampler's housing, fits and bought parts come from turbidity-sensor's
  `hardware/sampler/sampler.scad`, pinned to its `v0.1.0` tag instead of `4be431f`;
  `scad/custom/sampler.scad` is an adapter that sets the housing's foot from the port library and
  defines `sampler_pin`, `sampler_placed`, `sampler_print` and `sampler_panel` for `head.scad`.
  syringe-actuator is no longer pinned directly, coming in through turbidity-sensor, and
  `sampler_actuator.scad`, `tests/sampler/fit.scad` and `just check-sampler` move to
  turbidity-sensor. The sampler's base and top export byte-identical.
- The README opens by saying this repository is the reference build, the jar reactor the paper
  describes, with the parts another reactor needs in the tagged libraries it pins and the acrylic
  column reactor in column-bioreactor; its library table lists the eight packages `scadman.lock`
  installs, each at its pin, and which library pins each.

### Fixed

- `render_all` did not render the probes; it now does.
- `scad/motor_mount.scad` no longer `use`s itself.
- The probe port's taper between the bayonet and the collet was the tail length plus 5 mm long; it
  is now `transition_length` (25 mm) plus the probe body diameter over √3, and the collet is cut
  off where it would rise past the taper.
- In `scad/assembly.scad`, `do_probe_orient_base` showed in the Customizer's temperature probe
  section; it is in the DO probe section.
- `atlas_probe.scad` loaded `lib/trapezium.scad`, which does not exist in `scad-v2/`; it loads
  `../utils/trapezium.scad`.
- `scad-v2/utils/circular_patterm.scad` is named `circular_pattern.scad`.
- The frame's base wall thickness, three times the light depth, was undefined once the light
  dimensions moved to `strip_lights.scad`; the frame includes that file and takes the depth of the
  `generic` light.
- `bayonet_port()` filled the middle of lock parts as well as pins; it now fills the core, or the
  centre bore tube, only on pins.
- The probe and thermocouple ports still called `bayonet_port()` with `inner_radius`,
  `oring_height` and the other old arguments, so the interface and neck radius arrived undefined
  and neither port built. They take `interface_radius`, `neck_radius`, `oring_cs_diameter`,
  `oring_interference` and `allowance` (0.2 mm), and opened on their own render a 9.5 mm
  interface with a 15 mm neck.
- `bayonet_port()` had lost `shell_thickness`, leaving the shell at twice the pin radius, and no
  longer cut the O-ring groove. It takes `shell_thickness` again and cuts the groove into the neck
  face, `oring_cs_diameter` less `oring_interference` (new, 0.1 mm, asserted smaller) deep.
- The head's bayonet lock loop ran from 0 to 360° inclusive and drew one lock twice.
- The bayonet ports did not seat in the lid: the pin half was 15 mm tall against an 18 mm lid with
  no shank, so it could not reach its lock; the lock sat inside the lid with 0.7 mm of radial
  interference; and the flipped pin put its pins 60° out of phase with the lock's channels. The
  lid holes, sized as the interface radius plus 1.5 pin radii, were smaller than the lock. The
  head now places each half at its hole centre with no flip, the pin passing through the lid and
  the lock bearing on its underside. The thermocouple mount's base is now the flange diameter less
  the allowance instead of the lock's outer diameter.
- `peri_pumps.scad` listed a commented-out `generic` pump, so the registry was `[undef]` and
  OpenSCAD warned on every load. It registers `generic_peri_pump`: a 50 mm carrier with a 4 mm
  base, three 20 x 10 x 20 mm rollers at a -1.5 mm offset, a 28 mm cassette with 3 mm walls, a
  3 mm tube and a 4 mm shaft bore.
- The centre bore was capped by the port flange, so the tube and thermocouple ports had no
  through-hole while their flanges were labelled with one; the bore now opens through the flange.
- The frame drew its strip lights even with every render flag off, because `render_lights` was
  never read; the lights now render only under `render_lights` or `render_all`.
- `cylindrical_flex_collet.scad` opened on its own did not pass its `part_end_fn` setting; it
  does now.
- Including `atlas_probes.scad` or `thermocouple_probes.scad` drew example probes into the file
  that included them; their example calls are commented out like the other registries'.
- **Breaking:** The bench motor and its gearbox were registered as 36PG with the letters
  transposed; they are `motor_36gp_3530_5p18` (`36GP-3530-5.18`) and `gearbox_36gp_5p18`
  (`36GP-5.18`), matching `docs/procurement.md`.
- Every registered vessel rendered off its registered height, by half the neck corner radius less
  the wall and rim radius (6.5 gal jar +4.95 mm, 1.5 L canister -2.32 mm); all six now render at
  their registered height, diameter and bore.
- The gearboxes' input bores were registered as 22 x 3 mm; they are 2 x 8 mm, matching the motor
  shaft, and `motor_36pg_3429_5p2` has the 2 x 8 mm shaft and 8 x 3 mm boss of the 36GP motor.
- The O-ring rebate on a bayonet port left a 1.2 mm land on `bayonet_std`, narrower than the
  1.6 mm O-ring; it runs from the interface radius less the allowance, a 3.6 mm land.
- The thermocouple port's NPT mount started at the flange diameter less the allowance, which left a
  false lip at the transition; it starts at the full flange diameter.
- `atlas_probes.scad` again drew the lab pH and DO probes at the origin of every file that
  included it, `head.scad` and `bayonet_probe_port.scad` among them; its example calls are
  commented out, with a note saying why they must stay so.
- The lid's port ring sat at a quarter of the vessel's outer diameter whatever the opening the
  plug fills; it now sits as far out as leaves `lid_holes_offset` (2.0 mm) between each bore and
  the plug's edge, and the head asserts the bores keep that much between neighbours.
- A lid rendered on its own exported as twelve plain holes, with the bayonet locks a separate
  part; the locks are unioned into the lid, and `render_bayonet_lock` shows them alone only when
  the lid is not rendered.
- **Breaking:** The bayonet coupling mated in three indistinguishable seatings 120° apart, so a
  baffle plate or a tilted probe collet could lock pointing the wrong way. `bayonet_std` registers
  a 25° key that offsets the second pin, so a wrong seating jams; `bayonet_key_angle()`,
  `bayonet_pin_angles()`, `bayonet_seating_count()` and `bayonet_is_keyed()` read it, the port
  asserts the key clears the channel mouths, and the head asserts the interface is keyed when a
  baffle or probe port is fitted. Needs bayonet-lock-scad 0.11.0 or later, and lids and ports
  printed before this do not mate with those printed after.
- **Breaking:** The port flange never seated on the panel: its O-ring rebate ran out to the flange
  edge, giving 6% squeeze and 37% gland fill on the 1.6 mm cord. The flange now cuts only a groove
  (0.75 x and 1.5 x the cord, deep and wide), leaving lands either side that bear on the panel. The
  interface row carries the ring, `[oring_id, oring_cs]`, and a `flange_lip` instead of
  `flange_r` and `oring_intf`, and the flange radius is derived from the groove. `bayonet_std`
  takes the 23 x 1.5 mm EPDM ring, McMaster-Carr 8785N383, added to `purchased-parts.csv`; the
  port asserts the groove stands outboard of the lock's bore and fills under 90%, and the head's
  port spacing assert measures the flanges (2.25 mm apart) instead of the bores.
- **Breaking:** The joint spans ignored the gap between the lid and the top base: the bolts were
  sized for an 18 mm grip (M8x25) against a 20.4 mm span, and the 12 nuts above the lid sat off the
  top base instead of the rim. The bolts are now M8x30 and the nuts 2.4 mm higher. `frame()` no
  longer takes `rod_length`; it derives 322 mm as the vessel, flange and nut heights plus 2.5 mm
  of thread (`rod_thread_proud`).
- The bearing pocket was 22.8 x 7.5 mm round a 22 x 7 mm bearing, with an allowance on top of
  dimensions that already had one. The head cuts it from NopSCADlib's `BB608` (`shaft_bearing`,
  the 6153K71) plus `bearing_hole_allowance`, 22.2 x 7.0 mm; `bearing_diameter` and
  `bearing_height` are removed.
- A baffle plate too thick for the bore failed with a message about the jar's neck;
  `bayonet_baffle_width()` itself now asserts the plate passes the bore. Two asserts that could
  never fire, the port gland fill and the vessel's opening against its neck, are removed.
- Changing `threaded_rod_diameter` left M8 nuts drawn and pocketed on the rod; the frame reads one
  `rod_nut` and asserts it matches the rod.
- `frame.scad` drew two rib levels whatever `n_rib_levels` said; the rib and spacer loops follow
  it.
- **Breaking:** Selecting another `reactor_lights` resized the frame but kept pockets for the
  frame's own `frame_light`. `frame()` takes `light` instead of `lights_length` and cuts every
  pocket, cord slot and wall check from it; `frame_light` is removed.
- The shaft coupling was drawn 12.5 mm across, NopSCADlib's 5-to-8 coupling, instead of the 14 mm
  uxcell 8-to-8 bought. It is registered as `shaft_coupler_8x8_rigid` (25 x 14 mm) in
  `scad/purchased/shaft_couplings.scad`, selected by `shaft_coupler`, and the head asserts its
  bores match the gearbox output shaft and the impeller shaft.
- **Breaking:** The lid flange was 0.4 mm narrower than the frame it lands on, since it ignored
  `base_jar_fit_allow`. `frame.scad` exports `frame_outer_diameter()` and `head()` takes
  `joint_outer_diameter` instead of `frame_wall_thickness`.
- `head.scad` and `frame.scad` opened on their own previewed against numbers copied from the
  assembly (bolt circle, bore, flange, jar size), so a lid exported from `head.scad` with other
  allowances would not fit the frame. Both derive them, `head.scad` through `use <frame.scad>`
  and `frame.scad` from the registered jar.
- The cart was sized for the 220 mm jar and a 450 mm height rather than the assembled reactor, so
  units overlapped by 17.4 mm, the side clearance was 1.3 mm instead of 20 mm, and each unit passed
  63.75 mm through the rail above. `cart.scad` reads the envelope from `assembly.scad`
  (`reactor_envelope_diameter()` and `reactor_envelope_height()`, 257.4 x 543.75 mm, built on the
  new `frame_floor_depth()` and `head_stack_height()`), and the cart grows from 560 x 320 to
  634.8 x 357.4 mm and from 1125 to 1312.5 mm tall with castors.
- The 36PG gearboxes' output boss was registered 3 mm long, carried over from the 36GP; it is
  2 mm, from the E-S outline drawings.
- `docs/agitation.md`'s mean-dissipation column was computed on 10 L instead of the 8.17 L culture
  volume `head()` uses; the table is regenerated from the model.
- `docs/references.md` credited the standard tank configuration to Guo, Langrish and Fletcher
  (2003); the paper is by Zhou, Shi and Yu. The claim itself stands.
- The Davis thesis reference is identified: Ryan Z. Davis, "Design and Scale-Up of Production
  Scale Stirred Tank Fermentors", MS thesis, Utah State University, 2010 (was D.A. Davis, 2009),
  and the entry records that Davis relays its numbers from other sources.
- Three claims in the references were wrong once the sources were read: Barbosa 2003 does not
  establish a critical gas entrance velocity, so the 30-50 m/s figure is removed from
  `docs/agitation.md` and `TODO.md`; Davis's spacing figures do not come from the Xing et al. 2009
  paper he cites; and blade twist is characterised after all (Patwardhan 1999, Kumaresan 2006),
  putting this blade at 30° of twist, 83° at the hub to 53° at the tip, so the borrowed Po 0.99 is
  likely an over-estimate.
- Oldshue's handbook, the source behind Davis's figures, gives no impeller spacing rule, no 80%
  power penalty and no top-impeller submergence; its 1-2 diameters are an off-bottom clearance for
  fluidfoils, and its baffle width is T/12. The Davis entry is marked unreliable for numbers, and
  `docs/agitation.md` records what Oldshue does give: three baffles are acceptable at the same total
  projected area as four, and a sparge ring about 80% of the impeller diameter (75.6 mm here).
- Oldshue's handbook is dated 1997, from its copyright page, instead of 1996, with its ISBN and
  place.
- The drivetrain was drawn 8 mm higher than reported, because the shaft, drive stack and baffle
  limit measured from the rim instead of the lid's outer face: the shaft sat 13 mm over the punt
  instead of 5 mm and the impeller 48 mm off the floor instead of 40. `head_punt_top_depth()`
  states the datum, and the motor mount drops from 130 to 122 mm and the envelope from 579.25 to
  571.25 mm.
- The baffle area ratio compared plate width only, reporting 0.83; it now counts the submerged
  length of each plate against Oldshue's area over the liquid depth, giving 0.18 at the 0.8 fill,
  and the warning names depth rather than count as the lever. `docs/agitation.md` no longer claims
  the three baffles are permissible by area.
- The set screw tap hole in the hub fouled a fin root and put the blade in front of the socket;
  the screws now thread into an 8 mm collar above the blades (`impeller_collar_height`), and
  `head()` asserts the collar fits between the impellers and leaves wall around its hole.
- The Rushton power-number reference names its authors, Kaiser, Werner, Jossen, Kraume and Eibl
  (2017), cited in the SCAD by its 2016 online date; Fořt is spelled correctly in the SCAD
  comments, and two `TODO.md` figures left from the clearance changes are corrected.
- Medek's departure check read the baffle positions before they were assigned, so it always
  reported the baffle count as a departure; with four baffles the pitched blade reads Po 1.602 and
  flow number 0.806, extrapolated on T/D and H/T only.
- `head()` echoed the sparge riser's slack through its port without checking it, so an 8 mm riser
  in the 6 mm bore built with -2 mm of slack; it now asserts the riser fits its port and that its
  bore is inside the tube.
- On a lid with no baffle ports, `head()` still reported a plate width and length, warned of zero
  area, and loaded the plates with the impeller's torque divided by zero (`inf N`); the baffle
  checks and reports now run only when a baffle is fitted, and the mouth window is bounded on one
  side.
- The thermocouple mount's thread tooth was a fixed 1.0 mm, taller than 1/8 NPT's 0.94 mm pitch,
  which crashed CGAL; it is 0.55 of the pitch.
- `docs/references.md` recorded Montante 2006 as using a pitched blade turbine and reporting mixing
  times comparable to a baffled vessel, both from search summaries. Read, it uses a Rushton turbine
  and reports no mixing times; what it measures is a centred unbaffled flow number of 0.25, 65%
  below baffled. Scargiali 2014 is read too: it recommends the pitched blade for shear-sensitive
  cells and puts unbaffled transfer level with sparged baffled reactors only above about 500 W/m3,
  against 209 W/m3 here at rated speed.
- `docs/ports-layout.md` put the full port set's smallest mouth at 130.4 mm and the reduced set's at
  81.6 mm, and valued spreading the big ports at 19.3 mm; four equally spaced baffles leave every
  port beside one, so the figures are 142.0 mm, 122.7 mm for a three-baffle set, and 77.6 mm, and
  `jar_6p5gal` (137 mm) no longer fits the full set.
- The thermocouple registry did not include the NPT thread table and the port never passed the
  thread to its mount, so the temperature port cut a 1/2 NPT mount, 25.3 mm across, on a 17.2 mm
  mini flange; it cuts 1/8 NPT.
- A missing comma in a `head.scad` assert message stopped `use <head.scad>` exporting any function,
  so `assembly.scad`'s gasket factor and joint bolt count went undef, and the keying assert's
  message read an empty list on every render. Both are fixed and every file renders without a
  warning.
- `set_screws.scad` named NopSCADlib grub screws without including their table, so every set screw
  row had an undef type; it includes NopSCADlib's screws.
- The lid is turned over after its bores are cut, so each bore landed on the port opposite its own:
  with mixed interfaces, `air_in` and `base` put mini locks in std bores, leaving a 4.9 mm gap
  through the lid, and two std locks sat in mini bores. `head_port_at()` takes `flipped` and cuts at
  the mirrored angle, which also drops the unstated need for an even port count.
- A pin half was drawn, and exported for printing, with its pins at the entry angle rather than
  where they sit once locked, so a printed baffle or tilted probe came out 30° off when locked in.
  `bayonet_port()` takes `pins_at_locked` (default true), which moves the pins back by the sweep so
  the body's own frame is its locked position; the lock half is unchanged.
  `bayonet_entry_rotation()` returned the turn instead of its undo and now has the opposite sign.
- The impeller's tip ring stood outboard of the blades, so the part swept 102.5 mm where the model
  said 94.5 mm, D/T was 0.488 against a reported 0.45, and the blades overlapped the baffles by
  1.98 mm. The ring sits inboard of the impeller radius, and the plate clears by 2.02 mm.
  `head_impeller_swept_radius()` gives what the impeller sweeps, `head_baffle_width()` sizes the
  plate from it, and `head()` warns when it differs from the nominal diameter. `head()` also
  reports the baffle's running clearance, less the lean the coupling's 0.2 mm of play allows at the
  lower impeller (2.28 mm against a 2 mm gap).
- The sparge ring's gas holes stopped at the nominal inner wall, short of the faceted wall, leaving
  a skin (0.020 mm at `$fn` 128, thicker than the 1.2 mm wall at `$fn` 12). The holes now reach by
  the facet's chord sagitta, and an assert keeps them from reaching the outer wall.
- The sparger tubes ended inside their port, measured to the lid's outer face, with nothing to
  push a hose over; they stand `sparge_riser_proud` (15 mm) above the port's top face.
- `purchased-parts.csv` had fallen behind the model: it listed the 9 in 3872K117 thermocouple that
  overshoots `jar_1gal_180x197`'s floor instead of the 6 in 1245N31 (USD 96.67), had no row for the
  mini ports' 13 x 1.5 mm o-ring (1289N323), and said 12 std port o-rings where 7 are needed. It
  adds them, two 4 x 2.5 mm 316 stainless tubes for the sparger, and `TODO` rows for the rotameter,
  metering valve and check valve.
- The baffle's tip deflection formula agreed only at zero freeboard and was 23% low at the plate's
  real 49 mm; rebuilt, `jar_10L`'s plate deflects 1.53 mm instead of 1.18 mm, on the tenth-of-width
  limit. `docs/agitation.md` and `TODO.md` record it.
- The pitched blade met the hub along a line of zero width, so every render reported a
  non-manifold solid; its inner corners now sit on the hub circle, burying the blade in the hub.
  The swept radius stays 47.25 mm.
- The impeller's axial span left out the blade's thickness (2.83 mm on the 4 mm blade at 45°), so
  every vertical budget was short by it: the room under the lower impeller is 76.95 mm instead of
  78.37 mm, the culture over the upper 53.35 mm instead of 54.77 mm, and the converging gap
  70.31 mm instead of 73.14 mm. `impeller_axial_span()` takes `thickness`; the hub's base is now
  flush with the blade's lowest corners, and the tip ring and set screw collar sit level with the
  blade top.
- The mouth fit still charged 8 mm for the tip ring after it moved inboard: `jar_6p5gal_305x470`'s
  D/T cap is 0.4879, not 0.4594, with 10.64 mm to pass its mouth instead of 2.64 mm. The check reads
  `head_impeller_swept_radius()` and moves into `head_mouth_is_feasible()`, so the reported mouth
  window counts it too.
- The baffle resonance warning could test the blade-passing frequency on a lid without baffles,
  since `&&` bound tighter than `||`; both arms now need baffles.
- The check valve row in `purchased-parts.csv` quoted Cole-Parmer's "Working Pressure 3-5 psi"
  without doubling the quotes, so CSV readers split it into 12 columns instead of 10.
- The sparge ring divided by `$fn` to size its gas holes, so on OpenSCAD builds that hand a `use`d
  module the caller's `$fn`, opening `assembly.scad` (which set none) divided by zero and fired the
  hole assert on a sound jar. The facet count is derived as OpenSCAD derives it, from `$fn` or from
  `$fa` and `$fs`; geometry is unchanged where `$fn` is set.
- `assembly.scad` set no `$fn`, unlike every other entry file, so on newer OpenSCAD builds the
  assembly was drawn to `$fa`/`$fs` instead of 64 in preview and 128 in a render; it now sets them.
- The probe ports leaned their collets 7° inward, toward the shaft, instead of outward: the pH
  probe's tip sat at radius 40.8 mm inside the impellers' 47.25 mm sweep. A positive tilt now leans
  outward, and the wedge under the collet is mirrored with it.
- **Breaking:** Leaned outward 7°, the pH probe ran 1.14 mm through the sparge ring and the collets
  past the jar's mouth. Only the DO probe leans now, by 4.5° (`do_probe_port_tilt_degrees`), and the
  pH probe hangs straight (`ph_probe_port_tilt_degrees` 0), replacing `probe_port_tilt_degrees`.
  `head()` asserts each probe's collet passes the jar's mouth as the lid goes in (0.32 mm to spare
  on `jar_10L`), and `just check-vessels` sweeps both leans flat. `docs/references.md` adds a probe
  mounting section with the Yokogawa, Atlas and Sensorex sources, marking the 4.5° as reasoned, not
  cited.
- `stirred_tank_medek_departures()` compared an undef blade angle, as on a twisted blade, which
  warned instead of answering and failed `just check` when `impeller_twisted_paddle_4` was selected;
  an undef angle is now listed as a departure.
- `render_sparger` also drew the stainless riser and support tube, so an exported sparge ring stood
  197 mm tall; the tubes have their own `render_sparge_tubes` flag, and the ring alone is
  140 x 140 x 18 mm.
- `docs/build.md` gave two outside diameters for the 3/8 in gas line run without saying which
  wall each was for, and 7.2 mm for the 3/16 in silicone, which is 7.94 mm at a 1/16 in wall; the
  outside diameters now say they follow a wall.
- The air pump's headroom was overstated about fourfold: 23.1 L/min "against this line" held the
  back-pressure at the design point, while the filter's drop rises with flow. The pump settles at
  6.05 L/min, and the old figure is echoed beside it.
- The baffle resonance warning tested nearness to the plate's first mode at the drive's fastest
  speed, though a DC drive passes every speed below it. `stirred_tank_critical_speed()` gives the
  speed at which each excitation crosses the mode, and `head()` reports each crossing against the
  drive's 320-420 rpm band and warns only on one inside it: the 10 mm plate's 17.59 Hz mode is
  crossed by blade passing at 264 rpm and by the shaft at 1055 rpm, 17.6% clear. An 11 mm plate
  (297 rpm, 7.2%) no longer warns and a 12 mm one (330 rpm) does. The warning no longer says a
  thicker plate moves the crossing out, and `docs/agitation.md` is corrected.
- `head.scad`, `docs/agitation.md` and `docs/ports-layout.md` still described the 9 mm baffle
  plate. The dovetail leaves 4.2 of 10 mm, 0.074 of the plate's second moment and a 14% deflection
  penalty; at 10 mm the joint does not trip the tenth-of-width warning (1.30 against 1.53 mm); and
  the plate widths are 17.09 mm on std and 9.51 mm on midi ports, while a 10 mm plate does not pass
  the mini's 9.8 mm bore.
- `docs/agitation.md` quoted the superseded D/T cap (0.4594 and 2.64 mm on `jar_6p5gal_305x470`);
  it is 0.4875 with 10.64 mm, and 0.64 to 0.87 on the other jars, with the old figures labelled
  superseded. It also said the baffle plates had not been lengthened, though they hang the full
  280 mm.
- `docs/procurement.md`, `TODO.md` and the metering valve row of `purchased-parts.csv` said the
  ReSun pump delivers 23.1 L/min against the line; they give 6.05 L/min, and `docs/procurement.md`
  keeps the 23.1 labelled.
- `docs/procurement.md` documented the 9 in 3872K117 thermocouple while the model and parts list
  use the 6 in 1245N31, and now records that the 9 in probe reached through a jar's floor. The air
  pump row in `purchased-parts.csv` gives 8.25 L and a 0.825-4.125 L/min band instead of 8.17 L
  and 0.82-4.09 L/min, a 17.4 kPa line instead of the vessel's 1.12 kPa, and no longer says the BOM
  has no flowmeter, regulator or check valve.
- `docs/build.md` quoted the baffle print echo as a 163 mm piece against a 170 mm bed; it quotes
  the 205.07 mm slenderness cap the model reports.
- `docs/agitation.md`'s blade-twist section described the helicoid as the current blade; it is
  marked superseded, since the model builds `pbt_45_4`. Its claim that the borrowed Po 0.99 made
  the power figures conservative holds only for a twisted blade and is labelled so, and Po is 1.498
  with a 51% rise instead of 1.602 and 62%.
- The bibliography: Michels 2015 appeared twice and is now one entry; twelve entries gain their
  grade and read status; the accession number PMC8459426 is resolved to Sato et al. 2021 (ACS
  Omega); Molina Grima et al. 1999, quoted in `docs/agitation.md` but cited nowhere, is added as
  unread; and `docs/references.md` records that Medek's correlations are taken at second hand
  through Fort. BibTeX that would have typeset wrong is fixed (an HTML entity, raw `<i>` tags, an
  unescaped ampersand, an unbraced SICI DOI, misspelt and misparsed names, U+2010 hyphens and 23
  page ranges on en-dashes), and the Spanish compound surnames in Sobczuk 2005 are written as the
  authors write them. The file has 48 entries.
- The Michels papers are read and their claims attributed to the right one of the 2010 and 2015
  papers. The bibliography uses the issue year throughout: Michels 2016, Nienow 2021, Kaiser 2017,
  Sobczuk 2006 and Leupold 2013. Jirout & Rieger is graded teaching material rather than peer
  reviewed, and its Np 0.99 is marked superseded.
- The gasket factor was attributed to ASME BPVC VIII-1 Table 2-5.1 while it was read from a
  Codesign Engineering summary; they are now two entries, the standard marked unread and the
  summary as the trade-press source read. The model is unchanged. `TODO.md` adds looking up the
  table's elastomer row and its seating stress `y`.
- `docs/references.bib` used `July`, `Sept` and `June`, which are not BibTeX month macros; all 27
  months are lowercase three-letter macros. Its header counts 48 entries, 39 with a DOI, instead
  of 33, and records the issue-year and surname conventions it does not take from Crossref.
- Six references in the docs, `TODO.md`, `purchased-parts.csv` and `thermocouple_probes.scad`
  pointed into notes that are not in the repository. `docs/procurement.md` records why the
  flowmeter, check valve and metering valve were chosen, `docs/ports-layout.md` records the bound
  of about 98 mm below which four baffles cannot sit beside two 16 mm probes, as a search result
  rather than a model output, and links `ports_layout.drawio`.
- `head()` did not echo a measured impeller power number, as it does a correlated one; it now gives
  it with its band (`rushton_6` Po 4.17 +/- 0.14) or says the source gives none.
- The standalone previews of `sheet_gasket.scad` and `sparge_ring.scad` had drifted: the gasket is
  read from the registered 1.5875 mm sheet instead of 1.5 mm, and the ring's radius is 68.25 mm
  instead of 68.04 mm.
- `just check-mesh` skipped five entry files as slow and said to build one before printing, though
  three can never pass: `head.scad` fails only on its seals, probes, and bearing and coupling, all
  declared not printed. `electronics_stand.scad` is now checked with `print_corner=true` (14 files
  instead of 13); `assembly.scad`, `cart.scad`, `frame.scad` and `head.scad` are skipped each with
  its own reason, printed even when one is named; and the recipe points to `just export-parts`
  before printing. `docs/design-conventions.md` adds the rule to check the configuration that makes
  the part, not the one that makes the picture, and `TODO.md` closes the item.
- The frame base's centre bore was cut from the wall, which left `jar_6p5gal_305x470`'s contact
  circle 13.2 mm inside the hole, the jar resting on the bore edge on its own fillet. The bore is
  cut from the jar's registered base corner radius and `base_jar_support_reach` (15 mm), so every
  jar lands 15 mm inboard of the floor ring; `frame()` takes `vessel_corner_radius_base`, asserts
  the bore stays positive and echoes the floor ring. The 10 L bore goes from 146.4 to 165.0 mm, so
  the printed base changes.
- Two figures chosen for `jar_10L` stopped other jars building from `assembly.scad`.
  `culture_working_volume` defaults to undef instead of 8.25 L, which had left
  `jar_6p5gal_305x470`'s thermocouple in the headspace; and the DO probe's lean is derived as the
  most of `do_probe_port_tilt_max` (4.5°) the jar's impellers, sparge ring and mouth allow (2.5° on
  `jar_1gal_180x197`) unless `do_probe_port_tilt_degrees` pins it, and `head()` echoes which. Four
  of six vessels render from `assembly.scad`, up from two; `jar_10L` is unchanged.
- `TODO.md` recorded two of six vessels as building and blamed `jar_1gal_155x251` on a vertical DO
  probe through the upper impeller; four failed as the model shipped, two are now fixed, and the
  blocker is the vertical pH probe running 6.29 mm through the lower impeller, with the old reading
  marked superseded. It adds an item for sweeping `assembly.scad` and `frame.scad` against the
  registry.
- **Breaking:** `culture_fill_fraction` was a fraction of the vessel's internal height while citing
  a headspace convention for volume, so `jar_10L` was filled to 86.5% of capacity. It is now a
  fraction of capacity (`head_vessel_capacity()`), solved to a surface height through the vessel's
  profile, and is 0.865 instead of 0.8, since 0.8 of capacity would leave 0.374 D of culture over
  the upper impeller against the 0.5 D floor; `jar_10L`'s fill line moves 3 µm. `head()` echoes the
  headspace and the departure from 0.8, and `frame.scad`'s preview labels its 0.8 as a height
  fraction.
- `just check-json` deleted every space in a dropdown list before comparing it with the registry,
  so a name with a space (such as `pH lab g2`) could never match; it splits on the commas and trims
  each name instead.
- `just export-parts` rendered each part from `head.scad` or `frame.scad`, which carry no build, so
  a designated part (such as `do_probe_name = "DO lab g1"`) was exported as the default part and a
  named vessel got the preview jar's frame, without a warning. Every part now renders through
  `assembly.scad`, whose new `export_at_origin` places a head part where `head.scad` would; the
  vessel is selected from `assembly.json` instead of `head.json`, and the export reports the
  designations it carries. With `DO lab g1` the DO port goes from 27.20 x 27.20 x 87.96 to
  27.20 x 27.40 x 93.99 mm; the default export is unchanged.
- A designated part skipped the rule its derivation selects on: a plug o-ring named by a build went
  unchecked (`AS568-151` built at 82.8% stretch), and a named strip light shorter than the culture
  built silently (`grow 8.6in`, 217 mm under a 236 mm culture). The plug ring's 0-5% stretch band
  is now asserted for whatever ring is fitted, and `assembly.scad` warns when the light leaves part
  of the culture unlit, saying how much.
- The Customizer showed the wrong descriptions, since it reads only the line immediately above a
  parameter: `shaft_name` showed the last line of a prose block, and `ph_probe_name` the line of
  code above it. Every parameter in `assembly.scad` gets a one-line description; all eight
  designations (vessel, shaft, strip light, plug o-ring, both probes, gasket sheet and motor) get a
  dropdown generated from their registry, which `just json` verifies; and twelve derived values
  (`reactor_build`, `_reactor_light`, the `_build_*` resolutions and `reactor_vessel`) move under
  `/* [Hidden] */`. `TODO.md` files the same problem in `head.scad`'s 130 parameters and
  `frame.scad`'s 35.
- The joint's bolt count was derived from the lid flange's thickness alone, where ASME's spacing
  rule wants the thinner of the two plates, so a 6 mm top base still reported 12 posts instead
  of 16. `assembly.scad` reads the top base's thickness from `frame_upper_base_height()`, which
  `frame.scad` exports; nothing moves at 8 mm against 10 mm. `frame_rod_at()` places what is cut at
  each tie rod for the rods and both bases. `TODO.md` retires the completed campaign item into its
  settled ledger.
- `TODO.md`'s magnetic drive item quoted gaps of wall plus punt with no clearance, and missed that
  the punt is re-entrant, so a driver hub inside it pays the wall alone (3.0 to 5.0 mm on four of
  five swept jars), which inverts its ranking: `jar_1p5L_109x215` is the worst at 7.5 mm of usable
  radius and `jar_1gal_155x251` the best at 36.5 mm through 3 mm of glass. It adds that the punt is
  a shallow cone (3.5 to 33.8°), that the torque to beat is already reported (0.067 N m for the
  pair at 320 rpm; 4.8-12.3 mN m on `jar_1p5L_109x215` at equal tip speed), and that a magnetic
  drive has no mount, which makes centred against eccentric a real decision.
- `docs/references.md`'s eccentricity section measured T as the vessel's outer diameter, where the
  project uses the bore. Corrected, Hall's e = 0.2 T needs 20.2 mm on `jar_1p5L_109x215` and
  42.0 mm on `jar_10L`, every e/T rises 4 to 8%, and the gains are 17/25/31% today and 31% at best
  on `jar_6p5gal_305x470`, the closing figure going from 24-30% to 25-31%. Hall 2004 and Karcz 2005
  are now read: the section writes out Karcz's eq. (6), states both papers' departures from this
  build, and says its figures are Karcz's up-pumping branch. `docs/ports-layout.md` and `TODO.md`
  follow.
- Two figures in `docs/agitation.md`, `docs/build.md` and `TODO.md`: the mouth-limited D/T is
  0.4879, not 0.4875, and the exhaust filter budget is 1.8854 kPa per L/min at 0.5465 of the inlet
  filter's slope, not 1.91 at 55%, which had been computed against the retired 8.25 L working
  volume.
- The tube sparger's holes were all blind: its octagon is sized across the flats but reaches
  3.247 mm across the corners on a 6 mm tube, so every hole stopped 0.247 mm inside the wall, and
  the split left a 0.247 mm skin, so the ring never opened. Hole reach is derived per ring from the
  corners. An odd hole count put a hole in the split and still counted it; the split is now checked
  against the real hole positions (9 refused, 10 built). The fit envelope, support pocket and arm
  half-width are measured across the corners too, a quarter millimetre more a side.
- The sparger's octagonal section stood on a corner, so its first layer was a knife edge and the
  holes met a corner. The section is turned so a flat lands on the bed (and on all four cardinals
  for a multiple of four facets), the spokes take their own quarter turn, the hole probes measure
  to the flat they now face, and the support boss no longer hangs 0.26 mm below the rings: the
  first-layer footprint goes from 32.1 to 2596 mm². `just check-holes` reported ok on a file that
  did not render; it now fails.
- `docs/build.md` told builders the sparger's feed socket is a hexagon; it is an octagon, both
  sockets 6.4 mm across flats, and its corners stand only 0.264 mm proud of the round one where a
  hexagon's stood 0.49 mm. `docs/agitation.md` no longer says there is no sparger in the model or
  sizes one at Oldshue's superseded 80% of the impeller, and records bubble size and the 2.25 open
  area ratio as what is open; `docs/references.md` no longer calls Hall 2004 unread; and
  `docs/design-conventions.md` marks its sparge ring example's conclusion as overtaken. `TODO.md`
  adds checking that a hole is fed, `sparger_report()`'s single path count, and settling the socket
  keying with a print.
- **Breaking:** The lid's gasket rested on a flat land on the rim that four of five jars do not
  have; only `jar_6p5gal_305x470` is ground flat. A vessel's `rim_rad` now says which lip it has:
  undef for ground flat, 0 for rounded in line with the wall, and above 0 for a bead standing that
  far proud (`vessel_rim_arc_radius()`, `vessel_lip_arc_meets_wall()`); `jar_6p5gal_305x470` goes
  from 0 to undef. A ground lip keeps the flat annular gasket; a crowned lip gets a gasket that
  covers it, with its contact band derived from how far the crown sinks in and compression set by
  the joint turn. `head()` takes `lip_arc_radius`. On `jar_10L` the gasket goes from a 3 mm inset
  to 8 mm covering, the contact band from 3 mm assumed to 3.24 mm derived, the seating force from
  3501.92 to 4234.86 N and the glass stress from 2.51 to 2.78 MPa, still on 12 posts. Two corner
  radii their walls contradicted (solved neck corners of 3.50 mm in a 5 mm wall and 3.36 mm in a
  4 mm wall) are re-measured, `jar_1gal_180x197` from 12.5 to 10.0 mm and `jar_1p5L_109x215` from
  7.5 to 6.0 mm, clearing both warnings.
- The tube port's rod gland was a counterbore open at the vessel-side face, so an unseated ring
  dropped into the culture and the steel tube lost what stops it slipping. It is now an enclosed
  groove above a 1.2 mm lip (a 2.2 mm radius bore the full length, the groove from -16.80 to
  -14.55 mm), which a 4 x 1.5 mm EPDM ring folds into by hand. `head()` draws the rod seals under
  `render_seals`, and `purchased-parts.csv` describes the groove instead of the counterbore.
- The litre and flow figures in `docs/` and `TODO.md` are re-derived from a render: `jar_10L` holds
  8.23207 L of culture, not 8.2807 L, and `jar_6p5gal_305x470` 20.42 L at 10.21 L/min instead of
  22.06 L at 11.03 L/min, which changes no rotameter choice. `docs/procurement.md`'s 84:1 spread was
  the flow's, not the culture volume's (14.7:1), and the flow spread is now 73:1; its meter table
  gains `jar_1gal_180x197`. `docs/agitation.md` no longer says `culture_working_volume` pins the
  dissipation volume.
- `head()` asked whether a vessel wants two impellers in H/T against 1.2, an unsourced convention on
  the wrong quantity. It now reports liquid height over impeller diameter against the bounds of
  Fitschen 2019 eq. (5), (H-d)/d > n > (H-2d)/(2d) (`stirred_tank_impeller_count_bounds()`,
  `stirred_tank_impeller_count_fits()`), which puts a pair out of reach on four of five jars
  instead of three, `jar_1gal_155x251` joining them. It reports and never asserts, since
  `docs/references.md` now records that the rule traces back to the Davis 2010 thesis and no
  primary source. The impeller count stays two on every jar.
- `sparger_report()` priced every bore segment on one path count of 2, so the feed run, which
  carries the whole flow, came out at half its velocity and a quarter of its head, while a ring was
  priced on the full flow instead of its share. Each segment is now priced on its own flow, rings
  by their share of the holes, and departures take the worst segment: on the build the feed run is
  5.46 m/s and 17.94 Pa with an open area ratio of 4.5, not 2.25. The two-ring example goes from
  clean to two departures.
- `docs/build.md` still quoted 291.8 N per post and 2.51 MPa on the glass from before the gasket
  moved onto the crowned lip; it now gives 352.9 N and 2.78 MPa, a torque band of 0.56-0.85 N m and
  bolt and rod stretch of 0.0010 and 0.0005 mm, with the 114° turn unchanged. `TODO.md`'s gasket
  recess item is rewritten for the 6 mm flat and 8 mm crowned gaskets.
- The port face o-ring's gland was cut at exactly the ring's outer diameter (26.00 mm for a
  26.00 mm ring), so a 23 x 1.5 ring would not go into a printed port; `bayonet_gland_allowance`
  (0.2 mm) opens it to 26.2 mm. The flange lips were 0.6 mm and are now 1.2 mm on `mini` and
  `midi` and 1.0 mm on `std`, and the gap between neighbouring flanges is checked against a new
  `lid_flange_gap` instead of `lid_holes_offset`, the wall the lid keeps around a bore. Every jar
  keeps its port set. The drawn port ring sits at the gland's face instead of mid-depth, at its free
  ID. `TODO.md` asks for a reprint to fit.
- `docs/ports-layout.md` had not followed the tube ports: it named the removed
  `sparge_support_functions`, said only the two gas ports were bored for a tube, gave the sparger
  two sockets 120° apart instead of five at 0, 180, 240, 270 and 330°, read `ACID Ø4.8` instead of
  `Ø4.4`, and called the socket boss a hex. It now says to count facets to tell the feed socket from
  the four supports.
- The 10 L jar's mouth is 142.2 mm as measured, not 143 mm, so every lid printed had a 142.6 mm
  plug for a 142.2 mm mouth. The lid, sparger and both gasket cutter halves change shape; the ports
  and baffle pieces only change position. The worst adjacent flange pair goes from 1.254 to
  1.0466 mm against the 1.0 mm `lid_flange_gap`, and the baffle's running clearance from 2.20 to
  1.80 mm; the documents follow (joint load 4212.27 N, 351.023 N per post).
- Figures in the documents that had moved without being followed: the lid gasket is cut
  142.2 x 158.2 mm one to a sheet, not 145 x 151 mm four to a sheet; the joint load is 351.023 N per
  post (2.1% of proof), not 291.8 N; the torque band 0.56-0.84 N m; the baffle cap 200 mm, not
  205.07 mm; the baffle plate 10.3454 mm, not 15.3 mm; Po 1.49679; the design flow
  0.822-4.11 L/min on 8.22 L; the filter drop 14.18 kPa and the valve Cv 0.0331. The silicone
  gasket row's objection is restated: a 142 mm ID falls inside the 142.2 mm mouth.
- Four recipes showed a sentence fragment in `just --list`, since `just` reads only the comment
  line above a recipe, and `analysis-all` had no description; each has a one-line one. `just stats`
  no longer points to one machine's setup when cloc is missing.
- `just check-bom` read `purchased-parts.csv` through the analysis virtualenv, so `just check`
  failed on a checkout where `just analysis-setup` had not been run; it uses the system Python.
- `just check-holes` failed with a bare `ModuleNotFoundError` where the system Python has no numpy;
  it runs its probe with `uv run --no-project --with numpy`.
- The feed riser was cut to the support sockets' datum, though the feed socket sits lower, so it
  came out 6.136 mm too long and would bottom in its socket and lift the ring off the four supports.
  The feed riser is now 182.037 mm and each support 188.174 mm (934.733 mm from the 1 m stock,
  65.27 mm spare), each drawn at its own length, the gas-line drop is priced down the feed tube
  (117.37 to 113.543 Pa), and `head.scad` passes `sparge_feed_height()` to `sparger()` instead of
  relying on a matching default.
- The thermocouple's reach was its catalogue tip length, which is measured from the end of the
  threads, compared against the floor and culture surface, which are measured from the lid's outer
  face, so it overstated the depth by the 25 mm the flange and mount stand above the lid, less the
  engaged thread. `head_thermocouple_depth()` gives the depth below the lid's outer face for both
  the reach checks and the impeller-collision run, with a new `thermocouple_thread_engagement`
  (0.5 of the threaded body, hand-tight on a printed boss): 137.4 mm instead of 152.4 mm for the
  1245N31 and 134.9 mm for the 3872K129. The floor assert tests the probe fully threaded and the
  surface assert not threaded at all; `jar_6p5gal_305x470`'s tip sits 9.26 mm under the surface at
  0.5 and 1.76 mm at zero engagement.
- `head_thermocouple_run()` re-derived the thermocouple port's interface instead of taking the
  lid's pinned one, which differs on `jar_6p5gal_305x470` and `jar_1gal_155x251`; it takes the
  interface as an argument. The sparger echo gave the feed riser's stiffness as a support's and now
  reports both free lengths, taking the feed's own datum when there are no supports.
- `just check-echo` looked for errors on stderr, but OpenSCAD writes ERROR and TRACE lines into the
  echo file, so that check never matched. The transcript is the echo file alone, with line numbers
  normalised to `line N`, so an assert is pinned by its condition and message and not by where it
  sits.
- `head.scad` declared `reactor_vessel_name` below `module dummy()`, so the Customizer never
  offered it and `head.json`'s sets could not be selected there; it sits in a Vessel Selection tab
  as in the other two entry files.
- Stale figures in `docs/agitation.md` sections 2 and 5: the impeller pair's torque is 0.102/0.176
  N m, 21-36% of rating, not 14-24%; the eccentricity room on `jar_6p5gal_305x470` is 9.8 mm, not
  10.3 mm; and the jar's capacity and the `jar_1p5L_109x215` mount overlap are updated. The
  operating-point table says which rows are echoed and which computed.
- Model figures in `docs/build.md`, `docs/ports-layout.md`, `docs/procurement.md` and
  `docs/references.md` that had moved: the port circle is r 56.5 mm, not 56.9; the reduced port
  set's smallest mouth is 78.0 mm, not 77.6; the tube cut list is 1 x 182.0 plus 4 x 188.2 mm with
  65 mm spare, not 5 x 188.2; the lid gasket is cut 142.2 x 158.2 mm one per sheet; and the plug
  ring stretches 3.67%, not 4.27%. The corrected port-set floors are a new entry in
  `docs/decisions.md`.
- The stir slot's two cuts started at the bore's radius, so a sliver of wall stood between them at
  the slot's edges (0.32 mm across the groove and 0.64 mm across the notch on `jar_10L`, 1.7 mm on
  `jar_1p5L_109x215`) and the carrier's ear could not enter. They run from the axis now.
- The rib pair carrying the empty light pockets turned under the other pair's bosses on every
  second level, where a pump mount could not drop in; it is the upper ring at every level.
- `check-holes` on `head.scad` never tested anything, since the head echoed its hole probes in the
  ring's own frame while the mesh sat 170 mm lower. The probes carry the part's origin, verified
  inside the mesh for both spargers.
- Two fan joint figures measured the punt at the fan's corners and a third at the screw circle;
  they share the screw-circle figure and the third is gone. `docs/build.md` said six registered
  vessels instead of five.
- Three printed parts exported with coincident faces where two solids met on exactly one plane,
  which the slicer had to repair: `sparge_arm`'s socket taper on the elbow's end cap, the
  impeller's set-screw collar on the body's top face, and the probe port's tilt wedge on the
  coupling and the holder. Each now starts just inside its neighbour without growing the part: the
  `sparge_cap` volume is unchanged and the impeller's grows 0.0003%, with every bounding box the
  same to four decimals.
- Every lid exported with coincident faces from bayonet-lock-scad's entry transition, cut by a
  cylinder whose base passed through three surfaces' centres at once. `openscad-libraries.txt`
  pins 0.11.1, which drops the redundant cut, so `tests/seams.txt` keeps only the probe ports'
  three seams instead of six.
- `just export-parts` failed on CI where it passed locally: `tests/seams.txt` pinned this machine's
  coincident-face counts, and `port_do_probe` measured none here and one on the Ubuntu 24.04
  runner, both on OpenSCAD 2021.01. A part now fails only above a ceiling of 10 coincident edges
  (`SEAM_CEILING`), clear of a tangency's one or two and of a shared face's tens or hundreds (202,
  124 and 43 for the three fixed earlier), and is noted below it; an open edge still fails.
- The gasket cutter base asserted rather than building for `jar_1p5L`, whose ring is cut inside the
  62 mm platen bore, taken from the three vessels whose gasket line reached a transcript.
  `platen_bore` is 36, clearing the smallest ring any registered vessel asks for (r 43.75), so every
  vessel that builds a head exports all three cutter parts; the spokes save 8 % against a solid
  disc.
- Gas figures in `docs/build.md`, `docs/procurement.md`, `TODO.md` and `purchased-parts.csv` follow
  what `head()` echoes now: the pump settles at 5.80 L/min against the line, not 5.97; an outlet
  filter may cost 1.70844 kPa per L/min, 49.5 % of the inlet's; and a second 1594522 filter on the
  outlet puts the line at 32.5 kPa and settles at 3.17 L/min. The `air_out` slot's floor, the
  headroom it spends, and the pump and needle valve rows follow.
- `check-holes` and `check-scad` passed on an OpenSCAD that renders nothing: the first read no probe
  lines as nothing to report, and the second passed every file meant to emit nothing. Both now
  render a cube first (`scripts/openscad-canary.sh`) and stop unless it comes back as geometry,
  judged by the file's size since a failed export can still exit 0.
- The condenser's print, assembly and report helpers passed literal bores, shells and collars
  instead of the modules' defaults, so a longer flow-head collar exported the insert 2 mm into the
  bed. Each file names its defaults once and the helpers read them; every part renders to the same
  volume.
- `render_ext_shaft`'s description said the shaft is cut to length; it is bought at a stock length,
  and the motor mount's height takes up the surplus.
- `frame.scad` reported an undefined-operation warning when opened, from `lights()` taking
  `allowance_cutout` as both its mode and its value. `light_places()` puts children on each light's
  angle, and `lights()` and `light_pockets()` draw and cut; the geometry is identical.
- Printed bases held their lights hard against the jar. A light's datum, the back of its body, sat
  on the jar's nominal diameter, putting its bulging cover 0.5 mm inside the glass; it now stands
  off by the cover's radius and half of `base_jar_fit_allow`, which lands the lens 0.3 mm off the
  glass on all five registered vessels. The seat has `light_pocket_allow` (0.3 mm) on each face
  instead of 0.4 mm shared across a dimension, is deep enough for the cover as well as the body, and
  is 1 mm longer than the light (`light_pocket_end_allow`), since it is closed at the top; `frame()`
  checks the seat's end, not the light's, against the rib levels. The cord groove and notch keep
  `light_allow`, so no floor or carrier moves. The base and ribs are a reprint.
- A light's seat was sunk past the bore by its clearance on its centre line, so at its corners,
  where the bore curves away, a crescent of material stood across the pocket's mouth, 0.198 mm at
  its thickest on `jar_1p5L`, where the stir drive's lead leaves the base. The seat's face now also
  clears the bore's fall over its half width (`light_bore_radius()`); its outer face, the light's
  position and every echo are unchanged, and the thinnest feature on `jar_1p5L`'s base goes from
  0.020 mm to 1.407 mm.
- The condenser coil panel's screw counterbore opened through the panel's underside, showing as a
  keyhole in the first layers. The screw sits 0.8 mm higher, the pocket running from -9.2 to
  -3.2 mm, and two asserts hold it between opening through the underside and its clearance hole
  leaving the socket.
- The mount-over-ports check holds the bearing blank's flange, so `jar_1p5L_magnetic` no longer
  builds with it 12.95 mm into its ports on a bearing lid.
- With no drive, the sparge ring hung where the shaft build puts it, 67.8 mm up on `jar_1p5L` and
  98.1 mm on `jar_1gal_155`; it now sits `sparge_ring_floor_gap` (10 mm) over the highest glass
  beneath it, read off the jar's profile by `vessel_floor_height()` and `head_ring_floor_rise()`.
  `jar_1p5L`'s DO probe now takes its full 4.5° lean, so its DO port changes.
- **Breaking:** `jar_1p5L_109x215` is 111.5 mm across, not 109.22, and is renamed
  `jar_1p5L_112x215` in the registry, its sets in all three JSON files, the Customizer and the
  docs. On the 1.5 L builds the joint circle is 130.5 mm, capacity 1.676 L and the stir carrier
  66.1 mm.
- `jar_1p5L_112x215`'s opening is 88.4 mm, not 87.5, where a lid printed to 87.5 fitted loose. Its
  lid goes uniform std, with all six ports on the std interface on a 59.2 mm port circle, so its
  tube ports are reprinted and `port_blank_mini` leaves the export; no registered jar uses the
  mini interface now. The gasket is cut 88.4 x 98.4 mm and the draft tube is 85.6 mm outside.
- The 36GP-3530's gearbox output shaft is 26 mm, measured on the bench motor, not 20, and its row
  is renamed `gearbox_36gp_3530_5p18`.
- The motor mount sized the gearbox's and impeller's shafts to meet at 0 mm in the coupler and
  missed the gearbox's pilot boss, so the shafts overlapped by 2 mm on `jar_10L` and collided on
  the bench. The mount's height counts the boss (`head_gearbox_shaft_reach()`),
  `shaft_shaft_coupling_offset` leaves a 3 mm gap by default, and `head()` reports the gap and
  refuses shafts that meet or that reach less than a quarter of the coupler. The `jar_10L` mount
  is 127 mm instead of 122 (134 mm on the 36GP-3530).
- The export's parts-list and printer-fit stubs took the build's parameter set with `-p/-P`, which
  newer OpenSCAD applies only to the file it opens, so every stub described the default shaft
  build and `just export-part frame_hub_cap jar_10L_magnetic` failed. They take the set's values
  as `-D` assignments (`export_defines`), and a missing set fails.
- The impeller's collar bore was cut at the hub bore's radius, leaving a ring of 77 edges the
  OpenSCAD nightly kept on `jar_1gal_180x197`'s impellers; the bore is cut once after the union.
- `check-echo` pinned OpenSCAD's `TRACE:` call-stack lines, which change between releases; they
  are dropped before comparison.
- `jar_10L_220x305`'s punt is 10 mm, not 5. The motor mount grows from 127 to 132 mm (the
  `motor_mount_middle_stand` 107 to 112 mm) and the magnetic carrier from 35 to 37 mm, the culture
  is 8.17 L at 229.5 mm deep, and every 10 L figure in the docs follows.
- `baffle_floor_clearance` was measured from the floor's lowest point, so on a punted jar the
  plates cleared the glass under them by less: 4.4 mm instead of 10 on `jar_10L`. The plates' length
  now comes off the glass under their span (`head_floor_rise()`): `jar_10L`'s go from 280 to
  274.4 mm and `jar_1gal_180`'s from 172 to 166.1 mm, and the baffle-length functions and
  `head_print_parts()` take the vessel.
- `check-designations` fed its bad names through a parameter set, whose unlisted values OpenSCAD
  2026.10 drops silently, so all fourteen bad-name rows failed on the nightly; they take the name
  as `-D`.
- The frame reported the fan, its joint and the magnets under every drive wherever the base is
  slotted; under any drive but the magnetic one it now reports one `stir drive: none fitted` line.
- The DO-over-ring warning fired for a probe face below the ring, printing a negative height; it
  now requires the face above the ring's centreline and says "above" or "below".
- The gas supply line printed a negative throttle drop where the line already costs more than the
  pump can push; it now says there is nothing for a throttle to drop.
- The sampler base's seat shared the top half's 8.14 mm bore, which the silicone sleeve swells the
  clear tube past; the seat, its 45° stop and its lead-in take `tube_seat_d = 8.6`, and the bore
  between the heads, and so the optical path, is unchanged.
- The July 2026 strain is CPCC 90 (Canadian Phycological Culture Centre), not CCPC 90: the run
  directory is renamed `2026-07-23-chlorella-cpcc90`, and its README, `pipeline.py`,
  `analysis/README.md`, the justfile example, `TODO.md`, the 2024-11-19 run's link and the
  `sensors.png` title follow.
- `check-holes` passed blind holes drilled down, whose two probes are open whether or not the hole
  reaches the bore; a third probe now sits in the wall just under the bore, for the arm and the
  loop.
- The arm's screw pilot and the ring's end-plug pilots ended exactly on the faces they open
  through, leaving `jar_10L`'s ring with 2 non-manifold edges; both run past their faces.
- The bayonet ports' lettering asked for `font="sans"`, a fontconfig alias each host resolves its
  own way, so exports changed with the machine; it is cut in `Liberation Sans`, held in
  `bayonet_port_font`, and CI installs `fonts-liberation` and fails unless `fc-match` resolves it.
- The 4x1.5 ring folded into the sparger's feed socket could not be fitted, and is gone from the
  ring, the arm and the loop. The arm and the loop seal on their riser by a press fit: a socket
  20 mm deep instead of 12 whose bore tapers from 4.2 to 3.8 mm (`sparger_socket_press()` 0.2 mm),
  the boss filled down to the part's underside, and the run carried straight under the bend where
  it left a wedge open; every riser keeps its length. The ring returns to its 12 mm slip-fit socket.
  Gas holes are 1.2 mm, since 1 mm printed too small, and round where they came out as hexagons:
  the ring's 16 run 3.76 m/s on `jar_10L`, the arm drops to 8 holes at 7.53 m/s, and the loop,
  whose far end bubbled weaker, takes 11 (`sparge_loop_hole_count`) at 5.47 m/s.
- `just clean` also deleted `working.tmp/`, which no recipe writes; it removes `output/` alone.
- The README listed four of the seven libraries `openscad-libraries.txt` pins, missing
  din168-thread-scad, turbidity-sensor and syringe-actuator; it lists all seven, points at the pin
  file for revisions, and says to run `just setup` first, since a global library copy can hide a
  missing `.openscad-libraries/`.
- `head_reach_obstacles()` listed both impellers under every drive, so the DO probe's lean ceiling
  on a magnetic build was capped by impellers it does not have; the list takes the drive and holds
  the impellers under the shaft drive only. No registered build moves.
- The wall cage's hoop channels at 0.15 mm a side let some bottom bars sit loose; the hoops are cut
  at 0.10 mm (`baffle_cage_fit()`), while the new `baffle_cage_bar_fit()` keeps the blades' bars at
  0.15, so only the hoops are reprinted.
- The needle valve and its barbs are priced and linked from Air Engineering's own product pages:
  the `11792-4-BLK` barb was 0.60, Clippard's price for more than 250, and is 1.54.
- The 2026-07-23 run's README timeline is corrected from its data: pH bottomed at 3.649 and was
  already falling before the impeller failed, the reboot gaps were 1.93 h and 6.23 h, the final
  stirred run began at 13:22 EDT, the mis-stamped burst is 17 s, and it now records the first
  12.82 h as stirred by an external driver and 13.65 h unstirred after a power loss.
- The temperature port's thermocouple was never drawn; it is, placed by
  `head_thermocouple_depth()` as the checks place it, and its rounded tip sits inside `tip_h`
  instead of 1.5875 mm past it.
- Beside a loop or an arm sparger, every tube port but `air_in` carried a tube cut to the ring's
  sockets, capped and drilled, hanging to a ring that is not there. A dosing tube now ends open at
  the upper impeller's centre (on `jar_10L` 187.938 mm instead of 219.474), the ring builds keep
  theirs, and `render_dose_tubes` draws these tubes apart from `render_sparge_tubes`. The 316 tube
  cut list on `jar_10L_220x305` drops from 1140.8 to 1046.19 mm.
- Figures in the docs and `purchased-parts.csv` that the model no longer emits take the committed
  echo transcripts' values (on `jar_10L` 8.17 L at 4.09 L/min, 17 hose clamps, the ring's five
  sockets), and figures from unregistered configurations are labelled with theirs. The riser tube
  goes from 1 to 2 one-metre lengths, since 1046.19 mm does not come out of one, and
  `references.bib` adds Daub 2014, Podgorska 2019 and Xing 2009.
- The O-ring row counts a ring build's rod seals as `head()` does, six on the full lid and three on
  the six-port jars, and the rotameter table's 1 gal row reads `jar_1gal (both)` instead of a
  mangled `jar*1gal*x2`.
- `docs/commissioning.md` gives the outlet filter's headroom as about 50 %, to roughly 21.1 kPa,
  not 51 % to 21.2, and both DO levers with the direction each moves the face; the filter row in
  `purchased-parts.csv` names the `gas_filter_cp_1594522` row instead of the removed
  `sparge_filter_drop_slope`.
- The column-lid spike's `build.sh` passed a non-manifold lid on an OpenSCAD that defaults to
  manifold, which prints no 2-manifold warning; it renders on CGAL wherever a backend is offered.
- At 300° the sampler's syringe actuator stood in the coil condenser on `air_out` on every build
  carrying both (about 8 x 5 x 15 mm, 223 to 238 mm over the lid), which `check-clash` missed while
  the actuator was not drawn. The sampler takes port 6 at 180°, opposite the condenser, and dose 1
  takes port 10 at 300°; the ring's sockets follow the tube ports to 0, 210, 240, 300 and 330°.
  The lid itself is unchanged, since each label is engraved on its port pin. `docs/ports-layout.md`
  names doses 1 and 4 for acid and base on the plate lid, and doses 2 and 1 under the wall cage.
- `docs/ports_layout.drawio` drew the ports clockwise, the lid seen from below, under an arrow for
  the shaft seen from above, so read counterclockwise eleven of its twelve labels sat on the wrong
  port; the ports are mirrored, a caption names the view as the plate lid seen from above with the
  wall cage's differences, and 180° is the sampler and 300° dose 1 instead of dose 1 and a dose 3.
  `docs/build.md`'s print lists name the dosing ports `dose_1`, `dose_2` and `dose_4` (`dose_1`
  alone on the six-port lids), add the coil condenser's five prints, the sampler's two, the three
  dosing pump mounts and the two heat pad plates, give the six-port lids six locks, and say plates
  split only where a piece would be too slender to print standing.

### Removed

- The archived FreeCAD models and STLs in `archive/models3d/`.
- `stls/impeller_v1.stl`.
- Print files `impeller_mould_negative` (STL and 3MF) and `tube_mount_pins_d6mm.3mf`.
- The nut traps in `male_end()`, with its `nut_width` and `nut_dim` arguments.
- `old_lid_multihole.scad` and `test.scad` from `scad-v2/_archive/`.
- Print files `phdo_lock.3mf`, `phdo_lock_v1` to `phdo_lock_v5`, `phdo_pinch.3mf` and
  `phdo_pinch_v0` to `phdo_pinch_v6`.
- Print files `motor_mount_new_base`, `motor_mount_new_base_v2`, `motor_mount_new_middle`,
  `motor_mount_new_middle_v2` and `motor_mount_new_top` (STL), and `turbidity_monitor_mount_v0` to
  `_v3` (STL) with `turbidity_monitor_mount_v0.3mf`, `_v1.3mf` and `_v3_XL.3mf`.
- `probe_atlas.scad` and `probe_thermocouple.scad` from `scad-v2/purchased/`, replaced by
  `atlas_probe.scad` and `thermocouple_probe.scad`.
- `scad-v2/utils/circular_pattern.scad`.
- Committed derived analysis data and the scripts the pipelines replace, about 62 MB:
  `clean_temps1.py`, `clean_start2.py`, `plot_sensors.py`, `plot_actuators.py` and the microalgae
  `cleaned0/1/2` CSVs; `clean_spectro.py`, `plot_spectro.py`, `plot_spectro_all.py` and the
  spectroscopy `cleaned1`, `flor1cm`, `flor90uWpeak` and `led1cm` CSVs; and the July 2026 run's
  per-signal CSVs. The pipelines regenerate them, except the spectroscopy `cleaned1` file, which
  nothing read.
- **Breaking:** Controls that did nothing are removed: `motor_mount.scad`'s `render_base_plate`,
  `render_middle_stand` and `render_face_plate` (`part_to_render` selects parts), `head.scad`'s
  `render_phdo_probes`, and `motor_mount()`'s unused `motor_faceplate_diameter` argument.
- **Breaking:** The original `scad/` tree (17 files, among them `assembly.scad`, `jar.scad`,
  `tube_lock.scad` and `thermocouple_lock.scad`), superseded by `scad-v2/`; its bayonet locks no
  longer built against bayonet-lock-scad 0.6.0 and later, which dropped `outer_bayonet()`.
- The assorted 4/6/6.5/20 mm EPDM O-ring row in `purchased-parts.csv`, none of which seals a port.
- `check_body_diameter()` from `motor_mount.scad`, and the unread parameters of `middle_pipe()`
  and `male_end()`'s second screw parameter.
- The Seichter 1981 reference, the only one never read, whose point Ameur 2018 carries; the
  bibliography is 33 entries, all read.
- The 40 printed STL files in `printing/` (42 MB), all superseded; the 33 PrusaSlicer 3MF projects
  that record what was printed stay, and `just export-parts` makes the current parts. The probe
  port fit sweep their names recorded (0.5 mm tight, 0.6 mm used) is noted on
  `probe_port_collet_body_allowance`.
- Four unread symbols: `head_bayonet` and `lid_vertical_allowance` in `head.scad`, and
  `stirred_tank_sparge_ring_diameter()` and `stirred_tank_baffle_width()` in `stirred_tank.scad`.
- **Breaking:** `scad/custom/sparge_ring.scad` and `sparge_ring()`, replaced by the tube sparger.
- `render_baffle_coupon`, `baffle_coupon_diameter` and the `baffle_port_coupon` print, since the
  baffle lean it was for no longer needs measuring: the narrower plate clears the blades by 2.20 mm
  running. `TODO.md` drops the measurement and the tip ring item, and turns the baffle item to
  whether the reduced projected area (0.579 of the reference) is acceptable.
- **Breaking:** `culture_working_volume`, the override that pinned the culture in litres; the volume
  always derives from `culture_fill_fraction`, and `head_liquid_height()` no longer takes a working
  volume.
- `just check-vessels` and `scripts/check-vessels.sh`: `just check-echo` sweeps the same 15 cells,
  pins each failing cell's assert message and fails when a vessel stops or starts building. The
  gate goes from 462 s to 348 s.
- `frame_light_pocket_allowance()`, which nothing read once the pump mount took plain numbers, and
  the pump mount's debug echo and side-rib assert.
- `just check-seams`, `just check-seams-update`, `scripts/check-seams.sh` and `tests/seams.txt`:
  `just test` is back to `check-mesh` and `check-holes`, no longer spending the twenty minutes
  `check-seams` added, and `TODO.md` closes the item on its cost.
- `dovetail_pts()`, which returned the same points as `trapezium_pts()`; `dovetail()` draws
  `trapezium()` from its root to its crown, and its renders are unchanged.
- `TODO.md`: its open work is tracked in issues, and the docs, `purchased-parts.csv` and
  `head.scad` point at those issues or at the doc that answers instead.
- The column lid spike in `scad/_spikes/column_lid/` and `just column-lid`, which move to their
  own repository, uwo-fast/column-bioreactor, built on bayonet-port-scad `v0.1.0`.
