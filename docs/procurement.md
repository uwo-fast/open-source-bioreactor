# Procurement

## Prices

[`purchased-parts.csv`](../purchased-parts.csv) is priced so that it can be summed. `just cost`
totals it by scope and currency, and `just cost 1.3960` combines the two currencies at 1.3960 CAD
per USD. `just check` fails on any row that cannot be summed.

- `scope` - `reactor` is the reference build (the 10 L jar, shaft drive and coil condenser) with its
  electronics. `sampler` is the turbidity sampler, `bench` the e-stop box, and `tooling` the tools.
- `qty` x `price` is the cost of buying the row. `qty` counts purchase units, and `unit` says what
  one unit is (`pack of 50`, `2 m length`). `need` is how many the build uses; a pack usually
  contains more.
- `currency` is the vendor's currency. Prices are never converted in the file.
- `price_confidence` gives the source of the price:
  - `read` - read from the vendor's listing on `price_date`
  - `representative` - one listing that meets a spec given by standard rather than by part number
  - `cited` - from a publication named in the row
  - `estimate` - an estimate, with its basis in the row
  - `listed` - carried over from before dates were recorded
  - `none` - not priced yet

The Slice boards are priced from their papers, not from their bills of materials, which belong to
their own repositories.

## Selection

### Bearing

- McMaster-Carr 6153K71, <https://www.mcmaster.com/6153K71/>
- shaft: 8mm; seal type: sealed; bearing type: ball; construction: single row; lubricant: grease;
  ball material: stainless steel
- trade no. 608-2RS: 22.000 mm OD (-0.008/0), 7.00 mm wide (-0.12/0), 8.000 mm bore (-0.007/0),
  checked with calipers against the drawing. It is registered as NopSCADlib's BB608, which has the
  same three dimensions, so the pocket is cut from the part itself and not from a copy of it.
- **Shaft Mount Type: Press Fit** is what McMaster specify, so heating the race and chilling the
  shaft is the intended assembly method, not a workaround for a wrong fit. Radial clearance is
  0.002-0.013 mm (MC3), and a press fit expands the inner ring and reduces that clearance. At the
  tightest end of the tolerance stack (an 8.000 mm shaft in a 7.993 mm bore), roughly 0.006 mm of
  the clearance is lost, which leaves the bearing very slightly preloaded. At 320-420 rpm, against
  a 34,000 rpm rating and 590 lb dynamic capacity, this adds a little friction but does not affect
  bearing life. It is also why the joint feels tight on assembly.
- **Materials caution: 440C is not bleach-resistant.** McMaster's note says these bearings "will
  weaken when exposed to salt water and harsh chemicals, such as bleach". The seals are Buna-N,
  which also has poor resistance to oxidisers. This reactor cannot be autoclaved, so it is
  chemically sterilised. Everything except the pH and DO probes is sterilised with 7.5 % hydrogen
  peroxide. The probes are cleaned by hand (sometimes with IPA), and bleach or chlorite is only ever
  used on the glass vessel. The shaft is 316 stainless for this reason, and the bearing is the
  weaker of the two. The bearing sits in a blind pocket in the lid rather than submerged, so it is
  exposed to vapour and splash rather than to the culture. A peroxide soak or flush would still
  reach it, and so would bleach if the lid ever went through the bleach step used for the vessel. How 440C and
  Buna-N withstand repeated exposure to 7.5 % peroxide is not recorded. If it becomes a problem, the
  usual solution is a full-ceramic bearing or one with plastic races.
- Temperature range -40 to 240 F, i.e. up to 116 C. This is a **third** independent reason the
  assembly cannot be autoclaved, alongside the soda-lime jar and the ~80 C glass transition of PETG.

### Impeller set screws

- McMaster-Carr 92029A142, <https://www.mcmaster.com/92029A142/>
- 316 stainless cup-tip set screw, M4 x 0.7 x 6 mm, 2 mm hex socket, Rockwell B80, pack of 50
- Eight are needed. Each Rushton prints as two halves, and each half takes two screws in its own
  hub, 120 degrees apart, between the blades. An impeller printed in one piece takes two screws in a
  collar above the blades, where no blade stands at any angle on any registered impeller type.
