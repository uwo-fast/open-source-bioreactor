# TODO

Open work only. A finished item is deleted rather than kept ticked - a page of them buries what is
actually left. What was decided, and what this project got wrong on the way, is in
`docs/decisions.md`; the reasoning behind a closed item is in the commit that closed it and in
`docs/`.

## model completeness / enhancement

- [ ] **place the bought pumps in the assembly, which needs the frame mount rethought**
  - the registry half is done. `purchased/peri_pumps.scad` carries the **Kamoer NKP-DC-S10B** with
    its part number, its 67 x 55 x 41 envelope and its 3 x 5 mm tube, and `purchased/peri_pump.scad`
    draws that envelope as a vitamin. `check-bom` guards the row - proved to fail on a wrong part
    number - and `head()` checks the pump's tube against the port it has to enter: 5 mm into a
    4.8 mm bore, **0.2 mm of interference, which is what grips it**
  - the printed head moved to `custom/peri_pump_head.scad`, one file, prefixed so it cannot collide
    with the bought part. It is an entry file now, so it renders and is mesh-checked rather than
    sitting as an unbuilt work in progress. It is a stretch goal and not this build
  - **what is left is placement, and the mount is what blocks it.** `peri_pump_frame_mount.scad`
    still assumes the printed path: it says it seats in pockets `frame.scad` does not have, it
    collars `motor_12v_5w` which is on no purchase list, and its `flange_screw_distance = 48.0`
    waits on a faceplate a snap-in Kamoer has not got. A bought unit wants a bracket that holds a
    67 x 55 x 41 body, which is a different part rather than a modified one
  - and the frame needs somewhere to put three of them: pockets, or a rail, or hanging off the
    electronics stand. That is a design decision rather than a parameter, and nothing else waits
    on it - the reference run had the dose pumps disabled throughout

- [ ] **measured gas flow** — a reproducibility gap, not a geometry one. **The parts are chosen and in the BOM: Dwyer `VFA-23` bare meter, C$86.22, and a Clippard `MNV-3KP` needle valve, US$15.11, the valve upstream of the meter. What is left is buying them and taking a reading.**
  - the gap it closes: the model states a vvm and no builder can set one. Against the real line the
    registered ReSun pump settles at **6.05 L/min** where **0.823-4.12** is wanted, so it runs at
    a fraction of rating with nothing metering it. That boundary condition is unrepeatable between runs
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

- [ ] **two of the five swept vessels do not render from `assembly.scad`**, and both for the drive
  - `jar_1p5L_109x215`'s port flanges leave 27.1 mm against a 56 mm motor mount; dropping the mount
    to 47.5 - the smallest registered motor plus two walls - still leaves it 8.2 mm short, and D/T
    does not move it. `jar_1gal_155x251` needs D/T under about 0.37 AND a mount under 39.4 mm, and
    at 39.4 the mount's inserts overlap the bearing pocket by 1.15 mm instead. Shrinking the mount
    only moves the failure
  - **`jar_1gal_155x251`'s probe conflict is the pH probe, not the DO probe.** It was recorded as a
    vertical DO probe through the upper impeller, which is what a flat sweep shows; lean the DO
    probe out and it clears, and the pH probe - vertical by Yokogawa's requirement, and the long one
    - runs 6.29 mm through the LOWER impeller. No DO lean reaches that.
  - the answer to both is the narrow-jar agitation question, tracked under "drive and aeration".
    Nothing else in the model is waiting on it

- [ ] **choose an outlet filter that fits in 1.93365 kPa/L/min, because the obvious one does not**
  - the exhaust is unguarded: the headspace vents through a support tube's bore into the room while
    a 0.2 um filter guards the inlet, which is half the usual arrangement. `head()` says so on every
    render now rather than leaving it to a document
  - **the second 1594522 does not work, which is what this item found.** It looked free - the filter
    is sold in tens - but an outlet filter raises the headspace the sparge holes discharge into. Two
    of them put the line at **31.8 kPa** against a pump that dead-heads at 27, and the reactor
    settles at **3.27 L/min**: 0.5 vvm stops being a setting it can hold
  - the model reports the budget instead of a part: **at most 1.93365 kPa per L/min**, 56.0 % of the
    inlet filter's slope, so roughly twice the membrane area. `sparge_outlet_filter_drop_slope` is
    undef until something is chosen; set it and head() prices the exhaust into the line
  - **the budget is GROSS, and the exhaust already spends some of it**: the vent slot and the tube
    above it cost 2.28-2.68 % before a filter exists, which `head()` now echoes. Small, and it is
    the whole of what is left rather than a share of it
  - **and `head_gas_line_pressure()` gets that exhaust wrong in both directions, latently.** With no
    outlet filter it prices the way out at **zero**, though the tube costs 23.7-55.2 Pa whatever is
    on the end of it; with one defined it charges a full **188.174 mm** riser where the gas only
    travels the slot-to-top run of **37.9-88.3 mm**, so it over-counts 2-3.5x. Under 0.5 % of a
    17368 Pa line either way, and dead code today since nothing sets the filter - but whoever sets
    it inherits both. Fixing it moves the operating flow, the throttle Cv and this budget, so it is
    a decision rather than a tidy-up
  - **and the budget goes NEGATIVE where the pump cannot reach the band at all**, which the echo
    prints straight: `jar_6p5gal_305x470` reads "an outlet filter may cost at most -2.05574 kPa per
    L/min". Arithmetic is right and the sentence is not - there is no budget, the line beats the
    pump, and the throttle warning three echoes down already says so. Pre-existing, found while
    pricing the vent slot, which guards the same number. One `<= 0` branch, same shape as the one
    `gas throttle` already has
  - **it moves with the inlet filter's own number**, which is still extrapolated rather than
    measured. Measure that first - the item below - and this budget follows from it
  - a fix that costs nothing in pressure is worth weighing against a filter at all: the exhaust
    could vent into a trap or a longer tube rather than a membrane, which guards against splashback
    without the drop. That is a different claim about sterility and should be made deliberately

