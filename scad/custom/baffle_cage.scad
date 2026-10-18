/**
 * @file baffle_cage.scad
 * @brief Four wall baffles on two hoops, built on the bench and lowered through the mouth whole
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The standard baffle set - four at T/12, T/72 off the wall, floor to surface - on a jar whose
 * mouth is narrower than the blades are apart. Two rigid hoops pass the mouth lying flat. Each
 * blade hangs between them on a radial bar at each end, which slides in a dovetail channel in the
 * hoop: slid in, every part of the cage is inside the hoops and goes straight down through the
 * mouth; inside, each blade is pushed out until its pads stop just short of the glass.
 *
 * The dovetails hold the cage together. Two humps on each bar are detents: each is taller than
 * the bar's slack in its channel, so it is pushed through and clicks out of it, one with the
 * blade out against the wall and one with it slid in. The top hoop stands above the culture and
 * carries an arm that catches a tube from the lid, so the cage cannot turn. It is a C: its gap
 * is where the probes hang. The bottom hoop is the top one mirrored in z, on a footing, without
 * the arm.
 *
 * DATUM: z = 0 is the floor datum the caller measures the hoops from; x, y on the jar's axis.
 * Blade angles are where the blades stand, the first one along +x.
 */

$fn = $preview ? 64 : 128;
z_fight = $preview ? 0.05 : 0;

/* [Preview] */

// the jar's bore radius
bore_radius = 105;
// the mouth's radius
mouth_radius = 71.1;
// where the blades stand, in degrees
blade_at = [0, 90, 180, 270];
// the top hoop's gap, from and to, in degrees
gap_at = [17, 81];
// height of the top hoop's underside
top_z = 245.5;
// height of the bottom hoop's footing underside
bottom_z = 4.3;
// the footing under the bottom hoop
foot = 2.2;
// where the arm catches a tube: angle, radius and the tube's diameter
key = [0, 56.5, 4];
// how far the blades are slid in, 0 to the travel
slide = 0;
// what to draw: the cage, or one print file as it sits on the bed
part = "cage"; // [cage, hoop_top, hoop_bottom, blade]

module dummy() {
  // stop the customizer detection from here onwards
}

// ----- the part's own numbers -----
// The wall gap and width are the standard's; the rest is this design's, reasoned, not cited.

function baffle_cage_wall_gap(bore_radius) = 2 * bore_radius / 72; // T/72, the industry standard
function baffle_cage_width(bore_radius) = 2 * bore_radius / 12; // T/12, the standard turbine's
function baffle_cage_thickness() = 4;
function baffle_cage_fit() = 0.15; // sliding clearance in a channel, each side
// what each hoop's outer edge keeps off the mouth on the way down
function baffle_cage_mouth_clearance() = 1.1;
function baffle_cage_hoop_width() = 6;
function baffle_cage_hoop_height() = 10;
// the band between the blocks: full width, this tall, flush with the face that prints on the bed
function baffle_cage_band_height() = 6;
function baffle_cage_block() = 9; // half-width of the full block round each channel, deg
function baffle_cage_taper() = 8; // what each block ramps down over, deg
function baffle_cage_flange() = 2; // the dovetail's step
function baffle_cage_flange_start() = 2.5; // where it starts to widen, off the channel's mouth
function baffle_cage_channel_depth() = 7;
function baffle_cage_tip_overlap() = 3; // how far a bar reaches inside its hoop with the blade out
// the pads stop this far off the glass; the cage is centred within it
function baffle_cage_pad_clearance() = 0.4;
function baffle_cage_pad_height() = 10;
function baffle_cage_pad_from_top() = 25;
function baffle_cage_pad_from_bottom() = 10;
function baffle_cage_bar_fillet() = 5;
// Detents: humps on the bar, toward the channel's ceiling, taller than the bar's slack there (the
// fit at the ceiling and the fit at the 45 deg lip), so each is pushed through.
function baffle_cage_hump_height() = 0.5;
function baffle_cage_hump_ramp() = 1.5;
function baffle_cage_hump_flat() = 1;
function baffle_cage_hump_play() = 0.2; // free travel before a hump bears on its channel
// the arm: its width, how far inboard of the tube it starts, its root fillets
function baffle_cage_arm_width() = 12;
function baffle_cage_arm_reach() = 6.5;
function baffle_cage_arm_fillet() = 3;
function baffle_cage_lead() = 1.2; // the lead-in round the arm's slot

// ----- derived from the jar -----

