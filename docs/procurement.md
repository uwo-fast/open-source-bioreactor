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
  - https://electric-b2c.com/products/36gp-3530-planetary-gear-dc-motor-torque-50kg-12v-24v-reduce-speed-8pm-to-1154rpm-pwm-reverse-forward-electric-12-volt-motor?variant=47572164116673