- The collar exists because a screw in the hub fouled a fin. At the hub surface the fins occupy
  58.0-86.3 deg and every 90 deg after that, while a 3.3 mm hole at 10 mm radius spans 19 deg. The
  screw therefore cut into the fin root, where bending stress is highest, and put a blade in front
  of the socket where a hex key could not reach it.
- Indexing the screws into the gaps between fins was rejected. Each fin is `resize()`d, which
  scales its y by 1.107 relative to its x, and the twist moves it again, so no single angle works
  for every type.
- **The screws are the whole joint.** The hub bore is a straight 8.4 mm on a shaft supplied at
  7.995-8.000 (`impeller_shaft_draft` is 0), which is a slip fit.
- An interference fit was rejected. On paper, 0.02 mm of radial interference gives 8 N-m against
  the 0.034 N-m one impeller needs. However, 8 MPa of sustained hoop stress in wet PETG at 30-37 C
  for weeks will creep and relax. A printed 8 mm bore is not repeatable to 0.02 mm. A fit tight
  enough to hold also cannot be taken apart for cleaning or to swap impeller types, which is the
  purpose of the typed registry.
- **Cup tip, not flat or cone.** The tip has to bite into the shaft, which at Rockwell B83 is soft
  enough to take a dimple. A cone tip would need a matching feature on the shaft and would fix the
  impeller height to it. A cup tip makes its own dimple and lets the impeller sit anywhere on the
  shaft.
- **316 rather than 18-8.** These screws are wetted, and the reactor is chemically sterilised rather
  than autoclaved. The heat-set inserts in the lid are 18-8, but they stay dry. A wetted 18-8 insert
  would repeat the problem recorded for the 440C bearing above. Tapping the PETG directly keeps every
  wetted metal part 316.
- **No thread is modelled.** The hole is printed at the 3.3 mm tap size and the screw cuts its own
  thread. M4 x 0.7 has 0.43 mm of thread depth, about one perimeter, and a 0.7 mm pitch is 3.5
  layers at 0.2 mm. A modelled thread would print as a staircase and give the screw a ramp to ride
  on rather than material to engage. Self-tapping displaces and compacts the material instead.
  Printed holes come out 0.1-0.3 mm undersize, so a 3.3 mm modelled hole prints close to the
  3.242 mm minor diameter.
- The hub radius is 10 mm. This leaves 5.8 mm of thread between the socket and the shaft, and a
  6 mm screw reaches the shaft surface when it sits flush. Two screws carry 1458 N, against the
  817 N that the rated motor torque applies to one impeller and 1225 N at stall.
- Also registered, but not purchased: **92029A144** (M4 x 8) for a 12 mm hub radius, and
  **92029A103** (M3 x 6) as the fallback if M4 cannot be tapped. M3 is not safer for being smaller.
  Thread shear area scales with circumference, so M3 needs 8.7 mm of engagement to carry what M4
  carries in 6.5 mm.

### Gas metering

Sized by calculation from the pump specification and the vessel geometry, not by a flow test.

- **The two pump figures are not simultaneous.** The ReSun is rated at ~65-70 L/min and
  ~0.027 MPa. Delivering both at once would be 30.4 W of pneumatic power from a 35 W input, or 87 %
  efficiency, which is impossible for a diaphragm pump. The two figures are the ends of its curve:
  free flow of ~67 L/min at zero back-pressure, and a dead-head pressure of 27 kPa at zero flow.
- Assuming a linear curve between those points, and taking the static back-pressure of the system
  as the culture head over the sparge ring plus the capillary pressure at a hole, the operating
  point is:

  | vessel             | culture  | 0.5 vvm        |
  | ------------------ | -------- | -------------- |
  | jar_1p5L_112x215   | 1.45 L   | 0.73 L/min     |
  | jar_1gal_155x251   | 3.35     | 1.67           |
  | jar_1gal_180x197   | 3.54     | 1.77           |
  | jar_10L_220x305    | **8.17** | **4.09 L/min** |
  | jar_6p5gal_305x470 | 20.42    | 10.21          |

  The volumes are integrated over the wetted profile of each jar. The head over the ring and the
  pump delivery depend on the whole line, which is computed only for the vessel being built.
  `head()` echoes both at render.

