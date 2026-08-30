# Agitation design basis

Why the impeller is the size it is, what actually limits agitation in this reactor, and what is
still unknown. Sources are catalogued in [`references.md`](references.md); this document is the
reasoning, not the bibliography.

---

## 1. What limits agitation

Ranked by what the evidence supports:

1. **Bubble rupture at a sparger or free surface** — dominant in any aerated vessel, 10⁷–10⁹ W/m³
2. **Local maximum energy dissipation rate ε_max** near the impeller — not the vessel mean
3. **Shear stress in Pa** — the practical metric for microalgae, measured directly in Couette devices
4. **Kolmogorov microscale against cell diameter** — real principle, not binding at these scales
5. **Tip speed** — a convenient proxy with no mechanistic standing

**Bubble rupture, not impeller shear, is the dominant damage mechanism.** Sobczuk et al. studied
*P. tricornutum* and *Porphyridium* on one rig and concluded that mechanical agitation was not the
direct cause of damage — bubbles rupturing at the culture surface were, with the impeller
implicated only as the thing that generated them. Independently, for mammalian cells, removing the
gas–liquid interface leaves growth and viability unaffected at 100–450 rpm, at 600 rpm in a
fully-filled vessel, and at 1500 rpm for hybridomas.

**Tip speed is not a design criterion.** It does not have the dimensions of either shear rate (s⁻¹)
or shear stress (Pa), a point Nienow makes in 2006 and repeats in 2021. The widely-quoted 1.5 m/s
limit traces to a single measurement on human melanoma cells in 5 % serum, generalised into a
universal rule in a paper that two sentences later reports 6 m/s causing no measurable harm to a
hybridoma line. **No tip-speed limit is asserted anywhere in this model, deliberately.**

**For *Chlorella vulgaris* the relevant figure is an optimum, not a threshold.** Leupold et al.
measured a peak at **1.26 m/s tip speed (0.45 Pa)** — 4.0 % higher photosynthetic activity and 48 %
higher growth against unstirred — with activity falling back to the unstirred control by **2.03 m/s
(0.9 Pa)** and 7–8 % below it by 5.89 m/s. No lethal limit was found at any speed tested. Chlorella
is a rigid-walled green alga, the most shear-tolerant class.

> **Assumption, stated once and carried everywhere below.** Leupold's apparatus is a Gust microcosm
> — 1.75 L, mixed by a **spinning plate with skirt** 5 cm off the bottom — not a stirred tank with
> an impeller. Their tip speed is that plate's rim speed, and the shear it makes lives in a
> plate-to-wall gap rather than an impeller's discharge jet. **Reading 1.26 and 2.03 m/s as impeller
> tip speeds is this project's transfer, not their result.** It is the only *Chlorella*-specific
> agitation measurement available, so the band below is built on it anyway — but every speed, every
> D/T argument and the motor selection itself inherit that assumption. See `docs/references.md` for
> what the paper actually reports, including that its calibration is direct only to 250 rpm and that
> the quoted Pa figures are the stress the authors call secondary in their own experiment.

---

## 2. This reactor, in the units that matter

Computed on the 94.5 mm impeller in the 10 L jar, with **Np = 1.498 from Medek's correlation** for
the registered 45° four-blade pitched turbine, and x = 16. Mean dissipation is over the **8.25 L**
this build is pinned to by `culture_working_volume`, not over the full jar — which holds 9.57 L brim
full. `head()` echoes every figure below at render.

| shaft speed | tip speed | Re | ε̄ (W/m³) | ε_max (W/kg) |
| --- | --- | --- | --- | --- |
| 255 rpm — Chlorella optimum | 1.26 m/s | 37,800 | 105 | 15.4 |
| 320 rpm — registered drive, rated | 1.58 m/s | 47,400 | 207 | 30.5 |
| 410 rpm — break-even | 2.03 m/s | 60,800 | 436 | 64.2 |
| 420 rpm — registered drive, no-load | 2.08 m/s | 62,300 | 468 | 69.0 |
| 1154 rpm — 36GP-3530 at full speed | 5.71 m/s | 171,100 | 9,738 | 1,432 |

Every figure in that column rose about 62 % when the blade changed, and none of it is the impeller
getting worse. The old numbers used **Np = 0.99 borrowed from a differently shaped blade**, with a
note calling them conservative; they were optimistic. Np is computed from this impeller's own
geometry by a correlation that states where it is being extrapolated.

