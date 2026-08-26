# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [x] rethink how the impeller diameter is driven, and guard it
  - the guard landed first: `head()` now refuses an impeller that cannot pass the vessel's opening, which caught `jar_6p5gal_305x470` building a 145 mm impeller for a 137 mm mouth. It was written against a tip ring standing *outboard* of the blades and went on charging `2 * fin_width` for it after the ring moved inboard; it now asks `head_impeller_swept_radius()`, and the test lives in `head_mouth_is_feasible()` with the other three couplings rather than only inside `head()`
  - the driver was wrong in its reference, not its value. It multiplied `vessel_outer_diameter`, but D/T everywhere in the literature is against the vessel's wetted bore, so the real ratio drifted with the glass — 0.468 to 0.489 across the registry for one nominal 0.45. It now reads the bore and is constant
  - `impeller_bore_ratio = 0.45` sits mid-band on every citation and is what lets every registered vessel build. `jar_6p5gal_305x470` is the binding one: its 137 mm mouth caps the ratio at **0.4879**, so 0.45 leaves **10.64 mm** to pass it through, and every other jar tolerates 0.64 to 0.87. Those read 0.4594 / 2.64 mm / 0.59-0.82 while the mouth assert was still charging 8 mm for the moved ring. The relations and their citations are in `scad/utils/stirred_tank.scad`, the reasoning in `docs/agitation.md`
  - the twist angle and the blade height are the parameters with no support — nothing citable exists for 55 degrees, or for the W/D of a twisted extrusion at all. Both are left alone and marked; `twist` turns out to be a pitch specifier rather than a blade angle, so the honest treatment is the derivation recorded in `docs/agitation.md`. A bench power-number measurement would settle it
