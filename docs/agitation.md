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

---

## 2. This reactor, in the units that matter

Computed on the 94.5 mm impeller in the 10 L jar, with Np = 0.99 (4-blade folded axial, the closest
measured analogue) and x = 16. Mean dissipation is over the **8.17 L** the jar holds at
`culture_fill_fraction`, not over the full jar; `head()` echoes every figure below at render.

| shaft speed | tip speed | Re | ε̄ (W/m³) | ε_max (W/kg) |
| --- | --- | --- | --- | --- |
| 255 rpm — Chlorella optimum | 1.26 m/s | 37,800 | 70 | 11.3 |
| 320 rpm — registered drive, rated | 1.58 m/s | 47,400 | 138 | 22.4 |
| 410 rpm — break-even | 2.03 m/s | 60,800 | 291 | 47.1 |
| 420 rpm — registered drive, no-load | 2.08 m/s | 62,300 | 313 | 50.6 |
| 1154 rpm — 36GP-3530 at full speed | 5.71 m/s | 171,100 | 6,482 | 1,049 |

**The vessel is fully turbulent throughout the band.** Every speed above clears both the textbook
Re > 10⁴ threshold and Nienow's stricter 2×10⁴.

**The margin against damage is large.** At the rated 320 rpm the impeller's peak dissipation is
~2.2×10⁴ W/m³ against bubble rupture at 10⁷–10⁹ W/m³ and a CHO lethal range of 10⁶–10⁸ W/m³ — two
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
- **No energy dissipation rate limit exists for any microalga.** The parameter the physics says
  governs has no citable number for these organisms.
- **Speed feedback is specified but not yet wired.** The registered drive carries a magnetic
  encoder and the model reports what it resolves — 672 counts per output turn, 0.89 rpm over a
  100 ms window — but nothing reads it yet, so tip speed and Re are still computed from a commanded
  speed rather than a measured one.
- **Partial inboard baffles are characterised in the literature but not recommended.** The relevant
  papers are paywalled and unread. The **count**, at least, is no longer resting on a gap: Oldshue
  1997 p. 202 gives four baffles at 1/12 T as the reference case and states that *"either 3, 6 or 8
  baffles can be used if preferred"* provided the total projected area matches. So three baffles
  are permissible by area, not by exception. Their being **partial and inboard** is still the
  uncited part.
