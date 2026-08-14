# Procurement

- bearing selection
  - McMaster-Carr 6153K71
  - shaft: 8mm
  - seal type: sealed
  - bearing type: ball
  - construction: single row
  - lubricant: grease
  - ball material: stainless steel
  - trade no. 608-2RS: 22.000 mm OD (-0.008/0), 7.00 mm wide (-0.12/0), 8.000 mm bore (-0.007/0),
    caliper-confirmed against the drawing. Registered as NopSCADlib's BB608, which carries those
    same three numbers, so the pocket is cut from the part and not from a copy of it
  - https://www.mcmaster.com/6153K71/

- thermocouple selection
  - McMaster-Carr 3872K117
  - Type K threaded thermocouple probe for liquids and gases
  - 1/2 NPT male fitting, wire leads
  - 9 in long x 1/8 in diameter grounded 304 stainless probe
  - 4 ft fiberglass cable, 24 AWG, 1/2 in wire leads
  - 0.5 s response time, 900 F maximum temperature
  - https://www.mcmaster.com/3872K117/

- motor mount insert selection
  - McMaster-Carr 97163A152
  - 18-8 stainless tapered heat-set insert for plastic, ASTM A380
  - M4 x 0.7 mm, 4.7 mm installed length, knurled, open end
  - 2 Ga drill (5.613 mm), 5.740 mm maximum hole, 8 deg taper on the top half
  - 5.72 mm minimum material thickness; the lid gives 18 mm
  - 4 per lid, sold in packs of 10
  - https://www.mcmaster.com/97163A152/
  - brass 94180A351 is the same part in brass and installs more easily, since brass carries
    heat to the plastic far better than stainless does. Passed over here because this face
    sees condensation, splash and wipe-downs, because the brass is not REACH compliant and
    holds a RoHS 6(c) lead exemption, and because at a pack of 100 against a pack of 10 it is
    the dearer buy for a single lid. Worth revisiting for a batch build
  - https://www.mcmaster.com/94180A351/

- rim gasket sheet selection
  - McMaster-Carr 8525T65
  - water- and steam-resistant EPDM, plain backing, black, ASTM D2000
  - 1/16 in thick (1.5875 mm), 12 in x 12 in sheet
  - Durometer 60A, 800 psi maximum, -20 to 220 F
  - the lid's gasket is cut 145 x 151 mm, so one sheet yields four
  - hardness is what sets the joint's bolt count, not just the material: under 75A the ASME
    VIII-1 gasket factor m is 0.5 and the lid takes 12 posts, at or over it m is 1.0 and the
    lid takes 16. `head_gasket_factor()` derives that from the registered row, so buying a
    harder sheet changes the print rather than quietly under-bolting the joint
  - https://www.mcmaster.com/8525T65/

- current motors in lab
  - 36GP-3530 Planetary Gear DC Motor Torque 50KG (12V 1154 RPM)
  - the listing offers ten 12 V speeds — 8 / 12 / 16 / 28 / 43 / 73 / 120 / 222 / 429 / 1154 rpm —
    and gives no ratio against any of them. 1154 is the top of that list and is unqualified, so it
    is registered as a no-load speed; no rated figure is published for this motor
  - https://electric-b2c.com/products/36gp-3530-planetary-gear-dc-motor-torque-50kg-12v-24v-reduce-speed-8pm-to-1154rpm-pwm-reverse-forward-electric-12-volt-motor?variant=47572164116673

- drive motor for the next build
  - **E-S Motor 36D gearmotor with encoder, RobotShop SKU RM-ESMO-071, mfr 36PG-555PM-14-EN 12V**
  - 12 V DC, gear ratio 1/14, **no-load 420 rpm, rated 320 rpm** at 5 kg·cm (0.490 N·m), rated
    current < 2 A, no-load current 400 mA, stall > 15 kg·cm / < 10 A, 30 W maximum
  - motor 36 x 57 mm, gearbox 36 x 34.5 mm, shaft 8 x 20 mm D-shaped with 15 mm of flat at 7 mm
  - faceplate 4-M4 tapped 5 mm deep on a 28 mm bolt circle, 22 mm pilot register standing 2 mm proud
  - encoder is magnetic, 2 channels, 12 PPR at the motor shaft, which past the 14:1 is 672
    quadrature counts per output revolution — around 0.9 rpm resolved over a 100 ms window, against
    an operating band 155 rpm wide
  - six flying leads (motor M1/M2, Hall GND, Hall A, Hall B, Hall Vcc); no connector fitted, unlike
    the 3429 SKUs which ship an SM2P-2.54 on 90 mm cables
  - chosen because 320–420 rpm spans the whole band `agitation.md` sets and is the only candidate
    reaching the 410 rpm break-even, and because the encoder retires the no-speed-feedback gap that
    band containment was working around
  - https://ca.robotshop.com/products/e-s-motor-36d-dc-planetary-gearmotor-w-encoder-12v-420rpm
  - **two numbers here are inferred, not published.** The encoder sheet tabulates no gearbox length,
    so 34.5 mm is the 36PG-3429 sheet's figure at 14:1; and its drawing's 57 mm spans the whole
    motor block without dimensioning the encoder separately, which is the same 57 mm the plain 555
    can gets with no encoder on it. Both feed the reactor envelope and so the cart, where a
    millimetre counts twice over two tiers — confirm with the vendor before ordering
  - superseded **RM-ESMO-16Q** (36PG-3429-5.2), which this document previously named: rated 950 rpm
    is 4.70 m/s at the tip, more than twice the break-even. Right family, wrong ratio. Still
    registered as a product
  - passed over **RM-ESMO-16N** (36PG-3429-19, 42.15 CAD), no-load 385 / rated 265 rpm at 2.4 kg·cm.
    Both ends sit inside the band and it is 27.6 mm shorter in the stack, but it cannot reach the
    410 rpm break-even and carries no encoder. The fallback if stack height turns out to bind
  - passed over **RM-ESMO-0MX** (36PG-555K-1260-19, 34.50 CAD), no-load 315 / rated 240 rpm at
    7 kg·cm. Its rated point falls below the growth optimum, and the torque it sells on is worth
    nothing here — the impeller pair asks under 5 % of it. Bare copper tabs, no connector

- 36PG gearbox family, from the E-S outline drawings and ratio tables
  - one faceplate across the range: 4 screws on a **28 mm bolt circle**, a 22 mm pilot register
    standing **2 mm** proud, and an 8 x 20 mm D-cut output shaft. The 3429 and 555K are tapped M3,
    the 555PM-EN M4. This is what lets the printed mount stay common across the range
  - **gearbox length goes with the ratio group, not with the motor**: 26.5 mm at 3.71 and 5.2,
    34.5 mm at 14, 19 and 27, 42.5 mm at 51, 100 and 139, 50.5 mm at 264 and 515
  - rated speed runs 0.68–0.71 of no-load across all ten ratios, so an unqualified catalogue speed
    is a no-load speed and the operating point is roughly 0.7 of it. This is why the registry keeps
    the two apart
  - the 36PG-3429 at 12 V, by ratio, as no-load rpm / rated rpm / rated kg·cm: 3.71 1950/1350/0.45,
    5.2 1400/950/0.65, 14 520/360/1.8, 19 385/265/2.4, 27 270/190/3.5, 51 140/100/6.5,
    100 72/50/13.5, 139 52/36/18.5, 264 28/19/34, 515 14/10/50
