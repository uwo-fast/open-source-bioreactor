# Decisions

This document holds two kinds of record, and they answer different questions.

**Settled** records what was decided and why, so that it is not quietly redone. Do not re-open an
entry without new evidence. When you have new evidence, rewrite the entry rather than leaving it in
place beside the decision that replaced it.

**Corrections** records what this project believed and got wrong. Each entry keeps the old reading
in full, because a figure that survived review is more useful as a warning than as a deletion. Most
of them were not typos. They were readings that were internally consistent and agreed with the
surrounding documents, but measured the wrong thing. Open work is in the issue tracker; nothing here
is a task.

A corrected figure is replaced where it appears and recorded here
([Design conventions](../docs/design-conventions.md#one-physical-thing-one-expression)).

## Corrections - readings that were wrong

- **The lid seals on a flat land.** It does not. Four of the five registered jars are fire-polished
  and have a rolled rim; only `jar_6p5gal_305x470` is ground. The gasket had been sized to a flat
  that most of the jars do not have, and the land was also serving as the crush stop. This was found
  by measuring jars, not by any check; nothing in the model could have detected it.
- **`jar_10L`'s baffle can reach the blades, at -0.28 mm running.** It cannot: the clearance is
  +2.20 mm. The claim was true when written (rendered at `01b9bc2`, the model echoes -0.277222). It
  went stale when the plate narrowed from 15.3 to 10.3454 mm, which opens the gap by half the width
  removed from the plate. **No commit set out to close it.** The cost was baffle area: 0.856 -> 0.579
  of reference, and six plates now reach 0.868 where they used to clear 1.284. A collision was traded
  for under-baffling.
- **The baffle tilt should be measured first.** It does not need measuring at all. The 2.44 mm lean
  is bore play alone, ignoring the face contact of the flange, so a measurement can only come in at
  or under it, and the clearance is already sufficient there. Every outcome led to the same action,
  which means it was not a test. That held while the plate width was set elsewhere. Now that the
  plate is sized to keep 1 mm after that lean, a smaller measured lean gives back width, and the
  measurement is a test again.
- **The impeller tip ring is justified by the strike case.** That case was the -0.28 mm. With
  +2.20 mm the ring has no remaining justification: its steady-load case had already put it two
  orders of magnitude beyond what the fluid requires.
- **The DO probe collides with the lower impeller on `jar_1gal_155x251`.** It is the pH probe, by
  6.29 mm, and no DO lean reaches the impeller. The old reading came from the only sweep that
  existed, which held both leans flat: the worst case for the DO probe and the best for the pH probe.
- **A second impeller is added above about H/T 1.2.** The threshold was quoted from this project's
  own document and uses the wrong quantity. The band is written in IMPELLER diameters, and H/T only
  stands in for it at one D/T. Read correctly, it rules out a pair on four of five jars, not three.
  It also has no primary source: Fitschen relays eq. (5) from Davis, whose own two sources do not
  contain it.
- **The working volume is pinned at 8.25 L.** It is 0.865 of the jar capacity. The coverage
  reasoning behind the number still stands (0.8 of capacity gives 0.374 D against the 0.5 floor),
  but the SCOPE was wrong. A figure chosen for one jar was governing six, and 8.25 L left the
  thermocouple of `jar_6p5gal` in the headspace and stopped that vessel from rendering at all.
- **The gasket recess loses its quarter across the 1 mm lands.** Four of five jars have no lands.
  The excess follows from the geometry: the recess is cut at `t(1-c)`, so `t*c` will not fit
  whatever the gasket. Where the excess goes depends on the lip type. On a crown it flows into the
  4.762 mm of the 8 mm gasket that the contact chord never touches. The figures quoted a 3 mm gasket
  that no jar uses.
- **The joint runs at 291.8 N per post and 2.51 MPa.** It has run at 352.9 N and 2.78 MPa since the
  seal moved onto the crown, and at 351.0 N since the mouth measured 142.2 rather than 143. This
  error has its own entry because of HOW it survived. The commit that changed the seal corrected the
  echo block that [Building it](../docs/build.md) quotes, but left every figure derived from it: the
  torque band, the bolt and rod stretch, a section heading and a ledger entry. Updating a quoted
  number is not the same as updating what was computed from it.
- **The riser's gland must be a counterbore open to the vessel**, because a 4 x 1.5 ring is 7 mm
  across free and cannot be folded through a 4.4 mm bore. Two of the three reasons were wrong. The
  claim that the open face lies on the bed, so nothing bridges the bore, was **already false**: the
  shoulder above the counterbore is itself a 1.03 mm unsupported ledge. The ring also folds through
  without trouble on a printed port. What the counterbore actually did was let the ring fall into
  the culture. Only the third reason survived, and it is why the replacement is a groove rather than
  a relocation.
- **A magnetic drive is most viable where it is most needed** (thin base, small punt), because the
  gap is base wall plus punt height plus clearance, about 11 mm on `jar_1p5L`. This was wrong in two
  ways. The figures included only two of the three terms in the definition, and a flat driver is
  not the only arrangement. A hub that nests UP INSIDE the punt pays only the wall thickness, which
  inverts the ranking, because the punt WIDTH is then both the lever arm and the space for magnets.
  `jar_1p5L` is the worst of the five at 7.5 mm of usable radius; `jar_1gal_155x251` is the best at
  36.5.
- **The sparge ring is sized at 80 % of the impeller, after Oldshue p. 214.** Two experimental
  studies (Birch & Ahmed 1997, Rewatkar & Joshi 1993) find that rings larger than the impeller
  perform better, and the ring is now placed by the mouth at 1.90 D. The flat 4 x 10 section that
  fit the radial band could not be cleaned, so the sparger is now a round tube split opposite the
  feed.
- **The mouth assert charged 8 mm for a tip ring that had been moved inboard of the blades.** While
  it did, the D/T caps read 0.4594 and 0.59-0.82. The ratio was never at risk, only the headroom it
  was chosen on.
- **The clearance was 0.6 D, chosen against Oldshue's 1-2 D as an allowance the vessel could not
  reach.** That allowance is for fluidfoils. Fort's guidance applies to a pitched blade and puts it
  at 0.9 D. The uncited convention of C/T between a quarter and a third supported 0.6 D (C/T 0.27)
  and does not reach 0.9 D (C/T 0.405).
- **The eccentricity analysis measured T as the outer diameter.** The e/T table in
  [References](../docs/references.md) (now in
  [Agitation](../docs/agitation.md#eccentric-mounting)) read "Hall's e = 0.2 T needs 21.8 mm on
  `jar_1p5L`", with every ratio 0.2 x or / the glass rather than the bore. This was the
  impeller-ratio defect again, recurring in a document after it had been fixed in the model. The
  numerator was lid geometry in mm and was never in question. Only the denominator changed, by 4 to
  8 %, all in one direction. The e/T columns are now echoed by `head()` rather than transcribed.
- **The feed socket is a hexagon.** It now takes the octagonal section of the tube itself; 0.264 mm
  of corner is what distinguishes it from a round support.
- **Jirout & Rieger's course notes were graded [PR].** They are undated teaching material, [TX].
  Their Np = 0.99 +/- 0.04 is the borrowed power number that the correlated 1.497 replaced.
- **The thermocouple was 3872K117, the same probe at 9 in**, until the model showed it reaching
  through the floor of `jar_1gal_180x197`. `head()` selects the 6 in 1245N31.
- **The metering range was "an 84:1 spread in culture volume".** The ratio was always the spread in
  flow; culture volume spans 14.7:1.
- **The baffle plate was 4 mm, then 8, then 9.** Each step was sized on a closed-form deflection
  that had only been checked at zero freeboard, and it read 23 % low at the plate's actual 49 mm.
  The first mode was the real limit all along, and 10 mm is where the blade-passing crossing clears
  the drive's band. `stirred_tank_baffle_deflection()` now integrates the point-load case.
- **The baffle piece cap was 170 mm, "because 180 mm machines are what a builder owns".** No 180 mm
  machine could ever build this reactor, because the frame bases are 257 mm across. The cap is now a
  slenderness rule, and `bioreactor.scad` reports which registered printers can print the build.
- **Below D/T 0.4305 the lock bore is what caps the baffle width.** That was true when the impeller
  and the bore were the only bounds. The sparge ring caps it on every jar that builds the ring,
  because the space outside a baffle does not grow with the mouth. On `jar_10L` under the arm, the
  impeller's running clearance after the plate's lean caps it. On the 70 mm Rushton the impeller is
  far enough inboard that the lock bore is the limit again, at 17.09 mm.
- **The full port set's smallest mouth is 130.4 mm and the reduced set's 81.6, and spreading the
  big ports is worth 19.3 mm.** All three figures assumed the ports could be arranged freely. Four
  baffles at every third port leave no port that is not beside one, so the worst pair is std
  against std whatever the tubes take. The correct figures are 142.0 and 78.0 mm, which `head()`
  reports.
- **A DC fan runs 1000-3000 rpm where this design wants 320-420.** That band was the reference
  build's drive speed on a 94.5 mm impeller, applied to jars whose impellers are half that size. The
  target is tip speed. Holding it puts `jar_1p5L` at 528-851 rpm and `jar_1gal_155` at 358-577,
  closer to a fan's native range than it appeared.
- **The pitched pair beat a Rushton by 4x on circulation per watt, and the gas criterion did not
  bind.** The 4x was `N_Q/Po`, which compares flow per watt at the same speed and diameter, not at
  the same power. At equal power and diameter, flow scales as `Fl * Po^(-1/3)`. That gives about
  1.8x on the Table 1 values from Grenville 2017 for both blades, and nearly even with McCabe's 1.3
  and 5.75 for the Rushton. The pitched pair also held its flow pattern to 1.57 vvm only at 420 rpm.
  Oldshue's 8x rule scales as N^3, so at the 255 rpm Chlorella optimum the ceiling was 0.35 vvm,
  below the 0.5 vvm design. [Agitation](../docs/agitation.md) gave both as the case for the axial
  blade until the build moved to the standard turbine.
- **`check-holes` proved the arm's holes break through.** It proved only that their ends were open.
  A hole drilled downward is cut from the outside in, and the probes sat at the outer face and on
  the bore centreline. Both were open whether or not the hole reached the bore, so an arm whose
  holes stopped 0.4 mm short of the bore passed. A third probe now sits in the wall just under the
  bore, for the arm and the loop, and that arm fails on it, with three of nine probes solid.
- **The ring and the arm were clean solids.** The ring as `jar_10L` draws it had two non-manifold
  edges. Its end-plug pilots started exactly on the face cut by the cleaning split, and the arm's
  screw pilot ended exactly on the boss flat it opens through. A cut whose end face coincides with
  the face it opens through leaves a pinch; on the arm, its angle happened to round this away. A
  loop built as a ring reusing both pilots measured four passages it does not have. Both pilots now
  run a millimetre or more past their face, as the loop's end pilot does, and the ring, the arm and
  the loop measure the expected passage counts: 10, 5 and 10.
- **The loop was a ring teed onto the arm.** The arm's run fed a split ring, which is two spargers
  joined together, not the pigtail it was intended to be. It is now one tube: an elbow, a hook onto
  the curl tangent from outside, and a C to a plugged end. Its pieces meet tangentially and overlap
  by 0.01 mm. When they met exactly face to face, they stayed separate shells and the part measured
  two passages it does not have. The hook costs size where the baffles do not bind: `jar_1p5L` goes
  from 40 to 25.2 mm, `jar_1gal_155` from 47.4 to 31.9 mm and `jar_6p5gal` from 88.6 to 71.5 mm,
  all under the band, which `head()` warns about. A tangent lead from the riser keeps nearly the
  whole radius, but on `jar_10L` it runs into the next plate around.
- **`check-scad`'s `-D '$fn=0'` pass renders what no build renders.** It does not. Consider a
  `use`d file that sets `$fn = 48` for itself, called from a file that leaves `$fn` at 0. On
  2026.10.03 its module sees 0 (the caller's value) with or without the `-D`. On 2021.01 it sees 48
  (its own value) unless the `-D` is given, and then 0. So on CI's 2021.01 the `-D` pass is the only
  way to render what a current OpenSCAD renders by default, which is what the comment on the pass
  said all along.

## Settled - do not re-open without new evidence

- **The gas line and the electronics are deliberately left out of the CAD.** The assembly includes
  parts whose geometry must be checked against the vessel, the head and the frame. These two groups
  have none:
  - **The gas line:** the air pump, the sterile inline filter, the rotameter and its adapters, the
    metering, check and needle valves, the reducers, the tubing and the hose clamps. These are
    purchased parts joined by tubing, and the tubing is routed at the bench. The design needs
    figures from the gas line, not shapes: `head()` echoes the losses of the filter, the check valve
    and the riser against the vessel back-pressure, and `purchased-parts.csv` lists the parts.
  - **The electronics:** the power supply, the Raspberry Pi 4B, the Slice_DCMT, Slice_RLHT and
    Slice_PHDO boards, the EZO pH and DO circuits, and the e-stop. They connect to the reactor by
    cable, no drawn part mounts them, and their position is decided at the bench.

  The parts at the end of the gas line are drawn: the sparge riser, the sparger and the condenser
  coil. If a frame mount is designed for either group, draw that group and record it here.

- **The loop gives way to the baffles, not the baffles to the loop.** A ring under the lower
  impeller sits among the plates, and the ring between the impellers had already shown the cost of
  the alternative: it reduced the plates from 17.09 to 10.35 mm. The plates mount from the lid and
  set the baffling for every build, while the loop is optional. So the loop goes inside the plates'
  inner edge, minus the lean that the plates and its own riser can swing through at its height, and
  minus 1.25 mm. On `jar_10L` that is 1.09 D against Birch & Ahmed's 1.4 D, still inside the
  1-2 D band.

- **`jar_10L_220x305` runs the loop; every other stirred build keeps the arm.** On the bench under
  lid plates, the loop stayed clear of them and every hole bubbled with the C level (#70). It also
  puts the gas under the whole lower impeller rather than one side of it. The reference build uses
  the wall cage, whose bars stand at r 61 against the loop's r 41.74, so there the loop size is set
  by its own hook, 1.09 D. `auto` stays with the arm, because a build under lid plates sits 1.25 mm
  off them. Run hard in the cage build, the loop did not turn on its single riser. The swirl torque
  that could have closed its gap in 1.27 deg does not, so the riser needs no key or flat.

- **The sampler halves screw together into heat-set inserts; the actuator screws come up from
  under its face into nuts inside it.** Three screws join the base to the top through heat-set
  inserts, as in the motor mount. An M3 nut is 6.4 mm across its corners against the 3.57 mm insert hole, so
  nuts would widen the corners they sit in. A loose nut is also one more thing to lose while the top
  is upside down beside the vessel. One of the three is an M2, from above, because the pin flange
  sits under the inner end of the case. The actuator was first fitted with screws from inside its
  front wall into nuts trapped in the face, and getting it onto four screws it had to carry down was
  the hardest part of the assembly. Now the screws stand up out of counterbores under the face and
  the actuator drops over them. Its nuts sit inside on a flat against its side wall, which holds
  them while the screws are turned from below. The actuator itself is unchanged.

- **The impeller tip ring is OFF by default, and is a flag rather than geometry.** It is a 4 x 4 mm
  annulus joining the blade tips, and it printed as a floating overhang for most of its
  circumference: 86.7 % of it unsupported, with a longest span of 61.6 mm. Nothing structural
  required it. One blade carries about 0.62 N at the no-load speed, which is 0.31 MPa at the root
  and 11 um of tip deflection, two orders of magnitude inside what printed PLA can take, and the
  blades attach to the hub rather than to each other. The strike-against-a-baffle case that had
  kept it no longer applies with the +2.20 mm running clearance (see the correction above). Measured
  on the exported part, removing it removes 4328 mm^3, a fifth of the impeller, and **does not
  change the swept diameter**: 94.5001 mm either way, because the blade corners define it and the
  ring sat inboard of them. It is also not part of the shape on which the power number of
  `pbt_45_4` is defined, so leaving it off is both more faithful and easier to print.
  `impeller_tip_ring = true` restores it if the baffle is ever widened enough to need it.

- **Eight parts are designated end to end**: vessel, shaft, plug o-ring, strip light, gasket sheet,
  motor, DO probe and pH probe. Each designation reaches the geometry, the readbacks and the
  exported STL. The rules are in
  [Design conventions](../docs/design-conventions.md#three-layers-and-where-a-parameter-lives),
  `check-designations` guards the surface, and the registries carry names, part numbers and
  provenance. The refusals below belong with this decision.
- **`heat_set_inserts` and `shaft_couplings` are not rewrapped into the `set_screws` shape.** That
  template wraps because the LIBRARY owns the geometry and the row adds purchase identity. These two
  are the opposite: the project registers the part in NopSCADlib's own schema. A wrap would cost
  about nine call-site edits in `head.scad` and buy only uniformity. The insert's fields go at the
  end of the row instead, starting at [11] because the library reads [9] and [10].
- **The port table is not threaded through its ~53 call sites**, and there is no guard against the
  hazard either. `head_interface_for` gives every probe port `bayonet_std` whatever it carries, so
  no expressible designation can change an interface, and the sweep test shows an equality guard
  would be a dead assert. **This is reopened by** a designation that can change a port's INTERFACE
  (a thermocouple thread swap), or one that changes the table's count.
- **The remaining BUILD rows are not hoisted mechanically.** The arithmetic in `0304a3a`: five moved
  declarations gained one carryable number. Relocation without the name-lookup layer multiplies
  duplicated defaults and carries nothing.
- **No `motor_for` / `air_pump_for` / `coupler_for` yet.** Those registries hold 4, 1 and 1 rows. A
  selection over one candidate is a fit check disguised as a selector. Registering rows comes first,
  not writing selectors.

- **A designation is a STRING, and `"auto"` means derive it.** It is not `undef`, which the
  customizer cannot see at all, and not a numeric sentinel. `0` litres or `-1` degrees is exactly
  the kind of plausible number that propagates unnoticed, and on a research instrument a negative
  lean is a value someone could be studying rather than a flag. A string is carried through, is
  visible in the surface, and is consumed by a mode branch that never multiplies it by anything.
  Numeric sentinels are rejected everywhere.
- **Cited bands at the pressure boundary may assert; `reasoned, not cited` limits may not.** The
  three o-ring checks guard the seal between the culture and the room, and come from gland practice
  rather than this project's judgement, so they keep the authority to refuse. The distinction is the
  provenance, not the severity, which is why the mount slenderness limit loses its authority to
  refuse.
- **No `builds/` escape file yet.** The only thing that genuinely cannot go in a parameter set is
  a nested table, and nobody has needed a custom port table: the two registered sets cover all six
  jars. `-D` is the escape hatch. Revisit this only if a custom table becomes a recurring need. If
  it is ever adopted, it must never be rendered with `-p`, which silently un-pins the file's own
  assignments.
- **`peri_pump_frame_mount.scad` is deliberately left alone**, including
  `flange_screw_distance = 48.0`. It is a stretch goal that needs a faceplate the purchased Kamoer
  does not have, and it blocks nothing.

Each of these questions was asked and answered. The reasoning is in the commit that closed it and,
where it is needed beyond the commit, in the other documents here.

- **The motor mount stays at dia 56.** It can go to 42; below that, its base inserts hit the bearing
  pocket. Shrinking it gains only eccentricity headroom on a vessel that is baffled anyway, and
  costs stiffness, since deflection scales as the cube of height over diameter.
- **The lid carries three baffles, not four, to free a port** (where it carries plates; see the
  wall cage below). Three plates fall short of Oldshue's reference area
  ([Agitation](../docs/agitation.md#baffles)); the fourth baffle's port went to a sampling line.
  Going back to four would mean re-laying the whole lid, since four equally spaced baffles do not
  land on three-at-120 deg.
- **`jar_10L`'s reference build carries the standard four baffles on the wall, not the lid's
  three.** The microalgae researcher advising the project asked for the standard set. Lid plates
  must pass through the mouth, so they cannot reach the wall, and four rigid baffles at T/12 against
  the wall cannot pass through the mouth. They are fitted on a cage whose blades slide in to pass
  it ([Agitation](../docs/agitation.md#baffles),
  [Building it](../docs/build.md#the-wall-baffle-cage)), giving 1.00 of the reference area against
  0.713 for the plates. The pH probe moves to the 30 deg port under it.
- **`auto` uses the cage wherever it fits, and the plates elsewhere.** The cage fits with a shaft
  or magnetic drive, not the ring, on a lid with baffle ports for a probe that the gap in the hoops
  leaves out, where a blade slides past the 10.4 mm it needs to run free between its detents (the
  hoop's 6, a 4 mm detent and 0.2 mm of play at each end). Both `jar_10L` builds fit, at 30.58 mm.
  The 1 gal jars do not: their 148 mm mouth against a 170 mm bore leaves 8.24 mm, every detent is
  always in a hoop, and `head()` refuses a cage named there. The six-port lids (`jar_6p5gal` and the
  two narrow jars) have no baffle ports, and their DO and pH probes stand 120 deg apart against the
  64 deg gap. Both cases need new geometry, tested on the bench before it is trusted (#93).
- **The cage is assembled on the bench and lowered in whole, not sprung against the wall.** The
  first spike's rigid rings were assembled inside the jar, which is where the spike stopped. Rings held
  against the glass were rejected:
  - a split PETG ring at the wall, 270 deg and closed end to end, is 0.75 x 210 = 157.5 mm across
    against the 142.2 mm mouth, so it passes only by coiling its ends past each other, at 1.5 to
    2.1 % strain;
  - sprung outward, a 6 x 8 ring preloaded 3 mm presses with 2.8 N, giving about 71 N-mm of friction
    at mu 0.25 (assumed) and r 102, and about 27 once PETG relaxes (62 % in 24 h for sheet,
    relayed), which is under the 63 N-mm the cage's riser takes at 320 rpm;
  - a ring set by a keystone wedge goes slack after 3.2 to 4.9 K of cooling, based on an unsourced
    CTE difference to the glass.
- **The slide cage, not half-rings or lugs.** The second print added half-rings and a stop nub on
  each bar. The nubs broke, the half-rings would not stay in their hoops, and when slid in, the pads
  stood 2.4 mm per side past the mouth. A dovetail lug at each blade with a snap tooth came next.
  Both added parts without making the cage work better, so the design went back to the first print's
  slide, with tighter fits. The closed outer end of the bar is now the stop, with nothing protruding
  to snap off.
- **The probes still sit beside baffles with three baffles.** Three baffles leave the middle port of
  each group of three free, but a probe there cannot sit opposite the air inlet, which lands on a
  baffle. Keeping DO opposite the air inlet was chosen, and the lid uses std ports throughout either
  way.
- **Commodity fasteners are specified by a STANDARD, not a supplier code.** `ISO 4017 M8x30 A2-70`
  can be bought anywhere and does not go stale, and nothing in the model reads a property of these
  fasteners beyond nominal size and a derived length. The sealing and mount hardware stays pinned
  by part number, because each of those parts has a property that a standard does not specify.
- **Cooke's blend-time correlation is deliberately absent.** It could not be made to reproduce the
  figures its own source prints beside it. Ruszkowski's correlation is encoded and was validated
  first (1.96 s against a published 1.9). See [References](../docs/references.md) before trying
  Cooke's again.
- **The reference build runs two `impeller_rushton_6` in the standard turbine configuration**: D =
  T/3, the lower impeller T/3 off the floor, the upper a further T/3 up (McCabe, Smith & Harriott
  1993 pp. 241-243 and 253), on the advice of the microalgae researcher advising the project. The
  first paper is about the design, so the reactor runs at a standard wherever one exists. The
  pitched pair and a Rushton under a pitched blade are parameters for later work
  ([Baseline](../docs/baseline.md)). The twisted paddle stays registered and drawn, but no
  correlation gives it a Po.
- **The Rushton power number is Kaiser's measured 4.17, not McCabe's 5.75**, and no choice in the
  build depends on which is right
  ([Agitation](../docs/agitation.md#2-this-reactor-in-the-units-that-matter)).
- **The shaft is 400 mm and must be a ground rotary shaft.** A 300 mm length is not in the catalogue,
  and 200 mm cannot reach. The shaft runs directly in the inner race of the 608 bearing, so plain h9
  rod would allow 0.043 mm of play and fret the bore.
- **The sparge ring sits in the gap between the impellers**, following Birch & Ahmed: above an
  up-pumping impeller and below a down-pumping one. The pitched pair converged, so one ring served
  both. Two Rushtons discharge radially, and none of the sources held here places a ring for them;
  the shaft drive's default is the arm. This supersedes Oldshue p. 214's ring at 80 % of the
  impeller, which two experimental studies contradict.
- **The sparger holes are 1.2 mm, for bubble size; they were 8 x 3 mm to resist fouling.** The
  culture photos show almost no buildup on the sparger, and 3 mm holes cost bubble size: 5.10 mm at
  formation against 3.76. They were 1 mm next, which printed too small. 16 x 1.2 mm holes run at
  3.76 m/s with an open area of 1.44. That is above 1, so the holes nearest the feed take more of
  the gas, but the 24 Pa per hole still outweighs the 18 Pa of velocity head in the bore. Bubbles
  are 3.76 mm at formation, and the arm fits eight holes on `jar_10L`, at 7.53 m/s.
- **The loop drills 11 holes, not the ring's 16.** Its single bore feeds them to a dead end, and
  with 16 holes the far end bubbled more weakly on the bench. 11 holes bring the open area to 0.99
  and the pressure drop across a hole from 24 to 50 Pa, at 5.47 m/s, just above Barbosa's 5.4. The
  ring keeps 16: it has two flow paths, and an odd count would put a hole in its split.
- **The working volume is DERIVED from a fraction of capacity, not pinned in litres.** It is 0.865
  of the jar capacity, which is 8.17035 L on jar_10L and scales to every registered vessel. A figure
  in litres applies to only one jar: 8.25 L left the thermocouple of jar_6p5gal_305x470 in the
  headspace and stopped that vessel from rendering at all.
- **The riser is welded hard-temper 316, not seamless soft.** Temper does not change the modulus,
  but the purpose of a support tube is to stay where it is put, and it costs $22.72/m against
  $181.42.
- **The plug o-ring cord is 3/32 in, not 1/8.** The groove and the port bores are cut into the same
  wall, so a thicker cord fouls the bores on every vessel, not only on a tight one.
- **The lid joint is specified as a TURN, not a torque, and this is deliberate.** 351.0 N per post
  is 0.56 to 0.84 N.m across the 0.20-0.30 nut factor range of unlubricated 18-8. That is a 40 %
  band from friction alone, on a fastener that galls, at a setting below the range of most torque
  wrenches. The turn is the gasket travel divided by the thread pitch, and has no modulus or
  friction term. Both are in
  [Building it](../docs/build.md#closing-the-lid-and-the-number-that-cracks-the-jar); the torque is
  given there to explain why it is not the instruction.
- **The lid follows the outer diameter of the frame, and trimming it gains nothing.** It was once
  cut to 252, its own minimum (the bolt circle plus a bore plus wall), because 257.40 put it 1.4 mm
  beyond every 256 mm machine. Then the FRAME was measured. Its base and top base are also 257.40,
  and its wall cannot be reduced because the rod bosses need 36.8 mm of it. So the trim thinned the
  lid flange and put a 2.7 mm step in the joint to suit a printer that the frame already ruled out.
  `bioreactor.scad` now REPORTS which printers can print this, instead of the design being made to
  fit one.
- **The baffle cap is a PRINT-QUALITY rule, not a bed-size rule.** It was a literal 170 justified by
  180 mm machines, which could never have built this reactor at all. It is now a piece's height
  against three times its own section (a brim as wide as the part on each side). The piece that
  binds is the TIP, not the piece carrying the port: a flange acts as a wide foot, so the bare plate
  is half again as slender. Do not re-derive the cap from a printer; that is the mistake it
  replaced.
- **The riser gland is an ENCLOSED GROOVE above a 1.2 mm lip.** A counterbore open to the vessel has
  nothing under the cord, so an unseated ring drops into the culture, which is what happened.
  Pressure still seats the cord on the upper shoulder, and the lip holds it when there is no
  pressure. The ring is folded and pushed up the bore past the lip, which a printed port showed is
  reasonable by hand. See Corrections.
- **Lights per cord is registered, and it does NOT decide how many lights there are.** These lights
  are sold as a cord and a controller driving a fixed number of tubes, so a layout that is not a
  whole number of cords requires buying the next one up. frame() reports the cords a layout needs;
  the layout remains an illumination decision. Deriving the count from the packaging would let the
  shop set the design, which is the wrong direction.
- **The baffle resonance check asks WHERE the mode is crossed, not whether the drive is near one.**
  It used to compare the mode against the excitations at the fastest drive setting and warn within
  30 %. That is correct for load and wrong for resonance: a DC motor sweeps every frequency below
  its maximum, so some mode is always crossed on the way up. What matters is the SPEED of the
  crossing and whether the drive is asked to hold it: 491 rpm on the 10 mm plate of
  `jar_1gal_180x197` against a 320-420 band. The clearance to that band is reported because it is
  what separates a 10 mm plate from an 11 mm one.
- **`check-mesh` is not in `just check`**, because it renders solids, which takes minutes to tens
  of minutes. The `$fn=0` second pass IS in `check-scad`, because that recipe is the fast one. Both
  were shown to FIRE on a deliberately broken input before being trusted.
- **The two gas-driven jars are registered as airlifts, not bubble columns.** Removing the draft
  tube from the airlift build leaves the bubble column. It uses the same lid and parts except for
  the ring, which is drawn a few millimetres smaller to fit inside the tube with its supports cut to
  match, and the DO port, which hangs its probe straight. A second registration would export
  near-duplicate parts for a build that the airlift's parts already cover.
  `drive_name = "none"` remains a drive the model builds; it is no longer a build the export writes.
- **Under the airlift the DO probe hangs straight.** Its lean exists to move the tip out of the
  shaft's shadow and into the flow
  ([Port layout](../docs/ports-layout.md#the-probes-lean-and-only-one-of-them)), and inside the
  riser there is no shaft and the whole core flows. Leaning it only moves it toward a tube that can
  shift by up to 2.5 mm: with the tube included among its obstacles, the derived lean came to within
  0.08 mm of the wall on `jar_1p5L`, less than the play of the tube itself.
- **A magnetic build that needs more floor height than the base gives stands on a riser.** The base
  remains the floor for the lights, so it is one print for every drive on its jar, and an airlift
  build does not grow for a drive it does not have. The alternative was a hollowed deep base: one
  print, but under every drive, and it moved the jar relative to the lights. The riser is walls
  only, so it prints as it stands, and it keeps the carrier unchanged by including the base's slot.
  `jar_1p5L` keeps its sunk floor: its 3.77 mm is far short of the 23.8 mm a riser needs to hold the
  carrier's ear.
- **The discharge holes in the support tubes are not drawn.** Every tube port except `air_in` is
  capped at its lower end and vents through a hole cut along its length, which is done at the bench.
  `head()` reports the window (37.9-88.4 mm from the top on `jar_10L`), and
  [Building it](../docs/build.md#drilling-the-support-tubes) says which end each port needs. Only
  the `air_out` hole has a required size, and only where no condenser uses that port; `head()`
  calculates it there. A default for a hand-cut window would be a guess, so it is not a parameter
  either.
- **The stirred jars keep two impellers, although Fitschen's spacing band allows one.** Fitschen
  eq. (5), `(H-d)/d > n > (H-2d)/(2d)` in impeller diameters, allows one on all three jars that
  take the shaft drive. n is 1 or 2 on `jar_10L_220x305` (H_L/d 3.27862) and `jar_6p5gal_305x470`
  (3.47503), and 1 on `jar_1gal_180x197` (2.7063), which `head()` reports as short for a pair at
  0.729831 D of culture over the upper impeller against the 0.5 D floor. No primary source supports
  the rule, so `head()` reports it and nothing asserts. The count stays at two: the power figure is
  per pair, the manifest lists two, the reference build physically exists, and the standard
  configuration the paper runs is two Rushtons.
- **The pump, the inlet filter and the other gas-line hardware are assigned in `head.scad`, not
  designated.** `head_air_pump`, `sparge_inlet_filter`, `sparge_check_valve`, the clamp and the
  inserts are set directly, and no parameter set can change them. The pump and the filter drive the
  gas budget, so they will be the first to get a `_name` designation when a build needs a different
  one. Until then a designation would be a parameter with one value.
- **Registry rows stay positional, checked by a signature per field.** `registry_by_name` checks
  every row of a registry on every lookup against a signature with one letter per field (string,
  number, list, bool, capitalised where undef is allowed), and `fan_by_name` does the same for
  NopSCADlib's unnamed rows. This catches a row that lost or gained a field, or a list where a
  number belongs: a `grow 13in` row with its per-cord count and its dimensions swapped fails with
  `registry rows ["grow 13in"] do not fit sln`. Two swapped fields of the same type still pass.
  Named fields would catch that, at the cost of rewriting every registry and every accessor.
- **`bayonet_port.scad` receives every o-ring as a global, and that stays.** It includes
  `bayonet_interfaces.scad`, an include that [Architecture](architecture.md) allows by name. That
  file includes `orings.scad` so that an interface row can name its ring, which rule 6 calls an
  honest cross-registry include. The o-rings arrive as a side effect of both allowed includes;
  moving them would mean the interface rows naming their ring some other way than by its row.
