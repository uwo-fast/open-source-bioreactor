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
_P. tricornutum_ and _Porphyridium_ on one rig and concluded that mechanical agitation was not the
direct cause of damage — bubbles rupturing at the culture surface were, with the impeller
implicated only as the thing that generated them. Independently, for mammalian cells, removing the
gas–liquid interface leaves growth and viability unaffected at 100–450 rpm, at 600 rpm in a
fully-filled vessel, and at 1500 rpm for hybridomas.

**Tip speed is not a design criterion.** It does not have the dimensions of either shear rate (s⁻¹)
or shear stress (Pa), a point Nienow makes in 2006 and repeats in 2021. The widely-quoted 1.5 m/s
limit traces to a single measurement on human melanoma cells in 5 % serum, generalised into a
universal rule in a paper that two sentences later reports 6 m/s causing no measurable harm to a
hybridoma line. **No tip-speed limit is asserted anywhere in this model, deliberately.**

**For _Chlorella vulgaris_ the relevant figure is an optimum, not a threshold.** Leupold et al.
measured a peak at **1.26 m/s tip speed (0.45 Pa)** — 4.0 % higher photosynthetic activity and 48 %
higher growth against unstirred — with activity falling back to the unstirred control by **2.03 m/s
(0.9 Pa)** and 7–8 % below it by 5.89 m/s. No lethal limit was found at any speed tested. Chlorella
is a rigid-walled green alga, the most shear-tolerant class.

> **Assumption, stated once and carried everywhere below.** Leupold's apparatus is a Gust microcosm
> — 1.75 L, mixed by a **spinning plate with skirt** 5 cm off the bottom — not a stirred tank with
> an impeller. Their tip speed is that plate's rim speed, and the shear it makes lives in a
> plate-to-wall gap rather than an impeller's discharge jet. **Reading 1.26 and 2.03 m/s as impeller
> tip speeds is this project's transfer, not their result.** It is the only _Chlorella_-specific
> agitation measurement available, so the band below is built on it anyway — but every speed, every
> D/T argument and the motor selection itself inherit that assumption. See `docs/references.md` for
> what the paper actually reports, including that its calibration is direct only to 250 rpm and that
> the quoted Pa figures are the stress the authors call secondary in their own experiment.

---

## 2. This reactor, in the units that matter

Computed on the 94.5 mm impeller in the 10 L jar, with **Np = 1.497 from Medek's correlation** for
the registered 45° four-blade pitched turbine, and x = 16. Mean dissipation is over the **8.22 L**
this build derives from `culture_fill_fraction`, not over the full jar — which holds 9.50 L brim
full. `head()` reports the two registered-drive rows; the others are computed from the same
relations at the speeds the Chlorella band asks for.

| shaft speed                         | tip speed | Re      | ε̄ (W/m³) | ε_max (W/kg) |
| ----------------------------------- | --------- | ------- | -------- | ------------ |
| 255 rpm — Chlorella optimum         | 1.26 m/s  | 37,800  | 105      | 15.4         |
| 320 rpm — registered drive, rated   | 1.58 m/s  | 47,400  | 208      | 30.5         |
| 410 rpm — break-even                | 2.03 m/s  | 60,800  | 436      | 64.2         |
| 420 rpm — registered drive, no-load | 2.08 m/s  | 62,300  | 470      | 69.0         |
| 1154 rpm — 36GP-3530 at full speed  | 5.71 m/s  | 171,100 | 9,738    | 1,432        |

Np comes from this impeller's own geometry by a correlation that states where it is extrapolated,
and it reads **H/T**, so the fill line is part of the power number.

**The vessel is fully turbulent throughout the band.** Every speed above clears both the textbook
Re > 10⁴ threshold and Nienow's stricter 2×10⁴.

**The margin against damage is large.** At the rated 320 rpm the impeller's peak dissipation is
~3.0×10⁴ W/m³ against bubble rupture at 10⁷–10⁹ W/m³ and a CHO lethal range of 10⁶–10⁸ W/m³ — two
to five orders of magnitude. Agitation is not what threatens this culture.

**Aeration dominates the power budget too.** The one peer-reviewed worked example for a microalgal
stirred tank puts aeration at 29.4–49.1 W/m³ against stirring at 0.65–1.30 W/m³.

