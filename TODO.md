# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [x] rethink how the impeller diameter is driven, and guard it
  - the guard landed first: `head()` now refuses an impeller whose top ring cannot pass the vessel's opening, which caught `jar_6p5gal_305x470` building a 145 mm impeller for a 137 mm mouth
  - the driver was wrong in its reference, not its value. It multiplied `vessel_outer_diameter`, but D/T everywhere in the literature is against the vessel's wetted bore, so the real ratio drifted with the glass — 0.468 to 0.489 across the registry for one nominal 0.45. It now reads the bore and is constant
  - `impeller_bore_ratio = 0.45` sits mid-band on every citation and is what lets every registered vessel build. `jar_6p5gal_305x470` is the binding one: its 137 mm mouth caps the ratio at 0.4594 with the impeller exactly filling the neck, so 0.45 leaves 2.64 mm to pass it through. The relations and their citations are in `scad/utils/stirred_tank.scad`, the reasoning in `docs/agitation.md`
  - the twist angle and the blade height are the parameters with no support — nothing citable exists for 55 degrees, or for the W/D of a twisted extrusion at all. Both are left alone and marked; `twist` turns out to be a pitch specifier rather than a blade angle, so the honest treatment is the derivation recorded in `docs/agitation.md`. A bench power-number measurement would settle it
- [ ] **measured gas flow** — a reproducibility gap, not a geometry one. **Range now calculated; see `docs/procurement.md`, gas metering selection. Buy a 0-5 L/min rotameter and a metering valve.**
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
  - **sparge riser** — 316 tube, 4 x 2.5 mm x 166.7 mm as drawn. See its own item below
  - **four fastener rows have no McMaster part numbers** — see the nice-to-haves item
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
- [ ] register the sparge riser as a real purchased part
  - `head.scad` draws it at 4 x 2.5 mm and 166.7 mm long, and those numbers are **chosen, not
    bought**. It wants a 316 stainless tube row of the same shape as `purchased/shafts.scad` —
    part number, OD and ID with tolerances, length, and the same REACH/RoHS note the shaft carries
  - 316 for the reason the shaft is: wetted, and the reactor is chemically sterilised rather than
    autoclaved. Rigid rather than flexible tubing because **it is the only thing holding the ring** —
    nothing else in the vessel touches it — so it is structure as much as gas path
  - stiffness is not what picks the size. At a deliberately conservative 0.36 N the tip deflects
    0.164 mm at 4 x 2.5 and 0.034 at 6 x 4, so anything orderable works. What picks it is the
    **2 mm of slack it currently has through the port's 6 mm bore**, and how that gap is sealed —
    which is the tube port's business and is not yet answered

- [ ] draw the vitamins that are registered but never rendered
  - the **ball bearing** is registered as `BB608` and its numbers cut the lid's pocket, but
    `ball_bearing()` is never called, so the part it is cut for does not appear. A pocket drawn
    from a row nobody can see is the sort of thing that stays wrong quietly
  - the **impeller set screws** are the same: `impeller_set_screw` sizes and places the tap holes,
    but `screw()` is never called on it. NopSCADlib draws grub screws as `hs_grub`, so both are a
    render toggle and a call, not new geometry
  - wants its own `render_bearing` / `render_set_screws` flags alongside the existing ones, and
    both belong in `render_all`. Non-urgent: nothing derives from them and no fit depends on it

- [ ] caliper the real jar rim against the registered profile
  - the lid's gasket recess is cut to the flat land on top of the glass, which the model puts at 5.00 mm wide (r 71.5 out to 76.5) with a 2 mm bead rolled outboard below it. That land comes from the registered `rim_radius` and wall thickness rather than from a measurement, and the recess width follows from it, so it is worth confirming before cutting a gasket to it
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

- [x] the baffle deflection formula was wrong
  - `stirred_tank_baffle_deflection()` was checked only at zero freeboard, where it agrees with the
    right answer at `qL^4/8EI`. At the plate's real 49 mm it was **23 % low**
  - rebuilt from the point-load case integrated over the loaded span, cross-checked against a
    numerical double integration of `M/EI`. `jar_10L`'s plate deflects **1.53 mm, not 1.18** - on
    the tenth-of-width limit rather than comfortably inside it

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
- [ ] pick McMaster part numbers for the four fastener rows
  - the M8x30 bolt, the M8 nut, the M4x8 socket head screw and the AS568-160 EPDM o-ring are specified but carry `TODO` in the part_number column. Everything needed to select them is in the row; what is missing is a catalogue number and a price
  - the rest of the sealing and mount hardware is already pinned: 8525T65 sheet, 97163A152 insert, 8785N383 port o-ring, 6153K71 bearing

## tooling / infrastructure / documentation

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
