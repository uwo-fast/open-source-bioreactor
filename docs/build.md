# Building it

What you do with tools in your hands. The other documents say why the reactor is the shape it is;
this one says what to cut, what to print, in what order to put it together, and which numbers will
break something if you get them wrong.

**Numbers here come from one of three places, and it is worth knowing which.** Most are quoted from
the model's own echoes, and those are the authority — this document repeats them for the reference
build, `jar_10L_220x305`, the vessel the registry selects. Build a different jar and they move,
sometimes a lot: render `scad/assembly.scad` and read yours back. Some come from the notes on
[`purchased-parts.csv`](../purchased-parts.csv), which is where a bought part's tolerances live. A
few are worked out here, from the two — the torque band and the stiffness of the bolted stack are
the only ones that matter — and each of those says so where it appears.

---

## Nothing here has been built yet

This reactor has not been printed or assembled. Every number below is derived from the model, and
the model has never been contradicted by a part in someone's hand. That is a real limitation and it
is worth stating plainly rather than burying: a first build should expect to correct this document.

Three figures in particular are bands rather than measurements, and all three are on
[`TODO.md`](../TODO.md) waiting for a bench:

- the **sterile filter's pressure drop**, extrapolated from a comparable disc, and the largest single
  term in the gas budget
- the **jar's rim profile**, which everything sealing is measured against and which no one has
  calipered
- the **baffle's lean under load**, reported as a worst case that the model itself says is a worst
  case

Two of the six registered vessels do not build at all. Neither `jar_1p5L_109x215` nor
`jar_1gal_155x251` can carry a top-entry drive on its lid at any mount size, and the second fails
earlier still — a vertical DO probe runs through the upper impeller, because in a 155 mm bore the
port circle and the impeller want the same radius. `just check-vessels` records both, and the
answer to both is a different agitation mode rather than a smaller part.

---

## What you print

None of these appear on the purchase list, because a purchase list only knows about things you buy.
This is the part of the build nothing else will remind you about.

**From `head.scad`:**

- the **lid**, one piece — flange, plug, bearing pocket, insert holes, gasket recess, o-ring groove,
  and all twelve bayonet *lock* halves. The locks are not optional detail: their channels are the
  walls of the lid's bores, so a lid exported without them is twelve plain holes that nothing locks
  into
- the **port pin halves**, one per port — tube ports for `air_in`, `air_out`, `media`, `acid`,
  `base`; probe ports with their integral flex collets for DO and pH; a thermocouple port carrying
  an NPT mount
- the **baffle ports and plates** — one plate per baffle port, each split into dovetailed pieces
- the **motor mount**, in three parts: base plate, face plate, middle stand
- **two impellers**
- the **sparge ring**

**From `frame.scad`:** the base, the top base, the ribs and the rod spacers.

**Tools, printed once:** the two halves of the gasket cutter.

Transparent PETG for anything in contact with the culture, grey for structure.

### Two things about printing them

**The two impellers are mirror images, not the same part turned over.** Pumping direction follows
the blade's handedness and rotating a part cannot change it. They are two different STLs, and a pair
built from one file twice will pump the same way and not converge on the sparge ring.

**Export the motor mount from `head.scad`, not from `motor_mount.scad`.** That file will happily
build a mount, and the mount it builds does not match the holes the assembly drills in the lid. The
file says so itself.

The baffle plates are split so they fit a small bed:

```
baffle print: 2 pieces of 140 mm, tallest standing 163 mm against a 170 mm bed;
the dovetail leaves 4.2 mm of 10 crossing each joint, 0.074088 of the plate's
second moment
```

170 mm is the cap the model splits against — 180 mm machines are the small end of what anyone
building this owns, and 10 mm leaves room for a brim. A larger printer can pin `baffle_segments = 1`
and print each plate whole, which is stiffer: the joints already take 14 % of the tip deflection.