### The operating point

On the 94.5 mm impeller the band worth aiming at is narrow:

| target                            | tip speed | shaft speed |
| --------------------------------- | --------- | ----------- |
| Chlorella growth optimum          | 1.26 m/s  | **255 rpm** |
| break-even, stirring stops paying | 2.03 m/s  | **410 rpm** |

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

Torque is not what limits the choice. The impeller pair draws under 0.102 N·m at rated and under
0.176 N·m at no-load against a 0.490 N·m rating — **21 to 36 % of it** — so the shaft runs nearer
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
at 0.4879 with the impeller exactly filling the neck; 0.45 leaves 10.64 mm to pass it through. Every
other registered jar tolerates 0.64 to 0.87.

The model asserts that what the impeller sweeps can pass the vessel's opening.

### The helicoid, and why it was abandoned

The blade this project first drew, `impeller_twisted_paddle_4`, is a constant-pitch helicoid:
`linear_extrude(twist=)` is a pitch specifier, so the blade angle β from the plane of rotation
varies with radius, `tan β = P / (2πr)`, running 83° at the hub to 53° at the tip at 55° of twist.
That is steeper than 45° everywhere — a twisted paddle biased toward radial pumping, not the axial
impeller the D/T guidance is written about — and no correlation reaches it: Medek's envelope stops
at 60°, and the twist papers (Patwardhan & Joshi 1999 §3.4.3, Kumaresan & Joshi 2006 §3.1.3.3)
tested at most 20° of twist where this is 30° on their definition. Both find twist lowers Po, so
the 0.99 borrowed from an untwisted folded blade was an over-estimate for the helicoid. Its blade
height has no source either.

The hub was grown from 7.5 to 10 mm radius (0.159 to 0.212 D) to carry the set screws; that is
within the 0.2–0.33 D hubs carry in practice. The alternative, a local boss leaving the blade
alone, prints with an overhang and has to be indexed against the blades; the joint was the binding
problem, and a slipping impeller costs the whole run.

The row stays registered and `head()` still draws it. A bench measurement, `Po = P/(ρN³D⁵)` from
shaft power at three or four speeds in water, would give it a power number; see `TODO.md`.

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
`v_tip` ∝ D^(−2/3) while pumping Q ∝ D^(4/3) — a larger impeller runs slower at the tip _and_ pumps
more. Peak-to-mean dissipation scales as (T/D)³, so moving D/T from 0.33 to 0.50 cuts it by ~3.5×.

This is why shear-sensitive culture wants a large impeller turning slowly, and it runs opposite to
the intuition that gentler means smaller and faster.

**One caution:** "low shear" impellers are not reliably gentle. A low power number can coexist with
a _higher_ peak dissipation than a Rushton turbine. Size the impeller; do not trust the label.

---

## 5. Agitation mode per vessel

Not every registered jar can be agitated the same way, and the reasons are geometric rather than
preferential. Three of the five swept vessels carry no baffles, and **they are unbaffled for two
different reasons** — a distinction `docs/ports-layout.md` did not draw, because it attributes all of
it to the 98 mm mouth floor.

| vessel               | mouth | bore  | mouth/T   | baffles | why not                                   |
| -------------------- | ----- | ----- | --------- | ------- | ----------------------------------------- |
| `jar_1gal_180x197`   | 148   | 170   | 0.871     | 4       | —                                         |
| `jar_10L_220x305`    | 142.2 | 210   | 0.677     | 4       | —                                         |
| `jar_6p5gal_305x470` | 137   | 280.8 | **0.488** | 0       | the port circle falls inside the impeller |
| `jar_1gal_155x251`   | 95.8  | 149.3 | 0.642     | 0       | mouth below the flange floor              |
| `jar_1p5L_109x215`   | 87.5  | 101.2 | 0.864     | 0       | mouth below the flange floor              |

**The absolute floor**, which the ports document already has: below about 98 mm no baffle fits beside
two Ø16 Atlas probes at any port count. That is `jar_1p5L` and `jar_1gal_155`. Note that `jar_1p5L`
has a _generous_ mouth for its bore — 0.864 — so its problem is absolute size, not proportion.

