# TODO

Open work only. A finished item is deleted. What was decided, and what this project got wrong on
the way, is in `docs/decisions.md`; the reasoning behind a closed item is in the commit that
closed it and in `docs/`.

## model completeness / enhancement

- [ ] **place the bought pumps in the assembly**
  - the registry half is done: `purchased/peri_pumps.scad` carries the Kamoer NKP-DC-S10B, drawn
    as its envelope, and `head()` checks its tube against the port it enters
  - `custom/peri_pump_frame_mount.scad`'s insert now clicks into an empty light pocket in a rib
    (a detent under the rib), but its flange still assumes the old printed head: a motor on no
    purchase list, a faceplate a snap-in Kamoer has not got. A bought unit wants a bracket for a
    67 x 55 x 41 body on that insert
  - and the frame needs somewhere to put three of them: pockets, a rail, or the electronics stand.
    Nothing else waits on it - the reference run had the dose pumps disabled

- [ ] **measured gas flow**
  - the model states a vvm and no builder can set one: the ReSun pump settles at 5.80 L/min where
    0.822-4.11 is wanted. The aeration a culture wants runs 0.1-1 vvm depending on what it is for;
    the model's band stops at 0.5, and this pump and filter reach about 0.7 on `jar_10L`, which is
    enough for now. The parts are in the BOM (Dwyer VFA-23 meter, Clippard MNV-3KP needle
    valve upstream of it; why these, `docs/procurement.md`). What is left is buying them and taking
    a reading
  - no sparger geometry waits on it: `sparge_design_vvm` appears only in echoes, and the 8 x 3 mm
    holes cover 0.25-2 vvm inside Barbosa's tested 0.4-5.4 m/s
  - CO2 is answered by a run, not a calculation: air at 0.5 vvm supports about 0.09 g/L/day on a
    30 % utilisation assumption, and the 2026-07-23 run grew CCPC 90 for 8.7 days on air alone. The
    reactor's actual CO2 utilisation is the measurable unknown, and the bigger lever on productivity

- [ ] **two of the five swept vessels do not render from `bioreactor.scad`**, both for the drive
  - `jar_1p5L_109x215`'s port flanges leave 27.1 mm against a 56 mm motor mount; the smallest
    registered motor plus two walls is 47.5 and still 8.2 short
  - `jar_1gal_155x251` fails on the pH probe (vertical, and the long one) running 6.29 mm through
    the lower impeller; no DO lean reaches that. The mount would fail next at -8.30 mm
  - the answer to both is a different agitation mode, under "alternative agitation modes"

- [ ] **choose an outlet filter that fits in the budget `head()` reports**
  - the exhaust is unguarded: the headspace vents through a support tube into the room. A second
    1594522 on the outlet does not work: two put the line at 32.5 kPa against a pump that dead-heads
    at 27 and it settles at 3.17 L/min, and 0.5 vvm stops being a setting it can hold
  - `head()` reports the budget instead: at most 1.70844 kPa per L/min on `jar_10L`, 49.5 % of the
    inlet filter's slope, net of the vent slot and the tube, which are priced into the line. Set
    `sparge_outlet_filter` and `head()` prices the filter in too
  - the budget moves with the inlet filter's slope, which is extrapolated - measure that first
  - a trap or a longer tube would guard against splashback with no drop; a different sterility claim

- [ ] **measure the sterile filter's pressure drop**
  - 3.45 kPa per L/min is extrapolated from an equivalent 0.2 um PTFE disc, and is the largest
    single term in the gas budget. Area-correcting Pall's Acro 50 gives 3.02, so it sits 14 %
    conservative
  - a water manometer at two points, 1 and 2 L/min (35 and 71 cm of column), tests the slope and
    the linearity both. Not at the set flow: 14.3 kPa is 1.46 m of water
  - the operational number: the filter may rise to 23.3 kPa with the valve wide open before
    0.5 vvm is unreachable, so "fully open and it will not hold 0.5 vvm" is the replace signal

- [ ] **the tube seal goes in by hand; getting it back out is untested**
  - the 4x1.5 EPDM folds into its enclosed groove on a printed port, so the gland stands as built
  - untested on the same print: whether the steel tube pushes the ring out or nicks it going in,
    and whether the ring comes out for cleaning without a tool that scars the bore. If removal
    needs a pick, the build notes need to say so

