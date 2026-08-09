# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [ ] rethink how the impeller diameter is driven, and guard it
  - `head()` scales it off `vessel_outer_diameter`, but what it has to pass through is the vessel *opening*; nothing asserts the impeller is smaller than the opening, so an out-of-range `impeller_impeller_vessel_outer_diameter_factor` silently models an impeller that cannot be installed
- [ ] align the assembly -> subassembly -> part parameter interfaces
  - `head.scad` and `frame.scad` hardcode the vessel dimensions in their standalone preview calls (`220 / 143 / 295` and `305 / 220`), which reproduce `jar_10L_220x305` — 295 being a hand-copy of the derived `vessel_internal_height()`. Deliberate for now so each subassembly previews standalone; fold into the interface pass rather than patching piecemeal
- [x] carry the probe tail and connector dimensions in `atlas_probes.scad` and read them back
  - first attempt added a four-number tail group, which was wrong: tracing the geometry showed it held one dead number, two collet-shape numbers, and one derived hex size — no probe facts at all. `tail_maj_d` was provably inert (8.7 → 6 and 8.7 → 9.1 both render an identical part, because the port's hex cut is 9.18 across flats and removes strictly more), and it duplicated `neck`, which already described the same strain relief boot
  - settled shape: the registry holds one group per physical feature — `neck` the boot, `body` the cap, `tip` the shaft, `conn_d` the connector — and `bayonet_probe_port` derives the rest. The collet's neck section houses the boot, so `neck` sizes it; the hex is derived as `(conn_d + allowance) / cos(30)` so a round Ø8 connector clears the flats, instead of the magic 10 that silently encoded the same sum
  - envelope unchanged, internal cavities changed on purpose: same z extent and max radius, 9300 → 9556 facets

- [ ] put the pH and DO caps on their datasheet values
  - the registry is meant to be the product as its sheet describes it, with the consuming part's allowances absorbing tolerance. The pH and DO rows are the last exception: caps carry caliper readings of 15.6/16.0 and 36.0/35.6 where all six of those sheets say 16.0 x 36.2
  - this moves printed geometry — the collet bore and grip length both come off it — so it wants a deliberate pass, not a silent edit
  - the `15.9` soft-backed / `16.3` hard-backed question folds into this. `15.9` is gone from the tree; `16.3` survives in `cylindrical_flex_collet.scad`, commented as the hard-backed variant. No datasheet mentions a backing variant, so if it is a real product it wants its own registered row rather than a competing number

## nice to haves

- [ ] Add curve / inflection point to holes in bayonet connectors to grip tubes better
  - sehan's idea, currently they grip really tight already so this is just a thought for improving the design if we find the tubes are slipping out too easily in testing; or if we wanted to reduce the interference fit and make it easier to insert the tubes in the first place while keeping them from slipping out
- [ ] optional end styles (sensor gland) for atlas probes to match product more closely
- [ ] register lights per cord on the strip lights and drive the frame from it
  - recorded in the row comments for now: `rwntao_13in` is 3 tubes per cord, the three `grow_*` are 4. `lights_per_quadrant` in `frame.scad` is still set by hand and has no relation to what a cord actually carries
  - `strip_lights.scad` would gain the count, and `frame.scad` would derive placement from it rather than from a free parameter — cords come in fixed multiples, so the current setup can ask for a light count no purchasable product provides

## second hardware revision

- [ ] use a less expensive shaft for the impeller and try and get in 300mm instead of oversized 400mm thats being compensated by the parameteric printed motor mount
  - might not need to be linear motion surface rated and all that
- [ ] swap out the threaded rods with printed parts
