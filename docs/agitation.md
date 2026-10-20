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

Computed on the 70 mm Rushton turbine in the 10 L jar, with **Np = 4.17 ± 0.14 measured** (Kaiser 2016) and x = 12. Mean dissipation is over the **8.17 L** this build derives from
`culture_fill_fraction`, not over the full jar — which holds 9.45 L brim full — and it is one
impeller's power, the floor for the pair (below). `head()` reports the two registered-drive rows;
the others are computed from the same relations at the speeds the Chlorella band asks for.

| shaft speed                         | tip speed | Re     | ε̄ (W/m³) | ε_max (W/kg) |
| ----------------------------------- | --------- | ------ | -------- | ------------ |
| 320 rpm — registered drive, rated   | 1.17 m/s  | 26,000 | 130      | 27.1         |
| 344 rpm — Chlorella optimum         | 1.26 m/s  | 28,000 | 162      | 33.6         |
| 420 rpm — registered drive, no-load | 1.54 m/s  | 34,200 | 294      | 61.2         |
| 554 rpm — break-even                | 2.03 m/s  | 45,100 | 675      | 141          |

**The pair draws more than the table.** McCabe, Smith & Harriott (1993 p. 253) put two turbines at
least one impeller diameter apart at about 1.9× one; these are exactly one apart, so the pair's
mean at the rated speed is nearer 250 W/m³ than 130. `head()` reports one impeller's power as the
floor and both summed as the torque's ceiling, and does not pick a factor between them.

**The power number is Kaiser's, not the textbook's.** McCabe's Table 9.3 gives 5.75 for the
standard disc turbine, from tanks with four baffles at T/10. Kaiser measured 4.17 at laboratory
scale. This vessel has neither: three plates at 0.71 of the four-at-T/12 area. The model keeps the
measured figure, and the difference is 38 % on every power and torque figure: at 5.75 the rated
speed draws 1.46 W, 179 W/m³, and the pair stays under 0.087 N·m of the 0.490 rating, so nothing
about the drive turns on which is right. A bench measurement of the printed part settles it
(`TODO.md`).

**The vessel is fully turbulent throughout the band.** Every speed above clears both the textbook
Re > 10⁴ threshold and Nienow's stricter 2×10⁴.

**The margin against damage is large.** At the rated 320 rpm the impeller's peak dissipation is
~2.7×10⁴ W/m³ against bubble rupture at 10⁷–10⁹ W/m³ and a CHO lethal range of 10⁶–10⁸ W/m³ — two
to five orders of magnitude. Agitation is not what threatens this culture.

**Aeration dominates the power budget too.** The one peer-reviewed worked example for a microalgal
stirred tank puts aeration at 29.4–49.1 W/m³ against stirring at 0.65–1.30 W/m³.

### The operating point

On the 70 mm impeller the band worth aiming at is wider than the drive:

| target                            | tip speed | shaft speed |
| --------------------------------- | --------- | ----------- |
| Chlorella growth optimum          | 1.26 m/s  | **344 rpm** |
| break-even, stirring stops paying | 2.03 m/s  | **554 rpm** |

**The registered drive is the 36PG-555PM-14-EN**, 14:1, rated 320 rpm and no-load 420 rpm — 1.17 to
1.54 m/s. It was chosen on the 94.5 mm pitched pair this build ran before, where that span was
1.58 to 2.08 m/s and it was the only motor examined that reached the break-even end of the band. On
the standard turbine it brackets the optimum and stops short of break-even, so the
optimum-against-break-even comparison now wants either a faster motor or the larger impeller back
(`docs/baseline.md`).

It was taken over a 19:1 sibling whose entire rated-to-no-load span, 265–385 rpm, sat inside the
pitched pair's band. That containment is a workaround for having no speed feedback: with nothing measuring the
shaft, where it settles between rated and no-load is set by load, so both ends have to be safe.
**This motor carries a magnetic encoder instead** — 2 channels, 12 PPR at the motor shaft, which
past the 14:1 is 672 quadrature counts per output revolution and resolves about 0.9 rpm over a
100 ms window, against a band 210 rpm wide. Commanding a speed and measuring it beats choosing a
motor that cannot miss.