- [ ] **measure the sterile filter's pressure drop**
  - `sparge_filter_drop_slope = 3.45` kPa per L/min is EXTRAPOLATED from an equivalent 0.2 um PTFE
    disc, not measured, and Cole-Parmer publish no curve for 1594522. It is the largest single term
    in the gas budget, so it is the largest thing in the model taken on an approximation
  - a water manometer across it settles it, but **NOT at the set flow**, which is what this said
    until it was costed: 3.45 kPa/L/min at 4.14 L/min is 14.3 kPa, and that is **1.46 m of water
    column**. Not a bench instrument
  - **two points at 1 and 2 L/min instead** - 35 and 71 cm of column, both readable on a metre of
    tube. And two points test more than one does: the model treats the filter as LINEAR because
    membrane flow at these pressures is viscous, so a second point tests that assumption as well as
    the slope, and the slope is what the whole gas budget hangs on. Ten minutes either way
  - it is corroborated, not invented: area-correcting Pall's Acro 50 from 19.6 to this filter's
    16.2 cm2 gives 3.02 against the 3.45 used, so the figure sits 14 % conservative
  - **the operational number that falls out: 1.65x of loading headroom.** The filter may rise to
    23.3 kPa with the valve wide open before 0.5 vvm becomes unreachable. So "the valve is fully
    open and it still will not hold 0.5 vvm" is the replace-the-filter signal, and that belongs in
    the build notes

- [ ] **the tube seal goes IN by hand - what is untested is getting it back OUT**
  - **the fold-through is settled, on a printed port: the 4x1.5 EPDM folds into the groove fine.**
    So the enclosed gland stands as built, `bayonet_bore_gland_lip` stays at 1.2 mm, and the lead-in
    chamfer held in reserve is not needed. That was the open question the geometry could not answer
    - 1.5 mm of cord doubling to 3.0 against a 4.4 mm bore said it passes, not that it was pleasant
  - **two things the same print can still answer, and neither is done:** whether passing the steel
    tube pushes the ring back out of the groove or nicks it on the way, and whether the ring comes
    back OUT for cleaning or replacement without a tool that scars the bore. Captive cuts both ways,
    and this part gets autoclaved
  - if removal turns out to need a pick, that is worth knowing before the build notes tell anyone to
    do it in a jar at arm's length - it is a maintenance step, not a one-time assembly one


- [ ] **re-print the ports: the gland was cut with no clearance and the flanges were thin**
  - found on a printed `baffle_piece_0`: the 23x1.5 would not go into its groove. The gland was cut
    at exactly the ring's OD - a **26.00 mm groove for a 26.00 mm ring**, 0.00 of clearance - because
    `oring_gland_od` is a SEALING dimension being used as an assembly one. `bayonet_gland_allowance`
    is 0.2 now, the same the coupling's own halves get, and the groove measures Ø26.2 on a re-export
  - **the flange lips were one extrusion**: 0.6 mm at a 0.4 nozzle, on the wall the cord is pressed
    against. mini and midi are 1.2 now, std 1.0
  - **what was holding std down was a conflated check, not geometry.** `lid_holes_offset` is the wall
    the LID keeps around a bore, and it was also being asked for as the gap between two raised
    FLANGES, where nothing but air is at stake. On `jar_10L` that held the std flanges 2.054 mm apart
    while the lid between their bores measured **4.654**. `lid_flange_gap` splits them, each checked
    against what it names, and std goes 13.7 -> 14.1 with 1.0466 mm still between flanges
  - **what is left is a re-print and a bench check.** Nothing here is measured against a printer -
    the 0.2 is this file's own convention and the lips are extrusion counts. Print one std and one
    mini port, fit the 23x1.5 and the 13x1.5, and key the allowance to a caliper reading if either
    is still tight. `output/` is untracked, so re-run `just export-parts` first
  - **and the mouth correction spent most of what was left.** The jar measures 142.2 rather than the
    143 that was noted, so the port circle comes in 0.4 mm and the chord with it: the worst adjacent
    pair went **1.254 -> 1.0466 mm** against a `lid_flange_gap` of 1.0. `jar_10L` now carries the
    full twelve-port set on **0.0466 mm** of slack, where it had 0.254. Nothing fails and the gate is
    green, but this is the number to check before any flange lip grows again - the next set that
    fits is the six-port one
  - **and it is now every gap on the lid, not four of them.** The tube ports were on mini only
    because the interface was picked per port; the twelve-port circle puts a probe beside a baffle
    whatever they take, so the small flanges bought nothing and the lid is uniform std now. Packing
    did not move - 1.0466 mm either way - but the eight roomy gaps of 5.85 and 10.65 mm went with
    it. That is the trade the uniform lid made, and this is where it lands
  - still open, and unpriced: whether 1.0466 mm between two 5 mm tall flanges is enough to get a
    cloth into. If not, the lever is a thinner cord - a 23x1 EPDM (McMaster 8785N348, same line, not
    registered) takes the groove to 1.5 wide and Ø25.2, which buys the width back at 0.25 mm of
    squeeze instead of 0.375