- [ ] **re-print the ports and bench-check the gland and the flange gaps**
  - the gland now carries `bayonet_gland_allowance` 0.2 (the 23x1.5 would not go into a groove cut
    at exactly its OD) and the flange lips are 1.0-1.2 mm. Neither is measured against a printer:
    print one std and one mini port, fit the rings, and key the allowance to a caliper reading
  - `jar_10L` carries the twelve-port set on 0.0466 mm of slack: the worst adjacent pair is
    1.0466 mm against a `lid_flange_gap` of 1.0. The next flange lip that grows moves it to the
    six-port set
  - unpriced: whether 1.0466 mm between two 5 mm flanges is enough to get a cloth into. The lever
    is a thinner cord: a 23x1 EPDM (McMaster 8785N348, not registered) takes the groove to
    Ø25.2 at 0.25 mm of squeeze

- [ ] **the sparge socket is cut at the riser's own diameter, with nothing to spare**
  - `sparge_feed_bore = steel_tube_od(sparge_riser_tube)`: a Ø4.0 socket for a Ø4.0 tube, with a
    0.5 mm lead-in that helps the tube find the hole but does not widen it
  - the fix is not free: the socket is the ring tube's own section, so opening the bore to 4.2
    thins `feed_wall` to 1.1 and trips `sparger()`'s assert. Clearance has to come from the
    section, 6.4 -> 6.6, which shrinks the ring radius ~0.1 mm and moves every hole
  - untested: nobody has pushed a 4 mm tube into a printed socket. One bench check settles it

- [ ] **model the support tubes' discharge holes, or decide not to**
  - every tube port but `air_in` is capped at the ring and vents through a hole drilled up its
    length. `head()` reports the window (37.9-88.7 mm from the top on `jar_10L`) and `docs/build.md`
    says which end each port wants; the hole itself is a bench operation and is not drawn
  - only `air_out`'s hole has a size to meet, and `head()` prices it: the floor is 1.055 mm2 on
    `jar_10L`, 0.288 on `jar_1gal_180x197`, none on `jar_6p5gal` (its line beats the pump). A normal
    file cut clears it nearly 7x; a shallow pass that just breaks the wall does not
  - not parameterised on purpose: a default for a hand-cut window would be a guess

- [ ] **where the sparger's gas actually goes, and whether the DO probe should move**
  - the DO face sits 20.6 mm above the sparge ring's centreline and 0.87 mm off its radius, over a
    ring of bubbles in the convergence zone: the one placement that can read wrong both ways
  - the flow rate is not the concern (bulk mean 16x what the probe needs); the gas path is not
    modelled, and no source found gives DO placement relative to a sparger
  - a bench question: run it and see whether the DO trace is spiky. If it matters, the free
    variables are the lean and the ring's height, both parameters already

- [ ] **the baffle clears the blades now, and baffle area paid for it**
  - running clearance is +1.80009 mm (4.07731 nominal less 2.27722 of lean), after the plate
    narrowed 15.3 -> 10.3454 mm and the mouth correction took 0.4 mm of it
  - the price: reference projected area 0.856 -> 0.579 of Oldshue's four-at-T/12; six plates reach
    only 0.868. Whether 0.579 is acceptable is the open question, and buying width back walks toward
    the blades. The tip ring is off and stays a flag (`docs/decisions.md`)
  - the 2.28 mm lean is a worst case - bore play alone, levered 11.4x, ignoring the flange's face
    contact - and only matters if the plate widens
  - fixes, cheapest first, costed against the old 15.3 mm plate: taper the plate's inner edge with
    depth; deepen the bayonet engagement to 36 mm (halves the lean, adds a third joint); a
    baffle-only interface row at 0.1 mm allowance (a tight bayonet twisted by hand in a jar)

## drive and aeration

Follows from the agitation work; reasoning and citations in `docs/agitation.md`.

- [ ] **two things to confirm on the drive before ordering it**
  - the encoder sheet for `motor_36pg_555pm_14_en` tabulates no gearbox length; 34.5 mm is inferred
    from the 3429 sheet at 14:1. It feeds the envelope (571.25 mm) and the cart's tiers
  - caliper the bolt circle on the printed mount: Ø28 with M4 should clear holes cut for the
    36GP's Ø27.6 / 4.2, so the new motor may drop in without a reprint

- [ ] **bench-measure the twisted paddle's power number, if it is wanted back**
  - the build runs `impeller_pbt_45_4` now; the twisted row stays registered with no Po any
    correlation reaches, and its 0.634921 width ratio is the one unsourced ratio in `impellers.scad`
  - `Po = P/(rho N^3 D^5)` from shaft power at three or four speeds in water settles it. Worth
    doing to publish the blade, not to build the reactor. Kumaresan & Joshi 2006
    (doi:10.1016/j.cej.2005.10.002) is paywalled and may say something

