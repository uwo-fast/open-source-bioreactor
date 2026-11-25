# Port layout

The twelve-port lid has twelve bayonet locks on one circle, 30 deg apart. On a jar whose mouth is
smaller than the 142 mm those need, the six-port lid has six, 60 deg apart. The locks are identical,
so the function of each port is defined entirely by `head_ports` in `scad/head.scad`. This document
explains how that table was derived; the table itself is the record.

[`ports_layout.drawio`](ports_layout.drawio) is a top-view sketch of the same port circle on the
plate lid, editable in draw.io.

## Why three baffles, and why they set everything else

**The wall cage frees the three plate ports.** A build that uses the wall cage carries no lid plates.
Both `jar_10L` builds use it: `jar_10L_220x305` names it, and `jar_10L_magnetic` gets it from
`baffle_name = "auto"`. The cage hoops are C-shaped, with the gap in the sector between the 0 and
90 deg blades, and every probe has to hang in that gap. `head_ports_walled()` therefore moves the pH
probe from 120 deg to the freed 30 deg port and puts blanks at 120, 150 and 270 deg. The rest of this
document describes the plate lid, which `jar_1gal_180x197` uses. `jar_1gal_155x251` uses the reduced
set, which has no baffles.

An equally spaced baffle count must divide the number of ports. With twelve ports that allows 2, 3,
4, 6 or 12 baffles, and `head()` asserts this instead of trusting the table.