- [ ] **the sparge socket is cut at the riser's own diameter, with nothing to spare**
  - `sparge_feed_bore = steel_tube_od(sparge_riser_tube)`, so a Ø4.0 socket receives a Ø4.0 tube.
    That is the SAME defect the port o-ring gland had - a printed pocket drawn at the nominal size of
    the bought part it must accept - and it was missed when that one was audited, because the sweep
    looked for named allowance constants and this is a bore set equal to a diameter
  - a **0.5 mm lead-in chamfer** is in at every socket mouth, which is what makes a rigid tube FIND
    the hole. It does not make the hole bigger: below the chamfer the bore is untouched, so if the
    print comes in under size the tube still will not seat
  - **the fix is not free, and that is why it is here rather than done.** The socket is deliberately
    the ring tube's own section - `sparger.scad` says sizing a boss to the riser instead "showed as a
    0.2 mm ledge all round", which is a defect that was fixed on purpose. So the wall around the
    socket is `(6.4 - 4)/2 = 1.2`, exactly `feed_wall`, with nothing spare: open the bore to 4.2 and
    that wall falls to 1.1 and trips `sparger()`'s own assert
  - **so clearance has to come from the section**, `sparge_tube() = sparge_bore() + 2*sparge_wall`,
    sized off whichever bore it has to surround rather than off the gas one alone. 6.4 -> 6.6 grows
    `sparge_tube_extent()`, which shrinks `head_sparge_ring_radius` by about 0.1 mm and moves every
    hole with it. Small, but it is a geometry ripple and `check-holes` is what would confirm it
  - **untested either way**: nobody has yet pushed a 4 mm tube into a printed socket. The sparger has
    been printed; whether the riser seats has not been reported. One bench check settles whether any
    of this is needed, and it is the same check the gland is waiting on

- [ ] **model the support tubes' discharge holes, now that four ports have one**
  - every tube port but `air_in` drops a 188.174 mm steel tube to the sparge ring and is capped
    there, so each does its job through a hole drilled up its length. `head()` reports the WINDOW
    that hole may sit in - 37.9375 to 88.6626 mm from the top for a headspace vent, past the second
    for a tube discharging into the culture - and `docs/build.md` says which end each port wants
  - **what is not modelled is the hole itself.** It is a bench operation with a file or a rotary
    tool, so nothing draws it, nothing checks it, and the tube is drawn as a plain cylinder. That is
    the honest state and it may be the right one - a hand-cut slot in a bought tube is not obviously
    the model's business
  - **only `air_out`'s hole had a size to meet, and it is priced now rather than asserted.**
    `head()` echoes what the exhaust path costs: a slot at the tube's own **7.06858 mm2** bore is
    156.558 Pa and the tube above it 23.7-55.3 Pa, together 2.27-2.67 % of the 7948.33 Pa the
    exhaust has to spend - the same Pa the throttle is giving away, since the budget and that drop
    are one headroom expressed two ways
  - **the useful half is the FLOOR, and it is not the formality it looked like.** The slot is the
    whole budget at **0.992047 mm2** on `jar_10L`, a Ø1.12388 mm hole. A normal file cut clears that
    7.13x over, but a shallow pass that only just breaks the 0.5 mm wall over a couple of
    millimetres lands on it, so it is a real thing to get wrong. `docs/build.md` says to look
    through the hole against the light
  - **the floor is per-jar and the echo derives it**, which is why no size is written into the
    sentence: 0.992 mm2 here against **0.282709** on `jar_1gal_180x197`, since what sets it is the
    headroom that jar's own gas line has left. `jar_6p5gal_305x470` has none - its line beats the
    pump at the top of its band - so the echo says the slot has no size to meet rather than
    printing the nan a negative budget gives
  - NOT parameterised, deliberately: a `sparge_vent_slot_area` would need a default that is a guess
    at a hand-cut window, and a guessed default feeding a reported number is what this project grades
    as reasoned-not-cited. The floor is checkable with a rule; the slot itself stays the bench's
  - the three dosing holes meter nothing and need no size
  - settled: the three dosing stubs get hose clamps, 17 on the list where there were 14. Silicone
    over a 4 mm riser measures about 6 mm and SAE 4 closes from 5.6, so it is the same clamp as the
    whole gas line and 2 packs of 10 still cover it

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

