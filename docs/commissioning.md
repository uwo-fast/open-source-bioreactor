# Commissioning

The first run, once the reactor is together as [Building it](build.md) leaves it, and the numbers
worth sending back from it.

**Set the gas rate before anything else.** 0.1-0.5 vvm on 8.17 L is **0.817-4.09 L/min**, which is
16 % to 82 % of the registered 0-5 L/min meter - both ends on scale, which is what that range buys.
The pump is seven times oversized, so the entire band sits in the first part of the needle valve's
travel - that is why the valve is a 3 deg needle and not the 20 deg one.

**Watch the DO trace on the first run.** On a shaft-drive build with the loop or the ring, `head()`
reports where the DO probe's face sits against the sparger (`DO probe in the gas:`; of the
transcripts, `build__jar_10L_220x305` carries it), and warns when the face overlaps the sparger's
radius. A galvanic probe reads high with a bubble on the membrane and low with nothing moving past,
so a probe over the bubbles can be wrong in both directions. A characteristically spiky trace means
the probe is in the plume. Where the bubbles go is a bench question, and the model has two levers.
The port's lean moves the face across the gas: it leans outward, so leaning less takes the face
inward, away from a ring outboard of it and toward a loop inboard of it. On `jar_10L` the lean is
already at its 4.5 deg ceiling, away from the loop. The sparger's height (`sparge_cap_drop` for the
loop and the arm, `sparge_ring_gap_fraction` for the ring) moves the gas up or down under the face.
The echo gives the face's offset after either change.

**Know the replace-the-filter signal.** The sterile filter can rise about **50 %** - from 14.1 kPa
to roughly 21.1 - before 0.5 vvm becomes unreachable with the valve wide open. So _valve fully open
and still short of the rate_ is the signal, and it is not a pump problem.

---

## What to record

The model is waiting on four measurements. If you build one of these, these are the numbers worth
sending back:

1. **The sterile filter's Delta P** at the set flow, from a water manometer across it. It is the largest
   term in the gas budget and the only one that is extrapolated.
2. **The jar's rim**, calipered - the land width on top of the glass, the wall, and the mouth. Three
   registered numbers disagree on two vessels and a caliper says which is wrong.
3. **The baffle's lean.** Print the lid's baffle port and one plate segment, seat them, and measure
   the tilt at a known distance below the lid. The model keeps 1 mm running clearance after a
   stacked worst case of lean, 2.44 mm at `jar_10L`'s lower impeller, and cannot tell how much of
   that lean is real. On the reference build the lock bore caps the plate first, so the lean costs
   no width there; on a build where the impeller caps it, whatever the measurement takes off is
   plate width back.
4. **Whether the joint holds.** Nobody has yet tightened twelve nuts a third of a turn onto a glass
   jar with a printed flange in between. How much it relaxes, and over what time,
   is the number the build most needs.
