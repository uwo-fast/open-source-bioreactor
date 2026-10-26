# TODO

Open work only. A finished item is deleted. What was decided, and what this project got wrong on
the way, is in `docs/decisions.md`; the reasoning behind a closed item is in the commit that
closed it and in `docs/`.

## model completeness / enhancement

- [ ] **place the bought pumps in the assembly**
  - the registry half is done: `purchased/peri_pumps.scad` carries the Kamoer NKP-DC-S10B, drawn
    as its envelope, and `head()` warns when its tube's bore will not grip the riser it goes over
  - `custom/peri_pump_frame_mount.scad`'s insert now clicks into an empty light pocket in a rib
    (a detent under the rib), but its flange still assumes the old printed head: a motor on no
    purchase list, a faceplate a snap-in Kamoer has not got. A bought unit wants a bracket for a
    67 x 55 x 41 body on that insert
  - and the frame needs somewhere to put three of them: pockets, a rail, or the electronics stand.
    Nothing else waits on it - the reference run had the dose pumps disabled

- [ ] **measured gas flow**
  - the model states a vvm and no builder can set one: the ReSun pump settles at 5.78 L/min where
    0.817-4.09 is wanted. The aeration a culture wants runs 0.1-1 vvm depending on what it is for;
    the model's band stops at 0.5, and this pump and filter reach about 0.7 on `jar_10L`, which is
    enough for now. The parts are in the BOM (Dwyer VFA-23 meter, Clippard MNV-3KP needle
    valve upstream of it; why these, `docs/procurement.md`). What is left is buying them and taking
    a reading
  - no sparger geometry waits on it: `sparge_design_vvm` appears only in echoes. The arm the stirred
    builds take runs its 10 x 1 mm holes at 8.67 m/s at 0.5 vvm on `jar_10L`, outside Barbosa's
    tested 0.4-5.4 m/s, and `head()` warns; on `jar_1gal_180` the same arm runs 11 holes at
    3.42 m/s, inside it
  - CO2 is answered by a run, not a calculation: air at 0.5 vvm supports about 0.09 g/L/day on a
    30 % utilisation assumption, and the 2026-07-23 run grew CPCC 90 for 8.7 days on air alone. The
    reactor's actual CO2 utilisation is the measurable unknown, and the bigger lever on productivity

- [ ] **choose an outlet filter that fits in the budget `head()` reports**
  - the exhaust is unguarded: the headspace vents through the coil condenser into the room. A second
    1594522 on the outlet does not work: two put the line at 32.4 kPa against a pump that dead-heads
    at 27 and it settles at 3.14 L/min, and 0.5 vvm stops being a setting it can hold
  - `head()` reports the budget instead: at most 1.707 kPa per L/min on `jar_10L`, 49.5 % of the
    inlet filter's slope, net of the coil condenser's outlet, which is priced into the line. Set
    `sparge_outlet_filter` and `head()` prices the filter in too
  - the budget moves with the inlet filter's slope, which is extrapolated - measure that first
  - a trap or a longer tube would guard against splashback with no drop; a different sterility claim

- [ ] **measure the sterile filter's pressure drop**
  - 3.45 kPa per L/min is extrapolated from an equivalent 0.2 um PTFE disc, and is the largest
    single term in the gas budget. Area-correcting Pall's Acro 50 gives 3.02, so it sits 14 %
    conservative
  - a water manometer at two points, 1 and 2 L/min (35 and 70 cm of column), tests the slope and
    the linearity both. Not at the set flow: 14.1 kPa is 1.44 m of water
  - the operational number: the filter may rise to 21.2 kPa with the valve wide open before
    0.5 vvm is unreachable, so "fully open and it will not hold 0.5 vvm" is the replace signal

- [ ] **the tube seal goes in by hand; getting it back out is untested**
  - the 4x1.5 EPDM folds into its enclosed groove on a printed port, so the gland stands as built
  - untested on the same print: whether the steel tube pushes the ring out or nicks it going in,
    and whether the ring comes out for cleaning without a tool that scars the bore. If removal
    needs a pick, the build notes need to say so

