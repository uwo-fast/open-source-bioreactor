# Procurement

## Prices

[`purchased-parts.csv`](../purchased-parts.csv) is priced so it can be summed: `just cost` totals it
by scope and currency, and `just cost 1.3960` folds the two currencies together at that many CAD per
USD. `just check` fails on a row that cannot be summed.

- `scope` — `reactor` is the reference build (the 10 L jar, shaft drive, coil condenser) with its
  electronics; `sampler` is the turbidity sampler, `bench` the e-stop box, `tooling` the tools.
- `qty` × `price` is what buying the row costs. `qty` counts purchase units and `unit` says what one
  is (`pack of 50`, `2 m length`); `need` is how many the build uses, which a pack usually exceeds.
- `currency` is the vendor's own, never converted in the file.
- `price_confidence` says where the number came from: `read` off the vendor's listing on
  `price_date`; `representative`, one listing that meets a spec given by standard rather than part
  number; `cited` from a publication the row names; `estimate`, with its basis in the row;
  `listed`, carried from before dates were recorded; `none`, not priced yet.

The Slice boards are priced from their papers, not from their bills of materials: those belong to
their own repositories.

## Selection

### Bearing

- McMaster-Carr 6153K71, <https://www.mcmaster.com/6153K71/>
- shaft: 8mm; seal type: sealed; bearing type: ball; construction: single row; lubricant: grease;
  ball material: stainless steel
- trade no. 608-2RS: 22.000 mm OD (-0.008/0), 7.00 mm wide (-0.12/0), 8.000 mm bore (-0.007/0),
  caliper-confirmed against the drawing. Registered as NopSCADlib's BB608, which carries those
  same three numbers, so the pocket is cut from the part and not from a copy of it
- **Shaft Mount Type: Press Fit** is what McMaster specify, so heating the race and chilling the
  shaft is the intended method rather than a workaround for a wrong fit. Radial clearance is
  0.002-0.013 mm (MC3), and a press fit expands the inner ring and eats into that: at the
  tightest end of the stack - a 8.000 mm shaft in a 7.993 mm bore - roughly 0.006 mm of the
  clearance goes, which leaves the bearing very slightly preloaded. At 320-420 rpm against a
  34,000 rpm rating and 590 lb dynamic capacity that is a little friction, not a life problem,
  and it is why the joint feels tight on assembly.
- **Materials caution: 440C is not bleach-resistant.** McMaster's own note says these bearings
  "will weaken when exposed to salt water and harsh chemicals, such as bleach", and the seals are
  Buna-N, which is likewise poor against oxidisers. This reactor cannot be autoclaved, so it is
  chemically sterilised - 7.5 % hydrogen peroxide for everything but the pH and DO probes, which
  are cleaned by hand (sometimes with IPA), and bleach or chlorite only ever on the glass vessel -
  and the shaft is 316 for exactly that reason. The bearing is the weaker half of that pair. It
  sits in a blind pocket in the lid rather than submerged, so it meets vapour and splash rather
  than the culture, but a soak or a flood-through of peroxide would reach it, and so would bleach
  if the lid ever went through the vessel's step. How 440C and Buna-N stand repeated 7.5 %
  peroxide is not recorded; a full-ceramic or plastic-raced bearing is the usual answer if it
  becomes a problem.
- Temperature range -40 to 240 F, i.e. up to 116 C - a **third** independent reason this assembly
  cannot be autoclaved, alongside the soda-lime jar and PETG's ~80 C glass transition.

### Impeller set screws

- McMaster-Carr 92029A142, <https://www.mcmaster.com/92029A142/>
- 316 stainless cup-tip set screw, M4 x 0.7 x 6 mm, 2 mm hex socket, Rockwell B80, pack of 50
- eight needed: each Rushton prints as two halves, and each half takes two in its own hub, 120
  degrees apart between the blades; an impeller printed whole takes two in a collar above the
  blades, where no blade stands at any angle on any registered impeller type
- **the screws are the whole joint.** The hub bore is a straight 8.4 mm on a shaft supplied at
  7.995-8.000 (`impeller_shaft_draft` is 0), which is a slip fit
- an interference fit was rejected. On paper 0.02 mm radial gives 8 N-m against the 0.034 N-m one
  impeller asks, but 8 MPa of sustained hoop stress in PETG at 30-37 C, wet, for weeks will creep
  and relax; a printed 8 mm bore is not repeatable to 0.02 mm; and a fit tight enough to hold
  cannot be taken apart for cleaning or to swap impeller types, which is the point of the typed
  registry