Torque is not what limits the choice. The impeller pair draws under 0.063 N·m at rated and under
0.109 N·m at no-load against a 0.490 N·m rating — **13 to 22 % of it** — so the shaft runs nearer
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

### The standard turbine

Two six-blade Rushton turbines in the standard turbine's proportions: D = T/3, blades D/5 high and
D/4 long (McCabe, Smith & Harriott 1993 pp. 242-243, Fig. 9.7, after Rushton, Costich & Everett
1950), on a 3D/4 disc (Middleton & Ramshaw, US 5198156; McCabe gives no disc diameter). It is the
configuration the stirred-tank literature compares against, which is why the reference build runs
it; `docs/baseline.md` says which settings are held at a standard and which later work moves.

A Rushton's flat blades have no hand, so both positions take the same part, and it prints as two
halves (`docs/build.md`).

### Diameter

`impeller_bore_ratio` is `undef` and takes the Rushton row's 1/3: 70 mm in `jar_10L`'s 210 mm bore.
It is measured against the vessel's **wetted bore** — the internal diameter, not the outside of the
glass. This matters: multiplying the outer diameter lets the real ratio drift with wall thickness,
which across this project's vessel registry meant 0.468 to 0.489 for one nominal 0.45.

1/3 is near the bottom of the 0.3–0.5 band the model echoes. For solids suspension McCabe gives
D/T 1/3 as often recommended, "though some prefer" 0.4 (p. 268), and a larger impeller disperses
more gas at a given speed (p. 272). Section 4 is the case for larger; the pitched pair below ran at
0.45.

**`jar_6p5gal_305x470` is the vessel the mouth binds.** Its 137 mm mouth on a 280.8 mm bore caps
the ratio at 0.4879 with the impeller exactly filling the neck. At 1/3 the impeller is 93.6 mm and
passes with 43.4 mm to spare; 0.45 left 10.64 mm. The model asserts that what the impeller sweeps
can pass the vessel's opening.

### Clearance and spacing

**The lower impeller is T/3 off the floor**, 70 mm on `jar_10L` and exactly 1 D: McCabe's E/Dt of
1/3 for one turbine, and his "about one impeller diameter above the bottom" for the lowest of
several (p. 241), which at D = T/3 is the same height.

**The upper is a further T/3 up**, 1 D apart. That is the least spacing McCabe gives for a pair
whose power nearly doubles (p. 253), and it is the equal thirds of Rutherford et al. 1996's merging
flow at H = T, as Li et al. 2007 Fig. 1 relays it. Rutherford's alternatives are parallel flow
(lower T/4, the pair T/2 apart) and diverging flow (lower 0.15 T); the thresholds between them are
not claimed here.

On `jar_10L` that leaves 63 mm under the lower impeller's blades, 56 mm between the two impellers'
blades, and 92.5 mm — **1.32 D** — of culture over the upper.

**Two impellers, at H/T 1.09.** McCabe keeps one turbine to a liquid depth equal to or somewhat over
T and adds more for deeper (p. 241), so this column sits at the edge of needing a second. Two is on
the advice of the microalgae researcher advising the project.

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

### The pitched pair it replaced

Until the Rushton pair, the reference build ran two 45° four-blade pitched turbines,
`impeller_pbt_45_4`, at D/T 0.45, the lower 0.9 D off the floor and the pair 1 D apart. That layout
is the row's own `tank` field, so it is one `head_impeller_lower_type` / `head_impeller_upper_type`
setting away, and a Rushton under a pitched blade is long-term work in `TODO.md`. What was worked
out for it stays true of it:

- **Po and flow number are correlated.** Medek's correlation (Fořt et al. 2002) gives them from the
  geometry and names the conditions a vessel breaks — on `jar_10L`, T/D and H/T. The hand-drawn
  helicoid before it is uncorrelatable (above).
