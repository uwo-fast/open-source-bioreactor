"""Slice each part every 0.2 mm through its height and report any slice with material thinner than
min_wall, from thin.scad. Pieces under 0.05 mm2 are the zero-area seams where faceted curves
meet after the offsets, not material, and are not counted. A slice counts only if OpenSCAD ran cleanly: an ERROR or WARNING is a
failure, never an empty result. Usage: thin_sweep.py '<openscad and its flags>' <outdir> [base|top ...]"""
import re, shlex, subprocess, sys
from pathlib import Path

here = Path(__file__).resolve().parent
openscad, out = shlex.split(sys.argv[1]), Path(sys.argv[2])
parts = sys.argv[3:] or ["base", "top"]
echo = subprocess.run([*openscad, "-o", str(out / "e.csg"), str(here.parent.parent / "scad" / "custom" / "sampler.scad")], capture_output=True, text=True).stderr
nums = lambda key: float(re.search(key + r" ([-\d.]+)", echo).group(1))
ranges = {"base": (5.0, nums("split")), "top": (nums("split"), nums("face"))}
bad = 0
MIN_AREA = 0.05

def pieces(svg):
    """Areas of the closed paths in an SVG export."""
    found = []
    for path in re.findall(r'<path d="([^"]+)"', svg.read_text()):
        for sub in re.split(r"(?=M)", path):
            pts = [tuple(map(float, q)) for q in re.findall(r"(-?[\d.]+),(-?[\d.]+)", sub)]
            if len(pts) > 2:
                found.append(abs(sum(pts[i][0] * pts[(i + 1) % len(pts)][1] - pts[(i + 1) % len(pts)][0] * pts[i][1]
                                     for i in range(len(pts)))) / 2)
    return found

for part in parts:
    lo, hi = ranges[part]
    z, flagged, n = lo + 0.1, [], 0
    while z < hi:
        svg = out / f"thin_{part}_{z:.2f}.svg"
        r = subprocess.run([*openscad, "-D", f'which="{part}"', "-D", f"z={z:.2f}", "-o", str(svg), str(here / "thin.scad")],
                           capture_output=True, text=True).stderr
        if re.search(r"ERROR|WARNING|Assertion", r):
            print(f"{part} z {z:.2f}: FAILED TO RUN: {r.strip().splitlines()[-1][:100]}"); bad += 1
        elif "top level object is empty" not in r and svg.exists():  # no file and no error: an empty slice
            worst = max(pieces(svg), default=0)
            if worst >= MIN_AREA:
                flagged.append((round(z, 2), round(worst, 2)))
        n += 1
        z += 0.2
    print(f"{part}: {n} slices from z {lo:.1f} to {hi:.1f}; thin material in {len(flagged)}"
          + (": " + ", ".join(f"z {z} ({a} mm2)" for z, a in flagged) if flagged else ""))
    bad += len(flagged)
sys.exit(1 if bad else 0)