- **cup tip, not flat or cone.** The tip has to bite the shaft, which at Rockwell B83 is soft
  enough to take a dimple. A cone tip would need a matching feature and would fix the impeller's
  height to it; a cup tip makes its own and lets the impeller sit anywhere on the shaft
- **316 rather than 18-8.** These are wetted, and the reactor is chemically sterilised rather
  than autoclaved. The lid's heat-set inserts are 18-8, but those stay dry - a wetted 18-8 insert
  would repeat the conflict recorded against the 440C bearing above. Tapping the PETG directly
  keeps every wetted metal at 316
- **no thread is modelled.** The hole is printed at the 3.3 mm tap size and the screw cuts its
  own. M4 x 0.7 has 0.43 mm of thread depth, about one perimeter, and 0.7 mm of pitch is 3.5
  layers at 0.2 mm, so a modelled thread prints as a staircase and gives the screw a ramp to ride
  rather than material to engage. Self-tapping displaces and compacts instead. Printed holes come
  out 0.1-0.3 mm undersize, so a modelled 3.3 lands near the 3.242 mm minor diameter as printed
- the hub is 10 mm in radius: 5.8 mm of thread stands between socket and shaft, and a 6 mm screw
  arrives at the shaft surface sitting flush. Two of them carry 1458 N against the 817 N the
  motor's rated torque asks of one impeller, and against 1225 N at stall
- also registered, not bought: **92029A144** (M4 x 8) for a 12 mm hub radius, and **92029A103**
  (M3 x 6) as the fallback if M4 cannot be tapped. M3 is not the safer choice for being smaller -
  thread shear area goes with circumference, so it needs 8.7 mm of engagement to carry what the
  M4 carries in 6.5

### Gas metering

Sized by calculation from the pump's own specification and the vessel geometry, not by a flow test.

- **the pump's two numbers are not simultaneous.** The ReSun is quoted at ~65-70 L/min and
  ~0.027 MPa; delivering both at once is 30.4 W of pneumatic power against a 35 W input, which
  would be 87 % efficient and is impossible for a diaphragm pump. They are the ends of its curve:
  free flow ~67 L/min at zero back-pressure, dead-head 27 kPa at zero flow
- taking the curve as linear between them and the system's static back-pressure as the culture
  head over the sparge ring plus the capillary pressure at a hole, the operating point is:

  | vessel             | culture  | 0.5 vvm        |
  | ------------------ | -------- | -------------- |
  | jar_1p5L_112x215   | 1.45 L   | 0.73 L/min     |
  | jar_1gal_155x251   | 3.35     | 1.67           |
  | jar_1gal_180x197   | 3.54     | 1.77           |
  | jar_10L_220x305    | **8.17** | **4.09 L/min** |
  | jar_6p5gal_305x470 | 20.42    | 10.21          |

  The volumes are integrated over each jar's own wetted profile. The head over the ring and what
  the pump delivers depend on the whole line, which is computed only for the vessel being built;
  `head()` echoes them at render.

- **the pump is not the constraint.** Against the whole line it settles at **5.79 L/min** where
  4.09 is wanted - not the **21.0** that a back pressure held at the design point suggests, since
  the filter is linear in flow and asking for more raises the line; `head()` echoes the 5.79 and
  says so
- **the line, not the vessel, sets the budget.** The sterile filter drops **14.1 kPa**, nearly seven
  times the vessel, and the check valve another **1.9**, of which 1.2 is just cracking it open. The
  line comes to **18.3 kPa** and leaves the valve **7.0** to drop, so it needs a Cv of **0.0349**
- **nothing filters the way out, and a second inlet filter will not do it.** A bioreactor normally
  filters the air in _and_ out; this one vents the headspace through the coil condenser into the
  room. An outlet filter does not sit between the pump and the sparge holes, but it raises the
  headspace those holes discharge into, and the gas has to beat that too. `head()` reports the
  budget: an outlet filter may cost at most **1.719 kPa per L/min**, 0.498 of what the inlet one
  costs, so it wants roughly **twice the membrane area** rather than a second `1594522`. The coil
  condenser's outlet is already priced into the line, so that budget is net of it. The inlet
  filter's own slope is extrapolated rather than measured, and the budget moves with it
- **range: a rotameter reads 10-100 % of full scale**, so for 0.1-0.5 vvm:

  | vessel             | needs           | scale         |
  | ------------------ | --------------- | ------------- |
  | jar_1p5L_112x215   | 0.15-0.73 L/min | 0-1 L/min     |
  | jar*1gal*×2        | 0.33-1.77       | 0-2 L/min     |
  | jar_10L_220x305    | 0.82-4.09       | **0-5 L/min** |
  | jar_6p5gal_305x470 | 2.04-10.21      | 0-15 L/min    |

