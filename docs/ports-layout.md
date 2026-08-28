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

## What the air-out port also carries

The ring hangs on more than its feed. `sparge_support_functions` names the ports that carry a second
riser, and it names **`air_out`** — because it is the one tube port that BOTH layouts place 120° from
`air_in`, which is as far apart as either circle allows.

A support riser is the same tube in the same material as the feed, but its socket is **blind**. It
carries load and no gas, which is what lets it double as the exhaust: the tube is capped at the
bottom and does its job through a hole drilled higher up, above the culture line. The model is the
only thing that knows where that line is, so it dimensions the drill in an echo rather than leaving
a hand operation undimensioned — **38 to 87.9 mm from the tube's TOP end** on `jar_10L`, measured
from that end because it is the one you can reach with the tube in your hand, past the lid's inner
face and short of the liquid. Nearer the lid is better: the headspace is there for foam, and foam
finds the lowest hole. With no support named at all the model warns — the ring would then hang on
the feed riser alone.

The two sockets are told apart **on the part**, because you cannot see inside one at the bottom of
a jar: the feed's boss is a **hex** and a support's is round. Otherwise they are the same boss —
same bore, same height, same arm — and the difference is entirely internal. Sized across the flats,
so the wall is unchanged and only the corners are new material.

## The two gas ports are bored for a tube, and sealed around it

Every other tube port passes **flexible tubing**, which deforms into a printed bore and holds itself
there. The two gas ports pass a **rigid steel riser**, which does neither, and for a long time they
were bored as though they did not know the difference: `air_in` and `air_out` each carried a literal
bore radius of 3 — a hose radius on a port no hose enters, since the supply line pushes over the
riser's 15 mm proud end and is clamped there. So a 4 mm tube hung in a 6 mm hole with **2 mm of
slack**, neither located nor closed.

Both bores come off `sparge_riser_tube` now, at OD plus 0.2 mm, which is the same allowance the
bearing and shaft holes take. Slack **2 mm → 0.4**. That is a guide and nothing more: printed
plastic on ground steel leaks along the layer lines however close it is cut.

What closes it is a **rod gland** — the only one in the build, and the opposite of the face seals
every port already carries. A face seal is chosen by the gland it sits in; this one's **ID is the
tube**, 4 mm on the 4 mm riser, so it seats at zero stretch and `head()` checks the two registered
rows against `oring_stretch` rather than trusting them to agree. `8785N364`, one size down the
same catalogue page as the port seals, at 18 % radial squeeze — Apple Rubber's Table A gives
radial glands 14–23 % where a face gland takes 19–33 %.

It is a **counterbore at the lid's inner face**, not an enclosed groove, and that is forced rather
than chosen: a 4 × 1.5 ring is 7 mm across free and cannot be folded through a 4.4 mm bore to reach
a groove behind it. Which face it opens at is then the whole of the design, and both reasons point
the same way. The vessel is on that side, so headspace pressure drives the cord onto the shoulder
instead of out past it; and that face is the one on the bed when the pin half is printed, so nothing
bridges the bore.

**Why it is worth a purchased part.** A bioreactor normally filters the air on the way in *and* on
the way out, and this build only has the inlet filter. That is worth fixing — but an exhaust filter
does nothing at all while the lid has open holes beside it. Unsealed, each gas port was a
**15.7 mm² annulus** against the support tube's **7.07 mm² bore**, so about **82 %** of the exhaust
left by the gaps rather than by the vent; boring for the tube alone would still have left 43 %. A
0.2 µm sterile filter guarding a vessel that is open to the room is a filter on one of several
openings.

## The lid says which port is which

Checking whether a socket could be misplumbed found the real hazard one level up. Tube ports were
engraved with their **bore**, and this lid has pairs: `air_in` and `air_out` are both 3 mm, so both
read `O6`, and acid and base are both 2.4 mm and both read `O4.8`. The lid could not tell you which
port was the gas line — and dosing acid into the base line is the same mistake with worse
consequences.

Tube ports now carry their **function and their bore**: `AIR IN O4.4`, `ACID O4.8`. The gas ports
read 4.4 rather than the 6 above, because their bore is cut for the riser and not for a hose — see
the section before this one. The ring itself cannot be installed rotated: its two sockets are 120°
apart, and only one rotation puts both under tube ports; every other lands one on a baffle or a
probe.

## The probes lean, and only one of them

Probe ports carry a **radial** tilt — the port leans the probe within the plane its own axis lies
in, outward, away from the shaft. Two reasons it is not zero:

- **DO leans 4.5°.** A galvanic probe consumes the oxygen it reads, so Atlas ask for roughly
  60 mL/min across the membrane; leaning the tip out of the shaft's shadow and toward the wall puts
  it where the flow is. 4.5° is a bench limit rather than a derived one — past it the probe gets
  very hard to put through the port mouth
