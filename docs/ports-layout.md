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

## One table does not serve the family

The layout above is a 143 mm mouth's layout. It does not fit the two narrow jars, and no amount of
rearranging makes it fit: two Ø16 Atlas probe bodies force a 13.6 mm flange, four baffles force four
more of them, and six flanges of that size do not go onto a Ø58 port circle in any order. That is
geometry, not tuning.

What sets the limit is the **worst adjacent pair**, not the port count:

```
2·Rpc·sin(180/n)  ≥  flange_r(i) + flange_r(i+1) + lid_holes_offset
```

Three consequences, all invisible while every port was the same size:

1. **Order matters.** The layout above puts a baffle beside a probe twice, so the binding pair is
   13.6 + 13.6 even though half the ports are 1.5–3 mm tubes.
2. **Big ports must be at most half the count**, or two are forced adjacent and every saving
   elsewhere is wasted.
3. **A middle size can be worse than a small one**, because what binds is the pair, not the port.

A flange is as big as it is because of its face seal, not its bore:

```
flange_r = (oring_ID + 2·cs)/2 + lip        oring_ID = 2·(lock_bore_r + land + cs/2)
```

That returns 23 mm for the standard interface, which is exactly the registered ring — so it is the
rule the design already used. Ø16 probe body, 2 mm collet wall each side, Ø20 opening, Ø23 ring,
13.6 mm flange. **Nothing in that chain has slack**, which is why every limit below traces back to
the two probes.

| interface | iface_r | flange_r | baffle width, 9 mm plate |
| --- | --- | --- | --- |
| std | 10 | 13.60 | 17.5 mm |
| midi | 7 | 10.60 | 10.3 mm |
| mini | 5 | 8.60 | 3.6 mm — useless |

Baffles cannot be small: the plate drops through the lock bore, so `width = 2·√(bore² − (t/2)²)`.

## The two port sets

| set | ports | functions | min mouth |
| --- | --- | --- | --- |
| **full** | 12 | 4 baffle, do_probe, ph_probe, temperature, air_in, air_out, media, acid, base | 130.4 mm |
| **reduced** | 6 | do_probe, ph_probe, temperature, air_in, air_out, media | 81.6 mm |

The reduced set keeps both probes, temperature, the gas path in and out, and one liquid line. It
drops the four baffles and the acid/base pair — pH control is what a narrow jar gives up, not
measurement. Which functions a given experiment wants is the operator's call; this is the default.

| vessel | mouth | full 12 | reduced 6 | assigned |
| --- | --- | --- | --- | --- |
| `jar_1p5L_109x215` | 87.5 | −11.11 | **+2.95** | reduced |
| `jar_1gal_155x251` | 95.8 | −8.96 | **+7.10** | reduced |
| `jar_6p5gal_305x470` | 137.0 | **+1.70** | +27.70 | full |
| `jar_10L_220x305` | 143.0 | **+3.25** | +30.70 | full |
| `jar_1gal_180x197` | 148.0 | **+4.55** | +33.20 | full |
| `generic` | 150.0 | **+5.07** | +34.20 | full |

Figures are millimetres of slack in the worst adjacent pair, against the 2 mm the lid keeps.

Two notes on the full set. It assumes the thermocouple moves off 1/2 NPT onto a midi flange — on
twelve ports that is the difference between seven big ports and six, and so between a 142 mm and a
130 mm smallest mouth, because seven of twelve forces two big ones adjacent. And it assumes the big
ports are **spread so no two touch**; that reordering alone is worth 19.3 mm of smallest mouth and
takes `jar_6p5gal` from failing to fitting. `jar_10L` today has 0.25 mm of slack and would have 3.25.

## Baffles on a narrow jar

The small jars are unbaffled, and an unbaffled vessel with a centred shaft swirls: Montante measured
a flow number of 0.25 for a centred unbaffled impeller, **65% below the same impeller baffled**.

Off-centring the shaft is the established fix and is well supported — Hall measured 45° PBTs in
60 and 88 mm vessels and found eccentric agitation indistinguishable from baffled at equal power, and
36% faster than unbaffled centred. **It is not available here.** Eccentricity is referenced to the
tank diameter while the room for it is set by the mouth, and the motor mount sits in that room:
Hall's e = 0.2 T wants 21.8 mm on `jar_1p5L`, where the best any lid can offer is 0.5 mm. See
`docs/references.md` for the numbers on every vessel.

So the narrow jars trade baffles for a real change of agitation, not for a shrug. That is the airlift
variant in `TODO.md`, and it is the same change that removes the motor mount — the part that blocks
the ports and the eccentricity both.
