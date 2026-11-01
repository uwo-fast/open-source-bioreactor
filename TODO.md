# TODO

Open work before the paper only. A finished item is deleted. What was decided, and what this
project got wrong on the way, is in `docs/decisions.md`; the reasoning behind a closed item is in
the commit that closed it and in `docs/`. Work planned for after the paper is a GitHub issue
labelled `post-pub`, all linked from #90; ideas nobody has planned are in `docs/future-work.md`.

## model completeness / enhancement

- [ ] **read the gas line on the pump, with a filter at each end**
  - the runs so far were fed from the building's air line; the paper's runs are on the ReSun pump.
    The reading that settles the line: the rotameter with the pump on, the needle valve wide open
    and a 1594522 on both the inlet and the outlet
  - the model says two filters do not work: they put the line at 32.4 kPa against a pump that
    dead-heads at 27, and it settles at 3.14 L/min, so 0.5 vvm stops being a setting it can hold.
    That rests on 3.45 kPa per L/min, extrapolated from an equivalent 0.2 um PTFE disc, because
    Cole-Parmer publish no pressure drop for 1594522. Fit `sparge_filter_drop_slope` to the reading;
    set `sparge_outlet_filter` and `head()` prices the outlet filter in
  - the operational number follows from the fitted slope: "fully open and it will not hold
    0.5 vvm" is the replace signal
  - record what the reading is taken on: the 5 L/min Dwyer VFA-23 on the BOM, or the 10 L/min meter
    also in use (its make and model off the label, as an alternate row), and the flow `jar_10L` is
    run at, which is the vvm the paper states
  - CO2 is answered by a run, not a calculation: air at 0.5 vvm supports about 0.09 g/L/day on a
    30 % utilisation assumption, and the 2026-07-23 run grew CPCC 90 for 8.7 days on air alone

- [ ] **watch the DO trace on `jar_10L` for spikes**
  - the reference build runs the loop, and `head()` puts the DO face 103.9 mm above it and 28.7 mm
    off its radius, out of its gas. A clean trace on a run closes this; the lean is the free
    variable if it is not

- [ ] **finish the wall baffle cage on `jar_10L`**
  - the cage went in with the loop and the lid, and the impeller turns clear of it, but some bottom
    bars sat loose and pushed in at their lower end. The hoops' channels are going from 0.15 to
    0.10 mm a side, with the blades' bars unchanged, and a bottom hoop at 0.10 is printing. Reprint
    the top hoop to match if it holds, which also replaces any top hoop printed before 3399521 with
    its arm at 0°; taller detents on the blades are the next lever if it does not
  - the loop inside it was run hard and did not turn on its riser
  - still to see: 10 min at 320 rpm with no blade crept inward
  - record in `docs/build.md` the fit and detents that held, and whether a hand reaches the bottom
    bars 240 mm down

## drive and aeration

Follows from the agitation work; reasoning and citations in `docs/agitation.md`.

- [ ] **run two Rushtons, the standard configuration**
  - a professor recommended the six-blade disc turbine (2026-10-08) and, on his advice
    (2026-10-13), the reference build runs a Rushton at both positions; the hybrid is in
    `docs/future-work.md`
  - his source, McCabe, Smith & Harriott 1993 ch. 9 (2026-10-14), gives the standard turbine's
    D = E = T/3 and the blades D/5 by D/4; in person he asked for two, the lower T/3 off the floor and
    the upper a further T/3 up, which is Rutherford's merging flow. Both are on the row now. Still
    to come: his written confirmation of the layout, asked for on 2026-10-14
  - if the paper states power: a bench measurement of the printed Rushton's power number,
    `Po = P/(rho N^3 D^5)` from shaft power at three or four speeds in water. The model keeps
    Kaiser's measured 4.17 where McCabe's Table 9.3 gives 5.75, 38% more power, and Grenville's
    flow number 0.65 where McCabe gives 1.3 (`docs/decisions.md`)
  - the row: height D/5, length D/4, disc 3D/4. Middleton & Ramshaw, US 5198156 "Agitators" (ICI,
    1993), gives exactly these as typical; the Czech standard behind Fořt's "standard Rushton" is
    ČSN 69 1021 (1984, withdrawn 2005), not read. Zhou 2003, which the row cites now, gives D/4 by
    D/4 and no disc. Po: keep Kaiser's measured 4.17 ± 0.14, with Grenville's typical 5.0 the
    spread; Fl 0.65 from Grenville, typical
  - printed as a split disc: two identical halves, each flat face down with no supports, held by two
    M4x6 set screws in its own hub and lined up by two 1.75 mm filament pins. Printed against a
    supported one-piece at 94.5 mm, the halves won, and a 70 mm pair printed and fitted;
    `impeller_split_disc` makes it the default