**The ratio bound**, which it did not: `jar_6p5gal`'s mouth is small relative to its BORE, so the
port circle its lid can offer sits inside the impeller's own sweep. Measured by adding a
three-baffle set and rendering: the flanges fit — 7, 8 and 9-port sets all clear at a 137 mm mouth,
and Oldshue sanctions three baffles at equal projected area — and the vessel then failed on
something else, _"a 126.36 mm impeller leaves no room for a baffle on a 107 mm port circle"_. No port
count reaches it; D/T would have to fall to about 0.20 against a 0.3 floor. **This jar cannot carry a
lid-hung baffle at all**, and the port table is not what stops it.

### The three modes

**Baffled stirred** — `jar_10L`, `jar_1gal_180`. The reference configuration; nothing here changes it.

**Unbaffled eccentric stirred** — `jar_6p5gal`. It is the family's worst case today: the largest
vessel, unbaffled and centred, which Montante measured at flow number **0.25, 65 % below the same
impeller baffled**. It cannot be baffled, but it _builds_, it carries a top-entry drive, and it has
room to offset one. `head()` prices that room: **9.8 mm today, e/T 0.035, worth 15.8 %** of the
centred blend time by Karcz; about **25 mm** with the mount at the Ø36 floor its own gearbox
faceplate allows, e/T 0.090, **worth 31 %**. This is a mount change on a jar that already works, not a new mode of
agitation.

What rides with it, and none of it is small: six of the eight Karcz departures fire here and Reynolds
is one of them; Galletti reports macro-mixing in an eccentric unbaffled vessel is UNSTEADY, the
vortex oscillating slowly rather than sitting; Cabaret reports power RISING with eccentricity; and
Hall's measured `e = 0.2 T` stays out of reach at 0.090.

**Gas-driven** — `jar_1p5L`, `jar_1gal_155`. For these two the eccentric-versus-centred question does
not arise, because neither can carry a shaft to centre or offset. Four things point the same way:

- **Both build failures are assertions about the top-entry drivetrain.** The mount overlaps the port
  flanges by 12.95 mm on `jar_1p5L`; the pH probe runs 6.29 mm through the lower impeller on
  `jar_1gal_155`. Neither assert would exist in a configuration without that drivetrain, and the
  model has no way to express one — a modelling gap, not a physical result.
- **`jar_1p5L`'s impeller is already negated at the design aeration rate.** Oldshue's 8× rule caps
  axial pumping at **0.341 vvm** where the design is 0.5. It is the only vessel in the family that
  floods; the others hold 1.7× to 3.2× headroom. At intended conditions it is a bubble column with a
  spinning obstruction in it.
- **Measured, on this organism, at this scale.** Uyar 2024 ran _C. sorokiniana_ in 2 L
  side-illuminated columns and moved the stirrer from 100 to 200 rpm for **15 %** on kLa and **18 %**
  on mixing time, while the sparger moved kLa **five-fold**. Productivity ranked bubble column 0.097,
  airlift 0.072, stirred tank 0.064 gdw/L·day. The impeller is not what makes a vessel of this size
  work.
- **Swirl is specifically wrong for a side-illuminated column.** Molina Grima: average irradiance
  "considers only the total length of the dark and the light periods, not the frequency of switch".
  Solid-body rotation preserves a cell's radius, so it is close to the worst available flow here —
  the failure is not slow blending, it is that the light/dark cycle never happens.

**An AIRLIFT rather than a plain bubble column**, and the reason is this project's own objection to
leaning on aeration: aeration that mixes as a side effect is an uncontrolled variable. A draft tube
gives a riser/downcomer ratio, a circulation velocity and a circulation time — quantities Uyar
measured at 10.9-12.1 cm/s and 6.1-6.8 s, and which a bubble column does not have at all; that paper
computes circulation time "only for ALR which has a circulation loop, it is not applicable to BCR nor
STR". Uyar's bubble column did out-produce its airlift, but the authors attribute that to the
sparger — microporous against a single 0.8 mm orifice — so it is not evidence that a column beats an
airlift at equal sparging.

### What outranks all three