## exhaust condenser and humidifier

Printed from their own files, `custom/condenser_cold_finger.scad`, `custom/condenser_coil.scad` and
`custom/gl_port_cap.scad`; nothing in `head()` places them yet.

- [ ] **bench-test the condensers, then place the one that works**
  - the test: a fixed flow, 48 h, the level marked (1 mm is 34.6 mL in the 210 mm bore), room and
    culture temperature logged. The one-piece cold finger, empty and then iced, is the baseline
  - untested on a print: the `large` and `xl` bayonets and their face rings, and the coil wound on
    the mandrel and its ends formed on the puck at about 2x the tube's OD, which is tight for 3003.
    The first head cracked where it asked for a bend no tube can make; this one takes no bending
  - the flow insert's printed well is the only wall between coolant and gas: water-test it first, and
    feed it by gravity or through a valve on the inlet with the outlet draining freely
  - the aluminum coil never goes through the vessel's bleach step
  - placing one in `head()` replaces the `air_out` slot and tube the gas budget prices today, and
    renders its clearance to the motor mount and the probes, which is arithmetic until then

- [ ] **fit the humidifier cap to the bottle, and set it against the condenser**
  - the rim gasket's 34 mm bore is an estimate: caliper the bottle's rim. Try a short `din168_nut`
    ring on the bottle's thread before printing the whole cap
  - a condenser that cools the exhaust below the humidified inlet's dew point makes the culture gain
    water, so the two are set together, not each to its own limit

## alternative agitation modes

`jar_1p5L` and `jar_1gal_155` cannot carry a top-entry drive at any mount size, nor four baffles
beside two Ø16 probes at any port count. Why, and what the three modes are, is `docs/agitation.md`
section 5. Neither item is scheduled.

- [ ] **explore an airlift variant, with no impeller**
  - needs in the model: a draft tube as a part, riser and downcomer areas, superficial gas
    velocity, a reported circulation time. The sparge ring is this mode's sparger; the shaft and
    magnetic builds run the arm (`sparger_name`)
  - and the arm is the wrong sparger for the two jars this mode is FOR. Its reach is the port
    circle less the shaft, which on `jar_1gal_155` leaves 8.7 mm of bore and one hole at 2.9 hole
    diameters, on `jar_1p5L` 4.6 mm and 1.5 - both under the pitch floor, which head() warns on.
    Those jars want the ring, a stone, or an arm placed off something other than the shaft

- [ ] **the magnetic drive is modelled; what is left is the bench**
  - `drive_name = "magnetic"` builds it: a fan picked by rule in a carrier hung in the base bore,
    two magnets in a cap on its hub, a stir bar centred on the punt; the base is slotted for it
    under either drive. `docs/build.md` has the assembly
  - nothing models the coupling. How much torque two 8 x 5 discs hand a 38 mm bar through 1 mm of
    air and 5 of glass, and at what fan speed the bar decouples, are measurements; the sizes are
    parameters so the answer can be put in. The target is the shaft drive's torque at equal tip
    speed, `v^2 D^3` scaled: 4.8-12.3 mN.m for the pair on `jar_1p5L`, 15.3-39.6 on `jar_1gal_155`
  - speed is PWM on the fan's own line and nothing reads it back; a 3-wire fan's tachometer line
    is the only encoder this drive has
  - centred, on the punt, was the decision: eccentric has nothing locating it on a floor whose high
    point is the centre it avoids, and Galletti finds it unsteady with power rising with eccentricity
  - the floor under the jar is sunk for the fan the bore admits, so a jar whose light happens to
    be short is not left without a drive. `jar_1p5L` is 3.78 mm deeper for it and gains a carrier;
    `jar_6p5gal` and `jar_1gal_155` want far more than `carrier_floor_lift_max` allows and get
    none. Each of those two has its own item below

- [ ] **`jar_1gal_155` wants a magnetic drive and a 40 mm floor, and a base that deep wants hollowing**
  - it is one of the two jars that cannot carry a top-entry drive, and its coupling geometry is the
    best of any registered jar: a 3 mm wall and a 6 mm punt put the magnets 4 mm from the culture,
    against 6 mm on `jar_10L`
  - the floor it wants is 40 mm against the 2 the light leaves. Measured on the exported part, that
    takes the base from 234 to 1000 cm3 of solid - plus 766, or 327% - because the base is drawn
    solid, so the added depth is an annulus across the whole footprint rather than a sump under
    the jar. The reactor also stands 261 mm to 299
  - so the work is to hollow or rib a deep base first, then raise `carrier_floor_lift_max`. Nothing
    else follows: `rod_length` carries no floor term, so the rods do not move

