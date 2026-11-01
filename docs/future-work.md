# Future work

Ideas with their reasoning, kept so nobody has to rediscover them. Nothing here is planned or
tracked. Open work before the paper is `TODO.md`; work planned for after it is a GitHub issue
labelled `post-pub`, all linked from #90. When one of these is picked up, it moves to one of those and leaves here.

## gas line

- **a water-column manometer for the sterile filter's pressure drop.** The model's 3.45 kPa per
  L/min is extrapolated from an equivalent 0.2 um PTFE disc; area-correcting Pall's Acro 50 gives
  3.02, so it sits 14 % conservative. A water manometer at 1 and 2 L/min (35 and 70 cm of column)
  tests the slope and its linearity both; not at the set flow, where 14.1 kPa is 1.44 m of water.
  The paper's runs fit the slope to a rotameter reading instead (`TODO.md`), since a builder will
  not make or buy a manometer. A differential pressure bench is a separate project.

- **a trap or a longer exhaust tube instead of an outlet filter.** It would guard against
  splashback with no pressure drop, but it is a different sterility claim from a filter.

- **what a printed sparge face costs.** `custom/sparge_puck.scad` prints one outlet face per puck;
  the bench run is `docs/build.md`'s _The sparge test pucks_.
  - a porous face is priced by one borrowed point: Pálfy et al.'s membrane carried linearly to
    4 L/min wants 15 times the open area of a 52.8 mm face, and at that size the pump would push
    about 0.28 L/min through it; the render's warning gives both. Linear is an assumption a
    three-flow reading settles
  - finer holes buy little on their own: the bubble floor goes as the cube root of the hole, and
    near an impeller hole size has a negligible effect (Rewatkar & Joshi 1993, in 0.57-1.5 m
    vessels). So a finer face is the airlift ring's question first, not the arm's
  - it closes with a measured row per face that `head()` prices in the gas line, as it does the
    filter
  - a bent steel tube sparger, made on a tube bender of about 1/8 to 2 in, is the unprinted
    alternative; keep its tube size a parameter across that range

## sparger

- **where the ring's gas goes, if a stirred build takes the ring.** No registered build does:
  `jar_10L_220x305` runs the loop, the other stirred builds the arm, and the airlift hangs DO
  straight inside its tube. Given the ring, the DO face sits 20.6 mm above its centreline and
  0.59 mm off its radius on `jar_10L`, over a ring of bubbles in the convergence zone: the one
  placement that can read wrong both ways. The flow rate is not the concern (bulk mean 16x what the
  probe needs); the gas path is not modelled, and no source found gives DO placement relative to a
  sparger. The free variables are the lean and the ring's height, both parameters already.

- **the ring's bore is the departure, not its holes, and it is more than one designation.** On
  `jar_10L` given the ring, at its 4.11 L/min, sweeping the bore with 8 x 3 mm holes held. With
  16 x 1.2 mm holes the 4.0 mm row is 5.42 m/s at an open area of 1.44, and a hole's 24 Pa
  outweighs the 17.7 Pa of velocity head, though `head()` flags the bore again; the sweep wants
  redoing at that size:

  | bore        | feed velocity | open area | velocity head | verdict                             |
  | ----------- | ------------- | --------- | ------------- | ----------------------------------- |
  | 4.0 (today) | 5.46 m/s      | 4.50      | 17.9 Pa       | 2 departures                        |
  | 8.0         | 1.36          | 1.12      | 1.1           | 1 departure; pH tip hits the ring   |
  | 8.5         | 1.21          | 1.00      | 0.9           | clean sparger; pH tip hits the ring |
  | 10.0        | 0.87          | 0.72      | 0.5           | no room for a baffle                |

  `sparge_bore()` is the riser's own OD, so the bore is a designation: `steel_tube_welded_10x0p5`
  is registered; there is no 8.5 row. What it costs is the cascade: the tube goes 6.4 -> 12.4
  across the flats, and past 8 mm the wider ring meets the pH probe's tip and then leaves no room
  for a baffle; the riser's port bore, rod gland, pressure drop, support tube and BOM row all
  follow. Unpriced.

- **`check-holes` without a CGAL render, so it can join `just check`.** Both ends of every hole
  are probed - the arm's by default, the ring's with `-D head_sparger="ring"` - and it was proved
  by injection when written (a bore swept 180 degrees failed 5 of 20 on `feed`). What would let it
  into the gate is a probe that needs no rendered mesh: the claim is geometric and the part is a
  union of primitives. `spoke_holes` is unprobed; no caller sets it and `sparger()` refuses the
  unbored-arm case.

## baffles and lid

- **the lid plates' width is the lean's to give back**, on any build that still hangs them.
  - on `jar_10L` the plate is sized to keep 1 mm running to the blades after 2.27722 mm of lean:
    3.27722 nominal, 11.9456 mm wide. The ring's 10.3454 mm bound applies only where the ring is
    built, and `jar_1gal_180` is at the lock bore's 17.0892
  - the price is area: 0.499 of Oldshue's four-at-T/12 at three plates, which gave their fourth
    port to a sampling line. The impeller alone would allow 14.5 mm (0.606), at -0.28 running in
    the worst case. The tip ring is off and stays a flag (`docs/decisions.md`)
  - the 2.28 mm lean is a worst case - bore play alone, levered 11.4x, ignoring the flange's face
    contact
  - fixes, cheapest first, costed against the old 15.3 mm plate: taper the plate's inner edge with
    depth; deepen the bayonet engagement to 36 mm (halves the lean, adds a third joint); a
    baffle-only interface row at 0.1 mm allowance (a tight bayonet twisted by hand in a jar)