**The sparger, and it applies family-wide.** The five-fold kLa spread Uyar measured came entirely
from bubble size: 1.56 mm from a microporous sparger against 4.18-4.25 mm from orifice spargers. This
ring is 8 × 3 mm holes — coarser than the 0.8 mm orifice that gave them 4 mm bubbles. Whatever mode a
jar runs, a finer sparger is worth more than the choice between modes. It is a trade rather than an
oversight: the hole size carries a settled anti-fouling reason, recorded in `TODO.md`. It has not
been priced against the mass transfer it costs, and it should be.

---

## 6. The design basis as it stands

Every figure below is what `head()` reports for `jar_10L_220x305` at the reference fill; the
transcript is `tests/echo/head__jar_10L_220x305.txt`. What was believed before and got wrong is in
`docs/decisions.md`.

### Sparger

Two spargers share the riser from the `air_in` port, and a build names one (`sparger_name`): the
**arm** is the default under the shaft and magnetic drives, and the **ring** is kept for the
airlift mode that does not exist yet. What `head()` reports for each follows.

#### The arm

- **One straight run under the lower impeller, holes down.** The ring's feed without the ring:
  the same socket and elbow, then a run turned inward from the port circle at r 56.5 to end 5 mm
  short of the shaft at r 9, 66.95 mm off the floor — 10 mm under the lower impeller's blades, so
  the bubbles rise into it. That is where the stirred-tank literature puts a sparger; Birch &
  Ahmed's argument for a ring between the impellers stays with the ring below.
- **Three 3 mm holes, the same size as the ring's for the same anti-fouling reason**, at 3.8 hole
  diameters along the 33.9 mm of bore past the elbow, 3.23 m/s each at 0.5 vvm — inside Barbosa's
  0.4–5.4 m/s.
  Bubbles are 5.10 mm at formation, as the ring's; nothing about the arm changes what a 3 mm hole
  makes.
- **The bore is the same departure**: 5.45 m/s in the feed run, open area ratio 1.68, and
  `head()` names both.
- **The gas supply has to beat 1783 Pa before anything bubbles**: 172.3 mm of culture over the arm
  plus 96 Pa of capillary — 680 Pa more than the ring asked, since the arm sits 69 mm lower.
- **The baffles keep the ring's width, 10.35 mm, under the arm too**, so one set of plates prints
  once. The arm would let them go to 14.5, and at 2 mm nominal to the impeller against 2.28 mm of
  coupling lean that plate can touch the blades; widening them is its own decision.

#### The ring

- **A tube ring at 1.405 D, placed by the mouth.** Birch & Ahmed 1997 tested a ring at 1.4 D — the
  radius at which the annulus outboard of the impeller encloses the volume it sweeps — and found
  better power draw and delayed flooding; Rewatkar & Joshi 1993 recommend a large ring outright.
  So the ring goes as far out as the mouth allows, 132.8 mm on this jar, with 1.25 mm to the
  baffles inboard and 1.25 mm to the mouth on the way in. It is a 6.4 mm octagonal tube on a 4 mm
  bore, split opposite the feed and plugged with two screws so a brush passes through it.
- **It sits between the impellers because the pair converges.** Birch & Ahmed place a ring above an
  up-pumping blade and below a down-pumping one; at `head_shaft_rotation = 1` the lower pumps up
  and the upper down, so one ring at 136.3 mm off the floor — 51.25 mm above the lower impeller and
  43.25 mm below the upper — sits in both discharges. Reverse the rotation and it would need two,
  which `head()` warns on.
- **Eight 3 mm holes, and their geometry is for spacing and against fouling, not for even flow.**
  Rewatkar & Joshi: _"hole size and number of holes have negligible effect when the sparger is
  located near the impeller."_ Even flow is unreachable anyway: 96 Pa of capillary pressure to
  launch a bubble against 2.4 Pa to push gas through a hole, so a fixed tolerance hurts small holes
  most. At 0.5 vvm the holes run 1.21 m/s, inside the 0.4–5.4 m/s Barbosa 2003 actually ran; he
  establishes no critical velocity.
- **What it cannot do is make small bubbles.** Diameter at formation goes as the cube root of hole
  size — 5.10 mm here — so the 1.56 mm of a microporous sparger would want an 86 µm orifice, which
  is why those are sintered. Bubble size is the strongest lever on kLa this design does not have;
  it is the open item.