- **buy 0-5 L/min for the 10 L jar**, where 0.82-4.09 sits at 16.3-81.7 % of scale. No single range
  covers the family — that is a property of a 70:1 spread between the smallest jar at 0.1 vvm and
  the largest at 0.5, not a bad choice.
- enriching with CO₂ later does not invalidate the meter. A rotameter reads by gas density, and
  0.5 % CO₂ in air changes density by 0.26 %
- the chain is in [`purchased-parts.csv`](../purchased-parts.csv): Dwyer `VFA-23` bare meter, Clippard `MNV-3KP` needle
  valve dropping **7.0 kPa** at 4.09 L/min, Cole-Parmer `5011521` check valve against the 1.0-1.9
  kPa of culture head that sits over the ring
- the valve is the 3° needle `MNV-3KP` rather than the 20° `MNV-4K2`. Both are Cv 0.094, so both
  sit at about 37 % of travel; what differs is roughly seven times the rotation for the same
  change in flow, and the pump being seven times oversized puts the whole band in the first part
  of that travel
- the meter is the BARE `VFA-23`, not the valved `-BV`. Dwyer do not publish the integral valve's
  Cv, and unstated specs are what disqualified the medical and welding flowmeter channels here -
  closing the metering row on one would have been inconsistent with how everything else was picked
- **what was rejected, and on what.**
  - _Flowmeter, 13 candidates._ The discriminator was **scale unit and calibration pressure**,
    not range or price. Five McMaster tubes read **scfh**, which puts a conversion on every
    reading in the paper. The medical channel is referenced at **50 psig** and the welding
    channel at **30**, so both would read about **87 % wrong** at this line's pressure — ruled
    out on calibration basis rather than cost. Cole-Parmer have no 5 L/min rung and their
    nearest tube is 8.5 L/min full scale, which costs **±10.4 %** at the design point against
    the Dwyer's ±6.1 %, for 69 % more money. A glass LZB-4WB was cheapest but its listing quotes
    "2.5 %, 4 %, 6 %" across the series without saying which applies to that model.
  - _Check valve, 13 candidates._ The discriminator was the **flowing drop at 4.087 L/min**,
    which no spec sheet carries — every page quotes only static cracking pressure. Computing it
    from published Cv reorders the field: an Air Logic umbrella at the same nominal cracking
    pressure costs about **0.9 kPa more**, because its flow capacity is a quarter. The
    nylon/silicone sibling `5011519` was rejected on material — nylon is hygroscopic and swells
    in continuously humid air. `5011521` beat US Plastic `22577` **on procurement, not physics**:
    1.85 against 1.78 kPa by that arithmetic (`head()` puts this valve at 1.93 in the line) is
    inside the error on the filter figure that dominates the budget, and it shares a supplier with
    the sterile filter, so one shipment and one customs clearance.
  - _Metering valve._ Against the required Cv of 0.0349, `MNV-2` (Cv 0.032) runs out of authority
    and an Ideal Valve 52-1-12 (Cv 0.019) **cannot reach the design flow at all**. `MNV-4K2`
    meets the Cv and was rejected on the **needle**: Clippard's catalogue gives it a 20° taper,
    coarser than the `MNV-1` already rejected for being coarse.

### Hose clamps

- McMaster-Carr 5011T141, <https://www.mcmaster.com/5011T141/>
- worm-drive hose clamp, 316 stainless band **and** screw, 5/16 in band × 0.023 in, SAE J1508
- SAE 4: 7/32 in to 5/8 in, i.e. **5.556 to 15.875 mm**; 1/4 in hex, 7.5 in.-lbs maximum torque
- 17 needed - 14 on the gas line and 3 on the dosing stubs - sold in tens, so 2 packs; US$19.82 a
  pack
- **the band width sets the riser.** The clamp is registered in `scad/purchased/hose_clamps.scad`
  and `sparge_riser_proud` derives from its **7.9375 mm** band plus 3.5 mm of lead-in either side:
  **14.9375 mm**. The 5/16 in band is the narrowest McMaster offer this clamp in; the 1/2 in band
  is 12.7 mm and would leave 2.3 mm of lead-in in total
