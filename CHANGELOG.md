# Changelog

All notable changes to this project are documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- CI runs `just check` and `just test` on OpenSCAD 2021.01, the oldest supported, as well as on the
  pinned snapshot; there `check-clash` and `check-baffle-cage` say SKIP, as 2021.01 has no manifold
  backend
- `dev/decisions.md` records that the gas line and the electronics on the purchase list stay off the
  CAD: neither has geometry to check against the vessel, head or frame, and the parts the gas line
  ends in (the sparge riser, sparger and condenser coil) are drawn

### Changed

- The sampler's case comes from uwo-fast/turbidity-sensor v0.3.0, which renames the sampler housing
  the sampler case (`hardware/sampler-case/sampler_case.scad`) and pins uwo-fast/syringe-actuator
  v0.1.1, whose lid gains a tab closing the barrel's slot. The sampler's printed base and top are
  unchanged; run `just setup` to install the new pins

### Fixed

- `head()` warns that the DO probe sits in the sparger's plume even when the upper impeller has no
  flow number; before, an impeller without one, such as `impeller_folded_axial_4`, silenced the
  warning
- `docs/ports-layout.md` gives the six-port lid's six locks, 60 deg apart, on the jars whose mouth is
  too small for twelve, and says every registered build that leans the DO probe leans it the full
  4.5 deg
- The ring sparger's figures in `docs/agitation.md` come from a build that builds (`jar_10L` with
  lid plates), `docs/references.md` names `do_probe_port_tilt_max` and calls 4.5 deg a ceiling, and
  the purchase list gives the sterile filter's drop as about 6.8 times the vessel's back-pressure, as
  `head()` reports, not twelve

## [0.1.0] - 2026-11-22

### Added

- A parametric OpenSCAD model of a jar bioreactor: `scad/bioreactor.scad` for the whole reactor,
  `scad/head.scad` for the lid and everything that hangs from it, and `scad/frame.scad` for the stand.
  Five glass jars from 1.5 L to 6.5 gal are registered; the reference build, the one the paper
  describes, is `jar_10L_220x305`; the acrylic column reactor is uwo-fast/column-bioreactor
- Nine registered builds in `scad/bioreactor.json`, each a vessel and what it designates by name
  (drive, sparger, baffles, condenser, heating pad, probes, motor), with a Customizer parameter set
  per vessel for `head.scad` and `frame.scad`
- Four drives, picked with `drive_name`: `shaft`, a top-entry shaft from a motor mount on the lid;
  `magnetic`, a stir carrier and hub cap under a base slotted for it, on a riser under
  `jar_1gal_155` and `jar_6p5gal`; `none`; and `airlift`, a standing draft tube. The 1.5 L and the
  155 mm 1 gal jars build as airlifts or magnetic, as their lids cannot carry the shaft
- The printed lid, in one piece: flange, plug, bearing pocket, heat-set insert holes, a recess for
  the rim gasket and a groove for the plug o-ring, and twelve bayonet ports, or six on a jar whose
  mouth is too small for twelve. `lid_center_name` picks a lid that takes either drive, closed by a
  printed bearing blank under the magnetic drive, or a plain one
- Port pins for the lid, each engraved with what it carries: tube ports for the gas and dosing lines,
  probe ports with flex collets for the Atlas DO and pH probes, with the DO probe leaned as far as
  the jar allows, a thermocouple port with an NPT mount, and a `BLANK` pin for each port size
- Two Rushton turbines on the reference build's shaft, each printed as two halves of one part, and a
  registry of impellers, pitched-blade pairs among them, sized against the jar's bore
- Baffles: four blades on a wall cage, a top and bottom hoop lowered into the jar whole, on the
  `jar_10L` builds; lid-hung plates on the other twelve-port lids, split with a sliding dovetail
  where a plate would be too slender to print standing, and none on the six-port lids