- [ ] **the baffle clears the blades now, and BAFFLE AREA is what paid for it**
  - **+1.80009 mm running** - 4.07731 nominal less 2.27722 of lean - so the plate cannot reach the
    impeller and the echo's "THE PLATE CAN REACH THE BLADES" branch does not fire. It closed as a
    side effect of the plate narrowing 15.3 -> 10.3454 mm, which opens the gap by half what it takes
    off the plate. No commit set out to close it; see `docs/decisions.md`
  - **the mouth correction took 0.4 mm of it.** 143 was a mis-noted figure and the jar measures
    142.2, which walks the port circle - and the plates hanging off it - inward while the impeller
    stays at 94.5. Running clearance went **2.20009 -> 1.80009 mm**, an 18 % cut in the margin this
    item exists to defend, and it lands before any of the fixes below are priced
  - **the price was a third of the baffling.** Reference projected area 0.855763 -> **0.578548** of
    Oldshue's four-at-T/12, and six plates - the next count that spaces equally on twelve ports - now
    reach only 0.867821 where they used to clear the reference outright at 1.28364. Under-baffling is
    the failure `docs/agitation.md` says lets the vessel swirl rather than mix
  - **so the question is whether 0.579 is acceptable, and what may be spent to get it back.** Buying
    width walks straight back toward the blades, which is why the two are one item. Thickness touches
    neither: it is a tolerance stack, and the deflection half is closed at a 10 mm plate
  - **the impeller's tip ring was the other half of this and is decided**: off by default, because
    the load never asked for it and the strike case it was kept on has gone. `impeller_tip_ring`
    turns it back on, so widening the plate is still open - it just costs a flag now rather than a
    decision. See `docs/decisions.md`
  - **the 2.28 mm lean is a worst case and only matters if the plate widens.** It is bore play alone
    - 0.2 mm over 18 mm of engagement, levered 205 mm to the lower impeller, an **11.4x
    amplification** - and the model ignores the flange's face contact, which resists tilt far harder
    than a bore. The real lean is somewhere between that and almost nothing. The tilt measurement was
    dropped because every outcome led to the same action; it returns only if the margin is spent
  - **the fixes, in order of what they cost.** Their figures were costed against a 15.3 mm plate and
    a negative clearance, so treat them as mechanisms rather than numbers - and now for buying width
    back rather than giving it away:
    - *taper the plate's inner edge with depth* so it matches the lean, worst at the bottom and zero
      at the lid. Buys clearance for about half the area a uniform cut costs. New geometry in
      `bayonet_baffle_port.scad`
    - *deepen the bayonet engagement to 36 mm*. Halves the lean and costs no area, but the stack
      grows, pushing the plate from 2 printed pieces to 3 and adding a third dovetail joint - and
      joints already take 14 % of the deflection
    - *a baffle-only interface row at 0.1 mm allowance*. Free in the model, no area or print cost,
      but that is a tight printed bayonet on the one port twisted by hand at arm's length in a jar
    - *`baffle_impeller_clearance` 2 -> 3*. One line, but it spends area to buy clearance the plate
      no longer needs - the wrong direction now

## drive and aeration

Follows from the agitation work; the reasoning and citations are in `docs/agitation.md`.

- [ ] **two things to confirm on the drive before ordering it**
  - the encoder sheet for `motor_36pg_555pm_14_en` tabulates NO gearbox length, so the registered
    **34.5 mm is inferred** from the 3429 sheet at the same 14:1, and the sheet does not dimension
    the encoder past the can either. Both feed the reactor envelope (571.25 mm) and the cart, which
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

## alternative agitation modes

`jar_1p5L` and `jar_1gal_155` cannot carry a top-entry drive on their lids at any mount size, and
they cannot hold four baffles beside two Ø16 Atlas probes at any port count. A stirred version of
either would be a centred shaft in an unbaffled vessel - Montante measured that at a flow number
65 % below the same impeller baffled, which is swirl rather than mixing. So the answer is not a
smaller mount, it is a different mode.

Neither is scheduled and nothing in the current build waits on them. What makes them worth doing
rather than dropping the two jars: a family spanning three agitation modes off one lid and one
sparger is a stronger claim than one mode across six jars, and it is the claim the paper makes.

- [ ] explore an airlift variant of the sparger, with no impeller at all
  - falls out of the port work: mouths under about 98 mm cannot hold four baffles beside two Ø16
    Atlas probes at any port count, so the small jars are unbaffled whatever else is decided. See
    `docs/ports-layout.md`, "Baffles on a narrow jar", for where that number comes from
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

