# References

Every external source this design rests on, what it is used for, and where in the repo that use
lives. Kept so a number in the CAD can be traced back to the thing that justifies it, and so
nobody has to reconstruct the reasoning later.

**Verification status is recorded per source, and it is not decoration.** Several claims in this
project reached the design through summaries before anyone read the paper, and three of those
turned out to be wrong. The status says how far each source was actually checked:

- **read** — the full text was retrieved and the cited passage confirmed
- **abstract** — only the abstract was available; the claim is from it
- **unread** — cited from a secondary source, not obtained

Grades: **[PR]** peer-reviewed · **[TH]** thesis · **[PAT]** patent · **[TX]** textbook ·
**[TP]** trade press · **[VN]** vendor.

Every literature source below is also in [`references.bib`](references.bib) — 33 entries carrying
the grade and verification status in their `note` fields, so the whole set imports into a reference
manager in one go rather than one DOI at a time. Vendor pages, part numbers and software libraries
are deliberately not in it: they are cited inline on the registry row or file that uses them.

---

## Impeller and tank geometry

**Fitschen, J., Maly, M., Rosseburg, A., Wutz, J., Wucherpfennig, T. & Schlüter, M. (2019).**
"Influence of Spacing of Multiple Impellers on Power Input in an Industrial-Scale Aerated Stirred
Tank Reactor." *Chemie Ingenieur Technik* 91(11):1794-1801. [doi:10.1002/cite.201900121](https://doi.org/10.1002/cite.201900121) **[PR]** ·
**read**
D/T 0.3-0.5 and ~0.3 for radial impellers; impeller spacing 1.0-2.0 d; the up-to-35 % power
penalty for spacing too close. Their own rig ran d/D = 0.33, a radial ratio, so the spacing rule is
carried from the literature they review rather than measured on an axial impeller.
→ `scad/utils/stirred_tank.scad`, `scad/head.scad` impeller guideline block

