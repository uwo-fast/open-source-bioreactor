# Decisions

Two kinds of record, and they answer different questions.

**Settled** is what was decided and why, so it is not quietly redone. Do not re-open an entry
without new evidence — and when you do have it, rewrite the entry rather than leaving it standing
beside the thing that replaced it.

**Corrections** is what this project believed and got wrong. Each entry keeps the old reading in
full, because a figure that survived review is worth more as a warning than as a deletion: most of
them were not typos but readings that were coherent, agreed with the documents around them, and were
measuring the wrong thing. `TODO.md` carries open work only; nothing here is a task.

A corrected figure in a document or in source is replaced where it sits and recorded here; it does
not stay inline.

## Corrections — readings that were wrong

- **The lid seals on a flat land.** It does not. Four of the five registered jars are fire-polished
  and roll over; only `jar_6p5gal_305x470` is ground. The gasket had been sized to a flat that most
  of the family does not have, and the land was doing double duty as the crush stop. Caught by
  measuring jars, not by any check — nothing in the model could have known.
- **`jar_10L`'s baffle can reach the blades, at −0.28 mm running.** It cannot: +2.20 mm. The claim
  was true when written — rendered at `01b9bc2` the model echoes −0.277222 — and went stale when the
  plate narrowed from 15.3 to 10.3454 mm, which opens the gap by half what it takes off the plate.
  **No commit set out to close it.** The cost was baffle area: 0.856 → 0.579 of reference, and six
  plates now reach 0.868 where they used to clear 1.284. A collision was traded for under-baffling.
- **The baffle tilt wants measuring, first.** It does not want measuring at all. The 2.28 mm lean is
  bore play alone with the flange's face contact ignored, so a measurement can only come in at or
  under it — and the clearance already clears there. Every outcome led to the same action, which is
  what makes it not a test. That held while the plate's width was set elsewhere; since the plate is
  sized to keep 1 mm after that lean, a smaller measured lean is width back, and the measurement is a
  test again.
- **The impeller tip ring earns its place on the strike case.** That case was the −0.28 mm. With
  +2.20 mm the ring has no surviving argument: its steady-load case already put it two orders of
  magnitude past what the fluid asks for.
- **The DO probe collides with the lower impeller on `jar_1gal_155x251`.** It is the pH probe, by
  6.29 mm, and no DO lean reaches it. The old reading came from the only sweep that existed, which
  held both leans flat — the DO probe's worst case and the pH probe's best.
- **A second impeller is added above about H/T 1.2.** The threshold was quoted from this project's
  own document and is on the wrong quantity: the band is written in IMPELLER diameters, and H/T only
  stands in for it at one D/T. Read properly it puts a pair out of reach on four of five jars, not
  three. And it has no primary — Fitschen relays eq. (5) from Davis, whose own two sources do not
  contain it.
- **The working volume is pinned at 8.25 L.** It is 0.865 of what the jar holds. The coverage
  reasoning behind the number still stands — 0.8 of capacity gives 0.374 D against the 0.5 floor —
  but the SCOPE was wrong: a figure chosen for one jar was governing six, and 8.25 L left
  `jar_6p5gal`'s thermocouple in the headspace and stopped that vessel rendering at all.
- **The gasket recess loses its quarter across the 1 mm lands.** There are no lands on four of five
  jars. The excess is an identity — the recess is cut at `t(1−c)`, so `t·c` will not fit whatever
  the gasket — but where it goes splits by lip kind, and on a crown it flows into the 4.762 mm of
  the 8 mm gasket the contact chord never touches. The figures quoted a 3 mm gasket no jar carries.
- **The joint runs at 291.8 N per post and 2.51 MPa.** 352.9 N and 2.78 MPa since the seal moved
  onto the crown, and 351.0 N since the mouth measured 142.2 rather than 143. Worth its own entry because of HOW it survived: the commit that changed the seal
  corrected the echo block `docs/build.md` quotes and left every figure derived from it — the torque
  band, the bolt and rod stretch, a section heading, a ledger entry. Updating a quoted number is not
  the same as updating what was computed from it.