- **Diameter.** 0.45 sits mid-band on every source for an axial impeller: 0.3–0.5 generally,
  0.4–0.5 in cell culture, 0.44–0.46 as a manufacturer's "most preferred". Above roughly 0.5 an
  axial impeller loses its strong axial motion.
- **Clearance 0.9 D, after Fořt.** He tested pitched blades at C/D 0.5 and 1.0 and found hydraulic
  efficiency higher at 1.0, tying low clearances to solids suspension and high ones to blending.
  Medek's correlation reproduces it, since `Po ∝ (C/D)^−0.165` and `N_Q ∝ (C/D)^0.254`:

  | C/D     | Po        | N_Q       | N_Q/Po    | vs 0.6      |
  | ------- | --------- | --------- | --------- | ----------- |
  | 0.6     | 1.596     | 0.800     | 0.502     | —           |
  | 0.8     | 1.522     | 0.861     | 0.566     | +12.8 %     |
  | **0.9** | **1.492** | **0.887** | **0.594** | **+18.5 %** |
  | 1.0     | 1.467     | 0.911     | 0.621     | +23.9 %     |

  Not 1.0, which is the correlation's own C/D limit and drops coverage over the upper impeller
  below half a diameter on `jar_10L`. The quarter-to-third of tank diameter usual for an axial
  impeller maps to C/D 0.556–0.741 in that bore; no source held here states it, so no band
  function encodes it.

- **Oldshue's 1–2 D spacing is a fluidfoil statement.** His passage is about _"these fluidfoil
  impellers"_, both the allowance and the short-circuiting caveat. The band `head()` echoes has no
  primary (Fitschen relays it from Davis, whose sources do not carry it), so it is reported and
  never asserted. At 1 D the pitched pair sits below the ~1.55 D at which pitched-blade pairs act
  independently, and inside the 0.33–0.5 T Nienow specifies for a stacked pair.
- **The 0.5 D coverage floor is reasoned, not cited.** Oldshue names the concern and gives no
  number; it is where a down-pumping impeller starts drawing its own discharge back off the surface.
  `head()` warns rather than asserts.
- **Blade count.** Measured on otherwise identical folded-blade axial impellers, Po runs 0.79 /
  0.99 / 1.34 for 3 / 4 / 6 blades, so six costs about 35 % more power than four at the same speed
  and diameter.
- **The two are mirror images**, not the same part turned over: pumping direction follows blade
  handedness and no rotation changes it.

**What the switch to the Rushton pair corrected** is in `docs/decisions.md`: the pitched pair was
argued for on 4× the circulation per watt, which at equal power and diameter is about 1.8×, and on
a gas criterion that did not bind, which it did at the Chlorella optimum.

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

