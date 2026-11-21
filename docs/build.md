# Building it

What you do with tools in your hands. The other documents say why the reactor is the shape it is;
this one says what to cut, what to print, in what order to put it together, and which numbers will
break something if you get them wrong.

The figures here are the reference build's, `jar_10L_220x305`, from its echo transcript; a bought
part's tolerances come from [`purchased-parts.csv`](../purchased-parts.csv). Build a different jar
and they move: render `scad/bioreactor.scad` for yours and read them back.

---

## Nothing here has been built yet

This reactor has not been printed or assembled. Every number below is derived from the model, and
the model has never been contradicted by a part in someone's hand. A first build should expect to
correct this document.

Three figures in particular are bands rather than measurements, and all three wait on a bench (see
[What to record](commissioning.md#what-to-record)):

- the **sterile filter's pressure drop**, extrapolated from a comparable disc, and the largest single
  term in the gas budget
- the **jar's rim profile**, which everything sealing is measured against and which no one has
  calipered
- the **baffle's lean under load**, reported as a worst case that the model itself says is a worst
  case

Not every vessel takes every drive. `jar_1p5L_112x215` and `jar_1gal_155x251` cannot carry a
top-entry drive on their lids at any mount size - the mount overlaps the port flanges on the first,
and on the second the pH probe runs through the lower impeller, because in a 155 mm bore the port
circle and the impeller want the same radius - so both are built as airlifts, with no drive and a
draft tube, and both also take the magnetic one. The builds that work are the sets in `scad/bioreactor.json`, and
`just check-builds` fails if one of them stops building. What each vessel cannot yet take, and why,
is in [Agitation mode per vessel](agitation.md#5-agitation-mode-per-vessel), and the benches that
would settle the airlift and magnetic builds are #86 and #87.

---

## What you print

None of these appear on the purchase list, because a purchase list only knows about things you buy.
This is the part of the build nothing else will remind you about.

**From `head.scad`:**

- the **lid**, one piece - flange, plug, bearing pocket, insert holes, gasket recess, o-ring groove,
  and all twelve bayonet _lock_ halves. The locks are not optional detail: their channels are the
  walls of the lid's bores, so a lid exported without them is twelve plain holes that nothing locks
  into
- the **port pin halves**, one per port - tube ports for `air_in`, `air_out` (only on the ring's
  builds; elsewhere the coil condenser's body is that pin) and the dosing
  lines `dose_1` to `dose_3`; probe ports with their integral flex collets for DO and pH; a thermocouple port carrying
  an NPT mount
- a **blank port** for each bayonet size the lid uses - a pin with no bore, labelled `BLANK`, to
  close a port with nothing in it while cleaning, testing or servicing
- the **baffle ports and plates** - one plate per baffle port, each split into dovetailed pieces;
  or, on a build that carries the wall cage (both `jar_10L` builds, where `baffle_name = "auto"`
  takes it), the **cage**: a top hoop, a bottom hoop and four blades, and three more blanks for the
  ports the plates would have taken (see [The wall baffle cage](#the-wall-baffle-cage))
- the **motor mount**, in three parts: base plate, face plate, middle stand
- **two impellers**
- the **sparger** - the arm, or the ring or the loop if the build names one (`sparger_name`; see
  [The sparger](#the-sparger))

**From `frame.scad`:** the base, the top base, **eight ribs** and **twelve rod spacers**. The ribs
are one part printed eight times: each is rotated by a multiple of 90 deg and bitten by the same lights
cutout, so the exported meshes differ only in how the cut surface tessellates.

**The drive decides two of those lists.** `drive_name` in `bioreactor.scad` is `shaft` (above),
`magnetic`, `none` or `airlift`. Magnetic takes the motor mount and the impellers off the head's list, adds a
**bearing blank** in their place, and adds the **stir carrier** and the **hub cap** to the frame's,
and on `jar_1gal_155` and `jar_6p5gal` the **stir riser** too.
On the default lid the lid and the base are the same parts either way: the lid keeps its bearing pocket, bore and
inserts and the blank plugs them - its boss is the bearing's size, sealed by the pocket's own
o-ring, its pin fills the shaft bore, and its flange bolts to the four inserts with the mount's own
screws - and the base is slotted for the carrier whichever drive a build names, except on a jar
whose magnetic build stands on a riser, where the riser carries the slot. See
[The magnetic drive](#the-magnetic-drive).

`none` prints neither drive's parts, and `airlift` is `none` with a draft tube added: the gas is all that moves the culture, and the sparger is the
ring unless the build names the arm. Its lid is plain - no pocket, bore or inserts - which
`lid_center_name` sets: `bearing` for the convertible lid above, `plain` for this one, and `auto`
takes plain under `none` or `airlift` and bearing otherwise. A magnetic build states `plain` where the blank's
flange would not clear the ports, as `jar_1p5L_magnetic` and `jar_1gal_155_magnetic` do; that lid
cannot later take the shaft.

**Tools, printed once:** the three parts of the gasket cutter. The base is printed once for good -
it is the same for every gasket; the outer disc and inner plate follow the cut and are reprinted
when the vessel changes.

Food-grade clear PETG for anything in contact with the culture, grey PETG for structure. The
food-grade qualifier is a purchasing constraint, not a colour: a clear spool is not automatically
one, and the wetted parts are what the culture sits against for the length of a run.

### Two things about printing them

**Each Rushton prints as two halves, and all four halves are one part.** Standing on its blades, a
disc turbine's disc overhangs the whole ring between hub and blades, and supports there leave the
disc rough. Split at the disc's mid-plane, each half prints on its half-disc with nothing
overhanging. Turn one half over onto another and line them up with two lengths of 1.75 mm filament
in the pin holes at 90 and 270 deg; the blades sit on multiples of 60 deg, so they land on each other.
`impeller_half` on the print list is the part, four off. A turbine too small for its half to take
the set screw's hole prints whole, and `head()` warns.

**A pitched pair's two impellers are mirror images, not the same part turned over.** Pumping
direction follows the blade's handedness and rotating a part cannot change it, so they are two
different STLs, and a pair built from one file twice will pump the same way and not converge on the
sparge ring. A Rushton's flat blades have no hand, so the reference build's two are one part.

**Export the motor mount from `head.scad`, not from `motor_mount.scad`.** That file will happily
build a mount, and the mount it builds does not match the holes the assembly drills in the lid. The
file says so itself.

The baffle plates are split when a piece would be too slender to print standing. On
`jar_1gal_180x197`, the registered jar that hangs them, one piece passes:

```
baffle print: 1 piece of 165.218 mm, tallest standing 188.218 mm against a 200 mm slenderness cap
```

Where a plate is split, as on `jar_10L` given lid plates (`baffle_name = "lid"`, two pieces of
136.997 mm), the pieces join with a dovetail. A larger printer can pin `baffle_segments = 1` and
print each plate whole, which is stiffer: split, the joints take 14 % of the tip deflection.

**The slide runs along the plate's width, and that is a load choice.** The swirl pushes on the
plate's face, so with the slide across the width that load bears on the dovetail's flanks and the
one free axis carries only vibration. A blind end registers the pieces; the butt faces meet, so
the 0.1 mm allowance is flank clearance only and the plate keeps its length. The neck - the only
material crossing the joint plane - is the parameter rather than the tail's depth, and a shallow
10 deg flare buys engagement without eating it.

**Two things about the joint are not modelled.** The first mode `head()` reports is the solid
plate's; the joints soften it by an amount not computed. And a 0.1 mm crevice at the joint sits in
the culture, in a vessel that is chemically sterilised rather than autoclaved - a cleaning
liability nothing here answers.

**That cap is about the part, not about your printer.** It is a piece's height against **three
times its own section**: a brim as wide as the part on each side, which is why a brim is worth
printing on something this slender. The rule gives **205.07 mm**, and
the **printer ceiling clamps the cap to 200 mm** - the shortest registered build height less 10 -
so 200 is what the echo reports, against `jar_1gal_180x197`'s 188 mm tallest piece.

The piece that binds is not the obvious one. The piece carrying the port stands on a **28.2 mm
flange**, which is a wide foot; a tip piece stands on the section alone and is half again as
slender for it. That section is **17.09 x 10 mm** - the widest plate the port's lock bore will
pass, which `jar_1gal_180x197`'s plates also are - so the cap is a property of the
port and grades the same on every vessel.

`just export-parts` writes every one of these as its own STL, with a print list beside them, and
CGAL-renders each on the way past - so a part that is not a valid solid is caught there rather than
in a slicer. It measures each one too, and reports which registered printers take it. It covers the
reactor's own parts - the lid and everything hanging from it, and the frame's base, top base, ribs
and rod spacers - which comes to **49 pieces across 25 distinct parts** on `jar_10L_220x305`.

**A build is a parameter set in `scad/bioreactor.json`**: a vessel and whatever it designates.
`just export-parts jar_10L_magnetic` exports that one to `output/jar_10L_magnetic/`, and the print
list opens with the model's own statement of what it is (vessel, drive, fill, every designation
not left `auto`). To look at one part while working on it, `just export-part frame_base
jar_10L_magnetic` renders that row alone in a few seconds and writes no list.

**`just export-parts` with no build exports every registered build, by vessel**, to `build/`:

```
build/jar_10L_220x305/
  common/     the frame, the gasket cutter, the lid, the ports, the sparger
  stirred/    the motor mount and the impellers
  magnetic/   the stir carrier, the hub cap and the bearing blank
```

`common/` is what every registered build of that vessel prints the same - the same part, judged by
its geometry rather than its name, and not one drive's own - so it is printed once, and the type's
folder adds what makes it that build. A vessel with one registered build still splits its drive's
own parts out. Each distinct part renders once, and each vessel's folder is replaced whole, so
what is there is what the model prints now.

It renders the parts in parallel, every core at once, so the whole list takes about as long as the
lid alone.

**Pictures** come from the same model. `just render-parts jar_10L_220x305` draws every part on
that print list on its own, to `output/figures/jar_10L_220x305/parts/`. `just render` draws the
views listed in `scad/views.tsv`: the assembly whole and cut open, the head and the frame apart,
and the components. `just render 'head_*'` draws only the rows it matches. A new figure is a row
in that file, and its header says what a row can name.

**Exploded views** come from `head.scad`'s `explode`, the step in mm between neighbours along the
vessel's axis; 0, the default, is assembled and moves nothing. The lid stays put. The drive stack
lifts off it in the order it goes on - inserts, bearing, the mount's base, its screws, the coupler,
the stand, the face plate, the motor - and the shaft and impellers drop below; the ports' o-rings,
pins and probes lift off above, and the rim gasket and plug ring drop below. `just render
'*exploded*'` draws the drive and the lid apart at 40 mm.

**Without OpenSCAD:** the Export workflow on GitHub runs the same export on demand and on every
tag, one job per build, and leaves the STLs and the print list as a downloadable artifact
(`stl-<build>`) on the run. It is also the only place the parts that print are CGAL-checked in CI -
`just test` covers the entry files' previews, not the manifests.

It is not everything in this repo that gets printed. The bench around the reactor has its own
list: `just export-accessories` writes three **bottle holders** (one per dosing bottle, at the
86.1 mm round bottle), the **e-stop box**'s base and lid, and the **electronics stand**'s printed
corner to `output/accessories/`, from `accessory_print_parts()` in
`scad/support/accessories.scad`. The cart prints nothing and was never built
([future work](../dev/future-work.md#bench)).

**What you need to own.** Three parts are a **257.6 mm disc** - the lid, and the frame's base and
top base - and they are the widest things in the build by a long way. A disc has the same width at
every angle, so it cannot be turned to fit a narrow bed: what your printer needs is `min(X, Y)` of
at least 257.6.

`scad/bioreactor.scad` reports this on every render, off the geometry rather than the meshes, so
its answer agreeing with `just export-parts` is the check that nothing has fallen off a manifest.
It checks against the machines registered in
[`scad/purchased/printers.scad`](../scad/purchased/printers.scad): the **Prusa CORE One L**, the
**Bambu H2D**, the **Sovol SV08**, a **Voron 2.4 350** and the **Prusa XL**.

A **Bambu X1C** is 256, short by **1.6 mm**. A **Voron 250** is short by 7.6. A **Prusa CORE One**
is 250 x 220 and cannot do it at any margin, because the jar alone is 220 mm across and the lid has
to overhang the glass to carry its bolts. Trimming the lid does not help: the frame's bases are
257.6 too, and their wall is set by the rod bosses.

---

## What you cut

| Stock                              | Cut                                      | Yield                                           |
| ---------------------------------- | ---------------------------------------- | ----------------------------------------------- |
| M8 threaded rod, DIN 975 A2        | **4 x 322 mm**                           | buy 1500 mm or more                             |
| 316 SS tube 4 x 0.5 mm, `50415K21` | **1 x 265.3 + 3 x 187.9 + 1 x 200.7 mm** | 1029.9 mm from a 2000 mm length, 970.1 mm spare |
| EPDM sheet 1/16 in 60A, `8525T65`  | **142.2 x 158.2 mm** per lid             | 1 per 304.8 mm sheet                            |

**The rod length follows the jar, not the design.** 322 mm is `jar_10L`; it is 214 mm on
`jar_1gal_180` and 487 on `jar_6p5gal`. It is derived as vessel 305 + flange 8 + nut 6.5 + 2.5 mm
left proud of the top nut, so a different vessel height moves it directly.

**Deburr the tube bore after cutting, and treat that as a step rather than a nicety.** A wheel
cutter rolls a 0.5 mm wall inward at the cut, and the riser's bore is only 3 mm - so the restriction
lands exactly where gas enters. The registered tool is a NOGA RC1000, whose minimum bore is not
published; check its blade actually reaches 3 mm before relying on it. A round needle file does the
same job on two cuts. A jeweller's saw in a mitre jig avoids the problem instead of correcting it,
because a saw does not roll the wall in the first place.

Cut the rim gasket with the printed cutter rather than by hand. Everything happens on the base,
which is the cutting surface, carries the nuts and is what both stages screw to, so nothing has to
be lined up on a board by eye.

1. **Three M4 nuts into the channels** on the base's underside, and one into the hex pocket at its
   centre. They cannot turn, and they slide along their channels, which is what lets one base serve
   every gasket size.
2. **First cut.** Lay the sheet on the base, put the outer disc on it, and run a screw through the
   disc's centre into the central nut. Cut round the disc. The screw pierces the sheet at its
   centre, which is waste - the inner cut removes it.
3. **Second cut.** Leave a short screw standing in the centre and drop the blank over it, or just
   lay the blank on the base. Lower the inner plate onto it: the counterbore's mouth is flared, so
   it shepherds the blank into its seat as it comes down. Run the three clamp screws through the
   plate, through the base's slots, into the nuts. Cut down the bore.

   The base has two rings of slots. A plate reaches whichever one clears its own blank - the inner
   ring for the small jars, the outer for the large - so the nuts move to match the plate you
   printed, and the ring the plate does not use stays clear of every cut.

The plate stands `grip` (0.4 mm) proud of its seat, so it closes on rubber and pinches the blank
rather than resting on the base. The concentricity of the finished ring is a printed counterbore
rather than your hand.

---

## Fits you make

Most of the fits in this reactor are bought. These are the ones you create at the bench, and each
one has a number that decides whether it works.

**The bearing is a press fit - heat the race and chill the shaft.** The shaft is 7.995-8 mm in an
8 mm bore, so the fit runs from 0.007 mm interference to 0.005 mm clearance; the pocket in the lid
is 22.2 mm for a 22 mm outside diameter. The joint feeling tight on assembly is the intended
condition. **Keep the bearing out of the vessel's bleach step**: its 440C and Buna-N are the weak
link against the sterilant ([why](procurement.md#bearing)).

**Heat-set the four M4 inserts into the lid from the mount face.** 4.7 mm of insert into a 5.6 mm
hole, with 13.25 mm of lid left beneath them. The inserts go in once and stay; the M4 x 8 screws
into them come out every time the mount does. The insert only offers 4.7 mm of thread, so a longer
screw bottoms out instead of clamping, and the screw is 18-8 into 18-8 - take care not to round the
socket.

**The impeller bore is a slip fit, and the set screws are what locate it.** The bore is 8.4 mm
straight through on an 8 mm shaft - 0.4 to 0.405 mm of slack before print shrinkage - so an
impeller slides to its height and is fixed there. Open the bore with a reamer or a drill if your
printer closes it up; `head()` reports the slack it was cut for.

**The impeller set screws cut their own thread.** The hole is printed at the 3.3 mm tap size and no
thread is modelled; printed holes come out undersize, so expect to open one. A split impeller has no
collar: each half takes two in its hub, in the gaps between the blades at 30 and 150 deg, so four per
impeller. One printed whole takes two at 0 and 120 deg, through the 8 mm collar above the blades.
Either way it is 5.8 mm of thread. They are cup-point on purpose:
they bite the shaft rather than relying on friction, which is all that holds the impeller once the
bore slides.

**The o-rings go in four different ways, and only one of them is stretched.**

| Seal                           | How it seats                                               |
| ------------------------------ | ---------------------------------------------------------- |
| Lid plug, `AS568-160`          | **stretched 3.67 %** onto a groove cut from the jar's bore |
| Port face seals, 12 of them    | seated in a gland cut to fit the ring, no stretch          |
| Riser rod seals, `8785N364` x5 | **0 % stretch** - the ring's ID _is_ the 4 mm tube         |
| Bearing rim seal, `8785N382`   | **0 % stretch** - the ring's ID _is_ the 22 mm bearing     |

**The bearing seal goes in before the bearing.** Drop the 22x1.5 down the pocket and let it expand
into the groove at mid-depth, then press the bearing past it. It seals on the bearing's **outer
race**, which does not turn - the inner race does, and on a 608 both race faces are flush, so a
gasket under the bearing would be clamped against a rotating steel face. Nothing seats _on_ the
pocket floor: the bearing still bottoms there.

The rod seals go into an enclosed groove just above the lid's **inner** face, and they go in
**before** the tubes pass through. That face is inaccessible once the lid is on the jar. There is
one per tube port - five on the full lid, three on the six-port jars. Each ring folds into its
groove; work it round and seat it with a small flat screwdriver.

**The silicone sits differently at every joint, and the risky ones are all downstream.** One bore,
3/16 in ID, covers the whole run from the meter to the ring: **native** on the check valve's barb,
**stretched 33 %** onto the sterile filter's 1/4 in step, and **0.76 mm loose** over the 4 mm riser,
which a worm clamp closes. Watch the filter joints: silicone creeps,
and that joint is the sterile barrier. A leak upstream of the rotameter only costs flow you then
dial back in; a leak downstream means the vessel gets less than the meter claims and every vvm
figure in [Agitation](agitation.md) is wrong by that much. All four of the risky joints - the
check valve twice, the filter twice - are downstream.

---

## The magnetic drive

A PC fan in a printed carrier hung in the base's bore, two magnets in a cap on its hub, and a PTFE
stir bar on the jar's punt inside. Nothing passes through the lid. What the model picks and where it
puts it, on `jar_10L_magnetic`:

```
stir drive: fan80x25 in a 164.6 mm carrier 36.75 mm tall, its top 0 mm under
the landing plane, hung on its ear 8 mm off the bottom face; the fan is turned 55 deg
to put a flat on the slot's bearing, and the lead leaves its 8 mm notch there for the
14.65 mm slot at 145 deg
fan joint: 4 x M4 x 40 mm down through the fan into nuts in 4.2 mm hex pockets at the
carrier's bottom face, 7.55 mm of carrier over them; the head stands 2.2 mm on the
fan, 3.48992 mm under the glass
fan joint, head down: an M4 x 40 mm cap screw up from the pocket to a nut on the fan
stands 4.25 mm over that nut, 1.76008 mm into it - shorten the screw, or build it the
other way up
stir magnets: 2 x MAG5x8 on the 40 mm hub at 28 mm pitch, faces 1.24242 mm under the
punt and 6.24242 mm from the floor inside
stir bar: 38x8 centred on the 30 mm punt plateau, overhanging it by 4 mm each end;
sweeps r 19 under the sparge arm, 41.5363 mm over it; the sparger is still placed on
the shaft drive's impeller
```

**The fan is picked by rule, not named.** Of NopSCADlib's fans, the one with the widest hub whose
corners clear the carrier's pocket and whose depth fits under the jar with the joint's own depth
reserved; the thinnest of that hub. The hub is the sort key because it is what the magnets are
carried on, and a wider frame around a smaller hub buys nothing. An 80 x 25 on `jar_10L` and
`jar_1gal_180`, a 40 x 11 on `jar_1p5L`, and on a riser a 60 x 25 on `jar_1gal_155` and a
120 x 25 on `jar_6p5gal`. The magnets
and the bar are named (`stir_magnet_name`, `stir_bar_name`), because a bench usually has some: the
defaults are two dia 8 x 5 discs and a 38 mm bar, and the other registered sizes are in
`purchased/magnets.scad` and `purchased/stir_bars.scad`.

**The floor under the jar is sunk for that fan, up to a point.** The frame reaches below the jar by
whatever the light stack overshoots its height by. The floor takes the deeper of that and what the
fan and the magnets need, so a jar whose light happens to be short still gets a drive. `jar_1p5L` is 3.77 mm deeper for
it and gains a carrier. `carrier_floor_lift_max` (10 mm) is how far that goes: past it the base
would be mostly added floor. The floor does not depend on which drive a build names, so the base is
still one print for either.

**Past that limit the magnetic build stands on a riser.** `jar_1gal_155` wants 36 mm more than its
light leaves and `jar_6p5gal` 35, so their bases keep the light's floor and a magnetic build of
either adds `frame_stir_riser`, which makes up the rest under the whole frame. On
`jar_1gal_155_magnetic`:

```
stir riser: 36 mm under the base, which keeps the light's 4 mm floor; walls at r [50.15,
63.65, 82.25, 94.95], keyed into every light's cord notch
```

It is walls only, 3 mm (`riser_wall`), so it prints as it stands with nothing to bridge but the
lead's doorways. Four rings: one round the carrier at the base's own bore; one under the circle the
jar lands on, since the floor ring over it is 4 mm on `jar_1gal_155` and would otherwise span; one
under the lights' middle, which holds them at the base's underside as the bench would; and one
round the base's edge, so the reactor stands on the base's full width. Four spokes on the quadrant
lines tie them. The carrier hangs in it exactly as in a deep base: a block on its ring carries the
same groove and ear notch, and the groove runs on out through the other rings as the lead's
doorway.

It locates in the base's cord notches, all twelve: in each, from the seat's face to the edge, a key
fills the notch less the 0.3 mm a light keeps in its seat, so it centres on the base as closely as a
light sits its seat and leaves every seat clear. **The lights' cords leave from the top**, against
the top base, which is also where a light seats best. The reactor stands 36 mm taller for it, and a
build under any other drive stands on the bench.

1. Stand the riser on the bench, drop the carrier in with its ear down the notch, and lead the
   wire out through the doorway.
2. Fit the lights into the frame, cords up, then lower the frame onto the riser with a key in every
   cord notch.

The carrier's ear stands 23.8 mm off the bench, so a riser has to be at least that tall to hold it
under the base. A drive wanting between 10 and that over the light's floor fits neither the base
nor a riser, and the model says so; no registered jar is in that band.

**How high the carrier hangs is set by the magnets, not the fan.** Their faces are held
`stir_magnet_glass_clearance` (1 mm) under the jar's punt, at the magnets' outer edge where the cone
comes lowest, and the carrier's top follows down from there - never above the plane the jar lands
on. That is what "faces 1 mm under the punt and 6 mm from the floor inside" is: 1 mm of air and 5 of
glass to the culture, with the bar's axis 4 mm above that.

That ceiling is why a deeper floor does not help every jar. Where the punt rises further than the
magnets and their cap need, the carrier stops at the landing plane and the cap grows instead: a solid
floor under the magnets, up into the punt's void, until either the magnets reach their clearance or
the cap's rim reaches its own. On `jar_10L` the rim binds first, so the cap is 8.39 mm tall and the
magnets sit 1.24 mm under the punt. On `jar_6p5gal` the punt rises 15 mm at the magnets and the cap
grows 8 mm to reach 1 mm, but its 12 mm wall still puts them 13 mm from the culture against 4-6 mm
on every other jar. Floor depth is not that jar's problem.

**Assembly, in the order the parts allow:**

1. **Print the carrier pocket up, as it is modelled** - there is nothing to support: it is solid
   under the fan, every wall is vertical and the ear's wedge slopes upward.
2. **Four nuts into the hex pockets in the bottom face**, then the **fan into the pocket from
   above**, hub up, with its lead on the side the pocket wall is cut down - that side faces the
   base's slot. Four M4 x 40 screws down through the fan's own corner holes into those nuts: one
   driver, from above, and the nuts cannot turn. The fan is bolted rather than screwed into its
   own plastic, so it comes apart as many times as you like. The lead lies in the 8 mm cut above
   the 3 mm seat, wherever it leaves the fan, and drops down the notch in the middle of that side.
   The heads stand 2.2 mm on the fan with 3.49 mm to the glass; the nuts and the last 4 mm of
   thread sit under the carrier, in the 8 mm the ear holds it clear by.

   The pocket is cut to the larger of an M4 nut and an M4 cap head, so **the joint also runs the
   other way up** - cap screw up from the pocket, nut on the fan's face, hex key from below and a
   spanner on top. Nothing about the print changes. Whether it closes does change with the jar,
   because the screw comes in 5 mm steps and the remainder stands over the nut: on `jar_10L` an
   M4 x 40 is 1.76 mm into the glass, and on `jar_1gal_180` an M4 x 35 is 0.59 mm into it, so
   either would have to be shortened. The `fan joint, head down` echo gives that number for the build
   in front of you. Build it heads up unless you have a reason not to.

3. **Magnets into the cap**, opposite poles up: a bar follows a north and a south, and two norths
   hold nothing. Press-fit pockets (0.2 mm on the diameter); a drop of adhesive if they are loose.
   Glue the cap to the hub's face, or stick it with double-sided foam tape, centred - it is a disc
   rather than a skirt because a skirt would foul the blade roots.
4. **Carrier into the bore from above, before the jar.** Turn it until the ear finds the notch at
   the slot's light position and let it down: the ear lands on the two shoulders beside the wire
   groove and the carrier hangs from them, 8 mm clear of whatever the frame stands on. The lead
   comes down the notch between the ear's two legs and straight into the groove, which joins the
   light cord notch already cut through the wall. On a riser the carrier goes into the riser
   instead, before the frame is set on it, and the groove is the riser's doorway out.
5. **Bar into the jar, jar into the base.** The bar sits centred on the punt plateau; the magnets
   find it through the glass.
6. **Blank onto the lid.** The 22x1.5 ring goes in the pocket's groove as it would for the bearing;
   the blank's boss pushes past it, the pin down the bore, and four M4 screws into the inserts.

**What the base gives up for this:** one T-shaped slot at an empty light position - the cord
notch's own profile carried across the floor ring to the bore, and above it a notch 3 mm wider each
side, open at the top, that stops 8 mm short of where the jar lands. Nothing else moves, and the
slot is cut under the shaft drive too, so a base printed today takes either. A base whose magnetic
build stands on a riser gives up nothing: the slot is the riser's.

**Three things it buys** that are on no purchase list yet: the fan, the magnets and the bar. Any of
the size does, which is why none has a part number; `check-bom` says so in its header.

**What it does not do.** The sparger, the baffles and the DO probe's lean are still sized and
placed on the shaft drive's impeller - that geometry is their basis and stays. The echo says so.
And nothing here models the coupling: how much torque two dia 8 discs hand a bar through 6 mm is a
bench measurement, which is why the fan and magnet sizes are parameters rather than answers.

## The sparger

Three spargers, one build parameter: `sparger_name` is `arm`, `ring` or `loop`, and `auto` is the
arm. The ring is what runs under no drive, and the only one the airlift takes, since it centres the
draft tube; the shaft and magnetic builds run the arm, and the loop is theirs to choose.
`jar_10L_220x305` chooses it. All three
hang off the same riser from the `air_in` port, and the other four tubes stay whichever is fitted -
they are the dosing and vent lines, and under the arm or the loop they simply have nothing to socket
into. `head()` reports each as `sparge arm:`, `sparge loop:` or `sparge ring:`, and
[Agitation](agitation.md#sparger) has what those figures mean.

**The arm is the ring's feed without the ring**: the same socket the riser drops into, the same
elbow, and one straight run turned inward to end 5 mm short of the shaft, holes drilled down so the
bubbles rise into the lower impeller. It sits 10 mm under that impeller's blades, which is where a
sparger goes in the stirred-tank literature; the ring sat between the impellers on Birch & Ahmed's
argument, and that argument stays with the ring. Same 1.2 mm holes as the ring; the count follows
the arm's length at the pitch floor, which on `jar_10L` is eight.

**The loop is the arm hooked round into a C.** The same socket, boss and screw on the same riser,
the elbow turned inward, then one tube that hooks onto a C-shape spanning 300 deg round the shaft at the arm's height
with eleven of the ring's holes drilled down, so the gas rises into the lower impeller all the way
round. It is as large as the baffles let it be: inside their inner edge by the lean they and its
own riser can swing through at its height and 1.25 mm, which on `jar_10L` is 75.95 mm across,
1.09 D. On the other jars the hook places it, smaller. It hangs on one riser, and `head()` warns
what sideways force closes its gap to a baffle; seat it, square it to the shaft, and drive the
screw before the lid goes on, since turning it 1.27 deg on the riser closes that gap as well. Its one
end takes the ring's plug screw, and a pipe cleaner goes in there and round to the socket.

**With no drive the ring goes to the floor.** Between the impellers is only a place when there are
impellers; under `drive_name = "none"` the ring's underside sits `sparge_ring_floor_gap` (10 mm)
over the highest glass beneath it, so the column is sparged from the bottom. The supports lengthen
to match - on `jar_1p5L` that moves their stock from a 500 mm length to a 1000 mm one.

**How the riser is held.** The ring's sockets are bored 0.2 mm over the 4 mm tube - a slip fit,
since a printed bore at the tube's own size is a press fit and the ring's five blind sockets cannot
take one - and are 12 mm deep. The ring rests on its six tubes and needs nothing more. The arm and
the loop hang on one, so their socket carries a boss, and the same M4x6 316 set screw that plugs the ring's
ends self-taps into a pilot in that boss and bites the tube by 3 mm: seat the arm, point it at the
shaft, and drive the screw. The arm's end is open through a pilot like the ring's, so a brush
passes, and a second of those screws plugs it.

**The arm's and the loop's socket seals by a press fit.** The gas leaves the riser at the socket's
bottom, and with a slip fit it climbs the annulus round the riser and out of the screw's pilot:
bench runs held at low flow and let small bubbles out at higher. So their socket is 20 mm deep and
its bore tapers from 4.2 mm at the mouth to 3.8 mm at the bottom: the riser goes in freely and is
gripped over the lower 10 mm. The boss is filled down to the part's underside, so stand the part on
a flat surface and press the riser straight down into it until it bottoms, then drive the screw,
which sits 2 mm under the mouth and stops the riser backing out.

**The baffles are as wide as the sparger built lets them be.** Under the ring they stop at
10.35 mm, which is what the ring leaves outside them. Under the arm the lock bore stops them, at
17.09 mm on `jar_10L`; a larger impeller stops them first, since `baffle_impeller_clearance` is a
running clearance, 1 mm to the blades after the lean the port coupling allows. A lid whose plates were printed for the arm does
not take the ring.

**Check-holes covers whichever is built**: the ring, the arm and the loop. A hole drilled down is
cut from outside, so one that stops short leaves a skin under the bore, where the face and the
bore's centreline are both open anyway; a third probe point, in that skin, catches it.

## The wall baffle cage

The standard four baffles stand on the wall, 17.5 mm wide and 2.92 mm off the glass, and their
outer edges are 204 mm apart against a 142.2 mm mouth. So the cage changes shape: two hoops of
r 64-70 pass the mouth lying flat, and each blade slides 30.6 mm in and out on a radial bar at each
end, in a dovetail channel in each hoop. Each bar's outer end is closed under the flange, so it
stops against the hoop and a blade cannot slide through into the middle. `head()` echoes the fit
as `baffle cage:` and the parts as `baffle cage print:`; the geometry is
`scad/custom/baffle_cage.scad`.

**Printing.** PETG, no supports. Both hoops print channels up: the top one turned over with its
arm on the bed, the bottom one as it sits, on its footing. They are mirror images, not one part
printed twice: the dovetail is on one side of the bar only, so the blade prints flat with it on
top. A blade is 238.7 mm long and needs that much bed in one direction.

**Building it, on the bench.**

1. Hold the hoops apart by a blade's length. Slide each blade's two bars into the channels from
   outside, tip first, until the detent at each tip clicks out of the hoop's inside: the blade is
   out, held both ways between that detent and the one outside the hoop.
2. Push each blade in through its two detents' clicks to its stop, 30.6 mm.
3. Lower the cage through the mouth onto the floor, bending the hoops where the pads catch: slid
   in, they stand 2.9 mm a side past it. Turn the gap in the hoops toward the DO probe's port.
4. Reach in and push each blade out until it clicks, against the wall.
5. Fit the lid. The air inlet's riser, the tube the sparger hangs from, drops into the slot in
   the top hoop's arm, which stops the cage turning.

**The lid under the cage.** The hoops are Cs, and the probes hang in the gap. The pH probe goes in
the 30 deg port instead of the 120 deg, and 120, 150 and 270 deg take blanks (`baffle cage ports:`).

**What the bench found.** The hoops' channels are cut 0.10 mm a side and the blades' bars drawn at
0.15 (`baffle_cage_fit()` and `baffle_cage_bar_fit()`), so a change of fit reprints only the hoops.
With the hoops at 0.15 too, some bottom bars sat loose and pushed in at their lower end. At 0.10
both hoops hold the blades, and the cage ran 10 min at 320 rpm with no blade crept inward. A hand
reaches the bottom bars, 240 mm down, for step 4. If a bar binds, sand its flange; if a detent will
not go through, sand it, and if it does not click, it needs to be taller. The model reports the
blades' load at 420 rpm (`baffle cage load:`) but not whether a detent holds against it; the
bench's run is 320 rpm.

## The airlift's draft tube

`drive_name = "airlift"` adds one printed part, `draft_tube`: a plain tube on three feet, standing on
the jar's floor round everything that hangs from the lid. The gas rises inside it and the culture
comes down outside. Nothing holds it but the ring. On `jar_1p5L_112x215`:

```
draft tube: 81.6 mm bore, 85.6 mm outside, 153.172 mm long from 11.6501 to 164.823 mm off the
floor, on 3 feet of 10.3704 mm; 1.4 mm each side through the mouth, and the ring inside it keeps
1.25 mm to its wall, so it shifts up to 1.25 mm
```

1. **Print it in clear PETG, feet down.** It is a straight wall with no overhang; each foot meets
   it through a 6 mm fillet either side (`draft_tube_foot_fillet`), so the corner does not crack.
   An opaque tube makes its core a place the cells only pass through in the dark.
2. **Lower it into the jar first**, feet down and square to the mouth: it passes with 1.4 mm each
   side on both jars, so it goes in straight or not at all.
3. **Centre it by hand**, reaching down its own bore. Standing loose it can sit several millimetres
   off centre on `jar_1p5L` and more on `jar_1gal_155`, and the ring has 1.25 mm to find its top.
4. **Then lower the lid.** The ring goes down inside the tube and ends inside its feet or its wall,
   which holds it there. Everything else hanging from the lid ends inside it.

**It can move.** The ring stops it 1.25 mm off centre where it sits inside the wall, as on
`jar_1p5L`; on `jar_1gal_155` the ring sits among the feet and the tube can shift 2.5 mm. `head()`
checks the probes against the tube shifted that far, and the tightest is `jar_1p5L`'s collets at
0.75 mm. The DO probe hangs straight under the airlift.

## Putting the lid together

The order is forced by geometry, not preference.

1. **Ports into the lid first.** The lock half of every bayonet is printed as part of the lid; the
   pin half is the cartridge that carries the flange, the seal and whatever hangs into the vessel.
   It drops in from outside and turns to lock. Two catch pockets in each flange are there for
   pliers.
2. **Everything that hangs below a port must pass the lock's bore on the way in** - that is what
   sets the baffle plate's width, and the model asserts it.
3. **Then the lid goes onto the jar**, and everything hanging from it passes down through the mouth -
   so _every part of the assembly is level with the mouth at some moment on the way down_. What
   matters is the widest the assembly ever gets, not where it finishes. On `jar_10L` the DO probe's
   collet is the binding part, reaching 70.78 mm against a 71.1 mm mouth - **0.32 mm to spare**.
4. **The probes go in last**, down through the bayonet's bore into the collet. They never pass the
   mouth at all, which is why their length is not part of the clearance above.

### Two ways to assemble it wrong that nothing will catch

**The ring's sockets look identical from above.** (The arm has one socket, and this does not
arise.) The feed socket is an **octagon** and the
support sockets are **round**, and that is the only thing telling them apart, because you cannot see
inside a socket at the bottom of a jar. Get it wrong and the gas goes down a capped tube and
straight back out its own vent hole into the headspace - while the rotameter reads flow and the
culture gets nothing.

**Count the facets.** Both sockets are 6.4 mm across the flats, and the octagon's corners stand only
**0.264 mm** proud of the circle, so feel for the corners rather than glancing. The feed socket is
an octagon because it is the tube's own section.

**The ports are labelled by function for the same reason.** Every tube port bores the same 4.4 mm
for the same 4 mm riser, so the bore on a mark tells you nothing. A gas line on the wrong one vents
into the headspace; a dosing line on the wrong one puts acid where base should go. The marks read
`AIR IN Ø4.4`, `DOSE 2 Ø4.4`: read the word, not the number. Which dose carries what is yours to
record. Baffle ports are marked with the length of plate they carry.

The sparge ring itself cannot be installed rotated: it carries a socket under every tube port -
five on the full lid at 0, 180, 210, 240 and 330 deg - and that pattern is irregular enough that only
one rotation puts them all under ports. On the six-port jars it is three.

### Drilling the support tubes

On a ring build every tube port but `air_in` takes a support tube: capped where it meets the ring, and doing its job
through a hole you drill. Four of them on the twelve-port lid, two on the six-port jars. The model is
the only thing that can dimension that hole, and it does:

```
sparge support drilling: a support tube vents through a hole drilled between
37.9375 and 81.3477 mm from its top end (past the lid's inner face, short of the
culture); nearer the first is better
```

That is `jar_1gal_155x251`. A tube meant to discharge INTO the culture is drilled past the second
number instead.

**Which end of that window depends on the port.** `air_out`, where it carries a tube, is the
exhaust and wants the first number - the headspace is there for foam, and foam finds the lowest
hole. The dosing lines discharge into the culture, so
they are drilled past the second, and low is better: the dose lands where the impeller will carry it
away, and the tube below the hole is a dead leg that keeps whatever it is given.

**Beside a loop or an arm there is nothing to drill.** No ring rests on the dosing tubes, so they are
cut open-ended at the upper impeller's centre, and `sparge tube stock:` gives the length to cut.

**Only `air_out`'s hole has a size to meet**, on the ring's builds, where no condenser takes that
port. The model prices it rather than saying it is the exhaust path and leaving it there. On
`jar_1gal_155x251`:

```
gas exhaust slot: a slot of the tube's own 7.06858 mm2 bore costs 25.9379 Pa at
1.67312 L/min, and the tube above it 9.63158-20.6526 Pa over the 37.9375-81.3477 mm
drilling window, together 0.207856-0.272259% of the 17112.5 Pa the exhaust has to
spend; file past 0.275196 mm2 (a 0.591938 mm round hole), which the bore clears
25.6856x over
```

**On this jar the floor is about 0.28 mm^2, which is a dia 0.59 mm hole.** A normal file cut clears it
many times over, and a shallow pass that only just breaks the 0.5 mm wall is the one way to land
near it. Cut it, then hold the tube up to the light and look through the hole before it goes in.

**Read the floor off your own render rather than off this page.** It moves with the jar, because it
is set by the headroom that jar's gas line has left: 0.275 mm^2 here against 0.108 mm^2 on
`jar_1p5L_112x215`.

That 17112.5 Pa is the same pressure the throttle is currently giving away, and the same headroom an
outlet filter would have to fit inside - so what the slot spends comes off both. The slot and the
tube are already in the line the pump is priced against, at the long end of the drilling window; an
outlet filter, once one is named, joins them there. The three dosing holes meter nothing and need
no size.

Measured from the **top** end, because that is the end you can reach with the tube in your hand.

---

## Closing the lid, and the number that cracks the jar

**This joint is limited by the glass, not by the fastener, and nothing about the hardware says so.**

Twelve posts hold the lid down on a 239 mm circle, 62.6 mm apart: **eight M8 bolts and four M8 tie
rods**, the rods occupying every third position. The bolts' heads bear under the top base; the rods
run the full height of the frame from the lower base. All twelve are tightened by a **nut sitting on
top of the lid flange**, so the operation is the same at every post. On `jar_10L_220x305`:

```
joint load: 4212.27 N of gasket seating over 12 posts = 351.023 N each, on M8
bolts and M8 rods
lid lip: crowned on a 3.5 mm arc standing 2 mm proud of the wall - no flat to
seat on, so the gasket covers the lip and the crown sinks 0.396875 mm into it;
8 mm of gasket, 3.23766 mm of contact
lid gasket load: 3.23766 mm of contact, 4212.27 N to hold 25% squeeze,
2.77566 MPa on the glass
```

**351.0 N per post.** An M8 A2-70 proof load is about 16.5 kN, so the joint runs at **2.1 % of
proof** - the fastener is nowhere near being the limit. A published tightening torque for the same
bolt is 20-24 N-m. This joint wants something near **0.6**. Torque one of these to fastener spec and
you put roughly forty times the intended load onto a soda-lime jar.

### Do not reach for a torque wrench

Torque only ever reaches preload through a friction coefficient, and here you cannot know it. Across
the 0.20-0.30 that an unlubricated stainless nut plausibly spans, 351.0 N is **0.56 to 0.84 N-m** -
a 40 % band from the friction assumption alone. 18-8 galls, which is exactly what makes that
coefficient unpredictable, and 0.7 N-m is below the bottom of most torque wrenches anyway.

### Turn the nut instead

```
joint tightening: 114.3 deg past snug on each of the 12 nuts (0.396875 mm of gasket
travel on a 1.25 mm pitch); the printed flange creeps, so go back to them
```

A turn is geometry. The 1/16 in gasket is 1.5875 mm, 25 % squeeze is 0.3969 mm of travel, and an
M8 x 1.25 thread converts that to **114 deg**. No modulus and no friction enter it.

The rest of the stack barely moves: at 351.0 N an M8 bolt stretches 0.0010 mm over its 20.4 mm grip
and a rod 0.0005 mm over the 10.4 mm between its top-base nut and its lid nut - under 0.3 % of the
gasket's travel either way. The printed flange is the soft part, and it is the one number in this
section without a source: roughly 0.02 mm under a nut face, from PETG's modulus and a nut's bearing
area, which is an estimate and not a measurement. So:

> **Snug, then a third of a turn.** 120 deg is 114 deg for the gasket plus a little for the plastic, and it
> is a mark you can see on a nut where 114 deg is not.

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
cannot actually get there: the recess holds three quarters of the rubber's section and elastomer is
near enough incompressible, so the last quarter has to escape sideways first. Flange-on-glass is
_past_ the design point, not at it.

**And on every jar but the 6.5 gallon there is no land to stop you.** Those lips are crowned, so the
flange has nothing to bottom on and the turn is the only thing setting the squeeze - which is why
this section instructs a turn rather than a torque, and why over-tightening is a real possibility
rather than a theoretical one. Count the turn.

**Do not substitute a harder gasket without re-deriving the joint.** 60A durometer is what sets the
ASME VIII-1 gasket factor m = 0.5, and that is what gives twelve posts. At 75A or harder the same
lid wants sixteen.

### How good is 351.0 N?

Not very, and the model says so. `elastomer_shape_factor()` is the free-bulge form - it assumes both
edges of the pad can spread, and the recess walls are exactly where they cannot. The modulus behind
it is correlated from hardness rather than measured. So 351.0 N and 2.78 MPa are figures for judging
a design, not for cutting a part to, and `elastomer.scad` says as much at the top of the file.

**The turn is the more robust of the two**, which is why it is the instruction. It comes from the
gasket's thickness and the thread's pitch - neither of which is a correlation.

---

## The gas line

Order matters, and two of the joints are ordered for reasons that are not obvious.

```
pump --3/8 in-- reducer --1/4 in-- reducer --1/8 in-- METERING VALVE --
      rotameter --3/16 in silicone-- check valve -- STERILE FILTER -- riser
```

**The metering valve goes upstream of the rotameter.** The meter is calibrated at 14.7 psia, and
putting the throttle ahead of it means the meter only ever sees downstream line loss - which is what
makes the correction 0.7 % instead of something that matters.

**The rotameter's two adapters are deliberately different sizes**, 1/8 in in and 3/16 in out, so the
line steps up inside the meter's own bore rather than through a coupler. One less joint.

**The sterile filter is the boundary.** Everything downstream of it is inside the sterile envelope
and is platinum-cure silicone; everything upstream can be PVC or polyurethane, and the barbed
fittings on that side are rated for firm line rather than silicone.

**One clamp size, `5011T141`, closes all fourteen joints**, as long as the 3/8 in run is bought in
1/16 or 3/32 in wall: in 1/8 in wall it sits at the clamp's last thread. Snug each with the 1/4 in
nut driver and stop - a wrench will strip one, and these get opened again at every filter change.
Why this clamp, this grade and this wall: [Procurement](procurement.md#hose-clamps).

The check valve exists to stop culture siphoning back into the pump when it stops. It is not
optional.

**Nothing filters the way out, and do not fit a second inlet filter there.** The headspace vents
through the coil condenser into the room. A second `1594522` on the outlet would hold the reactor
under 0.5 vvm; an outlet filter has to fit the budget `head()` reports as `gas exhaust:`. Why:
[Procurement](procurement.md#gas-metering).

---

## The exhaust condenser

**The coil is on the lid's lists.** Its body is `air_out`'s pin, so that port carries no tube and
no slot: the headspace leaves up the condenser's bore and out of its 4.5 mm outlet barb, which
`head()` prices in the gas line. Every build whose sparger is not the ring takes it
(`condenser_name`); the ring's builds keep `air_out`'s tube, which holds the ring. `just export-parts`
writes the body, panel, former and both pucks, each in the orientation it prints in. The split cold
finger prints from its own file, `custom/condenser_cold_finger.scad`. See #134 and #135
for what the prints still have to prove.

**Print the bodies to hold gas, and anything that holds water to hold water.** A condenser body is
the exhaust path: gas that leaks through its wall bypasses the cold and carries water out with it.
The cold finger's flow insert is the only wall between coolant and the gas, so a weep there drains
into the culture. For both, print at the hot end of the filament's range, with four or more walls,
0.15 mm layers and a touch of extra flow (about 105 %). Leak paths run through the walls, not the
infill, so walls are what to spend on. Water-test the flow insert before it goes on the reactor.

**Print the open well's lid the other way: sparse.** It is insulation over the ice, so low infill in a
pattern that boxes the air into cells, honeycomb or cubic rather than one that leaves it free to
move. Keep its dia 1.5 vent open; ice melting and water warming push air out through it, and a sealed
lid would pressurise the well.

**The coil is wound on the former, and the former stays in.** A coil whose bottom end runs back up
its own middle cannot come off a one-piece mandrel: to unscrew, the mandrel's ridge has to sweep
through the leg. So there is no mandrel. The former is the arbor - chuck the stub below the coil,
wind, and it stays in the reactor holding the turns at pitch, in the dead space it already blocks.
`part = "puck_bottom"` and `part = "puck_top"` are the only tools, one for each end's radius.

1. Bend the bottom end while the tube is still straight and a bender has room, on `puck_bottom`: a
   quarter turn inward, then a quarter turn up, leaving a leg the height of the coil.
2. Lay that end into the former's channel **from the side** - the bends into the foot, the leg up
   the groove. Nothing is threaded into a hole, which is the step that cannot be done later. A tie
   through the stub holds the tail while the first turn goes on.
3. Wind up the former, pushing each turn down onto the ridge below it. The ridge's flat top is what
   sets the pitch; the slack above each turn is there because a part printed standing cannot hold an
   overhang past 45 deg, and it is why the winding direction matters.
4. Bend the top end on `puck_top`, in open air above the coil: inward a quarter turn, then up.
5. Lower the panel onto the two ends - they are already vertical and parallel - and onto the
   former's spigot. An M3 x 14 cap head goes in radially through the counterbore in the coupling's
   face, crosses the socket and bites the spigot.

The two ends bend at different radii on purpose. The bottom one has to finish inside the coil, so
9.5 mm is as gentle as it can be; the top one only has to reach a seal, so it bends at 11.25 mm and
lands further out, which is as far as the coupling's core lets a seal sit.

A length that has been bent back and forth work-hardens and cracks at the next bend; start from a
fresh piece rather than straightening one.

**The coil condenser's aluminium tube never goes through the vessel's bleach step.** It takes the
7.5 % peroxide with everything else; bleach and chlorite attack it.

---

## The turbidity sampler

On the full lid it takes port 10, at 300 deg: at 330 deg it stood in the coil condenser on `air_out`.
`just export-parts` writes its base and top as they print, and the render's `sampler:` line gives
the riser's cut length and the clear tube's length for your jar. On `jar_10L` that is a 200.7 mm
riser, ending 114.8 mm under the culture's surface, and a 44.6 mm clear tube. It is a flow cell
round the turbidity probe's bare board, with a syringe actuator bolted on top drawing culture up a
clear tube between the board's heads; the screws, nuts and inserts are on the purchase list.

**The riser is the dip tube.** It is the port's own sparge riser, cut so its top end stops inside
the base and its open end stands at the culture's mid-depth, where the sample is drawn. The clear
tube runs 16 mm down over its top end, a sleeve of 1/8 by 1/4 in silicone tubing between them.

**Fit the luer-to-barb fitting first.** Warm the clear tube's end with a heat gun, push the barb in
until the tube reaches the fitting's centre flange, and let it cool. The stretched 18 mm stands above
the heads, where the tube's bore has widened for it.

1. Heat-set two M3 inserts into the top's outer corners and one M2 into the base's inner end, each
   from its parting face.
2. Drop the board into the top upside down, heads first, connector outward.
3. Close the base onto the top: two M3 button heads from below, and the M2 countersunk from above
   down the slot in the top's skirt, with a ball-end hex key, since the face stands over it.
4. Drop the clear tube down the shroud. Its bore narrows to a snug fit only between the heads, and
   the tube's end seats in the base; the riser comes up through the pin's o-ring into its bottom.
5. Open the actuator's four front knockouts. Push four M3 x 10 screws up through the face from the
   counterbores under it, lower the actuator over them, and run a nut onto each from inside through
   its roof's window, a flat against the side wall, which holds it. Tighten from below.

This order is the design's; the first full assembly will confirm it.

## The e-stop box

A box for the panel-mount e-stop: it prints from its own file, `support/estop_box.scad`,
`part = "base"` and `part = "lid"`, the base open side up and the lid flat. The e-stop's neck goes
through the lid's bore and its nut clamps the lid; the body hangs into the base, and the two
channels' four wires leave by the hole in one wall.

**Measure the e-stop first.** The file's first four parameters are its body below the panel -
height, width and length, contact blocks included - and the panel cutout its neck takes. The box
is square on the wider side, with `wire_space` kept round the body and below it; rendering echoes
the closed size. `lid_thickness` has to be inside the panel range the e-stop's nut clamps.

**Fit the e-stop to the lid, then close the box.** The four lid screws are M3 self-tapping, into
pilot holes in the base's corner posts; for heat-set inserts set `screw_pilot_diameter` to the
insert's hole. Fit a grommet or gland in the wire hole before the wires go through it.

## The sparge test pucks

Bench parts, not reactor parts: how to print and run them is in
[Sparge test pucks](../analysis/methods/sparge-test-pucks/README.md).

---

Once it is together, the first run is [Commissioning](commissioning.md).
