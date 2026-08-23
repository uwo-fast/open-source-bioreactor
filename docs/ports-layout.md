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

## What the air-in port now carries

The **sparger** is not on this circle, but it hangs from it. The port at 240° carries the function
`air_in`, and the ring's feed arm runs inboard along that sector to a socket directly beneath it, so
the riser is a straight tube with no bend.

That the arm can run inboard at all is a property of this layout: 240° sits **between** the baffles
at 210° and 300°, so the whole radial band is clear there. It is the only reason a feed can cross
from the port circle out to a ring at 1.44 D without fouling a plate. Move the air inlet to a baffle
port and the arm has nowhere to go — which is why `head()` asserts the `air_in` port is a tube.

Nothing names the index 8. `head_sparge_feed_port()` asks the table which port is `air_in` and gets
back wherever it currently sits, so reordering the lid carries the sparger with it. The lookup
insists on exactly one match, so a table with two air inlets or none fails loudly rather than
silently taking the first.