- **The bore is a departure.** The feed run carries the whole flow at 5.45 m/s with an open area
  ratio of 4.5, and each ring 2.25, so the holes compete with their supply. `head()` names both;
  the fix is a wider riser, which is one designation and a cascade of fits (`TODO.md`).
- **The risers are structure.** Nothing else in the vessel touches the ring, so the five 4 × 0.5 mm
  316 tubes that drop from the tube ports — one feeding, four blind — are what hold it: 1.73 N/mm
  a support, 0.58 mm of sway per newton against 1.25 mm to the baffles. The feed's socket is the
  ring's own tube standing up; the supports' are round, which is the only thing that tells them
  apart at the bottom of a jar.
- **The gas supply has to beat 1104 Pa before anything bubbles**: 103.0 mm of culture over the
  ring plus 96 Pa of capillary. The line's own losses are an order of magnitude more, and the
  sterile filter's slope is extrapolated (`TODO.md`).

### Impeller

- **A 45° four-blade pitched turbine, chosen for what can be said about it.** Medek's correlation
  (Fořt et al. 2002) gives Po 1.497 and a flow number 0.892 from the geometry and names the
  conditions this vessel breaks — T/D and H/T. The hand-drawn helicoid it replaced is
  uncorrelatable (section 3); the switch raised every power, dissipation and torque figure about
  50 %, which is a borrowed number being replaced by a correlated one, not the impeller getting
  worse.
- **Axial over radial, deliberately.** A Rushton disperses gas better — Oldshue's 3× against 8–10×
  of the gas stream's power — but a photobioreactor's criterion is Molina Grima's frequency of
  switch between light and dark, which is pumping. On circulation bought per watt, `N_Q/Po`, the
  axial blade wins by about 4×, and the gas criterion does not bind: at 420 rpm the pair holds its
  flow pattern up to 1.54 vvm against a 0.5 vvm design point.
- **Clearance is 0.9 D, from the source the power number comes from.** Fořt tested pitched blades at
  C/D 0.5 and 1.0 and found hydraulic efficiency higher at 1.0, tying low clearances to solids
  suspension and high ones to blending, which is this reactor's duty. Medek's correlation
  reproduces it, since `Po ∝ (C/D)^−0.165` and `N_Q ∝ (C/D)^0.254`:

  | C/D     | Po        | N_Q       | N_Q/Po    | vs 0.6      |
  | ------- | --------- | --------- | --------- | ----------- |
  | 0.6     | 1.602     | 0.806     | 0.503     | —           |
  | 0.8     | 1.528     | 0.867     | 0.568     | +12.8 %     |
  | **0.9** | **1.498** | **0.893** | **0.596** | **+18.5 %** |
  | 1.0     | 1.473     | 0.918     | 0.623     | +23.9 %     |

  Not 1.0, which is the correlation's own C/D limit and drops coverage over the upper impeller
  below half a diameter. The centreline sits 85.05 mm off the floor (C/T 0.405), leaving 77.0 mm
  under the lower impeller and 51.6 mm — **0.546 D** — of culture over the upper; coverage binds at
  0.946 D. `head()` asserts the shaft still reaches the lower impeller's bore and the upper stays
  submerged, which on this jar spans roughly 0.19 to 1.45 D.

- **Oldshue's 1–2 D does not apply, and that is a class distinction.** His passage is about _"these
  fluidfoil impellers"_, and both halves of it — the allowance and the short-circuiting caveat —
  are fluidfoil statements. On this vessel they could not both be met anyway: the band needs
  C ≥ 94.5 mm and half a diameter of coverage needs C ≤ 89.4 mm, because the column is short for
  two impellers — 2.48 impeller diameters of liquid where the spacing band allows `0.24 < n < 1.48`.
  That band has no primary (Fitschen relays it from Davis, whose sources do not carry it), so
  `head()` reports it and never asserts. The pair stays: the ring sits in its gap and the reference
  build exists (`TODO.md`).
- **The 0.5 D coverage floor is reasoned, not cited.** Oldshue names the concern and gives no
  number; it is where a down-pumping impeller starts drawing its own discharge back off the surface.
  `head()` warns rather than asserts.
