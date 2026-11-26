# Building it

This document covers the hands-on build. The other documents explain why the reactor is designed
the way it is. This one lists what to cut and what to print, the order of assembly, and the numbers
that will break something if you get them wrong.

The figures here are for the reference build, `jar_10L_220x305`, taken from its echo transcript.
Tolerances of purchased parts come from [`purchased-parts.csv`](../purchased-parts.csv). The figures
change with the jar: for a different jar, render `scad/bioreactor.scad` for it and read them from the
output.

---

## Nothing here has been built yet

This reactor has not been printed or assembled. Every number below is derived from the model, and
no physical part has yet been checked against the model. Expect the first build to correct this
document.

Three figures in particular are ranges rather than measurements, and all three need a bench test
(see [What to record](commissioning.md#what-to-record)):

- the **sterile filter pressure drop**, extrapolated from a comparable disc. It is the largest single
  term in the gas budget.
- the **jar rim profile**, which every seal is measured against and which nobody has measured with
  calipers
- the **baffle lean under load**, which the model reports as a worst case and states is a worst case

Not every vessel takes every drive. `jar_1p5L_112x215` and `jar_1gal_155x251` cannot carry a
top-entry drive on the lid at any mount size. On the first, the mount overlaps the port flanges. On
the second, the pH probe passes through the lower impeller, because in a 155 mm bore the port circle
and the impeller need the same radius. Both are therefore built as airlifts, with no drive and a
draft tube, and both can also take the magnetic drive. The working builds are the parameter sets in
`scad/bioreactor.json`, and `just check-builds` fails if one of them stops building.
[Agitation mode per vessel](agitation.md#5-agitation-mode-per-vessel) lists which drives each vessel
cannot yet take, and why. The bench tests that would settle the airlift and magnetic builds are #86
and #87.

---

## What you print

None of these parts are on the purchase list, because it covers only bought parts. Nothing else in
the build will remind you to print them.

**From `head.scad`:**

- the **lid**, as one piece: flange, plug, bearing pocket, insert holes, gasket recess, o-ring groove,
  and all twelve or six bayonet _lock_ halves. The locks are not optional detail. Their channels
  form the walls of the lid bores, so a lid exported without them has plain holes that nothing can
  lock into.
- the **port pin halves**, one per port: tube ports for `air_in`, `air_out` (only on the ring
  builds; elsewhere the coil condenser body is that pin) and the dosing lines (`dose_1`, `dose_2` and
  `dose_4` on the twelve-port lid, `dose_1` on the six-port lid); probe ports with integral flex
  collets for DO and pH; and a thermocouple port carrying an NPT mount
- a **blank port** for each bayonet size the lid uses: a pin with no bore, labelled `BLANK`, to close
  an empty port during cleaning, testing or servicing
- the **baffle ports and plates**: one plate per baffle port, split into dovetailed pieces only where
  a single piece would be too slender to print standing (see below), and none on the six-port lids.
  A build that carries the wall cage gets the **cage** instead: a top hoop, a bottom hoop, four
  blades, and three more blanks for the ports the plates would have used (see
  [The wall baffle cage](#the-wall-baffle-cage)). Both `jar_10L` builds carry the cage:
  `jar_10L_220x305` names it, and `baffle_name = "auto"` selects it on `jar_10L_magnetic`.
- the **coil condenser** on `air_out`, in five parts (body, panel, former and two pucks), on every
  build whose sparger is not the ring (see [The exhaust condenser](#the-exhaust-condenser))
- the **turbidity sampler**, on the twelve-port lids, in two parts: the base, which is the pin for
  its port, and the top (see [The turbidity sampler](#the-turbidity-sampler))
- the **motor mount**, in three parts: base plate, face plate and middle stand
- **two impellers**
- the **sparger**: the arm, or the ring or the loop if the build names one (`sparger_name`; see
  [The sparger](#the-sparger))

**From `frame.scad`:** the base, the top base, **eight ribs**, **twelve rod spacers** and **three
dosing pump mounts**, plus **two heat pad plates** on a build that names a heating pad (both
`jar_10L` builds). The ribs are one part printed eight times. Each is rotated by a multiple of 90 deg
and cut by the same lights cutout, so the exported meshes differ only in how the cut surface is
tessellated.

**The drive changes two of these lists.** `drive_name` in `bioreactor.scad` is `shaft` (listed
above), `magnetic`, `none` or `airlift`. The magnetic drive removes the motor mount and the
impellers from the head list and adds a **bearing blank** in their place. It adds the **stir
carrier** and the **hub cap** to the frame list, and on `jar_1gal_155` and `jar_6p5gal` the **stir
riser** as well. On the default lid, the lid and the base are the same parts for either drive. The
lid keeps its bearing pocket, bore and inserts, and the blank plugs them: its boss is the size of the
bearing and is sealed by the pocket o-ring, its pin fills the shaft bore, and its flange bolts to the
four inserts with the motor mount screws. The base is slotted for the carrier whichever drive a
build names. The exception is a jar whose magnetic build stands on a riser, where the riser carries
the slot. See [The magnetic drive](#the-magnetic-drive).

`none` prints the parts of neither drive. `airlift` is `none` with a draft tube added: the gas alone
moves the culture, and the sparger is the ring unless the build names the arm. The airlift lid is
plain, with no pocket, bore or inserts. `lid_center_name` sets this: `bearing` for the convertible
lid above, `plain` for this one, and `auto` selects plain under `none` or `airlift` and bearing
otherwise. A magnetic build sets `plain` where the flange of the blank would not clear the ports, as
`jar_1p5L_magnetic` and `jar_1gal_155_magnetic` do. That lid cannot later take the shaft drive.

**Tools, printed once:** the three parts of the gasket cutter. The base is printed once and kept,
because it is the same for every gasket. The outer disc and inner plate depend on the cut and are
reprinted when the vessel changes.

Use food-grade clear PETG for parts in contact with the culture, and grey PETG for structural parts.
Food-grade is a purchasing requirement, not a colour: a clear spool is not necessarily food-grade,
and the wetted parts are in contact with the culture for the whole run.

### Two things about printing them

**Each Rushton turbine prints as two halves, and all four halves are the same part.** Printed
standing on its blades, a disc turbine has its disc overhanging the whole ring between hub and
blades, and supports there leave the disc rough. Split at the mid-plane of the disc, each half
prints on its half-disc with no overhang. Turn one half over onto another and align them with two
lengths of 1.75 mm filament in the pin holes at 90 and 270 deg. The blades are at multiples of
60 deg, so they line up. The part is `impeller_half` on the print list, quantity four. A turbine too
small for its half to take the set screw hole prints whole, and `head()` warns.

**The two impellers of a pitched pair are mirror images, not the same part turned over.** Pumping
direction depends on the handedness of the blades, and rotating a part cannot change it. They are
therefore two different STLs. A pair printed twice from one file pumps in the same direction and does
not converge on the sparge ring. Rushton blades are flat and have no handedness, so the two in the
reference build are the same part.

**Export the motor mount from `head.scad`, not from `motor_mount.scad`.** `motor_mount.scad` will
build a mount on its own, but that mount does not match the holes the assembly drills in the lid.
The file states this itself.

The baffle plates are split when a piece would be too slender to print standing. On
`jar_1gal_180x197`, the registered jar that uses hanging plates, one piece passes:

```
baffle print: 1 piece of 165.218 mm, tallest standing 188.218 mm against a 200 mm slenderness cap
```

Where a plate is split, as on `jar_10L` fitted with lid plates (`baffle_name = "lid"`, two pieces of
136.997 mm), the pieces join with a dovetail. On a larger printer you can set `baffle_segments = 1`
and print each plate whole, which is stiffer. When the plate is split, the joints account for 14 %
of the tip deflection.

**The dovetail slides along the plate's width, and this is chosen for the load.** The swirl pushes on
the face of the plate. With the slide across the width, that load bears on the dovetail flanks, and
the one free axis carries only vibration. A blind end registers the pieces. The butt faces meet, so
the 0.1 mm allowance is flank clearance only and the plate keeps its length. The design parameter is
the neck, which is the only material crossing the joint plane, rather than the depth of the tail. A
shallow 10 deg flare adds engagement without reducing the neck.

**Two aspects of the joint are not modelled.** The first mode that `head()` reports is for a solid
plate; the joints lower it by an amount that is not computed. A 0.1 mm crevice at the joint also sits
in the culture, in a vessel that is chemically sterilised rather than autoclaved. This is a cleaning
risk that the design does not address.

**The slenderness cap depends on the part, not on your printer.** It limits the height of a piece to
**three times its own section**: a brim as wide as the part on each side, which is why a brim is worth
printing on a part this slender. The rule gives **205.07 mm**, and the **printer ceiling clamps the
cap to 200 mm** (the shortest registered build height less 10). The echo therefore reports 200,
against the 188 mm tallest piece on `jar_1gal_180x197`.

The limiting piece is not the obvious one. The piece carrying the port stands on a **28.2 mm
flange**, which is a wide foot. A tip piece stands on its section alone, which makes it half again as
slender. That section is **17.09 x 10 mm**, the widest plate the lock bore of the port will pass, and
also the plate size on `jar_1gal_180x197`. The cap is therefore a property of the port and is the same
on every vessel.

`just export-parts` writes each of these parts as its own STL, with a print list beside them. It
renders each part with CGAL as it goes, so a part that is not a valid solid is caught there rather
than in a slicer. It also measures each part and reports which registered printers can print it. It
covers the parts of the reactor itself (the lid and everything hanging from it, and the frame base,
top base, ribs and rod spacers): **49 pieces across 25 distinct parts** on `jar_10L_220x305`.

**A build is a parameter set in `scad/bioreactor.json`**: a vessel and whatever it designates.
`just export-parts jar_10L_magnetic` exports that build to `output/jar_10L_magnetic/`, and the print
list begins with the model's own description of the build (vessel, drive, fill, and every
designation not left at `auto`). To check one part while working on it,
`just export-part frame_base jar_10L_magnetic` renders that row alone in a few seconds and writes no
list.

**`just export-parts` with no build exports every registered build, grouped by vessel**, to `build/`:

```
build/jar_10L_220x305/
  common/     the frame, the gasket cutter, the lid, the ports, the sparger
  stirred/    the motor mount and the impellers
  magnetic/   the stir carrier, the hub cap and the bearing blank
```

`common/` holds the parts that every registered build of that vessel prints identically (the same
part judged by its geometry rather than its name, and not specific to one drive), so they are printed
once. Each drive folder adds the parts specific to that build. A vessel with only one registered
build still has its drive-specific parts split out. Each distinct part is rendered once, and each
vessel folder is replaced whole, so its contents always match what the model prints now.

The parts are rendered in parallel on every core, so the whole list takes about as long as the lid
alone.

**Pictures** come from the same model. `just render-parts jar_10L_220x305` renders each part on that
print list separately, to `output/figures/jar_10L_220x305/parts/`. `just render` renders the views
listed in `scad/views.tsv`: the whole assembly and a cutaway, the head and the frame separately, and
the components. `just render 'head_*'` renders only the rows it matches. To add a figure, add a row
to that file; its header lists what a row can specify.

**Exploded views** use the `explode` parameter in `head.scad`: the spacing in mm between neighbouring
parts along the vessel axis. The default, 0, is the assembled state and moves nothing. The lid stays
in place. The drive stack lifts off it in assembly order (inserts, bearing, mount base, its screws,
the coupler, the stand, the face plate, the motor), and the shaft and impellers drop below. The port
o-rings, pins and probes lift off above, and the rim gasket and plug ring drop below.
`just render '*exploded*'` renders the drive and the lid exploded at 40 mm.

**Without OpenSCAD:** the Export workflow on GitHub runs the same export on demand and on every tag,
one job per build, and attaches the STLs and the print list to the run as a downloadable artifact
(`stl-<build>`). It is also the only place in CI where the printed parts are checked with CGAL.
`just test` covers the previews of the entry files, not the manifests.

Not everything printed for this repository is listed above. The bench around the reactor has its own
list: `just export-accessories` writes three **bottle holders** (one per dosing bottle, sized for the
86.1 mm round bottle), the base and lid of the **e-stop box**, and the printed corner of the
**electronics stand** to `output/accessories/`, from `accessory_print_parts()` in
`scad/support/accessories.scad`. The cart has no printed parts and was never built
([future work](../dev/future-work.md#bench)).

**Printer size.** Three parts are **257.6 mm discs** (the lid, the frame base and the top base), and
they are by far the widest parts in the build. A disc has the same width at every angle, so it cannot
be rotated to fit a narrow bed. Your printer needs `min(X, Y)` of at least 257.6.

`scad/bioreactor.scad` reports this on every render, calculated from the geometry rather than the
meshes, so agreement with `just export-parts` confirms that no part has dropped off a manifest. It
checks against the printers registered in
[`scad/purchased/printers.scad`](../scad/purchased/printers.scad): the **Prusa CORE One L**, the
**Bambu H2D**, the **Sovol SV08**, a **Voron 2.4 350** and the **Prusa XL**.

A **Bambu X1C** has 256, which is **1.6 mm** short. A **Voron 250** is 7.6 short. A **Prusa CORE
One** is 250 x 220 and cannot print it at any margin, because the jar alone is 220 mm across and the
lid has to overhang the glass to carry its bolts. Trimming the lid does not help: the frame bases are
also 257.6, and their wall is set by the rod bosses.

---

## What you cut

| Stock                              | Cut                                      | Yield                                           |
| ---------------------------------- | ---------------------------------------- | ----------------------------------------------- |
| M8 threaded rod, DIN 975 A2        | **4 x 322 mm**                           | buy 1500 mm or more                             |
| 316 SS tube 4 x 0.5 mm, `50415K21` | **1 x 265.3 + 3 x 187.9 + 1 x 200.7 mm** | 1029.9 mm from a 2000 mm length, 970.1 mm spare |
| EPDM sheet 1/16 in 60A, `8525T65`  | **142.2 x 158.2 mm** per lid             | 1 per 304.8 mm sheet                            |

**The rod length depends on the jar, not on the design.** 322 mm is for `jar_10L`; it is 214 mm on
`jar_1gal_180` and 487 on `jar_6p5gal`. It is calculated as vessel 305 + flange 8 + nut 6.5 + 2.5 mm
left above the top nut, so a different vessel height changes it directly.

**Deburr the tube bore after cutting. This is a required step, not an optional one.** A wheel cutter
rolls the 0.5 mm wall inward at the cut, and the riser bore is only 3 mm, so the restriction is
exactly where the gas enters. The registered tool is a NOGA RC1000, whose minimum bore is not
published; check that its blade reaches 3 mm before relying on it. A round needle file does the same
job on two cuts. A jeweller's saw in a mitre jig avoids the problem instead of correcting it, because
a saw does not roll the wall inward.

Cut the rim gasket with the printed cutter, not by hand. All the work is done on the base: it is the
cutting surface, it holds the nuts, and both stages screw to it, so nothing has to be aligned by eye
on a board.

1. **Put three M4 nuts into the channels** on the underside of the base, and one into the hex pocket
   at its centre. The nuts cannot turn, but they slide along their channels, which lets one base
   serve every gasket size.
2. **First cut.** Lay the sheet on the base, put the outer disc on it, and run a screw through the
   centre of the disc into the central nut. Cut around the disc. The screw pierces the sheet at its
   centre, which is waste that the inner cut removes.
3. **Second cut.** Leave a short screw standing in the centre and drop the blank over it, or just
   lay the blank on the base. Lower the inner plate onto it. The mouth of the counterbore is flared,
   so it guides the blank into its seat as the plate comes down. Run the three clamp screws through
   the plate and the slots in the base into the nuts. Cut along the bore.

   The base has two rings of slots. Each plate uses whichever ring clears its own blank: the inner
   ring for the small jars, the outer for the large. Move the nuts to match the plate you printed.
   The ring the plate does not use stays clear of every cut.

The plate stands `grip` (0.4 mm) proud of its seat, so it closes on the rubber and pinches the blank
rather than resting on the base. The concentricity of the finished ring is set by a printed
counterbore, not by hand.

---

## Fits you make

Most of the fits in this reactor come with purchased parts. These are the ones you make at the
bench, and each depends on a number.

**The bearing is a press fit: heat the race and chill the shaft.** The shaft is 7.995-8 mm in an
8 mm bore, so the fit ranges from 0.007 mm interference to 0.005 mm clearance. The pocket in the lid
is 22.2 mm for a 22 mm outside diameter. The joint should feel tight on assembly. **Keep the bearing
out of the bleach step for the vessel**: its 440C and Buna-N are the weak point against the
sterilant ([why](procurement.md#bearing)).

**Heat-set the four M4 inserts into the lid from the mount face.** Each insert is 4.7 mm long and
goes into a 5.6 mm hole, with 13.25 mm of lid below it. The inserts go in once and stay. The M4 x 8
screws come out every time the mount does. The insert has only 4.7 mm of thread, so a longer screw
bottoms out instead of clamping. Screw and insert are both 18-8, so take care not to round the
socket.

**The impeller bore is a slip fit, and the set screws locate the impeller.** The bore is 8.4 mm
straight through on an 8 mm shaft, giving 0.4 to 0.405 mm of clearance before print shrinkage, so an
impeller slides to its height and is fixed there. If your printer prints the bore undersize, open it
with a reamer or a drill. `head()` reports the clearance it was designed for.

**The impeller set screws cut their own thread.** The hole is printed at the 3.3 mm tap size, and no
thread is modelled. Printed holes come out undersize, so expect to open one. A split impeller has no
collar: each half takes two screws in its hub, between the blades at 30 and 150 deg, so there are four
per impeller. An impeller printed whole takes two at 0 and 120 deg, through the 8 mm collar above the
blades. Either way there is 5.8 mm of thread. The screws are cup-point on purpose. They bite the
shaft rather than relying on friction, because once the bore slides they are all that holds the
impeller.

**The o-rings are seated in four different ways, and only one is stretched.**

| Seal                           | How it seats                                               |
| ------------------------------ | ---------------------------------------------------------- |
| Lid plug, `AS568-160`          | **stretched 3.67 %** onto a groove cut from the jar's bore |
| Port face seals, 12 of them    | seated in a gland cut to fit the ring, no stretch          |
| Riser rod seals, `8785N364` x5 | **0 % stretch** - the ring's ID _is_ the 4 mm tube         |
| Bearing rim seal, `8785N382`   | **0 % stretch** - the ring's ID _is_ the 22 mm bearing     |

**Fit the bearing seal before the bearing.** Drop the 22x1.5 o-ring down the pocket and let it expand
into the groove at mid-depth, then press the bearing past it. It seals on the **outer race** of the
bearing, which does not turn. The inner race turns, and on a 608 both race faces are flush, so a
gasket under the bearing would be clamped against a rotating steel face. Nothing seats _on_ the
pocket floor; the bearing still bottoms there.

The rod seals go into an enclosed groove just above the **inner** face of the lid, and they go in
**before** the tubes pass through, because that face cannot be reached once the lid is on the jar.
There is one per tube port: five on the full lid, three on the six-port jars. Fold each ring into its
groove, then work it around and seat it with a small flat screwdriver.

**The silicone tubing fits differently at every joint, and the risky joints are all downstream.** One
tubing size, 3/16 in ID, runs from the meter to the ring. It fits **at its native size** on the check
valve barb, is **stretched 33 %** onto the 1/4 in step of the sterile filter, and is **0.76 mm loose**
over the 4 mm riser, where a worm clamp closes it. Watch the filter joints: silicone creeps, and that
joint is the sterile barrier. A leak upstream of the rotameter only loses flow, which you then dial
back in. A leak downstream means the vessel gets less gas than the meter shows, and every vvm figure
in [Agitation](agitation.md) is wrong by that amount. All four risky joints (two at the check valve,
two at the filter) are downstream.

---

## The magnetic drive

A PC fan in a printed carrier hangs in the bore of the base. Two magnets sit in a cap on the fan hub,
and a PTFE stir bar sits on the punt inside the jar. Nothing passes through the lid. This is what the
model selects and where it places it on `jar_10L_magnetic`:

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

**The fan is selected by a rule, not named.** From the NopSCADlib fans, the model takes those with
the widest hub whose corners clear the carrier pocket and whose depth fits under the jar with room
reserved for the fan joint, and of those, the thinnest. Hub size is the sort key because the magnets
are carried on the hub, and a larger frame around a smaller hub gains nothing. The result is an
80 x 25 on `jar_10L` and `jar_1gal_180`, a 40 x 11 on `jar_1p5L`, and, on a riser, a 60 x 25 on
`jar_1gal_155` and a 120 x 25 on `jar_6p5gal`. The magnets and the bar are named
(`stir_magnet_name`, `stir_bar_name`), because a lab usually has some on hand. The defaults are two
dia 8 x 5 discs and a 38 mm bar, and the other registered sizes are in `purchased/magnets.scad` and
`purchased/stir_bars.scad`.

**The floor under the jar is lowered for the fan, up to a limit.** The frame extends below the jar by
however much the light stack exceeds the jar height. The floor uses the deeper of that and what the
fan and the magnets need, so a jar with a short light stack still gets a drive. `jar_1p5L` is 3.77 mm
deeper for this and gains a carrier. `carrier_floor_lift_max` (10 mm) sets the limit; beyond it, the
base would be mostly added floor. The floor does not depend on which drive a build names, so the base
is still one print for either drive.

**Beyond that limit, the magnetic build stands on a riser.** `jar_1gal_155` needs 36 mm more than its
light stack leaves, and `jar_6p5gal` needs 35. Their bases keep the floor set by the lights, and a
magnetic build of either adds `frame_stir_riser`, which makes up the difference under the whole frame.
On `jar_1gal_155_magnetic`:

```
stir riser: 36 mm under the base, which keeps the light's 4 mm floor; walls at r [50.15,
63.65, 82.25, 94.95], keyed into every light's cord notch
```

The riser is walls only, 3 mm thick (`riser_wall`), so it prints as it stands, with nothing to bridge
except the doorways for the fan lead. It has four rings:

- one around the carrier, at the bore of the base
- one under the circle the jar lands on, since the floor ring above it is only 4 mm on `jar_1gal_155`
  and would otherwise span unsupported
- one under the middle of the lights, which holds them against the underside of the base as the
  bench would
- one around the edge of the base, so the reactor stands on the full width of the base

Four spokes on the quadrant lines join the rings. The carrier hangs in the riser exactly as it does
in a deep base: a block on its ring carries the same groove and ear notch, and the groove continues
out through the other rings as the doorway for the lead.

The riser locates in all twelve cord notches of the base. In each notch, a key runs from the seat
face to the edge and fills the notch, less the 0.3 mm a light keeps in its seat. The riser therefore
centres on the base as closely as a light sits in its seat, and every seat stays clear. **The light
cords leave from the top**, against the top base, which is also where a light seats best. The reactor
stands 36 mm taller on the riser. A build with any other drive stands on the bench.

1. Stand the riser on the bench, drop the carrier in with its ear down the notch, and lead the
   wire out through the doorway.
2. Fit the lights into the frame with the cords up, then lower the frame onto the riser with a key
   in every cord notch.

The carrier ear stands 23.8 mm above the bench, so a riser has to be at least that tall to hold the
carrier under the base. A drive that needs between 10 and that height below the light floor fits
neither the base nor a riser, and the model reports this. No registered jar falls in that range.

**The carrier height is set by the magnets, not by the fan.** The magnet faces are held
`stir_magnet_glass_clearance` (1 mm) below the jar punt, at the outer edge of the magnets where the
cone is lowest, and the carrier top is positioned down from there. It is never above the plane the
jar lands on. This is what "faces 1 mm under the punt and 6 mm from the floor inside" means: 1 mm of
air and 5 of glass between the magnets and the culture, with the bar axis 4 mm above that.

That upper limit is why a deeper floor does not help every jar. Where the punt rises higher than the
magnets and their cap need, the carrier stops at the landing plane and the cap grows instead. It adds
a solid floor under the magnets, up into the void of the punt, until either the magnets reach their
clearance or the cap rim reaches its own. On `jar_10L` the rim limits first, so the cap is 8.39 mm
tall and the magnets sit 1.24 mm under the punt. On `jar_6p5gal` the punt rises 15 mm at the magnets
and the cap grows 8 mm to reach 1 mm, but the 12 mm wall of that jar still puts the magnets 13 mm
from the culture, compared with 4-6 mm on every other jar. Floor depth is not the problem on that
jar.

**Assembly, in the order the parts allow:**

1. **Print the carrier pocket up, as modelled.** It needs no supports: it is solid under the fan,
   every wall is vertical and the wedge on the ear slopes upward.
2. **Put four nuts into the hex pockets in the bottom face**, then **lower the fan into the pocket
   from above**, hub up, with its lead on the side where the pocket wall is cut down. That side faces
   the slot in the base. Drive four M4 x 40 screws down through the corner holes of the fan into the
   nuts, with one driver from above; the nuts cannot turn. The fan is bolted rather than screwed into
   its own plastic, so it can be taken apart any number of times. The lead lies in the 8 mm cut above
   the 3 mm seat, wherever it leaves the fan, and drops down the notch in the middle of that side.
   The screw heads stand 2.2 mm above the fan with 3.49 mm to the glass. The nuts and the last 4 mm of
   thread sit under the carrier, in the 8 mm of clearance the ear holds it at.

   The pocket is cut to fit the larger of an M4 nut and an M4 cap head, so **the joint can also be
   assembled the other way up**: cap screw up from the pocket, nut on the face of the fan, a hex key
   from below and a spanner on top. The print does not change. Whether the joint closes does depend
   on the jar, because screws come in 5 mm steps and the excess length stands above the nut. On
   `jar_10L` an M4 x 40 reaches 1.76 mm into the glass, and on `jar_1gal_180` an M4 x 35 reaches
   0.59 mm into it, so either would have to be shortened. The `fan joint, head down` echo gives that
   number for your build. Assemble it heads up unless you have a reason not to.

3. **Fit the magnets into the cap** with opposite poles up: a bar follows a north and a south pole,
   and two norths hold nothing. The pockets are a press fit (0.2 mm on the diameter); use a drop of
   adhesive if the magnets are loose. Glue the cap, centred, to the face of the hub, or fix it with
   double-sided foam tape. It is a disc rather than a skirt because a skirt would foul the blade
   roots.
4. **Fit the carrier into the bore from above, before the jar.** Turn it until the ear finds the
   notch at the light position of the slot, and let it down. The ear rests on the two shoulders beside
   the wire groove, and the carrier hangs from them, 8 mm clear of whatever the frame stands on. The
   lead runs down the notch between the two legs of the ear and straight into the groove, which joins
   the light cord notch already cut through the wall. On a riser, the carrier goes into the riser
   instead, before the frame is set on it, and the groove is the doorway out of the riser.
5. **Put the bar in the jar, and the jar in the base.** The bar sits centred on the punt plateau,
   and the magnets couple to it through the glass.
6. **Fit the blank to the lid.** The 22x1.5 o-ring goes in the pocket groove as it would for the
   bearing. Push the boss of the blank past it with the pin down the bore, and drive four M4 screws
   into the inserts.

**What the base gives up for this:** one T-shaped slot at an empty light position. It is the profile
of the cord notch carried across the floor ring to the bore, with a notch above it that is 3 mm wider
on each side, open at the top, and stops 8 mm short of where the jar lands. Nothing else changes, and
the slot is also cut for the shaft drive, so a base printed today takes either drive. A base whose
magnetic build stands on a riser gives up nothing, because the slot is in the riser.

**It needs three parts that are not yet on the purchase list:** the fan, the magnets and the bar. Any
of the right size will do, so none has a part number; the header of `check-bom` says so.

**What it does not do.** The sparger, the baffles and the lean of the DO probe are still sized and
placed for the shaft drive impeller. That geometry remains their basis, and the echo says so. Nothing
here models the coupling. How much torque two dia 8 discs transmit to a bar through 6 mm is a bench
measurement, which is why the fan and magnet sizes are parameters rather than fixed answers.

## The sparger

There are three spargers, selected by one build parameter: `sparger_name` is `arm`, `ring` or
`loop`, and `auto` selects the arm. The ring is used with no drive, and it is the only sparger the
airlift takes, because it centres the draft tube. The shaft and magnetic builds use the arm, and can
choose the loop instead; `jar_10L_220x305` does. All three hang from the same riser from the `air_in`
port. The other four tubes stay whichever sparger is fitted. They are the dosing and vent lines, and
with the arm or the loop they have nothing to fit into. `head()` reports each sparger as
`sparge arm:`, `sparge loop:` or `sparge ring:`, and [Agitation](agitation.md#sparger) explains those
figures.

**The arm is the ring feed without the ring**: the same socket that the riser drops into, the same
elbow, and one straight run turned inward to end 5 mm short of the shaft, with holes drilled downward
so the bubbles rise into the lower impeller. It sits 10 mm below the blades of that impeller, which
is where the stirred-tank literature places a sparger. The ring sat between the impellers following
the argument of Birch & Ahmed, and that argument applies only to the ring. The arm uses the same
1.2 mm holes as the ring. The hole count follows from the arm length at the minimum pitch, which gives
eight on `jar_10L`.

**The loop is the arm bent around into a C.** It has the same socket, boss and screw on the same
riser and the same elbow turned inward, then one tube that hooks into a C-shape spanning 300 deg
around the shaft at the height of the arm. Eleven of the ring's holes are drilled downward in it, so
the gas rises into the lower impeller all the way around. The loop is as large as the baffles allow:
it stays inside their inner edge by the lean that they and its own riser can swing through at its
height, plus 1.25 mm. On `jar_10L` that is 75.95 mm across, 1.09 D. On the other jars the hook places
it, and it is smaller. It hangs on one riser, and `head()` warns what sideways force would close its
gap to a baffle. Seat it, square it to the shaft, and drive the screw before the lid goes on, since
rotating it 1.27 deg on the riser also closes that gap. One end takes the same plug screw as the
ring; a pipe cleaner goes in there and around to the socket.

**With no drive, the ring sits near the floor.** A position between the impellers only exists when
there are impellers. With `drive_name = "none"`, the underside of the ring sits
`sparge_ring_floor_gap` (10 mm) above the highest glass beneath it, so the column is sparged from the
bottom. The supports lengthen to match; on `jar_1p5L` that changes their stock from a 500 mm length to
a 1000 mm one.

**How the riser is held.** The ring sockets are bored 0.2 mm over the 4 mm tube and are 12 mm deep.
This is a slip fit, because a printed bore at the nominal tube size is a press fit and the five blind
sockets of the ring cannot take one. The ring rests on its six tubes and needs nothing else. The arm
and the loop hang on one tube, so their socket has a boss. The same M4x6 316 set screw that plugs the
ends of the ring self-taps into a pilot hole in that boss and bites 3 mm into the tube: seat the arm,
point it at the shaft, and drive the screw. The end of the arm is open through a pilot hole like the
ring's, so a brush can pass, and a second set screw plugs it.

**The socket of the arm and the loop seals with a press fit.** The gas leaves the riser at the bottom
of the socket. With a slip fit, it climbs the annulus around the riser and escapes through the pilot
hole of the screw. In bench runs the slip fit held at low flow and let small bubbles out at higher
flow. The socket is therefore 20 mm deep, and its bore tapers from 4.2 mm at the mouth to 3.8 mm at
the bottom, so the riser goes in freely and is gripped over the lower 10 mm. The boss is filled down
to the underside of the part, so stand the part on a flat surface and press the riser straight down
into it until it bottoms. Then drive the screw, which sits 2 mm below the mouth and stops the riser
backing out.

**The baffles are as wide as the fitted sparger allows.** With the ring they are limited to 10.35 mm,
which is the space the ring leaves outside them. With the arm the lock bore limits them, to 17.09 mm
on `jar_10L`. A larger impeller limits them first, because `baffle_impeller_clearance` is a running
clearance: 1 mm to the blades after the lean the port coupling allows. A lid with plates printed for
the arm does not take the ring.

**Check-holes covers whichever sparger is built**: the ring, the arm or the loop. A hole drilled
downward is cut from outside, so one that stops short leaves a skin under the bore, where the face
and the centreline of the bore are both open anyway. A third probe point, in that skin, catches it.

## The wall baffle cage

The standard four baffles stand at the wall, 17.5 mm wide and 2.92 mm off the glass. Their outer
edges are 204 mm apart, against a 142.2 mm mouth, so the cage changes shape. Its two hoops, r 64-70,
pass through the mouth lying flat. Each blade slides 30.6 mm in and out on a radial bar at each end,
in a dovetail channel in each hoop. The outer end of each bar is closed under the flange, so it stops
against the hoop and a blade cannot slide through into the middle. `head()` echoes the fit as
`baffle cage:` and the parts as `baffle cage print:`. The geometry is in
`scad/custom/baffle_cage.scad`.

**Printing.** PETG, no supports. Both hoops print with the channels up: the top hoop turned over with
its arm on the bed, and the bottom hoop as it sits, on its footing. They are mirror images, not one
part printed twice. The dovetail is on one side of the bar only, so the blade prints flat with the
dovetail on top. A blade is 238.7 mm long and needs that much bed in one direction.

**Assembly, on the bench.**

1. Hold the hoops apart by the length of a blade. Slide the two bars of each blade into the channels
   from outside, tip first, until the detent at each tip clicks out of the inside of the hoop. The
   blade is now out, held both ways between that detent and the one outside the hoop.
2. Push each blade in through two clicks of its detents to its stop, 30.6 mm.
3. Lower the cage through the mouth onto the floor, bending the hoops where the pads catch: with the
   blades slid in, the hoops stand 2.9 mm past the mouth on each side. Turn the gap in the hoops
   toward the DO probe port.
4. Reach in and push each blade out until it clicks into place against the wall.
5. Fit the lid. The air inlet riser, which is the tube the sparger hangs from, drops into the slot in
   the arm of the top hoop and stops the cage turning.

**The lid with the cage.** The hoops are C-shaped, and the probes hang in the gap. The pH probe goes
in the 30 deg port instead of the 120 deg port, and the 120, 150 and 270 deg ports take blanks
(`baffle cage ports:`).

**What the bench found.** The hoop channels are cut at 0.10 mm a side and the blade bars drawn at
0.15 (`baffle_cage_fit()` and `baffle_cage_bar_fit()`), so a change of fit reprints only the hoops.
With the hoops also at 0.15, some bottom bars sat loose and pushed in at their lower end. At 0.10
both hoops hold the blades, and the cage ran for 10 min at 320 rpm without any blade creeping inward.
A hand can reach the bottom bars, 240 mm down, for step 4. If a bar binds, sand its flange. If a
detent will not pass through, sand it; if it does not click, it needs to be taller. The model reports
the blade load at 420 rpm (`baffle cage load:`) but not whether a detent holds against it. The bench
run was at 320 rpm.

## The airlift's draft tube

`drive_name = "airlift"` adds one printed part, `draft_tube`: a plain tube on three feet, standing on
the floor of the jar around everything that hangs from the lid. The gas rises inside it and the
culture flows down outside it. Only the ring holds it in place. On `jar_1p5L_112x215`:

```
draft tube: 81.6 mm bore, 85.6 mm outside, 153.172 mm long from 11.6501 to 164.823 mm off the
floor, on 3 feet of 10.3704 mm; 1.4 mm each side through the mouth, and the ring inside it keeps
1.25 mm to its wall, so it shifts up to 1.25 mm
```

1. **Print it in clear PETG, feet down.** It is a straight wall with no overhang. Each foot joins the
   wall through a 6 mm fillet on either side (`draft_tube_foot_fillet`), so the corner does not crack.
   With an opaque tube, cells would pass through its core in the dark.
2. **Lower it into the jar first**, feet down and square to the mouth. It passes with 1.4 mm each
   side on both jars, so it goes in straight or not at all.
3. **Centre it by hand**, reaching down its bore. Standing loose, it can sit several millimetres off
   centre on `jar_1p5L`, and further on `jar_1gal_155`, and the ring has 1.25 mm to find the top of
   the tube.
4. **Then lower the lid.** The ring goes down inside the tube and ends inside its feet or its wall,
   which holds the tube in place. Everything else that hangs from the lid ends inside the tube.

**It can move.** Where the ring sits inside the wall, as on `jar_1p5L`, it stops the tube 1.25 mm off
centre. On `jar_1gal_155` the ring sits among the feet and the tube can shift 2.5 mm. `head()` checks
the probes against the tube shifted that far, and the tightest clearance is 0.75 mm, at the collets
on `jar_1p5L`. The DO probe hangs straight in the airlift.

## Putting the lid together

The order is set by the geometry, not by preference.

1. **Fit the ports into the lid first.** The lock half of every bayonet is printed as part of the
   lid. The pin half is the cartridge that carries the flange, the seal and whatever hangs into the
   vessel. It drops in from outside and turns to lock. The two catch pockets in each flange are for
   pliers.
2. **Everything that hangs below a port must pass through the lock bore on the way in.** This sets
   the width of the baffle plate, and the model asserts it.
3. **Then fit the lid onto the jar.** Everything hanging from it passes down through the mouth, so
   _every part of the assembly is level with the mouth at some point on the way down_. What matters
   is the widest the assembly ever gets, not where it ends up. On `jar_10L` the DO probe collet is
   the limiting part, reaching 70.78 mm against a 71.1 mm mouth: **0.32 mm to spare**.
4. **Fit the probes last**, down through the bayonet bore into the collet. They never pass through
   the mouth, which is why their length is not part of the clearance above.

### Two ways to assemble it wrong that nothing will catch

**The ring sockets look identical from above.** (The arm has one socket, so this does not apply to
it.) The feed socket is an **octagon** and the support sockets are **round**. That is the only
difference between them, and you cannot see inside a socket at the bottom of a jar. If you get it
wrong, the gas goes down a capped tube and straight back out of its vent hole into the headspace,
while the rotameter shows flow and the culture gets nothing.

**Count the facets.** Both sockets are 6.4 mm across the flats, and the octagon corners stand only
**0.264 mm** outside the circle, so feel for the corners rather than relying on a glance. The feed
socket is an octagon because that is the cross-section of the tube.

**The ports are labelled by function for the same reason.** Every tube port has the same 4.4 mm bore
for the same 4 mm riser, so the bore on a label tells you nothing. A gas line on the wrong port vents
into the headspace. A dosing line on the wrong port puts acid where base should go. The labels read
`AIR IN Ø4.4` and `DOSE 2 Ø4.4`: read the word, not the number. Recording which dose line carries
what is up to you. Baffle ports are labelled with the length of plate they carry.

The sparge ring itself cannot be installed rotated. It has a socket under every tube port (five on
the full lid, at 0, 210, 240, 300 and 330 deg), and that pattern is irregular enough that only one
rotation puts them all under ports. On the six-port jars there are three.

### Drilling the support tubes

On a ring build, every tube port except `air_in` takes a support tube. The tube is capped where it
meets the ring and does its job through a hole you drill. There are four on the twelve-port lid and
two on the six-port jars. Only the model can dimension that hole, and it does:

```
sparge support drilling: a support tube vents through a hole drilled between
37.9375 and 81.3477 mm from its top end (past the lid's inner face, short of the
culture); nearer the first is better
```

That example is `jar_1gal_155x251`. A tube meant to discharge INTO the culture is drilled past the
second number instead.

**Which end of that window to use depends on the port.** `air_out`, where it carries a tube, is the
exhaust and should be drilled near the first number: the headspace is there to hold foam, and foam
finds the lowest hole. The dosing lines discharge into the culture, so they are drilled past the
second number, and lower is better. The dose then lands where the impeller will carry it away, and
the tube below the hole is a dead leg that retains whatever is fed into it.

**With a loop or an arm there is nothing to drill.** No ring rests on the dosing tubes, so they are
cut open-ended at the centre of the upper impeller, and `sparge tube stock:` gives the length to cut.

**Only the `air_out` hole has a minimum size**, on the ring builds, where no condenser takes that
port. The model calculates its pressure cost rather than only stating that it is the exhaust path. On
`jar_1gal_155x251`:

```
gas exhaust slot: a slot of the tube's own 7.06858 mm2 bore costs 25.9379 Pa at
1.67312 L/min, and the tube above it 9.63158-20.6526 Pa over the 37.9375-81.3477 mm
drilling window, together 0.207856-0.272259% of the 17112.5 Pa the exhaust has to
spend; file past 0.275196 mm2 (a 0.591938 mm round hole), which the bore clears
25.6856x over
```

**On this jar the minimum is about 0.28 mm^2, which is a dia 0.59 mm hole.** A normal file cut
exceeds it many times over. A shallow pass that only just breaks through the 0.5 mm wall is the only
way to get close to it. Cut the hole, then hold the tube up to the light and look through the hole
before fitting the tube.

**Read the minimum from your own render, not from this page.** It changes with the jar, because it
depends on the headroom left in that jar's gas line: 0.275 mm^2 here against 0.108 mm^2 on
`jar_1p5L_112x215`.

That 17112.5 Pa is the same pressure the throttle currently drops, and the same headroom an outlet
filter would have to fit within, so whatever the slot uses comes off both. The slot and the tube are
already included in the gas line the pump is sized against, at the long end of the drilling window.
An outlet filter, once one is specified, will be added there too. The three dosing holes meter
nothing and need no particular size.

Distances are measured from the **top** end, because that is the end you can reach with the tube in
your hand.

---

## Closing the lid, and the number that cracks the jar

**This joint is limited by the glass, not by the fasteners, and nothing about the hardware tells you
so.**

Twelve posts hold the lid down on a 239 mm circle, 62.6 mm apart: **eight M8 bolts and four M8 tie
rods**, with a rod at every third position. The bolt heads bear on the underside of the top base. The
rods run the full height of the frame from the lower base. All twelve are tightened by a **nut on top
of the lid flange**, so the procedure is the same at every post. On `jar_10L_220x305`:

```
joint load: 4212.27 N of gasket seating over 12 posts = 351.023 N each, on M8
bolts and M8 rods
lid lip: crowned on a 3.5 mm arc standing 2 mm proud of the wall - no flat to
seat on, so the gasket covers the lip and the crown sinks 0.396875 mm into it;
8 mm of gasket, 3.23766 mm of contact
lid gasket load: 3.23766 mm of contact, 4212.27 N to hold 25% squeeze,
2.77566 MPa on the glass
```

**351.0 N per post.** The proof load of an M8 A2-70 bolt is about 16.5 kN, so the joint runs at
**2.1 % of proof**. The fastener is nowhere near the limit. A published tightening torque for the
same bolt is 20-24 N-m. This joint needs about **0.6**. Tighten one of these to the fastener
specification and you put roughly forty times the intended load onto a soda-lime jar.

### Do not reach for a torque wrench

Torque gives preload only through a friction coefficient, and here the coefficient is unknown.
Across the range of 0.20-0.30 that is plausible for an unlubricated stainless nut, 351.0 N
corresponds to **0.56 to 0.84 N-m**, a 40 % spread from the friction assumption alone. 18-8 galls,
which is what makes the coefficient unpredictable, and 0.7 N-m is below the range of most torque
wrenches anyway.

### Turn the nut instead

```
joint tightening: 114.3 deg past snug on each of the 12 nuts (0.396875 mm of gasket
travel on a 1.25 mm pitch); the printed flange creeps, so go back to them
```

A turn angle depends only on geometry. The 1/16 in gasket is 1.5875 mm thick, 25 % squeeze is
0.3969 mm of travel, and an M8 x 1.25 thread converts that to **114 deg**. Neither modulus nor
friction enters into it.

The rest of the stack barely moves. At 351.0 N an M8 bolt stretches 0.0010 mm over its 20.4 mm grip,
and a rod stretches 0.0005 mm over the 10.4 mm between its top-base nut and its lid nut. Either way
this is under 0.3 % of the gasket travel. The printed flange is the soft part, and its compression is
the one number in this section without a source: roughly 0.02 mm under a nut face, estimated from the
PETG modulus and the bearing area of a nut, not measured. So:

> **Snug, then a third of a turn.** 120 deg is 114 deg for the gasket plus a little for the plastic,
> and it is a mark you can see on a nut, which 114 deg is not.

Snug is the point where the flange stops moving under hand pressure on a short key.

**Pattern.** Bring all twelve nuts to snug first, working across the circle rather than around it.
Then take them to a third of a turn in the same order, in two passes. A gasket squeezed unevenly
seals at its tightest point and leaks opposite it, and glass does not tolerate being loaded on one
side.

**Then check them again.** PETG creeps under sustained load, and the flange, the top base and the
plastic under the twelve nut faces are all in this load path. Re-check after a few hours and again
after the first run.

### Two things not to do

**Do not tighten until the flange meets the glass.** The recess is 1.19 mm deep for a 1.5875 mm
sheet, so at the design squeeze the gasket is nominally flush and the flange nominally touches the
glass. In practice it cannot get there. The recess holds three quarters of the cross-section of the
rubber, and elastomer is nearly incompressible, so the remaining quarter has to escape sideways
first. Flange-on-glass is _past_ the design point, not at it.

**On every jar except the 6.5 gallon, there is no land to stop you.** Those lips are crowned, so the
flange has nothing to bottom on, and the turn alone sets the squeeze. That is why this section
specifies a turn rather than a torque, and why over-tightening is a real risk rather than a
theoretical one. Count the turn.

**Do not substitute a harder gasket without re-deriving the joint.** The 60A durometer sets the
ASME VIII-1 gasket factor m = 0.5, which is what gives twelve posts. At 75A or harder, the same lid
needs sixteen.

### How good is 351.0 N?

Not very, and the model says so. `elastomer_shape_factor()` uses the free-bulge form, which assumes
both edges of the pad can spread; the recess walls are exactly where they cannot. The modulus behind
it is correlated from hardness, not measured. So 351.0 N and 2.78 MPa are figures for judging a
design, not for cutting a part to, and `elastomer.scad` states this at the top of the file.

**The turn is the more reliable of the two**, which is why it is the instruction. It comes from the
gasket thickness and the thread pitch, and neither is a correlation.

---

## The gas line

The order matters, and two of the joints are placed where they are for reasons that are not obvious.

```
pump --3/8 in-- reducer --1/4 in-- reducer --1/8 in-- METERING VALVE --
      rotameter --3/16 in silicone-- check valve -- STERILE FILTER -- riser
```

**The metering valve goes upstream of the rotameter.** The meter is calibrated at 14.7 psia. With the
throttle ahead of it, the meter sees only the downstream line loss, which keeps the correction at
0.7 % instead of something significant.

**The two rotameter adapters are deliberately different sizes**, 1/8 in in and 3/16 in out, so the
line steps up inside the meter bore rather than through a coupler. This saves one joint.

**The sterile filter is the boundary.** Everything downstream of it is inside the sterile envelope
and is platinum-cure silicone. Everything upstream can be PVC or polyurethane, and the barbed
fittings on that side are rated for firm tubing rather than silicone.

**One clamp size, `5011T141`, closes all fourteen joints**, as long as the 3/8 in tubing is bought in
1/16 or 3/32 in wall. With 1/8 in wall it sits at the last thread of the clamp. Snug each clamp with
the 1/4 in nut driver and stop. A wrench will strip one, and these are reopened at every filter
change. The reasons for this clamp, grade and wall are in
[Procurement](procurement.md#hose-clamps).

The check valve stops culture siphoning back into the pump when the pump stops. It is required.

**Nothing filters the outlet, and do not fit a second inlet filter there.** The headspace vents
through the coil condenser into the room. A second `1594522` on the outlet would hold the reactor
under 0.5 vvm. An outlet filter has to fit within the budget `head()` reports as `gas exhaust:`. The
reasons are in [Procurement](procurement.md#gas-metering).

---

## The exhaust condenser

**The coil is on the lid's part lists.** Its body is the pin for `air_out`, so that port carries no
tube and no slot. The headspace gas leaves up the condenser bore and out of its 4.5 mm outlet barb,
which `head()` includes in the gas line pressure budget. Every build whose sparger is not the ring
takes it (`condenser_name`). The ring builds keep the `air_out` tube, which holds the ring.
`just export-parts` writes the body, panel, former and both pucks, each in its print orientation. The
split cold finger prints from its own file, `custom/condenser_cold_finger.scad`. #134 and #135 track
what the prints still have to prove.

**Print the condenser bodies gas-tight, and any part that holds water watertight.** A condenser body
is the exhaust path: gas that leaks through its wall bypasses the cooling and carries water out with
it. The flow insert of the cold finger is the only wall between the coolant and the gas, so a leak
there drains into the culture. For both, print at the hot end of the filament's range, with four or
more walls, 0.15 mm layers and slightly increased flow (about 105 %). Leak paths run through the
walls, not the infill, so spend material on walls. Water-test the flow insert before fitting it to
the reactor.

**Print the lid of the open well the opposite way, with sparse infill.** It insulates the ice, so use
low infill in a pattern that traps the air in cells, such as honeycomb or cubic, rather than one that
lets the air move freely. Keep its dia 1.5 vent open: melting ice and warming water push air out
through it, and a sealed lid would pressurise the well.

**The coil is wound on the former, and the former stays in place.** A coil whose bottom end runs back
up through its own middle cannot be removed from a one-piece mandrel: to unscrew it, the mandrel ridge
would have to pass through the leg. So there is no mandrel. The former is the arbor: chuck the stub
below the coil and wind, and the former stays in the reactor, holding the turns at pitch in dead space
it already occupies. `part = "puck_bottom"` and `part = "puck_top"` are the only tools, one for the
bend radius at each end.

1. Bend the bottom end on `puck_bottom` while the tube is still straight and there is room for a
   bender: a quarter turn inward, then a quarter turn up, leaving a leg the height of the coil.
2. Lay that end into the channel in the former **from the side**, with the bends in the foot and the
   leg up the groove. Nothing has to be threaded through a hole, which is the step that cannot be done
   later. A tie through the stub holds the tail while the first turn goes on.
3. Wind up the former, pushing each turn down onto the ridge below it. The flat top of the ridge sets
   the pitch. The slack above each turn is there because a part printed standing cannot hold an
   overhang past 45 deg, and it is why the winding direction matters.
4. Bend the top end on `puck_top`, in open air above the coil: a quarter turn inward, then up.
5. Lower the panel onto the two ends, which are already vertical and parallel, and onto the spigot of
   the former. Insert an M3 x 14 cap head screw radially through the counterbore in the coupling
   face; it crosses the socket and bites the spigot.

The two ends are bent at different radii on purpose. The bottom end has to finish inside the coil, so
9.5 mm is the gentlest bend it can have. The top end only has to reach a seal, so it bends at
11.25 mm and ends further out, which is as far out as the coupling core allows a seal to sit.

Tube that has been bent back and forth work-hardens and cracks at the next bend. Start from a fresh
piece rather than straightening a bent one.

**The aluminium tube of the coil condenser must never go through the bleach step for the vessel.** It
takes the 7.5 % peroxide with everything else, but bleach and chlorite attack it.

---

## The turbidity sampler

On the full lid the sampler takes port 6, at 180 deg, opposite the coil condenser on `air_out`. At
330 deg the sampler intersected the condenser, and at 300 deg its syringe actuator did.
`just export-parts` writes its base and top in print orientation, and the `sampler:` line of the
render gives the cut length of the riser and the length of the clear tube for your jar. On `jar_10L`
these are a 200.7 mm riser, ending 114.8 mm below the culture surface, and a 44.6 mm clear tube. The
sampler is a flow cell around the bare board of the turbidity probe. A syringe actuator bolted on top
draws culture up a clear tube between the heads on the board. The screws, nuts and inserts are on the
purchase list.

**The riser is the dip tube.** It is the sparge riser of this port, cut so that its top end stops
inside the base and its open end sits at the mid-depth of the culture, where the sample is drawn. The
clear tube runs 16 mm down over its top end, with a sleeve of 1/8 by 1/4 in silicone tubing between
them.

**Fit the luer-to-barb fitting first.** Warm the end of the clear tube with a heat gun, push the barb
in until the tube reaches the centre flange of the fitting, and let it cool. The stretched 18 mm sits
above the heads, where the bore for the tube is widened to take it.

1. Heat-set two M3 inserts into the outer corners of the top and one M2 insert into the inner end of
   the base, each from its parting face.
2. Drop the board into the top upside down, heads first, with the connector facing outward.
3. Close the base onto the top with two M3 button heads from below and the M2 countersunk screw from
   above, down the slot in the skirt of the top. Use a ball-end hex key, because the face stands over
   the screw.
4. Drop the clear tube down the shroud. The bore narrows to a snug fit only between the heads, and the
   end of the tube seats in the base. The riser comes up through the o-ring in the pin into the bottom
   of the tube.
5. Open the four front knockouts on the actuator. Push four M3 x 10 screws up through the face from
   the counterbores underneath, and lower the actuator over them. Run a nut onto each screw from
   inside, through the window in the actuator roof, with one flat of the nut against the side wall,
   which holds it. Tighten from below with the long arm of a 2.5 mm hex key, straight up the groove in
   the side of the case under each screw.

This order follows the design. The first full assembly will confirm it.

## The e-stop box

A box for the panel-mount e-stop. It prints from its own file, `support/estop_box.scad`, with
`part = "base"` and `part = "lid"`: the base open side up and the lid flat. The neck of the e-stop
goes through the bore in the lid, and its nut clamps the lid. The body hangs into the base, and the
four wires of the two channels leave through the hole in one wall.

**Measure the e-stop first.** The first four parameters in the file are the dimensions of its body
below the panel (height, width and length, including contact blocks) and the panel cutout for its
neck. The box is square, sized to the wider side, with `wire_space` kept around and below the body.
Rendering echoes the closed size. `lid_thickness` must be within the panel thickness range that the
e-stop nut clamps.

**Fit the e-stop to the lid, then close the box.** The four lid screws are M3 self-tapping screws,
into pilot holes in the corner posts of the base. For heat-set inserts, set `screw_pilot_diameter` to
the insert hole size. Fit a grommet or gland in the wire hole before the wires go through it.

## The sparge test pucks

These are bench parts, not reactor parts. Printing and running them is covered in
[Sparge test pucks](../analysis/methods/sparge-test-pucks/README.md).

---

Once the reactor is assembled, the first run is described in [Commissioning](commissioning.md).