Both columns then fell about 7 % when the fill line was pinned to a working volume, and Np went
1.602 to 1.498. Medek's correlation reads **H/T**, so changing how full the vessel is changes the
power number. Neither move is the impeller changing — only what is known about it.

**The vessel is fully turbulent throughout the band.** Every speed above clears both the textbook
Re > 10⁴ threshold and Nienow's stricter 2×10⁴.

**The margin against damage is large.** At the rated 320 rpm the impeller's peak dissipation is
~3.0×10⁴ W/m³ against bubble rupture at 10⁷–10⁹ W/m³ and a CHO lethal range of 10⁶–10⁸ W/m³ — two
to five orders of magnitude. Agitation is not what threatens this culture.

**Aeration dominates the power budget too.** The one peer-reviewed worked example for a microalgal
stirred tank puts aeration at 29.4–49.1 W/m³ against stirring at 0.65–1.30 W/m³.

### The operating point

On the 94.5 mm impeller the band worth aiming at is narrow:

| target | tip speed | shaft speed |
| --- | --- | --- |
| Chlorella growth optimum | 1.26 m/s | **255 rpm** |
| break-even, stirring stops paying | 2.03 m/s | **410 rpm** |

**The registered drive is the 36PG-555PM-14-EN**, 14:1, rated 320 rpm and no-load 420 rpm — 1.58 to
2.08 m/s. Of the motors examined it is the only one that reaches the break-even end of the band,
which matters because the comparison between optimum and break-even is one this instrument exists
to make.

It was taken over a 19:1 sibling whose entire rated-to-no-load span, 265–385 rpm, sits inside the
band. That containment is a workaround for having no speed feedback: with nothing measuring the
shaft, where it settles between rated and no-load is set by load, so both ends have to be safe.
**This motor carries a magnetic encoder instead** — 2 channels, 12 PPR at the motor shaft, which
past the 14:1 is 672 quadrature counts per output revolution and resolves about 0.9 rpm over a
100 ms window, against a band 155 rpm wide. Commanding a speed and measuring it beats choosing a
motor that cannot miss.

Torque is not what limits the choice. The impeller pair draws under 0.067 N·m at rated and under
0.116 N·m at no-load against a 0.490 N·m rating — **14 to 24 % of it** — so the shaft runs nearer
the no-load end than the rated one. That is why the registry carries rated torque and `head()`
reports the comparison at each speed: it is the fact that says where an unmeasured shaft settles.

The registries carry output speed, reduction ratio and rated torque, so `head()` computes Re, tip
speed, power, torque and both dissipation figures at render rather than leaving them to be worked
out by hand. **No-load and rated speed are registered separately**: across the ten ratios of the
36PG-3429 table, rated runs 0.68–0.71 of no-load, so treating a catalogue speed as an operating
point overstates it by about half. An unqualified vendor figure is a no-load figure.

The drive it replaces was open-loop PWM at ~39 % duty on a 1154 rpm motor, with the shaft speed
inferred rather than measured and no published operating point anywhere near the band.

---

## 3. Impeller geometry

### Diameter

`impeller_bore_ratio = 0.45`, measured against the vessel's **wetted bore** — the internal diameter,
not the outside of the glass. This matters: multiplying the outer diameter lets the real ratio drift
with wall thickness, which across this project's vessel registry meant 0.468 to 0.489 for one
nominal 0.45.

The value sits mid-band on every source: 0.3–0.5 generally, 0.4–0.5 for axial impellers in cell
culture, 0.44–0.46 as a manufacturer's "most preferred". Above roughly 0.5 an axial impeller loses
its strong axial motion.

**`jar_6p5gal_305x470` is the binding vessel.** Its 137 mm mouth on a 280.8 mm bore caps the ratio
at 0.4594 with the impeller exactly filling the neck; 0.45 leaves 2.64 mm to pass it through. Every
other registered jar tolerates 0.59 to 0.82. The model asserts that the impeller — measured across
its fin-top ring, which is what meets the neck first — can pass the vessel's opening.

### Blade twist and height — out of the literature's tested range

`impeller_twist_ang` and `impeller_height` remain **uncharacterised for this blade**, but not for
the reason recorded here until 2026-08-13. That entry said twist had "no citable basis" and that a
search found nothing giving a value. Both twist papers were obtained and read on that date, and
both give values.