- **The uncited C/T convention supported 0.6 D and does not reach 0.9 D.** The quarter-to-third of
  tank diameter usual for an axial impeller maps to C/D 0.556–0.741 in this bore; 0.9 D is above it
  and rests on Fořt alone. No source held here states the convention, so no band function encodes
  it.
- **What the drive does to the culture**, at the rated 320 rpm: Re 47,400, tip 1.58 m/s, 1.71 W
  into 8.22 L = 208 W/m³ mean and 30.5 W/kg peak, the pair under 0.10 N·m of a 0.49 N·m rating;
  blend to 95 % in 4.6 s; kLa 0.0098 s⁻¹ coalescing. Both transfer correlations are extrapolated —
  van't Riet is fitted over 500–10,000 W/m³ and Ruszkowski over 0.01–10 m³ — and `head()` says so.
- **No energy dissipation rate limit exists for any microalga.** The parameter the physics says
  governs has no citable number for these organisms.
- **Speed feedback is specified but not wired.** The drive's encoder resolves 0.89 rpm over 100 ms,
  672 counts per output turn, and nothing reads it yet: tip speed and Re are computed from a
  commanded speed.

### Baffles

- **Four at 90°, which is Oldshue's reference count, and the vessel is still under-baffled.** His
  reference is four plates at T/12 running the liquid depth; these hang from the lid to the floor
  limit, 10.35 × 280 mm with 229 mm submerged, and reach **0.579** of the reference projected area.
  Both levers are spent: depth is at the floor, and the next count that spaces equally on twelve
  ports is six, which would give 0.868. Under-baffling lets the vessel swirl rather than mix.
- **The width is capped by the sparge ring, not the bore or the impeller.** The room outside a
  baffle does not grow with the mouth, and a ring wide enough to clear it does not exist, so the
  plate yields: 10.35 mm where the lock bore would pass 17 and the impeller 14.5. Running clearance
  to the impeller is +1.80 mm — 4.08 nominal less 2.28 of lean the coupling's 0.2 mm of play
  allows — and closed.
- **What sized the plate was dynamics, not strength and not collision.** Root stress is about 1 % of
  yield, and the plate bends tangentially while the impeller sweeps a circle, so deflection never
  closes the radial gap. What binds is the first bending mode, which falls as 1/L², and the blade
  passing that sweeps 0–28 Hz on the way to 420 rpm. Stiffness goes as t³ and the mode as t^1.5,
  so thickening raises the crossing toward the 320–420 rpm band the drive runs in: on the 15.3 mm
  plate the crossing sat at 231 / 264 / 297 / 330 rpm for 9 / 10 / 11 / 12 mm, and 12 lands in the
  band. The plate is **10 mm**. On today's narrower plate the mode is 19.2 Hz, crossed by blade
  passing at 287 rpm and by the shaft at 1150, clearing the band by 10 %; the tip deflects
  1.94 mm under 0.78 N, which is over the tenth-of-width limit `head()` warns on. Thicker walks the
  crossing in, so the plate stays at 10 and the warning stands until the area question is settled.
- **The load is reasoned from two directions and neither is cited.** Each plate reacts its share of
  the impeller's torque, `T / (n · r)`; the dynamic pressure of a tangential stream at 0.3 of tip
  speed agrees within 26 %. No source held here loads a baffle. Added mass is not optional in the
  mode: the entrained water is over twice the PETG's own, and leaving it out overstates the
  frequency by about 80 %.
- **Partial and inboard is uncited.** The plates span r 51.3–61.7 mm in a 210 mm bore, so the
  annulus outboard of them is 43 mm wide and unobstructed — a consequence of passing every part
  through a 142.2 mm mouth. Inboard baffles are characterised in the literature, not recommended;
  the relevant papers are paywalled and unread (`docs/references.md`).

- **The plate prints in two dovetailed pieces**, and the joint is in the deflection above: 4.2 mm
  of the plate's 10 crosses the joint plane, 0.074 of its second moment, 0.28 mm of the 1.94 mm at
  the tip. Why it splits where it does, which way the slide runs and what the joint leaves
  unmodelled is in `docs/build.md`.