- **The riser's gland must be a counterbore open to the vessel**, because a 4 × 1.5 ring is 7 mm
  across free and cannot be folded through a 4.4 mm bore. Two of the three reasons were wrong. That
  the open face lies on the bed so nothing bridges the bore was **already false** — the shoulder
  above the counterbore is itself a 1.03 mm unsupported ledge. And the ring folds through fine, on a
  printed port. What the counterbore actually did was let the ring fall into the culture. Only the
  third reason survived, and it is why the replacement is a groove rather than a relocation.
- **A magnetic drive is most viable where it is most needed** — thin base, small punt — because the
  gap is base wall plus punt height plus clearance, about 11 mm on `jar_1p5L`. Wrong twice. The
  figures carried two of the three terms the definition names, and a flat driver is not the only
  arrangement: a hub that nests UP INSIDE the punt pays the wall alone, which inverts the ranking,
  because the punt's WIDTH is then both the lever arm and the room for magnets. `jar_1p5L` is the
  worst of the five at 7.5 mm of usable radius; `jar_1gal_155x251` the best at 36.5.
- **The sparge ring is sized at 80 % of the impeller, after Oldshue p. 214.** Two experimental
  studies (Birch & Ahmed 1997, Rewatkar & Joshi 1993) find rings larger than the impeller better;
  the ring is placed by the mouth at 1.44 D. And the flat 4 × 10 section that fit the radial band
  could not be cleaned, so the sparger is a round tube split opposite the feed.
- **The mouth assert charged 8 mm for a tip ring that had been moved inboard of the blades.** The
  D/T caps read 0.4594 and 0.59–0.82 while it did; the ratio was never in danger, only the headroom
  it was chosen on.
- **The clearance was 0.6 D, chosen against Oldshue's 1–2 D as an allowance the vessel could not
  reach.** That allowance is for fluidfoils; Fořt's guidance fits a pitched blade and puts it at
  0.9 D. The uncited C/T quarter-to-third convention supported 0.6 D (C/T 0.27) and does not reach
  0.9 D (C/T 0.405).
- **The eccentricity analysis measured T as the outer diameter.** `docs/references.md`'s e/T
  table read "Hall's e = 0.2 T needs 21.8 mm on `jar_1p5L`", with every ratio 0.2 × or ÷ the glass
  rather than the bore - the impeller-ratio defect, recurring in a document after it was fixed in
  the model. The numerator was lid geometry in mm and never in question; only the denominator
  moved, 4 to 8 % all one way. The e/T columns are echoed by `head()` now, not transcribed.
- **The feed socket is a hexagon.** It takes the tube's own octagonal section now; 0.264 mm of
  corner is what tells it from a round support.
- **Jirout & Rieger's course notes were graded [PR].** Undated teaching material, [TX]; its
  Np = 0.99 ± 0.04 is the borrowed power number the correlated 1.497 replaced.
- **The thermocouple was 3872K117, the same probe at 9 in**, until the model showed it reaching
  through `jar_1gal_180x197`'s floor. `head()` selects the 6 in 1245N31.
- **The metering range was "an 84:1 spread in culture volume".** The ratio was always the flow
  spread; culture volume spans 14.7:1.
- **The baffle plate was 4 mm, then 8, then 9.** Each step was sized on a closed-form deflection
  that was only ever checked at zero freeboard and read 23 % low at the plate's real 49 mm; the
  first mode was the real limit all along, and 10 mm is where the blade-passing crossing clears the
  drive's band. `stirred_tank_baffle_deflection()` integrates the point-load case now.
- **The baffle piece cap was 170 mm, "because 180 mm machines are what a builder owns".** No
  180 mm machine could ever build this reactor: the frame's bases are 257 mm across. The cap is a
  slenderness rule now, and `bioreactor.scad` reports which registered printers take the build.