- [ ] **explore a magnetic drive: a DC fan under the jar turning a rotor inside it**
  - a square DC fan below the vessel, a printed hub on its centre boss carrying two magnets facing
    up, and a magnet potted into a printed rotor inside. Nothing crosses the boundary, so it retires
    the shaft, coupling, bearing, plug seal AND motor mount in one move - the lid becomes ports and a
    seal. It is what a lab does at this scale, and the one mode that removes the constraint rather
    than working around it
  - **the punt decides it, and it is a shallow CONE rather than a dimple** - so the rotor's seat is a
    conical one that pivots on the punt, making the obstacle the bearing. Cone angles off
    `vessel_outer_profile()`: 3.5 deg on `jar_10L`, 10 on `jar_1p5L`, 12.5 on `jar_1gal_155`, 14.3 on
    `jar_1gal_180`, 33.8 on `jar_6p5gal`. A conventional stir bar straddles all of them
  - **the gap depends on how the driver sits.** The punt is re-entrant, so a driver lying flat pays
    wall plus punt while one whose hub nests UP INSIDE it pays the wall alone:

    | vessel | flat driver | nested driver | usable radius nested |
    | --- | --- | --- | --- |
    | jar_1gal_155x251 | 9.0 | **3.0** | 36.5 |
    | jar_1p5L_109x215 | 11.0 | **4.0** | 7.5 |
    | jar_10L_220x305 | 10.0 | **5.0** | 15.0 |
    | jar_1gal_180x197 | 12.0 | **5.0** | 50.0 |
    | jar_6p5gal_305x470 | 27.0 | **12.0** | 80.0 |

  - **and nesting inverts the ranking**, because the punt's WIDTH is then both lever arm and room for
    magnets. `jar_1p5L`, the jar this mode exists for, is the worst of the five at 7.5 mm of usable
    radius; `jar_1gal_155x251` the best by a distance at 36.5 mm through 3 mm of glass
  - **the torque is already known and the order is millinewton-metres.** Scaled from
    `docs/agitation.md` at constant D/T and EQUAL TIP SPEED - torque as `v^2 D^3`, not `D^5` - over
    the 1.26-2.03 m/s band. SCALED, NOT RENDERED: it holds `Po` fixed and a printed rotor is neither
    `pbt_45_4` nor a pair, so it settles the order and nothing finer:

    | vessel | rpm across the band | pair | one rotor |
    | --- | --- | --- | --- |
    | jar_1p5L_109x215 | 528-851 | 4.8-12.3 mN·m | ~2.4-6.2 |
    | jar_1gal_155x251 | 358-577 | 15.3-39.6 mN·m | ~7.6-19.8 |

    Those rpm are what holding tip speed asks, which is nearer a fan's native range than the drive's
    own 320-420 band suggested. PWM and speed feedback are still wanted
  - **it gives eccentricity back, which is the bigger prize.** `docs/ports-layout.md` rules out
    Hall's off-centre fix because `e = 0.2 T` wants 20.2 mm on `jar_1p5L` where the best any lid
    offers is 0.5 - the motor mount is in the room the offset needs. A magnetic drive puts nothing
    through the mouth, so what ruled it out is gone
  - **the decision this item does not make: centred or eccentric.** They are different rotors. A
    centred one is still a centred impeller in an unbaffled jar - Montante's flow number 0.25, which
    is the thing this question exists to escape. An eccentric one has nothing locating it: at
    `e = 20.2` on `jar_1p5L` it sits 12.7 mm outboard of a 7.5 mm plateau, 2.2 mm down a 10 deg
    slope, on a floor whose high point is the centre it is avoiding. Galletti reports eccentric
    unbaffled macro-mixing is UNSTEADY, and power RISES with eccentricity - which a low-torque fan is
    least able to pay
  - **and a bottom drive gives ONE impeller**, on `jar_1p5L` at H/T 1.681 - the tallest column in the
    registry, turning 170 mm of liquid from the floor. Not a reason against the mode; the number to
    answer before calling it equivalent


## nice to haves

- [ ] Add curve / inflection point to holes in bayonet connectors to grip tubes better
  - sehan's idea, currently they grip really tight already so this is just a thought for improving the design if we find the tubes are slipping out too easily in testing; or if we wanted to reduce the interference fit and make it easier to insert the tubes in the first place while keeping them from slipping out

- [ ] back-plug the Atlas probe bore, or accept that the probe body is the seal
  - the collet's connector hex opens **straight through** the probe bore to atmosphere - 8.6 mm
    across the flats, **64.05 mm2** - so with no probe in it the port is a hole into the headspace.
    What closes it is the probe BODY, and that is a grip rather than a seal:
    `_bp_collet_body_allowance` is 0.6 mm, taken up by sprung tabs. Nothing in the model draws a
    seal there, checks one, or reports the gap
  - **low concern, and the reason is bench experience rather than the model**: the probes largely
    self-seal once the body is seated. This is written down so it is a known open edge rather than
    something nobody looked at
  - **the fix, if it is ever wanted, is probably NOT cad.** Hot glue or another temporary seal at
    the hex is the honest answer for a part that has to come apart to change a probe, and a modelled
    gland at the connector end would be geometry standing in for a squirt of adhesive. Worth saying
    out loud so nobody designs one by reflex
  - it belongs with the sensor-gland item below: both are about the connector end of the probe, and
    if either is ever done they should be looked at together
  - the port's OTHER seal is not this one - the bayonet face o-ring closes the flange against the
    lid and is unaffected

- [ ] optional end styles (sensor gland) for atlas probes to match product more closely

## tooling / infrastructure / documentation