- **the gasket recess holds three quarters of the rubber, which only matters on `jar_6p5gal`.**
  The recess is cut at `t(1-c)`, so `t*c` will not fit whatever the gasket. On a crown the
  displaced rubber flows into the width the contact chord never touches - on `jar_10L` 4.762 mm,
  about 0.857 mm2 against 1.890 free; on the one ground jar it must leave across the lands.
  `jar_6p5gal` also carries the registry's highest load, 1253.6 N per post and 7.34 MPa against
  398.8 and 2.92 on `jar_1gal_180`, the next highest; reported, not asserted. The fix is a groove
  section 10-25 % over the gasket's; that jar offers 10 mm of rim where the gasket is held to 6.
  Not chased: it changes the lid for one jar.

## agitation

- **a Rushton under a pitched blade: the hybrid, set aside for a standard design.** `head()` takes
  a lower and an upper type, so it is one line away: `head_impeller_upper_type = impeller_pbt_45_4`.
  Modelled on `jar_10L` at 320 rpm: 4.76 W, 0.193 N m summed, 0.5 vvm held to 147 rpm below and
  287 rpm above. The case, from when it was the plan:
  - asked which limits his microalgae cultures, the professor who recommended the Rushton answered
    light usually, CO2 supply can, O2 removal is secondary. Light is circulation, the pitched
    blade's job; CO2 is dispersion, the Rushton's
  - **the gas ceiling binds inside the operating band.** `head()` checks Oldshue's 8x rule at each
    drive speed. The cap goes as N^3: 0.70 vvm at the rated 320 rpm, 0.35 vvm at the 255 rpm
    Chlorella optimum, against the 0.5 vvm design; the crossover is about 287 rpm. A radial
    impeller at the same power, 3x not 8x, would hold about 0.94 vvm at 255 rpm
  - **circulation per watt**: about 1.8x in the pitched blade's favour at equal power and
    diameter, not the 4x `agitation.md` once claimed (`docs/decisions.md`)
  - **at equal power a Rushton is the gentler of the two**: peak dissipation goes as
    `x Po^(-1/4) D^-3`, so about 0.56x the pitched blade at the same diameter, about 1.4x at
    D = T/3. Both are orders of magnitude under any damage figure. Grenville's Figs. 6-7 have the
    Rushton making the largest drops at equal power (liquid-liquid, so indirect for gas): its gas
    advantage is holding its pattern under gas, not finer bubbles per watt
  - a Rushton as the lower impeller over the sparger arm, where the gas loads first and Oldshue
    puts 40 % of the dispersing work, the pitched blade above for circulation

- **the twisted paddle's power number, to publish the blade.** The build runs `impeller_rushton_6`;
  the twisted row stays registered with no Po any correlation reaches, and its 0.634921 width ratio
  is the one unsourced ratio in `impellers.scad`. `Po = P/(rho N^3 D^5)` from shaft power at three
  or four speeds in water settles it. Kumaresan & Joshi 2006 (doi:10.1016/j.cej.2005.10.002) is
  paywalled and may say something.

- **the annulus-sparged airlift (B).** The tube as downcomer, the annulus as riser, bubbles up the
  lit wall. It wants a sparger outside the tube, which the mouth-limited ring cannot reach, and
  Chisti & Moo-Young 1987 recommend a cone under the turn for it (`docs/references.md`).

- **fix the draft tube, if standing it proves loose.** A plain lid leaves its centre free; a
  bayonet there, as the other ports carry what hangs from them, would locate the tube from above
  rather than by the ring's clearance. Or shape each foot to capture the ring, so the ring holds the
  tube down and centred with no new part.

- **`jar_6p5gal` as a magnetic build wants larger magnets, not a deeper floor.** It stands on a
  35 mm riser and builds, coupling across the 13 mm below; it is not registered. Its punt rises
  15 mm at the magnets' radius and the carrier may not stand above the plane the jar lands on, so
  the hub cap grows 8 mm into the punt's void and the magnets reach 1 mm under the punt. Its 12 mm
  wall still puts them 13 mm from the culture, against 4-6 mm on every other jar. A 39 mm floor
  would seat a 120 x 25 at a 29 mm pitch, the best pitch of any jar, and would still be coupling
  across those 13 mm. Larger magnets are what would change it.

## condenser

- **offer the split cold finger beside the coil in `head()`.** The coil is placed: its body is
  `air_out`'s pin, the port carries no tube, and the gas line prices its 4.5 mm outlet, 30.5 Pa at
  4.09 L/min on `jar_10L`, where the slot and tube cost 178-209. `just check-clash` holds it clear
  of the probes, the port pins, the motor, the motor mount and the sampler, locked and at entry.
  The split cold finger would be the second `condenser_name`. The one-piece cold finger stays an
  option inside its own file only: nothing prints it, and it should not reach `head()` or
  `bioreactor.scad`.

## probes

- **back-plug the Atlas probe bore.** The connector hex opens straight through to atmosphere
  (64 mm2). The probe's back is a soft elastomer, so the probe body closes it by grip and seals
  itself well enough on the bench. If a fix is ever wanted it is hot glue at the hex, not a
  modelled gland.

- **optional end styles (a sensor gland) for the Atlas probes**, to match the product more
  closely.

## bench

- **a rolling cart for four reactors.** `support/equipment_cart.scad` draws two tiers of E3030
  extrusion, two reactors a tier, on 12 3D corner brackets and four swivel plate castors: 635 x
  358 mm, 1387 mm tall with its castors. It prints nothing, its castor is a generic one with no
  part behind it, and it has not been built, so nothing of it is on the purchase list.