- [ ] **`jar_6p5gal` is not a floor problem and a deeper floor will not fix it**
  - its punt rises 15 mm at the magnets' radius and the carrier may not stand above the plane the
    jar lands on, so the magnets sit 9 mm under the punt whatever the floor does. With a 12 mm wall
    that is 21 mm to the culture, against 4-6 mm on every other jar
  - a 39 mm floor would seat a 120 x 25 at a 29 mm pitch, the best pitch of any jar, and it would
    still be coupling across those 21 mm
  - the two things that would change it: let the bore and the carrier rise into the punt's void,
    which is free space today and would give 13 mm; or larger magnets. Both are their own decision

## nice to haves

- [ ] curve or inflection in the bayonet tube holes, to grip tubes better or ease insertion
- [ ] **back-plug the Atlas probe bore, or accept that the probe body is the seal**
  - the connector hex opens straight through to atmosphere (64 mm2); the probe body closes it by
    grip, not seal, and self-seals well enough on the bench. If a fix is ever wanted it is hot glue
    at the hex, not a modelled gland. Look at it with the sensor-gland item
- [ ] optional end styles (sensor gland) for atlas probes to match product more closely

## tooling / infrastructure / documentation

- [ ] **the port lettering is not pinned to a font, so it is whatever the host resolves `sans` to**
  - `scad/custom/bayonet_port.scad` asks for `font="sans"` in three places (:324, :332, :505).
    `sans` is a fontconfig alias, not a face, so the glyphs are whatever that host happens to
    prefer: here `fc-match sans` gives Noto Sans, with Liberation Sans also installed. The CI
    artifact's lettering was seen to differ from the bench's for exactly this reason
  - pinning it to one installed face makes the exported STL the same everywhere. It moves every
    port's mesh, so it wants its own commit
  - it is cosmetic - the lettering says which port is which - but a figure that changes with the
    machine is the kind of thing this project pins everywhere else

- [ ] **`jar_1gal_180x197` has no magnetic build, though it takes the drive**
  - `scad/bioreactor.json` carries `jar_10L_magnetic` and `jar_1p5L_magnetic` but no
    `jar_1gal_180_magnetic`, so that jar's magnetic parts cannot be exported by name. It takes an
    80 x 25 at a 28 mm pitch, the same coupling as `jar_10L`, and needs no model change - one
    entry in the parameter set

- [ ] **the probe port's transition lands exactly on the collet, and the obvious fix costs material**
  - `bayonet_probe_port`'s transition cone ends at exactly `-_transition_length`, which is exactly
    where the collet begins, at exactly the same diameter. Same defect as the three that are fixed,
    and on three of the builds it leaves one or two near-degenerate triangles (two vertices 1e-4
    apart) rather than a whole shared ring
  - carrying the cone on past the joint does clear it - 11326 triangles and one repeated becomes
    11542 and none - but it adds 5.21 mm3, because the cone is solid out to the hex and the collet
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
  - `bayonet_port.scad` `use`s `atlas_probes.scad` for its preview's example probe, as
    `sheet_gasket.scad` does its registry; rule 2 allows a preview that

- [ ] **four of five jars carry a second impeller the spacing does not support**
  - Fitschen eq. (5), `(H-d)/d > n > (H-2d)/(2d)`, in impeller diameters:

    | vessel             | H_L    | d = 0.45 T | H_L/d | H/T   | band allows |
    | ------------------ | ------ | ---------- | ----- | ----- | ----------- |
    | jar_10L_220x305    | 234.59 | 94.50      | 2.482 | 1.117 | n = 1       |
    | jar_1gal_180x197   | 153.36 | 76.50      | 2.005 | 0.902 | n = 1       |
    | jar_6p5gal_305x470 | 325.26 | 126.36     | 2.574 | 1.158 | n = 1       |
    | jar_1gal_155x251   | 188.59 | 67.19      | 2.807 | 1.263 | n = 1       |
    | jar_1p5L_109x215   | 168.70 | 45.55      | 3.704 | 1.667 | n = 1 or 2  |

  - it correlates with coverage: every jar the band puts at one impeller is spending coverage on
    the pair; `jar_1gal_180x197` at 0.107 D against the 0.5 D floor is the worst
  - no primary stands behind the rule, so `head()` reports and nothing asserts
  - the count stays two: the sparge ring sits in the gap, the power is per pair, the manifest lists
    two, and the reference build physically exists. Changing it unpicks all of that

