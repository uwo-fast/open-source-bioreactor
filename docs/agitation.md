# Agitation design basis

This document explains how the impeller was sized, what limits agitation in this reactor, and what
is still unknown. The sources are listed in [References](references.md).

---

## 1. What limits agitation

Ranked by the strength of the evidence:

1. **Bubble rupture at a sparger or free surface** - dominant in any aerated vessel, 10^7-10^9 W/m^3
2. **Local maximum energy dissipation rate epsilon_max** near the impeller - not the vessel mean
3. **Shear stress in Pa** - the practical metric for microalgae, measured directly in Couette devices
4. **Kolmogorov microscale against cell diameter** - a real principle, but not binding at these scales
5. **Tip speed** - a convenient proxy with no mechanistic basis

**Bubble rupture, not impeller shear, is the dominant damage mechanism.** Sobczuk et al. studied
_P. tricornutum_ and _Porphyridium_ on the same rig and concluded that mechanical agitation did not
directly cause damage. Bubbles rupturing at the culture surface did, and the impeller was implicated
only because it generated the bubbles. Separately, for mammalian cells, removing the gas-liquid
interface leaves growth and viability unaffected at 100-450 rpm, at 600 rpm in a completely filled
vessel, and at 1500 rpm for hybridomas.

**Tip speed is not a design criterion.** It has the dimensions of neither shear rate (s^-1) nor
shear stress (Pa), as Nienow pointed out in 2006 and again in 2021. The widely quoted 1.5 m/s limit
comes from a single measurement on human melanoma cells in 5 % serum. A paper generalised it into a
universal rule, and two sentences later reported that 6 m/s caused no measurable harm to a hybridoma
line. **This model deliberately asserts no tip-speed limit.**

**For _Chlorella vulgaris_ the relevant figure is an optimum, not a threshold.** Leupold et al.
measured a peak at **1.26 m/s tip speed (0.45 Pa)**, with 4.0 % higher photosynthetic activity and
48 % higher growth than the unstirred control. Activity fell back to the unstirred control by
**2.03 m/s (0.9 Pa)**, and to 7-8 % below it by 5.89 m/s. They found no lethal limit at any speed
tested. Chlorella is a rigid-walled green alga, the most shear-tolerant class.

