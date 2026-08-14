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
→ `scad/head.scad` `impeller_n_fins`

**Jirout, T. & Rieger, F.** "Impeller design for mixing of suspensions." CTU Prague —
<https://users.fs.cvut.cz/tomas.jirout/vyuka/p2_hmp/chep_vyuka.pdf> **[PR]** · **read**
Reproduces the above and adds the folded-blade series, including **Np = 0.99 ± 0.04** for a 4-blade
folded axial impeller — the closest measured analogue to this project's blade.

**Zhou, G., Shi, L. & Yu, P. (2003).** "CFD Study of Mixing Process in Rushton Turbine Stirred
Tanks." 3rd Int. Conf. on CFD in the Minerals and Process Industries, CSIRO, Melbourne —
<https://www.cfd.com.au/cfd_conf03/papers/002Guo.pdf> **[PR]** · **read**
The classic standard tank configuration: H = T, D = T/3, C = T/3, four baffles at T/10.
Cited here as "Guo, Langrish & Fletcher" until 2026-08-13 — an attribution reconstructed from the
filename, in which `Guo` is the first author's *given* name. The claim was re-checked against the
PDF and stands; only the authors were wrong.

**Grenville, R., Giacomelli, J., Padron, G. & Brown, D. (2017).** "Impeller Performance in Stirred
Tanks." *Chemical Engineering*, August 2017, pp. 46-54 —
<https://framatomebhr.com/Portals/0/PDF/Publications/Impeller-Perfomance-in-Stirred-Tanks.pdf>
**[TP]** · **read**
The peak-dissipation correlation `ε_max = 1.04·x·Po^(3/4)·N³·D²` (±15 %) and the peak-to-mean form
`0.82·(x/Po^(1/4))·(T/D)³`. **Trade press, not peer-reviewed** — the weakest-graded source carrying
real weight in this design.

**Lonza Biologics, US10883076B2** — <https://patents.google.com/patent/US10883076B2/en> **[PAT]**
· **read**
Axial impellers at D/T 0.35-0.55, preferred 0.40-0.48, "most preferred" 0.44-0.46. Self-contradictory
on its own upper bound; superseded as the D/T citation by Nienow 2006 and Rotondi 2021.

**Davis, D.A. (2009).** MSc thesis, Utah State University **[TH]** · **read**
Spacing penalty below 1.0 d; top impeller ≥ 1.5 d below the surface; baffles 0.08-0.10 T, four at
90°.

**Eng. Life Sci. 2017, 17:500-511.** [doi:10.1002/elsc.201600096](https://doi.org/10.1002/elsc.201600096) **[PR]** · **read**
The power-number definition `Np = P/(ρN³d⁵)` and measured Rushton Np 4.17 ± 0.14.

### Blade twist — searched, and nothing exists

Recorded because the absence is itself a finding. `impeller_twist_ang` and `impeller_height` are
**uncharacterised design parameters**, documented by derivation in `scad/head.scad` rather than by
citation.

- **Patwardhan, A.W. & Joshi, J.B. (1999).** *Ind Eng Chem Res*. [doi:10.1021/ie980772s](https://doi.org/10.1021/ie980772s) **[PR]** ·
  **abstract** — twist is one of six co-varied parameters across ~40 axial impellers; no twist value
  appears in the abstract.
- **Kumaresan, T. & Joshi, J.B. (2006).** *Chem Eng J*. [doi:10.1016/j.cej.2005.10.002](https://doi.org/10.1016/j.cej.2005.10.002) **[PR]** ·
  **unread** — explicitly varies blade twist, paywalled. **The one genuine outstanding gap.**
- **Lightnin / General Signal patents** — <https://patents.google.com/patent/US5158434A/en>,
  <https://patents.google.com/patent/US4468130A/en> **[PAT]** · **read** — the only published twist
  numbers found (30-45° twist, 18-30° tip chord angle). They describe a cambered foil with a
  tangential chord; this project's blade is a thick radial fin, so they do not transfer.
- Helical-ribbon and screw-impeller work is **creeping-flow, Re < 20**, four orders from this
  reactor's duty, and does not apply: Rieger 1981, [doi:10.1135/cccc19812007](https://doi.org/10.1135/cccc19812007);
  [doi:10.3390/chemengineering2020026](https://doi.org/10.3390/chemengineering2020026) **[PR]** · **abstract**.

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

**Hu, W., Berdugo, C. & Chalmers, J.J. (2011).** "The potential of hydrodynamic damage to animal
cells of industrial relevance." *Cytotechnology* 63(5):445-460. [doi:10.1007/s10616-011-9368-3](https://doi.org/10.1007/s10616-011-9368-3)
**[PR]** · **read**
With no gas-liquid interface, cells are unaffected at 100-450 rpm, 600 rpm in a full vessel, and
1500 rpm for hybridomas. Bubble rupture 1e7-1e9 W/m³. A **review**, so those three results are
restated from Zhang & Thomas 1993 and Kunas & Papoutsakis 1990.

**Ma, N., Koelling, K.W. & Chalmers, J.J. (2002).** *Biotechnol Bioeng* 80(4):428-437.
[doi:10.1002/bit.10387](https://doi.org/10.1002/bit.10387) **[PR]** · **unread**
Bubble-rupture dissipation orders of magnitude above impeller dissipation.

**Barbosa, M.J., Albrecht, M. & Wijffels, R.H. (2003).** *Biotechnol Bioeng* 83(1):112-120.
[doi:10.1002/bit.10657](https://doi.org/10.1002/bit.10657) **[PR]** · **abstract**
Damage occurs at bubble **formation**, not rise or burst; critical gas entrance velocities
~30-50 m/s. The design constraint for any future sparger.

**Michels, M.H.A. et al. (2010, 2016).** *Bioprocess Biosyst Eng* 33:921-927,
[doi:10.1007/s00449-010-0415-9](https://doi.org/10.1007/s00449-010-0415-9); *J Appl Phycol* 28:53-62, [doi:10.1007/s10811-015-0559-8](https://doi.org/10.1007/s10811-015-0559-8) **[PR]** ·
**read**
Shear thresholds in Pa for four marine species; damage is instantaneous rather than cumulative; the
rigid-cell-wall rule; measured shear in real photobioreactors (circulation tube 0.57 Pa, pump
pressure side 1.82 Pa, centrifugal impeller tip 26 Pa).

**Wang, C. & Lan, C.Q. (2018).** *Biotechnology Advances* 36(4):986-1002.
[doi:10.1016/j.biotechadv.2018.03.001](https://doi.org/10.1016/j.biotechadv.2018.03.001) **[PR]** · **abstract**
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
**[PR]** · **abstract** — CHO resistant to 6.4e6 W/m³; sub-lethal glycosylation shifts two orders
lower.

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
