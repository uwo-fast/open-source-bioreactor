# Decisions

Two kinds of record, and they answer different questions.

**Settled** is what was decided and why, so it is not quietly redone. Do not re-open an entry
without new evidence — and when you do have it, rewrite the entry rather than leaving it standing
beside the thing that replaced it.

**Corrections** is what this project believed and got wrong. Each entry keeps the old reading in
full, because a figure that survived review is worth more as a warning than as a deletion: most of
them were not typos but readings that were coherent, agreed with the documents around them, and were
measuring the wrong thing. `TODO.md` carries open work only; nothing here is a task.

Corrections to a document's own prose stay in that document, marked `(Superseded — kept for the
record)` where they sit — `docs/design-conventions.md` on the rim datum, `docs/agitation.md` on the
impeller-count threshold, `docs/procurement.md` on the meter spread, `docs/references.md` on Davis.

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
  what makes it not a test.
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
- **A DC fan runs 1000–3000 rpm where this design wants 320–420.** The band was the reference
  build's drive on a 94.5 mm impeller, applied to jars whose impellers are half that. The target is
  tip speed, and holding it puts `jar_1p5L` at 528–851 rpm and `jar_1gal_155` at 358–577 — nearer a
  fan's native range than it looked.

## Settled — do not re-open without new evidence

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
- **the twelve big ports cannot be spread so that no two are adjacent.** Four baffles equally spaced
  on twelve ports sit every third port, which leaves no port not adjacent to one. Geometry, not
  tuning. It becomes possible at three baffles, which is a trade against baffle area recorded in
  `docs/ports-layout.md`
- **commodity fasteners carry a STANDARD, not a supplier code.** `ISO 4017 M8x30 A2-70` is buyable
  anywhere and does not go stale; nothing in the model reads a property of them beyond nominal size
  and a derived length. The sealing and mount hardware stays pinned by number, because each of those
  carries something a spec does not
- **Cooke's blend-time correlation is deliberately absent.** It could not be made to reproduce the
  figures its own source prints beside it. Ruszkowski's is encoded and was validated first (1.96 s
  against a published 1.9). See `docs/references.md` before trying it again
- **the build runs `impeller_pbt_45_4`, not the twisted paddle.** Po and flow number come from
  Medek's correlation on that geometry; the twisted row stays registered and drawn but has no Po that
  any correlation reaches
- **the shaft is 400 mm and must be a ground rotary shaft.** 300 mm does not exist in the catalogue
  and 200 cannot reach. It runs directly in the 608 bearing's inner race, so plain h9 rod would allow
  0.043 mm and fret the bore
- **the sparge ring sits in the gap between the impellers**, from Birch & Ahmed: above an up-pumping
  impeller, below a down-pumping one. This pair converges, so one ring serves both. Supersedes
  Oldshue p. 214's 80 %-of-impeller ring, which two experimental studies contradict
- **the ring's 8 × 3 mm holes are for spacing and against fouling, not for even flow.** Capillary is
  96 Pa against 2.4 Pa of orifice, so they will not share equally at any count
- **the working volume is DERIVED from a fraction of capacity, not pinned in litres.** 0.865 of what
  the jar holds, which is 8.22105 L on jar_10L and scales to every registered vessel. A litre figure
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