- **The pump is not the constraint.** Against the whole line it settles at **5.79 L/min**, where
  4.09 is needed. It does not reach the **21.0** that a back-pressure fixed at the design point
  would suggest, because the filter drop is linear in flow and a higher flow raises the line
  pressure. `head()` echoes the 5.79 figure and says so.
- **The line, not the vessel, sets the pressure budget.** The sterile filter drops **14.1 kPa**,
  nearly seven times the vessel, and the check valve another **1.9**, of which 1.2 is its cracking
  pressure. The line totals **18.3 kPa** and leaves **7.0** for the valve to drop, so the valve
  needs a Cv of **0.0349**.
- **Nothing filters the exhaust, and a second inlet filter would not work there.** A bioreactor
  normally filters both the incoming _and_ outgoing air. This one vents the headspace through the
  coil condenser into the room. An outlet filter is not between the pump and the sparge holes, but
  it raises the headspace pressure that the holes discharge into, and the gas has to overcome that
  too. A second identical filter adds its 14.1 kPa and brings the line to **32.4 kPa** at
  4.09 L/min, against a pump that dead-heads at 27. The reactor would settle at **3.14 L/min**, and
  could no longer hold 0.5 vvm. `head()` reports the budget: an outlet filter may cost at most
  **1.719 kPa per L/min**, 0.498 of the inlet filter, so it needs roughly **twice the membrane
  area** rather than a second `1594522`. The coil condenser outlet is already included in the line,
  so the budget is net of it. The slope of the inlet filter is extrapolated rather than measured,
  and the budget changes with it.
- **Range: a rotameter reads 10-100 % of full scale**, so for 0.1-0.5 vvm:

  | vessel             | needs           | scale         |
  | ------------------ | --------------- | ------------- |
  | jar_1p5L_112x215   | 0.15-0.73 L/min | 0-1 L/min     |
  | jar_1gal (both)    | 0.33-1.77       | 0-2 L/min     |
  | jar_10L_220x305    | 0.82-4.09       | **0-5 L/min** |
  | jar_6p5gal_305x470 | 2.04-10.21      | 0-15 L/min    |

- **Buy 0-5 L/min for the 10 L jar**, where 0.82-4.09 falls at 16.3-81.7 % of scale. No single
  range covers every jar. This follows from the 70:1 spread between the smallest jar at 0.1 vvm and
  the largest at 0.5, not from a poor choice of meter.
- Enriching with CO2 later does not invalidate the meter. A rotameter reading depends on gas
  density, and 0.5 % CO2 in air changes the density by 0.26 %.
- The parts are listed in [`purchased-parts.csv`](../purchased-parts.csv): a Dwyer `VFA-23` bare
  meter, a Clippard `MNV-3KP` needle valve dropping **7.0 kPa** at 4.09 L/min, and a Cole-Parmer
  `5011521` check valve against the 1.0-1.9 kPa of culture head over the ring.
- The valve is the 3 deg needle `MNV-3KP` rather than the 20 deg `MNV-4K2`. Both have a Cv of
  0.094, so both operate at about 37 % of travel. The difference is that the `MNV-3KP` needs roughly
  seven times the rotation for the same change in flow. Because the pump is seven times oversized,
  the whole operating band falls in the first part of that travel.
- The meter is the BARE `VFA-23`, not the `-BV` version with an integral valve. Dwyer do not
  publish the Cv of the integral valve. Unstated specs are what ruled out the medical and welding
  flowmeters here, so choosing a part with unstated specs for the metering row would have been
  inconsistent with how every other part was selected.
