# Port layout

The lid carries twelve bayonet locks on one circle, 30 deg apart. They are identical, so what a port
_is_ comes entirely from `head_ports` in `scad/head.scad` - this document is the derivation behind
that table, and the table is the statement of record.

[`ports_layout.drawio`](ports_layout.drawio) is the sketch of the same circle on the plate lid,
seen from above, editable in draw.io.

## Why three baffles, and why they set everything else

**Under the wall cage the plates' three ports are freed.** A build on the wall cage (both
`jar_10L` builds: `jar_10L_220x305` names it, and `baffle_name = "auto"` takes it on
`jar_10L_magnetic`) carries no lid plates. Its hoops are Cs whose gap is the
sector between the 0 and 90 deg blades, and every probe has to hang there, so `head_ports_walled()`
moves the pH probe from 120 deg to the freed 30 deg port and puts blanks at 120, 150 and 270 deg. What
follows describes the plate lid, which `jar_1gal_180x197` carries; `jar_1gal_155x251` takes the
reduced set, which has no baffles.

An equally spaced count has to divide the port circle. On twelve ports that allows 2, 3, 4, 6 or
12 baffles, and `head()` asserts it rather than trusting the table.

**Three at 120 deg is a departure, taken for a port.** Four at 90 deg is Oldshue's reference, and three
plates that cannot widen fall short of his area, so the plate lid is under-baffled
([Agitation](agitation.md#baffles)); the fourth plate's port went to a sampling line. `head()` warns,
and names four plates as the next count that spaces equally.

Three baffles sit every fourth port, and the remaining nine fall into **three adjacent triples,
one between each pair of baffles**. Going back to four is not a matter of turning one port into a
baffle: four equally spaced do not land on three-at-120 deg, so it means the whole layout this one
replaced (four baffles every third port, and one tube port fewer).

## The layout

| #   | angle   | port         | function         |
| --- | ------- | ------------ | ---------------- |
| 0   | 0 deg   | tube dia 4.4 | air out          |
| 1   | 30 deg  | **baffle**   |                  |
| 2   | 60 deg  | probe        | dissolved oxygen |
| 3   | 90 deg  | thermocouple | temperature      |
| 4   | 120 deg | probe        | pH               |
| 5   | 150 deg | **baffle**   |                  |
| 6   | 180 deg | sampler      | turbidity        |
| 7   | 210 deg | tube dia 4.4 | dose 2           |
| 8   | 240 deg | tube dia 4.4 | air in           |
| 9   | 270 deg | **baffle**   |                  |
| 10  | 300 deg | tube dia 4.4 | dose 1           |
| 11  | 330 deg | tube dia 4.4 | dose 4           |

Every tube port is bored dia 4.4 for the steel riser it carries; what a port is for is engraved on
its flange. The three dosing ports are numbered, not named: which carries acid, base, media or
anything else is the user's to choose, and any of them can be given to another function. They
keep the numbers 1, 2 and 4 they were printed with: the turbidity sampler took dose 3's port,
because at 330 deg it stood in the coil condenser on `air_out` at 0 deg. At 300 deg its syringe
actuator stood in the condenser too, so it moved opposite it, to 180 deg, and dose 1 took 300 deg.

## The heuristics, and where this layout lands against them

These reduce interference between sensing, aeration, dosing and exhaust while keeping the
arrangement symmetric and manufacturable. Each is checked against the table above.

- **Air in as far as practical from the dissolved-oxygen probe**, so bubbles do not collect on or
  pass over the sensing surface. Air in at 240 deg, DO at 60 deg - **180 deg, the maximum the circle
  allows**. Secondarily from pH, at 120 deg.
- **Air out separated from air in and the sparger sector**, and away from the expected splash and
  foam region. Air out at 0 deg, 120 deg from air in. Impeller circulation direction is a secondary
  preference here, not a prediction.
- **Dosing lines grouped near air in and the mixing sector**, so dosed solution disperses quickly,
  and **away from the pH probe** so a fresh dose does not bias it. Doses 1 and 4, at 300 deg and 330 deg,
  sit 180 deg and 150 deg from pH, so they are the ones for acid and base. Dose 2, at 210 deg, is 90 deg
  from pH. Under the wall cage pH moves to 30 deg, and the order turns over: dose 2 is 180 deg from
  it, dose 1 90 deg and dose 4 60 deg, so there doses 2 and 1 are the ones for acid and base.
- **Thermocouple adjacent to the DO probe**, so the temperature used for DO compensation comes from
  the same region of liquid. They are at 90 deg and 60 deg - **adjacent**.
- **The other lines distributed through the space** with clearance from baffles, probes, the
  other dosing lines, and the shaft. The dosing lines are at 210, 300 and 330 deg; doses 1 and 4 are
  on adjacent ports. The tall things that stand on the lid, the condenser at 0 deg and the sampler at 180 deg, are
  opposite each other.

## What the air-in port carries

The **sparger** is not on this circle, but it hangs from it. The port at 240 deg carries the function
`air_in`, and the ring's feed arm runs inboard along that sector to a socket directly beneath it, so
the riser is a straight tube with no bend.

That the arm can run inboard at all is a property of this layout: 240 deg sits **between** the baffles
at 150 deg and 270 deg, so the whole radial band is clear there. It is the only reason a feed can cross
from the port circle out to a ring at 1.90 D without fouling a plate. Move the air inlet to a baffle
port and the arm has nowhere to go - which is why `head()` asserts the `air_in` port is a tube.

Nothing names the index 8. `head_sparge_feed_port()` asks the table which port is `air_in` and gets
back wherever it currently sits, so reordering the lid carries the sparger with it. The lookup
insists on exactly one match, so a table with two air inlets or none fails loudly rather than
silently taking the first.

## What the other tube ports also carry

The ring hangs on more than its feed. **Every tube port but `air_in` drops a riser to it** - four on
the twelve-port lid, two on the six-port jars - and the model derives that from the port table rather
than naming functions, so any lid answers it.

The stock is what makes it free: a support is cut to its socket, 253.01 mm on `jar_1gal_155x251`,
and this tube is sold by the metre. That jar's feed and two supports come to 752.9 mm, so they take a
1000 mm length.

**Beside a loop or an arm, nothing rests on them.** The dosing ports carry the same tube, cut to dose
rather than to hold: open at the upper impeller's centre, where the impeller draws the dose straight
in, with no capped end below the hole to keep an old dose. On `jar_10L` each is 187.9 mm and ends
99.5 mm under the surface; with the feed and the sampler's tube the cut list is 1029.9 mm, from a
2000 mm length. A magnetic build has no impeller there and takes the same height, as its arm already
takes its own from the impellers a stirred build turns.

A support riser is the same tube in the same material as the feed, but its socket is **blind**: it
carries load and no gas, is capped at the bottom, and does its port's job through a hole drilled
higher up, which the model dimensions and [Building it](build.md#drilling-the-support-tubes) says how
to drill. Only `air_out`'s hole has a size to meet, being the whole exhaust path, and only on the
ring's builds; everywhere else the coil condenser takes that port.

The feed socket is told apart from the supports **on the part**: the feed's boss is an **octagon**
and a support's is round, and that is the only difference
([how to tell them apart](build.md#two-ways-to-assemble-it-wrong-that-nothing-will-catch)). Every
socket also carries a 0.5 mm lead-in chamfer, for getting several rigid tubes into their sockets at
once.

## Every tube port is bored for a tube, and sealed around it

Every tube port passes a **rigid steel riser** and is bored off `sparge_riser_tube` at OD plus
0.2 mm, the same allowance the bearing and shaft holes take; that is a guide and nothing more,
since printed plastic on ground steel leaks along the layer lines however close it is cut. The soft
tube of a gas or dosing line pushes OVER the riser's 14.94 mm proud end and is clamped there,
rather than into the port's own bore.

What closes it is a **rod gland** - the only one in the build, and the opposite of the face seals
every port already carries. A face seal is chosen by the gland it sits in; this one's **ID is the
tube**, 4 mm on the 4 mm riser, so it seats at zero stretch and `head()` checks the two registered
rows against `oring_stretch` rather than trusting them to agree. `8785N364`, one size down the
same catalogue page as the port seals, at 18 % radial squeeze - Apple Rubber's Table A gives
radial glands 14-23 % where a face gland takes 19-33 %.

It is an **enclosed groove just above the lid's inner face**, behind a 1.2 mm lip: the ring is
folded and pushed up the bore past the lip, and is captive after that: the vessel is on that side,
so a groove open to it would let an unseated ring drop into the culture. Headspace pressure drives
the cord onto the upper shoulder; the lip is what holds it when there is none.

**Why it is worth a purchased part.** An exhaust filter does nothing while the lid has open holes
beside it: without the seal each port is a 2.64 mm^2 hole into the headspace, and a 0.2 um sterile
filter guarding a vessel open to the room is a filter on one of several openings.

## The lid says which port is which

Tube ports carry their **function and their bore**: `AIR IN Ø4.4`, `DOSE 2 Ø4.4`. Every one is cut
for the same riser, so the bore distinguishes nothing and the function word carries it: read the
word, not the number. A gas line on the wrong port vents into the headspace, and acid in the base
line is the same mistake with worse consequences. The ring is keyed so it cannot be installed
rotated ([Building it](build.md#two-ways-to-assemble-it-wrong-that-nothing-will-catch)).

## The probes lean, and only one of them

Probe ports carry a **radial** tilt - the port leans the probe within the plane its own axis lies
in, outward, away from the shaft. Two reasons it is not zero:

- **DO leans 4.5 deg.** A galvanic probe consumes the oxygen it reads, so Atlas ask for roughly
  60 mL/min across the membrane; leaning the tip out of the shaft's shadow and toward the wall puts
  it where the flow is. 4.5 deg is a bench limit rather than a derived one - past it the probe gets
  very hard to put through the port mouth
- **pH stays vertical, and that is not a concession.** Yokogawa ask for a pH sensor at least 15 deg
  above the horizontal to keep bubbles out of the glass bulb; hanging straight down clears that by
  75 deg. Which is fortunate, because the pH probe is the long one - the only thing on this lid that
  reaches the sparge ring's height, and at any lean at all it goes through the ring

Both angles are **per-build**, on the same footing as `culture_fill_fraction`: 4.5 deg is what
`jar_10L` allows, and `jar_1gal_180x197` is shorter, so its own ceiling is nearer 2.5 deg.
`check-echo` sweeps the registry with both flat, because vertical clears every jar.

What checks this is `scad/utils/meridian.scad`. The vessel's obstructions are axisymmetric - an
impeller sweeps a cylinder, the ring is an annulus - and a port's tilt never leaves its meridian, so
"does a thing hanging from the lid clear a thing turning on the shaft?" collapses into the
(radius, height) half-plane exactly, arithmetic rather than solid modelling.

## One table does not serve the family

The layout above is a 142.2 mm mouth's layout. It does not fit the two narrow jars, and no amount of
rearranging makes it fit: two dia 16 Atlas probe bodies force a 14.1 mm flange, three baffles force three
more of them, and six flanges of that size do not go onto a dia 58 port circle in any order. That is
geometry, not tuning.

What sets the limit is the **worst adjacent pair**, not the port count:

```
2*Rpc*sin(180/n)  >=  flange_r(i) + flange_r(i+1) + lid_flange_gap      (air between flanges)
2*Rpc*sin(180/n)  >=  hole_r(i)   + hole_r(i+1)   + lid_holes_offset   (lid wall between bores)
```

Three consequences:

1. **Order matters, where there is a choice.** The layout above puts a baffle beside a probe twice,
   so the binding pair is 14.1 + 14.1 even though half the ports are 1.5-3 mm tubes. On this lid
   there is no choice - see below - but on a lid with fewer baffles there is.
2. **Big ports must be at most half the count**, or two are forced adjacent and every saving
   elsewhere is wasted. Necessary, not sufficient: equally-spaced baffles can force the adjacency
   anyway.
3. **A middle size can be worse than a small one**, because what binds is the pair, not the port.

A flange is as big as it is because of its face seal, not its bore:

```
flange_r = (oring_ID + 2*cs + fit)/2 + lip  oring_ID = 2*(lock_bore_r + land + cs/2)
```

That returns 23 mm for the standard interface, which is exactly the registered ring - so it is the
rule the design already used. dia 16 probe body, 2 mm collet wall each side, dia 20 opening, dia 23 ring,
14.1 mm flange. **Nothing in that chain has slack**, which is why every limit below traces back to
the two probes. `fit` is the 0.2 mm the groove needs to RECEIVE a moulded ring rather than only seal
it: a printed 23x1.5 does not go into a groove cut to its own 26.00 mm OD.

| interface | iface_r | flange_r | baffle width, 10 mm plate                      |
| --------- | ------- | -------- | ---------------------------------------------- |
| std       | 10      | 14.10    | 17.09 mm                                       |
| midi      | 7       | 11.30    | 9.51 mm                                        |
| mini      | 5       | 9.30     | will not pass - a 10 mm plate in a 9.8 mm bore |

Baffles cannot be small: the plate drops through the lock bore, so `width = 2*sqrt(bore^2 - (t/2)^2)`.

## The two port sets

**The ports cannot be arranged freely, and the reason is the baffles.**

**This layout puts each probe beside a baffle,** both are std, and the worst pair is 14.1 + 14.1
whatever size the tubes are. Mixed port sizes do not move the twelve-port lid at all - `jar_10L`'s
binding gap is 1.0466 mm either way. Three baffles leave the middle port of each triple free of
them, but a probe there cannot sit opposite the air inlet, which lands on a baffle; the layout keeps
DO opposite air in and pays for it in mouth it does not need.

**So the model stops paying for what it does not get.** `head_ports_uniform()` asks whether a lid can
carry std on every port, and `head_interface_for()` gives it std throughout where the answer is yes.
On `jar_10L` that is free to the millimetre - every figure `head()` reports is byte-identical either
way - and it buys a lid where any port takes any function and one face o-ring covers all twelve.
All five registered vessels come out uniform.

Where mixed sizing would pay is the reduced set, which has no baffles at all. Six ports all on std
wants an 87.6 mm mouth; `jar_1p5L` has 88.4 and clears it by 0.8, which the model measures as a
1.4 mm worst pair against a 1.0 mm floor. With the tubes on mini the set wants 78.0. **No
registered jar needs the mini interface today**: it is what a mouth between 78.0 and 87.6 would
take. `head()` reports both floors on every render.

What the uniform lid costs is not packing but CLEANING. On the mixed twelve-port lid four gaps are
1.0466 mm and eight are 5.85 or 10.65; uniform makes all twelve 1.0466. That does not create the
problem - the four tight gaps were always there - but it does make it the whole lid's rather than a
corner of it. And the lid is where the growth goes. In photos of past cultures the buildup is high
in the culture, in the headspace and on the lid, with almost none low down on the sparger and
probes. Whether a cloth goes through 1.0466 mm is untested.

| set         | ports | functions                                                                                   | worst pair | min mouth |
| ----------- | ----- | ------------------------------------------------------------------------------------------- | ---------- | --------- |
| **full**    | 12    | 3 baffle, do_probe, ph_probe, temperature, air_in, air_out, dose_1, dose_2, dose_4, sampler | std\|std   | 142.0 mm  |
| **reduced** | 6     | do_probe, ph_probe, temperature, air_in, air_out, dose_1                                    | std\|mini  | 78.0 mm   |

A three-baffle set with the probes two steps from each baffle makes the worst pair std against
mini, about 20 mm of mouth. The registered set does not do that, because it keeps DO opposite air
in, so its smallest mouth is the full set's 142.0 mm.

**Both sets are registered and the mouth picks between them** - `head_port_set_full` and
`head_port_set_reduced` in `head.scad`, chosen by `head_port_set_for()`, which asks whether the
flanges clear each other rather than being told. `head_ports` is the override: undef derives, and
setting it pins a table for an operator who wants a different function in a port.

| vessel               | mouth | full 12   | reduced 6 | assigned |
| -------------------- | ----- | --------- | --------- | -------- |
| `jar_1p5L_112x215`   | 88.4  | -13.88    | **+5.20** | reduced  |
| `jar_1gal_155x251`   | 95.8  | -11.96    | **+8.90** | reduced  |
| `jar_6p5gal_305x470` | 137.0 | -1.30     | **+29.5** | reduced  |
| `jar_10L_220x305`    | 142.2 | **+0.05** | +32.1     | full     |
| `jar_1gal_180x197`   | 148.0 | **+1.55** | +35.0     | full     |

Millimetres of slack in the worst adjacent pair, against the 1 mm of air the lid keeps between two
flanges (`lid_flange_gap`); `head()` reports the assigned set's on every render.

`jar_6p5gal` takes the reduced set today and **builds** because of it. Its 137 mm mouth misses the
full set by 1.30 mm. A three-baffle set with its probes off the baffles would clear the flanges, and
the vessel then fails on its impeller, which leaves no room for a baffle
([Agitation](agitation.md#5-agitation-mode-per-vessel)).

The reduced set keeps both probes, temperature, the gas path in and out, and one liquid line. It
drops the three baffles and three of the four dosing lines. What a narrow jar gives up is pH
_control_, which wants an acid and a base line, not pH measurement. Which functions a given
experiment wants is the operator's call; this is the default.

**Its tubes and instruments alternate** - DO, air_out, temperature, air_in, pH, dose_1 - so the
three tubes the sparge ring hangs from stand 120 deg apart rather than on one side of it. On a mixed
lid every adjacent pair is then a std flange beside a mini, the worst pair it already had, so the
78.0 mm floor is where it was. The other
placement rules fit inside that: DO stays opposite the air inlet, and the thermocouple sits one
port from DO rather than beside it.

## Baffles on a narrow jar

**The floor is about 98 mm, and it is not a property of the registered sets.** Sweeping port count
rather than taking the registered twelve, four baffles cannot sit beside two dia 16 Atlas probes below
roughly a 98 mm mouth at _any_ count - the two probes are the widest pair on the circle and four
baffles must space equally around them. The registered full set lands above that anyway at
142.0 mm, so nothing in the model computes 98; it is the bound the search ran into, and
it is why the small jars are unbaffled whatever else is decided rather than pending a cleverer
layout.

The small jars are unbaffled, and an unbaffled vessel with a centred shaft swirls: Montante measured
a flow number of 0.25 for a centred unbaffled impeller, **65% below the same impeller baffled**.

Off-centring the shaft is the established fix and is well supported - Hall measured 45 deg PBTs in
60 and 88 mm vessels and found eccentric agitation indistinguishable from baffled at equal power, and
36% faster than unbaffled centred. **It is not available here.** Eccentricity is referenced to the
tank diameter while the room for it is set by the mouth, and the motor mount sits in that room:
Hall's e = 0.2 T wants 20.7 mm on `jar_1p5L`, where the best any lid can offer is 0.95 mm. See
[Agitation](agitation.md#eccentric-mounting) for the numbers on every
vessel, and for why T is the bore.

So the narrow jars trade baffles for a real change of agitation: the airlift
([Agitation](agitation.md#5-agitation-mode-per-vessel)), the same change that removes the motor
mount - the part that blocks the ports and the eccentricity both.
