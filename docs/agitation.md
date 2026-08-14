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

Computed for the 10 L jar with Np = 0.99 (4-blade folded axial, the closest measured analogue) and
x = 16:

| impeller | rpm | Re | ε̄ (W/m³) | ε_max (W/kg) |
| --- | --- | --- | --- | --- |
| 94.5 mm | 100 | 14,900 | 3.5 | 0.68 |
| 94.5 mm | 257 | 38,300 | 58.6 | 11.6 |
| 94.5 mm | 1154 (full motor speed) | 171,800 | 5,308 | 1,049 |

**The vessel is fully turbulent at every speed** (Re > 10⁴ by the textbook threshold, > 2×10⁴ by
Nienow's stricter one at all but the lowest speed).

**The margin against damage is large.** At 257 rpm the impeller's peak dissipation is ~1.2×10⁴ W/m³
against bubble rupture at 10⁷–10⁹ W/m³ and a CHO lethal range of 10⁶–10⁸ W/m³ — two to five orders
of magnitude. Agitation is not what threatens this culture.

**Aeration dominates the power budget too.** The one peer-reviewed worked example for a microalgal
stirred tank puts aeration at 29.4–49.1 W/m³ against stirring at 0.65–1.30 W/m³.

### The operating point

The drive is open-loop PWM with **no speed feedback**, so shaft speed is inferred from duty cycle
rather than measured. At the recorded duty the inferred speed is ~450 rpm, which is **past the
2.03 m/s point where stirring stops paying** for Chlorella. Not damaging — but not earning its
power either.

On the 94.5 mm impeller the band worth aiming at is narrow:

| target | tip speed | shaft speed |
| --- | --- | --- |
| Chlorella growth optimum | 1.26 m/s | **255 rpm** |
| break-even, stirring stops paying | 2.03 m/s | **410 rpm** |

The motor and gearbox registries now carry output speed and reduction ratio, so `head()` computes
Re, tip speed, power and both dissipation figures at render rather than leaving them to be worked
out by hand. **No-load and rated speed are registered separately**: they differ by a factor of 1.47
on the one motor with both published, so treating a catalogue speed as an operating point
overstates it badly. An unqualified vendor figure is a no-load figure.

Worth knowing: the replacement motor already registered does not reach this band. The
36PG-3429-5.2 is rated 950 rpm, or 4.70 m/s at the tip. It is the right motor family at the wrong
ratio — a sibling at roughly 19:1 lands near 257 rpm.

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

### Blade twist and height — uncharacterised

`impeller_twist_ang` and `impeller_height` have **no citable basis**. A dedicated literature search
found three stirred-tank hits in total for "impeller blade twist", none giving a value, and nothing
at all for W/D or blade height of a twisted extrusion. The classic `w = D/4` ratios describe flat
Rushton blades and do not apply.

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
  design. Damage occurs at bubble *formation*, with critical gas entrance velocities around
  30–50 m/s, and Nienow's guidance places the sparger below the lower impeller — a requirement the
  model cannot currently express.
- **No energy dissipation rate limit exists for any microalga.** The parameter the physics says
  governs has no citable number for these organisms.
- **No speed feedback.** Tip speed and Re are computed from an inferred shaft speed.
- **Partial inboard baffles are characterised in the literature but not recommended.** The relevant
  papers are paywalled and unread; this design's three inboard baffles rest on that gap.