Patwardhan & Joshi 1999 §3.4.3 and Kumaresan & Joshi 2006 §3.1.3.3 define **blade twist as the hub
angle minus the tip angle**, and agree on the direction: increasing twist **lowers** the power
number and the primary flow number, while secondary flow and shear move much less. Patwardhan
tested 10° and 20° twist on 30°, 45° and 60° blades; Kumaresan tested 10° on a 30° six-blade
turbine and measured a 3 % drop in secondary flow number and 1 % in averaged shear.

On their definition **this blade is a 30° twist**, 83° at the hub to 53° at the tip — 1.5× the
largest twist either tested, at hub angles 23° beyond either's range. So the numbers do not
transfer, but the direction does, and it matters: **Po = 0.99 is borrowed from an untwisted blade,
so it is likely an over-estimate here**, making the power, dissipation and torque figures above
conservative rather than optimistic.

A second, smaller departure was added deliberately. The hub carries the set screws that hold the
impeller to the shaft, and sizing it for thread engagement grew it from 7.5 to 10 mm radius — from
0.159 D to 0.212 D, burying 6.3 % more of each blade's span. That is within the 0.2–0.33 D hubs
carry in practice, and it is a real trade: the alternative was a local boss that left the blade
alone, at the cost of geometry that prints with an overhang and has to be indexed against the
blades. The joint was the binding problem, and a slipping impeller costs the whole run.

Nothing citable was found for W/D or blade height of a twisted extrusion. The classic `w = D/4`
ratios describe flat Rushton blades and do not apply.

What can honestly be said is derived from the geometry itself. `linear_extrude(twist=)` sweeps a
**constant-pitch helicoid**, so the parameter is a *pitch* specifier and the blade angle β measured
from the plane of rotation varies with radius:

```text
tan β = P / (2πr),   P = axial advance per turn = height × 360/twist

at twist = 55° over a 60 mm impeller:  P = 393 mm,  P/D = 4.2
   hub 83°     0.4R 73°     0.7R 62°     tip 53°
```

A flat pitched blade sits at one angle everywhere; the tested turbines are 24°, 35° and 45°. **This
blade is steeper than 45° at every radius**, making it a twisted paddle biased toward radial pumping
rather than the axial impeller the D/T guidance is written about. A 45° tip would need ~73° of twist.

**A bench measurement would settle it.** `Po = P/(ρN³D⁵)` from shaft power at three or four known
speeds in water, repeated across printed variants, gives a real power-number curve for this blade —
more than the literature currently offers for anyone.

### Blade count

4 blades. Measured on otherwise identical folded-blade axial impellers, Po runs 0.79 / 0.99 / 1.34
for 3 / 4 / 6 blades, so going to 6 costs about 35 % more power at the same speed and diameter.

### Spacing

`impeller_spacing_factor = 1.0`, in impeller diameters. This sits at the bottom of the cited 1.0–2.0
band, and below the ~1.55 d at which pitched-blade pairs act independently — so the pair interacts
and power is not simply additive. In terms of tank diameter it is 0.45 T, inside the 0.33–0.5 T that
Nienow specifies for a stacked pair.

The upper impeller is a **mirror** of the lower, not the same part turned over: pumping direction
follows blade handedness and no rotation changes it.

---

## 4. Why large and slow

At **fixed tip speed**, peak dissipation falls as the impeller grows:

```text
ε_max = 1.04 · x · Po^(3/4) · N³ · D²        with v_tip = πND fixed:   ε_max ∝ 1/D
```

Doubling impeller diameter halves the maximum local energy dissipation, because the same power is
spread over a swept volume that grows as D³. At **constant power per volume** in a fixed vessel,
v_tip ∝ D^(−2/3) while pumping Q ∝ D^(4/3) — a larger impeller runs slower at the tip *and* pumps
more. Peak-to-mean dissipation scales as (T/D)³, so moving D/T from 0.33 to 0.50 cuts it by ~3.5×.

This is why shear-sensitive culture wants a large impeller turning slowly, and it runs opposite to
the intuition that gentler means smaller and faster.

**One caution:** "low shear" impellers are not reliably gentle. A low power number can coexist with
a *higher* peak dissipation than a Rushton turbine. Size the impeller; do not trust the label.

---

## 5. Open

