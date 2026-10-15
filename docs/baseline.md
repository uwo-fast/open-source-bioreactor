# Baseline and knobs

What this reactor is built to show now, what it holds at a standard so that can be shown, and
which settings later work is meant to move. The reasoning behind each number lives in the document
it links to; this page is the map, and the framing a paper about the design starts from.

---

## What the first paper claims

The contribution is the design: a stirred-tank photobioreactor that is parametric, derives its
numbers from cited data, prints on a desktop printer and costs little. To make that claim the
reactor has to be comparable with the literature, so **wherever a standard configuration exists,
the reference build runs at it**. A choice of this project's own would make every result a result
about that choice.

Later papers turn the knobs: the impeller pair, the layout, the speed, the aeration. The model
already carries them, and each is one parameter away. Nothing on this page is a claim that the
standard is the best setting; only that it is the one a reader can compare against.

## How the model holds a standard

- **A knob defaults to its standard.** Where a component carries one, the layout comes from the
  component's own row: the impeller types in `scad/custom/impellers.scad` each carry the tank
  layout they are standard at, and `impeller_bore_ratio`, `impeller_clearance_factor` and
  `impeller_spacing_factor` are `undef` until set.
- **A departure is reported, not hidden.** A knob set to a number is echoed as a departure from the
  standard, with both values (`impeller layout: D/T 0.45 departs from the standard's 0.333333`).
  The echo transcripts in `tests/echo` record every build's stream, so a departure shows in review.
- **Every number carries its kind**: measured, correlated, borrowed from a source, or reasoned and
  not cited (`docs/design-conventions.md`). A standard is a borrowed number, and the row says from
  where.

---

## Agitation: the baseline

On `jar_10L_220x305` (bore T = 210 mm, culture H/T 1.09).

| knob              | baseline                                                                                                      | source                                                                                                                                                      | kind                                                   | what later work varies                                                 |
| ----------------- | ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------- |
| impeller type     | six-blade Rushton turbine at both positions                                                                   | the standard fermentation configuration, on a microalgae researcher's advice                                                                                | chosen to be standard                                  | a Rushton under a pitched blade (`TODO.md`, long term); a pitched pair |
| blade proportions | blades D/5 high, D/4 long, on a 3D/4 disc                                                                     | McCabe 1993 p. 243 for the blades; Middleton & Ramshaw, US 5198156 for the disc                                                                             | borrowed                                               | none planned                                                           |
| power number      | 4.17 ± 0.14                                                                                                   | Kaiser 2016                                                                                                                                                 | measured, by others                                    | a bench measurement of the printed part                                |
| flow number       | 0.65                                                                                                          | Grenville 2017, typical                                                                                                                                     | borrowed                                               | as above                                                               |
| D/T               | 1/3 (70 mm)                                                                                                   | the standard turbine, McCabe, Smith & Harriott 1993 pp. 242-243, after Rushton, Costich & Everett 1950; the Handbook of Industrial Mixing allows T/4 to T/2 | borrowed                                               | 0.45, where the pitched pair ran                                       |
| lower clearance   | T/3 (1 D, 70 mm)                                                                                              | McCabe 1993: E/T 1/3 for one turbine, and about one impeller diameter off the bottom for several (p. 241)                                                   | borrowed                                               | T/4, Rutherford et al.'s parallel flow                                 |
| spacing           | T/3 (1 D, 70 mm)                                                                                              | Rutherford et al. 1996's merging flow, equal thirds at H = T, relayed by Li et al. 2007 Fig. 1; McCabe 1993 p. 253 asks at least one impeller diameter      | borrowed                                               | T/2, the parallel flow; 1.5-2 D                                        |
| impeller count    | 2 at H/T 1.09                                                                                                 | the microalgae researcher advising the project; McCabe 1993 p. 241 keeps one impeller to a depth equal to or somewhat over T and adds more for deeper       | chosen to be standard; Rutherford's pairs ran at H = T | a single Rushton                                                       |
| baffles           | four, sized against four at T/12 (Oldshue 1997 p. 202); the lock bore's depth holds them to 0.71 of that area | McCabe 1993 p. 240 and p. 243, four at T/12; the Handbook gives T/12 to T/10                                                                                | borrowed, with a stated shortfall                      | wider plates, six plates                                               |

**What the baseline costs.** The motor was chosen when the impeller was 94.5 mm, to reach both ends
of the speed band `docs/agitation.md` builds from Leupold et al. 2012. On the 70 mm impeller its
320–420 rpm gives 1.17–1.54 m/s at the tip: the _Chlorella_ optimum of 1.26 m/s falls at about
344 rpm, inside the band, and the 2.03 m/s break-even is out of reach. That band carries its own
stated assumption, that a plate-and-skirt rig's rim speed transfers to an impeller's tip.

**What it changes, on jar_10L at the rated 320 rpm**: 1.06 W, 130 W/m³ mean and 27.1 W/kg peak,
the pair under 0.063 N·m of the 0.490 N·m rating. The gas holds at 0.5 vvm down to 242 rpm.

**Other jars.** The standard layout is written for H = T. `jar_1gal_180x197`, at H/T 0.90, still
leaves 0.73 D over the upper impeller; `jar_1p5L_112x215` holds 0.5 vvm only above 399 rpm, which
is echoed as a warning.

---

## Not yet reconciled

- `docs/agitation.md` still argues for the pitched pair at D/T 0.45 and quotes its numbers.
- The baffle widths: four at T/10 against the T/12 the model sizes to; the sources accept both.
- Rutherford et al. 1996 is read through Li et al. 2007 and its abstract, not in full; the
  thresholds between its flow patterns are not claimed here.
- Rushton, Costich & Everett 1950 is read through McCabe, Smith & Harriott 1993, not in itself.
- The Handbook of Industrial Mixing's pages are relayed, not checked against the text.
- The power number: McCabe 1993 gives 5.75 for the standard disc turbine at T/10 baffles (Table
  9.3) and 1.3 for its flow number (p. 266); the model carries Kaiser's measured 4.17 and
  Grenville's 0.65. At 5.75 the power is 38% higher.