**That cap is about the part, not about your printer.** It used to be a literal 170, justified by
180 mm machines being "the small end of what anyone building this owns" — and no 180 mm machine was
ever going to build this reactor, so the number was measuring nothing. It is now a piece's height
against **three times its own section**: a brim as wide as the part on each side, which is why a
brim is worth printing on something this slender. On `jar_10L` that comes out at 205 mm against a
163 mm tallest piece.

The piece that binds is not the obvious one. The piece carrying the port stands on a **27.2 mm
flange**, which is a wide foot; a tip piece stands on the plate's own **15.3 × 10 mm** section and
is half again as slender for it. So the rule grades every piece by the plate.

`just export-parts` writes every one of these as its own STL, with a print list beside them, and
CGAL-renders each on the way past — so a part that is not a valid solid is caught there rather than
in a slicer. It measures each one too, and reports which registered printers take it. It covers the
lid and everything hanging from it; the frame is still a matter of setting the render flags at the
top of `frame.scad` by hand — and since the frame holds two of the three widest parts, take
`assembly.scad`'s report rather than the print list's for what you need to own.

**What you need to own.** Three parts are a **257.40 mm disc** — the lid, and the frame's base and
top base — and they are the widest things in the build by a long way. A disc has the same width at
every angle, so it cannot be turned to fit a narrow bed: what your printer needs is `min(X, Y)` of
at least 257.40.

`scad/assembly.scad` reports this on every render, against the machines registered in
[`scad/purchased/printers.scad`](../scad/purchased/printers.scad). Today that is the **Prusa CORE
One L**, the **Bambu H2D**, the **Sovol SV08**, a **Voron 2.4 350** and the **Prusa XL**.

What misses, and by how little, is worth knowing. A **Bambu X1C** is 256 — short by **1.4 mm**. A
**Voron 250** is short by 7.4. A **Prusa CORE One** is 250 × 220 and cannot do it at any margin,
because the jar alone is 220 mm across and the lid has to overhang the glass to carry its bolts.
The lid was briefly trimmed to 252 to reach the X1C; the frame's bases are 257.40 too and its wall
is set by the rod bosses, so that bought nothing and was undone.

---

## What you cut

| Stock | Cut | Yield |
| --- | --- | --- |
| M8 threaded rod, DIN 975 A2 | **4 × 322 mm** | buy 1500 mm or more |
| 316 SS tube 4 × 0.5 mm, `50415K21` | **2 × 186.7 mm** | 373.4 mm from a 500 mm length, 126.6 mm spare |
| EPDM sheet 1/16 in 60A, `8525T65` | **145 × 151 mm** per lid | 4 per 304.8 mm sheet |

**The rod length follows the jar, not the design.** 322 mm is `jar_10L`; it is 214 mm on
`jar_1gal_180` and 487 on `jar_6p5gal`. It is derived as vessel 305 + flange 8 + nut 6.5 + 2.5 mm
left proud of the top nut, so a different vessel height moves it directly.

**Deburr the tube bore after cutting, and treat that as a step rather than a nicety.** A wheel
cutter rolls a 0.5 mm wall inward at the cut, and the riser's bore is only 3 mm — so the restriction
lands exactly where gas enters. The registered tool is a NOGA RC1000, whose minimum bore is not
published; check its blade actually reaches 3 mm before relying on it. A round needle file does the
same job on two cuts. A jeweller's saw in a mitre jig avoids the problem instead of correcting it,
because a saw does not roll the wall in the first place.

Cut the rim gasket with the printed two-stage cutter rather than by hand: the outer disc guides the
first cut, then the blank drops into a counterbore under the inner plate whose bore guides the
second. The concentricity of the finished ring is then a printed counterbore rather than your hand.

---

## Fits you make

Most of the fits in this reactor are bought. These are the ones you create at the bench, and each
one has a number that decides whether it works.

**The bearing is a press fit — heat the race and chill the shaft.** That is what McMaster specify,
not a workaround for a wrong hole. The shaft is 7.995–8 mm in an 8 mm bore, so the fit runs from
0.007 mm interference to 0.005 mm clearance; the pocket in the lid is 22.2 mm for a 22 mm outside
diameter. The joint feeling tight on assembly is the intended condition.