- **There is no sparger in the model.** `ports-layout.md` reasons about a sparger sector and bubble
  trajectories, but air enters through a bayonet tube port and nothing else. Given that bubble
  rupture is the dominant damage mechanism, this is the largest open item in the reactor's fluid
  design. Damage originates at the sparger during bubble *formation* rather than at bursting
  (Barbosa 2003), but **no critical entrance velocity is established** in anything read here — the
  "30–50 m/s" this document carried until 2026-08-13 was not supported by its source, which reports
  0.4–5.4 m/s in its own runs and says the parameter needs more work.
  **The geometry, though, is now citable.** Oldshue 1997 p. 214: *"A sparge ring about 80 % of the
  impeller diameter is more effective than an open pipe beneath the impeller or sparge rings larger
  than the impeller,"* because the gas should enter where it passes straight through the impeller's
  high-shear zone. On the 94.5 mm impeller that is a **~75.6 mm ring**, and it agrees with Nienow's
  requirement that the sparger sit below the lower impeller. **The binding problem is vertical
  room**: the lower impeller sits 0.42 D off the floor, leaving 10 mm of clear space beneath it, so
  the off-bottom clearance has to be settled before a sparger can be drawn at all.
- **Off-bottom clearance used to be a consequence of shaft length, and is now a design parameter.**
  The impeller was placed with its bottom flush against a shaft that bottomed out 5 mm over the
  punt, so `C = punt + shaft clearance + height/2` — a *mixing* quantity falling out of *how long
  the shaft was*. Raising it therefore meant raising the shaft, which pushed the motor mount up with
  it, and at 400 mm — the only length McMaster cut that reaches this vessel, since there is no
  300 mm — that took the mount past three diameters of slenderness. The impeller is now placed off
  the floor by `impeller_clearance_factor` and the shaft runs past it down to the punt regardless,
  so **the mount stays at 122 mm across the whole usable range** and that sum is asserted as the
  lower bound instead of being the definition. The band is **0.4233 to 1.2328 D**: below it the
  shaft no longer reaches the impeller's bore, above it the upper impeller breaks the surface and
  pumps air. Oldshue's 1.0–2.0 for fluidfoils is therefore reachable up to 1.233, and what buys the
  clearance is submersion, not stack height.
- **The gas enters between the impellers, and that position is derived rather than chosen.** Birch
  & Ahmed 1997 set out to fill exactly this gap — their introduction says *"there seems to be no
  available information on the influence of sparger location on the gas dispersion performance of
  upward pumping mixed flow turbines"* — and conclude that *"the direction of flow from these
  impellers dictates that the sparger be placed **above the impeller for the PDU**, and **below for
  the PDD**"*. This pair converges: the lower pumps up, the upper pumps down, so the gap between
  them is above one and below the other. **One ring satisfies both.** A diverging pair would need
  two, which is what `head_shaft_rotation` is for and why `head()` warns if it is reversed.
- **The ring is 1.44 D and its section is not round.** The radial band between the baffles at
  r 64.55 and the jar's mouth at r 71.50 is **6.95 mm**, and a round section of 6 mm has no solution
  in it at any ratio — 4.95 mm is the largest that fits with a millimetre each side. But the squeeze
  is *entirely* radial: the gap gives 73 mm of height. So the section is **4 mm radial × 10 mm
  axial**, a 1.6 × 7.6 mm bore of 12.16 mm², about a 6 mm tube's, spending the dimension that is
  free. **This is why the ring is printed and not bent**: a tube is round, and round does not fit.
- **The feed does not attach at the ring's radius.** A round boss there is wider than the section
  and fouls the baffles on one side and the mouth on the other — measured at 0.29 and 0.26 mm. The
  ring instead runs an arm inboard along the air inlet's own angular sector, which has no baffle in
  it, ending in a vertical socket under the lid port. The riser is then straight, and there is no
  hollow tee to build because the junction is printed into the ring.
- **The riser is structure, not just plumbing.** Nothing else in the vessel touches the ring, so
  the tube that feeds it is also what holds it — which is why it is a rigid 316 tube rather than
  flexible tubing. Stiffness is not what sizes it: under a deliberately conservative 0.36 N the tip
  deflects 0.164 mm at 4 × 2.5 mm and 0.034 at 6 × 4, so anything orderable is stiff enough. What
  sizes it is the port bore it passes through and how that gap seals, which is still open.
