# Design conventions

Rules this model is built to. They were arrived at by getting them wrong first, so each one carries
the failure it exists to prevent. Anything contradicting them is a defect rather than a variation.

---

## The rim datum

**The lid is located by the glass rim.** Its gasket seats on the flat land on top of the glass and
its plug enters the mouth. The rim is fixed by the jar; the frame's top base is derived *below* it.

The consequence that matters: the **2.4 mm gap** between the top base's upper face and the lid
flange's underside is *required*, not slack to be removed. It is the clearance that lets the joint
bolts pull the lid down **into** the vessel rather than bottoming it on the frame. Every span
crossing the joint has to count it — bolt grips, nut placements, anything measured from one side to
the other.

Anything that seats the lid on the frame instead of the glass is wrong. This was mis-derived
backwards twice before it was written down.

**Frame coordinates.** The frame builds with z = 0 at its own floor, then draws its body offset by
`−base_floor_height`. Frame-local `total_height` = 349.75 is assembly z = 305, the rim. If those
look contradictory, the offset has been forgotten.

---

## One physical thing, one expression

The repo's recurring defect: one physical fact stated twice, in two places, which agree until one
moves. Every instance found this way was silent — the model built happily and the two numbers
simply diverged.

Real examples, each of which shipped:

- The **strip light** was selected twice — the assembly passed only its length while the frame read
  its own second selection. Changing the light resized the frame around a pocket that never moved.
- The **impeller ratio** multiplied the vessel's outer diameter where D/T means the bore, so the
  real ratio drifted with glass thickness rather than being held constant.
- The **cart** sized its envelope off the bare jar, so two bioreactors on a tier overlapped by
  17.4 mm and each passed through the rail above it.
- The **bearing's** allowance was applied twice — once folded into the registered diameter and again
  as the pocket allowance — leaving the pocket 0.8 mm oversize.

The fix is always the same shape: one expression, read back by whoever needs it. Subassemblies
export accessors (`frame_outer_diameter()`, `head_gasket_factor()`) rather than have consumers
rebuild the value.

**Name the quantity, not a quantity that resembles it.** Three defects here came from names that
permitted two readings — outer diameter versus bore, motor speed versus output speed, screw centre
distance versus bolt circle. If a field could be read two ways, it eventually will be.

**Documents are the second expression.** The same defect appears in prose, and there it is worse:
the model cannot check a document, so a stale figure sits unchallenged until a reader trusts it.
Eight were found in one pass — a D/T cap the model had moved, a thermocouple nothing buys, a pump
delivery the model explicitly retracts in its own echo, a fenced echo quoting a number the model no
longer emits, and one document stating both that the baffle hangs its full length and that it has
never been lengthened.

Prefer quoting an accessor or an echo over restating its result. Where a figure must be written out,
**check it against the model rather than against another document** — several of these agreed with
each other and with nothing else.

**A corrected figure gets its predecessor labelled, not deleted.** The form is
`(Superseded — kept for the record.)`, followed by what the number was and what made it wrong. The
old value is evidence: it records which assumption failed, and deleting it invites the same mistake
back. Three of the eight above were live only because the correction was made somewhere else and
the original was left standing with nothing marking it.

---

## Three layers, and where a parameter lives

The model was built on two: things two components must agree on, which live in `assembly.scad`, and
a component's own preferences, which live in its own file. That is right as far as it goes, and it
misses a third kind, which surfaced when a build's choices had nowhere to be stated.

A **DESIGNATION** is a per-reactor choice: which registered jar, which motor, which probe in which
port, what fill fraction. It is not a preference — it is about *this* build, not about the design —
and it is not classic coupling, because `assembly.scad` may never consume it. It is forced into the
entry file anyway, by a platform fact: a customizer parameter set can only assign parameters
declared in the file being rendered. See *What the customizer can and cannot carry*.

**Where a parameter lives.** It belongs in `assembly.scad` if any of these hold:

- two or more components must agree on it;
- `assembly.scad` itself consumes it in a derivation — `frame_wall_thickness` feeding
  `joint_outer_diameter`, the fill fraction feeding light selection, the shaft feeding the envelope;
- it is a designation, a per-reactor choice an operator states.

Everything else stays in the component that embodies it: allowances, wall thicknesses, land margins,
joint geometry, and the search that derives a designation left unstated.

**A designation travels as a NAME, never as a row.** A parameter set holds values, not references,
so a registered row cannot be named directly. The form is a string parameter resolved through that
registry's by-name lookup — `reactor_vessel_name` with `vessel_by_name()` is the pattern — with a
loud assert on a name nothing matches. `"auto"` means *derive it*.

That string is not the plausible number this document bans elsewhere. `undef` is unavailable here
(the customizer cannot see it) and a numeric sentinel would be exactly the plausible value that
propagates unnoticed into arithmetic. A string cannot: it is visible in the surface, it is carried,
and it is consumed by a mode branch that never multiplies it by anything.

**Only departures travel.** The build list packs only what a build actually states; anything left at
`"auto"` is omitted, so the component's own search remains the single expression of the default.
Nothing is ever declared live in two files with defaults kept in step by hand.

**A value read back out of a component is an argument whose default is that component's own.**
`function head_gasket_factor(sheet = lid_gasket_sheet)` — verified: a default argument resolves in
the file that defines the function, not the caller's, so one expression serves both the standalone
preview and the assembled build and the readback cannot disagree with the geometry it describes.

**Pinning does not switch the checks off, it inverts them.** A designated row runs the same fit
asserts the derived one would have, and the echo reports what was pinned *and what derivation would
have chosen*. A selection over a registry holding one row says so — "sole registered row,
fit-checked, not chosen" — rather than implying a choice was made.

---

## Purchased parts are registered rows that drive geometry

Every bought part is a row in `scad/purchased/`, and the geometry is cut from the row rather than
from numbers typed beside it. The hole is derived from the insert; the pocket from the bearing; the
gasket recess from the sheet's thickness.

The failure this prevents: a heat-set insert was once modelled from a library row that **was not a
purchasable part**, and the lid was printed for it. A registry row must describe something orderable,
and where a library already carries the real part (`BB608` is the 608 bearing actually bought) the
library row is used directly rather than copied.

**The contract every registry owes.** A rows list; a `*_name()` accessor; a part number where a
stable one exists, and `undef` with the reason where it does not; provenance travelling with each
value; and a `*_by_name()` lookup wherever the part is designatable. Data-only registries — rows
that carry numbers and draw nothing — are legitimate.

**Only orderable rows go in the swept list.** The list is what `check-vessels` and the sweeps build
against, so a placeholder in it means "this builds" covers something nobody can buy.

**Designatable is not the same as purchased.** Every bought thing is a registered row; only the ones
an operator actually picks per reactor get a by-name lookup and a slot on the build surface. The
bearing, the heat-set inserts, the screws, the riser tube and its o-ring, the hose clamp are the
design's bill of materials — one expression each, not a menu.

---

## A number is a claim, and it carries how good a claim it is

Parametric CAD makes numbers adjustable. It does not make them *true*, and adjustable-but-unfounded
is the more dangerous state, because the model looks equally confident either way.

So every quantity in this model is one of four kinds, and which kind it is travels with it:

- **measured** — a source states it for this exact thing. `impeller_rushton_6`'s `Po 4.17 ± 0.14`.
- **correlated** — a published correlation computes it from this geometry, and can say where that
  geometry leaves the correlation's validity. `pbt_45_4` takes `Po` from Medek this way.
- **borrowed** — no source reaches this shape, so a nearby one's number stands in. Always echoed,
  never silent.
- **reasoned, not cited** — nothing in the literature held here supports it and the model needs a
  value anyway. Marked in the source with that exact phrase: the 0.5 D coverage floor, the baffle
  load, the mount slenderness limits, a diaphragm pump's curve taken as linear.

