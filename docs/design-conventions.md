# Design conventions

The model follows these rules. Each one was learned from a mistake, so each one names the failure it
prevents. Anything that contradicts them is a defect, not a variation.

---

## The rim datum

**The glass rim locates the lid.** The lid gasket seats on the top of the glass, and the lid plug
enters the mouth. The jar fixes the rim height, and the top base of the frame is derived _below_ it.

**The gasket seating surface differs from jar to jar, and only one is flat.** `jar_6p5gal_305x470`
has a ground rim with a flat annulus. Every other jar has a fire-polished rim with a CROWN: the glass
rolls over, and on two of the jars the roll stands proud of the wall as a bead. There is therefore no
flat land to inset a gasket into or to bottom the flange on. Instead, the gasket covers the lip, and
the compressed part is the band the crown makes as it sinks in.

The important consequence is that the **2.4 mm gap** between the upper face of the top base and the
underside of the lid flange is _required_. It is not slack to be removed. It is the clearance that
lets the joint bolts pull the lid down **into** the vessel instead of bottoming it on the frame. Every
dimension that crosses the joint must include it: bolt grips, nut positions, and anything measured
from one side of the joint to the other.

Seating the lid on the frame instead of on the glass is wrong. This was derived backwards twice
before it was written down.

**Frame coordinates.** The frame is built with z = 0 at its own floor, and its body is then drawn
offset by `-base_floor_height`. Frame-local `total_height` = 349.75 corresponds to assembly z = 305,
the rim. If those two values look contradictory, the offset has been missed.

---

## One physical thing, one expression

The most common defect in this repository is one physical fact stated twice, in two places. The two
agree until one of them changes. Every case found was silent: the model built without error and the
two numbers diverged.

Real examples, all of which shipped:

- The **strip light** was selected twice. The assembly passed only its length, while the frame read
  its own second selection. Changing the light resized the frame around a pocket that never moved.
- The **impeller ratio** was multiplied by the outer diameter of the vessel, where D/T means the
  bore. The actual ratio therefore drifted with glass thickness instead of staying constant.
- The **cart** sized its envelope from the bare jar, so two bioreactors on one tier overlapped by
  17.4 mm and each passed through the rail above it.
- The **bearing** allowance was applied twice, once in the registered diameter and again as the
  pocket allowance, which left the pocket 0.8 mm oversize.
- The **eccentricity analysis** took T as the outer diameter. This was the impeller-ratio defect
  above, recurring in a document after it had been fixed in the model, so the document and the model
  in the same repository disagreed about what T meant. No check could catch it, because no geometry
  reads those numbers. It is the clearest example of the rule below: a document is the second
  expression, and the worse place for one.

The fix is always the same: one expression, which everything that needs the value reads back.
Subassemblies export accessors (`frame_outer_diameter()`, `head_gasket_factor()`) instead of having
consumers rebuild the value.

**Name the exact quantity, not a similar one.** Three defects came from names that could be read two
ways: outer diameter or bore, motor speed or output speed, screw centre distance or bolt circle. If a
field can be read two ways, eventually it will be.

**Documents are the second expression.** The same defect occurs in prose, and it is worse there. The
model cannot check a document, so a stale figure stays unchallenged until a reader relies on it. One
review found eight, including:

- a D/T cap that the model had changed
- a thermocouple that is not purchased
- a pump delivery that the model explicitly retracts in its own echo
- a fenced echo quoting a number the model no longer emits
- one document stating both that the baffle hangs its full length and that it has never been
  lengthened

Prefer quoting an accessor or an echo to restating its result. Where a figure has to be written out,
**check it against the model, not against another document**. Several of these figures agreed with
each other and with nothing else.