- **The gas supply has to beat 1121 Pa before anything bubbles** — 104.7 mm of culture over the ring
  is 1025 Pa of head, plus 96 Pa of capillary at a 3 mm hole. That is about 11 mbar, well inside an
  aquarium pump, but it is the number a pump has to be chosen against and nothing recorded it before.
- **Hole geometry is for spacing and against fouling, not for even flow.** Rewatkar & Joshi:
  *"hole size and number of holes have negligible effect when the sparger is located near the
  impeller."* Worked through, even flow is not achievable anyway — capillary pressure to launch a
  bubble is 96 Pa against 2.4 Pa to push gas through the hole, so the holes will not share equally
  at any count, and a fixed tolerance hurts *small* holes most (±0.1 mm is 58 Pa of spread at 1 mm
  and 1.6 Pa at 6 mm). Eight at 3 mm.
- **The blade is a 45° four-blade pitched turbine, and it was chosen for what can be said about
  it.** The alternative was the constant-pitch helicoid this project drew by hand, whose power
  number is not merely unmeasured but **uncorrelatable**: Medek's envelope stops at 60° of blade
  angle and that blade runs 83° at the hub to 53° at the tip, so no source reaches it. Ameur's
  helical-screw work is viscous and laminar where this vessel is Re 47,000 in water. Its blade
  width had no source either — after Fořt supplied h/D 0.2 for the pitched and folded families, the
  helicoid's 0.634921 is the only geometric ratio left in the registry with nothing behind it.
  A pitched blade is also the easiest thing in the registry to draw and to print, where the
  helicoid was the hardest.
- **The switch is not free and the direction may read backwards.** Po goes 0.99 → 1.602 and every
  power, dissipation and torque figure rises about 62 %. That is a borrowed number being replaced
  by a correlated one, not the impeller getting worse; the old figures carried a note calling them
  conservative, and they were optimistic. It also loaded the baffles 62 % harder — they react the
  impeller's torque — which took the plates from 8 mm to 9 to stay inside their deflection limit.
- **What it bought back is vertical room.** At h/D 0.2 the blade projects `h·sin 45°` = 13.4 mm onto
  the shaft against the helicoid's 60 mm, so the pair spans 107.9 mm of the 241 mm column instead of
  154.5. At the same 0.6 D clearance the sparger's room goes **26.7 → 50.0 mm** and coverage over
  the upper impeller **0.63 → 0.88 D**. The two quantities that were competing all afternoon both
  improved, and the clearance could now be raised to about 0.95 D before coverage binds.
- **Axial was kept over radial deliberately.** A Rushton would disperse gas better — Oldshue's
  3× against 8–10× — but a photobioreactor's criterion is Molina Grima's *"frequency of switch"*
  between light and dark, which is pumping, not power. On circulation bought per watt (`N_Q/Po`)
  an axial blade beats a Rushton **4.3×**. And the gas criterion turns out not to bind: the axial
  pair covers 0.5 vvm at 332 rpm and 1.0 vvm at 418, both inside the drive's band.
- **The clearance is 0.9 D, set from the source the power number comes from.** Fořt tested pitched
  blade impellers at C/D 0.5 and 1.0 and concluded that *"the impeller hydraulic efficiency exhibits
  higher values for impeller off bottom clearance equal to the impeller diameter than for half of
  this distance, when interference between the bottom and the impeller takes place"* — and his
  abstract ties low clearances to solids suspension and higher ones to blending miscible liquids,
  which is this reactor's duty. Medek's correlation reproduces it from the other side, since
  `Po ∝ (C/D)^−0.165` and `N_Q ∝ (C/D)^0.254`:

  | C/D | Po | N_Q | N_Q/Po | vs 0.6 |
  | --- | --- | --- | --- | --- |
  | 0.6 | 1.602 | 0.806 | 0.503 | — |
  | 0.8 | 1.528 | 0.867 | 0.568 | +12.8 % |
  | **0.9** | **1.498** | **0.893** | **0.596** | **+18.5 %** |
  | 1.0 | 1.473 | 0.918 | 0.623 | +23.9 % |

  `N_Q/Po` is circulation bought per watt — the light/dark switching criterion again. **0.9 rather
  than 1.0** because 1.0 is the correlation's own C/D limit, leaving no margin on the number the
  whole design now rests on, and because it drops coverage over the upper impeller to 0.48 D. The
  last 4.5 % of efficiency is not worth spending both margins on.