function baffle_cage_outer_edge(bore_radius) = bore_radius - baffle_cage_wall_gap(bore_radius);
function baffle_cage_inner_edge(bore_radius) = baffle_cage_outer_edge(bore_radius) - baffle_cage_width(bore_radius);
function baffle_cage_pad_proud(bore_radius) = baffle_cage_wall_gap(bore_radius) - baffle_cage_pad_clearance();
function baffle_cage_hoop_outer(mouth_radius) = mouth_radius - baffle_cage_mouth_clearance();
function baffle_cage_hoop_inner(mouth_radius) = baffle_cage_hoop_outer(mouth_radius) - baffle_cage_hoop_width();
// slid in by this, every part of a blade is inside the hoops' outer edge
function baffle_cage_travel(bore_radius, mouth_radius) =
  baffle_cage_outer_edge(bore_radius) + baffle_cage_pad_proud(bore_radius) + baffle_cage_pad_clearance()
  - baffle_cage_hoop_outer(mouth_radius);
function baffle_cage_bar_tip(mouth_radius) = baffle_cage_hoop_inner(mouth_radius) - baffle_cage_tip_overlap();
// the bar's top, in the top hoop's frame: z 0 is its underside, where the channel opens
function baffle_cage_bar_top() = baffle_cage_channel_depth() - baffle_cage_fit();
function baffle_cage_hump_length() = 2 * baffle_cage_hump_ramp() + baffle_cage_hump_flat();
// the arm sits above the bar and its humps, which slide in under it
function baffle_cage_arm_z() = baffle_cage_bar_top() + baffle_cage_hump_height() + baffle_cage_fit();
// the blade's ends, from the hoops' undersides
function baffle_cage_blade_top(top_z) = top_z + baffle_cage_bar_top();
function baffle_cage_blade_bottom(bottom_z, foot) =
  bottom_z + foot + baffle_cage_hoop_height() - baffle_cage_bar_top();
// the lowest a slid-in bottom bar reaches, its detents included, from the footing's underside
function baffle_cage_bar_low(bottom_z, foot) = baffle_cage_blade_bottom(bottom_z, foot) - baffle_cage_hump_height();

// ----- profiles -----

// the bar's section (y, z), in the top hoop's frame: the plate, and the dovetail's flange on +y
module baffle_cage_bar_2d(z0 = -1) {
  tb = baffle_cage_thickness();
  fl = baffle_cage_flange();
  f0 = baffle_cage_flange_start();
  bt = baffle_cage_bar_top();
  polygon([[-tb / 2, z0], [tb / 2, z0], [tb / 2, f0], [tb / 2 + fl, f0 + fl], [tb / 2 + fl, bt], [-tb / 2, bt]]);
}

module baffle_cage_channel_2d() {
  tb = baffle_cage_thickness();
  fit = baffle_cage_fit();
  offset(delta=fit) baffle_cage_bar_2d();
  translate([-tb / 2 - fit, -5]) square([tb + 2 * fit, 5 + z_fight + 0.01]); // open through the underside
}

module baffle_cage_ring_2d(ri, ro, gap_at) {
  difference() {
    circle(r=ro);
    circle(r=ri);
    polygon([[0, 0], for (a = [gap_at[0]:2:gap_at[1]]) 2 * ro * [cos(a), sin(a)], 2 * ro * [cos(gap_at[1]), sin(gap_at[1])]]);
  }
}

module baffle_cage_wedge_2d(a0, a1, r) polygon([[0, 0], r * [cos(a0), sin(a0)], r * [cos(a1), sin(a1)]]);

// ----- the hoop -----

/**
 * @brief The top hoop in its own frame: z 0 its underside, where the channels open
 * @param ri, ro Inner and outer radius
 * @param blade_at Where the blades stand, deg
 * @param gap_at The C's gap, deg
 * @param key [angle, radius, diameter] of the tube the arm catches; undef for none
 */
module baffle_cage_hoop(ri, ro, blade_at, gap_at, key = undef) {
  h = baffle_cage_hoop_height();
  hb = baffle_cage_band_height();
  blk = baffle_cage_block();
  tp = baffle_cage_taper();
  arm_z = baffle_cage_arm_z();
  aw = baffle_cage_arm_width();
  fr = baffle_cage_arm_fillet();

  // a thin radial slice at a, from z0 up
  module slice(a, z0) rotate([0, 0, a]) translate([ri - 10, -0.005, z0]) cube([ro - ri + 20, 0.01, h - z0]);