> **The bearing is the weak link against bleach.** 440C and Buna-N are both poor against
> hypochlorite, and this reactor is chemically sterilised rather than autoclaved. The shaft is 316
> precisely for that reason. The bearing sits in a blind lid pocket and is not submerged — keep it
> that way.

**Heat-set the four M4 inserts into the lid from the mount face.** 4.7 mm of insert into a 5.6 mm
hole, with 13.25 mm of lid left beneath them. The inserts go in once and stay; the M4 × 8 screws
into them come out every time the mount does. The insert only offers 4.7 mm of thread, so a longer
screw bottoms out instead of clamping, and the screw is 18-8 into 18-8 — take care not to round the
socket.

**The impeller set screws cut their own thread.** The hole is printed at the 3.3 mm tap size and no
thread is modelled; printed holes come out undersize, so expect to open one. Two per impeller at 0
and 120°, 5.8 mm of thread through the 8 mm collar above the blades. They are cup-point on purpose:
they bite the shaft rather than relying on friction, because the hub bore tapers to exactly the
shaft nominal and grip was otherwise zero by design.

**The o-rings go in three different ways, and only one of them is stretched.**

| Seal | How it seats |
| --- | --- |
| Lid plug, `AS568-160` | **stretched 4.27 %** onto a groove cut from the jar's bore |
| Port face seals, 12 of them | seated in a gland cut to fit the ring, no stretch |
| Riser rod seals, `8785N364` ×2 | **0 % stretch** — the ring's ID *is* the 4 mm tube |

The two rod seals go into a counterbore at the lid's **inner** face, and they go in **before** the
riser passes through. That face is inaccessible once the lid is on the jar.

**The silicone sits differently at every joint, and the risky ones are all downstream.** One bore,
3/16 in ID, covers the whole run from the meter to the ring: **native** on the check valve's barb,
**stretched 33 %** onto the sterile filter's 1/4 in step, and **0.76 mm loose** over the 4 mm riser,
which a worm clamp closes. Watch the filter joints: silicone creeps,
and that joint is the sterile barrier. A leak upstream of the rotameter only costs flow you then
dial back in; a leak downstream means the vessel gets less than the meter claims and every vvm
figure in [`agitation.md`](agitation.md) is wrong by that much. All four of the risky joints — the
check valve twice, the filter twice — are downstream.

---

## Putting the lid together

The order is forced by geometry, not preference.

1. **Ports into the lid first.** The lock half of every bayonet is printed as part of the lid; the
   pin half is the cartridge that carries the flange, the seal and whatever hangs into the vessel.
   It drops in from outside and turns to lock. Two catch pockets in each flange are there for
   pliers.
2. **Everything that hangs below a port must pass the lock's bore on the way in** — that is what
   sets the baffle plate's width, and the model asserts it.
3. **Then the lid goes onto the jar**, and everything hanging from it passes down through the mouth
   — so *every part of the assembly is level with the mouth at some moment on the way down*. What
   matters is the widest the assembly ever gets, not where it finishes. On `jar_10L` the DO probe's
   collet is the binding part, reaching 71.18 mm against a 71.5 mm mouth — **0.32 mm to spare**.
4. **The probes go in last**, down through the bayonet's bore into the collet. They never pass the
   mouth at all, which is why their length is not part of the clearance above.

### Two ways to assemble it wrong that nothing will catch

**The sparger's sockets look identical from above.** The feed socket is a **hexagon** and the
support sockets are **round**, and that is the only thing telling them apart, because you cannot see
inside a socket at the bottom of a jar. Get it wrong and the gas goes down a capped tube and
straight back out its own vent hole into the headspace — while the rotameter reads flow and the
culture gets nothing.

**The ports are labelled by function for the same reason.** `air_in` and `air_out` have the same
bore, so marking them by bore alone put `Ø6` on both. A gas line on the wrong one vents into the
headspace; a dosing line on the wrong one puts acid where base should go. The marks now read
`AIR IN Ø4.4`, `ACID Ø4.8`. Baffle ports are marked with the length of plate they carry.