- **pH stays vertical, and that is not a concession.** Yokogawa ask for a pH sensor at least 15°
  above the horizontal to keep bubbles out of the glass bulb; hanging straight down clears that by
  75°. Which is fortunate, because the pH probe is the long one — the only thing on this lid that
  reaches the sparge ring's height, and at any lean at all it goes through the ring

Both angles are **per-build**, on the same footing as `culture_working_volume`: 4.5° is what
`jar_10L` allows, and `jar_1gal_180x197` is shorter, so its own ceiling is nearer 2.5°.
`check-vessels` sweeps the registry with both flat, because vertical clears every jar.

What checks this is `scad/utils/meridian.scad`. The vessel's obstructions are axisymmetric — an
impeller sweeps a cylinder, the ring is an annulus — and a port's tilt never leaves its meridian, so
"does a thing hanging from the lid clear a thing turning on the shaft?" collapses into the
(radius, height) half-plane exactly, arithmetic rather than solid modelling.

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

1. **Order matters, where there is a choice.** The layout above puts a baffle beside a probe twice,
   so the binding pair is 13.6 + 13.6 even though half the ports are 1.5–3 mm tubes. On this lid
   there is no choice — see the correction below — but on a lid with fewer baffles there is.
2. **Big ports must be at most half the count**, or two are forced adjacent and every saving
   elsewhere is wasted. Necessary, not sufficient: equally-spaced baffles can force the adjacency
   anyway.
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

**Corrected.** An earlier draft of this section put the full set's smallest mouth at 130.4 mm and the
reduced set's at 81.6, and claimed that spreading the big ports was worth 19.3 mm. All three were
wrong: they assumed the ports could be arranged freely. They cannot, and the reason is the baffles.

**Four baffles equally spaced on twelve ports sit every third port, which leaves no port that is not
adjacent to one.** A probe therefore *must* touch a baffle, both are std, and the worst pair is
13.6 + 13.6 whatever size the tubes are. Mixed port sizes do not move the twelve-port lid at all -
`jar_10L`'s binding gap is 2.254 mm before and after - and **spreading the big ports so no two touch
is not achievable at this port count and baffle spacing.** It is not a thing left to do; it is a
thing that does not exist.

Where mixed sizing does pay is the reduced set, which has no baffles at all. Six ports all on std
wants an 87.6 mm mouth; `jar_1p5L` has 87.5, and would miss by a tenth of a millimetre. With the
tubes on mini it wants 77.6 and clears by ten. **The smallest jar in the family is buildable because
of the mini interface and not otherwise.**

| set | ports | functions | worst pair | min mouth |
| --- | --- | --- | --- | --- |
| **full** | 12 | 4 baffle, do_probe, ph_probe, temperature, air_in, air_out, media, acid, base | std\|std 27.2 | 142.0 mm |
| **three-baffle** | 12 | as above with three baffles at 120° | std\|mini 22.2 | 122.7 mm |
| **reduced** | 6 | do_probe, ph_probe, temperature, air_in, air_out, media | std\|mini 22.2 | 77.6 mm |

Dropping to three baffles is what buys the middle row: with three, the ports two steps from each
baffle are free, so the probes can sit off them and the worst pair becomes std against mini. It costs
baffle area - the four-plate layout is already at 0.856 of Oldshue's reference, and three would be
0.64 - so it is a trade, not an improvement.

**Both sets are registered and the mouth picks between them** — `head_port_set_full` and
`head_port_set_reduced` in `head.scad`, chosen by `head_port_set_for()`, which asks whether the
flanges clear each other rather than being told. `head_ports` is the override: undef derives, and
setting it pins a table for an operator who wants a different function in a port.

| vessel | mouth | full 12 | 3-baffle 12 | reduced 6 | assigned |
| --- | --- | --- | --- | --- | --- |
| `jar_1p5L_109x215` | 87.5 | −14.11 | −9.11 | **+4.95** | reduced |
| `jar_1gal_155x251` | 95.8 | −11.96 | −6.96 | **+9.10** | reduced |
| `jar_6p5gal_305x470` | 137.0 | −1.30 | +3.70 | **+29.70** | reduced |
| `jar_10L_220x305` | 143.0 | **+0.25** | +5.25 | +32.70 | full |
| `jar_1gal_180x197` | 148.0 | **+1.55** | +6.55 | +35.20 | full |
| `generic` | 150.0 | **+2.07** | +7.07 | +36.20 | full |

Millimetres of slack in the worst adjacent pair, against the 2 mm the lid keeps.

`jar_6p5gal` takes the reduced set today and **builds** because of it. Its 137 mm mouth misses the
four-baffle set by 1.30 mm, so the alternative is the three-baffle row, which it would clear by 3.70.
That is a choice between a baffle and the full instrument set rather than a geometric dead end, and
it stays open: the three-baffle set is not registered, because dropping to three costs baffle area on
a layout already at 0.856 of the reference.

The reduced set keeps both probes, temperature, the gas path in and out, and one liquid line. It
drops the four baffles and the acid/base pair. What a narrow jar gives up is pH *control*, not pH
measurement. Which functions a given experiment wants is the operator's call; this is the default.

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