- **Below D/T 0.4305 the lock bore is what caps the baffle's width.** It was, when the impeller
  and the bore were the only bounds; the sparge ring caps it on every jar that builds the ring, since
  the room outside a baffle does not grow with the mouth, and the impeller's running clearance after
  the plate's lean caps it on `jar_10L` under the arm. On the 70 mm Rushton the impeller is far
  enough in that the lock bore binds there again, at 17.09 mm.
- **The full port set's smallest mouth is 130.4 mm and the reduced set's 81.6, and spreading the
  big ports is worth 19.3 mm.** All three assumed the ports could be arranged freely; four baffles
  every third port leave no port that is not beside one, so the worst pair is std against std
  whatever the tubes take. 142.0 and 78.0 mm, which `head()` reports.
- **A DC fan runs 1000–3000 rpm where this design wants 320–420.** The band was the reference
  build's drive on a 94.5 mm impeller, applied to jars whose impellers are half that. The target is
  tip speed, and holding it puts `jar_1p5L` at 528–851 rpm and `jar_1gal_155` at 358–577 — nearer a
  fan's native range than it looked.
- **The pitched pair beat a Rushton by 4× on circulation per watt, and the gas criterion did not
  bind.** The 4× was `N_Q/Po`, which compares flow per watt at the same speed and diameter, not at
  the same power. At equal power and diameter flow goes as `Fl · Po^(−1/3)`: about 1.8× on
  Grenville 2017's Table 1 values for both blades, and near even with McCabe's 1.3 and 5.75 for
  the Rushton. And the pitched pair held its flow pattern to 1.57 vvm only at 420 rpm; Oldshue's
  8× rule scales as N³, so at the 255 rpm Chlorella optimum the ceiling was 0.35 vvm, under the
  0.5 vvm design. `docs/agitation.md` carried both as the case for the axial blade until the build
  moved to the standard turbine.
- **`check-holes` proved the arm's holes break through.** It proved only their ends were open. A
  hole drilled down is cut from the outside in, and the probes sat at the outer face and on the
  bore's centreline, both open whether the hole reached the bore or not: an arm whose holes
  stopped 0.4 mm under the bore passed. A third probe now sits in the wall just under the bore, for
  the arm and the loop, and that arm fails on it, three of nine probes solid.
- **The ring and the arm were clean solids.** The ring as `jar_10L` draws it carried two
  non-manifold edges. Its end-plug pilots started exactly on the face the cleaning split cuts, and
  the arm's screw pilot ended exactly on the boss flat it opens through; a cut whose end face is
  the face it opens through leaves a pinch, which the arm's angle happened to round away. A loop
  built as a ring reusing both measured four passages it does not have. Both pilots now run a
  millimetre and more past their face, as the loop's end pilot does, and the ring, the arm and the
  loop count the passages they should: 10, 5 and 10.
- **The loop was a ring teed onto the arm.** The arm's run went in to a split ring, which is two
  spargers spliced, not the pigtail it was for. It is now one tube: elbow, a hook onto the curl
  tangent from outside, and a C to a plugged end. Its pieces meet tangent and lap 0.01 mm into each
  other; meeting exactly face to face, they stayed separate shells and the part measured two
  passages it does not have. The hook costs size where the baffles do not bind: `jar_1p5L` goes
  from 40 to 25.2 mm, `jar_1gal_155` from 47.4 to 31.9 mm and `jar_6p5gal` from 88.6 to 71.5 mm,
  all under the band, which `head()` warns. A tangent lead from the riser keeps nearly the whole
  radius, but on `jar_10L` it runs into the next plate round.

## Settled — do not re-open without new evidence

