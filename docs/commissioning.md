# Commissioning

This document covers the first run after the reactor is assembled as described in
[Building it](build.md), and the measurements from that run worth reporting back.

**Set the gas rate before anything else.** 0.1-0.5 vvm on 8.17 L is **0.817-4.09 L/min**, which is
16 % to 82 % of the registered 0-5 L/min meter. Both ends are on scale, which is the reason for that
meter range. The pump is seven times oversized, so the whole band falls in the first part of the
needle valve travel. That is why the valve has a 3 deg needle and not the 20 deg one.

**Watch the DO trace on the first run.** On a shaft-drive build with the loop or ring sparger, where
the flow number of the upper impeller is known, `head()` reports the position of the DO probe face
relative to the sparger (`DO probe in the gas:`). Of the transcripts, `build__jar_10L_220x305`
includes this line. `head()` warns when the face is above the sparger and over its radius. A
galvanic probe reads high when a bubble is on the membrane and low when no liquid moves past it, so
a probe above the bubbles can be wrong in either direction. A characteristically spiky trace means
the probe is in the bubble plume. Where the bubbles go has to be found on the bench. The model has
two parameters that change it: the port lean (`do_probe_port_tilt_max`, an upper limit) and the
sparger height (`sparge_cap_drop` for the loop, `sparge_ring_gap_fraction` for the ring). The port
leans outward, so less lean moves the face inward. On `jar_10L` the loop is inboard and the lean is
already at its 4.5 deg limit, so less lean only moves the face closer to the loop: 28.7 mm from its
radius at 4.5 deg, and 18.2 mm at 0 deg. With the ring on `jar_6p5gal_305x470`, the face is 0.59 mm
outboard of the ring radius at the limit, crosses it near 4.25 deg, and clears the warning only at
0 deg, 9.89 mm inboard. The sparger height moves the gas up or down under the face. After either
change, the echo output gives the new face position.

**Know when to replace the filter.** The sterile filter pressure drop can rise by about **50 %**,
from 14.1 kPa to roughly 21.1 kPa, before 0.5 vvm becomes unreachable with the valve fully open. A
_valve fully open and still below the set rate_ therefore means the filter needs replacing. It does
not indicate a pump problem.

---

## What to record

The model depends on four measurements that have not been made yet. If you build this reactor,
these are the numbers worth reporting back:

1. **Sterile filter Delta P** at the set flow, measured with a water manometer across the filter.
   It is the largest term in the gas budget and the only one that is extrapolated.
2. **Jar rim dimensions**, measured with calipers: the land width on top of the glass, the wall, and
   the mouth. Three registered numbers disagree on two vessels, and a caliper measurement shows
   which is wrong.
3. **Baffle lean.** Print the baffle port of the lid and one plate segment, seat them, and measure
   the tilt at a known distance below the lid. The model keeps 1 mm of running clearance after a
   stacked worst-case lean (2.44 mm at the lower impeller on `jar_10L`), and cannot tell how much of
   that lean is real. On the reference build the lock bore limits the plate first, so the lean costs
   no plate width there. On a build where the impeller is the limit, any lean the measurement removes
   from the worst case is regained as plate width.
4. **Whether the joint holds.** No one has yet tightened twelve nuts a third of a turn onto a glass
   jar with a printed flange between them. How much the joint relaxes, and over what time, is the
   measurement the build most needs.