- [ ] **FOUR of five jars carry a second impeller the spacing does not support**
  - the band bounds the COUNT - Fitschen eq. (5), `(H-d)/d > n > (H-2d)/(2d)` - and is written in
    IMPELLER diameters, not tank diameters, which is where the old H/T 1.2 reading went wrong:

    | vessel | H_L | d = 0.45 T | H_L/d | H/T | band allows | old H/T 1.2 said |
    | --- | --- | --- | --- | --- | --- | --- |
    | jar_10L_220x305 | 234.59 | 94.50 | 2.482 | 1.117 | n = 1 | one |
    | jar_1gal_180x197 | 153.36 | 76.50 | 2.005 | 0.902 | n = 1 | one |
    | jar_6p5gal_305x470 | 325.26 | 126.36 | 2.574 | 1.158 | n = 1 | one |
    | jar_1gal_155x251 | 188.59 | 67.19 | 2.807 | 1.263 | **n = 1** | **two** |
    | jar_1p5L_109x215 | 168.70 | 45.55 | 3.704 | 1.667 | n = 1 or 2 | two |

  - **`jar_1gal_155x251` is the mover.** At H/T 1.263 the old threshold gave it a pair; the band
    gives it one. `jar_1p5L_109x215` is now the only jar a pair is admissible on, and one is
    allowed there too. At this D/T the crossover is H/T **1.35** - but quoting it in H/T is the
    mistake, since that only holds at D/T 0.45
  - **it correlates with coverage both ways**: every jar the band puts at one impeller is a jar the
    pair is spending coverage on. `jar_1gal_180x197` at 0.107 D against the 0.5 D floor is the
    worst case, not a separate problem
  - **there is no primary behind the rule**, so nothing may assert on it and `head()` reports the
    bounds rather than testing a number. Fitschen [PR] relays eq. (5) from Davis [TH], whose own
    two sources do not contain it, and Oldshue's chapter has no numeric count rule at all. See
    `docs/decisions.md` and the Fitschen entry in `docs/references.md`
  - **the count stays two, and this is what changing it costs**: the sparge ring is placed in the
    GAP between the impellers, the power reporting is per pair, and the manifest lists an upper and
    a lower. One impeller unpicks all three, and changes the reference build that physically exists

- [ ] **nothing checks a Customizer description, so they can rot the way figures do**
  - the sweep is done: `head.scad`, `frame.scad` and `assembly.scad` each have **0 parameters with
    no description line above**, from 33, 9 and 4. A large share of the fixes were MOVING the
    author's own trailing comment onto the line above - OpenSCAD reads only that line, so words
    like "heat-set into the lid, and they stay there once set" already existed where the UI could
    not see them
  - what is not a description was hidden rather than written: `impeller_n_fins` and
    `impeller_twist_ang` come off the designated impeller row, `nut_pocket_diameter` and
    `nut_height` off `rod_nut`, `reactor_vessel` off the name above it. Offering any of them lets a
    derived number disagree with what it is derived from. 113 / 31 / 20 are offered now, 20 / 4 / 12 hidden
  - **and `/* [Hidden] */` runs until the NEXT section marker**, which is a trap: putting one above
    `z_fight` in head.scad silently hid every render flag below it, because that file had no marker
    between the internals and the flags. Caught by counting the visible surface, not by reading the
    diff
  - **guarded now, for one of the two defects.** `just check-customizer` is in the gate and was
    proved to fire twice over - on a removed description, and on a `[Hidden]` marker with no comment
    saying what it hides, which is how one block came to swallow 17 sparger parameters unremarked.
    It also settled a question the sweep had only got lucky on: `$`-prefixed names are SPECIAL
    variables, which the customizer does not offer, so they want no description
  - **the OTHER defect is still open, and the count above hides it.** "0 parameters with no
    description" means none shows a line of CODE. It does not mean none shows half a sentence -
    roughly **54** offered parameters still take the last line of a multi-line block, which was the
    larger half of what this item originally described. `head.scad:107` offers
    "motor_mount_part_to_render above, and useful interactively for the same reason."
  - it is NOT gated, deliberately. Detecting a fragment means guessing whether a sentence started on
    the line before, and a sample says the obvious heuristic is only about half precise -
    `assembly.scad:167` reads "Height of the lid flange, vessel rim to the top of the lid, in mm",
    which is a good description the heuristic flags. A check with that false-positive rate gets
    turned off. What each of the 54 wants is one clean line ADDED at the bottom of its block, read
    from the block rather than inferred - the descriptions written from inference during this sweep
    had about a 50 % error rate, and mass-writing 54 more at speed would put in more than it took out


- [ ] **the sparger's holes are not the wrong size - the BORE is, and it is one designation**
  - priced against the model's own functions rather than argued. Holding the settled 8 x 3 mm spec
    and sweeping only the bore, at the build's duty of 4.11052 L/min through one ring:

    | bore | feed velocity | open area | velocity head | verdict |
    | --- | --- | --- | --- | --- |
    | 4.0 (today) | 5.46 m/s | 4.50 | 17.9 Pa | 2 departures |
    | 6.0 | 2.43 | 2.00 | 3.5 | 2 departures |
    | 8.0 | 1.36 | 1.12 | 1.1 | 2 departures |
    | **8.5** | 1.21 | **1.00** | 0.9 | **clean** |
    | 10.0 | 0.87 | 0.72 | 0.5 | clean, with margin |

  - **so the settled decision does not have to be re-made.** 3 mm holes for spacing and against
    fouling stand; a 1.2 mm hole in an algal culture is still a hole that blocks. What was wrong was
    reading the fix as a hole problem: sweeping hole diameter at bore 4 leaves every size in
    departure, and sweeping bore at 3 mm clears at 8.5. The count is not the lever either
  - **and the bore is not a free parameter.** `sparge_bore()` returns
    `steel_tube_od(sparge_riser_tube)` - one passage, the riser's own - so the change is a
    DESIGNATION: `steel_tube_welded_4x0p5` to `steel_tube_welded_10x0p5`, McMaster 50415K35, which
    is already registered. 8 mm is registered too and does not clear; there is no 8.5 row
  - **what it costs is the cascade, and that is the decision.** The tube goes 6.4 -> 12.4 mm across
    the flats, which has to clear the baffles and pass the mouth; the riser passes a port bore sized
    for 4 mm with a 4x1.5 rod gland sized to it; and the riser's own pressure drop, its support tube
    and its BOM row all follow. None of that is priced yet - what is priced is that the sparger side
    is one row change and the hole spec survives it


