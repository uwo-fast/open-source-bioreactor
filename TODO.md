# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [x] rethink how the impeller diameter is driven, and guard it
  - the guard landed first: `head()` now refuses an impeller whose top ring cannot pass the vessel's opening, which caught `jar_6p5gal_305x470` building a 145 mm impeller for a 137 mm mouth
  - the driver was wrong in its reference, not its value. It multiplied `vessel_outer_diameter`, but D/T everywhere in the literature is against the vessel's wetted bore, so the real ratio drifted with the glass — 0.468 to 0.489 across the registry for one nominal 0.45. It now reads the bore and is constant
  - `impeller_bore_ratio = 0.45` sits mid-band on every citation and is what lets every registered vessel build. `jar_6p5gal_305x470` is the binding one: its 137 mm mouth caps the ratio at 0.4594 with the impeller exactly filling the neck, so 0.45 leaves 2.64 mm to pass it through. The relations and their citations are in `scad/utils/stirred_tank.scad`, the reasoning in `docs/agitation.md`
  - the twist angle and the blade height are the parameters with no support — nothing citable exists for 55 degrees, or for the W/D of a twisted extrusion at all. Both are left alone and marked; `twist` turns out to be a pitch specifier rather than a blade angle, so the honest treatment is the derivation recorded in `docs/agitation.md`. A bench power-number measurement would settle it
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
- [ ] design the sparger
  - the largest open item in the reactor's fluid design. Bubble rupture rather than impeller shear dominates cell damage, and there is no sparger in the model at all — air enters through a bayonet tube port. `ports-layout.md` already reasons about a "primary sparger sector" that does not exist
  - needs its own research pass: bubble size, orifice velocity, sparger geometry, whether Pluronic F-68 belongs in the medium, and Nienow's requirement that the sparger sit below the lower impeller
  - **there is no citable critical entrance velocity.** The 30-50 m/s this item used to name was not supported by Barbosa 2003 once read: its own runs were 0.4-5.4 m/s, the larger figures are two comparison reactors from another study, and it closes by saying the parameter needs more work
  - the geometry no longer constrains this the way it did. Off-bottom clearance is a parameter now rather than a consequence of shaft length, and at 0.6 D the lower impeller leaves **26.7 mm** under it rather than the 10 mm it had. The new constraint is radial: the baffles hang full depth to r 64.55, and a 1.4 D ring sits at r 66.15 — **1.6 mm apart**
  - **the ring geometry is now citable.** Oldshue 1997 p. 214: a sparge ring at about 80 % of the impeller diameter beats both an open pipe beneath the impeller and a ring larger than it, because the gas should enter where it passes straight through the impeller's high-shear zone. On the 94.5 mm impeller that is a **~75.6 mm ring**. So S5's first two questions are settled — ring diameter, and that it sits under the impeller — and the open one is the vertical room to put it in
  - Oldshue's **1-2 d for fluidfoil impellers** turns out to be an allowance rather than a target ("if the impeller *can* be placed..."), and it is unreachable here anyway: his own coverage caveat in the sentence before it and the band do not overlap in a 241 mm column holding two impellers. Clearance is set at 0.6 D against C/T instead; see `docs/agitation.md`
- [ ] characterise the impeller's blade twist and height
  - both are uncharacterised design parameters with no citable basis; `twist` is a pitch specifier rather than a blade angle. A bench measurement would settle it: `Po = P/(rho*N^3*D^5)` from shaft power at three or four known speeds in water, across printed variants
  - one paywalled source might yet say something — Kumaresan & Joshi 2006, doi:10.1016/j.cej.2005.10.002, worth an interlibrary request

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

- [ ] add PowerShell and shell scripts to export a chosen assembly parameter set (eventually JSON, once the assembly is fully parameterized) as individual STL files, together with a print list, BOM, and other relevant build outputs
- [ ] run `tokei` in CI to report lines of code and other codebase statistics
- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based OpenSCAD preview

## second hardware revision

- [ ] use a less expensive shaft for the impeller and try and get in 300mm instead of oversized 400mm thats being compensated by the parameteric printed motor mount
  - might not need to be linear motion surface rated and all that
- [ ] swap out the threaded rods with printed parts
