# Port layout

The lid carries twelve bayonet locks on one circle, 30° apart. They are identical, so what a port
*is* comes entirely from `head_ports` in `scad/head.scad` — this document is the derivation behind
that table, and the table is the statement of record.

## Why four baffles, and why they set everything else

An equally spaced count has to divide the port circle. On twelve ports that allows 2, 3, 4, 6 or
12 baffles, and `head()` asserts it rather than trusting the table. Four at 90° is Oldshue's
reference case (1997 p. 202), so the count is no longer a departure to explain.

Four baffles must sit every third port. That is not a free choice, and it has one useful
consequence: the remaining eight ports fall into **four adjacent pairs, one between each baffle**.
The functional grouping below is built on those pairs rather than assigned port by port.

Going from three baffles to four costs one port, and the one dropped is a 1.5 mm tube — the
smaller of the two media/spare lines, and the least committed function on the lid.

## The layout

| # | angle | port | function |
| --- | --- | --- | --- |
| 0 | 0° | tube 3 mm | air out |
| 1 | 30° | **baffle** | |
| 2 | 60° | probe | dissolved oxygen |
| 3 | 90° | thermocouple | temperature |
| 4 | 120° | **baffle** | |
| 5 | 150° | probe | pH |
| 6 | 180° | tube 1.5 mm | media / spare |
| 7 | 210° | **baffle** | |
| 8 | 240° | tube 3 mm | air in |
| 9 | 270° | tube 2.4 mm | acid |
| 10 | 300° | **baffle** | |
| 11 | 330° | tube 2.4 mm | base |

## The heuristics, and where this layout lands against them

These reduce interference between sensing, aeration, dosing and exhaust while keeping the
arrangement symmetric and manufacturable. Each is checked against the table above.

- **Air in as far as practical from the dissolved-oxygen probe**, so bubbles do not collect on or
  pass over the sensing surface. Air in at 240°, DO at 60° — **180°, the maximum the circle
  allows**. Secondarily from pH, at 90°.
- **Air out separated from air in and the sparger sector**, and away from the expected splash and
  foam region. Air out at 0°, 120° from air in. Impeller circulation direction is a secondary
  preference here, not a prediction.
- **Acid and base grouped near air in and the mixing sector**, so dosed solution disperses quickly,
  and **away from the pH probe** so fresh acid or base does not bias it. Acid at 270° and base at
  330° sit 30° and 90° from air in; they are 120° and 180° from pH.
- **Thermocouple adjacent to the DO probe**, so the temperature used for DO compensation comes from
  the same region of liquid. They are at 90° and 60° — **adjacent**. The three-baffle layout this
  replaced put the pH probe between them, 60° apart, which did not meet this rule.
- **Remaining media and spare ports distributed through the space** with clearance from baffles,
  probes, dosing, and the shaft. One 1.5 mm line at 180°.

## What is not settled here

The **sparger** is not on this circle. It enters through the air-in port at 240°, but where its
ring sits in the vessel — and whether gas belongs below the lower impeller or in the gap between
the pair — is open; see `docs/agitation.md`.