- **Rejected candidates, and why.**
  - _Flowmeter, 13 candidates._ The deciding factors were **scale unit and calibration pressure**,
    not range or price. Five McMaster tubes read in **scfh**, which would add a conversion to every
    reading in the paper. Medical flowmeters are calibrated at **50 psig** and welding flowmeters at
    **30**, so both would read about **87 % wrong** at the pressure in this line. They were ruled
    out on calibration, not cost. Cole-Parmer have no 5 L/min model, and their nearest tube is
    8.5 L/min full scale. That gives **+/-10.4 %** at the design point, against +/-6.1 % for the
    Dwyer, at 69 % higher cost. A glass LZB-4WB was the cheapest, but its listing quotes "2.5 %,
    4 %, 6 %" across the series without saying which applies to that model.
  - _Check valve, 13 candidates._ The deciding factor was the **pressure drop while flowing at
    4.087 L/min**, which no spec sheet gives; every listing quotes only the static cracking
    pressure. Computing it from the published Cv changes the ranking. An Air Logic umbrella valve
    with the same nominal cracking pressure drops about **0.9 kPa more**, because its flow capacity
    is a quarter as large. The nylon/silicone variant `5011519` was rejected on material, because
    nylon is hygroscopic and swells in continuously humid air. `5011521` was chosen over US Plastic
    `22577` **for procurement reasons, not performance**. The two calculate at 1.85 and 1.78 kPa
    (`head()` puts this valve at 1.93 in the line), a difference within the error on the filter
    figure that dominates the budget. `5011521` also comes from the same supplier as the sterile
    filter, so both arrive in one shipment with one customs clearance.
  - _Metering valve._ Against the required Cv of 0.0349, the `MNV-2` (Cv 0.032) runs out of
    valve authority, and an Ideal Valve 52-1-12 (Cv 0.019) **cannot reach the design flow at
    all**. The `MNV-4K2` meets the Cv requirement but was rejected because of its **needle**:
    Clippard's catalogue gives it a 20 deg taper, coarser than the `MNV-1`, which had already been
    rejected as too coarse.

### Hose clamps

- McMaster-Carr 5011T141, <https://www.mcmaster.com/5011T141/>
- worm-drive hose clamp, 316 stainless band **and** screw, 5/16 in band x 0.023 in, SAE J1508
- SAE 4: 7/32 in to 5/8 in, i.e. **5.556 to 15.875 mm**; 1/4 in hex, 7.5 in.-lbs maximum torque
- 17 are needed (14 on the gas line and 3 on the dosing stubs). They are sold in packs of ten, so
  buy 2 packs, at US$19.82 a pack.
- **The band width sets the riser height.** The clamp is registered in
  `scad/purchased/hose_clamps.scad`, and `sparge_riser_proud` is derived from its **7.9375 mm**
  band plus 3.5 mm of lead-in on each side: **14.9375 mm**. The 5/16 in band is the narrowest that
  McMaster offer for this clamp. The 1/2 in band is 12.7 mm and would leave only 2.3 mm of lead-in
  in total.
- **One size covers the whole line**, as a consequence of the band width. The smallest size with
  the 5/16 in band is SAE 4, at 5.556-15.875 mm, and the next size up starts at 11 mm. The gas line
  uses four tube bores (3/8, 1/4 and 1/8 in PVC, and 3/16 in silicone), and SAE 4 covers all
  fourteen joints with one part number.
- The outside diameters of those tubes depend on the WALL thickness, which is separate from the
  bore and not fixed for a commodity tube. With a 1/16 in wall they are 12.70, 9.53, 6.35 and
  7.94 mm, and every one is within the clamp range; the 1/8 in joints are near the bottom of it but
  still engaged. The joint that can fall outside the range is the _largest_. A 3/8 in tube with a
  1/8 in wall is 9.525 + 2 x 3.175 = **15.875 mm**, and the upper limit of SAE 4 is 5/8 in, which
  is also **15.875 mm**: the clamp would be wound out to its last thread. So
  [`purchased-parts.csv`](../purchased-parts.csv) specifies that tube with a 1/16 or 3/32 in wall
  (12.70 or 14.29 mm OD), rather than adding an SAE 6 clamp for one joint.
- **316 rather than the three cheaper versions of the same clamp.** McMaster sell it with a 301
  band and a zinc-plated, 410, 305 or 316 screw. The plated screw should be rejected outright: the
  band survives, but the screw rusts and seizes, and the riser clamp sits in a permanently humid
  headspace. Of the rest, only 410 keeps the 10 in.-lbs rating; **305 and 316 are both derated to
  7.5**, so 316 loses no torque relative to 305 and costs only $4.46 more a pack. This reactor is
  chemically sterilised rather than autoclaved, and already has one recorded chloride
  vulnerability, the 440C bearing above. 316 is the grade that avoids reopening that issue.