- **one size covers the whole line**, which the width decides for it: the 5/16 in band's smallest
  size is the SAE 4 at 5.556-15.875 mm and the next size up starts at 11 mm. Against the gas
  line's four bores — 3/8, 1/4, 1/8 in PVC and 3/16 in silicone — the SAE 4 takes all fourteen
  joints on one part number
- those outside diameters follow the WALL, which is not the bore and is not pinned for a commodity
  tube. At 1/16 in wall they are 12.70, 9.53, 6.35 and 7.94 mm and every one is inside the range,
  the 1/8 in joints near the bottom of it but engaged. The joint that can leave the range is the
  _largest_: 3/8 in line in a 1/8 in wall is 9.525 + 2 × 3.175 = **15.875 mm**, and the SAE 4's
  upper limit is 5/8 in, which is **15.875 mm** - the same number twice, on a clamp wound out to
  its last thread. So [`purchased-parts.csv`](../purchased-parts.csv) specifies that run in 1/16 or 3/32 in wall, 12.70 or
  14.29 mm, rather than adding an SAE 6 for one joint
- **316 rather than the three cheaper builds of the same clamp.** McMaster sell it as 301 band
  with a zinc-plated, 410, 305 or 316 screw. The plated screw is the one to reject outright — the
  band survives and the screw rusts and seizes, and the riser clamp sits in a permanently humid
  headspace. Of the rest, 410 alone keeps the 10 in.-lbs rating; **305 and 316 are both derated to
  7.5**, so 316 costs nothing in torque against 305 and only $4.46 a pack. This reactor is
  chemically sterilised rather than autoclaved and already carries one recorded chloride
  vulnerability in the 440C bearing above; 316 is the grade that does not reopen that argument
- **7.5 in.-lbs is a galling limit, not a strength one** — austenitic screw in an austenitic
  housing. These get opened at every filter change, so they are snugged with the 1/4 in nut driver
  and never a wrench. Nothing here needs the torque: the clamps close soft tubing over rigid
  barbs, and the tightest of them is 0.76 mm of slack on the riser
- the rule this follows is the one set against the impeller set screws — wetted → 316, dry → 18-8.
  Strictly these are dry, which would allow the 305, and the 305 would be a defensible row. What
  tips it is that one clamp size serves every joint, so the whole line inherits whichever grade is
  bought, including the sterile-side four and the one at the lid

### Thermocouple

- McMaster-Carr 1245N31, <https://www.mcmaster.com/1245N31/>
- Type K threaded thermocouple probe for liquids and gases
- 1/2 NPT male fitting, wire leads
- 6 in long x 1/8 in diameter grounded 304 stainless probe
- 4 ft fiberglass cable, 24 AWG, 1/2 in wire leads
- 0.5 s response time, 900 F maximum temperature
- both the 6 in and the 9 in are registered in `purchased/thermocouple_probes.scad`; `head()`
  selects the 6 in, the 9 in reaching through `jar_1gal_180x197`'s floor

### Motor mount inserts