- Three spargers, picked with `sparger_name`, each drilled with 1.2 mm holes and fed by a steel
  riser sealed where it passes the lid: an arm under the lower impeller (the default), a ring (the
  default under no drive and the airlift) and a pigtail loop; and a bench puck to measure what a
  sparger's outlet face costs
- An exhaust coil condenser on `air_out`, in five printed parts, on every build whose sparger is not
  the ring; a cold-finger variant and a GL45 humidifier cap threaded to DIN 168 print from their
  own files
- A turbidity sampler on the twelve-port lids, opposite the condenser, with its dip tube ending open
  at the culture's mid-depth and its bought parts drawn in place. Its housing comes from
  uwo-fast/turbidity-sensor v0.1.0, which carries the uwo-fast/syringe-actuator v0.1.0 actuator
  for the 5ml-gnr2 syringe
- The frame: base, top base, eight ribs, twelve rod spacers, strip lights in a layout each build
  sets (the 10 L builds run 2 x 4), two 12 V silicone heating pads on the glass on the `jar_10L`
  builds, and three dosing pump mounts on the top rib level
- Bench parts beside the reactor: bottle holders, a two-piece box for a panel-mount e-stop, an
  electronics stand with a printed corner bracket, and a model of an equipment cart for four reactors
- A three-part gasket cutter, whose base is printed once and whose disc and plate are reprinted
  for each jar
- Purchased parts as registered rows that drive the geometry (`scad/purchased/`): jars, motors,
  thermocouples, gasket sheet, inserts, tubes, lights, heating pads, the gas train and printers;
  the Atlas probes and o-rings are bayonet-port-scad's
- An engineering report in each build's echo, from cited correlations: power number, blend time,
  kLa, off-bottom clearance, baffle area and the plate's deflection, the gas line's back-pressure
  budget, the DO probe's place against the sparger's plume, and whether each part fits the
  registered printers. Asserts refuse geometry that cannot be built, such as an impeller wider
  than the jar's mouth
- `purchased-parts.csv`, the purchase list for every build, priced and split by scope (reactor,
  sampler, bench, tooling); `just cost` totals it by scope and currency, or in CAD at a given rate
- `just export-parts`, every printed part of a build as an STL with a print list, or every build by
  vessel with the parts they share written once, each rendered and checked for a manifold;
  `just export-part` for one part, and `just export-accessories` for the bench parts. CI exports the
  two 10 L builds on every tag and on demand
- `just render`, pictures of the views `scad/views.tsv` lists, exploded views of the drive stack and
  the lid's ports among them, and `just render-parts`, every printed part of a build on its own
- `just check` gates: formatting and lint, every SCAD file evaluated, echo transcripts pinned for
  every registered build, the parameter sets, the builds, designations, the purchase list against
  the model, prices, the print list against the printed parts, and Customizer descriptions
- `just test`, the slow checks: meshes, gas holes that break through, the condenser and sampler
  against the lid, and the wall cage sliding, stopping, holding and clearing the glass. The gates
  name the OpenSCAD they run on and refuse one older than 2021.01, the oldest supported
- `just setup`, which installs the OpenSCAD libraries with scadman at the revisions `scadman.lock`
  pins; the bayonet ports come from CameronBrooks11/bayonet-port-scad v0.1.0
- Documentation: how to build it (`docs/build.md`), the first run (`docs/commissioning.md`), the
  design conventions, the baseline and its knobs, the agitation basis, the port layout, how the
  bought parts were chosen and the references; for contributors, `dev/architecture.md`,
  `dev/decisions.md` and `dev/future-work.md`
- `analysis/`: reproducible pipelines for two culture runs (2024-11-19 microalgae, 2026-07-23
  Chlorella CPCC 90) and the light irradiance measurement, and the sparge puck's bench protocol
- The design licensed GPL-3.0-or-later and the measurement data CC-BY-4.0 (`LICENSING.md`), and a
  `CITATION.cff`
