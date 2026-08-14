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

---

## Purchased parts are registered rows that drive geometry

Every bought part is a row in `scad/purchased/`, and the geometry is cut from the row rather than
from numbers typed beside it. The hole is derived from the insert; the pocket from the bearing; the
gasket recess from the sheet's thickness.

The failure this prevents: a heat-set insert was once modelled from a library row that **was not a
purchasable part**, and the lid was printed for it. A registry row must describe something orderable,
and where a library already carries the real part (`BB608` is the 608 bearing actually bought) the
library row is used directly rather than copied.

---

## Asserts versus echoes

This reactor is a research instrument. A parameter outside the usual range may be exactly what
someone is studying, so the model reports rather than refuses.

- **Assert** only what is physically impossible or unbuildable — an impeller too wide to pass the
  vessel mouth, a pocket cut through into the culture, a nut deeper than the base it sits in.
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

**`just check-scad`** evaluates every file in both directions: the ones meant to render standalone
must emit geometry, and every other file must emit **none** — a registry that draws its own example
draws it into every consumer, which has happened once already. A new entry file therefore fails
until it is listed, which is the point.

---

## Standalone previews

Each subassembly renders on its own. Those previews must **derive** what the assembly would hand
them rather than quote the resulting numbers — a preview that quotes a bolt circle keeps building
the old one after the real derivation moves, and a part exported from it will not fit.

What a preview may legitimately choose are the things the assembly chooses: the vessel, the light,
the wall thickness, the flange height. Everything downstream of those is derived.