- **Oldshue's 1–2 D no longer applies at all, and that is a class distinction rather than a
  reinterpretation.** His passage is about *"these fluidfoil impellers"* — the hydrofoil class —
  and a pitched blade turbine is a different, older one. Both halves of it, the allowance and the
  coverage caveat about short-circuiting, are fluidfoil statements. `head()` now reports the number
  as context and names Fořt's as the guidance that fits the blade. The 0.5 D coverage floor is kept,
  but on its own footing: a down-pumping impeller near the free surface entrains air, which is true
  of any blade and not Oldshue's to authorise.
- *(Superseded — kept for the record.)* **The clearance was 0.6 D. Oldshue's 1–2 D is an allowance this vessel cannot reach, which is not
  the same as a target it misses.** Read the sentence as written: *"**If** the impeller **can** be
  placed one to two impeller diameters off bottom … these impellers **offer** an excellent flow
  pattern as well as considerable economies in shaft design."* It rewards being able to sit high;
  it does not instruct you to. `head()` therefore reports the departure rather than warning on it.
  And the sentence has a second half that pulls the other way, in the same paragraph: fluidfoils
  *"short-circuit the fluid to a relatively low distance above the impeller. Very careful
  consideration of the coverage over the impeller is important."* Both requirements are Oldshue's,
  and here they do not overlap — the band needs C ≥ 94.5 mm, and keeping half a diameter of liquid
  over the upper impeller needs C ≤ 69.2 mm:

  | C/D | C | under lower | cover over upper |
  | --- | --- | --- | --- |
  | 0.423 (as inherited) | 40.0 | 10.0 mm | 76.5 (0.81 D) |
  | **0.600 (chosen)** | **56.7** | **26.7 mm** | **59.8 (0.63 D)** |
  | 0.700 | 66.1 | 36.1 mm | 50.4 (0.53 D) |
  | 1.000 (band floor) | 94.5 | 64.5 mm | 22.0 (0.23 D) |

  This is structural, not a near miss. Blade height is the only other term in the span, and it is
  the least defensible number in the model — but even at 0.4 D instead of 0.635 the ceiling only
  moves to 0.85 D. **The cause is that the vessel is short for two impellers**: they span 154.5 mm
  of a 241 mm column, and H/T is 1.124 where convention adds a second impeller above about 1.2.
- **0.6 D was chosen against a second, independent scale — an uncited one.** Off-bottom clearance
  is more often written C/T, and the quarter-to-third of tank diameter usual for an axial impeller
  maps to **C/D 0.556–0.741** in this bore. *No source held here states that convention* — it is
  not in Oldshue, and it is recorded as convention rather than citation, which is why no band
  function encodes it and nothing warns against it. It is corroboration, not authority: that window
  and the coverage limit agree independently, so the chosen value is reported both ways. 0.6 D is
  **C/T 0.27**, mid that window and below the coverage ceiling with margin. It roughly triples the room under the lower impeller, from
  10 mm — which fits no sparger at all — to 26.7 mm.
- **The 0.5 D coverage floor is reasoned, not cited.** Oldshue names the concern and gives no
  number. It is the depth below which a down-pumping impeller starts drawing its own discharge back
  off the surface instead of turning the vessel over, and `head()` warns rather than asserts on it.
- **No energy dissipation rate limit exists for any microalga.** The parameter the physics says
  governs has no citable number for these organisms.
- **Speed feedback is specified but not yet wired.** The registered drive carries a magnetic
  encoder and the model reports what it resolves — 672 counts per output turn, 0.89 rpm over a
  100 ms window — but nothing reads it yet, so tip speed and Re are still computed from a commanded
  speed rather than a measured one.
- **The count is now Oldshue's reference case, and the vessel is still under-baffled.** There are
  **four baffles at 90°**, which is the four-at-T/12 arrangement Oldshue 1997 p. 202 gives as the
  reference, so the count is no longer a departure to explain. It is the **area** that does not
  match: his baffles run the liquid depth, and these hang from the lid, so at an 8 L fill in a 10 L
  jar the liquid line sits 49 mm below a plate's own top. At the 100 mm length carried since the
  first print that leaves 51 mm wetted, and the wetted area is **0.19 of the reference**, up from
  0.14 on three plates.
- **The plates now hang the full 280 mm, and the area is 0.86 of the reference.** Depth was worth
  roughly four and a half times what the next step in count is — an equally spaced count has to
  divide the port circle, so on twelve ports the choices are 2, 3, 4, 6 or 12, and six plates would
  have reached only 0.28. Both levers are now spent: the plates reach the floor limit, and going to
  six would need the port circle re-derived again.