- [ ] **`check-holes` still needs a CGAL render, so it stays outside `just check`**
  - the FED half is closed. Each hole now declares two points - `exit` just inside the discharge
    face, `feed` on the tube's centreline where the bore runs - and both must be void. Proved by
    injection rather than by passing: a ring bore swept 180 degrees instead of 360 fails 5 of 20
    holes, every one of them on `feed` and none on `exit`, which is exactly the shape the single
    probe called clean
  - **and the live case was not the one this item named.** A hole in a solid arm is `spoke_holes`,
    which no caller sets and which `sparger()` already refuses. What the feed probe actually catches
    is on the part as designed: the ring bore stops short of each cut face by `plug_depth` to leave
    stock for the end screws, so a hole landing in that dead arc breaks the surface perfectly and
    connects to nothing
  - what is left is the COST. It needs a CGAL render, so it sits in `check-mesh`'s class and
    head.scad alone is minutes. The cheap coverage is `custom/sparger.scad` standalone, which cuts
    the same holes through the same functions in seconds. What would let it into the gate is a probe
    that needs no rendered mesh: the claim is geometric and the part is a union of primitives, so in
    principle the CSG answers it without CGAL
  - still unprobed: `spoke_holes` emits holes the probe module never walks - it iterates rings only.
    Latent rather than open, since no caller sets it and the assert covers its own failure, but a
    caller that did set it would get holes nothing tests


- [ ] **the sparger's two sockets are harder to tell apart than they were**
  - the feed socket takes the tube's own section now rather than being sized from the riser, which
    fixed a 0.2 mm ledge at the joint and cost the keying. Both sockets are 6.4 mm across the flats;
    the octagon's corners stand **0.264 mm** proud of the round one, where a hexagon's stood 0.49
  - it is the only thing telling a live feed from a blind support once the part is at the bottom of
    a jar, and getting it wrong sends gas down a capped tube and out its vent while the rotameter
    reads flow. `docs/build.md` now says count the facets rather than glance
  - what would settle it is a print: hold the two and see whether the difference is findable by
    hand. If not, the fix is a different tell that does not fight the joint - a collar, a flat, a
    mark - rather than going back to a socket sized on its own

- [ ] **decide whether the eccentricity report should reach the two jars that need it**
  - Karcz's eq. (6) is encoded in `utils/stirred_tank.scad` and `head()` consumes it: it takes the
    offset the mount leaves - the slack above the minimum its mount-versus-flange assert clears -
    and echoes the e/T and what it is worth, with the departures named. `docs/references.md`'s
    `e/T today` columns are read off that echo now rather than transcribed
  - **the gap is that it cannot reach `jar_1p5L_109x215` or `jar_1gal_155x251`**, which are the only
    two vessels the number would change a decision about. An assert stops each before the echo -
    the mount on the 1p5L, the pH probe on the 1gal_155, which fails on the probe before reaching
    the mount it would also fail at -8.30 mm. Verified, not assumed: neither renders the line. And
    the reason the mount fires IS the answer, since a lid with no room for the mount has none for an
    offset - so those two rows read 0 in the document on reasoning rather than on a render
  - the options are to demote that assert to an echo, which is a real change of policy for a
    genuine collision, or to compute the eccentricity report before it, or to leave it and let the
    document carry the two rows with the reasoning it already has. The third is defensible and is
    what stands; it is written down here so it is a choice rather than an oversight
  - what would settle it: those two jars only get an offset at all under a drive that does not
    stand on the lid, and that is the magnetic item under "drive and aeration". Deciding this
    before that one is deciding it backwards

- [ ] **a 330 mm light leaves a 0.067 mm lip of rib across its own channel**
  - **the silence that filed this item was a measurement artifact, and there is no silence.** The
    240005-byte identical CSG was rendered with `-D render_all=false`, which propagates into
    `frame.scad`'s OWN `render_all` in a `use`d file - so `frame()` ran its echoes and emitted
    nothing, and the one polyhedron in that file was the glass jar. Reproduced byte-for-byte at the
    commit that filed it. Rendered properly the two rows differ: the lower base and all eight ribs
    move with the light's WIDTH, 14.7 -> 14.5 mm of cutter, 0.1 mm a side
  - what the hypothesis got right is the LENGTH. `frame_floor_depth` clamps at a 2 mm minimum, and
    on this vessel a row would have to exceed **452.15 mm** to beat the clamp - the longest
    registered is 400. So length reaches nothing here, and the top base is never touched either:
    the pocket stops **129.5 mm** below it. Both are worth an echo rather than a silence
  - **and the rib stack is where it bites.** On `frame.scad`'s own preview
    (`collapse_spacer_z_allow=false`) with `rwntao_13in`, the top rib carries material from
    z 328.0 to 328.067 that `grow_16in` does not - a blind slot where the part wants a through one.
    Verified independently of the report that found it, by vertex-z histogram on
    `rib_to_render=5`. In the assembly the same pocket clears by 1.333 mm, so what PRINTS is right
  - so it is a preview that misrepresents the part by 0.067 mm, and a margin one rib level from
    being a real interference. Nothing computes it. What would close it: echo the clearance between
    the pocket's top and the top rib's upper face, which needs the light's z origin threaded out of
    `lights()` - it is not currently a number `frame()` holds