**Three baffles at 120 deg is a deliberate departure, made to free a port.** Oldshue's reference is
four at 90 deg, and three plates that cannot be made wider fall short of his baffle area, so the
plate lid is under-baffled ([Agitation](agitation.md#baffles)). The port for the fourth plate went to
a sampling line. `head()` warns, and names four plates as the next count that spaces equally.

The three baffles occupy every fourth port, and the remaining nine form **three groups of three
adjacent ports, one group between each pair of baffles**. Going back to four baffles is not a matter
of converting one port to a baffle. Four equally spaced baffles do not coincide with three at
120 deg, so it would mean going back to the layout this one replaced (four baffles on every third
port, and one fewer tube port).

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

Every tube port is bored to dia 4.4 for the steel riser it carries, and the function of each port is
engraved on its flange. The three dosing ports are numbered, not named. The user chooses which one
carries acid, base, media or anything else, and any of them can be reassigned to another function.
They keep the numbers 1, 2 and 4 they were printed with. The turbidity sampler took the port that was
dose 3: at 330 deg the sampler collided with the coil condenser on `air_out` at 0 deg. At 300 deg its
syringe actuator also collided with the condenser, so the sampler moved opposite the condenser, to
180 deg, and dose 1 took 300 deg.

## Placement rules, and how this layout meets them

These rules reduce interference between sensing, aeration, dosing and exhaust, while keeping the
arrangement symmetric and easy to manufacture. Each is checked against the table above.

- **Air in as far as practical from the dissolved-oxygen probe**, so bubbles do not collect on or
  pass over the sensing surface. Air in is at 240 deg and DO at 60 deg: **180 deg apart, the maximum
  the circle allows**. The second priority is distance from pH, at 120 deg.
- **Air out separated from air in and the sparger sector**, and away from the area expected to splash
  and foam. Air out is at 0 deg, 120 deg from air in. The direction of impeller circulation is a
  secondary preference here, not a prediction.
- **Dosing lines grouped near air in and the mixing sector**, so a dose disperses quickly, and **away
  from the pH probe**, so a fresh dose does not bias the reading. Doses 1 and 4, at 300 and 330 deg,
  are 180 and 150 deg from pH, so they are the ones to use for acid and base. Dose 2, at 210 deg, is
  90 deg from pH. With the wall cage, pH moves to 30 deg and the order reverses: dose 2 is 180 deg
  from it, dose 1 is 90 deg and dose 4 is 60 deg, so doses 2 and 1 are the ones for acid and base.
- **Thermocouple next to the DO probe**, so the temperature used for DO compensation is measured in
  the same region of liquid. They are at 90 and 60 deg, on **adjacent** ports.
- **The remaining lines spread around the circle**, with clearance from the baffles, the probes, the
  other dosing lines and the shaft. The dosing lines are at 210, 300 and 330 deg, and doses 1 and 4
  are on adjacent ports. The two tall parts on the lid, the condenser at 0 deg and the sampler at
  180 deg, are opposite each other.

## What the air-in port carries

The **sparger** is not on the port circle, but it hangs from it. The port at 240 deg has the function
`air_in`, and the feed arm of the ring runs inward along that sector to a socket directly below the
port, so the riser is a straight tube with no bend.

The arm can run inward only because of this layout: 240 deg is **between** the baffles at 150 and
270 deg, so the whole radial band is clear there. That is the only reason a feed can cross from the
port circle out to a ring at 1.90 D without hitting a plate. If the air inlet were moved to a baffle
port, the arm would have no route, which is why `head()` asserts that the `air_in` port is a tube.

Nothing refers to index 8 directly. `head_sparge_feed_port()` looks up which port in the table is
`air_in`, wherever it currently is, so reordering the lid moves the sparger with it. The lookup
requires exactly one match, so a table with two air inlets, or none, fails loudly instead of silently
taking the first.

## What the other tube ports also carry

The ring is supported by more than its feed. **Every tube port except `air_in` drops a riser to
it**: four on the twelve-port lid, two on the six-port jars. The model derives this from the port
table instead of naming functions, so it works for any lid.

The tube stock makes these supports cost nothing extra. A support is cut to length at its socket
(253.01 mm on `jar_1gal_155x251`), and the tube is sold by the metre. On that jar the feed and two
supports total 752.9 mm, so they come from one 1000 mm length.

**Beside a loop or an arm, nothing rests on them.** The dosing ports carry the same tube, cut for
dosing rather than for support. Each is open at the height of the upper impeller centre, where the
impeller draws the dose straight in, and has no capped end below the hole to hold an old dose. On
`jar_10L` each is 187.9 mm long and ends 99.5 mm below the liquid surface. With the feed and the
sampler tube, the cut list totals 1029.9 mm, from a 2000 mm length. A magnetic build has no impeller
at that height but uses the same height, just as its arm already takes its height from the impellers
of a stirred build.

A support riser is the same tube, in the same material, as the feed, but its socket is **blind**. It
carries load but no gas, is capped at the bottom, and serves the function of its port through a hole
drilled higher up. The model dimensions the hole, and
[Building it](build.md#drilling-the-support-tubes) says how to drill it. Only the hole for `air_out`
has a required size, because it is the whole exhaust path, and only on builds with the ring. On every
other build the coil condenser takes that port.

The feed socket and the support sockets are distinguished **on the part**: the boss of the feed
socket is an **octagon** and the boss of a support socket is round. That is the only difference
([how to tell them apart](build.md#two-ways-to-assemble-it-wrong-that-nothing-will-catch)). Every
socket also has a 0.5 mm lead-in chamfer, to help push several rigid tubes into their sockets at
once.

## Every tube port is bored for a tube, and sealed around it

Every tube port passes a **rigid steel riser** and is bored to the OD of `sparge_riser_tube` plus
0.2 mm, the same allowance as the bearing and shaft holes. That bore is only a guide, because printed
plastic on ground steel leaks along the layer lines however closely it is cut. The soft tube of a gas
or dosing line pushes OVER the 14.94 mm of riser that stands proud of the lid and is clamped there,
instead of going into the port bore.

The seal is a **rod gland**. It is the only one in the build, and the opposite of the face seals that
every port already has. A face seal is sized by its gland, but the **ID of this seal is set by the
tube**: 4 mm on the 4 mm riser. It therefore seats at zero stretch, and `head()` checks the two
registered rows against `oring_stretch` instead of assuming they agree. The part is `8785N364`, one
size smaller on the same catalogue page as the port seals, at 18 % radial squeeze. Apple Rubber's
Table A gives 14-23 % for radial glands and 19-33 % for face glands.

The gland is an **enclosed groove just above the inner face of the lid**, behind a 1.2 mm lip. The
ring is folded and pushed up the bore past the lip, and is then captive. The groove is closed on the
vessel side because a groove open to the vessel would let an unseated ring fall into the culture.
Headspace pressure pushes the cord onto the upper shoulder; when there is no pressure, the lip holds
it.

**Why it justifies a purchased part.** An exhaust filter is useless while the lid has open holes next
to it. Without the seal, each port is a 2.64 mm^2 hole into the headspace, and a 0.2 um sterile
filter on a vessel open to the room filters only one of several openings.

## The lid says which port is which

Tube ports are engraved with their **function and bore**: `AIR IN Ø4.4`, `DOSE 2 Ø4.4`. Every tube
port is cut for the same riser, so the bore does not distinguish them; the function word does. Read
the word, not the number. A gas line on the wrong port vents into the headspace, and acid in the base
line is the same mistake with worse consequences. The ring is keyed so that it cannot be installed
rotated ([Building it](build.md#two-ways-to-assemble-it-wrong-that-nothing-will-catch)).

## The probes lean, and only one of them

Probe ports have a **radial** tilt: the port leans the probe outward, away from the shaft, in the
plane that contains the probe axis. The two probes are treated differently:

- **DO leans 4.5 deg.** A galvanic probe consumes the oxygen it measures, so Atlas specifies roughly
  60 mL/min of flow across the membrane. Leaning the tip out of the shadow of the shaft and toward the
  wall puts it in the flow. 4.5 deg is a limit found on the bench, not a derived one: beyond it, the
  probe is very hard to push through the port mouth.
- **pH stays vertical, and this is not a compromise.** Yokogawa specifies that a pH sensor be at
  least 15 deg above horizontal to keep bubbles out of the glass bulb, and hanging vertically clears
  that by 75 deg. This is fortunate, because the pH probe is the long one. It is the only part on
  this lid that reaches the height of the sparge ring, and at any lean it would pass through the ring.

Both angles are set **per build**, like `culture_fill_fraction`. 4.5 deg is the maximum for the DO
port (`do_probe_port_tilt_max`), and `head()` leans the probe as close to that as the internals of
each jar allow. On every registered build that tilts it, including `jar_1gal_180x197`, that is the
full 4.5 deg. The two airlifts hang it vertically inside the draft tube. `check-echo` sweeps the
registry with both probes vertical, because vertical clears every jar.

The check is in `scad/utils/meridian.scad`. The obstructions in the vessel are axisymmetric (an
impeller sweeps a cylinder, and the ring is an annulus), and a tilted port stays in its own meridian
plane. The question "does a part hanging from the lid clear a part turning on the shaft?" therefore
reduces exactly to the (radius, height) half-plane, and is answered with arithmetic instead of solid
modelling.

## One table does not serve the family

The layout above is for a 142.2 mm mouth. It does not fit the two narrow jars, and no rearrangement
makes it fit. Two dia 16 Atlas probe bodies require 14.1 mm flanges, three baffles require three more
of the same size, and six flanges of that size do not fit on a dia 58 port circle in any order. That
is a geometric limit, not a tuning problem.

The limit is set by the **worst adjacent pair**, not by the number of ports:

```
2*Rpc*sin(180/n)  >=  flange_r(i) + flange_r(i+1) + lid_flange_gap      (air between flanges)
2*Rpc*sin(180/n)  >=  hole_r(i)   + hole_r(i+1)   + lid_holes_offset   (lid wall between bores)
```

Three consequences:

1. **Order matters, where there is a choice.** The layout above puts a baffle next to a probe twice,
   so the limiting pair is 14.1 + 14.1, even though half the ports are 1.5-3 mm tubes. On this lid
   there is no choice (see below), but on a lid with fewer baffles there is.
2. **Large ports must be no more than half the total**, otherwise two are forced to be adjacent and
   any saving elsewhere is wasted. This is necessary but not sufficient: equally spaced baffles can
   force the adjacency anyway.
3. **A medium size can be worse than a small one**, because the limit is set by the pair, not by the
   individual port.

The size of a flange is set by its face seal, not by its bore:

```
flange_r = (oring_ID + 2*cs + fit)/2 + lip  oring_ID = 2*(lock_bore_r + land + cs/2)
```

That gives 23 mm for the standard interface, which is exactly the registered ring, so it is the rule
the design was already using. The chain is: dia 16 probe body, 2 mm collet wall on each side, dia 20
opening, dia 23 ring, 14.1 mm flange. **Nothing in that chain has slack**, which is why every limit
below comes back to the two probes. `fit` is the 0.2 mm the groove needs to RECEIVE a moulded ring,
not only to seal it: a printed 23x1.5 does not go into a groove cut to its own 26.00 mm OD.

| interface | iface_r | flange_r | baffle width, 10 mm plate                      |
| --------- | ------- | -------- | ---------------------------------------------- |
| std       | 10      | 14.10    | 17.09 mm                                       |
| midi      | 7       | 11.30    | 9.51 mm                                        |
| mini      | 5       | 9.30     | will not pass - a 10 mm plate in a 9.8 mm bore |

Baffles cannot be made small, because the plate drops through the lock bore, so
`width = 2*sqrt(bore^2 - (t/2)^2)`.

## The two port sets

**The ports cannot be arranged freely, because of the baffles.**

**This layout puts each probe next to a baffle.** Both are std, so the worst pair is 14.1 + 14.1
whatever size the tubes are. Mixed port sizes make no difference on the twelve-port lid: the limiting
gap on `jar_10L` is 1.0466 mm either way. With three baffles, the middle port of each group of three
is not next to a baffle, but a probe there cannot sit opposite the air inlet, because that position
is a baffle. The layout keeps DO opposite air in, and pays for it with mouth diameter it does not
otherwise need.

**So the model does not pay for a benefit it does not get.** `head_ports_uniform()` checks whether a
lid can use std on every port, and `head_interface_for()` assigns std to every port where it can. On
`jar_10L` this costs nothing, to the millimetre (every figure `head()` reports is byte-identical either
way), and it gives a lid where any port can take any function and one face o-ring fits all twelve.
All five registered vessels come out uniform.

Mixed sizing would help in the reduced set, which has no baffles. Six ports all on std need an
87.6 mm mouth. `jar_1p5L` has 88.4 mm and clears it by 0.8 mm, which the model measures as a 1.4 mm
worst pair against a 1.0 mm minimum. With the tubes on mini, the set needs 78.0 mm. **No registered
jar needs the mini interface today**: it is for a mouth between 78.0 and 87.6 mm. `head()` reports
both minimums on every render.

The cost of the uniform lid is in CLEANING, not packing. On the mixed twelve-port lid, four gaps are
1.0466 mm and eight are 5.85 or 10.65 mm; the uniform lid makes all twelve 1.0466 mm. That does not
create the problem, because the four narrow gaps were always there, but it extends the problem from
one part of the lid to the whole lid. The lid is also where growth accumulates. Photos of past
cultures show buildup high in the culture, in the headspace and on the lid, and almost none low down
on the sparger and probes. Whether a cloth fits through 1.0466 mm has not been tested.

| set         | ports | functions                                                                                   | worst pair | min mouth |
| ----------- | ----- | ------------------------------------------------------------------------------------------- | ---------- | --------- |
| **full**    | 12    | 3 baffle, do_probe, ph_probe, temperature, air_in, air_out, dose_1, dose_2, dose_4, sampler | std\|std   | 142.0 mm  |
| **reduced** | 6     | do_probe, ph_probe, temperature, air_in, air_out, dose_1                                    | std\|mini  | 78.0 mm   |

A three-baffle set with the probes two ports away from each baffle would make the worst pair std
against mini, about 20 mm of mouth. The registered set does not do this, because it keeps DO opposite
air in, so its minimum mouth is the 142.0 mm of the full set.

**Both sets are registered, and the mouth selects between them.** They are `head_port_set_full` and
`head_port_set_reduced` in `head.scad`, selected by `head_port_set_for()`, which checks whether the
flanges clear each other instead of being told. `head_ports` is the override: undef derives the
table, and setting it pins a table for an operator who wants a different function in a port.

| vessel               | mouth | full 12   | reduced 6 | assigned |
| -------------------- | ----- | --------- | --------- | -------- |
| `jar_1p5L_112x215`   | 88.4  | -13.88    | **+5.20** | reduced  |
| `jar_1gal_155x251`   | 95.8  | -11.96    | **+8.90** | reduced  |
| `jar_6p5gal_305x470` | 137.0 | -1.30     | **+29.5** | reduced  |
| `jar_10L_220x305`    | 142.2 | **+0.05** | +32.1     | full     |
| `jar_1gal_180x197`   | 148.0 | **+1.55** | +35.0     | full     |

Values are millimetres of slack in the worst adjacent pair, against the 1 mm of air the lid keeps
between two flanges (`lid_flange_gap`). `head()` reports the value for the assigned set on every
render.

`jar_6p5gal` uses the reduced set today and **builds** because of it. Its 137 mm mouth is 1.30 mm too
small for the full set. A three-baffle set with its probes away from the baffles would clear the
flanges, but the vessel would then fail on its impeller, which leaves no room for a baffle
([Agitation](agitation.md#5-agitation-mode-per-vessel)).

The reduced set keeps both probes, temperature, gas in and out, and one liquid line. It drops the
three baffles and three of the four dosing lines. A narrow jar therefore loses pH _control_, which
needs an acid line and a base line, but keeps pH measurement. The operator decides which functions an
experiment needs; this is the default.

**Its tubes and instruments alternate** (DO, air_out, temperature, air_in, pH, dose_1), so the three
tubes that support the sparge ring are 120 deg apart instead of all on one side. On a mixed lid every
adjacent pair is then a std flange next to a mini, which was already the worst pair, so the 78.0 mm
minimum does not change. The other placement rules still hold: DO stays opposite the air inlet, and
the thermocouple sits one port away from DO rather than next to it.

## Baffles on a narrow jar

**The limit is about 98 mm, and it does not depend on the registered sets.** Sweeping the port
count, instead of using the registered twelve, shows that four baffles cannot fit beside two dia 16
Atlas probes below a mouth of roughly 98 mm at _any_ count. The two probes are the widest pair on the
circle, and four baffles must be equally spaced around them. The registered full set is above that
anyway, at 142.0 mm, so nothing in the model computes 98. It is the limit the search reached, and it
is why the small jars are unbaffled regardless of other decisions, not waiting for a better layout.

The small jars are unbaffled, and an unbaffled vessel with a centred shaft swirls. Montante measured
a flow number of 0.25 for a centred impeller without baffles, **65% lower than the same impeller with
baffles**.

Mounting the shaft off-centre is the established fix and is well supported. Hall measured 45 deg
PBTs in 60 and 88 mm vessels and found eccentric agitation indistinguishable from baffled agitation at
equal power, and 36% faster than unbaffled centred agitation. **It is not available here.**
Eccentricity is defined relative to the tank diameter, but the space for it is limited by the mouth,
and the motor mount occupies that space. Hall's e = 0.2 T requires 20.7 mm on `jar_1p5L`, where the
most any lid can offer is 0.95 mm. See [Agitation](agitation.md#eccentric-mounting) for the numbers
for every vessel, and for why T is the bore.

The narrow jars therefore replace baffles with a different form of agitation: the airlift
([Agitation](agitation.md#5-agitation-mode-per-vessel)). The same change removes the motor mount,
which is the part that blocks both the ports and the eccentric position.