**Replace a corrected figure where it appears, and record it once in [Decisions](../dev/decisions.md#corrections---readings-that-were-wrong).**
The old value shows which assumption failed, so it goes under _Corrections_ there, with the reason it
was wrong. It does not stay inline. A superseded paragraph next to its replacement is a second
expression of the same fact, and the commit that made the correction already holds the diff.

---

## Three layers, and where a parameter lives

The model was originally built on two layers. Values that two components must agree on live in
`bioreactor.scad`. A component's own preferences live in its own file. That is correct as far as it
goes, but it misses a third kind of parameter, which became apparent when there was no place to state
the choices for a build.

A **DESIGNATION** is a per-reactor choice: which registered jar, which motor, which probe in which
port, what fill fraction. It is not a preference, because it describes _this_ build, not the design.
It is not ordinary coupling either, because `bioreactor.scad` may never use it. It still has to go
in the entry file, because of a platform limitation: a customizer parameter set can only assign
parameters declared in the file being rendered. See _What the customizer can and cannot carry_.

**Where a parameter lives.** A parameter belongs in `bioreactor.scad` if any of these is true:

- two or more components must agree on it;
- `bioreactor.scad` itself uses it in a derivation, for example `frame_wall_thickness` feeding
  `joint_outer_diameter`, the fill fraction feeding light selection, or the shaft feeding the
  envelope;
- it is a designation, a per-reactor choice an operator states.

Everything else stays in the component it belongs to: allowances, wall thicknesses, land margins,
joint geometry, and the search that derives a designation when none is stated.

**A designation is passed as a NAME, never as a row.** A parameter set holds values, not references,
so it cannot name a registered row directly. Instead, a string parameter is resolved through the
by-name lookup of that registry. `reactor_vessel_name` with `vessel_by_name()` is the pattern. A name
that matches nothing fails a loud assert. `"auto"` means _derive it_.

That string is not the kind of plausible number this document forbids elsewhere. `undef` cannot be
used here, because the customizer cannot see it, and a numeric sentinel would be exactly the
plausible value that passes unnoticed into arithmetic. A string cannot do that. It is visible in the
customizer, it is passed through, and it is consumed by a mode branch that never multiplies it by
anything.

**Only departures are passed.** The build list packs only what a build actually states. Anything left
at `"auto"` is omitted, so the search in the component stays the single expression of the default.
No parameter is ever declared live in two files with defaults kept in step by hand.

**A value read back from a component is an argument whose default is the component's own value.**
For example, `function hub_cap_height(magnet, floor = hub_cap_floor)` in `magnet_hub_cap.scad`, which
`frame.scad` reads back. This was verified: a default argument resolves in the file that defines the
function, not in the caller's file. One expression therefore serves both the standalone preview and
the assembled build, and the readback cannot disagree with the geometry it describes.

**Pinning a part does not turn the checks off; it inverts them.** A designated row runs the same fit
asserts that a derived one would have, and the echo reports what was pinned _and what the derivation
would have chosen_. A selection from a registry that holds only one row says so ("sole registered
row, fit-checked, not chosen") instead of implying that a choice was made.

---

## Purchased parts are registered rows that drive geometry

Every purchased part is a row in `scad/purchased/`, and the geometry is cut from that row, not from
numbers typed next to it. The hole is derived from the insert, the pocket from the bearing, and the
gasket recess from the sheet thickness.

The failure this prevents: a heat-set insert was once modelled from a library row that **was not a
purchasable part**, and the lid was printed for it. A registry row must describe something that can be
ordered. Where a library already has the real part (`BB608` is the 608 bearing actually bought), the
library row is used directly instead of being copied.

**What every registry must provide:**

- a rows list;
- a `*_name()` accessor;
- a part number where a stable one exists, or `undef` with the reason where it does not;
- the provenance of each value, stored with the value;
- a `*_by_name()` lookup wherever the part can be designated.

Data-only registries, whose rows carry numbers and draw nothing, are allowed.

**Only REAL parts go in the swept list.** `check-echo` and the sweeps build against this list, so
each entry is a claim about hardware.

A **placeholder**, a row that describes nothing anyone has bought (such as `generic_vessel`, or a
`"generic"` probe with an empty part number), stays defined but is kept out of the list. It is a
shape, not a product, and sweeping it would make "this builds" cover something nobody can buy.

A **discontinued or bundled** part is the opposite case. It stays in the sweep, and the deviation is
recorded next to the list. The 36GP motor is no longer sold but is on the bench. The 12 V pump motor
comes fitted to a pump head and has no part number of its own. Both Atlas g1 probes are out of
production but still in use. Removing these from the sweep would stop checking hardware that exists,
which defeats the purpose of the sweep: to show that real parts build.

**A designatable part is not the same as a purchased part.** Every purchased item is a registered row,
but only the ones an operator actually chooses per reactor get a by-name lookup and a slot in the
build parameters. The bearing, the heat-set inserts, the screws, the riser tube and its o-ring, and
the hose clamp are the bill of materials of the design: one expression each, not a menu.

---

## A number is a claim, and it carries how good a claim it is

Parametric CAD makes numbers adjustable. It does not make them _true_. A number that is adjustable but
unfounded is the more dangerous case, because the model looks equally confident either way.

Every quantity in this model is therefore one of four kinds, and its kind is recorded with it:

- **measured** - a source states it for this exact part. Example: `Po 4.17 +/- 0.14` for
  `impeller_rushton_6`.
- **correlated** - a published correlation computes it from this geometry, and can report where the
  geometry is outside the range of validity of the correlation. `pbt_45_4` takes `Po` from Medek
  this way.
- **borrowed** - no source covers this shape, so the value for a similar one is used instead. It is
  always echoed, never silent.
- **reasoned, not cited** - nothing in the literature collected here supports it, but the model needs
  a value. The source marks it with that exact phrase. Examples: the 0.5 D coverage floor, the baffle
  load, the mount slenderness limits, and treating the curve of a diaphragm pump as linear.

The failure this prevents is a borrowed number gaining the authority of a measured one because it
sits in the same table. This model ran for months on `Po = 0.99`, borrowed from a blade of a different
shape and annotated _conservative_. The correlated value, when it arrived, was **1.602**. Every power,
torque and dissipation figure had therefore been 62 % optimistic, while carrying a note that said the
opposite.

**A registry row states what a source says, not what the design needs.** Where a source gives a band,
register the band. Where it gives nothing, register `undef` instead of a plausible number. `undef`
propagates and gets noticed; a plausible number does not.

---

## Report the departure, not just the number

Every correlation has a range of validity, and this vessel is outside several of them. That is
normal for an instrument built from jars instead of from a vendor catalogue. What is not acceptable
is _not knowing_ which ones.

A check therefore returns the **names** of the conditions it violates, not a boolean. `jar_10L` with
a pitched blade at the lower position echoes:

```
impeller, lower: pbt_45_4 Po 1.49248 and flow number 0.887217 from Medek's correlation
at 45 deg, extrapolated on ["T/D", "H/T"]
```

`stirred_tank_medek_departures()` returns a list because an extrapolation that is outside the range
on one count is different from one that is outside on four. A caller that only receives `false`
cannot tell them apart or know which to fix. One of those two departures, D/T, can be removed, and
that is visible only because the departures are named. The baffle count was a third departure until
the four baffles of the cage removed it.

The same approach applies to bands the design is measured against: echo the value, the band, and how
the source itself frames it. Oldshue's `1-2 d` is an **allowance** (_"if the impeller can be
placed... these impellers offer"_), so a value outside it is reported, not warned. It is also an
allowance for **fluidfoil** impellers, which a pitched blade is not. The model says so instead of
silently judging one impeller class against the guidance for another.

---

## Report a fit before you build the part

Register the geometry and its clearances, render, and read the reported values. Then draw the part.
Reporting costs less than drawing, and it is what catches arithmetic errors.

The case that made this a rule: a sparge ring was planned at 1.4 D with **1.60 mm** of clearance to
the baffles. That figure was measured from the ring _centreline_ to the baffle edge. The ring has a
6 mm section, so its inner face is 3 mm further in, and the true clearance is **-1.40 mm**. The ring
overlapped the baffles. Nothing about the plan looked wrong: the number was plausible, had a unit,
and was derived from real dimensions. The assert caught it on the first render, before any geometry
existed.

Working the problem through changed the design, not the number. The radial band available is
6.95 mm, no round section of 6 mm fits it at any diameter, and the constraint is entirely radial
while 73 mm of height is unused. The ring section became 4 x 10 mm. This is also why the ring is
printed rather than bent: **a tube is round, and a round section does not fit**.

A model whose checks only run after the geometry exists will confirm whatever was built.

---

## The model should be able to catch its author

The purpose of the three sections above is not documentation. It is to make the model disagree with
the person editing it, in the same session, before anything is committed.

Every one of these defects was found by a check, not by re-reading:

- `z = 0` in `head()` is the **outer** face of the lid, which the assembly seats `lid_flange_height`
  above the rim. Every depth referenced to the vessel was therefore **8 mm** out, and the drivetrain
  was drawn higher than the model reported.
- The baffle area ratio compared plate **width** with a reference **area**, and reported 0.83 for
  baffling that was actually 0.14.
- Medek's four-baffle condition was evaluated against `len(undef)`, because `_baffle_at` was assigned
  230 lines below its first use. It therefore reported a departure on a lid that has four baffles.
- A pitched blade that extends to `radius` sweeps **past** the diameter its power number is defined
  on, because the outermost points of a tilted rectangle are its corners. 1.5 % on diameter is 7 % on
  power.
- A round feed boss on the sparge ring was wider than the ring section, and fouled both the baffles
  and the jar mouth, at 0.29 and 0.26 mm.

None of these were subtle once seen, and none were visible while writing the code that caused them.

**The cost.** This approach is verbose, and it is only as good as the checks that someone wrote. A
number can be wrong in a way that nothing checks, and a reported band does not guarantee the value is
right. `reasoned, not cited` is still a guess; it is only a _labelled_ guess. The claim is narrow:
labelling the weak numbers and naming the violated conditions turns a class of silent drift into a
line of render output.

---

## Asserts versus echoes

This reactor is a research instrument. A parameter outside the usual range may be exactly what
someone is studying, so the model reports such values instead of refusing them.

- **Assert** only what is physically impossible or unbuildable: an impeller too wide to pass the
  vessel mouth, a pocket cut through into the culture, a nut deeper than the base it sits in.
- **Cited bands at the pressure boundary may also assert.** This is a deliberate exception, not a
  lapse. The three o-ring checks (riser stretch, plug gland fill, plug containment) protect the seal
  between the culture and the room, and they come from gland design practice, not from the judgement
  of this project. A seal outside its band is closer to unbuildable than to a variation someone is
  studying. A limit that is `reasoned, not cited` does **not** get that authority; it echoes.
- **Echo** the value and the literature band it is compared against, with a separate warning line
  when it falls outside the band. The build continues.

### Dead versus weak asserts

- **Dead** - the expression cannot vary, so no input can make it fail. Delete it. It looks like
  coverage but provides none.
- **Weak** - it varies, but only absurd inputs trigger it. It is cheap insurance, so keep it.

**Test whether an assert is dead by sweeping the parameter that drives it**, never a proxy. Sweeping
the vessel registry proves nothing about a guard driven by cord diameter. Two asserts were deleted
this way after proving algebraically that their terms cancel. A third was nearly deleted after a proxy
sweep, before sweeping the correct driver showed that it fired.

An assert derived from the thing it checks can never fire. If the code has just computed a
relationship, do not then assert it.

---

## Verifying a change

Two OpenSCAD behaviours determine how anything here is checked, and both are counter-intuitive.

**A failing assert still exits 0.** A failed CSG export returns success and writes a file of about
1 byte. Nothing may be gated on `$?`. `just check-scad` greps stderr for `ERROR` and uses file size as
a backstop. Before this was understood, every failing vessel in a six-vessel sweep looked like a pass.

**Mesh export is not reproducible; CSG export is.** Exporting the same file three times gave 29454,
29452 and 29456 facets, at three different file sizes. The set of distinct z-levels and the bounding
box were identical in all three, and the CSG output had the same hash each time.

So:

- _valid_ evidence - CSG diffs, distinct z-levels, bounding boxes, per-feature coordinates
- _not evidence_ - facet counts, STL file size, STL hashes

This also rules out STL hashing as a regression check for any future export tooling.

**A CSG diff cannot see anything the preview omits.** `head.scad` sets
`$bayonet_shell_only = $preview && fast_bayonet_preview`, which makes the bayonet library draw bare
shells and skip every pin, channel and notch. CSG export runs in preview mode, so a CSG comparison
shows those features as unchanged **regardless of what was done to them**. A change to the pin angles
came back byte-identical twice before this was understood.

A CSG diff therefore proves nothing about a feature that the preview suppresses. Either render the
affected part on its own, or pass `-D fast_bayonet_preview=false` and compare that. In general,
**check which flags were set before trusting a diff**, because a diff of two things that were never
drawn is a clean diff.

**`WARNING` is evidence too.** OpenSCAD reports undef reaching arithmetic as a warning, not an error.
A parse error in a `use`d file shows up as nothing else at all. A missing comma between two string
literals stopped `head.scad` from exporting any of its functions, without any error, while the file
still rendered on its own. Ninety warnings went unnoticed because the gate only grepped for `ERROR`.
`check-scad` now fails on either.

**`just check-scad`** evaluates every file in both directions. Files meant to render standalone must
produce geometry, and every other file must produce **none**: a registry that draws its own example
draws it into every file that uses it, which has already happened once. A new entry file therefore
fails until it is listed, which is intended.

**Neither of those checks runs CGAL, so neither can detect a broken solid.** `.csg` export is a dump
of the tree, not an evaluation of it, and mesh export tessellates without checking whether the result
is closed. The impeller blades were drawn TANGENT to the hub, giving 264 non-manifold edges, and every
check above passed on it, on every render. It was found by measuring the STL. **`just check-mesh`**
covers this: it renders to a mesh and fails if the defect count is above zero. **`just export-parts`**
applies the same test to every part in the print manifest, one at a time.

**Run a check in the configuration that produces the printed part, not the one that produces the
picture.** Four entry files render an assembly by default, and `check-mesh` used to skip all four as
"slow" and suggest running them before printing. Three of them cannot pass. The printed geometry of
`head.scad` alone IS a 2-manifold. What breaks it is `render_seals`, `render_probes`, and the bearing
with its coupling: EPDM in its grooves, Atlas bodies in their collets, a bearing on the shaft. All of
these are already on the `not_printed` list in `check-parts`. The check therefore failed on purchased
parts that the repository had declared as not printed, could never pass, and taught anyone who ran it
to ignore it. `scad/support/electronics_stand.scad` was also on that list and is not even slow: 14 s
as a picture, and 4 s as the printed bracket, which is a clean 2-manifold. It is now checked.

**A check that cannot pass is worse than no check**, because the next real failure looks like more
of the same noise.

**Check at the `$fn` used on the desktop, not only the one CI pins.** `$fn` is dynamically scoped.
OpenSCAD 2021.01 lets a `use`d module resolve it from its own file, while newer builds pass the
caller's value. A module that divides by `$fn` therefore works under one and produces `nan` under the
other. Nobody notices, because a `nan` in a comparison makes it false. `check-scad` runs a second pass
at **`-D '$fn=0'`**, which is the value in an unset viewport, and the geometry derives its facet count
from `$fa`/`$fs` instead of reading `$fn` from the caller.

**A clash check on a stand-in shape proves only the stand-in.** The preview tube of the condenser
coil was a horizontal disc swept around the helix, a 0.4 mm ribbon in section. A collision test
passed on it that a round tube would have failed, and the printed head then cracked where the real
tube would not bend. Draw the checked part from its real section, and prove the check can fail by
moving the part it guards (half a pitch, a few degrees) and watching it report. Fit is not the only
question for a bent or wound part. It must also be formable, at a radius the material allows, in the
order the parts are assembled. Any part it is formed against must be built to withstand the forming. The
head that cracked was not, because it was designed only to locate a finished coil.

---

## What the customizer can and cannot carry

These results were measured on **OpenSCAD 2021.01** by rendering test files, not by reading
documentation. Every rule in _Three layers_ depends on them. The test files were not kept, so after a
version upgrade, repeat the tests before anything else.

- **`-D` reaches the globals of a `use`d file. `-p`/`-P` does not.** A parameter set assigns only
  parameters declared in the file being rendered. Keys that name globals of a `use`d file have no
  effect and give no warning. This is why designations must be in the entry file.
- **A parameter whose default is `undef` is invisible to the customizer.** Its type cannot be
  inferred, so no parameter set can assign it. This was proved by giving it a numeric default, after
  which the same set applied. This is why a designation defaults to `"auto"` and never to `undef`.
- **A flat vector can be passed, but only as a string holding a SCAD literal.** A native JSON array
  is ignored without warning; `"[\"x\",\"y\"]"` applies, and may change length. Anything that
  generates a parameter set must emit that form.
- **A nested table cannot be passed at all**, in either encoding. Port tables and registry rows stay
  in SCAD, and only their names are passed.
- **`-p` overrides `-D` on the same key, without warning.** Keep the two sets of keys separate.
- **Almost every failure exits 0**: a bad `-P` name, a missing file, an unknown key, a value that
  cannot be parsed. Detect failures with a stderr grep or a `jq` check, never with `$?`.
- **`-o /dev/null` does not render at all.** It exits 1 because the file suffix is missing. A check
  written that way passes whatever it is run on, which is the kind of check this document warns
  against throughout. Export to a real file.
- **Dropdown annotations are comments**, so an option list cannot be generated at runtime. Where a
  list mirrors a registry, both the list and the registry say so.

---

## Standalone previews

Each subassembly renders on its own. These previews must **derive** the values the assembly would
pass them, not quote the resulting numbers. A preview that quotes a bolt circle keeps building the
old one after the real derivation changes, and a part exported from it will not fit.

A preview may choose only what the assembly chooses: the vessel, the light, the wall thickness, the
flange height. Everything downstream of those is derived.

**A subassembly keeps its own parameters as live standalone defaults.** Being able to open
`head.scad` and work on it directly is worth more than the purity of deleting them, and an assembled
build overrides them only through the departures it states. Where a preview must restate a value the
assembly owns, the restatement carries the drift label. It is two expressions kept in step by
discipline and by the echo, not by construction, and it should be visibly marked as such rather than
silently correct.