- McMaster-Carr 97163A152, <https://www.mcmaster.com/97163A152/>
- 18-8 stainless tapered heat-set insert for plastic, ASTM A380
- M4 x 0.7 mm, 4.7 mm installed length, knurled, open end
- 2 Ga drill (5.613 mm), 5.740 mm maximum hole, 8 deg taper on the top half
- 5.72 mm minimum material thickness; the lid gives 18 mm
- 4 per lid, sold in packs of 10
- brass 94180A351 (<https://www.mcmaster.com/94180A351/>) is the same part in brass and installs
  more easily, since brass carries heat to the plastic far better than stainless does. Passed over
  here because this face sees condensation, splash and wipe-downs, because the brass is not REACH
  compliant and holds a RoHS 6(c) lead exemption, and because at a pack of 100 against a pack of 10
  it is the dearer buy for a single lid. Worth revisiting for a batch build

### Rim gasket sheet

- McMaster-Carr 8525T65, <https://www.mcmaster.com/8525T65/>
- water- and steam-resistant EPDM, plain backing, black, ASTM D2000
- 1/16 in thick (1.5875 mm), 12 in x 12 in sheet
- Durometer 60A, 800 psi maximum, -20 to 220 F
- the lid's gasket is cut 142.2 x 158.2 mm, so one sheet yields ONE - the 158.2 mm outside
  diameter will not pair on a 304.8 mm sheet
- hardness is what sets the joint's bolt count, not just the material: under 75A the ASME
  VIII-1 gasket factor m is 0.5 and the lid takes 12 posts, at or over it m is 1.0 and the
  lid takes 16. `head_gasket_factor()` derives that from the registered row, so buying a
  harder sheet changes the print rather than quietly under-bolting the joint
- it is cut BY HAND with a scalpel, against a printed **two-stage** template
  (`scad/custom/gasket_cutter.scad`). One template cannot guide both cuts: a template shaped like
  the gasket is a 3 mm wall standing at the ring's diameter, too slack in its own plane to hold a
  blade, and bracing it needs material exactly where the blade goes. So the OUTER cut is taken
  against a plain disc with nothing outboard to foul the blade, and the blank then drops into a
  counterbore under the INNER plate, which holds it concentric while its bore guides the second
  cut. Concentricity is a printed counterbore rather than the operator's hand, and both parts
  print flat with no bridge and no support
- the radial perimeter does not have to be accurate - the gasket seals on its AXIAL faces - which
  is why a template and a scalpel are enough and no die is bought. The fixture takes the same
  `(ID, OD, thickness)` `sheet_gasket()` takes and knows nothing else about the jar

### Drive motor

- **E-S Motor 36D gearmotor with encoder, RobotShop SKU RM-ESMO-071, mfr 36PG-555PM-14-EN 12V**,
  <https://ca.robotshop.com/products/e-s-motor-36d-dc-planetary-gearmotor-w-encoder-12v-420rpm>
- 12 V DC, gear ratio 1/14, **no-load 420 rpm, rated 320 rpm** at 5 kg·cm (0.490 N·m), rated
  current < 2 A, no-load current 400 mA, stall > 15 kg·cm / < 10 A, 30 W maximum
- motor 36 x 57 mm, gearbox 36 x 34.5 mm, shaft 8 x 20 mm D-shaped with 15 mm of flat at 7 mm
- faceplate 4-M4 tapped 5 mm deep on a 28 mm bolt circle, 22 mm pilot register standing 2 mm proud
- encoder is magnetic, 2 channels, 12 PPR at the motor shaft, which past the 14:1 is 672
  quadrature counts per output revolution — around 0.9 rpm resolved over a 100 ms window, against
  an operating band 155 rpm wide
- six flying leads (motor M1/M2, Hall GND, Hall A, Hall B, Hall Vcc); no connector fitted, unlike
  the 3429 SKUs which ship an SM2P-2.54 on 90 mm cables
- chosen because its 320–420 rpm spanned the whole speed band on the 94.5 mm pitched pair, the only
  candidate reaching that band's 410 rpm break-even, and because the encoder gives the drive speed
  feedback. On the 70 mm turbine it brackets the 344 rpm optimum and cannot reach the 554 rpm
  break-even ([Agitation](agitation.md#the-operating-point))
- **two numbers here are inferred, not published.** The encoder sheet tabulates no gearbox length,
  so 34.5 mm is the 36PG-3429 sheet's figure at 14:1; and its drawing's 57 mm spans the whole
  motor block without dimensioning the encoder separately, which is the same 57 mm the plain 555
  can gets with no encoder on it. Both feed the reactor envelope and so the cart, where a
  millimetre counts twice over two tiers — confirm with the vendor before ordering
- rejected **RM-ESMO-16Q** (36PG-3429-5.2): rated 950 rpm is 3.48 m/s at the 70 mm turbine's tip,
  1.7 times the break-even. Right family, wrong ratio. Still registered as a product
- passed over **RM-ESMO-16N** (36PG-3429-19, 42.15 CAD), no-load 385 / rated 265 rpm at 2.4 kg·cm.
  Both ends sit inside the pitched pair's band and it is 27.6 mm shorter in the stack, but it
  cannot reach the 554 rpm break-even and carries no encoder. The fallback if stack height turns
  out to bind
- passed over **RM-ESMO-0MX** (36PG-555K-1260-19, 34.50 CAD), no-load 315 / rated 240 rpm at
  7 kg·cm. Its rated point falls below the growth optimum, and the torque it sells on is worth
  nothing here — the impeller pair asks under 5 % of it. Bare copper tabs, no connector

### 36PG gearbox family

- one faceplate across the range: 4 screws on a **28 mm bolt circle**, a 22 mm pilot register
  standing **2 mm** proud, and an 8 x 20 mm D-cut output shaft. The 3429 and 555K are tapped M3,
  the 555PM-EN M4. This is what lets the printed mount stay common across the range
- rated speed runs 0.68–0.71 of no-load across all ten ratios, so an unqualified catalogue speed
  is a no-load speed and the operating point is roughly 0.7 of it. This is why the registry keeps
  the two apart. The ratio tables are in `scad/purchased/gearboxes.scad`