  difference() {
    union() {
      translate([0, 0, h - hb]) linear_extrude(hb) baffle_cage_ring_2d(ri, ro, gap_at);
      linear_extrude(h) intersection() {
        baffle_cage_ring_2d(ri, ro, gap_at);
        for (a = blade_at) baffle_cage_wedge_2d(a - blk, a + blk, 2 * ro);
      }
      // Each block ramps down to the band, cut to the hoop's own curved faces so it runs into them
      // without a seam; none on a side the C's gap starts at.
      for (a = blade_at, sd = [-1, 1]) let (a0 = a + sd * blk, e = a + sd * (blk + tp))
        if (!(e > gap_at[0] && e < gap_at[1])) intersection() {
          hull() { slice(a0, 0); slice(e, h - hb); }
          linear_extrude(h) intersection() {
            baffle_cage_ring_2d(ri, ro, gap_at);
            baffle_cage_wedge_2d(min(a0, e), max(a0, e), 2 * ro);
          }
        }
      // the arm, and a fillet in each corner where it meets the hoop
      if (!is_undef(key)) {
        r0 = key[1] - baffle_cage_arm_reach();
        c = [sqrt((ri - fr) ^ 2 - (aw / 2 + fr) ^ 2), aw / 2 + fr];
        translate([0, 0, arm_z]) linear_extrude(h - arm_z) rotate(key[0]) {
          translate([r0, -aw / 2]) square([ri - r0 + 1, aw]);
          for (s = [0, 1]) mirror([0, s]) difference() {
            intersection() { translate([c[0], aw / 2]) square([ri, fr]); circle(r=ri + 0.5); }
            translate(c) circle(r=fr, $fn=48);
          }
        }
      }
    }
    for (a = blade_at) rotate([0, 0, a]) rotate([90, 0, 90]) translate([0, 0, ri - 5])
      linear_extrude(ro - ri + 10) baffle_cage_channel_2d();
    // the tube's slot, open toward the axis, its lead-in on the arm's upper face where the tube
    // comes down
    if (!is_undef(key)) {
      r0 = key[1] - baffle_cage_arm_reach();
      r1 = key[1] + key[2] / 2 + 1;
      w = key[2] + 4 * baffle_cage_fit();
      ld = baffle_cage_lead();
      rotate([0, 0, key[0]]) translate([0, 0, h]) mirror([0, 0, 1]) {
        hull() {
          translate([r0 - ld, -w / 2 - ld, -1]) cube([r1 - r0 + ld, w + 2 * ld, 1]);
          translate([r0, -w / 2, ld - 0.01]) cube([r1 - r0, w, 0.01]);
        }
        translate([r0 - 1, -w / 2, -1]) cube([r1 - r0 + 1, w, h - arm_z + 2]);
      }
    }
  }
}

// the bottom hoop as it sits: the top one mirrored in z, on its footing
module baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot) {
  h = baffle_cage_hoop_height();
  translate([0, 0, h + foot]) mirror([0, 0, 1]) {
    baffle_cage_hoop(ri, ro, blade_at, gap_at);
    translate([0, 0, h - z_fight]) linear_extrude(foot + z_fight) intersection() {
      baffle_cage_ring_2d(ri, ro, gap_at);
      // under the band and the blocks; the ramps stand on the band's footprint
      circle(r=ro);
    }
  }
}

// ----- the blade -----

/**
 * @brief One blade at +x, out against the wall, in the caller's frame
 * @param top_z The top hoop's underside
 * @param bottom_z The bottom hoop's footing underside
 */
module baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot) {
  tb = baffle_cage_thickness();
  r_out = baffle_cage_outer_edge(bore_radius);
  r_in = baffle_cage_inner_edge(bore_radius);
  r_tip = baffle_cage_bar_tip(mouth_radius);
  pp = baffle_cage_pad_proud(bore_radius);
  ph = baffle_cage_pad_height();
  rf = baffle_cage_bar_fillet();
  hh = baffle_cage_hump_height();
  hr = baffle_cage_hump_ramp();
  hl = baffle_cage_hump_length();
  bt = baffle_cage_bar_top();
  h = baffle_cage_hoop_height();
  ro = baffle_cage_hoop_outer(mouth_radius);
  ri = baffle_cage_hoop_inner(mouth_radius);
  z_bt = baffle_cage_blade_top(top_z);
  z_bb = baffle_cage_blade_bottom(bottom_z, foot);
  b_ref = bottom_z + foot + h; // the bottom hoop's channel mouth, its frame's z 0 mirrored
  // the out-detent just outside the hoop with the blade out; the in-detent just inside it slid in
  hump_at = [
    ro + baffle_cage_hump_play(),
    ri - baffle_cage_hump_play() - hl + baffle_cage_travel(bore_radius, mouth_radius),
  ];

