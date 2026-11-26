# Sparge test pucks

The sources cited below are in [References](../../../docs/references.md).

These are bench parts, not reactor parts. Each one prints from `scad/custom/sparge_puck.scad` with
one outlet face, and none goes in a jar. They are for measuring the pressure a printed outlet face
costs at a given flow, which is the one number the sparger model cannot calculate. The orifice
equation gives the cost of drilled holes. Nothing gives the cost of a printed porous face: the only
published value (Palfy et al. 2021) is a single point at 14.7 L/h, which the render borrows and
scales linearly.

**Print three hole pucks and one porous puck to start.** `hole_diameter` 3 matches the holes in the
sparger arm and is the control; 0.8 and 0.5 are the finer sizes. With `hole_count = 0`, the model
uses as many holes as it can while keeping the pressure drop through each hole at `bench_flow` well
above the effect that a `hole_scatter` difference in size has on the pressure a hole needs to
release a bubble. Every hole then flows at that rate. The first line of the render output gives the
margin. The drop scales with the square of the flow, so at lower flows the largest holes take the
gas. The render reports this if `bench_flow` is set to a lower flow with `hole_count` fixed at the
printed count. The 3 mm control also warns that its manifold is outside the range the sparger model
is fitted to. The 53.5 Pa velocity head of the feed is more than the 16.5 Pa drop through a hole,
so the jet into the plenum, not the scatter, may decide which holes flow. `outlet = "porous"` is a
solid face, `porous_layers` thick, with the same area as Palfy's, over ribs.

**The face prints on the bed, as rendered.** Finish each hole with a drill of size `hole_diameter`.
A 0.4 mm nozzle does not hold a hole that small, and the size of a drill is known. The layers of the
porous face must leak. Palfy et al. printed the walls at 115 % extrusion to seal them, and reduced
the three membrane layers to 95 % by editing the G-code. They printed their membrane last, on top of
its honeycomb. This one is printed first, against the bed with the ribs on top, and a flattened
first layer may leak less than theirs did. That is another reason the borrowed point is a guess.
Keep the sliced project with the results, because the slicer settings define the face as much as
the geometry does.

**Seal-check every puck first.** Tape over the face, put the puck under water and blow into it. Any
bubble at this stage is a leaking wall, and the face measurements mean nothing until the leak is
fixed.

**Take a blank reading of the feed first.** The pressure is read at a tee upstream of the puck, so
it also includes the losses in the tube and the riser offcut. For the 3 mm control, these losses
are as large as the cost of the face. With no puck fitted and the end of the offcut in air, read the
tee at each flow below, and subtract that from every later reading.

Then, with the puck under `bench_depth` of water in a clear column, record the following at three
rotameter flows (0.8, 2.5 and 4 L/min, which span the band of the reactor):

1. **Plenum pressure**, from that tee: a U-tube of clear tubing for the hole pucks, or a 0-30 kPa
   gauge for the porous one. The reading above the water head and the blank is the cost of the
   face. For a hole puck, the `sparge puck gauge` line of the render is the prediction to check.
   It is a range, because the capillary part is a peak that each bubble passes, and the U-tube
   damps it.
2. **Number of outlets bubbling at `bench_flow`.** The hole count was chosen so that all of them
   bubble. If only a few do, the scatter is larger than `hole_scatter`. At the lower flows a few
   are expected, and the count there is the reading.
3. **Bubble size**, from a photo against a scale in the column. The figure in the render is a lower
   bound.

**The porous puck may not reach any of those flows.** Scaled linearly from Palfy's single point,
its face costs so much that the pump at full output pushes about 0.28 L/min through it. The render
warning gives the figure. Run it with the pump at full output and record the flow and the pressure,
then repeat at two lower flows on a rotameter that can read them. If it passes much more than the
render predicts, the borrowed point was wrong, and the puck exists to find that out.

**The socket puck hangs from an offcut of the 4 mm riser,** held by the M4 set screw in the same
way as the arm socket, so it also checks the 0.2 mm slip fit, which nobody has measured. A barb
puck hangs from soft tubing, which cannot hold it down. The render reports whether it floats, and
by how much.

A face whose cost fits within the pressure the pump has left can be used on the reactor. A face
that does not stays on the bench.