- [ ] **measured gas flow** — a reproducibility gap, not a geometry one. **The parts are now chosen and in the BOM: Dwyer `VFA-23` bare meter, C$86.22, and a Clippard `MNV-4K2` needle valve, US$13.99, the valve upstream of the meter. What is left is buying them and taking a reading.**
  - the `-BV` valved variant was the obvious buy and was dropped on principle: Dwyer do not publish its Cv, and unstated specs are what disqualified the medical and welding flowmeter channels here. Buying the bare meter and a valve that publishes both a Cv and a flow-vs-turns curve is cheaper *and* closes the row on numbers
  - **the filter changed which valve.** At the old budget the throttle dropped 24.2 kPa for a required Cv of 0.020 and `MNV-2` (Cv 0.032) had the best resolution of anything found. Counting the sterile filter's 14.1 kPa cut the throttle's share to 9.96 kPa and raised required Cv to 0.0296, which puts `MNV-2` at 92 % of wide open with no authority left — the same failure the Ideal Valve 52-1-12 was rejected for. `MNV-4K2` at Cv 0.090 sits at 33 %, inside the 2–4× band
  - still unpublished and worth one email: the meter's **graduation interval**. Not a blocker — over a 70 mm scale it resolves finer than the ±0.25 L/min its ±5 %-of-full-scale accuracy allows
  - **Correction to how this was first filed.** It was written as "the reactor's binding
    constraint", outranking the geometry. That is wrong for a design and right only for a
    *productivity target*, which this project does not have. `sparge_design_vvm` appears only inside
    echo strings: **0.1 vvm and 2.0 vvm render byte-identical geometry.** Nothing in the SCAD moves
    with the gas rate or its CO₂ fraction
  - **The reactor is already CO₂-ready and that is the composable answer.** Enrichment happens
    upstream of the sterile inlet filter, so feeding air or air+CO₂ is a bench change, not a design
    change. There is nothing to add to the model to permit it
  - the drawn holes are indifferent too: the same 8 × 3 mm cover **0.25–2 vvm** inside the only
    orifice-velocity range anyone has tested (Barbosa's own 0.4–5.4 m/s). An 8× range, no change
  - **What does not go away** is that the model states a vvm and no builder can set one. The
    registered pump is 65–70 L/min at 27 kPa against 0.82–4.09 L/min at 1.12 kPa — 16–80× the flow,
    24× the pressure, running at 1.3–6.3 % of rating with nothing metering it. So the gas-flow
    boundary condition is unestablished, unrepeatable between runs, and unreproducible between
    builders. **That** is a design gap, because reproducibility is what this project claims. A
    rotameter or needle valve covering ~0.8–4 L/min closes it, and costs little
  - also cheap and unrelated to any target: a **check valve**. 1.03 kPa of culture head sits over
    the ring with nothing stopping it back-flowing down a 2.5 mm bore into a stopped pump
  - the 0.22 µm filter is registered but **its own ΔP has never been counted** against the 1121 Pa
    the model reports, and it could be the largest term in the chain
  - **the CO₂ question is downstream of a target nobody has set**, and it is the right question to
    put to a biochem engineer rather than to answer here: air at 0.5 vvm supports about
    0.09 g/L/day on a 30 % utilisation assumption, which is fine for growing *Chlorella* and short
    of 1 g/L/day, which would need ~0.47 % CO₂. Three independent derivations agree on those
    numbers. What none of them settle is this reactor's actual CO₂ utilisation efficiency, which is
    measurable here and is the assumption the whole estimate turns on
  - the nutrient feed does not change it. The medium is **0.2 g/L Miracle-Gro in DI water,
    unbuffered** — the figure is not a range, it is what `analysis/runs/2026-07-23-chlorella-ccpc90`
    records — and its urea carbon is worth about 0.035 g/L of biomass *in total*, not a per-day
    rate. This is not a mixotrophic culture
  - **and the empirical answer already exists.** That run grew *Chlorella vulgaris* CCPC 90 for
    8.7 days on air alone with no pH control. Against a target of growing Chlorella reproducibly,
    the CO₂ question is answered by the run, not by a calculation

    geometry work, because no sparger geometry can fix either problem below
  - **air alone cannot feed this reactor.** Algal biomass is ~50 % carbon, so 1 g/L/day needs
    1.74 mmol C/L/h. Air at 425 ppm supplies 1.043 mmol/L/h per vvm before absorption; at a 30 %
    absorption efficiency 0.5 vvm sustains **0.09 g/L/day**. For 1 g/L/day the feed gas needs
    **~0.47 % CO₂**, eleven times atmospheric. There is no CO₂ source in the BOM
  - **the flow cannot be set.** The registered ReSun pump is 65–70 L/min at 27 kPa against a
    reactor demand of 0.82–4.09 L/min at 1.12 kPa — **16–80× the flow and 24× the pressure**, so
    the reactor runs it at **1.3–6.3 % of rating**. The CSV row already says "heavily throttled in
    use — measured reactor flow TBD". With no flowmeter and no regulator there is no way to know
    where in the band a run sits, or to repeat it next week or on someone else's build. Every vvm
    figure in `docs/agitation.md` is therefore *unmeasurable with the registered parts*
  - **no check valve.** 1.03 kPa of culture head sits over the ring. A stopped pump has nothing
    stopping that back-flowing down a 2.5 mm bore
  - what the chain wants, none of it yet an orderable row: a **needle valve or rotameter** covering
    0.8–4 L/min, a **CO₂ source and blender** or a premixed cylinder, a **check valve**, and the
    0.22 µm filter that is already registered. The filter's own ΔP has never been counted against
    the 1121 Pa the model reports
  - the honest framing for a paper: this is a **CO₂ inventory problem**, and the enrichment fraction
    is a bigger lever on productivity than the entire sparger study was

- [ ] **two of six registered vessels do not build** — one cause left, and it is parked
  - was "only one builds", then four. `baffle_length` now hangs to each jar's own floor, which
    unblocked `generic` and `jar_1gal_180x197`; the port table becoming a property of the vessel
    unblocked `jar_6p5gal_305x470` before that
  - what is left is a single cause with an owner: **`jar_1p5L_109x215` and `jar_1gal_155x251` cannot
    carry a top-entry drive on their lids at all.** Their port flanges leave 27.1 and 35.4 mm where
    the motor mount's own floor is 42, so they are 14.9 and 6.6 mm of diameter short. No lid or
    mount change reaches it
  - that is the narrow-jar agitation question, tracked under "drive and aeration". Nothing else in
    the model is waiting on it
- [ ] **BOM completeness, before the rebuild purchase**
  - hardware is being bought for the revised design and for further vessels, so the BOM has to be
    orderable end to end rather than mostly orderable. Known holes:
  - **gas chain** — rotameter (0-5 L/min for the 10 L jar), metering valve dropping ~24 kPa at
    4 L/min, check valve. Sizing is done; part numbers are not
  - ~~**sparge riser**~~ — done: 316 welded tube 4 x 0.5 mm, 50415K21, one 1 m length cut into two
    186.7 mm tubes. See its own item below
  - ~~**four fastener rows have no part numbers**~~ — done, and deliberately NOT with a supplier
    code. A commodity fastener is fully specified by its standard, so `part_number` now carries
    `ISO 4017 M8x30 A2-70`, `ISO 4032 M8 A2`, `ISO 4762 M4x8 A2-70` and `DIN 975 M8 A2`, which is
    buyable anywhere and does not go stale. `source`/`url` name one place to get them
  - all four are **18-8, not plated steel and not 316**, per procurement.md's wetted→316 / dry→18-8
    rule. It is a free choice because strength is not a factor: 291.8 N per post against about
    16.5 kN of proof load, **1.8 %**
  - the **M8 rod is a stock length cut into four**, not four parts — 4 x 322 mm = 1288 mm, and the
    322 is vessel-dependent. Same defect the tube row had
  - **a tube cutter and a deburring tool** still want rows. 0.5 mm wall rolls inward at the cut and
    that restriction lands where gas enters, so deburring the ID is a real assembly step, not a
    nicety
  - **the sparge ring itself is printed**, so it needs no row, but it does need to appear in
    whatever print list the build instructions carry
  - worth doing in the same pass: check every registered row still matches what the model draws
    after this revision. The impeller, baffles, clearance and sparger all changed, and the BOM was
    written against the previous geometry
  - buying for **more than one vessel** is the point rather than a side effect: the paper's claim is
    a parametric family, and a second vessel realised from the same source is the evidence for it

- [x] ~~**register plug o-rings for the other mouths**~~ — **done**
  - 22 rings registered, AS568 dash 150 to 171, all 3/32 in cord from McMaster's water- and
    steam-resistant line with part numbers. They seal a mouth from 77 to 217 mm continuously, so
    every registered vessel resolves one and most substitutions would too
  - the cord is 3/32 in and not 1/8 in because `head_plug_oring_cord_limit()` caps it at 3.05 mm:
    the groove and the port bores are cut into the same wall of the plug, and the mouth cancels out
    of that algebra, so a fatter cord fouls the bores on every vessel rather than just a tight one
- [x] register the sparge riser as a real purchased part
  - it was drawn at 4 x 2.5 mm as two loose literals, and **that is not a size anyone sells.** At
    4 mm OD the catalogue offers 0.25, 0.4 and 0.5 mm walls and no 0.75, so the part the model
    prescribed could not be bought at all. Nothing caught it because nothing had to
  - **done.** `purchased/steel_tubes.scad` registers the 316 welded metric family, 2 to 12 mm OD,
    22 rows with part numbers, on the same schema as `shafts.scad`. `sparge_riser_tube` selects
    one and the OD, the bore, the second moment and the part number all come off it
  - **welded rather than seamless, and temper is what decides it.** These are hard temper where
    the seamless metric straights are soft; temper does not move the modulus, so bending stiffness
    is the same, but a support tube that stays where it is put is the whole point. The bore does
    not decide it - the riser costs a few hundred Pa against the 24 kPa the metering valve burns -
    and neither does the crevice, since the support tube is a dead leg by design, which is worse
    than a bead and shared by both. It is also $22.72/m against $181.42
  - wall is the stiffness lever: 0.5 mm keeps the support at 1.79 N/mm against 2.21 at the
    unbuyable 0.75, where 0.25 would drop it to 1.08. 0.5 is the thickest the 4 mm size comes in
  - `sparge_feed_bore` now derives from the tube's OD instead of being a second literal that
    happened to agree, and `check-bom` gained a fifth registry
  - still open, and unchanged by this: the **2 mm of slack the tube has through the port's 6 mm
    bore**, and how that gap is sealed. That is the tube port's business - see the sparger
    follow-ups below

- [x] the sparge back-pressure left out the riser and the filter
  - `head()` reported **1121 Pa** for the gas to beat and counted only the vessel. **The filter was
    the big omission, not the riser:** at the design flow it is **14.1 kPa, twelve times the
    vessel's own**, where the riser is 116 Pa
  - **done.** `gas_filter_pressure_drop()` and `gas_tube_pressure_drop()` in `utils/gas_supply.scad`;
    the riser is Darcy-Weisbach off the registered tube's bore, the filter is linear in flow, which
    is the right shape because membrane flow at these pressures is viscous. The pump is now said to
    beat **15.3 kPa**
  - correcting my own earlier note here: it said the riser was "240-400 Pa". That was computed at
    the unbuyable 2.5 mm bore. The tube we can actually buy is 3 mm, and drop goes as the fourth
    power of it, so it is **116 Pa**
  - it does have a consequence after all, which the old note said it did not: the filter takes over
    half of what the throttle had, so the valve's drop falls from 24.2 kPa to **9.96** and the Cv it
    needs rises from 0.021 to **0.030**. `head()` now reports that Cv, which is what actually picks
    the part
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

- [x] draw the vitamins that are registered but never rendered
  - the **ball bearing** was registered as `BB608` and its numbers cut the lid's pocket, but
    `ball_bearing()` was never called, so the part it is cut for did not appear. A pocket drawn
    from a row nobody can see is the sort of thing that stays wrong quietly
  - the **impeller set screws** were the same: `impeller_set_screw` sizes and places the tap holes,
    but `screw()` was never called on it. NopSCADlib draws grub screws as `hs_grub`, so both were a
    render toggle and a call, not new geometry
  - both now have their own flag - `render_bearing` and `render_set_screws` - and both are in
    `render_all`. The screws needed one structural change beyond a call: the pair of impellers is
    placed by one `mirror()`, so the printed part and its screws go inside a
    `head_impeller_assembly()` that the mirror catches together, or the upper impeller's screws
    stay on the lower one's angles
  - **and drawing them is what checks them.** Measured off the exports rather than asserted:
    the bearing comes out OD 22 / bore 8 / z -7 to 0, which is the pocket exactly; the screws come
    out as four separate solids, 0 and 120 degrees on the lower impeller and 0 and 240 on the
    upper, each running r 4.00 to 10.20 - cup tip on the shaft surface, socket on the hub's outer
    face, which is what `set_screw_length` was picked against

- [x] a fixture for cutting the rim gasket
  - `scad/custom/gasket_cutter.scad`. It takes the same three numbers `sheet_gasket()` takes - the two
    cut diameters and the stock thickness - and knows nothing else about what the ring seals, so
    `head()` hands it the derived cut exactly as it hands it to the gasket
  - **two stages, because one template cannot guide both cuts.** A template shaped like the gasket is
    a wall as wide as the ring - 3 mm here - standing at Ø148, far too slack in its own plane to hold
    a blade to a line. Bracing it needs material either inside the bore or outside the rim, and those
    are the two places the blade has to be
  - so the cuts are taken one at a time and the second locates off the first: cut round a solid disc
    at the OUTER diameter for a blank, then drop the blank into a counterbore under a plate bored at
    the INNER diameter and cut through the bore. Ordinary machinist practice, and it makes the ring's
    concentricity a printed counterbore rather than the operator's hand
  - both parts are discs with a pocket, so both print flat with no bridge and no support
  - the bed edge of the outer disc is drawn UNDER size and flared up to the guide diameter rather than
    chamfered off it. A first layer that squashes outward would otherwise stand proud of the very face
    the blade is held against, and every blank would come out that much oversize
  - `render_gasket_cutter` is deliberately not in `render_all`: it is a tool, and the assembly is the
    reactor
  - and the sheet's registered size finally does something. `gasket_sheet_yield()` derives the four
    per 12 in square that the registry comment and `docs/procurement.md` had each been asserting by
    hand

- [x] give the culture a real volume and draw it
  - it was a CYLINDER on the vessel's bore, and every process number the model reports is per unit
    volume - mean dissipation, kLa, blend time, sparge flow, the vvm band, the aeration ceiling.
    `vessel.scad` now exposes the wetted profile it already drew and the volume is integrated over
    it: +1.31 % on `jar_10L`, +2.56 % on `generic`, +2.76 % on `jar_1p5L`, +0.52 % on `jar_6p5gal`
    where the shoulder claws some back. `jar_10L` holds 9.573 L brim full, against a name saying 10
  - the old note had the sign backwards - "runs a few percent high" - because it counted the
    shoulder and forgot that the punt is a narrow pillar in a wide floor, so the liquid standing in
    the annulus round it was dropped. It ran LOW
  - a closed form was tried first and was wrong: cylinder plus punt annulus less base fillet
    predicted +2.0 % on `jar_10L` against the profile's +1.31 %, because the floor DISHES - a
    shallow cone from the punt plateau out to the base corner, not a flat floor with a pillar on it.
    That is the argument for integrating the drawn profile rather than describing it twice
  - `render_culture` revolves the SAME clipped profile the volume integrates, so the fill line is
    one statement rather than two. The drawn solid measures 8.2675 L against an echoed 8.2808, which
    is the 0.1607 % a 64-gon is inscribed by - not a disagreement

- [x] **set the fill line by WORKING VOLUME, not by a fraction of height**
  - `culture_fill_fraction = 0.8` is a fraction of internal HEIGHT. Nobody fills a jar to 80 % of
    its internal height; they pour in litres. And "we ran 8.0 L" transfers to another builder's jar
    where "80 % of internal height" does not, which is the reproducibility this project claims
  - the inversion is a bisection over `vessel_profile_litres()` - the profile is monotonic in height
    above the floor, so it converges - and the override idiom fits: `undef` derives from the
    fraction, a value in litres pins it
  - **done, and pinned at 8.25 L on this jar.** `culture_working_volume` takes litres and solves the
    height back; `undef` still derives from the fraction, which it has to, because a litre figure
    that suits `jar_10L` will not fit `jar_1p5L` and every registered vessel has to build
  - 8.25 rather than a rounder 8.0: at 8.0 the coverage over the upper impeller falls to 0.479 D
    against the 0.5 this project holds, and spending that margin to buy a tidier number is the wrong
    trade. 8.25 lands at 0.555 D, 235.1 mm deep, 79.7 % of internal height - so almost nothing
    downstream moved, which is the point
  - the echo now says whether the line was derived or pinned, and says so when a pinned volume is
    larger than the jar - the solver holds the line at the rim and the volumes below become the
    capacity, which nothing else would have reported

- [x] three BOM rows quote derived numbers that have since moved
  - the sterile filter's `14.1 kPa`, the rotameter's `81.7 % of scale`, the metering valve's
    `Cv 0.0296 at the 4.087 L/min design point`. Integrating the culture volume moved all of them by
    about 1.3 %: 14.28 kPa, 82.8 %, and Cv 0.0303 at 4.140 L/min
  - **no decision moved.** Still a 0-5 L/min rotameter, still `MNV-4K2` at 3.0x required and 34 % of
    travel. Held until the fill line above was settled rather than done twice, then refreshed
    against the pinned 8.25 L: filter 14.23 kPa, scale position 82.5 %, Cv 0.0301 at 4.125 L/min

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
- [x] align the assembly -> subassembly -> part parameter interfaces
  - both previews now derive rather than quote: `frame.scad` builds against a registered vessel row, and `head.scad` runs the frame's own accessors for the joint instead of copying their results. Verified by perturbing a driver — `-D threaded_rod_hole_allowance=3` used to leave `head.scad` standalone boring the old 9.2, and now tracks the assembly
  - the interface contract in `assembly.scad` was rewritten to describe the actual signatures, which it had never matched
- [x] carry the probe tail and connector dimensions in `atlas_probes.scad` and read them back
  - first attempt added a four-number tail group, which was wrong: tracing the geometry showed it held one dead number, two collet-shape numbers, and one derived hex size — no probe facts at all. `tail_maj_d` was provably inert (8.7 → 6 and 8.7 → 9.1 both render an identical part, because the port's hex cut is 9.18 across flats and removes strictly more), and it duplicated `neck`, which already described the same strain relief boot
  - settled shape: the registry holds one group per physical feature — `neck` the boot, `body` the cap, `tip` the shaft, `conn_d` the connector — and `bayonet_probe_port` derives the rest. The collet's neck section houses the boot, so `neck` sizes it; the hex is derived as `(conn_d + allowance) / cos(30)` so a round Ø8 connector clears the flats, instead of the magic 10 that silently encoded the same sum
  - envelope unchanged, internal cavities changed on purpose: same z extent and max radius, 9300 → 9556 facets

- [x] put the pH and DO caps on their datasheet values
  - they carried caliper readings of 15.6/16.0 and 36.0/35.6 where all six of those sheets say 16.0 x 36.2. Every row in the registry is now the product as its sheet describes it, with no exceptions, and the collet's allowances do the compensating
  - the `15.9` soft-backed / `16.3` hard-backed numbers are dropped. No datasheet mentions a backing variant, so it is not tracked; `cylindrical_flex_collet.scad` is a generic module and its preview values are just example hardware. If a backing variant turns out to be a real product it gets its own registered row

- [x] ~~spread the big ports so no two are adjacent~~ — **not achievable, closed**
  - four baffles equally spaced on twelve ports sit every third port, which leaves no port that is not adjacent to one. A probe must touch a baffle, both are std, and the worst pair is 27.2 mm whatever the tubes do
  - `jar_10L`'s binding gap is 2.254 mm with mixed port sizes and 2.254 without. The 19.3 mm this item claimed was arithmetic on an arrangement the baffle spacing forbids
  - it becomes possible with three baffles rather than four, which is a trade against baffle area and is recorded against `jar_6p5gal` in `docs/ports-layout.md` rather than assumed here

- [x] register a mini and a midi bayonet interface
  - `bayonet_std` is sized for the Ø16 Atlas probe body and nothing else needs it. A 2.4 mm dosing line carries the same 13.6 mm flange as a probe
  - the flange follows the face seal, not the bore: `oring_ID = 2*(lock_bore_r + land + cs/2)`, which returns exactly the registered 23 for std. Mini at iface_r 5 gives an 8.60 mm flange, midi at 7 gives 10.60. Small metric EPDM rings are orderable down to Ø9, so the seal is not the blocker
  - **check the bayonet's own pin geometry at iface_r 5 before trusting the number** - 3 pins at r 1.2 with a 30 deg sweep and 25 deg key have not been tried on a Ø10 circle
  - baffles cannot use either: the plate drops through the lock bore, so a mini gives a 3.6 mm baffle. Baffles stay std
  - **done.** Both registered and both render, pin and lock. The key margin was the flagged unknown and it holds: mini leaves 25 degrees against the 14.6 it needs
  - the thermocouple went further than midi. Its NPT mount stands ON the flange rather than passing through the bore, so 1/8 NPT needs 7.14 mm of flange and mini has 8.60 - the whole lid is now six std and six mini
  - it does not help the twelve-port lid at all, for the reason in the item above. It is what makes `jar_1p5L` buildable: six ports all std wants 87.6 mm and that jar has 87.5
  - the thermocouple's thread decides whether it is midi or std. 1/2 NPT needs std; 1/8 NPT fits midi. On twelve ports that is seven big ports versus six, and 142 mm versus 130 mm of smallest mouth. Threads and probes for both are already registered

- [x] make the port table a property of the vessel
  - two sets, recorded in `docs/ports-layout.md`: the full 12 for mouths over 130.4 mm, the reduced 6 for mouths over 81.6. Four registered vessels take the first, `jar_1p5L` and `jar_1gal_155` the second
  - `head_ports` is global today, so every vessel gets the 143 mm jar's lid. This is what item 10's JSON export is waiting on, and it needs the function names that landed in `head_port_index()`
  - the reduced set drops the four baffles and the acid/base pair. What a narrow jar gives up is pH *control*, not pH measurement
  - **done.** `head_ports` is the override now - undef derives the set from the mouth, setting it pins one. `jar_6p5gal` builds as a result, so two of six registered vessels build rather than one
  - the two narrow jars stop failing on port spacing and start failing on the motor mount overlapping their flanges, which is the item below and the real blocker
  - `docs/ports-layout.md` carries the numbers. jar_10L is byte-identical; it still takes the full twelve

- [x] ~~revisit the motor mount diameter~~ — **asked and answered: it stays at 56**
  - it can go to 42. Below that the mount's own base inserts run into the bearing pocket, which `head()` already asserts, at 0.15 mm of clearance at 42. The earlier note here said 36 from the gearbox faceplate; that floor is real but not the binding one
  - shrinking is not worth it. Deflection goes as the cube of height over diameter, and that ratio is calibrated against the build in hand at 2.3; 42 takes `jar_10L` to 2.9 against a warning that starts at 3. The one thing it would buy is eccentricity headroom - 0.060 to 0.092 e/T, not the 0.129 claimed here before - and that only matters on an unbaffled vessel, which the wide jars are not
  - **it was never the narrow jars' problem.** Their port flanges leave 35.4 mm on `jar_1gal_155` and 27.1 on `jar_1p5L`, so they are 6.6 and 14.9 mm of diameter short of the floor. Neither can carry a top-entry drive on its lid at any mount size, and no lid change reaches it. That is answered below by changing the agitation instead

- [x] report a mixing time
  - the reactor reports power, dissipation, Re and tip speed but never says how long it takes to blend, which is the number a fermentation paper leads with. Two standard correlations and this model already holds every input: Cooke's `t90 = 3.3 (1/N) Po^-0.33 (T/D)^0.33` and Ruszkowski's `t95 = 5.9 T^0.67 eps_T^-0.33 (T/D)^0.33`, both given in Hall 2004 (`docs/references.md`)
  - report both and the departure, do not assert. Hall is explicit that these were developed for fully baffled vessels of 1e-2 to 10 m3 and uses them at 60 mm "merely for comparative purposes"; this vessel is 8 L, so the same caveat applies and belongs in the echo
  - it also makes the unbaffled small jars sayable: Hall measured baffled 1.98 s against unbaffled centred 2.80 s at equal power, so a reported figure gives the reduced-port vessels something to be judged against
  - **done.** Ruszkowski only, and validated before encoding: 1.96 s against Hall's published 1.9 at 60 mm, 2.59 against 2.6 at 88 mm. This reactor is **4.58 s to 95% at the rated 320 rpm**, 3.49 s at no-load
  - Cooke's is deliberately absent. It could not be made to reproduce the figures Hall prints beside it, and a correlation that fails its own published check should not be in a report. Recorded in `docs/references.md` so it is not tried again without the discrepancy being resolved first

- [x] report kLa
  - the other headline number, and the one a reviewer will ask for first on a photobioreactor. Van't Riet's `kLa = C (P/V)^0.4 (u_s)^0.5` needs specific power, which is already computed, and superficial gas velocity, which follows from the sparge flow and the vessel bore
  - it is an air-water correlation and this is Miracle-Gro at 0.2 g/L, so it is an estimate of the right order and not a measurement - report it as such. Cabaret 2008 has measured values for unbaffled sparged tanks to sanity-check against
  - worth doing before the rebuild, since it is what says whether 0.5 vvm is the right set point rather than a guess
  - **done.** Both forms echoed; coalescing is the one that fits a 0.2 g/L broth, giving **0.0098 1/s at rated**, which lands inside the 0.01-0.06 1/s Cabaret measured for sparged unbaffled tanks
  - it is used below its fitted range - van't Riet is 500-10000 W/m3 and this vessel runs 209 - so the model says so every render. Still an air-water correlation for a real broth: an order of magnitude, not a measurement. A measured kLa would need a DO probe trace on a degassed vessel, which the rebuild could produce cheaply

- [x] split the baffles so they can be printed
  - a plate hanging to the floor is 172 to 280 mm across the vessels that carry baffles, plus 23 mm
    of port on top. Nobody prints that well: it is the tallest, most slender part in the model and
    it goes on the bed in the port's own axis, because the flange, the o-ring groove and the pins
    all want that orientation
  - **done.** `baffle_segment_height_max = 170` caps a piece, `baffle_segments = undef` derives the
    count from it and a number pins it. Every registered vessel comes out in two pieces; a 470 mm
    jar would take three. The cap targets 180 mm machines rather than the 250 mm ones, which costs
    less than it looks: at a 250 mm cap jar_10L still takes two pieces, because its part is 303 mm
    whole. What the choice actually costs is the short jar, which would otherwise print in one
  - the slide is along the plate's **width** and that is a load choice, not a shape one: the swirl
    pushes on the plate's face, so it bears on the flanks and the axis a sliding dovetail leaves
    free carries nothing. Blind at the far end, so it registers in one place
  - **measured, not reasoned.** The corner sweep in `dovetail()` was setting the tail back where it
    meets the face - the section crossing the joint plane measured **2.65 mm of a nominal 4.2** -
    so the root arc is now sunk below the plane and the plane cuts straight flank. Re-measured at
    4.22. The two pieces intersect in a zero-volume face at 0.1 mm allowance and interfere at -0.05,
    which is the fit being exactly what it says
  - what it costs: 4.2 mm of 9 crossing each joint is a tenth of the plate's second moment, and one
    joint adds 7 % to the tip deflection. Two things are not modelled - the first mode `head()`
    reports is the solid plate's, and the joint leaves a 0.1 mm crevice in a vessel that is
    chemically sterilised. See `docs/agitation.md`
- [x] the baffle deflection formula was wrong
  - `stirred_tank_baffle_deflection()` was checked only at zero freeboard, where it agrees with the
    right answer at `qL^4/8EI`. At the plate's real 49 mm it was **23 % low**
  - rebuilt from the point-load case integrated over the loaded span, cross-checked against a
    numerical double integration of `M/EI`. `jar_10L`'s plate deflects **1.53 mm, not 1.18** - on
    the tenth-of-width limit rather than inside it, and over it once the print joints are counted
  - **so the 15.3 mm plate now warns on every render of `jar_10L`.** Not chased here: it is the same
    jar whose baffle running clearance is already -0.28 mm, and both want deciding together
- [ ] **jar_10L's plate is against two limits at once**, both reported every render, neither
  asserted, and nothing printed yet - so they can be decided together
  - *deflection*: **done.** `baffle_thickness` 9 -> 10 puts the tip at **1.296 mm** against the
    1.53 mm tenth-of-width limit, and the warning is gone
  - *running clearance*: **still open, and the next action is a MEASUREMENT, not an edit.** 2 mm
    nominal to the impeller, less the 2.28 mm of lean the coupling's 0.2 mm of play allows at the
    lower impeller, so **-0.28 mm running** - the plate can reach the blades. Thickness does not
    touch it: it is a tolerance stack rather than a stiffness one
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
  - **the lever was not as free as this said.** It read that the lock bore does not cut into the
    15.3 mm width until 12.5 mm of thickness, so the plate could go to 12. The bore is not what
    binds. **The mode is.** Frequency goes as t^1.5, so thickening walks the plate's first mode up
    - 15.4 Hz at 9, 17.6 at 10, 19.8 at 11, 22.0 at 12 - and blade passing is four per revolution,
    sweeping 0 to 28 Hz on the way to the 420 rpm no-load speed. The crossing speed goes with it:
    231 rpm at 9, 264 at 10, 297 at 11, **330 at 12, which is inside the 320-420 operating band**.
    12 also fires the resonance echo. 10 is the whole window
  - **and the resonance check only looks at one speed.** It tests the mode against the excitations
    at the drive's *fastest* setting, on the grounds that fastest is worst. That is right for load
    and wrong for resonance: a DC motor's speed is continuous, so blade passing sweeps every
    frequency under 28 Hz and something is always crossed. What decides the plate is the *speed* at
    which the crossing happens and whether that speed is one the reactor runs at - which is what
    the numbers above are, and what the echo does not say

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

- [x] rename `gearbox_faceplate_screws_cdist` to say bolt circle
  - it was documented as "centre distance" but consumed as `separation / 2`, i.e. as a bolt circle diameter. For a 4-screw square pattern "centre distance" reads naturally as the square's side, and a 20 mm square is a Ø28.3 bolt circle — wrong by 40%
  - now `gearbox_faceplate_bolt_circle_dia`, and `motor_mount()`'s parameter renamed to match, so the quantity keeps one name from the registry row through to the hole it places. The `_dia` suffix settles diameter-versus-radius too, which retires the warning comment `gearboxes.scad` was carrying to compensate for the name
  - `peri_pump_frame_mount.scad`'s `flange_screw_distance` was checked and left alone: two screws mirrored at `± d / 2`, so it really is a centre-to-centre span
- [x] register the drive's output speed and the gearbox ratio
  - `gearboxes.scad` now carries `ratio` as a number, and `dc_motors.scad` carries `[no_load_out_rpm, rated_out_rpm]` at the output. The plan said one field; the E-S datasheet showed why it has to be two — the same motor is 1400 rpm no-load and 950 rpm rated, a factor of 1.47, so a single `rated_output_rpm` would have compared a ceiling against an operating point. That is the ambiguity this item existed to prevent, one level deeper than expected
  - the 36GP's 1154 is the vendor's only figure and is unqualified. Registered as no-load, because every vendor in this family names its variants by no-load speed; its rated speed stays `undef` rather than invented
  - `utils/stirred_tank.scad` gained Re, tip speed, shaft power, culture volume, and mean and peak dissipation. `head()` echoes them for each registered speed and says so plainly when a motor registers none. Verified against the table in `docs/agitation.md`: peak dissipation reproduces 0.68 / 11.6 / 1049 W/kg
  - **no tip-speed assert**, as planned — nothing new asserts at all
  - the non-geometric-field concern did not bite: the speeds sit in their own column and no geometry reads them. One genuinely new operating parameter did appear, `culture_fill_fraction`, because mean dissipation needs a volume and the model sets no fill line
- [x] decide the drive motor
  - **RM-ESMO-071, mfr 36PG-555PM-14-EN**: 14:1, no-load 420 rpm, rated 320 rpm at 5 kg·cm, with a magnetic encoder. Registered as `motor_36pg_555pm_14_en` and `head_motor` now points at it
  - the plan was the 19:1 sibling, on the argument that its whole rated-to-no-load span sits inside the band. The manufacturer sheets changed the answer: that containment only matters *because* there is no speed feedback, and the encoder variant retires the gap rather than working around it. It is also the only candidate reaching the 410 rpm break-even, which is half the comparison this instrument exists to make
  - the high-torque candidate (RM-ESMO-0MX, 7 kg·cm) went out on the numbers: the impeller pair asks under 5% of its rating so the torque buys nothing, its rated 240 rpm falls below the growth optimum, and it costs the same 57 mm of motor as the encoder one while shipping bare copper tabs
  - registering rated torque is what let that be argued in the model instead of in prose. The pair draws 14–24% of the rating, which is the evidence that an unmeasured shaft sits nearer no-load than rated
  - the E-S sheets gave far more than the product pages: one Ø28 faceplate across the whole 36PG range, gearbox length keyed to the ratio group (26.5 / 34.5 / 42.5 / 50.5 mm) rather than to the motor, and rated at 0.68–0.71 of no-load across all ten ratios — which vindicates the 0.679 the earlier estimate scaled by. All recorded in `docs/procurement.md`
  - the drawings also corrected `out_boss` from 3 mm to **2 mm** on both 36PG rows; the 3 was carried over from the 36GP and the file said so
  - **the stack grew 35.5 mm** (motor 30 → 57, gearbox 26 → 34.5), so the reactor envelope goes 543.75 → 579.25 mm and the cart 1312.5 → 1383.5 mm — the cart stacks two tiers, so every millimetre counts twice
  - confirm before ordering: the encoder sheet tabulates no gearbox length, so 34.5 is inferred from the 3429 sheet at 14:1, and it does not dimension the encoder past the can. Both feed the envelope
  - still worth a caliper: the bolt circle on the printed mount. Ø28 with M4 should clear holes cut for the 36GP's Ø27.6 / 4.2, so it may take the new motor without a reprint
- [x] register the encoder and report what it resolves
  - `dc_motors.scad` carries `[ppr, channels]` and `dc_motor.scad` derives counts per turn of the output: ppr x 2 edges x channels, taken through the reduction. 12 x 2 x 2 x 14 = **672 counts per output turn**, resolving 0.89 rpm over a 100 ms window against a band 155 rpm wide
  - most of that resolution is the gearbox rather than the encoder, which is why the ppr is registered as what it is — per channel at the motor shaft, ahead of the reduction
  - `head()` echoes it, and says plainly when a motor carries no encoder rather than echoing an undef. Exercised on all four registered rows, including the one with no gearbox to take a ratio from
  - `encoder_speed_window` is the one new parameter, an operating choice like `culture_fill_fraction`: the controller owns the real window and nothing is built from it
  - **no geometry, as expected.** The encoder sits inside the motor's own envelope, so nothing new is drawn and the render is untouched
  - the BOM's `Slice_DCMT` row now carries the wiring the motor actually needs — 2 motor leads and 4 encoder, no connector — flagged to confirm the board exposes the encoder inputs
- [x] design the sparger
  - **done, and its position is derived rather than chosen.** Birch & Ahmed 1997 - the paper whose
    stated aim is that "there seems to be no available information on the influence of sparger
    location on the gas dispersion performance of upward pumping mixed flow turbines" - conclude
    that the sparger goes above an up-pumping impeller and below a down-pumping one. This pair
    converges, so one ring in the gap sits in both discharges. `head_shaft_rotation` is what makes
    that true and `head()` warns if it is reversed
  - ring **1.44 D**, section **[4, 10] mm and not round**: the radial band between the baffles and
    the mouth is 6.95 mm and a round 6 mm section has no solution in it at any ratio, while the gap
    gives 73 mm of height. That is also what settled printed over bent - a tube is round
  - the feed does not attach at the ring's radius, where a round boss fouls the baffles and the
    mouth at 0.29 and 0.26 mm. An arm runs inboard along the air inlet's own baffle-free sector to
    a socket under the lid port, so the riser is straight and the junction is printed in
  - holes are 8 x 3 mm, for spacing and against fouling and **not** for even flow: capillary is
    96 Pa against 2.4 Pa of orifice, so they will not share equally at any count, and Rewatkar &
    Joshi find that near an impeller it does not matter
  - **superseded here:** Oldshue p. 214's 80 %-of-impeller ring, which two experimental studies
    contradict; and the claim that the sparger sits under the lower impeller
  - what is left is not geometry - see the gas supply item above

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

- [ ] **the sparger's tubes are not connectable, and its sockets are not tellable apart**
  - three follow-ups from the support-tube work, none of which the model does today. The first is a
    defect rather than an enhancement: the parts cannot be plumbed as drawn

  - **the tubes end flush with the lid.** `_sparge_riser_length = 0 - (...)` measures to the lid's
    OUTER face, so a tube runs up to the lid surface and stops - and the port's own flange stands
    5 mm above that, so the tube actually finishes *inside* its port. There is nothing to push a
    hose over, nothing to clamp, nothing for a fitting to grip. Wants a `proud` parameter measured
    from the port's top face, the way `rod_thread_proud` is measured from its nut

  - **nothing marks which socket feeds gas.** The feed socket opens into the ring's bore and a
    support socket bottoms 6 mm short, but they differ only by 4.8 mm of depth - same diameter, same
    height, same arm. Put the gas line in a blind socket and nothing tells you: the pump runs, the
    rotameter reads flow, and the gas vents at that tube's own hole instead of the ring. The arm has
    an 8.15 x 4 mm flat free, which takes "GAS" at 2.5 mm, and this repo already engraves its ports.
    A height or shape difference would do as well and needs no text

  - **nothing says where the drilled hole or filed slit goes.** A support tube is capped at the ring
    and does its real job through a hole higher up - a vent in the headspace, a media line wherever
    it should discharge. That is a hand operation and does not need modelling, but the HEIGHT does
    need stating, and the model is the only thing that knows where the liquid surface is. It already
    asserts exactly this for the thermocouple

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
    a normal choice rather than a compromise. It would make the family span two agitation modes off
    one lid and one sparger, which is a stronger claim than one mode across six jars
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

## bill of materials

- [x] add the sealing parts, the motor mount fasteners and the head-to-frame joint fasteners
  - every part the model calls for now has a row in `purchased-parts.csv`: the AS568-160 plug o-ring, the EPDM rim gasket sheet, 4 heat-set inserts and 4 M4 x 8 screws per lid, and 8 M8x30 bolts with 20 M8 nuts for the joint
  - the "Silicone gasket ring, 142 mm ID" row was this same rim gasket under an older name, at a size that cannot pass over the 142.6 mm plug. Replaced rather than added beside
  - each row quotes what the model echoes at render rather than repeating the arithmetic, so a substitute is checked against the echo: the ring against the 132.098-138.703 mm ID window, the sheet against the 145 x 151 mm cut, the screws against the insert's 4.7 mm of thread
  - a soldering iron with a conical tip is the install tool for the inserts, and stainless wants more heat and dwell than brass would. McMaster sell tips for it if we do not want to use a working iron's bit
- [x] ~~pick McMaster part numbers for the four fastener rows~~ — **answered by not doing it**
  - the AS568-160 o-ring resolved separately to 8785N637, so what was left was three fasteners and
    the threaded rod
  - a commodity fastener needs a STANDARD, not a catalogue number. Nothing in the model reads a
    property of these beyond nominal size and a derived length, both of which the standard carries,
    and a supplier code is region-specific and perishable where `ISO 4017 M8x30 A2-70` is not. It
    is also the direction the part-vs-supplier split wants to go rather than against it
  - `check-bom` was never going to cover them either way: it compares what the SCAD REGISTRIES
    prescribe, and there is no bolt registry. A number in that column would have bought nothing
  - the rest of the sealing and mount hardware stays pinned by number, because each carries
    something a spec does not: 8525T65 sheet, 97163A152 insert (its geometry cuts the lid pocket),
    8785N383 port o-ring, 6153K71 bearing

- [ ] **no check ever builds the geometry it checks**
  - `check-scad` exports **`.csg`**, which is the CSG tree rather than a solid, so CGAL never runs
    and a degenerate solid is invisible to `just check`. `check-vessels` does the same
  - that is how the pitched blade sat TANGENT to its hub - joined along a line of zero width, 264
    non-manifold edges in the mesh, OpenSCAD calling it out on every render - through a green suite.
    Anyone slicing the STL would have met it; nothing in the repo does
  - the guard is a recipe that renders the `entry` files to STL and fails on
    `may not be a valid 2-manifold`. **The cost is why it is not done here:** head.scad takes minutes
    to render where its `.csg` takes seconds, so this cannot go inside `just check` without changing
    what that recipe is for. A separate `check-mesh`, run before a print rather than on every edit,
    is the shape that fits
  - `head_impeller_swept_radius()` has the same flavour. It is `max(D/2, hub)` - a formula, not a
    measurement of what is drawn - so the echo comparing it against `impeller_diameter` can only
    ever fire on a hub wider than the impeller. It could not have caught the outboard tip ring it
    was written for, and it cannot catch the next one


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
    against is itself uncalipered - the item below


- [ ] add PowerShell and shell scripts to export a chosen assembly parameter set as individual STL files, together with a print list, BOM, and other relevant build outputs
  - **the JSON half is done.** `just json` writes `scad/assembly.json` and `scad/head.json` from the vessel registry, one set per jar, and `openscad -p scad/assembly.json -P <vessel>` selects one. `check-json` fails if either file is stale or its dropdown has drifted
  - what closed it was not the format but being able to CHOOSE: `reactor_vessel` was a reference to a registry variable, and a parameter file carries values, so under `-p` OpenSCAD dropped it and every set built the same jar. It selects by name now
  - what is left is the scripting: walk the sets, export each part to STL, and emit the print list and BOM beside them. Two of six vessels build today, so four of the six sets would fail - which is worth REPORTING rather than hiding, the same way `check-vessels` records what does not build
  - only `reactor_vessel_name` is name-selectable so far. The other fourteen registry choices - motor, gearbox, impeller, bayonet, gasket sheet, bearing, fasteners - are still variable references and would need the same treatment before a set could vary them. Not needed for a per-vessel export, and not worth doing until something wants to vary them
- [ ] run `tokei` in CI to report lines of code and other codebase statistics
- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based OpenSCAD preview

## second hardware revision

- [x] use a less expensive shaft for the impeller, and try for 300 mm instead of 400
  - **300 mm does not exist.** McMaster cut 8 mm stainless rotary shafts at 100, 200, 400, 600, 800
    and 1000; the part-number gap that suggested a 1265K65 is not a 300 mm shaft
  - 200 mm cannot reach either. The shaft spans a 295 mm vessel, so at 200 its top ends 98 mm
    *below* the lid with nothing to couple to, and reclaiming the impeller hub does not close a
    170 mm gap
  - **400 mm is right, and it costs nothing it used to.** The mount was only oversized because the
    lower impeller was pinned to the shaft's end, so raising the impeller raised the shaft and the
    mount with it. `10b49bc` decoupled them: the shaft runs to the punt whatever clearance is asked
    for, and the mount holds at **122 mm across the whole usable range** - it does not grow at 0.9 D
    any more than at 0.42
  - the surface rating is not incidental either. It is a **rotary** shaft, turned, ground and
    polished, and it runs directly in the 608 bearing's inner race - the -0.005/0 against the
    bearing's -0.007/0 is a transition fit. Plain rod at h9 would allow 0.043 mm and fret the bore.
    See `purchased/shafts.scad`, which states this at length
- [ ] swap out the threaded rods with printed parts