> **Assumption, stated once and applied throughout.** Leupold's apparatus is a 1.75 L Gust
> microcosm mixed by a **spinning plate with a skirt** 5 cm above the bottom, not a stirred tank with
> an impeller. Their tip speed is the rim speed of that plate, and its shear acts in the gap between
> the plate and the wall rather than in an impeller discharge jet. **Treating 1.26 and 2.03 m/s as
> impeller tip speeds is this project's transfer of their result, not their result.** It is the
> only agitation measurement available for _Chlorella_, so the band below is based on it regardless.
> Every speed, every D/T argument and the motor selection itself depend on that assumption. See
> [References](references.md#cell-damage-shear-and-agitation) for what the paper reports. Its
> calibration is direct only up to 250 rpm, and the quoted Pa figures are for the stress the authors
> call secondary in their own experiment.

---

## 2. This reactor, in the units that matter

Computed for the 70 mm Rushton turbine in the 10 L jar, with a **measured Np = 4.17 +/- 0.14**
(Kaiser 2016) and x = 12. Mean dissipation is taken over the **8.17 L** that this build derives from
`culture_fill_fraction`, not over the full jar, which holds 9.45 L filled to the brim. It is the
power of one impeller, which is the lower bound for the pair (see below). `head()` reports the two
registered-drive rows. The other rows are computed from the same relations at the speeds the
Chlorella band calls for.

| shaft speed                         | tip speed | Re     | mean epsilon (W/m^3) | epsilon_max (W/kg) |
| ----------------------------------- | --------- | ------ | -------------------- | ------------------ |
| 320 rpm - registered drive, rated   | 1.17 m/s  | 26,000 | 130                  | 27.1               |
| 344 rpm - Chlorella optimum         | 1.26 m/s  | 28,000 | 162                  | 33.6               |
| 420 rpm - registered drive, no-load | 1.54 m/s  | 34,200 | 294                  | 61.2               |
| 554 rpm - break-even                | 2.03 m/s  | 45,100 | 675                  | 141                |

**The pair draws more power than the table shows.** McCabe, Smith & Harriott (1993 p. 253) give the
power of two turbines at least one impeller diameter apart as about 1.9 times that of one. These are
exactly one diameter apart, so the mean for the pair at rated speed is nearer 250 W/m^3 than 130.
`head()` reports the power of one impeller as the lower bound and the sum of both as the upper bound
for torque, and does not choose a factor between them.

**The power number is Kaiser's measured value, not the textbook value.** McCabe's Table 9.3 gives
5.75 for the standard disc turbine, from tanks with four baffles at T/10. Kaiser measured 4.17 at
laboratory scale. This vessel matches neither exactly: it has four baffles at T/12 rather than T/10.
The model uses the measured figure. The difference is 38 % on every power and torque figure. At 5.75
the rated speed draws 1.46 W (179 W/m^3), and the pair stays under about 0.087 N-m of the 0.490
rating, so the choice of drive does not depend on which value is correct. A bench measurement of the
printed part will settle it (#133).

**Flow is fully turbulent throughout the band.** Every speed above exceeds both the textbook
threshold of Re > 10^4 and Nienow's stricter 2x10^4.

**The margin against damage is large.** At the rated 320 rpm, peak dissipation at the impeller is
~2.7x10^4 W/m^3. Bubble rupture is at 10^7-10^9 W/m^3 and the lethal range for CHO cells is
10^6-10^8 W/m^3, so the margin is two to five orders of magnitude. Agitation is not the threat to
this culture.

**Aeration also dominates the power budget.** The only peer-reviewed worked example for a microalgal
stirred tank gives 29.4-49.1 W/m^3 for aeration against 0.65-1.30 W/m^3 for stirring.

### The operating point

With the 70 mm impeller, the target band is wider than the speed range of the drive:

| target                                   | tip speed | shaft speed |
| ---------------------------------------- | --------- | ----------- |
| Chlorella growth optimum                 | 1.26 m/s  | **344 rpm** |
| break-even, where stirring stops helping | 2.03 m/s  | **554 rpm** |

**The registered drive is the 36PG-555PM-14-EN**: 14:1, rated at 320 rpm, 420 rpm at no load, giving
1.17 to 1.54 m/s. It was selected for the alternative 94.5 mm pitched pair, where that range was 1.58
to 2.08 m/s. It was the only motor examined that reached the break-even end of the band. With the
standard turbine it brackets the optimum but does not reach break-even. Comparing the optimum with
break-even therefore needs either a faster motor or a return to the larger impeller
([Baseline](baseline.md)).

It was chosen over a 19:1 variant whose whole range from rated to no-load speed, 265-385 rpm, lay
inside the band for the pitched pair. Keeping the whole range inside the band was a workaround for
the lack of speed feedback. When nothing measures the shaft speed, the load decides where it settles
between rated and no-load, so both ends have to be safe. **This motor has a magnetic encoder
instead**: 2 channels and 12 PPR at the motor shaft. Through the 14:1 gearbox this gives 672
quadrature counts per output revolution and resolves about 0.9 rpm over a 100 ms window, against a
band 210 rpm wide. Commanding a speed and measuring it is better than choosing a motor that cannot
miss the band.

Torque does not limit the choice. The impeller pair draws under 0.063 N-m at rated speed and under
0.109 N-m at no load, against a 0.490 N-m rating (**13 to 22 % of it**), so the shaft runs nearer
its no-load speed than its rated speed. This is why the registry stores rated torque and `head()`
reports the comparison at each speed: the comparison shows where an unmeasured shaft settles.

The registries store output speed, reduction ratio and rated torque, so `head()` computes Re, tip
speed, power, torque and both dissipation figures at render time instead of leaving them to hand
calculation. **No-load and rated speed are registered separately.** Across the ten ratios in the
36PG-3429 table, rated speed is 0.68-0.71 of no-load speed, so treating a catalogue speed as an
operating point overstates it by about half. A vendor speed with no qualifier is a no-load speed.

---

## 3. Impeller geometry

### The standard turbine

Two six-blade Rushton turbines with the standard turbine proportions: D = T/3, blades D/5 high and
D/4 long (McCabe, Smith & Harriott 1993 pp. 242-243, Fig. 9.7, after Rushton, Costich & Everett
1950), on a 3D/4 disc (Middleton & Ramshaw, US 5198156; McCabe gives no disc diameter). The
stirred-tank literature uses this configuration as its reference, which is why the reference build
uses it. [Baseline](baseline.md) lists which settings are held at a standard value and which later
work varies.

Rushton blades are flat and have no handedness, so both positions use the same part. It prints in
two halves ([Building it](build.md#two-things-about-printing-them)).

### Diameter

`impeller_bore_ratio` is `undef`, so it takes 1/3 from the Rushton row: 70 mm in the 210 mm bore of
`jar_10L`. The ratio is measured against the **wetted bore** of the vessel, which is the internal
diameter, not the outside diameter of the glass. This matters because a ratio applied to the outer
diameter lets the real ratio vary with wall thickness. Across the vessel registry in this project,
that gave 0.468 to 0.489 for a nominal 0.45.

1/3 is near the bottom of the 0.3-0.5 band that the model echoes. For solids suspension, McCabe says
D/T 1/3 is often recommended, "though some prefer" 0.4 (p. 268), and a larger impeller disperses
more gas at a given speed (p. 272). Section 4 makes the case for a larger impeller. The pitched pair
below ran at 0.45.

**On `jar_6p5gal_305x470` the mouth limits the diameter.** Its 137 mm mouth on a 280.8 mm bore caps
the ratio at 0.4879, where the impeller exactly fills the neck. At 1/3 the impeller is 93.6 mm and
passes with 43.4 mm to spare. At 0.45 it would leave 10.64 mm. The model asserts that the swept
diameter of the impeller fits through the vessel opening.

### Clearance and spacing

**The lower impeller is T/3 above the floor**, which is 70 mm on `jar_10L` and exactly 1 D. This
matches McCabe's E/Dt of 1/3 for a single turbine, and his "about one impeller diameter above the
bottom" for the lowest of several (p. 241), which is the same height when D = T/3.

**The upper impeller is a further T/3 higher**, 1 D apart. That is the minimum spacing McCabe gives
for a pair whose power nearly doubles (p. 253). It is also the equal thirds of the merging flow of
Rutherford et al. 1996 at H = T, as shown in Li et al. 2007 Fig. 1. Rutherford's alternatives are
parallel flow (lower impeller at T/4, the pair T/2 apart) and diverging flow (lower impeller at
0.15 T). This document makes no claim about the thresholds between them.

On `jar_10L` this leaves 63 mm below the blades of the lower impeller, 56 mm between the blades of
the two impellers, and 92.5 mm (**1.32 D**) of culture above the upper impeller.

**Two impellers, at H/T 1.09.** McCabe uses one turbine for a liquid depth equal to or somewhat
greater than T, and adds more for deeper liquid (p. 241), so this column is at the point where a
second becomes necessary. The project uses two on the advice of the microalgae researcher advising
it.

### The twisted paddle

`impeller_twisted_paddle_4` is a constant-pitch helicoid, so the blade angle beta from the plane of
rotation varies with radius as `tan(beta) = P/(2 pi r)`, from 83 deg at the hub to 53 deg at the
tip. No correlation covers it. Medek's envelope stops at 60 deg, and the twist papers tested at most
20 deg of twist, where this blade has 30 deg
([References](references.md#blade-twist---measured-in-the-literature-but-out-of-this-blades-range)).
The blade is steeper than 45 deg everywhere, so it is a twisted paddle biased toward radial pumping,
not the axial impeller the D/T guidance is written for. Its blade height has no source either. The
hub has a 10 mm radius (0.212 D) to carry the set screws, within the 0.2-0.33 D typical of hubs in
practice. A local boss that left the blade unchanged was rejected because it prints with an overhang
and must be indexed to the blades. The joint was the limiting problem, and an impeller that slips
loses the whole run.

It remains registered and drawn. A bench measurement of its power number is
[future work](../dev/future-work.md#agitation).

### The pitched pair

The alternative is two 45 deg four-blade pitched turbines, `impeller_pbt_45_4`, at D/T 0.45, with
the lower one 0.9 D above the floor and the pair 1 D apart. That layout is stored in the row's own
`tank` field, so a single `head_impeller_lower_type` / `head_impeller_upper_type` setting selects
it. A Rushton below a pitched blade is [future work](../dev/future-work.md#agitation). For that
layout:

- **Po and flow number come from a correlation.** Medek's correlation (Fort et al. 2002) gives both
  from the geometry and names the conditions a vessel violates. On `jar_10L` these are T/D and H/T.
- **Diameter.** 0.45 is mid-band in every source for an axial impeller: 0.3-0.5 in general, 0.4-0.5
  in cell culture, and 0.44-0.46 as one manufacturer's "most preferred". Above about 0.5 an axial
  impeller loses its strong axial flow.
- **Clearance 0.9 D, following Fort.** He tested pitched blades at C/D 0.5 and 1.0 and found higher
  hydraulic efficiency at 1.0. He associated low clearances with solids suspension and high ones
  with blending. Medek's correlation reproduces this, since `Po` scales as `(C/D)^-0.165` and `N_Q`
  as `(C/D)^0.254`:

  | C/D     | Po        | N_Q       | N_Q/Po    | vs 0.6      |
  | ------- | --------- | --------- | --------- | ----------- |
  | 0.6     | 1.596     | 0.800     | 0.502     | -           |
  | 0.8     | 1.522     | 0.861     | 0.566     | +12.8 %     |
  | **0.9** | **1.492** | **0.887** | **0.594** | **+18.5 %** |
  | 1.0     | 1.467     | 0.911     | 0.621     | +23.9 %     |

  Not 1.0, because 1.0 is the C/D limit of the correlation, and it reduces the culture depth over the
  upper impeller to less than half a diameter on `jar_10L`. The usual clearance for an axial
  impeller, a quarter to a third of the tank diameter, corresponds to C/D 0.556-0.741 in that bore.
  No source held here states it, so no band function encodes it.

- **Oldshue's 1-2 D spacing applies to fluidfoil impellers.** His passage is about _"these fluidfoil
  impellers"_, for both the allowance and the short-circuiting caveat. The band `head()` echoes has
  no primary source (Fitschen cites it from Davis, whose sources do not contain it), so it is
  reported and never asserted. At 1 D the pitched pair is closer than the ~1.55 D at which
  pitched-blade pairs act independently, and within the 0.33-0.5 T that Nienow specifies for a
  stacked pair.
- **The 0.5 D coverage minimum is reasoned, not cited.** Oldshue names the concern but gives no
  number. It is the depth at which a down-pumping impeller starts drawing its own discharge back
  from the surface. `head()` warns rather than asserts.
- **Blade count.** Measured on otherwise identical folded-blade axial impellers, Po is 0.79 / 0.99 /
  1.34 for 3 / 4 / 6 blades, so six blades take about 35 % more power than four at the same speed
  and diameter.
- **The two impellers are mirror images**, not the same part turned over. Pumping direction depends
  on blade handedness, and no rotation changes it.

---

## 4. Why large and slow

At **fixed tip speed**, peak dissipation decreases as the impeller gets larger:

```text
epsilon_max = 1.04 * x * Po^(3/4) * N^3 * D^2        with v_tip = pi N D fixed:   epsilon_max scales as 1/D
```

Doubling the impeller diameter halves the maximum local energy dissipation. At fixed tip speed the
power grows only as D^2, while the swept volume it is spread over grows as D^3. At **constant power
per volume** in a fixed vessel, `v_tip` scales as D^(-2/3) while pumping Q scales as D^(4/3), so a
larger impeller has a lower tip speed _and_ pumps more. Peak-to-mean dissipation scales as
(T/D)^3, so increasing D/T from 0.33 to 0.50 reduces it by ~3.5x.

This is why a shear-sensitive culture needs a large impeller turning slowly. It is the opposite of
the intuition that a gentler impeller is smaller and faster.

**One caution:** "low shear" impellers are not reliably gentle. A low power number can coexist with
a _higher_ peak dissipation than a Rushton turbine. Size the impeller rather than relying on the
label.

**The reference build still runs at D/T 1/3.** The argument above is for a parameter to vary, not
for the baseline. The results of the first paper must be comparable with the literature, so the
build keeps the standard turbine and leaves a larger impeller to later work
([Baseline](baseline.md)). At equal power and diameter the Rushton is the gentler of the two blades,
with about 0.56x the peak of a pitched blade, since `epsilon_max` scales as `x * Po^(-1/4)` (x and
Po from Grenville 2017, Table 1).

---

## 5. Agitation mode per vessel

Not every registered jar can be agitated the same way, and the reasons are geometric, not a matter
of preference. Three of the five swept vessels have no baffles, **for two different reasons**.

| vessel               | mouth | bore  | mouth/T   | baffles | why not                                   |
| -------------------- | ----- | ----- | --------- | ------- | ----------------------------------------- |
| `jar_1gal_180x197`   | 148   | 170   | 0.871     | 4       | -                                         |
| `jar_10L_220x305`    | 142.2 | 210   | 0.677     | 4       | -                                         |
| `jar_6p5gal_305x470` | 137   | 280.8 | **0.488** | 0       | the port circle falls inside the impeller |
| `jar_1gal_155x251`   | 95.8  | 149.3 | 0.642     | 0       | mouth below the flange floor              |
| `jar_1p5L_112x215`   | 88.4  | 103.5 | 0.854     | 0       | mouth below the flange floor              |

**The absolute minimum** ([Port layout](ports-layout.md#baffles-on-a-narrow-jar)): with a mouth
smaller than about 98 mm, no baffle fits beside two dia 16 Atlas probes at any port count. This
rules out `jar_1p5L` and `jar_1gal_155`. `jar_1p5L` has a _large_ mouth for its bore (0.854), so its
problem is absolute size, not proportion.

**The ratio limit**: the mouth of `jar_6p5gal` is small relative to its bore, so the port circle its
lid can offer lies inside the swept diameter of the impeller. This was measured by adding a
three-baffle set and rendering it. The flanges fit: 7-, 8- and 9-port sets all clear a 137 mm mouth,
and Oldshue accepts three baffles at equal projected area. The vessel then failed on something else:
_"a 126.36 mm impeller leaves no room for a baffle on a 107 mm port circle"_. No port count solves
this. D/T would have to fall to about 0.20, below the 0.3 minimum. **At D/T 0.45 this jar could not
carry a lid-hung baffle at all**, and the port table was not the cause. The measurement used the
pitched pair. By the same 0.20 limit, the Rushton at 1/3 does not fit either, although the set has
not been rendered again at that ratio.

### The three modes

**Baffled stirred**: `jar_10L` and `jar_1gal_180`. This is the reference configuration, and nothing
in this section changes it. The two `jar_10L` builds, the reference and the magnetic, carry the four
wall baffles counted in the table. `jar_1gal_180` hangs three plates from the lid.

**Unbaffled eccentric stirred**: `jar_6p5gal`. It is currently the worst case in the family: the
largest vessel, unbaffled and centred. Montante measured a flow number of **0.25 for that
arrangement, 65 % below the same impeller with baffles**. The jar cannot be baffled, but it
_builds_, it carries a top-entry drive, and it has room to offset the drive. `head()` calculates
what that room is worth: **9.8 mm today, e/T 0.035, worth 15.8 %** of the centred blend time by
Karcz. With the mount at the dia 36 minimum its gearbox faceplate allows, the offset is about
**25 mm**, e/T 0.090, **worth 31 %**. This is a mount change on a jar that already works, not a new
agitation mode.

The offset brings significant caveats. Six of the eight Karcz departures apply here, and Reynolds
number is one of them. Galletti reports that macro-mixing in an eccentric unbaffled vessel is
unsteady, with the vortex oscillating slowly rather than staying in place. Cabaret reports power
rising with eccentricity. Hall's measured `e = 0.2 T` remains out of reach at 0.090.

**Gas-driven**: `jar_1p5L` and `jar_1gal_155`. For these two the choice between eccentric and
centred does not arise, because neither can carry a shaft. Four points lead to the same conclusion:

- **Both build failures are assertions on the top-entry drivetrain.** On `jar_1p5L` the mount
  overlaps the port flanges by 12.5 mm. On `jar_1gal_155` the pH probe passes 6.29 mm into the lower
  impeller. Neither assertion exists in a configuration without that drivetrain, which the model
  expresses as `drive_name = "none"`. Both jars are registered as the airlift built on that
  configuration.
- **On `jar_1p5L` the gas already overwhelms the impeller at the design aeration rate.** A Rushton
  needs only 3x the power of the gas stream to hold its flow pattern, against Oldshue's 8x for an
  axial blade. Even so, it holds 0.5 vvm there only above 399 rpm. The drive is rated at 320 rpm,
  where the limit is **0.258 vvm**. It is the only vessel in the family that floods at rated speed.
  The others hold 0.5 vvm down to 227-297 rpm. Under the intended conditions it is a bubble column
  with a spinning obstruction in it.
- **Measured on this organism at this scale.** Uyar 2024 ran _C. sorokiniana_ in 2 L
  side-illuminated columns. Raising the stirrer speed from 100 to 200 rpm changed kLa by **15 %**
  and mixing time by **18 %**, while the sparger changed kLa **five-fold**. Productivity ranked
  bubble column 0.097, airlift 0.072 and stirred tank 0.064 gdw/(L day). At this size the impeller
  is not what makes the vessel work.
- **Swirl is particularly bad for a side-illuminated column.** Molina Grima: average irradiance
  "considers only the total length of the dark and the light periods, not the frequency of switch".
  Solid-body rotation keeps each cell at the same radius, so it is close to the worst possible flow
  here. The problem is not slow blending. It is that the light/dark cycle never happens.

**An airlift rather than a plain bubble column**, because this project objects to relying on
aeration for mixing: aeration that mixes as a side effect is an uncontrolled variable. A draft tube
gives a defined riser/downcomer ratio, circulation velocity and circulation time. Uyar measured these
at 10.9-12.1 cm/s and 6.1-6.8 s, and a bubble column does not have them at all. The paper computes
circulation time "only for ALR which has a circulation loop, it is not applicable to BCR nor STR".
Uyar's bubble column did produce more than its airlift, but the authors attribute that to the
sparger (microporous against a single 0.8 mm orifice). It is therefore not evidence that a column
beats an airlift with equal sparging.

**The airlift is not expected to outgrow the column either.** Sanchez Miron 2000 ran a bubble
column, a split cylinder and a draft-tube airlift side by side, with one alga at one power input,
and found _"no significant difference in culture performance"_. The draft tube provides the loop, in
which a cell rises through the core and descends through the lit annulus. It does not provide more
biomass.

`drive_name = "airlift"` selects this mode: the no-drive build plus a draft tube standing on the
floor around everything that hangs from the lid. The ring sparges inside the tube and also centres
it. On `jar_1p5L` the tube is 85.6 mm in diameter with A_d/A_r 0.508. On `jar_1gal_155` it is 93 mm
with 1.72. The narrower mouth limits the tube, while the bore sets the annulus. The gaps below and
above the tube give the turn the same area as the downcomer, within Chisti & Moo-Young's cap of
1.65. Chisti's circulation model is not applied: its data start at a height of 1.36 m, and these
loops are under 0.2 m. The DO probe hangs straight here. Its lean is there because of the shadow of
the shaft, and there is no shaft inside the riser.

### Eccentric mounting

Eq. (6) below is from Karcz's entry in
[References](references.md#unbaffled-vessels-and-eccentric-agitation), and Theta(0) is its
up-pumping branch at e = 0.

**What the geometry allows, with Karcz's correlation applied.** Eccentric mounting is a real and
well-supported effect, but this architecture can barely use it. The motor mount is a dia 56 body
centred on the lid, and the port flanges extend inward to `head_port_circle_radius(mouth) - 14.1`,
so the room for an offset is `Rpc - flange - lid_holes_offset - mount_radius`. On `jar_1p5L` this is
already **-12.5 mm**, and on `jar_1gal_155` it is **-8.30 mm**. This was an unasserted collision
until `head()` gained a check for it. Before that it was masked, because the port-spacing assertion
fails first.

The deeper problem is that **eccentricity is measured relative to the tank diameter, while the room
for it is set by the mouth.** Hall's e = 0.2 T needs 20.7 mm on `jar_1p5L` and 42.0 mm on
`jar_10L`. The largest offset any of these lids can give is 0.95 mm and 28.4 mm respectively, with
the mount reduced to the dia 36 minimum its gearbox faceplate allows and every port on a mini
flange. **e/T = 0.2 is out of reach on every registered vessel.** `jar_1gal_180` comes closest at
0.181, just short. The achievable values, from Karcz's equation:

| vessel         | mouth/T | e/T today | gain | e/T at best | gain |
| -------------- | ------- | --------- | ---- | ----------- | ---- |
| `jar_1p5L`     | 0.854   | 0         | 0%   | 0.009       | 5%   |
| `jar_1gal_155` | 0.642   | 0         | 0%   | 0.031       | 14%  |
| `jar_6p5gal`   | 0.488   | 0.035     | 16%  | 0.090       | 31%  |
| `jar_10L`      | 0.677   | 0.059     | 24%  | 0.135       | 37%  |
| `jar_1gal_180` | 0.871   | 0.090     | 31%  | 0.181       | 41%  |

**T here is the bore**, `vessel_outer_diameter - 2 x vessel_wall_thickness`, which is what T means
everywhere else in this project: the D/T in `head.scad` is calculated from it, and so is the H/T the
model echoes. The offset itself, `Rpc - flange - lid_holes_offset - mount_radius`, is lid geometry
in mm.

**The gain columns are computed from eq. (6)**, up-pumping branch: `gain = 1 - Theta(2*e/T) /
Theta(0)`, with `Theta(0) = 91.32`, so the table can be re-derived rather than trusted.

**The `e/T today` columns are echoed by the model, not transcribed.** `head()` computes the offset
the mount leaves (the slack above the minimum that its mount-versus-flange assertion requires),
divides it by the bore, and reports the gain with `stirred_tank_eccentric_gain()`. Those two columns
can therefore be read from a render rather than trusted. The figures above are that echo: 9.8 mm,
12.4 and 15.3, at e/T 0.035, 0.059 and 0.090. The two jars showing 0 produce no echo, because an
assertion stops them first. On `jar_1p5L` it is the mount. On `jar_1gal_155x251` it is the pH probe,
which fails before the mount is reached, although the mount would also fail. Their 0 is reasoned,
not rendered. It states the same fact another way: a lid with no room for the mount has no room for
an offset.

**The `e/T at best` columns are still calculated by hand**, because they describe a lid that does
not exist: the mount reduced to the dia 36 minimum its gearbox faceplate allows, with every port on
a mini flange. Nothing renders that lid, so nothing can echo it. These columns are eq. (6) evaluated
at a hand-calculated offset, and they are only as reliable as that calculation.

**They also have one digit less precision than they show.** These e/T values were re-derived from
the superseded column, which was quoted to three decimals, so each is uncertain by about +/-0.0005.
The offset in millimetres was never recorded for three of the five rows. Running the interval
through eq. (6) leaves four rows unchanged: 31 %, 37 %, 41 % and the 14 % for `jar_1gal_155` hold
across it. **`jar_1p5L` does not: it is 4.48 to 4.98 %, so 4 or 5**, and the recorded data cannot
say which. It is written as 5, the rounded midpoint, and it is the figure in this table most likely
to change on re-derivation.

The result is the wrong way round: **the vessels with room for eccentricity are the ones already
wide enough to carry baffles, and the two that need it have no room.** Off-centring does not rescue
the small jars. Separately, it is a cheap 25-31% gain on the large ones if they ever run unbaffled.
-> [Port layout](ports-layout.md#baffles-on-a-narrow-jar)

### What outranks all three

**The sparger, across the whole family.** The five-fold kLa spread Uyar measured came entirely from
bubble size: 1.56 mm from a microporous sparger against 4.18-4.25 mm from orifice spargers. The
spargers here have 1.2 mm holes, which make 3.76 mm bubbles at formation; 3 mm holes would make
5.10 mm bubbles. The 1.2 mm holes are still coarser than the 0.8 mm orifice that gave Uyar 4 mm
bubbles. Whichever mode a jar runs, a finer sparger matters more than the choice of mode. Fouling is
not a reason for larger holes. Photos of past cultures show almost no buildup on the sparger, or on
anything else at that depth. Buildup collects higher up, in the headspace and on the lid.

---

## 6. The design basis as it stands

Every figure below is what `head()` reports for `jar_10L_220x305` at the reference fill. The
transcript is `tests/echo/head__jar_10L_220x305.txt`. Earlier beliefs that turned out to be wrong
are listed in [Decisions](../dev/decisions.md#corrections---readings-that-were-wrong).

### Sparger

Three spargers share the riser from the `air_in` port, and each build names one (`sparger_name`).
The **arm** is the default with the shaft and magnetic drives, and the **ring** is the default with
no drive and with the airlift. The **loop** is used only when selected. The figures `head()` reports
for each are listed below. The ring's figures come from a `jar_10L` build with `sparger_name` set to
the ring and `baffle_name` set to `lid`, because the wall cage does not accept the ring. No
transcript holds that build. The loop's figures are from the reference build,
`tests/echo/build__jar_10L_220x305.txt`.

#### The arm

- **One straight run under the lower impeller, holes facing down.** It is the ring's feed without
  the ring: the same socket and elbow, then a run turned inward from the port circle at r 56.5 that
  ends 5 mm short of the shaft at r 9, 53 mm above the floor. That is 10 mm below the blades of the
  lower impeller, so the bubbles rise into it. This is where the stirred-tank literature places a
  sparger. Birch & Ahmed's argument for a ring between the impellers is covered under the ring
  below.
- **Eight 1.2 mm holes, the same size as the ring's**, spaced 3.32 hole diameters apart along the
  31.9 mm of bore between the elbow and the end plug. Each runs at 7.53 m/s at 0.5 vvm, beyond
  Barbosa's 0.4-5.4 m/s, and `head()` warns. The run cannot fit more holes at the minimum pitch.
  Bubbles are 3.76 mm at formation, as with the ring. The arm does not change the bubble size a
  1.2 mm hole produces.
- **The bore is not a departure**: 5.42 m/s in the feed run at an open area ratio of 0.72, and the
  94 Pa pressure drop across a hole is larger than the 18 Pa of velocity head in the bore.
- **The gas supply must exceed 2066 Pa before any bubbles form**: 186.5 mm of culture above the arm
  plus 240 Pa of capillary pressure. This is 509 Pa more than the ring needs, because the arm sits
  52 mm lower.
- **The arm gives the baffles back the width the ring took.** It runs between two plates rather than
  outboard of them, so the limit set by the ring no longer applies. The plates widen from 10.35 to
  17.09 mm, where the lock bore limits them (see below).

#### The loop

- **The arm's riser, socket and height, with the run hooked into a C around the shaft**, so
  the gas rises into the lower impeller all the way around rather than on one side. It is the
  pigtail sparger used under a turbine: one tube with no tee. The elbow turns inward from the port
  circle at r 56.5, a horizontal bend of the same radius as the elbow joins the curl tangentially
  from outside, and the C runs 300 deg around from there to a plugged end. It is 53 mm above the
  floor and 10 mm below the blades of the lower impeller, with the holes facing down.
- **76.54 mm in diameter, 1.09 D, set by the hook.** Birch & Ahmed's 1.4 D would be 99 mm, but the
  hook limits the size of the C (see below). 1.09 D is within the 1-2 D band. The mouth and the shaft
  are well clear, at 29.36 and 30.81 mm. With lid plates instead of the cage, the loop sits among the
  plates and they set its position. It stops 1.25 mm inside their inner edge, after allowing for the
  2.63 mm the plates can lean at its height and the 2.63 mm its own riser can lean, by the same
  coupling rule. The hook swings off the riser bearing toward the next plate and keeps 3.15 mm to
  the nearest plate once both have leaned.
- **The hook must start where the elbow ends**, with a bend inside the riser, and meet the C from
  outside, which costs about one more bend. The C can therefore be no larger than
  `sparge_loop_largest()`, 38.3 mm in radius at r 56.5. That sets its size on `jar_10L`. It also
  sets it on the other jars, where `head()` warns that it is below the band: 25.2 mm (0.73 D) on
  `jar_1p5L`, 31.9 mm (0.64 D) on `jar_1gal_155` and 71.5 mm (0.76 D) on `jar_6p5gal`.
- **Eleven 1.2 mm holes, the same as the ring's**, with the same 3.76 mm minimum bubble size, spread
  over the 291 deg of the C before the solid end plug, 14.7 hole diameters apart. A single bore
  carries all the gas to a dead end, where the ring has two paths. With sixteen holes the far end
  bubbled more weakly on the bench. The open area ratio was 1.44, and the 24 Pa across each hole was
  only just above the 18 Pa of velocity head in the bore. Eleven holes bring the open area to 0.99
  and the pressure drop across a hole to 50 Pa, at 5.47 m/s per hole. That is slightly above
  Barbosa's 5.4, and `head()` flags it. The two values multiply to the bore's own 5.42 m/s, so no
  hole size or count satisfies both. The ring keeps sixteen holes, because an odd count would put a
  hole in its split.
- **It hangs from the feed riser alone**, through the arm's boss and screw: 0.374 N/mm at the loop,
  29.6 mm below the end of the riser. With lid plates, a sideways force of 0.467 N closes its 1.25 mm
  gap to a baffle, and `head()` warns. That is not the only way to close the gap. The swirl from the
  impeller applies a torque to a C around the shaft, which turns it about the riser against the port
  seal, and as little as 1.27 deg of rotation does the same (1.25 mm over the 56.5 mm between the
  riser and the axis). The force and torque the flow applies are not known. This is a question for
  the bench.
- **Lid plates keep the width the arm gives them**, 17.09 mm, and the gas has to overcome the same
  2066 Pa as with the arm, from the same height.

#### The ring

- **A tube ring at 1.90 D, sized by the mouth.** Birch & Ahmed 1997 tested a ring at 1.4 D (the
  radius at which the annulus outside the impeller encloses the volume it sweeps) and found better
  power draw and delayed flooding. Rewatkar & Joshi 1993 recommend a large ring outright. So the ring
  is as large as the mouth allows, 132.8 mm on this jar, with 1.25 mm to the baffles inside it and
  1.25 mm to the mouth during insertion. With the 70 mm impeller that is 1.90 D, inside the 1-2 D
  band that `head()` echoes. It is a 6.4 mm octagonal tube with a 4 mm bore, split opposite the feed
  and plugged with two screws so that a brush can pass through it.
- **It sits midway between the impellers**, 105 mm above the floor and 35 mm from each. That
  position was chosen for the pitched pair, whose flows converged on it: Birch & Ahmed put a ring
  above an up-pumping blade and below a down-pumping one. Two Rushtons both discharge radially, so
  neither pumps toward the ring, and no source held here places a ring between two radial turbines.
- **Sixteen 1.2 mm holes, chosen for bubble size, not for even flow.** Rewatkar & Joshi: _"hole size
  and number of holes have negligible effect when the sparger is located near the impeller."_ Even
  flow cannot be reached anyway. Launching a bubble takes 240 Pa of capillary pressure, against
  24 Pa to push gas through a hole, so a fixed tolerance affects small holes most. At 0.5 vvm the
  holes run at 3.76 m/s, within the 0.4-5.4 m/s that Barbosa 2003 actually tested. He establishes
  no critical velocity. 1 mm holes printed too small.
- **It cannot make small bubbles.** Bubble diameter at formation scales with the cube root of hole
  size, giving 3.76 mm here, so the 1.56 mm bubbles of a microporous sparger would need an 86 um
  orifice. That is why those spargers are sintered. Bubble size is the strongest lever on kLa that
  this design does not have. It is the open item.
- **The bore sets the limit.** The feed run carries the whole flow at 5.42 m/s, which is the hole
  velocity times the open area ratio: 1.44 for the feed and 0.72 for each of the ring's two paths.
  While the bore runs that fast, no hole size satisfies both Barbosa's 5.4 m/s and an open area of 1.
  `head()` flags the open area and the bore. The fix is a wider riser, which means changing one
  designation and a cascade of fits ([future work](../dev/future-work.md#sparger)).
- **The risers are structural.** Nothing else in the vessel touches the ring, so the five
  4 x 0.5 mm 316 tubes that drop from the tube ports (one feeding, four blind) hold it. Each support
  gives 1.02 N/mm, which is 0.98 mm of sway per newton against 1.25 mm of clearance to the baffles.
  The feed socket is the ring's own tube turned upward. The support sockets are round, which is the
  only way to tell them apart at the bottom of a jar.
- **The gas supply must exceed 1557 Pa before any bubbles form**: 134.5 mm of culture above the ring
  plus 240 Pa of capillary pressure. The losses in the line itself are an order of magnitude larger,
  and the slope for the sterile filter is extrapolated (#131).

### Impeller

- **Two six-blade Rushton turbines in the standard layout**: D = T/3, the lower T/3 above the floor
  and the upper a further T/3 higher (section 3). Chosen to be comparable with the literature, not
  for best performance.
- **Po 4.17 +/- 0.14 measured** (Kaiser 2016) and flow number 0.65, Grenville's typical value.
  McCabe gives 5.75 and 1.3. Section 2 explains why the model keeps the measured power number.
- **Radial flow, and what it costs circulation.** The criterion for a photobioreactor is Molina
  Grima's frequency of switching between light and dark, which depends on pumping. At equal power
  and diameter, flow scales as `Fl * Po^(-1/3)`. With Grenville's Table 1 values (Rushton 0.65 and
  5.0, 45 deg pitched blade 0.80 and 1.5) this puts the pitched blade about 1.8x ahead, and his
  Fig. 3 agrees at about 2x the fluid pumped per joule. With McCabe's values for the Rushton, 1.3 and
  5.75, the two come out nearly even, so the gap is as uncertain as the flow number.
- **Gas does not limit this jar.** A radial impeller holds its flow pattern against a gas stream
  with 3x the power of the stream (Oldshue), so the pair holds 0.5 vvm down to 242 rpm, below the
  rated 320 rpm of the drive. At 320 rpm the limit is 1.16 vvm, and at 420 rpm it is 2.61. Gas does
  limit `jar_1p5L` (section 5).
- **Effect of the drive on the culture** at the rated 320 rpm: Re 26,000, tip speed 1.17 m/s, 1.06 W
  into 8.17 L = 130 W/m^3 mean and 27.1 W/kg peak for one impeller, the pair under 0.063 N-m of a
  0.49 N-m rating; blend time to 95 % 5.9 s; kLa 0.0081 s^-1 (coalescing). Both transfer
  correlations are extrapolated (van't Riet is fitted over 500-10,000 W/m^3 and Ruszkowski over
  0.01-10 m^3), and `head()` says so.
- **No energy dissipation rate limit exists for any microalga.** The parameter that governs damage,
  according to the physics, has no citable value for these organisms.
- **Speed feedback is specified but not wired.** The drive's encoder resolves 0.89 rpm over 100 ms
  (672 counts per output revolution), but nothing reads it yet. Tip speed and Re are computed from
  the commanded speed.

### Baffles

The two `jar_10L` builds, the reference and the magnetic, carry the standard four baffles on the
wall, mounted on a cage. `baffle_name = "auto"` selects the cage wherever it fits. `jar_1gal_180`
hangs plates from the lid, and the six-port lids carry no baffles
([Decisions](../dev/decisions.md#settled---do-not-re-open-without-new-evidence)). The first group of
bullets below describes the cage. The rest describe the plates as `head()` reports them on `jar_10L`
with `baffle_name = "lid"`, which no registered build uses and no transcript holds.

- **Four at T/12, T/72 from the glass, from floor to surface.** The blades are 17.5 mm wide, at 0,
  90, 180 and 270 deg (clear of the lit windows), 2.92 mm from the wall, and 229.5 mm of each is
  submerged. That is **1.00** of Oldshue's four-at-T/12 reference area. T/12 is McCabe's standard
  turbine (p. 243). The gap is Dynamix's J/6 (read), which is T/72, within the T/50 to T/72 of the
  Handbook of Industrial Mixing (cited through a trade article, not read). McCabe's Fig. 9.7 draws
  the baffles flush with the wall.
- **The cage changes shape to pass through the mouth.** The outer edges of the blades are 204 mm
  apart and the mouth is 142.2 mm, so a rigid cage cannot go in. Two hoops of r 64-70 pass through
  it lying flat, with 1.1 mm clearance on each side. Each blade hangs between the hoops on a radial
  bar at each end, which slides in a dovetail channel in the hoop. The bars are slid in 30.6 mm to a
  stop, closed under the bar flange at the outer end, and the cage goes down with the hoops bent
  where the pads catch. Inside the jar, each blade is pushed out to 0.4 mm from the glass at its
  pads. Three detents on each bar hold it: two straddle the hoop to hold it extended in both
  directions, and one holds it retracted during insertion.
  [Building it](build.md#the-wall-baffle-cage) covers the parts and the assembly.
- **One probe changes port.** The hoops are C-shaped, and the probes hang in the gap between the 0
  and 90 deg blades. The pH probe moves from the 120 deg port to the 30 deg port that a plate would
  otherwise use. The 120, 150 and 270 deg ports take blanks. Any port can take any function on this
  lid, so the move is only a re-plug.
- **The top hoop sits 1 mm above the culture**, out of the flow. It carries an arm that engages the
  air inlet riser (the tube the sparger hangs from), which stops the cage turning. At the no-load
  420 rpm, each blade carries 0.29 N and the riser 1.93 N at r 56.5, by the same `T / (n * r)` used
  for the plates (reasoned, not cited). Friction is not enough. The three prints contain 109 cm^3 of
  PETG, which weighs about 29 g in water and gives about 5 N-mm at mu 0.25 (assumed) at r 67 on the
  bottom hoop, against 63 N-mm on the riser at the rated 320 rpm.
- **Left to the bench, not modelled:** the slide fit, the force needed to push through a detent, and
  whether a detent holds a blade out under flow.

- **Three at 120 deg, one fewer than Oldshue's reference count, so the vessel is under-baffled.** His
  reference is four plates at T/12 over the full liquid depth (McCabe's standard turbine also has
  four at T/12, p. 243), and he accepts three only at the same total projected area. These plates
  hang from the lid down to the floor limit, 17.09 x 274 mm with 223.5 mm submerged, and reach
  **0.713** of the reference projected area. Four would reach 0.951. The port for the fourth plate
  went to a sampling line ([Port layout](ports-layout.md)). Neither option is available: the depth is
  at its limit, and the next count that spaces equally on twelve ports is four, which would cost
  that port. An under-baffled vessel swirls rather than mixes.
- **The width is limited by the lock bore.** The 70 mm impeller leaves room, so the plate keeps
  12.96 mm nominal clearance to the blades and 10.51 mm running. The difference is the 2.44 mm of
  lean that the 0.2 mm of play in the coupling allows at the lower impeller. That lean is a worst
  case: it counts bore play alone and ignores face contact at the flange. A ring build is limited by
  the ring instead, to 10.35 mm and 0.433 of reference, because the room outside a baffle does not
  grow with the mouth. The arm builds are not. On `jar_1gal_180` the plates are the same 17.09 mm and
  reach **0.847** of reference.
- **The plate was sized by dynamics, not by strength or collision.** Root stress is about 1 % of
  yield. The plate bends tangentially while the impeller sweeps a circle, so deflection never closes
  the radial gap. The limit is the first bending mode, which falls as 1/L^2, against the
  blade-passing frequency, which a six-blade turbine sweeps from 0 to 42 Hz on the way to 420 rpm.
  Stiffness scales as t^3 and the mode frequency as t^1.5, so a thicker plate raises the crossing
  toward the 320-420 rpm band. The plate is **10 mm**. On the 17.09 mm plate the mode is 17.9 Hz.
  Blade passing crosses it at 179 rpm and the shaft at 1072, which clears the band by 44 %. The tip
  deflects 0.92 mm under 0.64 N, within the tenth-of-width limit that `head()` warns on. The
  10.35 mm plate of the ring build deflects 1.52 mm and triggers that warning.
- **The load is estimated two ways, and neither is cited.** Each plate reacts its share of the
  impeller torque, `T / (n * r)`. The dynamic pressure of a tangential stream at 0.3 of tip speed
  agrees within 26 %. No source held here gives a baffle load. Added mass must be included in the
  mode: the entrained water has over twice the mass of the PETG, and leaving it out overstates the
  frequency by about 80 %.
- **Partial, inboard baffles are uncited.** The plates span about r 48-65 mm in a 210 mm bore, so
  the annulus outside them is about 40 mm wide and unobstructed. This follows from passing every
  part through a 142.2 mm mouth. Inboard baffles are characterised in the literature, not
  recommended. The relevant papers are paywalled and have not been read
  ([References](references.md#baffles)).

- **The plate prints in two dovetailed pieces**, and the joint is included in the deflection above.
  4.2 mm of the plate's 10 crosses the joint plane, which is 0.074 of its second moment and 0.13 mm
  of the 0.92 mm at the tip. [Building it](build.md#two-things-about-printing-them) explains why it
  splits where it does, which way the slide runs, and what the joint leaves unmodelled.