The sparge ring itself cannot be installed rotated: its two sockets are 120° apart, and only one
rotation puts both under tube ports.

### Drilling the support tube

The support tube is capped where it meets the ring and does its job through a hole you drill. The
model is the only thing that can dimension that hole, and it does:

```
sparge support drilling: a support tube vents through a hole drilled between 38
and 87.8892 mm from its TOP end - past the lid's inner face, short of the
culture. Nearer the first number is better; the headspace is there for foam and
foam finds the lowest hole.
```

Measured from the **top** end, because that is the end you can reach with the tube in your hand.

---

## Closing the lid, and the number that cracks the jar

**This joint is limited by the glass, not by the fastener, and nothing about the hardware says so.**

Twelve posts hold the lid down on a 238.8 mm circle, 62.5 mm apart: **eight M8 bolts and four M8 tie
rods**, the rods occupying every third position. The bolts' heads bear under the top base; the rods
run the full height of the frame from the lower base. All twelve are tightened by a **nut sitting on
top of the lid flange**, so the operation is the same at every post.

```
joint load: 3501.92 N of gasket seating over 12 posts = 291.827 N each, on M8
bolts and M8 rods
lid gasket load: 3 mm wide on a 3 mm rim, 3501.92 N to hold 25% squeeze,
2.51058 MPa on the glass
```

**291.8 N per post.** An M8 A2-70 proof load is about 16.5 kN, so the joint runs at **1.8 % of
proof** — the fastener is nowhere near being the limit. A published tightening torque for the same
bolt is 20–24 N·m. This joint wants something near **0.6**. Torque one of these to fastener spec and
you put roughly forty times the intended load onto a soda-lime jar.

### Do not reach for a torque wrench

Torque only ever reaches preload through a friction coefficient, and here you cannot know it. Across
the 0.20–0.30 that an unlubricated stainless nut plausibly spans, 291.8 N is **0.47 to 0.70 N·m** —
a 40 % band from the friction assumption alone. 18-8 galls, which is exactly what makes that
coefficient unpredictable, and 0.6 N·m is below the bottom of most torque wrenches anyway.

### Turn the nut instead

```
joint tightening: 114.3 deg past snug on each of the 12 nuts, all of which sit on
top of the lid - 0.396875 mm of gasket travel on a 1.25 mm pitch. The printed
flange takes a little more and then creeps, so go back to them.
```

A turn is geometry. The 1/16 in gasket is 1.5875 mm, 25 % squeeze is 0.3969 mm of travel, and an
M8 × 1.25 thread converts that to **114°**. No modulus and no friction enter it.

The rest of the stack barely moves: at 291.8 N an M8 bolt stretches 0.0008 mm over its 20.4 mm grip
and a rod 0.0004 mm over the 10.4 mm between its top-base nut and its lid nut — under 0.3 % of the
gasket's travel either way. The printed flange is the soft part, and it is the one number in this
section without a source: roughly 0.02 mm under a nut face, from PETG's modulus and a nut's bearing
area, which is an estimate and not a measurement. So:

> **Snug, then a third of a turn.** 120° is 114° for the gasket plus a little for the plastic, and it
> is a mark you can see on a nut where 114° is not.

Snug is where the flange stops moving under hand pressure on a short key.

**Pattern.** Bring all twelve to snug first, working across the circle rather than around it, then
take them to a third of a turn in the same order in two passes. A gasket squeezed unevenly seals at
its tightest point and leaks opposite it, and glass is unforgiving of being loaded on one side.

**Then go back to them.** PETG creeps under sustained load, and the flange, the top base and the
plastic under twelve nut faces are all in this load path. Re-check after a few hours and again after
the first run.

### Two things not to do