- **7.5 in.-lbs is a galling limit, not a strength limit**, because the screw and housing are both
  austenitic. These clamps are opened at every filter change, so tighten them snugly with the 1/4 in
  nut driver and never with a wrench. Nothing here needs the torque: the clamps close soft tubing
  over rigid barbs, and the tightest has 0.76 mm of slack, on the riser.
- This follows the rule set for the impeller set screws: wetted parts are 316, dry parts are 18-8.
  Strictly these clamps are dry, which would allow 305, and 305 would be a defensible choice. The
  deciding point is that one clamp size serves every joint, so the whole line gets whichever grade
  is bought, including the four on the sterile side and the one at the lid.

### Thermocouple

- McMaster-Carr 1245N31, <https://www.mcmaster.com/1245N31/>
- Type K threaded thermocouple probe for liquids and gases
- 1/2 NPT male fitting, wire leads
- 6 in long x 1/8 in diameter grounded 304 stainless probe
- 4 ft fiberglass cable, 24 AWG, 1/2 in wire leads
- 0.5 s response time, 900 F maximum temperature
- Both the 6 in and the 9 in probes are registered in `purchased/thermocouple_probes.scad`.
  `head()` selects the 6 in, because the 9 in would reach through the floor of `jar_1gal_180x197`.

### Motor mount inserts