**Nienow, A.W. (2006).** "Reactor engineering in large scale animal cell culture." *Cytotechnology*
50(1-3):9-33. [doi:10.1007/s10616-006-9005-8](https://doi.org/10.1007/s10616-006-9005-8) **[PR]** · **read**
Design guideline (a): axial hydrofoils at 0.4-0.5 of the vessel diameter, dual, clearance between
them 0.33-0.5 T, sparger below the lower impeller, baffles required. Also the dimensional objection
to tip speed, the honest Kolmogorov statement, the four regions of bubble damage, and the estimate
of peak dissipation from power over impeller swept volume.
→ `scad/utils/stirred_tank.scad`, `scad/head.scad`

**Nienow, A.W. (2021).** "The Impact of Fluid Dynamic Stress in Stirred Bioreactors — The Scale of
the Biological Entity: A Personal View." *Chemie Ingenieur Technik* 93(1-2):17-30.
[doi:10.1002/cite.202000176](https://doi.org/10.1002/cite.202000176) **[PR]** · **read**
Restates the tip-speed objection fourteen years on; turbulence at Re > ~2e4; "high" and "low shear"
impeller labels described as largely disproven.
→ `scad/utils/stirred_tank.scad`

**Rotondi, M. et al. (2021).** *Biotechnology Letters* 43:1103-1116.
[doi:10.1007/s10529-021-03076-3](https://doi.org/10.1007/s10529-021-03076-3) **[PR]** · **read**
As impeller diameter approaches 50 % of vessel diameter, axial flow loses its strong axial motion —
the upper bound on D/T.
→ `scad/utils/stirred_tank.scad`

**Fořt, I., Jirout, T., Sperling, R., Jambere, S. & Rieger, F. (2002).** "Study of Pumping Capacity
of Pitched Blade Impellers." *Acta Polytechnica* 42(4). [doi:10.14311/380](https://doi.org/10.14311/380) **[PR]** · **read**
Power number against blade angle and blade count, and the Medek correlations
`Po ∝ (sin α)^2.077` and `N_Qp ∝ (sin α)^0.468` (valid α 15-60°, Re > 1e4, four baffles) — power
rises with angle about 4.4× faster than pumping does. Blade-count series 3/4/6 → 0.79/0.99/1.34.

**Also fixes the blade width this project had recorded as unsourced.** Both impeller families are
Czech Standards and both are drawn at **h/D = 0.2** — the simple PBT is ČVS 691020 (nB 3 at α 24°,
35°, 45°; nB 6 at α 45°), the folded-blade impeller ČVS 691010 (nB 3, s/D 1.5, α 67°, β 25°, γ 48°).
Measured in a T = 400 mm vessel with four wall baffles at H = T, D/T 0.36. Two caveats for
transferring it: **H/T = 1.0 there against 1.124 here**, which is the one Medek departure this
vessel cannot remove; and the folded blade is a three-angle fold, not a flat plate at a pitch, so
its measured Po does not transfer to a plate drawn at 45°.
→ `scad/custom/impellers.scad` `impeller_folded_axial_3/4/6` and `impeller_pbt_45_4` width_ratio,
`scad/head.scad` `impeller_n_fins`

**Jirout, T. & Rieger, F.** "Impeller design for mixing of suspensions." CTU Prague —
<https://users.fs.cvut.cz/tomas.jirout/vyuka/p2_hmp/chep_vyuka.pdf> **[PR]** · **read**
Reproduces the above and adds the folded-blade series, including **Np = 0.99 ± 0.04** for a 4-blade
folded axial impeller — the closest measured analogue to this project's blade.
→ `scad/custom/impellers.scad` `impeller_folded_axial_4`

**Zhou, G., Shi, L. & Yu, P. (2003).** "CFD Study of Mixing Process in Rushton Turbine Stirred
Tanks." 3rd Int. Conf. on CFD in the Minerals and Process Industries, CSIRO, Melbourne —
<https://www.cfd.com.au/cfd_conf03/papers/002Guo.pdf> **[PR]** · **read**
The classic standard tank configuration: H = T, D = T/3, C = T/3, four baffles at T/10.
Cited here as "Guo, Langrish & Fletcher" until 2026-08-13 — an attribution reconstructed from the
filename, in which `Guo` is the first author's *given* name. The claim was re-checked against the
PDF and stands; only the authors were wrong. Also gives the reference Rushton: six blades with
width and height both D/4.
→ `scad/custom/impellers.scad` `impeller_rushton_6`

**Grenville, R., Giacomelli, J., Padron, G. & Brown, D. (2017).** "Impeller Performance in Stirred
Tanks." *Chemical Engineering*, August 2017, pp. 46-54 —
<https://framatomebhr.com/Portals/0/PDF/Publications/Impeller-Perfomance-in-Stirred-Tanks.pdf>
**[TP]** · **read**
The peak-dissipation correlation `ε_max = 1.04·x·Po^(3/4)·N³·D²` (±15 %) and the peak-to-mean form
`0.82·(x/Po^(1/4))·(T/D)³`. **Trade press, not peer-reviewed** — the weakest-graded source carrying
real weight in this design. The impeller constant x — Rushton 12, pitched blade 16, hydrofoil 17
— is a property of the shape, so it is carried per type.
→ `scad/custom/impellers.scad` x column, `scad/utils/stirred_tank.scad`

**Lonza Biologics, US10883076B2** — <https://patents.google.com/patent/US10883076B2/en> **[PAT]**
· **read**
Axial impellers at D/T 0.35-0.55, preferred 0.40-0.48, "most preferred" 0.44-0.46. Self-contradictory
on its own upper bound; superseded as the D/T citation by Nienow 2006 and Rotondi 2021.

**Davis, R.Z. (2010).** "Design and Scale-Up of Production Scale Stirred Tank Fermentors." MS
thesis, Mechanical and Aerospace Engineering, Utah State University —
<https://digitalcommons.usu.edu/etd/537> **[TH]** · **read**
Spacing 1.0-2.0 d with the bottom impeller 1.0 d off the floor, and power falling to about 80 % of
the properly-spaced value below 1.0 d; top impeller ≥ 1.5 d below the liquid surface; baffles
0.08-0.10 T, four on 90° centres.
**Davis relays these rather than measuring them**, from his refs [15] and [17]. Both primaries have
now been retrieved and read, and **four of the five relayed claims are not in either of them.**

| Davis's claim | In Oldshue [15]? | In Xing [17]? |
| --- | --- | --- |
| spacing 1.0-2.0 d **between impellers** | no | no |
| bottom impeller 1.0 d off the floor | **partly** — see below | no |
| power falls to ~80 % below 1.0 d | no | no |
| top impeller ≥ 1.5 d below the surface | no | no |
| baffles 0.08-0.10 T, four on 90° centres | **partly** — four at 1/12 T | no |

- **[15] = Oldshue (1997)**, chapter 5 of the handbook — retrieved and read, see its own entry
  below. The one thing that matches is p. 192: *"If the impeller can be placed **one to two impeller
  diameters off bottom**…"* — an **off-bottom clearance** for fluidfoil impellers, stated as a
  conditional trade-off. Davis appears to have read that as an impeller-**to-impeller** spacing
  rule; the numbers 1-2 d are the same, the quantity is not. Nothing in the chapter gives an
  impeller separation, an 80 % penalty, or a submergence depth.
- **[17] = Xing, Z., Kenty, B.M., Li, Z.J. & Lee, S.S. (2009)**, *Biotechnol Bioeng* 103(4),
  [doi:10.1002/bit.22287](https://doi.org/10.1002/bit.22287). Retrieved and read. A mixing-time,
  kLa and CO₂-removal scale-up study on 5,000 L CHO bioreactors that **contains no impeller-spacing
  guideline at all** — "impeller distance" and "off-bottom clearance" appear only as nomenclature
  symbols for its own vessel. (Davis also cites it Kenty-first; Xing is the first author.)

**Treat this entry as unreliable for numbers.** It is kept because it is where the numbers entered
this project and the correction has to stay visible, not because it supports them. Cite Oldshue
directly for the off-bottom clearance and the baffles.

So the spacing band, the 1.0 d off-bottom clearance, the 80 % penalty and the baffle geometry all
trace to a handbook nobody here has opened, relayed through a thesis. Treat them as leads, not as
design targets; the **read** against the thesis says only that Davis says them.
Cited as "Davis, D.A. (2009)" with no title until 2026-08-13; both initials and year were wrong.

**Oldshue, J.Y. (1997).** "Agitation," chapter 5 of Vogel, H.C. & Todaro, C.L. (eds.),
*Fermentation and Biochemical Engineering Handbook: Principles, Process Design, and Equipment*,
2nd ed., Noyes Publications, Westwood NJ, 1997, pp. 181-241. ISBN 0-8155-1407-7. **[TX]** · **read**
The primary behind the numbers `Davis (2010)` relays, retrieved 2026-08-20. What it actually says:

- **Baffles, p. 202.** Four baffles, *"each 1/12 the tank diameter in width"* — a single value,
  0.0833 T, not the 0.08-0.10 band Davis reports. And explicitly: *"Either 3, 6 or 8 baffles can be
  used if preferred. The general principle is to use the same total projected area as exists with
  four baffles, each 1/12 the tank diameter in width."* The project now runs **four**, which is his
  reference case outright; the passage had been carrying three, permitted by the same sentence.
  Either way the constraint is total projected area, not the count.
- **Off-bottom clearance, p. 192.** *"If the impeller can be placed one to two impeller diameters
  off bottom, which means that mixing is not provided at low levels during draw off, these
  impellers offer an excellent flow pattern as well as considerable economies in shaft design."*
  Read the grammar: **"if … can … offer"** makes this an allowance for **fluidfoil** impellers with
  a stated cost, not a rule to meet. `head()` reports a departure from it rather than warning.
- **Coverage over the impeller, p. 191-192** — the sentence immediately *before* the band, and the
  one that decides this reactor's clearance. *"However, there is a tendency for these impellers to
  short-circuit the fluid to a relatively low distance above the impeller. Very careful
  consideration of the coverage over the impeller is important."* He gives **no number**. The two
  requirements do not overlap in this vessel: the band needs C ≥ 94.5 mm and half a diameter of
  coverage allows C ≤ 69.2, because two impellers span 154.5 mm of a 241 mm column.
- **Axial impellers in a gassed system, p. 228.** *"the upward flow of gas tends to negate the
  downward action of the pumping capacity of the axial flow turbine. A radial flow turbine must
  have **three times** more power than the power in the gas stream for the mixer power level to be
  fully effective. On the other hand, the axial flow impeller must have **eight to ten times** more
  power than in the gas stream for it to establish the axial flow pattern."* Evaluated against this
  reactor: the axial pair holds its flow pattern only to **0.45 vvm at the rated 320 rpm**, where a
  radial impeller at the same power would take 1.20.
- **Sparger, p. 214.** *"A sparge ring about 80 % of the impeller diameter is more effective than
  an open pipe beneath the impeller or sparge rings larger than the impeller… the desired entry
  point for the gas is where it can pass initially through the high shear zone around the
  impeller."* **Superseded, and recorded here only because the project sized against it.** Two
  experimental studies find the opposite — Birch & Ahmed 1997 and Rewatkar & Joshi 1993, both above
  — and both recommend rings *larger* than the impeller. What survives is the second half: gas
  should enter where the impeller immediately works it, which agrees with Nienow 2006.
- **Gas dispersion.** The lower impeller does most of the gas-dispersing work, and a common
  three-impeller power split is 40 % lower / 30 % each upper.
- **kLa by gassing out, p. 226.** *"an unsteady state reaeration test in which the tank is stripped
  of oxygen; air is started with the mixer running and the dissolved oxygen level increase is
  monitored until the tank is saturated"* — the method this project needs, since Van't Riet's
  correlation does not reach its P/V. He warns the endpoint sits between top and bottom saturation
  values, so the driving force used to reduce it is not the log-mean one.

**Not in it**, despite being attributed to it: any impeller-to-impeller spacing rule, the 80 %
power penalty below 1.0 d, and any top-impeller submergence depth.
→ `docs/agitation.md` baffles and sparger sections

**Kaiser, S.C., Werner, S., Jossen, V., Kraume, M. & Eibl, D. (2017).** "Development of a method
for reliable power input measurements in conventional and single-use stirred bioreactors at
laboratory scale." *Engineering in Life Sciences* 17(5):500-511.
[doi:10.1002/elsc.201600096](https://doi.org/10.1002/elsc.201600096) **[PR]** · **read**
The power-number definition `Np = P/(ρN³d⁵)` and measured Rushton Np 4.17 ± 0.14. Cited in the SCAD
as "Kaiser 2016", which is the online publication date; the issue is 2017.
→ `scad/custom/impellers.scad` `impeller_rushton_6`

### Sparger geometry and location

Both were obtained and read on 2026-08-21. Together they overturn the 80 %-of-impeller ring
Oldshue gives on p. 214, which this project sized against until then — see that entry.

**Birch, D. & Ahmed, N. (1997).** "The Influence of Sparger Design and Location on Gas Dispersion
in Stirred Vessels." *Chemical Engineering Research and Design* (Trans IChemE Part A) 75(A5):487-496.
[doi:10.1205/026387697523994](https://doi.org/10.1205/026387697523994) **[PR]** · **read**
From the abstract: *"Significant performance improvements, in terms of improved power draw and
delayed onset of flooding on aeration, are achieved through the use of **'larger than impeller'
ring spargers**, positioned within the discharge stream from the impeller. There is little or no
penalty in terms of the gas holdup generated."* They tested a ring at **1.4 D**, which is not
arbitrary — the annulus from R out to 1.41 R encloses the same volume the impeller sweeps, a
physical rationale Oldshue's 80 % has never had. Gas belongs in the impeller's **discharge** stream,
so above an up-pumping impeller and below a down-pumping one.
→ `scad/utils/stirred_tank.scad` `stirred_tank_sparge_ring_band()` lower bound

**Rewatkar, V.B. & Joshi, J.B. (1993).** "Role of Sparger Design on Gas Dispersion in Mechanically
Agitated Gas-Liquid Contactors." *The Canadian Journal of Chemical Engineering* 71(2):278-291.
[doi:10.1002/cjce.5450710215](https://doi.org/10.1002/cjce.5450710215) **[PR]** · **read**
*"The use of a large ring is recommended"*, with the critical speed for gas dispersion **lowest at
a ring twice the impeller diameter**. Also, and this is what retired an entire hole-sizing study
here: *"Hole size and number of holes on the ring sparger have **negligible effect when the sparger
is located near the impeller**. However, these variables become important when the sparger is
located away from the impeller."* They used 2, 3 and 6 mm holes. **Scale caveat**: vessels of 0.57,
1.0 and 1.5 m diameter against this project's 0.21 m, and a pitched-blade **downflow** turbine,
where this reactor's lower impeller pumps up.
→ `scad/utils/stirred_tank.scad` `stirred_tank_sparge_ring_band()` upper bound

### Blade twist — measured in the literature, but out of this blade's range

Both twist papers were obtained on 2026-08-13 and read. The earlier note that "nothing exists" was
wrong: twist *is* characterised, with a consistent direction of effect. What is missing is coverage
of this blade's range, which is a different and narrower gap.

Both define **blade twist as the hub angle minus the tip angle**. On that definition this project's
blade is a **30° twist** — `agitation.md` derives 83° at the hub falling to 53° at the tip — which
is 1.5× the largest twist either paper tested, at hub angles 23° steeper than either explored.
`impeller_twist_ang` and `impeller_height` therefore remain **uncharacterised design parameters**,
documented by derivation in `scad/head.scad` rather than by citation.

- **Patwardhan, A.W. & Joshi, J.B. (1999).** *Ind Eng Chem Res*. [doi:10.1021/ie980772s](https://doi.org/10.1021/ie980772s) **[PR]** ·
  **read** — §3.4.3 tests 10° and 20° twist on 30°, 45° and 60° blades: *"For a particular blade
  angle, an increase in the twist decreases the values of N_P and N_QP. However, the values of
  N_QS are affected to a much smaller extent. As a result of these, the mixing time decreases with
  an increase in the blade twist."*
- **Kumaresan, T. & Joshi, J.B. (2006).** *Chem Eng J* 115:173-193. [doi:10.1016/j.cej.2005.10.002](https://doi.org/10.1016/j.cej.2005.10.002) **[PR]** ·
  **read** — §3.1.3.3, 10° twist on a six-blade 30° pitched turbine lowers the power number, cuts
  secondary flow number 3 % and averaged shear rate 1 %. Small in magnitude, same direction as
  Patwardhan. Was recorded here as the one outstanding paywalled gap; it is neither paywalled to us
  now nor the gap it was assumed to be.

**Consequence for the model.** Two independent studies agree that twist *reduces* the power number.
This project borrows Po = 0.99 from an **untwisted** 4-blade folded axial impeller, so that figure
is most likely an over-estimate for this blade, and every quantity derived from it — shaft power,
mean and peak dissipation, torque demand — is conservative in the safe direction. Neither paper
reaches 30° twist at 83° hub angle, so this is a direction, not a correction factor.
- **Lightnin / General Signal patents** — <https://patents.google.com/patent/US5158434A/en>,
  <https://patents.google.com/patent/US4468130A/en> **[PAT]** · **read** — the only published twist
  numbers found (30-45° twist, 18-30° tip chord angle). They describe a cambered foil with a
  tangential chord; this project's blade is a thick radial fin, so they do not transfer.
- Helical-ribbon and screw-impeller work is **creeping-flow, Re < 20**, four orders from this
  reactor's duty, and does not apply: Ameur et al. 2018,
  [doi:10.3390/chemengineering2020026](https://doi.org/10.3390/chemengineering2020026) **[PR]** ·
  **read** — its simulations run at Re = 10. A second example, Seichter 1981
  (doi:10.1135/cccc19812007), was dropped on 2026-08-20: it stayed paywalled, Ameur carries the
  dismissal on its own, and it was the only source here never read.

---

## Cell damage, shear and agitation

**Mazzuca Sobczuk, T., García Camacho, F., Molina Grima, E. & Chisti, Y. (2006).** "Effects of
agitation on the microalgae *Phaeodactylum tricornutum* and *Porphyridium cruentum*." *Bioprocess
and Biosystems Engineering* 28(4):243-250. [doi:10.1007/s00449-005-0030-3](https://doi.org/10.1007/s00449-005-0030-3) **[PR]** · **read**
The central mechanism: *"Mechanical agitation was not the direct cause of cell damage. Damage
occurred because of the rupture of small gas bubbles at the surface of the culture."* Tip speeds
>1.56 m/s (*P. tricornutum*) and 2.45-2.89 m/s (*P. cruentum*). Pluronic F-68 protective.

**Leupold, M., Hindersin, S., Gust, G., Kerner, M. & Hanelt, D. (2013).** "Influence of mixing and
shear stress on *Chlorella vulgaris*, *Scenedesmus obliquus*, and *Chlamydomonas reinhardtii*."
*J Appl Phycol* 25:485-495. [doi:10.1007/s10811-012-9882-5](https://doi.org/10.1007/s10811-012-9882-5) **[PR]** · **read**
Optimum tip speed **1.26 m/s = 0.45 Pa** (+48 % growth for *C. vulgaris*, +71 % for *S. obliquus*);
at **2.03 m/s = 0.9 Pa** photosynthetic activity falls back to the unstirred control; at 5.89 m/s it
is 7-8 % below control. *C. reinhardtii* does not benefit (−2.3 % PA at the optimum).

**Read the apparatus before transferring the tip speed.** This is not a stirred tank with an
impeller. It is a **Gust (1989) microcosm** — 1.75 L of culture in PMMA, *"mixing was created by the
tip speed of a **spinning plate with skirt**"* sitting 5 cm above the bottom, with metered fluid
recirculated through the centre axis. Their `u_tip = r·ω` is that **plate's** rim speed.

Three consequences for how this project uses the numbers:

- **The shear is generated in a plate-to-wall gap, not an impeller discharge.** The paper puts the
  main force at *"a surface of 644 cm² at the wall and spinning plate"*, as a Reynolds stress in the
  water head between the two. An impeller of the same tip speed produces a discharge jet, which is a
  different mechanism. Equal tip speed does not imply equal shear between the two devices, and the
  paper does not claim it does.
- **The Pa figures are the *bottom* stress, which the authors call the secondary force.** Calibrated
  friction velocity *"occurs at 314 cm² of the bottom of the microcosm and is the secondary, minor
  shear force in present study"*. So the 0.45 and 0.9 Pa quoted above are not the dominant stress in
  their own experiment.
- **Direct calibration stops at 250 rpm.** Rates above that *"are calculated by means of an empirical
  model based on hydrodynamics of a boundary layer theory (Schlichting 1968)"*.

None of this makes the measurement wrong, and it remains the only *Chlorella*-specific agitation
figure this project has. What it means is that **treating 1.26 and 2.03 m/s as impeller tip speeds is
an assumption this project makes, not a result the paper reports** — and it is the assumption that
sets the operating band and, through it, D/T. The physically transferable quantity the authors
themselves emphasise is friction velocity; converting that to an impeller would require estimating
the shear our own impeller produces, which has not been done.
→ `docs/agitation.md` operating point

**Hu, W., Berdugo, C. & Chalmers, J.J. (2011).** "The potential of hydrodynamic damage to animal
cells of industrial relevance." *Cytotechnology* 63(5):445-460. [doi:10.1007/s10616-011-9368-3](https://doi.org/10.1007/s10616-011-9368-3)
**[PR]** · **read**
With no gas-liquid interface, cells are unaffected at 100-450 rpm, 600 rpm in a full vessel, and
1500 rpm for hybridomas. Bubble rupture 1e7-1e9 W/m³. A **review**, so those three results are
restated from Zhang & Thomas 1993 and Kunas & Papoutsakis 1990.

**Ma, N., Koelling, K.W. & Chalmers, J.J. (2002).** *Biotechnol Bioeng* 80(4):428-437.
[doi:10.1002/bit.10387](https://doi.org/10.1002/bit.10387) **[PR]** · **read**
Bubble-rupture dissipation orders of magnitude above impeller dissipation: rupture reaches
1.66e4-4e5 kW/m3 against no detected damage below 1e4 kW/m3, and the peak falls two orders as
bubble diameter grows 1.7 to 6.32 mm.

**Barbosa, M.J., Albrecht, M. & Wijffels, R.H. (2003).** *Biotechnol Bioeng* 83(1):112-120.
[doi:10.1002/bit.10657](https://doi.org/10.1002/bit.10657) **[PR]** · **read**
Damage originates at the **sparger**, during bubble formation, rather than at bursting:
*"Superficial gas velocity alone cannot be used to estimate cell damage in sparged microalgal
cultures, which means that bubble bursting is not the only factor, and might not even be the most
important factor, leading to cell death."* Gas entrance velocity is named as the parameter to
watch, damage is strain-dependent, and the cell wall is confirmed protective.
**No critical velocity is established, and this entry used to claim one.** It read "critical gas
entrance velocities ~30-50 m/s", which the paper does not support: Barbosa's own runs were
0.4-5.4 m/s, and the larger figures quoted in it (13.3 m/s lab, 47.8 m/s pilot) are two comparison
reactors from Camacho et al. 2001, discussed to explain a lab-versus-pilot discrepancy. The paper
closes "more work remains to be done to clarify the influence of this parameter". Corrected
2026-08-13; the sparger design constraint this was carrying is weaker than it looked.

**Michels, M.H.A. et al. (2010, 2016).** *Bioprocess Biosyst Eng* 33:921-927,
[doi:10.1007/s00449-010-0415-9](https://doi.org/10.1007/s00449-010-0415-9); *J Appl Phycol* 28:53-62, [doi:10.1007/s10811-015-0559-8](https://doi.org/10.1007/s10811-015-0559-8) **[PR]** ·
**read**
Shear thresholds in Pa for four marine species; damage is instantaneous rather than cumulative; the
rigid-cell-wall rule; measured shear in real photobioreactors (circulation tube 0.57 Pa, pump
pressure side 1.82 Pa, centrifugal impeller tip 26 Pa).

**Wang, C. & Lan, C.Q. (2018).** *Biotechnology Advances* 36(4):986-1002.
[doi:10.1016/j.biotechadv.2018.03.001](https://doi.org/10.1016/j.biotechadv.2018.03.001) **[PR]** · **read**
Taxonomic shear-tolerance ranking: greens > cyanobacteria > haptophytes > reds > diatoms >
dinoflagellates. *Chlorella* is a rigid-walled green alga, the most tolerant class.

**Varley, J. & Birch, J. (1999).** *Cytotechnology* 29(3):177-205. [doi:10.1023/A:1008008021481](https://doi.org/10.1023/A:1008008021481)
**[PR]** · **read**
The provenance of the widely-quoted 1.5 m/s tip-speed limit — attributed to Kioukia et al. 1992 for
human melanoma cells in 5 % serum, then generalised, in a paper that also reports 6 m/s causing no
measurable harm to a hybridoma line. Also the correct rule that large slow agitators beat small fast
ones at equal power input. **Cited here as a caution, not as a design input.**

**Brindley Alías, C. et al. (2004).** *Biotechnol Bioeng* 87(6):723-733. [doi:10.1002/bit.20179](https://doi.org/10.1002/bit.20179)
**[PR]** · **read** — damage above 30-80 s⁻¹ in a **pump-driven tubular** photobioreactor.

**Contreras, A., García, F., Molina, E. & Merchuk, J.C. (1998).** *Biotechnol Bioeng* 60(3):317-325
[doi:10.1002/(SICI)1097-0290(19981105)60:3<317::AID-BIT7>3.0.CO;2-K](https://doi.org/10.1002/%28SICI%291097-0290%2819981105%2960:3%3C317::AID-BIT7%3E3.0.CO;2-K)
**[PR]** · **read** — growth optimum at ~7000 s⁻¹ in a **concentric tube airlift**.
*These two are often presented as contradictory. They are not — different equipment, different
shear mechanism.*

**Godoy-Silva, R. et al. (2009).** *Biotechnol Bioeng* 103(6):1103-1117. [doi:10.1002/bit.22339](https://doi.org/10.1002/bit.22339)
**[PR]** · **read** — CHO resistant to the highest EDR tested, 6.4e6 W/m³, with most product
quality attributes unaffected; the glycosylation shift begins at 6.0e4 W/m³, two orders lower.

**Walls, P.L.L. et al. (2017).** *Sci Rep* 7:15102. [doi:10.1038/s41598-017-14531-5](https://doi.org/10.1038/s41598-017-14531-5) **[PR]** ·
**read** — bubble-rupture energy simulation; repeated exposure lowers the lethal threshold.

**Karimi Alavijeh, M., Lee, K. & Gras, S.L. (2024).** *Eng Life Sci* 24(7):e2400023.
[doi:10.1002/elsc.202400023](https://doi.org/10.1002/elsc.202400023) **[PR]** · **read** — measured Kolmogorov length 78 µm against a <20 µm
cell, so the criterion is not binding at these scales.

**Uyar, B., Ali, M.D. & Uyar, G.E.O. (2024).** *Bioprocess Biosyst Eng* 47(2):195-209.
[doi:10.1007/s00449-023-02952-8](https://doi.org/10.1007/s00449-023-02952-8) **[PR]** · **read**
The only peer-reviewed power budget found for a microalgal stirred tank: **aeration 29.4-49.1 W/m³
against stirring 0.65-1.30 W/m³**.

**Wileman, A., Ozkan, A. & Berberoglu, H. (2012).** *Bioresour Technol* 104:432-439.
[doi:10.1016/j.biortech.2011.11.027](https://doi.org/10.1016/j.biortech.2011.11.027) **[PR]** · **read**
Microalgal broth rheology: Newtonian with <30 % viscosity rise below 20 kg/m³. Covers *Chlorella*,
*Nannochloris* and *P. tricornutum* — **not** *Arthrospira*.

---

## Seals and glands

**Apple Rubber, Seal Types and Gland Design Tables**, Section 4 —
<https://www.applerubber.com/src/pdf/section4-seal-types-and-gland-design-tables.pdf> **[VN]** ·
**read**
Table A static-seal bands: 19-33 % axial squeeze, 14-23 % radial; groove width ratios by cord; fill
never above 85 %, hard limit 90 %. Table B for the groove's outer diameter under internal pressure.
→ `scad/utils/oring_gland.scad`, `scad/head.scad` lid seal block

---

## Bolted joint

**ASME BPVC VIII-1, Mandatory Appendix 2** — flange design, gasket factor *m* from Table 2-5.1.
Working reference used: <https://codesignengg.com/wp-content/uploads/2025/05/LinkedIn-Article-Flange-Design-per-Appendix-2.pdf>
**[TP]** · **read**
Bolt count and spacing for the lid-to-frame joint; *m* = 0.5 for elastomer under 75A, 1.0 at or
above.
→ `scad/utils/bolt_pattern.scad`, `scad/head.scad` `head_gasket_factor()`

---

## Baffles

**Baffle width and number calculation** —
<https://myengineeringtools.com/references/pages/baffle_width_and_number_calculation.html> **[VN]**
· **read** → `scad/custom/bayonet_baffle_port.scad`

**PMC8459426** — <https://pmc.ncbi.nlm.nih.gov/articles/PMC8459426/> **[PR]** · **read**
Flow accelerating behind a baffle keeps that region from going stagnant, which is why partial
baffles standing inboard are not purely a loss. → `scad/head.scad` baffle block

**Note on status:** partial/inboard baffles are *characterised* in the literature, not
*recommended*. The relevant papers (*Chem Eng Res Des* S0263876207730952, *Chem Eng Sci*
S0009250906007950) are paywalled and unread. This design's three inboard baffles rest on an
unresolved citation.

---

## Unbaffled vessels and eccentric agitation

Opened because mouths under about 98 mm cannot hold four baffles beside two Ø16 probes at any port
count (`working.tmp/PORTS-options.md`), so the small jars in the family are unbaffled whatever else
is decided. Everything here is **unread** — obtained as citations and secondary summaries, not as
full text. The quantitative claims below are exactly the ones that need the papers before they can
be leaned on.

**Montante, G.; Bakker, A.; Paglianti, A.; Magelli, F. (2006).** "Effect of the shaft eccentricity
on the hydrodynamics of unbaffled stirred tanks." *Chemical Engineering Science* 61:2807-2814.
[doi:10.1016/j.ces.2005.09.021](https://doi.org/10.1016/j.ces.2005.09.021) **[PR]** · **unread**
The reference for eccentric mounting as a swirl fix: off-centre placement breaks the axisymmetric
rotating column that forms around a centred shaft in an unbaffled vessel. Reported second-hand as
giving mixing times similar to or lower than a baffled vessel with a centred shaft, **with a pitched
blade turbine** — which is this design's impeller, so it is the closest match in the literature and
the one worth retrieving first.

**Galletti, C.; Pintus, S.; Brunazzi, E. (2009).** "Effect of shaft eccentricity and impeller blade
thickness on the vortices features in an unbaffled vessel." *Chemical Engineering Research and
Design* 87:391-400. [doi:10.1016/j.cherd.2008.11.013](https://doi.org/10.1016/j.cherd.2008.11.013)
**[PR]** · **unread**
Two vortices, above and below the impeller, with the upper one dominating and its inclination set by
the eccentricity. Notes the vortex oscillates slowly rather than sitting steady, which is a caution
rather than a recommendation: it means macro-mixing in an eccentric unbaffled vessel is unsteady.

**Scargiali, F.; Busciglio, A.; Grisafi, F.; Brucato, A. (2014).** "Mass transfer and hydrodynamic
characteristics of unbaffled stirred bio-reactors: Influence of impeller design." *Biochemical
Engineering Journal* 82:41-47. [doi:10.1016/j.bej.2013.11.009](https://doi.org/10.1016/j.bej.2013.11.009)
**[PR]** · **unread**
The reason unbaffled is a design choice and not only a fallback. In an uncovered unbaffled vessel the
free-surface vortex transfers gas without sparging, so bubble bursting and the cell damage that goes
with it are avoided entirely — attractive for shear-sensitive and foaming systems. **Note this is the
opposite strategy to the one above**: eccentric mounting suppresses the vortex, this uses it. They
are two different vessels, not one recommendation.

**Busciglio, A.; Scargiali, F.; Grisafi, F.; Brucato, A. (2016).** "Oscillation dynamics of free
vortex surface in uncovered unbaffled stirred vessels." *Chemical Engineering Journal* 285:477-486.
[doi:10.1016/j.cej.2015.10.015](https://doi.org/10.1016/j.cej.2015.10.015) **[PR]** · **unread**

**Labík, L.; Petříček, R.; Moucha, T.; Brucato, A.; Caputo, G.; Grisafi, F. (2018).** "Scale-up and
viscosity effects on gas-liquid mass transfer rates in unbaffled stirred tanks." *Chemical
Engineering Research and Design* 132:584-592.
[doi:10.1016/j.cherd.2018.01.051](https://doi.org/10.1016/j.cherd.2018.01.051) **[PR]** · **unread**

**What the geometry says regardless of the papers.** Eccentric mounting is not currently available in
this architecture. The motor mount is a Ø56 body centred on the lid, and the port flanges reach
inward to `head_port_circle_radius(mouth) − 13.6`. On `jar_1p5L` the mount overlaps that band by
12.45 mm and on `jar_1gal_155` by 8.30 mm — **an unasserted collision**, masked only because the
port-spacing assert fires first. Where there is room at all it is small: e/T ≤ 0.070 on `jar_10L` and
≤ 0.099 on `jar_1gal_180`, against the 0.1-0.4 the literature works in. Moving the shaft off-centre
would mean shrinking the mount or moving the ports, and on the two jars that need it there is no
headroom at all.
→ `working.tmp/PORTS-options.md`, `TODO.md` airlift item

---

## Purchased parts

Vendor pages and datasheets are cited inline on the registry row that uses them, since the row is
the thing being justified:

- `scad/purchased/atlas_probes.scad` — Atlas Scientific product pages and datasheets, one per row
- `scad/purchased/vessels.scad` — the jar listings each vessel row was measured from
- `scad/purchased/strip_lights.scad` — LED strip listings
- `docs/procurement.md` and `purchased-parts.csv` — McMaster part numbers with their specifications

Notable rows: bearing **6153K71** (trade no. 608-2RS, and NopSCADlib's `BB608` carries the same
22 × 7 × 8), heat-set insert **97163A152**, rim gasket sheet **8525T65** (1/16 in = 1.5875 mm, 60A,
which sets the ASME gasket factor), port o-ring **8785N383**.

---

## Software and libraries

- **OpenSCAD** 2021.01
- **NopSCADlib** — vitamins: screws, nuts, inserts, ball bearings, shaft couplings, extrusions
- **bayonet-lock-scad** — the bayonet coupling this project's ports are built on
- `scad/custom/impeller.scad` is adapted from
  <https://infinityplays.com/3d-part-design-with-openscad-57-a-universal-propeller-impeller-design-module/>
  — a geometry module, not an engineering source

---

## Where the reasoning lives

- [`agitation.md`](agitation.md) — what limits agitation in this reactor, why the impeller is the
  size it is, and what is still uncharacterised
- [`design-conventions.md`](design-conventions.md) — the rules the model is built to, including the
  rim datum and how a geometry change is verified
- [`procurement.md`](procurement.md) and `purchased-parts.csv` — the bought parts and their specs
- [`ports-layout.md`](ports-layout.md) — port placement reasoning

Several claims in this list changed when the primary sources were read rather than summarised — a
Pa figure that was said not to exist, a tip-speed "threshold" that is really a growth optimum, and
a limit widely quoted as universal that rests on one cell line. That is why the verification status
above is recorded per source rather than assumed.