**Do not tighten until the flange meets the glass.** The recess is 1.19 mm deep for a 1.5875 mm
sheet, so at the design squeeze the gasket is nominally flush and the flange nominally touches. It
cannot actually get there: the recess holds three quarters of the rubber's section, elastomer is
near enough incompressible, and the last quarter has to escape sideways across the 1 mm lands first.
Flange-on-glass is *past* the design point, not at it.

**Do not substitute a harder gasket without re-deriving the joint.** 60A durometer is what sets the
ASME VIII-1 gasket factor m = 0.5, and that is what gives twelve posts. At 75A or harder the same
lid wants sixteen.

### How good is 291.8 N?

Not very, and the model says so. `gasket_shape_factor()` is the free-bulge form — it assumes both
edges of the pad can spread, and the recess walls are exactly where they cannot. The modulus behind
it is correlated from hardness rather than measured. So 291.8 N and 2.51 MPa are figures for judging
a design, not for cutting a part to, and `gasket_load.scad` says as much at the top of the file.

**The turn is the more robust of the two**, which is why it is the instruction. It comes from the
gasket's thickness and the thread's pitch — neither of which is a correlation.

---

## The gas line

Order matters, and two of the joints are ordered for reasons that are not obvious.

```
pump ──3/8 in── reducer ──1/4 in── reducer ──1/8 in── METERING VALVE ──
      rotameter ──3/16 in silicone── check valve ── STERILE FILTER ── riser
```

**The metering valve goes upstream of the rotameter.** The meter is calibrated at 14.7 psia, and
putting the throttle ahead of it means the meter only ever sees downstream line loss — which is what
makes the correction 0.7 % instead of something that matters.

**The rotameter's two adapters are deliberately different sizes**, 1/8 in in and 3/16 in out, so the
line steps up inside the meter's own bore rather than through a coupler. One less joint.

**The sterile filter is the boundary.** Everything downstream of it is inside the sterile envelope
and is platinum-cure silicone; everything upstream can be PVC or polyurethane, and the barbed
fittings on that side are rated for firm line rather than silicone. The smallest joints — 1/8 in ID,
about 6 mm outside — fall below most worm clamps and want spring or pinch clips.

The check valve exists to stop culture siphoning back into the pump when it stops. It is not
optional.

---

## Commissioning

**Set the gas rate before anything else.** 0.1–0.5 vvm on 8.25 L is **0.825–4.125 L/min**, which is
17 % to 83 % of the registered 0–5 L/min meter — both ends on scale, which is what that range buys.
The pump is seven times oversized, so the entire band sits in the first part of the needle valve's
travel — that is why the valve is a 3° needle and not the 20° one.

**Watch the DO trace on the first run.** The DO probe's face sits 20.6 mm above the sparge ring's
centreline and 0.87 mm off its radius, which is directly over a ring of bubbles. A galvanic probe
reads high with a bubble on the membrane and low with nothing moving past, so this is the one
placement that can be wrong in both directions. A characteristically spiky trace means the probe is
in the plume, and the fix is a bench one — the port's lean and the ring's height are both
parameters.

**Know the replace-the-filter signal.** The sterile filter can rise about **65 %** — from 14.2 kPa
to roughly 23.3 — before 0.5 vvm becomes unreachable with the valve wide open. So *valve fully open
and still short of the rate* is the signal, and it is not a pump problem.

---

## What to record

The model is waiting on four measurements. If you build one of these, these are the numbers worth
sending back:

1. **The sterile filter's ΔP** at the set flow, from a water manometer across it. It is the largest
   term in the gas budget and the only one that is extrapolated.
2. **The jar's rim**, calipered — the land width on top of the glass, the wall, and the mouth. Three
   registered numbers disagree on two vessels and a caliper says which is wrong.
3. **The baffle's lean.** Print the lid's baffle port and one plate segment, seat them, and measure
   the tilt at a known distance below the lid. The model reports a stacked worst case of −0.28 mm
   running clearance and openly says it cannot tell how much of that lean is real.
4. **Whether the joint holds.** Nobody has yet tightened twelve nuts a third of a turn onto a glass
   jar with a printed flange in between. How much it relaxes, and over what time, is the number this
   document most needs.
