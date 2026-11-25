# Baseline and adjustable parameters

This page sets out what the reactor is built to demonstrate now, which settings are fixed at a
standard value so that it can be demonstrated, and which settings later work is meant to vary. The
reasoning behind each number is in the document it links to. This page is an index to them.

---

## What the first paper claims

The contribution is the design: a parametric stirred-tank photobioreactor that derives its numbers
from cited data, prints on a desktop printer and is low in cost. To support that claim, the reactor
has to be comparable with the literature. Therefore, **wherever a standard configuration exists,
the reference build uses it**. A configuration chosen by this project would make every result
depend on that choice.

Later papers will vary the impeller pair, the layout, the speed and the aeration. The model already
includes these, and each one is a single parameter. This page does not claim that the standard is
the best setting, only that it is the one a reader can compare against.

## How the model applies a standard

- **A parameter defaults to its standard value.** Where a component defines a standard layout,
  the layout comes from that component's row. Each impeller type in `scad/custom/impellers.scad`
  carries the tank layout it is standard for, and `impeller_bore_ratio`,
  `impeller_clearance_factor` and `impeller_spacing_factor` are `undef` until set.
- **A departure is reported, not hidden.** A parameter set to a number is echoed as a departure
  from the standard, with both values (`impeller layout: D/T 0.45 departs from the standard's 0.333333`).
  The echo transcripts in `tests/echo` record the echo output of every build, so a departure shows
  up in review.
- **Every number states its kind**: measured, correlated, borrowed from a source, or reasoned and
  not cited ([Design conventions](design-conventions.md#a-number-is-a-claim-and-it-carries-how-good-a-claim-it-is)).
  A standard is a borrowed number, and its row gives the source.

---

## Agitation: the baseline

On `jar_10L_220x305` (bore T = 210 mm, culture H/T 1.09).

| parameter         | baseline                                                                                         | source                                                                                                                                                      | kind                                                   | what later work varies                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| impeller type     | six-blade Rushton turbine at both positions                                                      | the standard fermentation configuration, on a microalgae researcher's advice                                                                                | chosen to be standard                                  | a Rushton under a pitched blade ([future work](../dev/future-work.md#agitation)); a pitched pair |
| blade proportions | blades D/5 high, D/4 long, on a 3D/4 disc                                                        | McCabe 1993 p. 243 for the blades; Middleton & Ramshaw, US 5198156 for the disc                                                                             | borrowed                                               | none planned                                                                                     |
| power number      | 4.17 +/- 0.14                                                                                    | Kaiser 2016; [Agitation](agitation.md#2-this-reactor-in-the-units-that-matter) says why not McCabe's 5.75                                                   | measured, by others                                    | a bench measurement of the printed part                                                          |
| flow number       | 0.65                                                                                             | Grenville 2017, typical                                                                                                                                     | borrowed                                               | as above                                                                                         |
| D/T               | 1/3 (70 mm)                                                                                      | the standard turbine, McCabe, Smith & Harriott 1993 pp. 242-243, after Rushton, Costich & Everett 1950; the Handbook of Industrial Mixing allows T/4 to T/2 | borrowed                                               | 0.45, where the pitched pair ran                                                                 |
| lower clearance   | T/3 (1 D, 70 mm)                                                                                 | McCabe 1993: E/T 1/3 for one turbine, and about one impeller diameter off the bottom for several (p. 241)                                                   | borrowed                                               | T/4, Rutherford et al.'s parallel flow                                                           |
| spacing           | T/3 (1 D, 70 mm)                                                                                 | Rutherford et al. 1996's merging flow, equal thirds at H = T, relayed by Li et al. 2007 Fig. 1; McCabe 1993 p. 253 asks at least one impeller diameter      | borrowed                                               | T/2, the parallel flow; 1.5-2 D                                                                  |
| impeller count    | 2 at H/T 1.09                                                                                    | the microalgae researcher advising the project; McCabe 1993 p. 241 keeps one impeller to a depth equal to or somewhat over T and adds more for deeper       | chosen to be standard; Rutherford's pairs ran at H = T | a single Rushton                                                                                 |
| baffles           | four at T/12 on the wall, T/72 off the glass, floor to surface: 1.00 of Oldshue's reference area | McCabe 1993 p. 240 and p. 243, four at T/12; the Handbook gives T/12 to T/10; the gap is Dynamix's J/6                                                      | borrowed                                               | T/10 blades; lid plates, which other builds hang                                                 |

**What the baseline costs.** The motor was chosen when the impeller was 94.5 mm, so that it could
reach both ends of the speed band that [Agitation](agitation.md#the-operating-point) derives from
Leupold et al. 2012. With the 70 mm impeller, its 320-420 rpm gives a tip speed of 1.17-1.54 m/s.
The _Chlorella_ optimum of 1.26 m/s falls at about 344 rpm, inside the band, and the 2.03 m/s
break-even is out of reach. That band rests on a stated assumption: that the rim speed of a
plate-and-skirt rig transfers to the tip speed of an impeller.

**Effect on jar_10L at the rated 320 rpm.** Power is 1.06 W, with 130 W/m^3 mean and 27.1 W/kg
peak. The impeller pair needs under 0.063 N-m of the 0.490 N-m rating. The gas holds at 0.5 vvm
down to 242 rpm.

**Other jars.** The standard layout is written for H = T. `jar_1gal_180x197`, at H/T 0.90, still
leaves 0.73 D above the upper impeller. `jar_1p5L_112x215` holds 0.5 vvm only above 399 rpm, and
the model echoes a warning for this.

---

## Not yet reconciled

- The baffle width: four at T/10, against the T/12 the model uses. The sources accept both.
- Rutherford et al. 1996 was read through Li et al. 2007 and its own abstract, not in full. The
  thresholds between its flow patterns are not claimed here.
- Rushton, Costich & Everett 1950 was read through McCabe, Smith & Harriott 1993, not directly.
- The pages cited from the Handbook of Industrial Mixing are taken from other sources, not
  checked against the text.
- The flow number: McCabe 1993 gives 1.3 for a standard flat-blade turbine (p. 245), where the
  model uses Grenville's typical value of 0.65. The circulation comparison with a pitched blade
  depends on it, and moves from about 1.8x in favour of the pitched blade to nearly even
  ([Agitation](agitation.md#impeller)).
