# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [ ] rethink how the impeller diameter is driven, and guard it
  - `head()` scales it off `vessel_outer_diameter`, but what it has to pass through is the vessel *opening*; nothing asserts the impeller is smaller than the opening, so an out-of-range `impeller_impeller_vessel_outer_diameter_factor` silently models an impeller that cannot be installed
- [ ] align the assembly -> subassembly -> part parameter interfaces
  - `head.scad` and `frame.scad` hardcode the vessel dimensions in their standalone preview calls (`220 / 143 / 295` and `305 / 220`), which reproduce `jar_10L_220x305` — 295 being a hand-copy of the derived `vessel_internal_height()`. Deliberate for now so each subassembly previews standalone; fold into the interface pass rather than patching piecemeal
- [x] carry the probe tail and connector dimensions in `atlas_probes.scad` and read them back
  - added as `[tail_maj_d, tail_min_d, tail_h, conn_d]` at index 4, keeping `wire_d` and `accent_color` last as the scalar tail of the row. That shifts those two to 5 and 6 rather than appending — safe because every index lives in `atlas_probe.scad`, checked against the whole tree
  - four scalar accessors added; `head.scad` and `bayonet_probe_port.scad` now read them back and hold only the collet's own design choices. Printed geometry byte-identical — verified as the same 9300-facet vertex multiset
  - the body pair moved earlier (`3835aed`, `fd2b824`), so four numbers moved here rather than six

- [ ] reconcile `neck` against the tail group — they describe the same strain relief boot and disagree
  - surfaced by the move above: `neck` reads 5 at the cord widening to 10 at the cap over 26 mm, the tail group reads 8.7 at the cap narrowing to 4.3 at the cord over 24.5 mm. Same feature, opposite ends. They were never side by side before, so the conflict was invisible
  - both are caliper readings, of different probes. `neck` came off the June 2026 session (`6332a84`) that also measured body 15.6 — the probe these ports are built for — and its 26 mm matches the four sheets that dimension the boot. The tail numbers came off the April 2026 session (`52757dc`) on the hard-backed unit, body 16.3, which still has no registered row
  - so a printed collet mixes the two: cap bore from the registry, boot hole from `tail`. Measured in the rendered part, the bore at the plane the cap seats against is Ø8.697
  - **check before changing anything**: push a probe into a printed port. If the boot really were Ø10 at the cap the probe would stand ~6.8 mm proud, which is too obvious to have gone unnoticed — most likely the soft boot just deforms through, making this bookkeeping rather than a fit fault. If it does stand proud, `tail` needs `neck`'s numbers
  - resolving it either deletes the tail group's first three numbers (read `neck` instead, leaving only `conn_d`) or corrects `neck`. Changing either moves printed geometry, so measure first
  - still open from the original entry: `15.9` soft-backed / `16.3` hard-backed. `15.9` is gone from the tree; `16.3` survives in `cylindrical_flex_collet.scad` and is now commented as the hard-backed variant. None of the 15 datasheets mentions a backing variant, so this is a caliper question. The backing variant may want its own registered row

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