- [ ] **re-print the ports and bench-check the gland, the flange gaps and the sparge socket**
  - the gland now carries `bayonet_gland_allowance` 0.2 (the 23x1.5 would not go into a groove cut
    at exactly its OD) and the flange lips are 1.0-1.2 mm. Neither is measured against a printer:
    print a std port, fit the rings, and key the allowance to a caliper reading. Every registered
    lid is on std now; a mini port only matters if that interface is wanted again
  - the sparge sockets are bored 0.2 mm over the 4 mm riser (`sparge_socket_allow`); nobody has
    pushed a tube into a printed one yet
  - `jar_10L` carries the twelve-port set on 0.0466 mm of slack: the worst adjacent pair is
    1.0466 mm against a `lid_flange_gap` of 1.0. The next flange lip that grows moves it to the
    six-port set
  - unpriced: whether 1.0466 mm between two 5 mm flanges is enough to get a cloth into. The lever
    is a thinner cord: a 23x1 EPDM (McMaster 8785N348, not registered) takes the groove to
    Ø25.2 at 0.25 mm of squeeze
  - the lid is where cleaning matters most. In photos of past cultures the buildup is high in the
    culture, in the headspace and on the lid, with almost none low down on the sparger and probes

- [ ] **model the support tubes' discharge holes, or decide not to**
  - every tube port but `air_in` is capped at its lower end and vents through a hole drilled up its
    length. `head()` reports the window (37.9-88.4 mm from the top on `jar_10L`) and `docs/build.md`
    says which end each port wants; the hole itself is a bench operation and is not drawn
  - only `air_out`'s hole has a size to meet, and only where no condenser takes that port, which
    today is the ring's builds; `head()` prices it there. A normal file cut clears it several
    times over; a shallow pass that just breaks the wall does not
  - not parameterised on purpose: a default for a hand-cut window would be a guess