**The reference build runs at D/T 1/3 anyway.** The case above is for the knob, not the baseline:
the first paper's results have to compare with the literature, so the build holds the standard
turbine and a larger impeller is later work (`docs/baseline.md`). At equal power and diameter a
Rushton is the gentler of the two blades, about 0.56× a pitched blade's peak, since `ε_max` goes as
`x · Po^(−1/4)` (Grenville 2017's x and Po, Table 1).

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
| `jar_1p5L_112x215`   | 88.4  | 103.5 | 0.854     | 0       | mouth below the flange floor              |

**The absolute floor**, which the ports document already has: below about 98 mm no baffle fits beside
two Ø16 Atlas probes at any port count. That is `jar_1p5L` and `jar_1gal_155`. Note that `jar_1p5L`
has a _generous_ mouth for its bore — 0.854 — so its problem is absolute size, not proportion.

**The ratio bound**, which it did not: `jar_6p5gal`'s mouth is small relative to its BORE, so the
port circle its lid can offer sits inside the impeller's own sweep. Measured by adding a
three-baffle set and rendering: the flanges fit — 7, 8 and 9-port sets all clear at a 137 mm mouth,
and Oldshue sanctions three baffles at equal projected area — and the vessel then failed on
something else, _"a 126.36 mm impeller leaves no room for a baffle on a 107 mm port circle"_. No port
count reaches it; D/T would have to fall to about 0.20 against a 0.3 floor. **At D/T 0.45 this jar
could not carry a lid-hung baffle at all**, and the port table is not what stopped it. The
measurement was taken on the pitched pair; by the same 0.20 bound the Rushton's 1/3 does not reach
either, though the set has not been rendered again at it.

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
  flanges by 12.5 mm on `jar_1p5L`; the pH probe runs 6.29 mm through the lower impeller on
  `jar_1gal_155`. Neither assert exists in a configuration without that drivetrain, which the model
  expresses as `drive_name = "none"`; both jars are registered as the airlift built on it.
- **`jar_1p5L`'s impeller is already negated at the design aeration rate.** Even a Rushton, which
  needs only 3× the gas stream's power to hold its pattern against Oldshue's 8× for an axial blade,
  holds 0.5 vvm there only above 399 rpm, and the drive is rated at 320, where the ceiling is
  **0.258 vvm**. It is the only vessel in the family that floods at rated speed; the others hold
  0.5 vvm down to 227–297 rpm. At intended conditions it is a bubble column with a spinning
  obstruction in it.
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

**Nor is the airlift expected to out-grow the column.** Sánchez Mirón 2000 ran a bubble column, a
split cylinder and a draft-tube airlift side by side on one alga at one power input and found _"no
significant difference in culture performance"_. What the draft tube buys is the loop — a cell
goes up the core and down the lit annulus — not biomass.

`drive_name = "airlift"` is that mode: the no-drive build plus a draft tube standing on the floor
round everything that hangs from the lid, sparged inside by the ring, which also centres it. On
`jar_1p5L` the tube is 84.7 mm across with A_d/A_r 0.54; on `jar_1gal_155`, 93 mm and 1.72 — the
narrower mouth caps the tube while the bore sets the annulus. The gaps under and over it give the
turn the downcomer's own area, inside Chisti & Moo-Young's 1.65 cap. Chisti's circulation model is
not run: its data start at 1.36 m tall and these loops are under 0.2 m. The DO probe hangs straight
here, because its lean is for the shaft's shadow and inside the riser there is none.

### What outranks all three

**The sparger, and it applies family-wide.** The five-fold kLa spread Uyar measured came entirely
from bubble size: 1.56 mm from a microporous sparger against 4.18-4.25 mm from orifice spargers. This
ring is 8 × 3 mm holes — coarser than the 0.8 mm orifice that gave them 4 mm bubbles. Whatever mode a
jar runs, a finer sparger is worth more than the choice between modes. It is a trade rather than an
oversight: the hole size carries a settled anti-fouling reason, recorded in `TODO.md`. It has not
been priced against the mass transfer it costs, and it should be. Photos of past cultures show
almost no buildup on the sparger, or on anything else that deep. It collects higher in the culture,
in the headspace and on the lid.

---

## 6. The design basis as it stands

Every figure below is what `head()` reports for `jar_10L_220x305` at the reference fill; the
transcript is `tests/echo/head__jar_10L_220x305.txt`. What was believed before and got wrong is in
`docs/decisions.md`.

### Sparger

Three spargers share the riser from the `air_in` port, and a build names one (`sparger_name`): the
**arm** is the default under the shaft and magnetic drives, and the **ring** under no drive and
the airlift; the **loop** is chosen, never defaulted. What `head()` reports for each follows; the
ring's and the loop's figures are `jar_10L` builds with `sparger_name` set, which no transcript
holds.

#### The arm

- **One straight run under the lower impeller, holes down.** The ring's feed without the ring:
  the same socket and elbow, then a run turned inward from the port circle at r 56.5 to end 5 mm
  short of the shaft at r 9, 53 mm off the floor — 10 mm under the lower impeller's blades, so
  the bubbles rise into it. That is where the stirred-tank literature puts a sparger; Birch &
  Ahmed's argument for a ring between the impellers stays with the ring below.
- **Three 3 mm holes, the same size as the ring's for the same anti-fouling reason**, at 3.5 hole
  diameters along the 31.9 mm of bore between the elbow and the end plug, 3.21 m/s each at
  0.5 vvm — inside Barbosa's 0.4–5.4 m/s.
  Bubbles are 5.10 mm at formation, as the ring's; nothing about the arm changes what a 3 mm hole
  makes.
- **The bore is the same departure**: 5.42 m/s in the feed run, open area ratio 1.6875, and
  `head()` names both.
- **The gas supply has to beat 1922 Pa before anything bubbles**: 186.5 mm of culture over the arm
  plus 96 Pa of capillary — 509 Pa more than the ring asks, since the arm sits 52 mm lower.
- **The arm gives the baffles back the width the ring took.** It runs in between two plates rather
  than outboard of them, so the ring's bound goes with the ring: the plates widen from 10.35 to
  17.09 mm, where the lock bore stops them (below).

#### The loop

- **The arm's riser, socket and height, hooked round into a C about the shaft**, so the gas rises
  into the lower impeller all the way round rather than on one side of it. It is the pigtail
  sparger under a turbine, one tube with no tee: the elbow turns inward from the port circle at
  r 56.5, a horizontal bend of the elbow's radius hooks it onto the curl tangent from outside, and
  the C runs 300° round from there, 53 mm off the floor, 10 mm under the lower impeller's blades,
  holes down, to a plugged end.
- **75.95 mm across, 1.09 D, and the baffles place it.** Birch & Ahmed's 1.4 D would be 99 mm,
  but at this height the loop sits among the plates, which come off the lid first: it stops
  1.25 mm inside their inner edge after the 2.63 mm they can lean at its height and the 2.63 mm
  its own riser can, by the same coupling rule. 1.09 D is inside the 1–2 D band. The mouth and
  the shaft are far off, 29.7 and 30.5 mm. The hook swings off the riser's bearing toward the next
  plate, outside the C, and is measured against each plate in plan: 3.15 mm to the nearest once
  both have leaned.
- **The hook has to start where the elbow ends,** a bend inside the riser, and meet the C from
  outside, which costs about another bend: the C can be no more than
  `sparge_loop_largest()`, 38.3 mm in radius at r 56.5. On `jar_10L` the baffles bind first. On
  the others that is what places it, and `head()` warns it is under the band: 25.2 mm (0.73 D) on
  `jar_1p5L`, 31.9 mm (0.64 D) on `jar_1gal_155` and 71.5 mm (0.76 D) on `jar_6p5gal`.
- **The ring's eight 3 mm holes**, 1.20 m/s each at 0.5 vvm, so well inside Barbosa's
  0.4–5.4 m/s, and the same 5.10 mm bubble floor, spread over the 291° of C before the end plug's
  solid, 8.0 hole diameters apart. One bore carries all of it to a dead end, so its open area
  ratio is 4.5, twice the ring's two paths: the holes need not share the gas evenly along the C,
  which the bench sees.
- **It hangs on the feed riser alone**, through the arm's boss and screw: 0.374 N/mm at the loop,
  21.6 mm under the riser's end, so 0.467 N sideways closes its 1.25 mm to a baffle, and `head()`
  warns. Nor is that the only way to close it: the impeller's swirl puts a torque on a C round
  the shaft, which turns it about the riser against the port's seal, and as little as 1.27° of
  that does the same (1.25 mm over the riser's 56.5 mm from the axis). What the flow pushes and
  turns with is not known; this is the bench's question.
- **The plates keep the width the arm gives them**, 17.09 mm, and the gas has the arm's 1922 Pa to
  beat, from the same height.

#### The ring

- **A tube ring at 1.90 D, placed by the mouth.** Birch & Ahmed 1997 tested a ring at 1.4 D — the
  radius at which the annulus outboard of the impeller encloses the volume it sweeps — and found
  better power draw and delayed flooding; Rewatkar & Joshi 1993 recommend a large ring outright.
  So the ring goes as far out as the mouth allows, 132.8 mm on this jar, with 1.25 mm to the
  baffles inboard and 1.25 mm to the mouth on the way in. On the 70 mm impeller that is 1.90 D,
  inside the 1–2 D band `head()` echoes. It is a 6.4 mm octagonal tube on a 4 mm bore, split
  opposite the feed and plugged with two screws so a brush passes through it.
- **It sits midway between the impellers**, 105 mm off the floor, 35 mm from each. That place was
  chosen for the pitched pair, which converged on it: Birch & Ahmed put a ring above an up-pumping
  blade and below a down-pumping one. Two Rushtons both discharge radially, so neither pumps
  toward it, and nothing held here places a ring between two radial turbines.
- **Eight 3 mm holes, and their geometry is for spacing and against fouling, not for even flow.**
  Rewatkar & Joshi: _"hole size and number of holes have negligible effect when the sparger is
  located near the impeller."_ Even flow is unreachable anyway: 96 Pa of capillary pressure to
  launch a bubble against 2.4 Pa to push gas through a hole, so a fixed tolerance hurts small holes
  most. At 0.5 vvm the holes run 1.20 m/s, inside the 0.4–5.4 m/s Barbosa 2003 actually ran; he
  establishes no critical velocity.
- **What it cannot do is make small bubbles.** Diameter at formation goes as the cube root of hole
  size — 5.10 mm here — so the 1.56 mm of a microporous sparger would want an 86 µm orifice, which
  is why those are sintered. Bubble size is the strongest lever on kLa this design does not have;
  it is the open item.
- **The bore is a departure.** The feed run carries the whole flow at 5.42 m/s with an open area
  ratio of 4.5, and each ring 2.25, so the holes compete with their supply. `head()` names both;
  the fix is a wider riser, which is one designation and a cascade of fits (`TODO.md`).
- **The risers are structure.** Nothing else in the vessel touches the ring, so the six 4 × 0.5 mm
  316 tubes that drop from the tube ports — one feeding, five blind — are what hold it: 1.02 N/mm
  a support, 0.98 mm of sway per newton against 1.25 mm to the baffles. The feed's socket is the
  ring's own tube standing up; the supports' are round, which is the only thing that tells them
  apart at the bottom of a jar.
- **The gas supply has to beat 1413 Pa before anything bubbles**: 134.5 mm of culture over the
  ring plus 96 Pa of capillary. The line's own losses are an order of magnitude more, and the
  sterile filter's slope is extrapolated (`TODO.md`).

### Impeller

- **Two six-blade Rushton turbines at the standard**, D = T/3, the lower T/3 off the floor and the
  upper a further T/3 up (section 3). Chosen to be comparable, not for what it does best.
- **Po 4.17 ± 0.14 measured** (Kaiser 2016) and flow number 0.65, Grenville's typical. McCabe gives
  5.75 and 1.3; section 2 says why the model keeps the measured power number.
- **Radial, and what it costs the circulation.** A photobioreactor's criterion is Molina Grima's
  frequency of switch between light and dark, which is pumping. At equal power and diameter flow
  goes as `Fl · Po^(−1/3)`, which on Grenville's Table 1 (Rushton 0.65 and 5.0, 45° pitched blade
  0.80 and 1.5) puts the pitched blade about 1.8× ahead; his Fig. 3 agrees at about 2× the fluid
  pumped per joule. With McCabe's own pair for the Rushton, 1.3 and 5.75, the two come out nearly
  even, so the gap is as uncertain as the flow number.
- **The gas does not bind on this jar.** A radial impeller holds its flow pattern against a gas
  stream with 3× the stream's power (Oldshue), so the pair holds 0.5 vvm down to 242 rpm, under
  the drive's rated 320; at 320 the ceiling is 1.16 vvm and at 420 it is 2.61. `jar_1p5L` is the
  vessel where it binds (section 5).
- **What the drive does to the culture**, at the rated 320 rpm: Re 26,000, tip 1.17 m/s, 1.06 W
  into 8.17 L = 130 W/m³ mean and 27.1 W/kg peak for one impeller, the pair under 0.063 N·m of a
  0.49 N·m rating; blend to 95 % in 5.9 s; kLa 0.0081 s⁻¹ coalescing. Both transfer correlations
  are extrapolated — van't Riet is fitted over 500–10,000 W/m³ and Ruszkowski over 0.01–10 m³ —
  and `head()` says so.
- **No energy dissipation rate limit exists for any microalga.** The parameter the physics says
  governs has no citable number for these organisms.
- **Speed feedback is specified but not wired.** The drive's encoder resolves 0.89 rpm over 100 ms,
  672 counts per output turn, and nothing reads it yet: tip speed and Re are computed from a
  commanded speed.

### Baffles

- **Three at 120°, one fewer than Oldshue's reference count, and the vessel is under-baffled.** His
  reference is four plates at T/12 running the liquid depth (McCabe's standard turbine has four at
  T/12 too, p. 243), and he allows three only at the same total projected area. These hang from the
  lid to the floor limit, 17.09 × 274 mm with 223.5 mm submerged, and reach **0.713** of the
  reference projected area; four would reach 0.951. The fourth plate's port went to a sampling line
  (`docs/ports-layout.md`). Both levers are spent: depth is at the floor, and the next count that
  spaces equally on twelve ports is four, at the cost of that port. Under-baffling lets the vessel
  swirl rather than mix.
- **The width is capped by the lock bore.** The smaller impeller left room the 94.5 mm pitched pair
  did not, so the plate keeps 12.96 mm nominal to the blades and 10.51 mm running, after the
  2.44 mm of lean the coupling's 0.2 mm of play allows at the lower impeller. That lean is a worst
  case, bore play alone with the flange's face contact ignored. A ring build pays the ring's bound,
  10.35 mm and 0.433 of reference, since the room outside a baffle does not grow with the mouth;
  the arm builds do not. On `jar_1gal_180` the plates are the same 17.09 mm and reach **0.847** of
  reference.
- **What sized the plate was dynamics, not strength and not collision.** Root stress is about 1 % of
  yield, and the plate bends tangentially while the impeller sweeps a circle, so deflection never
  closes the radial gap. What binds is the first bending mode, which falls as 1/L², against blade
  passing, which a six-blade turbine sweeps from 0 to 42 Hz on the way to 420 rpm. Stiffness goes as
  t³ and the mode as t^1.5, so thickening raises the crossing toward the 320–420 rpm band. The plate
  is **10 mm**. On the 17.09 mm plate the mode is 17.9 Hz, crossed by blade passing at 179 rpm and
  by the shaft at 1072, clearing the band by 44 %; the tip deflects 0.92 mm under 0.64 N, under the
  tenth-of-width limit `head()` warns on. The ring build's 10.35 mm plate deflects 1.52 mm and
  draws that warning.
- **The load is reasoned from two directions and neither is cited.** Each plate reacts its share of
  the impeller's torque, `T / (n · r)`; the dynamic pressure of a tangential stream at 0.3 of tip
  speed agrees within 26 %. No source held here loads a baffle. Added mass is not optional in the
  mode: the entrained water is over twice the PETG's own, and leaving it out overstates the
  frequency by about 80 %.
- **Partial and inboard is uncited.** The plates span about r 48–65 mm in a 210 mm bore, so the
  annulus outboard of them is about 40 mm wide and unobstructed — a consequence of passing every
  part through a 142.2 mm mouth. Inboard baffles are characterised in the literature, not
  recommended; the relevant papers are paywalled and unread (`docs/references.md`).

- **The plate prints in two dovetailed pieces**, and the joint is in the deflection above: 4.2 mm
  of the plate's 10 crosses the joint plane, 0.074 of its second moment, 0.13 mm of the 0.92 mm at
  the tip. Why it splits where it does, which way the slide runs and what the joint leaves
  unmodelled is in `docs/build.md`.