- [ ] **`check-scad`'s `-D '$fn=0'` pass is not the neutraliser it reads as**
  - the head's own tessellation is settled: `head()` re-asserts `$fn = 0` and `head_fa()`/`head_fs()`
    inside its body, so `assembly.scad`'s 64/128 cannot reach it on any binary. Measured on both
    installed: 2021.01 unchanged, and 2026.09 moves from `$fn = 64` to 0 through the assembly path.
    It mattered - on the nightly the lid rendered **202,158 triangles against 36,974**, and -0.038 %
    of volume as the small bores inscribed
  - **what is left is the check.** `check-scad`'s second pass forces `-D '$fn=0'`, and a command-line
    `-D` crosses the `use` boundary on BOTH versions where an in-file assignment does not. So that
    pass does not render what any build renders: it also zeroes `sparger.scad`'s 96 and
    `bayonet_probe_port.scad`'s 64. Measured on the nightly it gives 38,354 triangles and
    508,327.683 mm3, matching neither real path
  - it is still worth having - it covers the CRASH a zero facet count causes - but it is not a
    tessellation-divergence test and should not be read as one. What would test that is rendering
    one part both ways and comparing, which is cheap at the CSG level and needs no CGAL
  - and `OPENSCAD` is unset, so `just` runs 2021.01 while `openscad-nightly` 2026.09 sits on the
    same machine. The version this project is checked on is whichever binary happens to be first on
    PATH, which is worth pinning rather than discovering


- [ ] **the recess holds three quarters of the rubber, and it is only a problem on `jar_6p5gal`**
  - the joint is instructed as a TURN - **114.3 deg past snug** on each of 12 nuts - because force
    reaches a fastener through a friction coefficient nobody can measure here, while a turn is the
    gasket's travel over the thread's pitch. That half is closed; this is what is left
  - **the excess is an IDENTITY.** The recess is cut at `t(1-c)`, so `t*c` will not fit whatever the
    gasket - a quarter at `c = 0.25`. On `jar_10L` 12.70 against 9.525 mm2, on `jar_6p5gal` 9.525
    against 7.144
  - **where it goes splits by lip kind.** On `jar_6p5gal`, the only ground one, the pad is squeezed
    uniformly and the quarter must leave across the lands. On a crown the contact is a **3.238 mm**
    chord of an 8 mm gasket, so 4.762 mm of width is never touched and the displaced rubber flows
    into that - about **0.857 mm2** against **1.890 mm2** free to bulge, roughly twice the room. The
    0.857 is two thirds of chord by sagitta, an approximation, and is what to re-run if the sheet,
    the compression or the lip arc moves
  - **and the crown's travel is bounded by the same identity**: the gasket stands `t*c` proud and the
    crown sinks `t*c`, so design compression arrives exactly when the crown has taken up all the
    proud rubber
  - **the load model's objection is `jar_6p5gal`'s alone now.** `gasket_shape_factor()` is the
    free-bulge form and is handed the CONTACT band - on a crown that is a chord with unconfined
    rubber either side, close to what free bulge assumes; on the flat jar the pad fills its recess
    and the walls are where it assumes bulging. That jar also carries the registry's highest load,
    **1253.6 N per post and 7.34 MPa**, against 352.9 and 2.78 on `jar_10L`. Reported, not asserted
  - the fix, if chased, is the usual rule for a confined flat gasket - groove section 10-25 % over
    the gasket's. Widening the recess buys it out of the lands, and `jar_6p5gal` offers 10 mm of rim
    where the gasket is held to 6. Not chased: it changes the lid for one jar

- [ ] **ONE printed part is on no print list, not four - and two of the four print nothing**
  - read file by file rather than counted: `bottle_holder.scad` makes a dovetailed sleeve and is the
    only original printed geometry of the three. `cart.scad` prints NOTHING - bought extrusion,
    bought NopSCADlib brackets, bought castors, and a translucent envelope that is a picture.
    `electronics_stand.scad` prints nothing original either: `print_corner` renders a NopSCADlib
    corner bracket, which is a VITAMIN, so it is a printed substitute for a bought part.
    `peri_pump_frame_mount.scad` is the fourth and is correctly parked on where the pumps mount
  - `check-parts` records all four rather than hiding them, and its reasons now say which is which
  - **so what is left is two questions, neither of them a manifest.** Does the reactor's print list
    cover an ACCESSORY - the bottle holder is bench furniture, not a reactor part - and is printing
    a NopSCADlib bracket instead of buying one deliberate? That bracket is on no purchase list and
    on no print list, so today it is in neither account
  - the cart's extrusion, brackets and castors are on no purchase list either. `check-bom` passes
    because these files sit outside its scope, the same way they sit outside `export-parts`. Whether
    bench furniture belongs in either account is the same question in the other direction


## long term / post paper submission

Not blocked on anything and not wanted before the paper is out.

- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based OpenSCAD preview
