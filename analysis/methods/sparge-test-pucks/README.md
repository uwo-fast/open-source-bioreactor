# Sparge test pucks

The puck model is `scad/custom/sparge_puck.scad`, and Palfy et al. 2021 is in
[References](../../../docs/references.md).

Bench parts, not reactor parts: each prints from `custom/sparge_puck.scad` with one outlet face,
and none goes in a jar. They exist to measure what a printed outlet face costs at a flow, which is
the one number the sparger model cannot work out. Drilled holes are priced by the orifice equation;
a printed porous face is priced by nothing, and the only published one (Palfy et al. 2021) is one
point at 14.7 L/h, borrowed and scaled linearly in the render.

**Print three hole pucks and one porous puck to start.** `hole_diameter` 3 is the arm's own holes
and the control; 0.8 and 0.5 are the finer ones. `hole_count = 0` takes as many holes as keeps the
drop through each well above what a `hole_scatter` difference in size does to the pressure a hole
needs to launch a bubble, at `bench_flow`, so every hole flows there; the render's first line says
by how much. The drop goes as the flow squared, so at lower flows the largest holes take the gas,
and the render says so if `bench_flow` is set to them with `hole_count` fixed at the printed
count. The 3 mm control also warns that its manifold is outside the range the sparger model is
fitted to: the feed's 53.5 Pa of velocity head is more than the 16.5 Pa through a hole, so the
jet into the plenum, not the scatter, may decide which holes flow. `outlet = "porous"` is a solid
face `porous_layers` thick at Palfy's area, over ribs.

**The face prints on the bed, as rendered.** Finish each hole with a drill of `hole_diameter`: a
0.4 mm nozzle does not hold a hole that small, and a drill's size is a number you know. For the
porous face, make its layers leak: Palfy et al. ran the walls at 115 % extrusion to seal them and
dropped the three membrane layers to 95 % by editing the G-code. Their membrane was printed last,
on top of its honeycomb; this one is printed first, pressed against the bed with the ribs on top,
and a first layer squashed flat may leak less than theirs did. That is one more reason the borrowed
point is a guess. Keep the sliced project with the results, since the face is the recipe as much as
the geometry.

**Seal-check every puck first.** Tape over the face, put it under water and blow: any bubble now is
a wall leaking, and the face's numbers mean nothing until it stops.

**Blank the feed first.** The pressure is read at a tee upstream of the puck, so it also carries
what the tube and the riser offcut lose on the way, which for the 3 mm control is as large as the
face's cost. With no puck on, and the offcut's end in air, read the tee at each flow below; take
that off every reading after.

Then, under `bench_depth` of water in a clear column, at three flows on the rotameter - 0.8, 2.5
and 4 L/min span the reactor's band - record:

1. **The plenum's pressure**, from that tee: a U-tube of clear tubing for the hole pucks, a
   0-30 kPa gauge for the porous one. What it reads above the water's own head and the blank is the
   face's cost. For a hole puck the render's `sparge puck gauge` line is the prediction to check: a
   range, since the capillary part is a peak each bubble passes and the U-tube damps it.
2. **How many outlets are bubbling, at `bench_flow`.** All of them is what the hole count was
   chosen for; a few means the scatter is larger than `hole_scatter`. At the lower flows a few is
   expected, and the count there is the reading.
3. **Bubble size**, from a photo against a scale in the column. The render's figure is a floor.

**The porous puck may not reach any of those flows.** Carried linearly from Palfy's one point, its
face costs so much that the pump flat out pushes about 0.28 L/min through it, and the render's
warning gives the figure. So run it with the pump flat out and record the flow it passes and the
pressure, then at two lower flows on a rotameter that reads them. If it passes much more than the
render says, the borrowed point was the wrong guess, which is what the puck is for.

**The socket puck hangs from an offcut of the 4 mm riser,** gripped by the M4 set screw as the
arm's socket is, so it also checks the 0.2 mm slip fit nobody has measured. A barb puck hangs from
soft tubing, which cannot hold it down: the render says whether it floats, and by how much.

A face whose cost fits under what the pump has left can be used on the reactor; one that does not
stays on the bench.