The failure this prevents is a borrowed number acquiring the authority of a measured one by sitting
in the same table. This model ran for months on `Po = 0.99` borrowed from a differently shaped
blade, annotated *conservative*; when the correlated value arrived it was **1.602**, so every power,
torque and dissipation figure had been 62 % optimistic while carrying a note saying the opposite.

**A registry row states what a source says, not what the design wants.** Where a source gives a
band, register the band. Where it gives nothing, register `undef` rather than a plausible number —
`undef` propagates and gets noticed, a plausible number does not.

---

## Report the departure, not just the number

Every correlation has a validity envelope, and this vessel is outside several of them. That is
normal for an instrument built from jars rather than from a vendor's catalogue. What is not
acceptable is *not knowing* which ones.

So a check returns the **names** of what it violates, not a boolean:

```
impeller: pbt_45_4 Po 1.49833 and flow number 0.893455 from Medek's correlation
at 45 deg, extrapolated on ["T/D", "H/T"]
```

`stirred_tank_medek_departures()` returns a list because an extrapolation that is out on one count
is a different thing from one that is out on four, and a caller that only learns `false` cannot tell
them apart or say which to fix. Two of those three departures were removable — a fourth baffle
retired one, D/T would retire another — and that was only visible because they were named.

The same shape applies to bands the design is measured against: echo the value, the band, and the
source's own framing. Oldshue's `1–2 d` is an **allowance** — *"if the impeller can be placed…
these impellers offer"* — so falling outside it is reported, not warned. And it is an allowance for
**fluidfoil** impellers, which this pitched blade is not, so the model says that too rather than
quietly grading one impeller class against another's guidance.

---

## Report a fit before you build the part

Register the geometry and its clearances, render, and read them — then draw. The reporting is
cheaper than the part and it is what catches the arithmetic.

The case that made this a rule: a sparge ring was planned at 1.4 D with **1.60 mm** of clearance to
the baffles. That figure was ring *centreline* to baffle edge; the ring has a 6 mm section, so its
inner face is 3 mm further in and the true clearance is **−1.40 mm**. The ring overlapped. Nothing
about the plan looked wrong — the number was plausible, stated with a unit, and derived from real
dimensions. The assert caught it on the first render, before any geometry existed.

Working it properly then changed the design rather than the number: the radial band available is
6.95 mm, no round section of 6 mm fits it at any diameter, and the squeeze is entirely radial while
73 mm of height sits unused. The ring's section became 4 × 10 mm, which is also the reason it is
printed rather than bent — **a tube is round, and round does not fit**.

A model whose checks only run after the geometry exists will confirm whatever was built.

---

## The model should be able to catch its author

The point of the three sections above is not documentation. It is that the model disagrees with the
person editing it, in the same session, before anything is committed.

Every one of these was found by a check rather than by re-reading:

- `head()`'s `z = 0` is the lid's **outer** face, which the assembly seats `lid_flange_height` above
  the rim — so every vessel-referenced depth was **8 mm** out, and the drivetrain was drawn higher
  than the model reported it.
- The baffle area ratio compared plate **width** against a reference **area**, reporting 0.83 for
  baffling that was actually at 0.14.
- Medek's four-baffle condition was evaluated against `len(undef)`, because `_baffle_at` was
  assigned 230 lines below its first consumer — so it reported a departure on a lid that has four.
- A pitched blade run out to `radius` sweeps **past** the diameter its power number is defined on,
  because a tilted rectangle's outermost points are its corners. 1.5 % on diameter is 7 % on power.
- A round feed boss on the sparge ring was wider than the ring's own section and fouled the baffles
  and the jar's mouth simultaneously, at 0.29 and 0.26 mm.

None of these were subtle once seen and none were visible while writing the code that caused them.

**What this costs.** It is verbose, and it is only as good as the checks someone bothered to write —
a number can be wrong in a way nothing checks, and a reported band is not a promise the value is
right. `reasoned, not cited` is still a guess; it is only a *labelled* guess. The claim here is
narrow: that labelling which numbers are weak, and naming which conditions are violated, converts a
class of silent drift into a line of render output.

