// One slice of a part, and whatever in it is thinner than min_wall: erode the slice by half of
// min_wall and grow it back, and what does not come back was thinner. Square offsets keep sharp
// corners, so only thin material is left. Run with -D which="base"|"top" -D z=<port-frame height>;
// the result is empty when the slice has nothing too thin. thin_sweep.py runs it through a part.
include <../../scad/custom/sampler.scad>
part = "none";
which = "top"; // [base, top]
z = 20;

module slice() projection(cut=true) translate([0, 0, -z]) { if (which == "base") sampler_base(); else sampler_top(); }

difference() {
  slice();
  offset(delta=min_wall / 2) offset(delta=-min_wall / 2) slice();
}
