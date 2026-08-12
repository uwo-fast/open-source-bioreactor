# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [ ] rethink how the impeller diameter is driven, and guard it
  - `head()` scales it off `vessel_outer_diameter`, but what it has to pass through is the vessel *opening*; nothing asserts the impeller is smaller than the opening, so an out-of-range `impeller_impeller_vessel_outer_diameter_factor` silently models an impeller that cannot be installed
- [ ] caliper the real jar rim against the registered profile
  - the lid's gasket recess is cut to the flat land on top of the glass, which the model puts at 5.00 mm wide (r 71.5 out to 76.5) with a 2 mm bead rolled outboard below it. That land comes from the registered `rim_radius` and wall thickness rather than from a measurement, and the recess width follows from it, so it is worth confirming before cutting a gasket to it
- [ ] align the assembly -> subassembly -> part parameter interfaces
  - `head.scad` and `frame.scad` hardcode the vessel dimensions in their standalone preview calls (`220 / 143 / 295` and `305 / 220`), which reproduce `jar_10L_220x305` — 295 being a hand-copy of the derived `vessel_internal_height()`. Deliberate for now so each subassembly previews standalone; fold into the interface pass rather than patching piecemeal
- [x] carry the probe tail and connector dimensions in `atlas_probes.scad` and read them back
  - first attempt added a four-number tail group, which was wrong: tracing the geometry showed it held one dead number, two collet-shape numbers, and one derived hex size — no probe facts at all. `tail_maj_d` was provably inert (8.7 → 6 and 8.7 → 9.1 both render an identical part, because the port's hex cut is 9.18 across flats and removes strictly more), and it duplicated `neck`, which already described the same strain relief boot
  - settled shape: the registry holds one group per physical feature — `neck` the boot, `body` the cap, `tip` the shaft, `conn_d` the connector — and `bayonet_probe_port` derives the rest. The collet's neck section houses the boot, so `neck` sizes it; the hex is derived as `(conn_d + allowance) / cos(30)` so a round Ø8 connector clears the flats, instead of the magic 10 that silently encoded the same sum
  - envelope unchanged, internal cavities changed on purpose: same z extent and max radius, 9300 → 9556 facets

- [x] put the pH and DO caps on their datasheet values
  - they carried caliper readings of 15.6/16.0 and 36.0/35.6 where all six of those sheets say 16.0 x 36.2. Every row in the registry is now the product as its sheet describes it, with no exceptions, and the collet's allowances do the compensating
  - the `15.9` soft-backed / `16.3` hard-backed numbers are dropped. No datasheet mentions a backing variant, so it is not tracked; `cylindrical_flex_collet.scad` is a generic module and its preview values are just example hardware. If a backing variant turns out to be a real product it gets its own registered row

## nice to haves

- [ ] Add curve / inflection point to holes in bayonet connectors to grip tubes better
  - sehan's idea, currently they grip really tight already so this is just a thought for improving the design if we find the tubes are slipping out too easily in testing; or if we wanted to reduce the interference fit and make it easier to insert the tubes in the first place while keeping them from slipping out
- [ ] optional end styles (sensor gland) for atlas probes to match product more closely
- [ ] register lights per cord on the strip lights and drive the frame from it
  - recorded in the row comments for now: `rwntao_13in` is 3 tubes per cord, the three `grow_*` are 4. `lights_per_quadrant` in `frame.scad` is still set by hand and has no relation to what a cord actually carries
  - `strip_lights.scad` would gain the count, and `frame.scad` would derive placement from it rather than from a free parameter — cords come in fixed multiples, so the current setup can ask for a light count no purchasable product provides

## bill of materials

- [ ] add the sealing parts the model now calls for
  - AS568-160 EPDM o-ring, 5.237 in ID x 0.103 in cord, one per lid. It centres the plug in the neck and is stretched onto a groove sized from the jar's bore, so a substitute has to land in the range `head.scad` echoes at render: 132.098 to 138.703 mm ID, which is 0 to 5% stretch
  - EPDM sheet stock, 1.5 mm, for the rim gasket. The cut is 145 x 151 mm and is echoed too, so the row can quote it rather than duplicate the arithmetic
  - the existing "Silicone gasket ring, 142 mm ID" row is this same rim gasket under an older name, at a size that cannot pass over the 142.6 mm plug. Replace that row rather than adding beside it
- [ ] add the motor mount joint fasteners
  - 4 heat-set inserts and 4 M4 x 8 socket head screws per lid. The insert is registered in `scad/purchased/heat_set_inserts.scad` and picked out in `docs/procurement.md`; the screw length is derived from it, so the row can quote what `head.scad` echoes rather than repeat the arithmetic
  - a soldering iron with a conical tip is the install tool, and stainless wants more heat and dwell than brass would. McMaster sell tips for it if we do not want to use a working iron's bit
- [ ] the head-to-frame joint fasteners have no rows at all
  - the model draws 8 M8 hex bolts clamping the lid flange to the top base, 8 nuts for them, and 3 nuts on each of the 4 tie rods - 20 M8 nuts in total. Only the rod itself is listed
  - hold the bolt length until the lid-to-top-base gap is settled: `frame.scad` sizes them for an 18 mm grip and so picks M8x25, but the real span across the gap is 20.4 mm and wants M8x30. That gap is the first work package of the parameter audit, so buying against the current figure would be buying the wrong bolt

## tooling / infrastructure / documentation

- [ ] add PowerShell and shell scripts to export a chosen assembly parameter set (eventually JSON, once the assembly is fully parameterized) as individual STL files, together with a print list, BOM, and other relevant build outputs
- [ ] run `tokei` in CI to report lines of code and other codebase statistics
- [ ] adopt the Just the Docs OpenSCAD setup for this project, including its web-based OpenSCAD preview

## second hardware revision

- [ ] use a less expensive shaft for the impeller and try and get in 300mm instead of oversized 400mm thats being compensated by the parameteric printed motor mount
  - might not need to be linear motion surface rated and all that
- [ ] swap out the threaded rods with printed parts