---

## Asserts versus echoes

This reactor is a research instrument. A parameter outside the usual range may be exactly what
someone is studying, so the model reports rather than refuses.

- **Assert** only what is physically impossible or unbuildable — an impeller too wide to pass the
  vessel mouth, a pocket cut through into the culture, a nut deeper than the base it sits in.
- **And cited bands at the pressure boundary may assert**, which is a deliberate exception rather
  than a lapse. The three o-ring checks — riser stretch, plug gland fill, plug containment — guard
  the seal between the culture and the room, and they come from gland practice rather than from
  this project's judgement. A seal outside its band is nearer unbuildable than it is to a variation
  someone is studying. A limit that is `reasoned, not cited` does **not** get that authority: it
  echoes.
- **Echo** the value and the literature band it sits against, with a distinct warning line when it
  falls outside. The build continues.

### Dead versus weak asserts

- **Dead** — the expression cannot vary, so no input reaches the failure. Delete it; it reads as
  coverage while providing none.
- **Weak** — it varies, but only absurd inputs trip it. Cheap insurance, keep it.

**Deadness is tested by sweeping the assert's own driving parameter**, never a proxy. Sweeping the
vessel registry proves nothing about a guard driven by cord diameter. Two asserts were deleted this
way after proving algebraically that their terms cancel; one more was very nearly deleted on a
proxy sweep before the correct driver showed it firing.

An assert derived from the thing it checks can never fire. If the code just computed the
relationship, do not then assert it.

---

## Verifying a change

Two OpenSCAD behaviours govern how anything here is checked, and both are counter-intuitive:

**A failing assert still exits 0.** A failed CSG export returns success and writes a ~1 byte file.
Nothing may be gated on `$?` — `just check-scad` greps stderr for `ERROR` and uses file size as a
backstop. Before this was understood, every failing vessel in a six-vessel sweep looked like a pass.

**Mesh export is not reproducible; CSG export is.** The same file exported three times gave 29454,
29452 and 29456 facets at three different file sizes, while the distinct z-level set and the
bounding box were identical across all three and the CSG output hashed identically.

So:

- *valid* evidence — CSG diffs, distinct z-levels, bounding boxes, per-feature coordinates
- *not evidence* — facet counts, STL file size, STL hashes

This also rules out STL hashing as a regression check for any future export tooling.

**A CSG diff is blind to whatever the preview drops.** `head.scad` sets
`$bayonet_shell_only = $preview && fast_bayonet_preview`, which makes the bayonet library emit bare
shells and skip every pin, channel and notch. CSG export runs in preview, so a CSG comparison shows
those features as unchanged **whatever was done to them** — a change to the pin angles came back
byte-identical, twice, before this was understood.

So a CSG diff proves nothing about a feature the preview is suppressing. Either render the affected
part on its own, or pass `-D fast_bayonet_preview=false` and compare that. The general form: **check
what the flags were before trusting what the diff says**, because a diff of two things that were
never drawn is a clean diff.

**`WARNING` is evidence too.** OpenSCAD reports an undef reaching arithmetic as a warning, not an
error, and a parse error in a `use`d file shows up as nothing else at all — a missing comma between
two string literals silently stopped `head.scad` exporting any of its functions while the file still
rendered on its own, and ninety warnings rode along unnoticed because the gate only grepped `ERROR`.
`check-scad` now fails on either.

**`just check-scad`** evaluates every file in both directions: the ones meant to render standalone
must emit geometry, and every other file must emit **none** — a registry that draws its own example
draws it into every consumer, which has happened once already. A new entry file therefore fails
until it is listed, which is the point.

**Neither of those runs CGAL, so neither can see a broken solid.** `.csg` export is a dump of the
tree, not an evaluation of it, and a mesh export tessellates without being asked whether the result
closes. The impeller's blades were drawn TANGENT to the hub — 264 non-manifold edges — and every
check above passed on it, every render, every time. It was found by measuring the STL.
**`just check-mesh`** closes that: it renders to a mesh and fails on a defect count above zero, and
**`just export-parts`** applies the same test to every part on the print manifest, one at a time.