## exhaust condenser and humidifier

`head()` places the coil condenser on `air_out` wherever the sparger is not the ring
(`condenser_name`). The split cold finger and the humidifier cap print from their own files,
`custom/condenser_cold_finger.scad` and `custom/gl_port_cap.scad`.

- [ ] **bench-test the condensers, with the humidifier in line**
  - the test: a fixed flow, 48 h, the level marked (1 mm is 34.6 mL in the 210 mm bore), room and
    culture temperature logged. The one-piece cold finger, empty and then iced, is the baseline
  - run it with the humidifier bottle on the inlet. Air leaves the bottle saturated at its
    temperature and the condenser strips water back out at its own: exhaust colder than the bottle
    and the culture gains water, warmer and it loses it. The marked level says which, so the two are
    set together, not each to its own limit
  - untested on a print: the `large` and `xl` bayonets and their face rings, and the coil wound on
    the former with its ends formed on the pucks at 2 to 2.4x the tube's OD, which is tight for 3003.
    Two heads have now been wrong here - the first asked for a bend no tube can make, the second put
    the tube through a puck groove narrower than the tube - so measure the formed radius before
    committing a length
  - the flow insert's printed well is the only wall between coolant and gas: water-test it first, and
    feed it by gravity or through a valve on the inlet with the outlet draining freely
  - the aluminum coil never goes through the vessel's bleach step

## nice to haves

- [ ] **register the e-stop on `purchased-parts.csv` by model**: its row carries no part number or
      source, only the measured body the box was printed for
- [ ] **refresh the needle valve's and barbs' prices and links**: the August order had MNV-3KP at
      16.18 against the CSV's 15.11 and 11792-4-BLK at 1.54 against 0.60, both from direct product
      pages where the CSV carries a category page and a datasheet

## tooling / infrastructure / documentation

- [ ] **the probe port's transition lands exactly on the collet, and the obvious fix costs material**
  - `bayonet_probe_port`'s transition cone ends at exactly `-_transition_length`, which is exactly
    where the collet begins, at exactly the same diameter. Same defect as the three that are fixed,
    and on the leaning DO ports of several builds - five on this host - it leaves one or two
    near-degenerate triangles (two vertices 1e-5 apart) rather than a whole shared ring
  - carrying the cone on past the joint did clear it when measured, but it added 5.21 mm3, because
    the cone is solid out to the hex and the collet
    below it is not, so the lead lands as a 0.034 mm ledge across the collet's mouth where the
    probe body sits. Reverted for that reason
  - the direction that costs nothing is to carry the _collet_ up into the cone instead: the cone is
    wider there and solid, so the overlap adds no volume. That means reaching into
    `cylindrical_flex_collet`, whose body length also places its tabs, so it is not a one-liner
  - what is left is one or two triangles of zero volume in a closed mesh, and which side of the
    rounding they land on depends on the machine: the same part measures none here and one on the
    CI runner's CGAL. `export-parts` notes them and passes; it fails on a count that could only
    come from two solids sharing a face

- [ ] **where the tree breaks `docs/architecture.md`**
  - `head()` is one module in three sections - derived, checks and reports, geometry. The checks
    cannot become a module of their own without restating the derived values, since a module
    returns nothing; a split by subsystem is the next cut, and it is unsettled how the pieces
    share head.scad's parameters without reading each other
  - `custom/bayonet_interfaces.scad` includes `orings.scad` so rows can name their ring - rule 6
    allows it - and `bayonet_port.scad` then includes that file and receives every o-ring as a
    global. Recorded, not yet worth moving

- [ ] **printed bench parts are on no print list, and bench furniture is in no account**
  - `support/bottle_holder.scad` and `support/estop_box.scad` are the printed parts among the
    bench furniture; the cart prints nothing, and the stand's `print_corner` is a printed
    substitute for a bought NopSCADlib bracket. The condensers and the humidifier cap are printed
    outside the manifests too, each from its own file. `check-parts` records all of them
  - the questions: does the reactor's print list cover an accessory, and is printing that bracket
    deliberate? The cart's extrusion, brackets and castors are on no purchase list either

- [ ] **registry rows are read by position, and only their length is checked**
  - every `_by_name` wrapper passes `registry_by_name` its row's field count, and a lookup fails
    on any row of the wrong length. Two fields of the same type swapped still pass
  - `fan_by_name` reads NopSCADlib's rows and is not checked
