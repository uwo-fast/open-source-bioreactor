# TODO

Open work only. A finished item is deleted rather than kept ticked - its reasoning is in the commit
that closed it and in `docs/`, and a page of them buries what is actually left. The exception is the
ledger at the end: decisions that took real work to reach and would otherwise be quietly redone.

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump

- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)

- [ ] **measured gas flow** — a reproducibility gap, not a geometry one. **The parts are chosen and in the BOM: Dwyer `VFA-23` bare meter, C$86.22, and a Clippard `MNV-3KP` needle valve, US$15.11, the valve upstream of the meter. What is left is buying them and taking a reading.**
  - the gap it closes: the model states a vvm and no builder can set one. Against the real line the
    registered ReSun pump gives **23.1 L/min** where **0.825-4.125** is wanted, so it runs at a few
    percent of rating with nothing metering it. That boundary condition is unrepeatable between runs
    and between builders, which is the reproducibility this project claims. Why these parts rather
    than the others is in `docs/procurement.md`
  - still unpublished and worth one email: the meter's **graduation interval**. Not a blocker - over
    a 70 mm scale it resolves finer than the ±0.25 L/min its ±5 %-of-full-scale accuracy allows
  - **the CO₂ question is answered by a run, not by a calculation.** Air at 0.5 vvm supports about
    0.09 g/L/day on a 30 % utilisation assumption, short of the 1 g/L/day that would need ~0.47 %
    CO₂ - eleven times atmospheric, and there is no CO₂ source in the BOM. But
    `analysis/runs/2026-07-23-chlorella-ccpc90` grew *C. vulgaris* CCPC 90 for 8.7 days on air alone
    with no pH control, and the target is growing Chlorella reproducibly. The nutrient feed does not
    change it: 0.2 g/L Miracle-Gro in DI water, unbuffered, whose urea carbon is worth ~0.035 g/L of
    biomass *in total* rather than per day. This is not a mixotrophic culture
  - **and no sparger geometry is waiting on any of it.** `sparge_design_vvm` appears only inside echo
    strings - 0.1 and 2.0 vvm render byte-identical geometry - and the drawn 8 × 3 mm holes cover
    **0.25-2 vvm** inside the only orifice-velocity range anyone has tested (Barbosa's 0.4-5.4 m/s).
    Enrichment happens upstream of the sterile filter, so air or air+CO₂ is a bench change
  - what none of it settles is this reactor's **actual CO₂ utilisation efficiency**, which is the
    assumption the 0.09 g/L/day turns on and is measurable here. The honest framing for a paper is a
    CO₂ inventory problem, where the enrichment fraction is a bigger lever on productivity than the
    entire sparger study was

- [ ] **two of six registered vessels do not build**, and one of them for two reasons
  - **`jar_1p5L_109x215` and `jar_1gal_155x251` cannot carry a top-entry drive on their lids at
    all.** Their port flanges leave 27.1 and 35.4 mm where the motor mount's own floor is 42, so
    they are 14.9 and 6.6 mm of diameter short. No lid or mount change reaches it
  - **and `jar_1gal_155x251` fails on the probe FIRST**, which the meridian check exposed: a
    vertical DO probe runs 6.29 mm through the upper impeller radially. Not a tilt problem -
    `check-vessels` sweeps both leans flat and it fails anyway, so the port circle and the impeller
    want the same radius in a 155 mm bore. So fixing the mount would not unblock that jar, which one
    recorded cause implied it would
  - the answer to both is the narrow-jar agitation question, tracked under "drive and aeration".
    Nothing else in the model is waiting on it

- [ ] **the riser has 2 mm of slack through its port, and nothing seals it**
  - the 4 mm tube passes a 6 mm port bore, so it is neither centred nor sealed by the port. That is
    the tube port's business rather than the sparger's, and it is the last of the four sparger
    follow-ups still open - the other three (tubes ending flush with the lid, telling the feed socket
    from a support, where to drill a support tube) are done
  - it matters in both directions: the feed riser leaks gas the rotameter has already counted, and a
    support tube is a dead leg into the headspace

- [ ] **measure the sterile filter's pressure drop**
  - `sparge_filter_drop_slope = 3.45` kPa per L/min is EXTRAPOLATED from an equivalent 0.2 um PTFE
    disc, not measured, and Cole-Parmer publish no curve for 1594522. It is the largest single term
    in the gas budget, so it is the largest thing in the model taken on an approximation
  - a water manometer across it at the set flow settles it. Ten minutes, and it turns the whole gas
    chain from estimated to measured
  - it is corroborated, not invented: area-correcting Pall's Acro 50 from 19.6 to this filter's
    16.2 cm2 gives 3.02 against the 3.45 used, so the figure sits 14 % conservative
  - **the operational number that falls out: 1.65x of loading headroom.** The filter may rise to
    23.3 kPa with the valve wide open before 0.5 vvm becomes unreachable. So "the valve is fully
    open and it still will not hold 0.5 vvm" is the replace-the-filter signal, and that belongs in
    the build notes

- [ ] **where the sparger's gas actually goes, and whether the DO probe should be somewhere else**
  - **the placement is the opposite of what was expected.** The DO probe was thought to sit in a slow
    corner between a baffle and the wall. It does not: its face sits **20.6 mm above the sparge
    ring's centreline and 0.87 mm off its radius**, directly over a ring of bubbles, in the
    convergence zone between two counter-pumping impellers. So it is the one placement that can be
    wrong in **both directions at once** - a galvanic probe reads HIGH with a bubble on the membrane
    and LOW with nothing moving past it
  - the geometry is exact and the gas is not modelled at all. The holes discharge INWARD, toward the
    impeller, so hanging vertical may be further INTO the plume rather than out of it. No source
    found gives DO probe placement relative to a sparger - Mettler-Toledo and Eppendorf both refused
    to be fetched, and Atlas's own bioreactor note has nothing on placement
  - the flow RATE is not the concern: 60 mL/min over the probe's sensing face is 8.84 mm/s against a
    bulk 145 mm/s at the rated speed, **16x**, and it would still be met at about 20 rpm. That is a
    bulk mean and `head()` reports it as one - it says the tank moves, not that the probe's own
    corner of it does
  - it is a bench question rather than a modelling one: run it, watch the DO trace, and see whether
    it is noisy. A galvanic probe with bubbles crossing the membrane gives a characteristic spiky
    trace, which is diagnosable without any more model
  - what the model can offer if it turns out to matter: the probe port circle is fixed at 56.9 and
    the ring's radius is the outermost the mouth allows, so the free variables are the LEAN and the
    ring's height. Both are already parameters

- [ ] caliper the real jar rim against the registered profile
  - the lid's gasket recess is cut to the flat land on top of the glass, which the model puts at 5.00 mm wide (r 71.5 out to 76.5) with a 2 mm bead rolled outboard below it. That land comes from the registered `rim_radius` and wall thickness rather than from a measurement, and the recess width follows from it, so it is worth confirming before cutting a gasket to it
  - **and two jars are already provably inconsistent up there.** `vessel_neck_corner_radius()` is
    SOLVED from the measured mouth bore rather than registered, and nothing checked the result
    against the wall. It comes out smaller than the wall on two rows:

    | vessel | neck corner | wall | shortfall |
    | --- | --- | --- | --- |
    | `jar_1gal_180x197` | 3.5 mm | 5 mm | 1.5 mm |
    | `jar_1p5L_109x215` | 3.36 mm | 4 mm | 0.64 mm |

  - what that does to the shape: the shoulder's OUTER face tops out `t - Rn` above the neck's
    bottom, so the outside has to come back DOWN to meet the neck. Measured on `jar_1gal_180x197`,
    the outer surface rises to z 186 and the neck starts at 184.5 - a notch running right round the
    neck root. The section is still manifold, which is why nothing ever caught it
  - `vessel()` already asserted exactly this failure for the BODY corners - "a corner tighter than
    the wall would invert its arc" - and simply omitted the neck, which is the one corner whose
    radius is derived rather than registered. It now REPORTS it instead of asserting: the shape is
    expressible rather than impossible, and asserting would move a jar that currently builds into
    `check-vessels`' broken list on the strength of an eyeballed number
  - **which of the three is wrong is the caliper question.** `corner_radius` is the one the registry
    itself calls the eyeballed value, and at or under 11 mm on the 1 gal and 6.86 on the 1.5 L it
    clears; they are registered at 12.5 and 7.5. But `opening_diameter` and `thickness` are
    measurements too and either could be the one that is off

- [ ] **jar_10L's baffle can reach the blades, and the next action is a MEASUREMENT**
  - 2 mm nominal clearance to the impeller, less the 2.28 mm of lean the coupling's 0.2 mm of play
    allows at the lower impeller, so **-0.28 mm running**. Reported every render, not asserted, and
    nothing is printed yet. Thickness does not touch it: it is a tolerance stack, not a stiffness
    one, and the deflection half of this item is closed (the plate is 10 mm - see `docs/agitation.md`)
  - **what the number actually is.** 0.2 mm of bayonet play over 18 mm of engagement, levered out
    205 mm to the lower impeller: an **11.4x amplification**, which is why a fit clearance smaller
    than a layer height ends up larger than the whole gap. Attacking the amplification is worth more
    than widening the gap
  - **but 2.28 mm is bore play ALONE.** The model tilts the plate as if the pin were free to cock
    inside its bore. It is not: the baffle's flange seats on the lid face across a much larger
    diameter, and a face contact resists tilt far harder than a bore does - the o-ring under it is
    the only thing that lets it rock at all. So the real lean is somewhere between 2.28 mm and
    almost nothing, and **nothing in the model can tell which**
  - **do this first:** print the lid's baffle port and one baffle top segment, seat them, and measure
    the tilt at a known distance below the lid. Twenty minutes, no parts, and it replaces a stacked
    worst case with a number - which is how the rest of this model has been settled
  - **the fixes, if the measurement confirms it**, in order of what they cost:
    - *taper the plate's inner edge with depth* so it matches the lean, which is worst at the bottom
      and zero at the lid. Buys the clearance for about half the area a uniform cut costs - roughly
      0.79 of reference against 0.744. New geometry in `bayonet_baffle_port.scad`
    - *`baffle_impeller_clearance` 2 -> 3*. One line, running clearance +0.72 mm, but width goes
      15.3 -> 13.3 and area 0.856 -> 0.744, which deepens the under-baffling warning already firing.
      Trades a warning for a warning
    - *deepen the bayonet engagement to 36 mm*. Halves the lean, costs no area - but the stack height
      grows, which pushes the plate from 2 printed pieces to 3 and adds a third dovetail joint, and
      joints already take 14 % of the deflection
    - *a baffle-only interface row at 0.1 mm allowance*. Free in the model, no area or print cost,
      but 0.1 mm is a tight printed bayonet fit on the one port that gets twisted by hand at arm's
      length inside a jar
  - **and the resonance check only looks at one speed** - a separate gap, and a real one. It tests
    the mode against the excitations at the drive's *fastest* setting, on the grounds that fastest is
    worst. That is right for load and wrong for resonance: a DC motor's speed is continuous, so blade
    passing sweeps every frequency under 28 Hz and something is always crossed. What decides the
    plate is the SPEED at which the crossing happens and whether the reactor runs there - 264 rpm on
    the 10 mm plate, against a 320-420 band - and the echo does not say it

- [ ] **the impeller's tip ring cannot print without support, and nothing has asked whether it earns it**
  - it is a 4 x 4 mm annulus tying the four blade tips, sitting inboard of `impeller_radius`. Measured
    off the exported blade by sampling its underside all the way round: **86.7 % of the ring floats**,
    and the longest unsupported span is **61.6 mm**, four times over. A 45 degree blade prints itself;
    the ring hanging between the blades does not
  - **the steady load does not need it.** One blade carries about 0.62 N at the 420 rpm no-load
    speed. Root bending is 15.8 N·mm on a section modulus of 50.4 mm3, so **0.31 MPa** - roughly one
    percent of printed PLA cross-layer strength - and the blade's own tip deflects **11 um**. The
    ring is two orders of magnitude past what the fluid asks for
  - **the strike case is the argument that keeps it.** The same jar's baffle running clearance is
    -0.28 mm, so a plate CAN reach the blades. A ring ties all four tips so a strike is reacted by
    the set rather than levering one blade. That is an impact case and no number here covers it
  - so it is a real decision, not an oversight: pay for support material and a scarred inner face on
    every impeller, or drop the ring and rely on the blade being 100x over-strength against
    everything except a collision the clearance stack already allows. **Deciding it is downstream of
    deciding the -0.28 mm**, which is the item above
  - the ring is also not part of the geometry `pbt_45_4`'s power number is defined on. Neither is a
    4 mm plate on a 94.5 mm impeller: **t/D 0.042** against roughly 0.02 for the standard PBT the
    correlations were measured on, and thickness is not a term in Medek's correlation at all. Both
    are printed-part departures from a correlated shape, unquantified in the same direction

## drive and aeration

Follows from the agitation work; the reasoning and citations are in `docs/agitation.md`.

- [ ] **two things to confirm on the drive before ordering it**
  - the encoder sheet for `motor_36pg_555pm_14_en` tabulates NO gearbox length, so the registered
    **34.5 mm is inferred** from the 3429 sheet at the same 14:1, and the sheet does not dimension
    the encoder past the can either. Both feed the reactor envelope (579.25 mm) and the cart, which
    stacks two tiers, so every millimetre counts twice
  - caliper the **bolt circle on the printed mount**: Ø28 with M4 should clear holes cut for the
    36GP's Ø27.6 / 4.2, so the new motor may drop in without a reprint

- [ ] bench-measure the twisted paddle's power number, IF it is wanted back
  - **demoted, not done.** The build no longer selects `impeller_twisted_paddle_4`; it runs
    `impeller_pbt_45_4`, whose Po and flow number come from Medek's correlation and whose blade
    width is Fořt's h/D 0.2. So nothing in the model now depends on an unmeasured number
  - the twisted row stays registered and `head()` still draws it. What it still lacks is a Po - no
    correlation reaches a constant-pitch helicoid at 83 degrees of blade angle at the hub falling to
    53 at the tip, Medek's envelope stops at 60, and Ameur's helical-screw work is viscous and
    laminar where this vessel is Re 47,000. Its 0.634921 width ratio is now the only geometric ratio
    in `impellers.scad` with no source behind it
  - a bench measurement would settle both: `Po = P/(rho*N^3*D^5)` from shaft power at three or four
    known speeds in water, across printed variants. Worth doing to publish the blade, not to build
    the reactor
  - one paywalled source might yet say something - Kumaresan & Joshi 2006,
    doi:10.1016/j.cej.2005.10.002, worth an interlibrary request

- [ ] settle how the narrow jars are agitated — **the family question these two items answer**
  - `jar_1p5L` and `jar_1gal_155` cannot carry a top-entry drive on their lids at any mount size, and they cannot hold baffles beside two Ø16 probes at any port count. A stirred version of either would be a centred shaft in an unbaffled vessel, which Montante measured at a flow number 65% below the same impeller baffled - swirl, not mixing
  - so the answer is not a smaller mount, it is a different mode. Two are on the table below and they are **separate design items, neither scheduled**. Nothing about the current build waits on them
  - what makes this worth doing rather than dropping the two jars: a family that spans three agitation modes off one lid and one sparger is a stronger claim than one mode across six jars, and it is the claim the paper would actually be making

- [ ] explore an airlift variant of the sparger, with no impeller at all
  - falls out of the port work: mouths under about 98 mm cannot hold four baffles beside two Ø16
    Atlas probes at any port count, so the small jars are unbaffled whatever else is decided. See
    `working.tmp/PORTS-options.md` for where that number comes from
  - the small jars visibly *do* mix on the air alone. That is not a reason to rely on it. Aeration
    that mixes as a side effect is an uncontrolled variable: the gas rate is then setting both kLa
    and the mixing time, they cannot be varied independently, and nothing in the model would say
    what the vessel is actually doing. Leaning on it would be sloppy in exactly the way this design
    is trying not to be
  - the honest version is to *design* for it: a real airlift, so the circulation is a geometry we
    chose and can report. A draft tube gives a defined riser and downcomer, so the circulation
    velocity follows from the gas holdup difference between them rather than from luck
  - it is also the more interesting variant for the paper. An impeller-free vessel drops the motor,
    the gearbox, the shaft, the coupling, the bearing and the seal - most of the cost and nearly all
    of the contamination risk - and photobioreactors are one of the few applications where that is
    a normal choice rather than a compromise
  - what it would need in the model: a draft tube as a part, riser and downcomer areas as derived
    quantities, superficial gas velocity, and a reported circulation time to sit beside the
    existing mixing reports. The sparge ring may or may not survive - an airlift usually wants the
    gas inside the draft tube, not in a ring at 1.44 D
  - explicitly parked, not scheduled. Nothing here blocks the current build

- [ ] explore a magnetic drive: a DC fan under the jar turning a rotor inside it
  - a square DC fan below the vessel, a printed hub on its centre boss carrying two magnets facing up, and a magnet inside the vessel - either a stir bar or, better here, a magnet potted into a printed rotor. Nothing crosses the boundary, so it retires the shaft, the coupling, the bearing, the plug seal around the shaft AND the motor mount in one move. The lid becomes ports and a seal
  - it is the obvious answer at this scale - it is what a lab does - and it is the one mode that removes the constraint rather than working around it
  - **the punt is what decides it, and no jar here has a flat centre.** The registry: `jar_1p5L` a 15 mm dimple 7 tall on a 4 mm base, `jar_1gal_155` a 73 mm dome 6 tall on 3 mm, `jar_10L` 30 mm and 5 on 5 mm, `jar_6p5gal` a 160 mm dome 15 tall on a 12 mm base. A conventional bar straddles all of them
  - which is why the rotor is the interesting part rather than the magnets: a printed impeller with a central recess that sits OVER the punt and pivots on it, magnets in its rim. The punt stops being an obstacle and becomes the bearing
  - the number that has to be run before any of it: coupling torque across the gap, which is base wall plus punt height plus clearance. That is about 11 mm on `jar_1p5L` and about 27 on `jar_6p5gal`, against the 5-10 mm a lab stir plate typically works through. **Magnetic is most viable exactly where it is most needed** - thin base, small punt - and probably not viable at all on the big jars
  - also unsettled: a DC fan runs 1000-3000 rpm where this design wants 320-420, so it needs PWM and a way to know the actual speed. Fan torque is low, which is fine for a 1.5 L jar and likely not for anything larger
  - separate design item, not scheduled

## nice to haves

- [ ] Add curve / inflection point to holes in bayonet connectors to grip tubes better
  - sehan's idea, currently they grip really tight already so this is just a thought for improving the design if we find the tubes are slipping out too easily in testing; or if we wanted to reduce the interference fit and make it easier to insert the tubes in the first place while keeping them from slipping out

- [ ] optional end styles (sensor gland) for atlas probes to match product more closely

- [ ] register lights per cord on the strip lights and drive the frame from it
  - recorded in the row comments for now: `rwntao_13in` is 3 tubes per cord, the three `grow_*` are 4. `lights_per_quadrant` in `frame.scad` is still set by hand and has no relation to what a cord actually carries
  - `strip_lights.scad` would gain the count, and `frame.scad` would derive placement from it rather than from a free parameter — cords come in fixed multiples, so the current setup can ask for a light count no purchasable product provides

## tooling / infrastructure / documentation

- [ ] **no assembly torque is specified anywhere, and the glass is what limits it**
  - `head()` reports **291.8 N per post** to hold the gasket at 25 % squeeze, which on M8 is about
    **0.6 N·m** - finger tight with a short wrench. A published M8 A2-70 figure is 20-24 N·m,
    roughly **40x** that, and the design point already puts **2.51 MPa on the jar's rim**
  - so the bolts are preload-limited by the SODA-LIME JAR, not by the fastener, and nothing
    anywhere says so. Torquing them to fastener spec is how the jar gets cracked
  - it is a build-instruction gap rather than a model one - the number is already computed and
    echoed. What is missing is somewhere for a builder to read it, and a tightening pattern
  - worth deciding at the same time whether the gasket recess is meant to bottom out as a stop.
    It is 1.19 mm deep for a 1.5875 mm sheet, so at 25 % squeeze the gasket is flush and the
    printed flange meets glass. That either is the stop or is the thing to avoid, and which one is
    not recorded
  - **the arithmetic says it cannot be the stop.** The gasket's section is 3 x 1.5875 = 4.76 mm2 and
    the recess's is 3 x 1.19 = 3.57 mm2, so the recess holds three quarters of the rubber that has to
    fit in it. Elastomer is near enough incompressible - bulk modulus about 2 GPa against a shear
    modulus of 1.2 MPa - so the flange cannot reach the glass until a quarter of the gasket has left
    the recess, and the only way out is sideways across the 1 mm bearing lands. The flange would then
    bottom on extruded rubber rather than on glass
  - it also disagrees with the load model. `gasket_shape_factor()` is `width / (2 * thickness)`, the
    FREE-bulge form: it assumes both edges of the pad can bulge, and the recess walls are exactly
    where they cannot. So the 291.8 N per post and the 2.51 MPa on the glass describe a pad that is
    not the one drawn - reported, not asserted, and `gasket_load.scad` already says its figures are
    for judging a design rather than cutting a part to
  - the usual rule for a confined flat gasket is groove section at or above gasket section, commonly
    10-25 % over. Widening the recess is what buys that, and the 1 mm lands either side are what it
    would come out of. Not chased here: it changes the lid, and the rim profile it is all measured
    against is itself uncalipered - see the caliper item above

- [ ] add PowerShell and shell scripts to export a chosen assembly parameter set as individual STL files, together with a print list, BOM, and other relevant build outputs
  - **the JSON half is done.** `just json` writes `scad/assembly.json` and `scad/head.json` from the vessel registry, one set per jar, and `openscad -p scad/assembly.json -P <vessel>` selects one. `check-json` fails if either file is stale or its dropdown has drifted
  - what closed it was not the format but being able to CHOOSE: `reactor_vessel` was a reference to a registry variable, and a parameter file carries values, so under `-p` OpenSCAD dropped it and every set built the same jar. It selects by name now
  - what is left is the scripting: walk the sets, export each part to STL, and emit the print list and BOM beside them. Four of six vessels build today, so two of the six sets would fail - which is worth REPORTING rather than hiding, the same way `check-vessels` records what does not build
  - only `reactor_vessel_name` is name-selectable so far. The other fourteen registry choices - motor, gearbox, impeller, bayonet, gasket sheet, bearing, fasteners - are still variable references and would need the same treatment before a set could vary them. Not needed for a per-vessel export, and not worth doing until something wants to vary them
  - **it also closes a hole in `check-mesh`.** That recipe renders per FILE, and `custom/impeller.scad`'s own example passes no `blade_pitch`, so it renders the TWISTED path - the pitched blade that was tangent to its hub is reached only through `head.scad`, which is on the slow list. So today's default sweep would not have caught the bug the recipe was written for. Per-PART rendering is what fixes it
  - the print list has to carry the **sparge ring**, which is printed and therefore has no BOM row - the one part a purchase list cannot remind you to make

- [ ] run `tokei` in CI to report lines of code and other codebase statistics

- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based OpenSCAD preview

## second hardware revision

- [ ] swap out the threaded rods with printed parts

## settled — do not re-open without new evidence

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
- **the working volume is pinned at 8.25 L, not a rounder 8.0.** At 8.0 the coverage over the upper
  impeller falls to 0.479 D against the 0.5 this project holds
- **the riser is welded hard-temper 316, not seamless soft.** Temper does not move the modulus, but a
  support tube that stays where it is put is the whole point - and it is $22.72/m against $181.42
- **the plug o-ring cord is 3/32 in, not 1/8.** The groove and the port bores are cut into the same
  wall, so a fatter cord fouls the bores on every vessel rather than just a tight one
- **`check-mesh` is not in `just check`** - it renders solids, which is minutes to tens of minutes.
  The `$fn=0` second pass IS in `check-scad`, because that recipe is the cheap one. Both were proved
  to FIRE on a deliberately broken input before being trusted