**A check must be run in the configuration that makes the part, not the one that makes the
picture.** Four entry files render an assembly by default, and `check-mesh` used to skip all four as
"slow" and invite you to run them before a print. Three of them cannot pass: `head.scad`'s printed
geometry alone IS a 2-manifold, and what breaks it is `render_seals`, `render_probes`, and the
bearing with its coupling — EPDM in its grooves, Atlas bodies in their collets, a bearing on the
shaft, every one of them already on `check-parts`' `not_printed` list. So the check failed on
vitamins the repo had declared are not printed, could never pass, and taught anyone who ran it to
ignore it. `electronics_stand.scad` was on that list too and is not even slow: 14 s as a picture,
and 4 s as the bracket it prints, which is a clean 2-manifold. It is checked now.

**A check that cannot pass is worse than no check**, because the next real failure reads as more of
the same noise.

**Check at the `$fn` the desk uses, not only the one CI pins.** `$fn` is dynamically scoped, and
2021.01 lets a `use`d module resolve it from its own file where newer builds pass the caller's — so
a module that divides by `$fn` is fine under one and produces `nan` under the other. Nobody sees it,
because a `nan` propagates into a comparison that is simply false. `check-scad` runs a second pass at
**`-D '$fn=0'`**, which is what an unset viewport actually is, and geometry derives its facet count
from `$fa`/`$fs` rather than reading `$fn` off the caller.

---

## What the customizer can and cannot carry

Measured on **OpenSCAD 2021.01**, by rendering probes rather than by reading documentation. Every
rule in *Three layers* rests on these, so a version bump re-runs them before anything else.

- **`-D` reaches a `use`d file's globals. `-p`/`-P` does not.** A parameter set assigns only
  parameters declared in the file being rendered; keys naming a `use`d file's globals do nothing,
  silently. This is the fact that forces designations into the entry file.
- **A parameter defaulting to `undef` is invisible to the customizer.** It has no inferable type, so
  no parameter set can assign it. Proved by giving one a numeric default, at which point the same
  set applied. This is why a designation defaults to `"auto"` and never to `undef`.
- **A flat vector is carryable, but only as a string holding a SCAD literal.** A native JSON array
  is ignored without warning; `"[\"x\",\"y\"]"` applies, and may change length. Anything
  generating a parameter set has to emit that form.
- **A nested table cannot be carried at all**, in either encoding. Port tables and registry rows
  stay in SCAD; only their names travel.
- **`-p` beats `-D` on the same key, silently.** Keep the two key sets disjoint.
- **Almost everything fails at exit 0** — a bad `-P` name, a missing file, an unknown key, an
  unparseable value. Detection is a stderr grep or a `jq` check, never `$?`.
- **`-o /dev/null` does not render at all** — it exits 1 on the missing suffix. A check written that
  way passes whatever it is pointed at, which is the shape of check this document warns about
  everywhere else. Export to a real file.
- **Dropdown annotations are comments**, so an option list cannot be generated at runtime. Where one
  mirrors a registry, both ends say so.

---

## Standalone previews

Each subassembly renders on its own. Those previews must **derive** what the assembly would hand
them rather than quote the resulting numbers — a preview that quotes a bolt circle keeps building
the old one after the real derivation moves, and a part exported from it will not fit.

What a preview may legitimately choose are the things the assembly chooses: the vessel, the light,
the wall thickness, the flange height. Everything downstream of those is derived.

**A subassembly keeps its own parameters as live standalone defaults.** Opening `head.scad` and
working on it directly is worth more than the purity of deleting them, and an assembled build
overrides them only through the departures it states. Where a preview must restate something the
assembly owns, the restatement carries the drift label — it is two expressions held in step by
discipline and by the echo, not by construction, and it should be visible as such rather than
quietly correct.
