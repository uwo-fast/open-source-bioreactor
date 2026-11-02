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
  - the cage went in with the loop and the lid, and the impeller turns clear of it. At 0.15 mm a
    side some bottom bars pushed in at their lower end; a bottom hoop reprinted with 0.10 mm
    channels, the blades unchanged, holds them. Reprint the top hoop at 0.10 to match, which also
    replaces any top hoop printed before 3399521 with its arm at 0°
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