  // a profile in (r, z) made into a piece of the plate
  module in_plate(y0 = -tb / 2, y1 = tb / 2) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
  module bar() rotate([90, 0, 90]) translate([0, 0, r_tip]) linear_extrude(r_out - r_tip) baffle_cage_bar_2d();
  module humps() for (r0 = hump_at) in_plate(-tb / 2, tb / 2 + baffle_cage_flange())
    polygon([[r0, bt - 0.01], [r0 + hr, bt + hh], [r0 + hl - hr, bt + hh], [r0 + hl, bt - 0.01]]);
  // the corner at p, between a bar running inward and the blade's inner edge running away in dz
  module corner_fillet(p, dz) difference() {
    translate([p[0] - rf, dz > 0 ? p[1] : p[1] - rf]) square([rf + 0.01, rf]);
    translate([p[0] - rf, p[1] + dz * rf]) circle(r=rf, $fn=48);
  }

  translate([r_in, -tb / 2, z_bb]) cube([r_out - r_in, tb, z_bt - z_bb]);
  translate([0, 0, top_z]) { bar(); humps(); }
  translate([0, 0, b_ref]) mirror([0, 0, 1]) { bar(); humps(); }
  // pads with 45 deg ends, their own height of them on the glass
  for (z = [z_bt - baffle_cage_pad_from_top() - ph, z_bb + baffle_cage_pad_from_bottom()]) in_plate()
    polygon([[r_out - 0.01, z - pp], [r_out + pp, z], [r_out + pp, z + ph], [r_out - 0.01, z + ph + pp]]);
  in_plate() {
    corner_fillet([r_in, top_z - 1], -1);
    corner_fillet([r_in, b_ref + 1], 1);
  }
}

// ----- the cage -----

/**
 * @brief The cage in the caller's frame, or one print file as it sits on the bed
 * @param bore_radius The jar's bore
 * @param mouth_radius The mouth's
 * @param blade_at Where the blades stand, deg
 * @param gap_at The hoops' gap, deg: from and to, between two blades
 * @param top_z The top hoop's underside
 * @param bottom_z The bottom hoop's footing underside
 * @param foot The footing's height
 * @param key [angle, radius, diameter] of the tube the top hoop's arm catches
 * @param slide How far every blade is slid in, 0 to baffle_cage_travel()
 * @param part "cage", or "hoop_top", "hoop_bottom", "blade" as each prints
 */
module baffle_cage(bore_radius, mouth_radius, blade_at, gap_at, top_z, bottom_z, foot, key, slide = 0, part = "cage") {
  ri = baffle_cage_hoop_inner(mouth_radius);
  ro = baffle_cage_hoop_outer(mouth_radius);
  h = baffle_cage_hoop_height();
  assert(gap_at[0] < gap_at[1], "baffle_cage: the gap runs from the lower angle to the higher");
  assert(slide >= 0 && slide <= baffle_cage_travel(bore_radius, mouth_radius), "baffle_cage: a blade slides between out and its travel in");

  if (part == "cage") {
    translate([0, 0, top_z]) baffle_cage_hoop(ri, ro, blade_at, gap_at, key);
    translate([0, 0, bottom_z]) baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot);
    for (a = blade_at) rotate([0, 0, a]) translate([-slide, 0, 0])
      baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot);
  }
  // Both hoops print channels up, so the lip's underside is a 45 deg overhang: the top one turned
  // over with its arm on the bed, the bottom one as it sits. The dovetail is on one side only, so
  // they are two parts, mirror images, not one turned over.
  else if (part == "hoop_top") translate([0, 0, h]) rotate([180, 0, 0]) baffle_cage_hoop(ri, ro, blade_at, gap_at, key);
  else if (part == "hoop_bottom") baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot);
  // flat, the flange up
  else if (part == "blade")
    rotate([90, 0, 0])
      translate([-baffle_cage_bar_tip(mouth_radius), baffle_cage_thickness() / 2, -baffle_cage_bar_low(bottom_z, foot)])
        baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot);
  else assert(false, str("baffle_cage: no part named \"", part, "\""));
}

baffle_cage(bore_radius, mouth_radius, blade_at, gap_at, top_z, bottom_z, foot, key, slide, part);