- **The loop yields to the baffles, not the baffles to the loop.** A ring under the lower impeller
  sits among the plates, and the ring between the impellers had already shown what the other way
  costs: it took the plates from 17.09 to 10.35 mm. The plates come off the lid and set the baffling
  for every build; the loop is an option. So it goes inside their inner edge, less the lean they and
  its own riser can swing through at its height and 1.25 mm, which on `jar_10L` is 1.09 D against
  Birch & Ahmed's 1.4 D, still inside the 1–2 D band.

- **`jar_10L_220x305` runs the loop; every other stirred build keeps the arm.** On the bench under
  lid plates the loop held off them and every hole bubbled with the C level (#70), and it puts the
  gas under the whole lower impeller rather than one side of it. The reference build carries the
  wall cage, whose bars stand at r 61 against the loop's r 41.74, so there it is set by its own
  hook, 1.09 D. `auto` stays the arm, because a build under lid plates sits 1.25 mm off them.

- **The sampler's halves screw together into heat-set inserts; the actuator's screws come up from
  under its face into nuts inside it.** Base to top, three screws go into inserts, as the motor
  mount's do: an M3 nut is 6.4 mm across its corners against the insert's 3.57 mm hole, so nuts
  would widen the corners they sit in, and a loose nut is one more thing to lose with the top
  upside down beside the vessel. One of the three is an M2, from above, because the pin's flange
  stands under the housing's inner end. The actuator first went on with its screws from inside its
  front wall into nuts trapped in the face, and getting it onto four screws it had to carry down
  was the hard part of assembling it; now the screws stand up out of counterbores under the face
  and the actuator drops over them, its nuts inside on a flat to its side wall, which holds them
  while the screws are turned from below. The actuator is unchanged.

- **The impeller's tip ring is OFF by default, and is a flag rather than geometry.** It is a 4 × 4 mm
  annulus tying the blade tips, and it printed as a floating overhang for most of its circumference —
  86.7 % of it unsupported, longest span 61.6 mm. Nothing structural asked for it: one blade carries
  about 0.62 N at the no-load speed, which is 0.31 MPa at the root and 11 µm of tip deflection, two
  orders of magnitude inside what printed PLA holds, and the blades attach to the hub rather than to
  each other. The strike-against-a-baffle case that kept it went with the +2.20 mm running clearance
  (see the correction above). Measured on the exported part: dropping it removes 4328 mm³, a fifth of
  the impeller, and **does not change the swept diameter** — 94.5001 mm either way, because the blade
  corners define it and the ring sat inboard of them. It is also not part of the shape `pbt_45_4`'s
  power number is defined on, so off is the more faithful geometry as well as the more printable one.
  `impeller_tip_ring = true` restores it if the baffle is ever widened enough to need it.

- **the architecture campaign is done, and these are its refusals.** Eight parts are designated end
  to end - vessel, shaft, plug o-ring, strip light, gasket sheet, motor, DO probe, pH probe -
  reaching the geometry, the readbacks and the exported STL. The rules are in
  `docs/design-conventions.md` ("Three layers, and where a parameter lives", "What the customizer
  can and cannot carry"), `check-designations` guards the surface, and the registries carry names,
  part numbers and provenance
- **REWRAPPING `heat_set_inserts` OR `shaft_couplings` into the `set_screws` shape was refused.**
  That template wraps because the LIBRARY owns the geometry and the row adds purchase identity;
  these are the opposite - the project registers the part in NopSCADlib's own schema - so a wrap
  costs about nine call-site edits in `head.scad` to buy uniformity and nothing else. The insert's
  fields ride the row's tail instead, starting at [11] because the library reads [9] and [10]
- **THREADING THE PORT TABLE through its ~53 call sites was refused**, and a guard against the
  hazard was refused with it. `head_interface_for` gives every probe port `bayonet_std` whatever it
  carries, so no expressible designation can move an interface, and an equality guard would be a
  dead assert by the sweep test. **What reopens it** is a designation that can move a port's
  INTERFACE - a thermocouple thread swap - or one that changes the table's count
- **do not hoist the remaining BUILD rows mechanically.** `0304a3a`'s arithmetic: five moved
  declarations bought one carryable number. Relocation without the name-lookup layer multiplies
  duplicated defaults and carries nothing
- **do not build `motor_for` / `air_pump_for` / `coupler_for` yet.** Those registries hold 4, 1 and
  1 rows; a selection over one candidate is a fit check wearing a selector's clothes. Registering
  rows is the prerequisite, not writing selectors

- **A designation is a STRING, and `"auto"` means derive it.** Not `undef`, which the customizer
  cannot see at all, and not a numeric sentinel: `0` litres or `-1` degrees is exactly the plausible
  number that propagates unnoticed, and on a research instrument a negative lean is a value someone
  could be studying rather than a flag. A string is carried, is visible in the surface, and is
  consumed by a mode branch that never multiplies it by anything. Rejected outright: numeric
  sentinels anywhere
- **Cited bands at the pressure boundary may assert; `reasoned, not cited` limits may not.** The
  three o-ring checks guard the seal between culture and room and come from gland practice rather
  than this project's judgement, so they keep refusal authority. The distinction is the provenance,
  not the severity - which is why the mount slenderness limit loses its
- **No `builds/` escape file yet.** The only thing that genuinely cannot ride a parameter set is a
  nested table, and nobody has needed a custom port table - the two registered sets cover all six
  jars. `-D` is the escape hatch. Revisit only if a custom table becomes recurring; if it is ever
  adopted it must never be rendered with `-p`, which silently un-pins the file's own assignments
- **`peri_pump_frame_mount.scad` is left alone deliberately**, `flange_screw_distance = 48.0` and
  all. It is a stretch goal waiting on a faceplate the bought Kamoer has not got, it blocks nothing,
  and the campaign has enough surface. See the pump item above for what it actually needs

Each of these was asked and answered. The reasoning is in the commit that closed it and, where it
outlives the commit, in `docs/`.

- **the motor mount stays at Ø56.** It can go to 42; below that its base inserts hit the bearing
  pocket. Shrinking buys only eccentricity headroom on a vessel that is baffled anyway, and costs
  stiffness - deflection goes as the cube of height over diameter
- **the lid carries three baffles, not four, for a port** (where it carries plates; see the wall
  cage below). Four at 90° is Oldshue's reference;
  he allows three at the same total projected area, and these plates cannot widen to give it, so
  three reach 0.713 of his reference on `jar_10L` against four's 0.951. The fourth baffle's port
  went to a sampling line. Going back to four relays the whole lid, since four equally spaced do
  not land on three-at-120°
- **`jar_10L`'s reference build carries the standard four on the wall, not the lid's three.** The
  advising microalgae researcher asked for the standard set. Lid plates pass the mouth, so they
  cannot reach the wall; four at T/12 against the wall cannot pass the mouth rigid. They go in on
  a cage whose blades slide in to pass it (`docs/agitation.md`, `docs/build.md`), 1.00 of the
  reference area against the plates' 0.713. The lid plates stay for every other build until each
  is checked against a cage; the pH probe moves to the 30° port under it
- **the probes still sit beside baffles at three.** Three baffles leave the middle of each triple
  of ports free of them, but a probe there cannot sit opposite the air inlet, which lands on a
  baffle. DO opposite air in was kept, and the lid is uniform std either way
- **commodity fasteners carry a STANDARD, not a supplier code.** `ISO 4017 M8x30 A2-70` is buyable
  anywhere and does not go stale; nothing in the model reads a property of them beyond nominal size
  and a derived length. The sealing and mount hardware stays pinned by number, because each of those
  carries something a spec does not
- **Cooke's blend-time correlation is deliberately absent.** It could not be made to reproduce the
  figures its own source prints beside it. Ruszkowski's is encoded and was validated first (1.96 s
  against a published 1.9). See `docs/references.md` before trying it again
- **the reference build runs two `impeller_rushton_6` at the standard turbine**: D = T/3, the lower
  T/3 off the floor, the upper a further T/3 up (McCabe, Smith & Harriott 1993 pp. 241-243 and 253),
  on the advice of the microalgae researcher advising the project. The first paper is about the
  design, so the reactor runs at a standard wherever one exists; the pitched pair and a Rushton
  under a pitched blade are knobs for later work (`docs/baseline.md`). The twisted paddle stays
  registered and drawn but has no Po that any correlation reaches
- **the Rushton's power number is Kaiser's measured 4.17, not McCabe's 5.75.** 5.75 is from tanks
  with four baffles at T/10, Kaiser's from laboratory scale, and this vessel has three plates at
  0.71 of the four-at-T/12 area, so neither is measured at it. At 5.75 the torque is still under
  0.087 N·m of the drive's 0.490, so no choice in the build turns on it; a bench measurement of the
  printed part replaces both
- **the shaft is 400 mm and must be a ground rotary shaft.** 300 mm does not exist in the catalogue
  and 200 cannot reach. It runs directly in the 608 bearing's inner race, so plain h9 rod would allow
  0.043 mm and fret the bore
- **the sparge ring sits in the gap between the impellers**, from Birch & Ahmed: above an up-pumping
  impeller, below a down-pumping one. The pitched pair converged, so one ring served both; two
  Rushtons discharge radially and nothing held here places a ring for them; the shaft
  drive's default is the arm. Supersedes
  Oldshue p. 214's 80 %-of-impeller ring, which two experimental studies contradict
- **the spargers' holes are 16 × 1 mm, for bubble size; they were 8 × 3 mm against fouling.** The
  culture photos show almost no buildup on the sparger, and 3 mm cost bubble size: 5.10 mm at
  formation against 3.53. Barbosa's 5.4 m/s and an open area of 1 multiply to the bore's own
  5.42 m/s, so 1 mm × 16 sits on that corner, and its 49 Pa a hole outweighs the bore's 18 Pa of
  velocity head, which 3 mm's 2.4 Pa did not. Capillary is 288 Pa, so they still will not share
  equally at any count. The arm fits ten at the pitch floor on `jar_10L`, at 8.67 m/s
- **the spargers' holes are 1.2 mm, not 1.** 1 mm came out too small on a print. 16 × 1.2 mm runs
  3.76 m/s at an open area of 1.44, past 1, so the holes nearest the feed take more of the gas;
  its 24 Pa a hole still outweighs the bore's 18 Pa of velocity head. Bubbles are 3.76 mm at
  formation, and the arm fits eight on `jar_10L`, at 7.53 m/s
- **the working volume is DERIVED from a fraction of capacity, not pinned in litres.** 0.865 of what
  the jar holds, which is 8.17035 L on jar_10L and scales to every registered vessel. A litre figure
  is a statement about one jar: 8.25 L left jar_6p5gal_305x470's thermocouple in the headspace and
  stopped that vessel rendering at all
- **the riser is welded hard-temper 316, not seamless soft.** Temper does not move the modulus, but a
  support tube that stays where it is put is the whole point - and it is $22.72/m against $181.42
- **the plug o-ring cord is 3/32 in, not 1/8.** The groove and the port bores are cut into the same
  wall, so a fatter cord fouls the bores on every vessel rather than just a tight one
- **the lid joint is instructed as a TURN, not a torque, and that is not an omission.** 351.0 N per
  post is 0.56 to 0.84 N.m across the 0.20-0.30 nut factor unlubricated 18-8 spans - a 40 % band
  from friction alone, on a fastener that galls, at a setting below most torque wrenches. The turn
  is the gasket's travel over the thread's pitch and has no modulus or friction in it. Both are in
  `docs/build.md`; the torque is there to say why it is not the instruction
- **the lid follows the frame's outer diameter, and trimming it buys nothing.** It was cut to 252
  once - its own floor, being the bolt circle plus a bore plus wall - because 257.40 put it past
  every 256 mm machine by 1.4 mm. Then the FRAME was measured: its base and top base are 257.40 as
  well, and its wall cannot come down because the rod bosses want 36.8 mm of it. So the trim thinned
  the lid's flange and put a 2.7 mm step in the joint to reach a printer the frame ruled out anyway.
  What can print this is REPORTED by bioreactor.scad instead of designed to
- **the baffle cap is a PRINT-QUALITY rule, not a bed one.** It was a literal 170 defended by
  180 mm machines, which could never have built this reactor at all. It is now a piece's height
  against three times its own section - a brim as wide as the part on each side - and the piece that
  binds is the TIP, not the one carrying the port: a flange is a wide foot, so the bare plate is
  half again as slender. Do not re-derive it from a printer; that is the mistake it replaced
- **the riser's gland is an ENCLOSED GROOVE above a 1.2 mm lip.** A counterbore open to the vessel
  has nothing under the cord, so an unseated ring drops into the culture - which is what it did.
  Pressure still seats the cord on the upper shoulder; the lip holds it when there is none. The ring
  is folded and pushed up the bore past the lip, which a printed port proved is reasonable by hand.
  Reversed 2026-09 - see Corrections
- **lights per cord is registered, and it does NOT decide how many lights there are.** These are
  sold as a cord and a controller driving a fixed number of tubes, so a layout that is not a whole
  number of cords buys the next one up. frame() reports the cords a layout needs; the layout stays
  an illumination decision. Deriving the count from the packaging would be letting the shop set the
  design, which is the direction the arrow must not point
- **the baffle's resonance check asks WHERE the mode is crossed, not whether it is near one.** It
  compared the mode against the excitations at the drive's fastest setting and warned within 30 %,
  which is right for load and wrong for resonance: a DC motor sweeps every frequency below its
  maximum, so something is always crossed on the way up. What matters is the SPEED of the crossing
  and whether the drive is asked to hold it - 264 rpm on the 10 mm plate against a 320-420 band, and
  the clearance to that band is reported because that is what separates a 10 mm plate from an 11
- **`check-mesh` is not in `just check`** - it renders solids, which is minutes to tens of minutes.
  The `$fn=0` second pass IS in `check-scad`, because that recipe is the cheap one. Both were proved
  to FIRE on a deliberately broken input before being trusted
- **the two gas-driven jars are registered as airlifts, not bubble columns.** Take the draft tube
  out of the airlift build and what is left is the bubble column: the same lid and parts but for
  the ring, drawn in a few millimetres to fit inside the tube with its supports cut to match, and
  the DO port, which hangs its probe straight. A second registration would export near-duplicate
  parts for a build the airlift's already make.
  `drive_name = "none"` stays a drive the model builds; it is no longer a build the export writes
- **under the airlift the DO probe hangs straight.** Its lean exists to take the tip out of the
  shaft's shadow toward the flow (`docs/ports-layout.md`), and inside the riser there is no shaft and
  the whole core flows. Leaning it only walks it toward a tube that can shift up to 2.5 mm: with
  the tube among its obstacles the lean derived to within 0.08 mm of the wall on `jar_1p5L`, less
  than the tube's own play
- **a magnetic build wanting more floor than the base gives stands on a riser.** The base stays the
  light's floor, so it is one print for every drive on its jar and an airlift build does not grow
  for a drive it lacks. A hollowed deep base was the other way: one print, but under every
  drive, and it moved the jar against the lights. The riser is walls only, so it prints as it
  stands, and it keeps the carrier as it was by carrying the base's slot. `jar_1p5L` keeps its sunk
  floor: its 3.77 mm is far short of the 23.8 mm a riser needs to hold the carrier's ear
