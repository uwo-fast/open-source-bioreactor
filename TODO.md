# TODO

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)
- [ ] give `gearbox_36gp_5p18` an input recess that actually receives the motor's boss and shaft
  - it models its input as one `[22, 3]` bore, so the boss (8 x 3) and shaft (2 x 8) on `motor_36gp_3530_5p18` intersect the gearbox body instead of seating in it; fine while it is only visualisation, wrong once anything keys off that interface
  - the 22 may be a mis-assignment rather than a measurement: `gearbox_36pg_3429_5p2`'s vendor drawing shows a 22 mm pilot register on the *output* face, so the same number may have been read off the wrong end
- [ ] rethink how the impeller diameter is driven, and guard it
  - `head()` scales it off `vessel_outer_diameter`, but what it has to pass through is the vessel *opening*; nothing asserts the impeller is smaller than the opening, so an out-of-range `impeller_impeller_vessel_outer_diameter_factor` silently models an impeller that cannot be installed
- [ ] align the assembly -> subassembly -> part parameter interfaces
  - `head.scad` and `frame.scad` hardcode the vessel dimensions in their standalone preview calls (`220 / 143 / 295` and `305 / 220`), which reproduce `jar_10L_220x305` — 295 being a hand-copy of the derived `vessel_internal_height()`. Deliberate for now so each subassembly previews standalone; fold into the interface pass rather than patching piecemeal
- [ ] carry the probe tail and connector dimensions in `atlas_probes.scad` and read them back
  - the collet needs six hardware numbers the registry does not hold, so they are entered again in `head.scad` (`probe_port_*`) and a third time in `bayonet_probe_port.scad` (`_bp_*`)
  - proposal: append one group rather than reshuffle, so every existing accessor keeps its index — `["name" [neck…], [body…], [tip…], wire_d, accent_color, [tail_major_d, tail_minor_d, tail_len, connector_d]]` — with `atlas_probe_tail(type) = type[6]` and four scalar accessors beside the existing ones
  - the collet's own design values (wall thickness, allowances, tab gap, deflection, tilt) are choices not probe facts, so they stay in `head.scad`; only the six hardware numbers move
  - decide first: `body_d` is already registered yet still duplicated, and there are four values in play for it — `15.6` (ph) and `16.0` (do) in the registry against `15.9` soft-backed / `16.3` hard-backed in the comments. Measurement question before schema question; the backing variant may want its own registered row
  - caveat: the tail group describes the connector end, which `atlas_probe()` itself does not draw, so it is data held for a consumer rather than for the model

## nice to haves

- [ ] Add curve / inflection point to holes in bayonet connectors to grip tubes better
  - sehan's idea, currently they grip really tight already so this is just a thought for improving the design if we find the tubes are slipping out too easily in testing; or if we wanted to reduce the interference fit and make it easier to insert the tubes in the first place while keeping them from slipping out
- [ ] optional end styles (sensor gland) for atlas probes to match product more closely

## second hardware revision

- [ ] use a less expensive shaft for the impeller and try and get in 300mm instead of oversized 400mm thats being compensated by the parameteric printed motor mount
  - might not need to be linear motion surface rated and all that
- [ ] swap out the threaded rods with printed parts