- [ ] **the sparger's bore is the departure, not its holes, and it is one designation**
  - at the build's 4.11 L/min through one ring, sweeping the bore with 8 x 3 mm holes held:

    | bore        | feed velocity | open area | velocity head | verdict            |
    | ----------- | ------------- | --------- | ------------- | ------------------ |
    | 4.0 (today) | 5.46 m/s      | 4.50      | 17.9 Pa       | 2 departures       |
    | 8.0         | 1.36          | 1.12      | 1.1           | 2 departures       |
    | **8.5**     | 1.21          | **1.00**  | 0.9           | **clean**          |
    | 10.0        | 0.87          | 0.72      | 0.5           | clean, with margin |

  - `sparge_bore()` is the riser's own OD, so the change is a designation:
    `steel_tube_welded_10x0p5` is registered; there is no 8.5 row
  - what it costs is the cascade: the tube goes 6.4 -> 12.4 across the flats and has to clear the
    baffles and pass the mouth; the riser's port bore, rod gland, pressure drop, support tube and
    BOM row all follow. Unpriced

- [ ] **`check-holes` still needs a CGAL render, so it stays outside `just check`**
  - both ends of every ring hole are probed, and it was proved by injection (a bore swept 180
    degrees fails 5 of 20 on `feed`). What would let it into the gate is a probe that needs no
    rendered mesh: the claim is geometric and the part is a union of primitives
  - `spoke_holes` is unprobed; no caller sets it and `sparger()` refuses the unbored-arm case

- [ ] **the sparger's two sockets are hard to tell apart**
  - both are 6.4 mm across the flats; the octagon's corners stand 0.264 mm proud of the round
    support. `docs/build.md` says count the facets. A print settles whether that is findable by
    hand; if not, a collar, a flat or a mark rather than a socket sized on its own

- [ ] **the eccentricity report cannot reach the two jars it would change a decision about**
  - an assert stops `jar_1p5L_109x215` (the mount) and `jar_1gal_155x251` (the pH probe) before the
    echo. A lid with no room for the mount has none for an offset, so the document's rows read 0
    on reasoning. Left standing; the magnetic drive those jars would take is centred anyway

- [ ] **`check-scad`'s `-D '$fn=0'` pass is not the tessellation test it reads as**
  - a command-line `-D` crosses the `use` boundary on every version where an in-file assignment
    does not, so that pass also zeroes `sparger.scad`'s 96 and the collet's 64 and renders what no
    build renders. It still covers the crash a zero facet count causes
  - what would test divergence is rendering one part both ways at the CSG level
  - `OPENSCAD` is unset, so `just` runs whichever binary is first on PATH (2021.01 here, with a
    2026.09 nightly beside it). Worth pinning

- [ ] **the recess holds three quarters of the rubber, and it only matters on `jar_6p5gal`**
  - the recess is cut at `t(1-c)`, so `t*c` will not fit whatever the gasket. On a crown the
    displaced rubber flows into the 4.762 mm of width the contact chord never touches (about
    0.857 mm2 against 1.890 free); on the one ground jar it must leave across the lands
  - `jar_6p5gal` also carries the registry's highest load, 1253.6 N per post and 7.34 MPa against
    351.0 and 2.78 on `jar_10L`. Reported, not asserted
  - the fix is a groove section 10-25 % over the gasket's; that jar offers 10 mm of rim where the
    gasket is held to 6. Not chased: it changes the lid for one jar

- [ ] **one printed part is on no print list, and bench furniture is in no account**
  - `support/bottle_holder.scad` is the only original printed geometry outside the manifests;
    the cart prints nothing, and the stand's `print_corner` is a printed substitute for a bought
    NopSCADlib bracket. `check-parts` records all of them
  - the questions: does the reactor's print list cover an accessory, and is printing that bracket
    deliberate? The cart's extrusion, brackets and castors are on no purchase list either

- [ ] **designations for the pump and the inlet filter, if builds start to differ**
  - `head.scad` assigns fifteen hardware rows directly (`head_air_pump`, `sparge_inlet_filter`,
    `sparge_check_valve`, the clamps and inserts among them) that no parameter set can change
  - the pump and the filter drive the gas budget, so they are the ones worth a `_name` designation
    first. Left until a build needs it

- [ ] **registry rows are read by position and not checked for shape**
  - `registry_by_name` checks the name only. A missing field shows as an undef warning, which
    `check-scad` fails on, but two fields of the same type swapped would pass
  - low risk; a row-length assert in each `_by_name` wrapper would close most of it

## long term / post paper submission

- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based preview