- McMaster-Carr 97163A152, <https://www.mcmaster.com/97163A152/>
- 18-8 stainless tapered heat-set insert for plastic, ASTM A380
- M4 x 0.7 mm, 4.7 mm installed length, knurled, open end
- 2 Ga drill (5.613 mm), 5.740 mm maximum hole, 8 deg taper on the top half
- 5.72 mm minimum material thickness; the lid is 18 mm thick
- 4 per lid, sold in packs of 10
- The brass 94180A351 (<https://www.mcmaster.com/94180A351/>) is the same part in brass. It
  installs more easily, because brass conducts heat into the plastic much better than stainless
  does. It was not chosen here for three reasons: this face is exposed to condensation, splash and
  wipe-downs; the brass part is not REACH compliant and relies on a RoHS 6(c) lead exemption; and,
  sold in packs of 100 rather than 10, it costs more for a single lid. Worth reconsidering for a
  batch build.

### Rim gasket sheet

- McMaster-Carr 8525T65, <https://www.mcmaster.com/8525T65/>
- water- and steam-resistant EPDM, plain backing, black, ASTM D2000
- 1/16 in thick (1.5875 mm), 12 in x 12 in sheet
- Durometer 60A, 800 psi maximum, -20 to 220 F
- The lid gasket is cut to 142.2 x 158.2 mm, so one sheet yields ONE gasket. Two 158.2 mm outside
  diameters do not fit side by side on a 304.8 mm sheet.
- The hardness, not only the material, sets the number of bolts in the joint. Below 75A the ASME
  VIII-1 gasket factor m is 0.5 and the lid takes 12 posts; at 75A or above, m is 1.0 and the lid
  takes 16. `head_gasket_factor()` derives this from the registered row, so buying a harder sheet
  changes the printed lid rather than silently under-bolting the joint.
- It is cut BY HAND with a scalpel, using a printed **two-stage** template
  (`scad/custom/gasket_cutter.scad`). One template cannot guide both cuts. A template shaped like
  the gasket would be a 3 mm wall at the ring diameter, too flexible in its own plane to guide a
  blade, and stiffening it would need material exactly where the blade goes. So the OUTER cut is
  made against a plain disc, with nothing outside it to obstruct the blade. The blank then drops
  into a counterbore under the INNER plate, which holds it concentric while the plate bore guides
  the second cut. Concentricity comes from a printed counterbore rather than the operator's hand,
  and both parts print flat with no bridges and no supports.
- The radial perimeter does not have to be accurate, because the gasket seals on its AXIAL faces. That is
  why a template and a scalpel are enough and no die is bought. The fixture takes the same
  `(ID, OD, thickness)` parameters as `sheet_gasket()` and needs nothing else from the jar.

### Drive motor

- **E-S Motor 36D gearmotor with encoder, RobotShop SKU RM-ESMO-071, mfr 36PG-555PM-14-EN 12V**,
  <https://ca.robotshop.com/products/e-s-motor-36d-dc-planetary-gearmotor-w-encoder-12v-420rpm>
- 12 V DC, gear ratio 1/14, **no-load 420 rpm, rated 320 rpm** at 5 kg-cm (0.490 N-m), rated
  current < 2 A, no-load current 400 mA, stall > 15 kg-cm / < 10 A, 30 W maximum
- motor 36 x 57 mm, gearbox 36 x 34.5 mm, shaft 8 x 20 mm D-shaped with 15 mm of flat at 7 mm
- faceplate 4-M4 tapped 5 mm deep on a 28 mm bolt circle, 22 mm pilot register standing 2 mm proud
- The encoder is magnetic, 2 channels, 12 PPR at the motor shaft. Through the 14:1 gearbox that is
  672 quadrature counts per output revolution, which resolves about 0.9 rpm over a 100 ms window,
  against an operating band 155 rpm wide.
- Six flying leads (motor M1/M2, Hall GND, Hall A, Hall B, Hall Vcc) and no connector, unlike the
  3429 SKUs, which ship with an SM2P-2.54 connector on 90 mm cables.
- Chosen because its 320-420 rpm range covered the whole speed band of the 94.5 mm pitched pair.
  It was the only candidate that reached the 410 rpm break-even of that band, and its encoder gives
  speed feedback for the drive. With the 70 mm turbine it brackets the 344 rpm optimum but cannot
  reach the 554 rpm break-even ([Agitation](agitation.md#the-operating-point)).
- **Two figures here are inferred, not published.** The encoder version's datasheet gives no
  gearbox length, so 34.5 mm is the figure from the 36PG-3429 datasheet at 14:1. Its drawing gives
  57 mm for the whole motor block without dimensioning the encoder separately, and 57 mm is also
  the length of the plain 555 motor without an encoder. Both figures affect the reactor envelope and
  therefore the cart, where each millimetre counts twice across two tiers. Confirm them with the
  vendor before ordering.
- Rejected **RM-ESMO-16Q** (36PG-3429-5.2): its rated 950 rpm gives 3.48 m/s at the tip of the
  70 mm turbine, 1.7 times the break-even. It is the right family with the wrong ratio. It is still
  registered as a product.
- Not chosen: **RM-ESMO-16N** (36PG-3429-19, 42.15 CAD), no-load 385 / rated 265 rpm at
  2.4 kg-cm. Both speeds are inside the band of the pitched pair, and it is 27.6 mm shorter in the
  stack. However, it cannot reach the 554 rpm break-even and has no encoder. It is the fallback if
  stack height turns out to be a constraint.
- Not chosen: **RM-ESMO-0MX** (36PG-555K-1260-19, 34.50 CAD), no-load 315 / rated 240 rpm at
  7 kg-cm. Its rated speed is below the growth optimum, and its main advantage, torque, is of no use
  here: the impeller pair needs under 5 % of it. Bare copper tabs, no connector.
- The motor on the bench is a discontinued **36GP-3530** (12 V, "1154 RPM"). The listing does not
  say what the 1154 refers to, so it is registered as a no-load speed. No rated speed is published
  for it.
  <https://electric-b2c.com/products/36gp-3530-planetary-gear-dc-motor-torque-50kg-12v-24v-reduce-speed-8pm-to-1154rpm-pwm-reverse-forward-electric-12-volt-motor?variant=47572164116673>

### 36PG gearbox family

- The whole range shares one faceplate: 4 screws on a **28 mm bolt circle**, a 22 mm pilot register
  standing **2 mm** proud, and an 8 x 20 mm D-cut output shaft. The 3429 and 555K are tapped M3,
  and the 555PM-EN M4. This lets one printed mount fit the whole range.
- Rated speed is 0.68-0.71 of no-load speed across all ten ratios. A catalogue speed with no
  qualifier is therefore a no-load speed, and the operating speed is roughly 0.7 of it. This is why
  the registry keeps the two separate. The ratio tables are in `scad/purchased/gearboxes.scad`.