- **What limited the depth was dynamics, not strength, and not collision.** Three candidate limits
  were worked and only one binds:
  - *Collision* does not. The plate bends **tangentially** and the impeller sweeps a circle, so
    deflection does not close the 2 mm radial gap to it. This was the constraint assumed at first
    and it is simply the wrong geometry.
  - *Strength* does not. Root bending stress at full depth is **0.69 MPa against ~50 MPa yield**,
    1.4 % — so creep is not a factor either.
  - *The first bending mode* does. It falls as 1/L², so going from 100 to 280 mm divides it by 7.8.
    A 4 mm plate at full depth lands at **5.4 Hz**, which is shaft rotation at the rated 320 rpm —
    a resonance at the steady operating point, not one passed through on the way up. It also
    deflects 8.9 mm, over half the plate's own width, so it would bend away from the swirl rather
    than block it.
- **So the plate is 8 mm thick rather than 4.** That puts the first mode at **13.3 Hz**, between
  shaft rotation (7 Hz at no load) and blade passing (28 Hz) and clear of both by more than 30 %
  even allowing ±30 % on the modulus and the added mass. Tip deflection falls to 1.1 mm. Thickness
  is free here: the lock bore would pass 18.1 mm at 8 mm thick and the impeller caps the plate at
  15.3 either way, so the extra thickness costs no width.
- **The load is reasoned from two directions and neither is cited.** Each plate reacts its share of
  the torque the impeller puts into the fluid, `T / (n · r)`, giving 0.51 N at no-load speed. The
  dynamic pressure of a tangential stream at 0.3 of tip speed gives 0.69 N over the same area. They
  agree within 26 %, which is the only corroboration available — no source held here loads a baffle.
  `head()` reports the load, the deflection and the first mode, and warns on deflection past a tenth
  of the plate width or a mode within 30 % of either excitation.
- **Added mass is not optional in that calculation.** For a plate this slender the entrained water
  is over twice the PETG's own mass, so leaving it out would overstate the first mode by about 80 %
  and hide exactly the resonance that drove the thickness.
- **The deflection all of those numbers came from was wrong, and is corrected.** The closed form in
  `stirred_tank_baffle_deflection()` was only ever checked at zero freeboard, where it happens to
  agree with the right answer at `qL⁴/8EI`; away from there it understated. At the plate's real
  49 mm of freeboard it was **23 % low**. Rebuilt by integrating the point-load case `Px²(3L−x)/6EI`
  over the loaded span and checked against a numerical double integration of `M/EI`, the 9 mm plate
  in `jar_10L` deflects **1.53 mm** rather than 1.18. That is on the tenth-of-width limit `head()`
  warns at rather than comfortably inside it. The older figures in this section — 8.9 mm at 4 mm
  thick, 1.1 mm at 8 — are stale twice over: by that error and by the load, which went from the
  no-load 0.51 N to 0.77 N at the rated speed when the pitched blade's power number landed.
- **So the plate is 10 mm, and the window is narrower than it looks.** At 9 mm the tip sat right on
  the tenth-of-width limit `head()` warns at, and warned on every render of `jar_10L`. The fix was
  written down as nearly free, because the lock bore does not cut into the width until 12.5 mm — so
  12 looked available. **The bore is not what binds.** First mode goes as `t^1.5`: 15.4 Hz at 9,
  17.6 at 10, 19.8 at 11, 22.0 at 12. Blade passing is four per revolution and sweeps 0–28 Hz on the
  way to the drive's 420 rpm no-load speed, so it crosses the mode at 231 rpm on a 9 mm plate, 264
  on a 10, 297 on an 11 and **330 on a 12 — inside the 320–420 band the reactor actually runs in**.
  Only 12 fires the model's resonance warning, which now asks whether a crossing lands *in* the band
  rather than whether the mode is within 30 % of an excitation at one speed. What separates 10 from
  11 is margin, and `head()` reports it: **10 clears the band by 17.6 %, 11 by only 7.2 %**. With a
  DC motor whose speed is set open-loop, 7 % is not much room for a controller to wander into. 10
  also clears the deflection limit by 15 %, and that is the whole window.
