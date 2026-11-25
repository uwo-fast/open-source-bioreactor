# Future work

Ideas and their reasoning, recorded so that nobody has to work them out again. Nothing here is
planned or tracked. Open work is tracked as a GitHub issue, and work planned for after the paper is
labelled `post-pub` and linked from #90. When an idea here is picked up, it becomes one of those
and is removed from this file.

## Gas line

- **A water-column manometer for the pressure drop across the sterile filter.** The model's
  3.45 kPa per L/min is extrapolated from an equivalent 0.2 um PTFE disc. Correcting Pall's Acro 50
  for area gives 3.02, so the model is 14 % conservative. A water manometer at 1 and 2 L/min (35 and
  70 cm of water column) would test both the slope and its linearity. It would not work at the set
  flow, where 14.1 kPa is 1.44 m of water. The paper's runs fit the slope to a rotameter reading
  instead (#131), because a builder will not make or buy a manometer. A differential pressure bench
  is a separate project.

- **A trap or a longer exhaust tube instead of an outlet filter.** It would protect against
  splashback with no pressure drop, but it makes a different sterility claim from a filter.

- **The cost of a printed sparge face.** `custom/sparge_puck.scad` prints one outlet face per puck.
  The bench run is [The sparge test pucks](../analysis/methods/sparge-test-pucks/README.md).
  - A porous face is priced from a single borrowed data point. Scaling the membrane of Palfy et al.
    linearly to 4 L/min requires 15 times the open area of a 52.8 mm face, and at that size the
    pump would push about 0.28 L/min through it. The render warning gives both figures. Linearity
    is an assumption that a reading at three flows would settle.
  - Finer holes gain little on their own. The minimum bubble size scales with the cube root of the
    hole size, and near an impeller hole size has a negligible effect (Rewatkar & Joshi 1993, in
    0.57-1.5 m vessels). A finer face is therefore a question for the airlift ring first, not the
    arm.
  - The work ends with a measured row for each face, which `head()` includes in the gas line, as it
    does for the filter.
  - A bent steel tube sparger, made on a tube bender for about 1/8 to 2 in tube, is the unprinted
    alternative. Keep its tube size a parameter across that range.

## Sparger

- **Where the gas from the ring goes, if a stirred build uses the ring.** No registered build
  does. `jar_10L_220x305` uses the loop, the other stirred builds use the arm, and the airlift
  hangs the DO probe directly inside its tube. With the ring, the DO probe face would sit above a
  ring of bubbles in the convergence zone, which is the one position that can give wrong readings
  in both directions. The flow rate is not the concern (the bulk mean is 16x what the probe needs).
  The gas path is not modelled, and no source found gives the placement of a DO probe relative to a
  sparger. The free variables are the lean and the ring height, and both are already parameters.

- **The ring bore, not its holes, causes the departure, and fixing it changes more than one
  designation.** On `jar_10L` with the ring, at 4.09 L/min, the bore was swept with the holes held at
  8 x 3 mm. With 16 x 1.2 mm holes, the 4.0 mm row is 5.42 m/s at an open area of 1.44, and the
  24 Pa across a hole outweighs the 17.7 Pa of velocity head, although `head()` flags the bore
  again. The sweep needs redoing at that hole size:

  | bore, holes             | feed velocity | open area | velocity head | verdict                             |
  | ----------------------- | ------------- | --------- | ------------- | ----------------------------------- |
  | 4.0, 16 x 1.2 (today)   | 5.42 m/s      | 1.44      | 17.7 Pa       | 2 departures                        |
  | 8.0, 8 x 3 (old sweep)  | 1.36          | 1.12      | 1.1           | 1 departure; pH tip hits the ring   |
  | 8.5, 8 x 3 (old sweep)  | 1.21          | 1.00      | 0.9           | clean sparger; pH tip hits the ring |
  | 10.0, 8 x 3 (old sweep) | 0.87          | 0.72      | 0.5           | no room for a baffle                |

  `sparge_bore()` is the OD of the riser itself, so the bore is a designation:
  `steel_tube_welded_10x0p5` is registered, and there is no 8.5 row. The cost is the knock-on
  effects. The tube grows from 6.4 to 12.4 across the flats, and above 8 mm the wider ring meets
  the tip of the pH probe and then leaves no room for a baffle. The riser port bore, rod gland,
  pressure drop, support tube and BOM row all change with it. Not priced.

- **`check-holes` without a CGAL render, so that it can join `just check`.** Both ends of every
  hole are probed, and holes in an arm or loop a third time, in the wall just under the bore. The
  arm is checked by default, the ring with `-D head_sparger="ring"` and the loop with
  `-D head_sparger="loop"`. When it was written, it was verified by fault injection (a bore swept
  180 degrees failed 5 of 20 on `feed`). To join the gate it needs a probe that does not need a
  rendered mesh: the check is geometric and the part is a union of primitives. `spoke_holes` is not
  probed; no caller sets it, and `sparger()` refuses an arm without a bore.

## Baffles and lid

- **The lid plate width can be recovered from the lean allowance**, on any build that still hangs
  lid plates.
  - On `jar_10L` with lid plates (`baffle_name = "lid"`; both its registered builds use the cage),
    the plate stops at the 17.0892 mm lock bore: 12.9554 nominal, and 10.511 to the blades after
    2.44444 mm of lean. The 10.3454 mm limit from the ring applies only where the ring is built.
    `jar_1gal_180` is also at 17.0892.
  - The cost is baffle area: 0.713 of Oldshue's four baffles at T/12 with three plates on
    `jar_10L`, and 0.847 on `jar_1gal_180`, which gave its fourth port to a sampling line. The tip
    ring is off and remains a flag ([Decisions](decisions.md)).
  - The 2.44 mm lean is a worst case: bore play alone, multiplied 12.2x by leverage, ignoring face
    contact at the flange.
  - Fixes, cheapest first, costed against the old 15.3 mm plate: taper the inner edge of the plate
    with depth; deepen the bayonet engagement to 36 mm (halves the lean, adds a third joint); add a
    baffle-only interface row at 0.1 mm allowance (a tight bayonet, twisted by hand inside a jar).

- **The gasket recess holds three quarters of the rubber, which only matters on `jar_6p5gal`.** The
  recess is cut at `t(1-c)`, so `t*c` will not fit whatever the gasket. On a crowned rim the
  displaced rubber flows into the width that the contact chord never touches: on `jar_10L` that
  width is 4.762 mm, about 0.857 mm2 against 1.890 free. On the one ground jar it
  must escape across the lands. `jar_6p5gal` also has the highest load in the registry, 1253.6 N per
  post and 7.34 MPa, against 398.8 and 2.92 on `jar_1gal_180`, the next highest. This is reported,
  not asserted. The fix is a groove cross-section 10-25 % larger than the gasket; that jar has
  10 mm of rim where the gasket is limited to 6. Not pursued, because it changes the lid for one
  jar.

## Agitation

- **A Rushton below a pitched blade: the hybrid, set aside in favour of a standard design.**
  `head()` accepts a lower and an upper impeller type, so it is a one-line change:
  `head_impeller_upper_type = impeller_pbt_45_4`. Modelled on `jar_10L` at 320 rpm: 4.76 W,
  0.193 N m in total, and 0.5 vvm held to 147 rpm below and 287 rpm above. The case for it:
  - When asked what limits his microalgae cultures, the professor who recommended the Rushton
    answered that light usually does, CO2 supply can, and O2 removal is secondary. Light depends on
    circulation, which is the job of the pitched blade. CO2 depends on dispersion, which is the job
    of the Rushton.
  - **The gas limit is reached inside the operating band.** `head()` checks Oldshue's 8x rule at
    each drive speed, and the limit scales as N^3, so the pitched blade holds the 0.5 vvm design
    only above about 287 rpm. For the 94.5 mm pitched blade (D/T 0.45) that is 0.70 vvm at the
    rated 320 rpm and 0.35 vvm at its 255 rpm optimum for Chlorella. A radial impeller at the same
    power needs 3x, not 8x, and would hold about 0.94 vvm at 255 rpm.
  - **Circulation per watt**: about 1.8x in favour of the pitched blade at equal power and diameter
    ([Agitation](../docs/agitation.md#impeller)).
  - **At equal power, a Rushton is the gentler of the two.** Peak dissipation scales as
    `x Po^(-1/4) D^-3`, so a Rushton gives about 0.56x the pitched blade at the same diameter, and
    about 1.4x at D = T/3. Both are orders of magnitude below any damage threshold. Grenville's
    Figs. 6-7 show the Rushton producing the largest drops at equal power (in liquid-liquid
    systems, so only indirect evidence for gas). Its advantage with gas is that it keeps its flow
    pattern when gassed, not that it makes finer bubbles per watt.
  - The Rushton would be the lower impeller, over the sparger arm, where the gas enters first and
    where Oldshue puts 40 % of the dispersing work. The pitched blade would sit above it for
    circulation.

- **Measure the power number of the twisted paddle, so the blade can be published.** The build uses
  `impeller_rushton_6`. The twisted paddle remains registered, with no Po from any correlation, and
  its 0.634921 width ratio is the only unsourced ratio in `impellers.scad`. Measuring
  `Po = P/(rho N^3 D^5)` from shaft power at three or four speeds in water would settle it.

- **The annulus-sparged airlift (B).** The tube acts as the downcomer and the annulus as the riser,
  with bubbles rising along the lit wall. It needs a sparger outside the tube, which the ring
  cannot reach because its size is limited by the jar mouth. Chisti & Moo-Young 1987 recommend a
  cone under the turn for this layout
  ([References](../docs/references.md#the-airlift)).

- **Fix the draft tube in place, if a free-standing tube proves loose.** A plain lid leaves its
  centre free. A bayonet there, as on the other ports that carry hanging parts, would locate the
  tube from above rather than relying on the ring clearance. Alternatively, shape each foot to
  capture the ring, so that the ring holds the tube down and centred with no new part.

- **A magnetic build of `jar_6p5gal` needs larger magnets, not a deeper floor.** On a 35 mm riser
  it builds, coupling across the 13 mm below, but it is not registered. Its punt rises 15 mm at the
  magnet radius, and the carrier may not stand above the plane the jar rests on, so the hub cap
  grows 8 mm into the void under the punt and the magnets reach 1 mm below the punt. The 12 mm
  wall still puts them 13 mm from the culture, against 4-6 mm on every other jar. A 39 mm floor
  would take a 120 x 25 magnet at a 29 mm pitch, the best pitch of any jar, but would still couple
  across the same 13 mm. Only larger magnets would change that.

## Condenser

- **Offer the split cold finger as an alternative to the coil in `head()`.** The coil is already
  placed: its body is the `air_out` pin, the port carries no tube, and the gas line includes its
  4.5 mm outlet, at 30.5 Pa at 4.09 L/min on `jar_10L`, compared with 178-209 for the slot and
  tube. `just check-clash` keeps it clear of the probes, port pins, motor, motor mount and sampler,
  both locked and at entry. The split cold finger would be the second `condenser_name`. The
  one-piece cold finger remains an option only inside its own file: nothing prints it, and it
  should not reach `head()` or `bioreactor.scad`.

## Probes

- **Plug the back of the Atlas probe bore.** The connector hex opens straight through to
  atmosphere (64 mm2). The back of the probe is a soft elastomer, so the probe body grips and seals
  it well enough on the bench. If a fix is ever needed, use hot glue at the hex rather than a
  modelled gland.

- **Optional end styles (a sensor gland) for the Atlas probes**, to match the product more closely.

## Bench

- **A rolling cart for four reactors.** `scad/support/equipment_cart.scad` models two tiers of E3030
  extrusion, two reactors per tier, on 12 3D corner brackets and four swivel plate castors:
  635 x 358 mm, and 1387 mm tall including the castors. It has no printed parts, its castor is a
  generic model with no specific part behind it, and it has not been built, so none of it is on
  the purchase list.

## Model structure

- **Split `head()` by subsystem.** It is one module with three sections (derived values, checks and
  reports, geometry). The checks cannot become a separate module without restating the derived
  values, because an OpenSCAD module returns nothing. Splitting by subsystem is the next step.
  [Architecture](architecture.md#not-yet-settled) records the open question: how the pieces share
  the parameters of head.scad without reading each other. Deferred until after the paper, because
  it changes no geometry a builder sees, and every echo transcript would catch a regression.