- [ ] **whether the loop earns its one-riser hang**
  - `jar_10L_220x305` runs it, inside the wall cage, where it is set by its own hook at 76.54 mm
    and stands 19.3 mm inside the cage's bars; nothing hangs near it. Every other stirred build
    keeps the arm. Under lid plates, as on `jar_10L_magnetic`, it sits 1.25 mm inside them once
    they and its riser have leaned, and `head()` warns that 0.467 N sideways closes that, against a
    flow force nobody has measured
  - the swirl is the likelier load: its torque on a C round the shaft turns the loop about its
    riser, held only by the port's seal, and as little as 1.27° closes the same gap. Nothing prices
    that; a key or flat on the riser in its port would stop it if the bench shows it turning
  - on the bench, under lid plates, it held off them, and all eight 3 mm holes bubbled with the
    C level (#70). It now drills sixteen 1 mm holes, open area ratio 1.00 on its one bore; count
    them again, and watch for it turning on its riser in the cage build

- [ ] **where the sparger's gas actually goes, and whether the DO probe should move**
  - only for a stirred build given the ring (`sparger_name = "ring"`), which no registered build
    takes: `jar_10L_220x305` runs the loop, the other stirred builds the arm, and the airlift hangs
    DO straight inside its tube
  - there the DO face sits 20.6 mm above the sparge ring's centreline and 0.59 mm off its radius on
    `jar_10L`, over a ring of bubbles in the convergence zone: the one placement that can read wrong
    both ways. The loop gets the same report, and on `jar_10L_220x305` puts the face 103.9 mm
    above it and 28.7 mm off its radius, out of its gas
  - the flow rate is not the concern (bulk mean 16x what the probe needs); the gas path is not
    modelled, and no source found gives DO placement relative to a sparger
  - a bench question: run it and see whether the DO trace is spiky. If it matters, the free
    variables are the lean and the ring's height, both parameters already

- [ ] **bench the wall baffle cage on `jar_10L`**
  - the first print slid and held, but its slide was loose, and so was the 0° joint, where the
    hoops' C ended at the dovetail's lip; the fit is now 0.15 mm a side, the detents 0.5 mm, and
    the gap starts past that lip's ramp, at 17°
  - a blade could also slide through its hoop into the middle; each bar's outer end is now closed
    under the flange and stops against the hoop; and a third detent at each bar's tip clicks in
    inside the hoop, so with the out-detent the blade is held out both ways, each steep on the face
    toward the hoop
  - print one top hoop and one blade first: the bar slides free between its detents and needs a
    firm push and a click through each; then the whole cage through the mouth, the blades out, the
    lid on with the air inlet's riser in the arm's slot; then 10 min at 320 rpm with no blade crept inward
  - the slide fit (0.15 mm a side) and the detents' 0.5 mm are guesses until that; the steps are in
    `docs/build.md`
  - every other build still hangs lid plates: each needs the cage checked against its jar before it
    can name `baffle_name = "wall"`, and the magnetic, airlift and ring builds are refused today

- [ ] **measure what a printed sparge face costs, before any reactor sparger changes**
  - `custom/sparge_puck.scad` prints one outlet face per puck; the bench run is `docs/build.md`'s
    _The sparge test pucks_
  - a porous face is priced by one borrowed point: Pálfy et al.'s membrane carried linearly to
    4 L/min wants 15 times the open area of a 52.8 mm face, and at that size the pump would push
    about 0.28 L/min through it; the render's warning gives both. Linear is an assumption a
    three-flow reading settles
  - finer holes buy little on their own: the bubble floor goes as the cube root of the hole, and
    near an impeller hole size has a negligible effect (Rewatkar & Joshi 1993, in 0.57-1.5 m
    vessels). So a finer face is the airlift ring's question first, not the arm's
  - closes with a measured row per face that `head()` prices in the gas line, as it does the filter

- [ ] **on `jar_10L` the lid plates' width is the lean's to give back** (the magnetic build and
      head.scad's own default; the shaft reference build carries the wall cage)
  - the plate is sized to keep 1 mm running to the blades after 2.27722 mm of lean: 3.27722 nominal,
    11.9456 mm wide. The ring's 10.3454 mm bound applies only where the ring is built, and
    `jar_1gal_180` is at the lock bore's 17.0892
  - the price is still area: 0.499 of Oldshue's four-at-T/12 at three plates, which gave their
    fourth port to a sampling line. The impeller alone would allow 14.5 mm (0.606), at -0.28 running
    in the worst case. The tip ring is off and stays a flag (`docs/decisions.md`)
  - the 2.28 mm lean is a worst case - bore play alone, levered 11.4x, ignoring the flange's face
    contact - so measuring it (the bench list in `docs/build.md`) is the cheapest width there is
  - fixes, cheapest first, costed against the old 15.3 mm plate: taper the plate's inner edge with
    depth; deepen the bayonet engagement to 36 mm (halves the lean, adds a third joint); a
    baffle-only interface row at 0.1 mm allowance (a tight bayonet twisted by hand in a jar)

## drive and aeration

Follows from the agitation work; reasoning and citations in `docs/agitation.md`.

- [ ] **two things to confirm on the drive before ordering it**
  - the encoder sheet for `motor_36pg_555pm_14_en` tabulates no gearbox length; 34.5 mm is inferred
    from the 3429 sheet at 14:1. It feeds the envelope (581.25 mm) and the cart's tiers
  - caliper the bolt circle on the printed mount: Ø28 with M4 should clear holes cut for the
    36GP's Ø27.6 / 4.2, so the new motor may drop in without a reprint

- [ ] **bench-measure the twisted paddle's power number, if it is wanted back**
  - the build runs `impeller_rushton_6` now; the twisted row stays registered with no Po any
    correlation reaches, and its 0.634921 width ratio is the one unsourced ratio in `impellers.scad`
  - `Po = P/(rho N^3 D^5)` from shaft power at three or four speeds in water settles it. Worth
    doing to publish the blade, not to build the reactor. Kumaresan & Joshi 2006
    (doi:10.1016/j.cej.2005.10.002) is paywalled and may say something

- [ ] **run two Rushtons, the standard configuration**
  - a professor recommended the six-blade disc turbine (2026-10-08). Asked which limits his
    microalgae cultures, he answered light usually, CO2 supply can, O2 removal is secondary. The
    hybrid below answers that split, but the paper sets out to prove a standard design, so on his
    advice (2026-10-13) the reference build runs a Rushton at both positions and the hybrid waits
  - his source, McCabe, Smith & Harriott 1993 ch. 9 (2026-10-14), gives the standard turbine's
    D = E = T/3 and the blades D/5 by D/4; in person he asked for two, the lower T/3 off the floor and
    the upper a further T/3 up, which is Rutherford's merging flow. Both are on the row now, and
    his written confirmation of the layout was asked for on 2026-10-14
  - still to come: a bench measurement of the printed Rushton's power number,
    `Po = P/(rho N^3 D^5)` from shaft power at three or four speeds in water. The model keeps
    Kaiser's measured 4.17 where McCabe's Table 9.3 gives 5.75, 38% more power, and Grenville's
    flow number 0.65 where McCabe gives 1.3 (`docs/decisions.md`)
  - the row: height D/5, length D/4, disc 3D/4. Middleton & Ramshaw, US 5198156 "Agitators" (ICI,
    1993), gives exactly these as typical; the Czech standard behind Fořt's "standard Rushton" is
    ČSN 69 1021 (1984, withdrawn 2005), not read. Zhou 2003, which the row cites now, gives D/4 by
    D/4 and no disc. Po: keep Kaiser's measured 4.17 ± 0.14, with Grenville's typical 5.0 the
    spread; Fl 0.65 from Grenville, typical
  - **printing it.** Standing on its blades, the disc's underside from the hub to the blades' roots
    (r 10-23.6 mm, 1714 mm2) is held only by the hub and needs supports, which leave that face
    rough; a professor called it unprintable as drawn. A spike splits it at the disc's mid-plane
    into two identical halves, each printed flat face down (1.2 mm of disc on the bed, blades and
    hub up), no supports. The pair less the one-piece turbine is 0.0 mm3; the one-piece less the
    pair is 248 mm3, the holes. Each half holds itself with two M4x6 set screws in its own hub at
    30 and 150 deg, between the blades, 5.3 mm up from the joint, and no collar; two 2 mm holes,
    4 mm deep at r 7.1 and 90/270 deg, take 1.75 mm filament pins to line the blades up. The
    cost is a clamped seam through the disc to clean. Done: printed against a supported one-piece
    at 94.5 mm, the halves won, and a 70 mm pair printed and fitted; `impeller_split_disc` now
    makes it the default, with no collar and the screws 4.1 mm up from the joint at 70 mm

## exhaust condenser and humidifier

`head()` places the coil condenser on `air_out` wherever the sparger is not the ring
(`condenser_name`). The split cold finger and the humidifier cap print from their own files,
`custom/condenser_cold_finger.scad` and `custom/gl_port_cap.scad`.

- [ ] **bench-test the condensers, then place the one that works**
  - the test: a fixed flow, 48 h, the level marked (1 mm is 34.6 mL in the 210 mm bore), room and
    culture temperature logged. The one-piece cold finger, empty and then iced, is the baseline
  - untested on a print: the `large` and `xl` bayonets and their face rings, and the coil wound on
    the former with its ends formed on the pucks at 2 to 2.4x the tube's OD, which is tight for 3003.
    Two heads have now been wrong here - the first asked for a bend no tube can make, the second put
    the tube through a puck groove narrower than the tube - so measure the formed radius before
    committing a length
  - the flow insert's printed well is the only wall between coolant and gas: water-test it first, and
    feed it by gravity or through a valve on the inlet with the outlet draining freely
  - the aluminum coil never goes through the vessel's bleach step

- [ ] **offer the split cold finger beside the coil in `head()`**
  - the coil is placed: its body is `air_out`'s pin, the port carries no tube, and the gas line
    prices its 4.5 mm outlet, 30.5 Pa at 4.09 L/min on `jar_10L`, where the slot and tube cost
    178-209. Intersected with the probes, the port pins, the motor mount and the motor, it touches
    none of them on `jar_10L`, `jar_1gal_180x197` or `jar_6p5gal`; no assert holds that yet
  - the split cold finger is the second `condenser_name`. The one-piece cold finger stays an option
    inside its own file only: nothing prints it, and it should not reach `head()` or
    `bioreactor.scad`

- [ ] **fit the humidifier cap to the bottle, and set it against the condenser**
  - the rim gasket's 34 mm bore is an estimate: caliper the bottle's rim. Try a short `din168_nut`
    ring on the bottle's thread before printing the whole cap
  - a condenser that cools the exhaust below the humidified inlet's dew point makes the culture gain
    water, so the two are set together, not each to its own limit

## turbidity sampler

`head()` places it on the full lid's port 10, at 300 degrees, and derives its riser's cut and
drilling.

- [ ] **what `head()` still does not own of the sampler**
  - the inserts, which a custom part may not read (`docs/architecture.md`): `custom/sampler.scad`
    still includes `purchased/heat_set_inserts.scad`
  - the lid clash and the ±30 degree twist: intersected with the probes, the port pins, the baffle
    pins, the motor mount, the motor and the condenser on `jar_10L` and `jar_1gal_180x197`, it
    touches none of them at -30, 0 or 30 degrees; at 330 degrees it ran into the condenser. No
    assert holds that yet

- [ ] **what the sampler still has to prove on the bench**
  - the bushing's seal under the syringe's suction, and the 40 mm sampling depth
  - the clear tube's McMaster part number: the one fitted is believed to be FEP from there

## alternative agitation modes

`jar_1p5L` and `jar_1gal_155` cannot carry a top-entry drive at any mount size, nor four baffles
beside two Ø16 probes at any port count, so both are registered as airlifts, and both with the
magnetic drive on a plain lid. Why, and what the three modes are, is
`docs/agitation.md` section 5.

- [ ] **the airlift is modelled; what is left is the bench**
  - `drive_name = "airlift"` builds it on `jar_1p5L` and `jar_1gal_155`: a clear draft tube on
    three feet, sparged inside by the ring, which centres it. `docs/build.md` has the assembly
  - measure the loop: a dye pulse or a float gives the circulation time and the downcomer's
    velocity, which no correlation in `docs/references.md` reaches at under 0.2 m tall
  - watch the DO reading hanging straight: the lean it no longer has was for a shaft's shadow, and
    the riser should carry flow past it, but that is the bench's to confirm
  - how it is held: the ring centres it, to 1.25 mm where the ring sits inside the wall
    (`jar_1p5L`) and 2.5 mm where it sits among the feet (`jar_1gal_155`); its weight holds it
    down, about 20 g net under water if printed solid, and nothing stops it turning or lifting. The
    bench says whether that is enough; the item below is what follows if not
  - `jar_1gal_180x197` and `jar_10L` do not build as airlifts: the tube stands where their baffles
    hang. Neither is registered
  - `jar_6p5gal` does not build as one: the equal-area gap stands its tube on 126 mm feet, 73 mm
    long in 325 mm of culture, and `draft_tube_span_min` (0.5 of the depth, a judgement) refuses
    it. Not registered

- [ ] **the annulus-sparged airlift (B), if the bench asks for it**
  - the tube as downcomer, the annulus as riser, bubbles up the lit wall. Wants a sparger outside
    the tube, which the mouth-limited ring cannot reach, and Chisti & Moo-Young 1987 recommend a
    cone under the turn for it (`docs/references.md`)

- [ ] **fix the draft tube, if standing it proves loose**
  - a plain lid leaves its centre free; a bayonet there, as the other ports carry what hangs from
    them, would locate the tube from above rather than by the ring's clearance
  - or shape each foot to capture the ring, so the ring holds the tube down and centred with no
    new part

- [ ] **the magnetic drive is modelled; what is left is the bench**
  - `drive_name = "magnetic"` builds it: a fan picked by rule in a carrier hung in the base bore,
    two magnets in a cap on its hub, a stir bar centred on the punt; the base is slotted for it
    under either drive, or the riser is where a build stands on one. `docs/build.md` has the
    assembly
  - nothing models the coupling. How much torque two 8 x 5 discs hand a 38 mm bar through 1 mm of
    air and 3-5 mm of glass, and at what fan speed the bar decouples, are measurements; the sizes are
    parameters so the answer can be put in. The target is the shaft drive's torque at equal tip
    speed, `v^2 D^3` scaled: 4.8-12.3 mN.m for the pair on `jar_1p5L`, 15.3-39.6 on `jar_1gal_155`
  - speed is PWM on the fan's own line and nothing reads it back; a 3-wire fan's tachometer line
    is the only encoder this drive has
  - centred, on the punt, was the decision: eccentric has nothing locating it on a floor whose high
    point is the centre it avoids, and Galletti finds it unsteady with power rising with eccentricity
  - the floor under the jar is sunk for the fan the bore admits, so a jar whose light happens to
    be short is not left without a drive. `jar_1p5L` is 3.77 mm deeper for it and gains a carrier;
    `jar_6p5gal` and `jar_1gal_155` want far more than `carrier_floor_lift_max` allows, so their
    magnetic builds stand on a riser instead (`docs/build.md`)

- [ ] **`jar_6p5gal` is not a floor problem and a deeper floor will not fix it**
  - a magnetic build of it now stands on a 35 mm riser and builds, coupling across the 13 mm
    below; it is not registered
  - its punt rises 15 mm at the magnets' radius and the carrier may not stand above the plane the
    jar lands on, so the hub cap grows 8 mm into the punt's void and the magnets reach 1 mm under
    the punt. Its 12 mm wall still puts them 13 mm from the culture, against 4-6 mm on every other
    jar
  - a 39 mm floor would seat a 120 x 25 at a 29 mm pitch, the best pitch of any jar, and it would
    still be coupling across those 13 mm
  - what would change it now is larger magnets, which is its own decision

## nice to haves

- [ ] **register the e-stop on `purchased-parts.csv` by model**: its row carries no part number or
      source, only the measured body the box was printed for

- [ ] a lead-in at the mouth of the bayonet tube bore, to ease the tube past the rod gland's o-ring
      without nicking it; the gland does the gripping now
- [ ] **back-plug the Atlas probe bore, or accept that the probe body is the seal**
  - the connector hex opens straight through to atmosphere (64 mm2); the probe body closes it by
    grip, not seal, and self-seals well enough on the bench. If a fix is ever wanted it is hot glue
    at the hex, not a modelled gland. Look at it with the sensor-gland item
- [ ] optional end styles (sensor gland) for atlas probes to match product more closely

## tooling / infrastructure / documentation

- [ ] **the DO probe's lean is capped by impellers a non-shaft build does not have**
  - `head_probe_tilt_ceiling()` reads `head_reach_obstacles()`, which lists both impellers under
    every drive; `head()` drops them from its own clearance report but not from the ceiling. Latent:
    every magnetic build reaches the full 4.5 deg today, and the airlift hangs DO straight without
    asking the ceiling. Safe either way, since the lean only comes out smaller
  - nothing reachable shows it: allowed 15 deg, `jar_10L` stops at 4.67 deg on its shaft and
    magnetic builds alike, with the impellers counted or not and even raised to 2.5 D, so
    something else binds first. Worth fixing when a build makes the impellers bind, with that
    build as the test

- [ ] **the port lettering is not pinned to a font, so it is whatever the host resolves `sans` to**
  - `scad/custom/bayonet_port.scad` asks for `font="sans"` in three places (:324, :332, :509).
    `sans` is a fontconfig alias, not a face, so the glyphs are whatever that host happens to
    prefer: here `fc-match sans` gives Noto Sans, with Liberation Sans also installed. The CI
    artifact's lettering was seen to differ from the bench's for exactly this reason
  - pinning it to one installed face makes the exported STL the same everywhere. It moves every
    port's mesh, so it wants its own commit
  - it is cosmetic - the lettering says which port is which - but a figure that changes with the
    machine is the kind of thing this project pins everywhere else

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
  - `custom/sampler.scad` includes `purchased/heat_set_inserts.scad` until `head()` places it and
    passes the inserts in (see the turbidity sampler)

- [ ] **the three stirred jars carry a second impeller the spacing does not support**
  - Fitschen eq. (5), `(H-d)/d > n > (H-2d)/(2d)`, in impeller diameters, on the jars that take the
    shaft drive (the two narrow jars build as airlift or magnetic):

    | vessel             | H_L    | d = 0.45 T | H_L/d | H/T   | band allows |
    | ------------------ | ------ | ---------- | ----- | ----- | ----------- |
    | jar_10L_220x305    | 229.50 | 94.50      | 2.429 | 1.093 | n = 1       |
    | jar_1gal_180x197   | 153.36 | 76.50      | 2.005 | 0.902 | n = 1       |
    | jar_6p5gal_305x470 | 325.26 | 126.36     | 2.574 | 1.158 | n = 1       |

  - it correlates with coverage: every jar the band puts at one impeller is spending coverage on
    the pair; `jar_1gal_180x197` at 0.107 D against the 0.5 D floor is the worst
  - no primary stands behind the rule, so `head()` reports and nothing asserts
  - the count stays two: the sparge ring sits in the gap, the power is per pair, the manifest lists
    two, and the reference build physically exists. Changing it unpicks all of that

- [ ] **the ring's bore is the departure, not its holes, and it is more than one designation**
  - on `jar_10L` given the ring (the stirred default is the arm), at its 4.11 L/min, sweeping the
    bore with 8 x 3 mm holes held. With 16 x 1 mm holes the 4.0 mm row is 5.42 m/s at an open
    area of 1.00, and a hole's 49 Pa outweighs the 17.7 Pa of velocity head, so the bore is no
    longer a departure on its own; the sweep wants redoing at that size:

    | bore        | feed velocity | open area | velocity head | verdict                             |
    | ----------- | ------------- | --------- | ------------- | ----------------------------------- |
    | 4.0 (today) | 5.46 m/s      | 4.50      | 17.9 Pa       | 2 departures                        |
    | 8.0         | 1.36          | 1.12      | 1.1           | 1 departure; pH tip hits the ring   |
    | 8.5         | 1.21          | 1.00      | 0.9           | clean sparger; pH tip hits the ring |
    | 10.0        | 0.87          | 0.72      | 0.5           | no room for a baffle                |

  - `sparge_bore()` is the riser's own OD, so the bore is a designation:
    `steel_tube_welded_10x0p5` is registered; there is no 8.5 row
  - what it costs is the cascade: the tube goes 6.4 -> 12.4 across the flats, and past 8 mm the
    wider ring meets the pH probe's tip and then leaves no room for a baffle; the riser's port
    bore, rod gland, pressure drop, support tube and BOM row all follow. Unpriced

- [ ] **`check-holes` still needs a CGAL render, so it stays outside `just check`**
  - both ends of every hole are probed - the arm's by default, the ring's with
    `-D head_sparger="ring"` - and it was proved by injection when written (a bore swept 180
    degrees failed 5 of 20 on `feed`). What would let it into the gate is a probe that needs no
    rendered mesh: the claim is geometric and the part is a union of primitives
  - `spoke_holes` is unprobed; no caller sets it and `sparger()` refuses the unbored-arm case

- [ ] **the sparger's two sockets are hard to tell apart**
  - both are 6.4 mm across the flats; the octagon's corners stand 0.264 mm proud of the round
    support. `docs/build.md` says count the facets. A print settles whether that is findable by
    hand; if not, a collar, a flat or a mark rather than a socket sized on its own

- [ ] **`check-scad`'s `-D '$fn=0'` pass is not the tessellation test it reads as**
  - a command-line `-D` crosses the `use` boundary on every version where an in-file assignment
    does not, so that pass also zeroes `sparger.scad`'s and the collet's own `$fn` - 48 and 64 in
    the CSG it renders, 96 and 128 in an exported part - and renders what no build renders. It
    still covers the crash a zero facet count causes
  - what would test divergence is rendering one part both ways at the CSG level
  - `OPENSCAD` is unset, so `just` runs whichever binary is first on PATH (2021.01 here, with a
    2026.09 nightly beside it). Worth pinning

- [ ] **the recess holds three quarters of the rubber, and it only matters on `jar_6p5gal`**
  - the recess is cut at `t(1-c)`, so `t*c` will not fit whatever the gasket. On a crown the
    displaced rubber flows into the width the contact chord never touches - on `jar_10L` 4.762 mm,
    about 0.857 mm2 against 1.890 free; on the one ground jar it must leave across the lands
  - `jar_6p5gal` also carries the registry's highest load, 1253.6 N per post and 7.34 MPa against
    398.8 and 2.92 on `jar_1gal_180`, the next highest. Reported, not asserted
  - the fix is a groove section 10-25 % over the gasket's; that jar offers 10 mm of rim where the
    gasket is held to 6. Not chased: it changes the lid for one jar

- [ ] **printed bench parts are on no print list, and bench furniture is in no account**
  - `support/bottle_holder.scad` and `support/estop_box.scad` are the printed parts among the
    bench furniture; the cart prints nothing, and the stand's `print_corner` is a printed
    substitute for a bought NopSCADlib bracket. The condensers, the humidifier cap and the pump
    mount are printed outside the manifests too, each from its own file. `check-parts` records all of them
  - the questions: does the reactor's print list cover an accessory, and is printing that bracket
    deliberate? The cart's extrusion, brackets and castors are on no purchase list either

- [ ] **designations for the pump and the inlet filter, if builds start to differ**
  - `head.scad` assigns hardware rows directly (`head_air_pump`, `sparge_inlet_filter`,
    `sparge_check_valve`, the clamp and the inserts among them) that no parameter set can change
  - the pump and the filter drive the gas budget, so they are the ones worth a `_name` designation
    first. Left until a build needs it

- [ ] **registry rows are read by position and not checked for shape**
  - `registry_by_name` checks the name only. A missing field shows as an undef warning, which
    `check-scad` fails on, but two fields of the same type swapped would pass
  - low risk; a row-length assert in each `_by_name` wrapper would close most of it

## long term / post paper submission

- [ ] **a Rushton under a pitched blade: the hybrid, set aside for a standard design**
  - `head()` takes a lower and an upper type, so it is one line away:
    `head_impeller_upper_type = impeller_pbt_45_4`. Modelled on jar_10L at 320 rpm: 4.76 W,
    0.193 N m summed, 0.5 vvm held to 147 rpm below and 287 rpm above. The case, from when it was
    the plan:
  - light usually limits, CO2 supply can (the professor's reply): light is circulation, the
    pitched blade's job; CO2 is dispersion, the Rushton's
  - **the gas ceiling binds inside the operating band.** `head()` checked Oldshue's 8x rule only
    at no-load (420 rpm, 1.573 vvm), and now checks it at each drive speed. The cap goes as N^3:
    0.70 vvm at the rated 320 rpm, 0.35 vvm at the 255 rpm Chlorella optimum, against the 0.5 vvm
    design; the crossover is about 287 rpm. A radial impeller at the same power, 3x not 8x, would
    hold about 0.94 vvm at 255 rpm
  - **circulation per watt**: about 1.8x in the pitched blade's favour at equal power and
    diameter, not the 4x `agitation.md` once claimed (`docs/decisions.md`)
  - **at equal power a Rushton is the gentler of the two**: peak dissipation goes as
    `x Po^(-1/4) D^-3`, so about 0.56x the pitched blade at the same diameter, about 1.4x at
    D = T/3. Both are orders of magnitude under any damage figure. Grenville's Figs. 6-7 have the
    Rushton making the largest drops at equal power (liquid-liquid, so indirect for gas): its gas
    advantage is holding its pattern under gas, not finer bubbles per watt
  - a Rushton as the lower impeller over the sparger arm, where the gas loads first and Oldshue
    puts 40 % of the dispersing work, the pitched blade above for circulation

- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based preview