- **What `head()` reports on the 10 mm plate today**: 0.772 N each, **1.300 mm** at the tip with
  0.185 mm of that the joints, first mode **17.6 Hz** — crossed by blade passing at **264 rpm** and
  by the shaft at 1055, against the 320–420 rpm the drive runs.
  The joints take a larger share of a stiffer plate than they did of a thinner one, because the
  dovetail's 4.2 mm neck does not thicken with it. Running clearance is untouched at **−0.28 mm** —
  that is a tolerance stack, not a stiffness one, and it is still open.

### Splitting the plate so it can be printed

- **The plate is the tallest thing in the model and it does not fit on a printer.** Hanging to the
  floor it is 172 mm in `jar_1gal_180`, 275 in `generic` and 280 in `jar_10L`, and the port's own
  flange and lid section add 23 mm on top of that. The part stands on the bed in the port's axis —
  the flange, the o-ring groove and the pins all want that orientation — so the printer's Z is what
  bounds it. It splits into equal pieces joined by a **sliding dovetail**.
- **The cap is 170 mm, and it is a reproducibility choice.** 180 mm machines (Prusa MINI, Bambu
  A1 mini) are the small end of what anyone building this owns, and 10 mm leaves room for a brim.
  `baffle_segment_height_max` is the parameter, and raising it costs less than it looks: at a
  250 mm cap `jar_10L` still needs two pieces, because its part is 303 mm whole. What a bigger
  machine buys is the *short* jar, whose 195 mm part would go on the bed in one. At 170 every
  registered vessel comes out in **two pieces** — 140 mm each in `jar_10L`, standing 163 mm with
  the port — and a 470 mm jar would take three.
- **The slide runs along the plate's width, and that is a load choice.** The swirl pushes on the
  plate's *face*, so with the slide across the width that load bears on the dovetail's flanks and
  the one axis a sliding dovetail leaves free carries nothing but vibration. Sliding across the
  thickness instead would put the working load directly in the free direction. A blind end stops
  the slide and registers the two pieces in one place; the butt faces meet with nothing between
  them, so the plate keeps its length and the 0.1 mm allowance is flank clearance only.
- **What it costs is the neck.** Only the tail crosses the joint plane, so the joint has
  **4.2 mm of the plate's 9**, a tenth of its second moment. One joint at mid-plate adds
  **0.11 mm** to the tip deflection, 7 %, taking `jar_10L` from 1.53 to **1.64 mm** — which is what
  now trips the tenth-of-width warning. The neck is the parameter rather than the tail's depth for
  exactly that reason, and a shallow 10° flare is what buys engagement without eating it.
- **Two things about the joint are not modelled.** The first bending mode `head()` reports is the
  solid plate's; the joints soften it, and by how much is not computed. And a 0.1 mm crevice at the
  joint sits in the culture, in a vessel that is chemically sterilised rather than autoclaved —
  which is a cleaning liability a reviewer would reasonably raise and nothing here answers.
- **What used to cap the depth was an interference of 46 microns.** The plates hang on the port
  circle at r 56.9 mm, and at the widest the lock bore would pass — 19.39 mm — the inner edge fell
  at r 47.204 against an impeller sweeping r 47.25. That overlap, and nothing else, is why the
  plates had to stop above the upper impeller and forfeit the whole lower half of the vessel. The
  width is now derived from the impeller rather than from the bore alone, whichever binds: at a
  2 mm radial clearance the plate is 15.3 mm, it passes the impellers instead of stopping above
  them, and the cap becomes the floor at 280 mm rather than 123.5 mm. The port circle itself is not
  a lever — it already sits as far out as the lid plug allows. The coupling runs the other way too:
  at **D/T ≤ 0.4305** the impeller stops binding and the plate returns to the full 19.39 mm the bore
  allows, and past D/T 0.54 there is no plate left at all and the model refuses to build.
- **The plate has not actually been lengthened yet.** Deflection of a cantilever goes as the fourth
  power of its length, and the plate's inner edge is now 2 mm from a turning impeller, so how much
  of that 280 mm can be used is a stiffness question rather than a geometric one.
- Their being **partial and inboard** is separately uncited: the relevant papers are paywalled and
  unread. Note that these plates span r 49.3–64.6 mm in a 210 mm bore, so the annulus outboard of
  them is 40 mm wide and unobstructed — a consequence of having to pass every part through a 143 mm
  mouth, and a difference from the wall-mounted reference case that no source here quantifies.
