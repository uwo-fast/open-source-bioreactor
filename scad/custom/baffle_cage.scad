/**
 * @file baffle_cage.scad
 * @brief Four wall baffles on two hoops, built on the bench and lowered through the mouth whole
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The standard baffle set - four at T/12, T/72 off the wall, floor to surface - on a jar whose
 * mouth is narrower than the blades are apart. Two rigid hoops pass the mouth lying flat. Each
 * blade hangs between them on a radial bar at each end, which slides in a dovetail channel in the
 * hoop: slid in, the cage goes down through the mouth; inside, each blade is pushed out until its
 * bars' inner ends are flush with the hoops' inside, its pads just short of the glass.
 *
 * The dovetails hold the cage together. A stop on each bar's outer end, on the dovetail's side,
 * meets the hoop's outside and keeps a blade from sliding through into the middle; a hump on the
 * bar is a detent that holds it slid in on the way down. Out, the blades are locked by half-rings
 * dropped into each hoop: a skirt inside the hoop stands where a bar would have to go to slide
 * back in. The top hoop stands above the culture, and its two half-rings key into it; one of them
 * carries an arm that catches a tube from the lid, so the cage cannot turn. The hoops are Cs:
 * the gap is where the probes hang. The bottom hoop is the top one mirrored in z, on a footing,
 * and its half-rings sit on its band between the blocks.
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
// the hoops' gap, from and to, in degrees
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
// whether to draw the half-rings that lock the blades out
locked = true;
// what to draw: the cage, or one print file as it sits on the bed
part = "cage"; // [cage, hoop_top, hoop_bottom, blade, lock_top_0, lock_top_1, lock_bottom_0, lock_bottom_1]

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
// the stop on a bar's outer end: how far it runs along the bar, and how far past the flange it
// stands, on the flange's side
function baffle_cage_stop_length() = 1;
function baffle_cage_stop_proud() = 1.5;
// the pads stop this far off the glass; the cage is centred within it
function baffle_cage_pad_clearance() = 0.4;
function baffle_cage_pad_height() = 10;
function baffle_cage_pad_from_top() = 25;
function baffle_cage_pad_from_bottom() = 10;
function baffle_cage_bar_fillet() = 5;
// The detent: a hump on the bar, toward the channel's ceiling, taller than the bar's slack there
// (the fit at the ceiling and the fit at the 45 deg lip), so it is pushed through.
function baffle_cage_hump_height() = 0.5;
function baffle_cage_hump_ramp() = 1.5;
function baffle_cage_hump_flat() = 1;
function baffle_cage_hump_play() = 0.2; // free travel before the hump bears on its channel
// The half-rings: the skirt's radial clearance to the hoop and its thickness, the flange on the
// hoop, and the top's keys into its pockets.
function baffle_cage_lock_clearance() = 0.2;
function baffle_cage_lock_skirt() = 2.5;
function baffle_cage_lock_flange() = 1.5;
function baffle_cage_lock_flange_reach() = 5; // how far over the hoop the flange runs
function baffle_cage_lock_bottom_skirt() = 2.5; // how far below the bottom flange the skirt reaches
function baffle_cage_key_width() = 6;
function baffle_cage_key_depth() = 2;
function baffle_cage_key_reach() = 2.5; // into the hoop past its inside
function baffle_cage_split_clearance() = 0.5; // between the two half-rings, deg each side
// the arm: its width, how far inboard of the tube it starts, its thickness, its root fillets
function baffle_cage_arm_width() = 12;
function baffle_cage_arm_reach() = 6.5;
function baffle_cage_arm_thickness() = 3;
function baffle_cage_arm_fillet() = 3;
function baffle_cage_lead() = 1.2; // the lead-in round the arm's slot

// ----- derived from the jar -----

function baffle_cage_outer_edge(bore_radius) = bore_radius - baffle_cage_wall_gap(bore_radius);
function baffle_cage_inner_edge(bore_radius) = baffle_cage_outer_edge(bore_radius) - baffle_cage_width(bore_radius);
function baffle_cage_pad_proud(bore_radius) = baffle_cage_wall_gap(bore_radius) - baffle_cage_pad_clearance();
function baffle_cage_hoop_outer(mouth_radius) = mouth_radius - baffle_cage_mouth_clearance();
function baffle_cage_hoop_inner(mouth_radius) = baffle_cage_hoop_outer(mouth_radius) - baffle_cage_hoop_width();
// slid in until the stop meets the hoop's outside
function baffle_cage_travel(bore_radius, mouth_radius) =
  baffle_cage_outer_edge(bore_radius) - baffle_cage_stop_length() - baffle_cage_hoop_outer(mouth_radius);
// out, a bar's inner end is flush with the hoop's inside, where the half-ring's skirt bears on it
function baffle_cage_bar_tip(mouth_radius) = baffle_cage_hoop_inner(mouth_radius);
// slid in, how far the blades and their pads reach
function baffle_cage_slid_edge(bore_radius, mouth_radius) =
  baffle_cage_outer_edge(bore_radius) - baffle_cage_travel(bore_radius, mouth_radius);
function baffle_cage_slid_pad(bore_radius, mouth_radius) =
  baffle_cage_slid_edge(bore_radius, mouth_radius) + baffle_cage_pad_proud(bore_radius);
// The hoops' gap: from the end of the ramp on the dovetail's side of the blade at `from`, so the
// lip that holds the flange is backed, to the block's side of the next blade.
function baffle_cage_gap(from, step) = [from + baffle_cage_block() + baffle_cage_taper(), from + step - baffle_cage_block()];
// the bar's top, in the top hoop's frame: z 0 is its underside, where the channel opens
function baffle_cage_bar_top() = baffle_cage_channel_depth() - baffle_cage_fit();
function baffle_cage_hump_length() = 2 * baffle_cage_hump_ramp() + baffle_cage_hump_flat();
// the blade's ends, from the hoops' undersides
function baffle_cage_blade_top(top_z) = top_z + baffle_cage_bar_top();
function baffle_cage_blade_bottom(bottom_z, foot) =
  bottom_z + foot + baffle_cage_hoop_height() - baffle_cage_bar_top();
// the lowest a slid-in bottom bar reaches, its detent included, from the footing's underside
function baffle_cage_bar_low(bottom_z, foot) = baffle_cage_blade_bottom(bottom_z, foot) - baffle_cage_hump_height();
// The two half-rings run the C from the gap's end round to its start, split at the middle of the
// sector between two blades nearest the C's own middle.
function baffle_cage_lock_split(blade_at, gap_at) =
  let (
    _mid = (gap_at[1] + gap_at[0] + 360) / 2,
    _step = 360 / len(blade_at),
    _k = round((_mid - blade_at[0] - _step / 2) / _step)
  ) blade_at[0] + _step / 2 + _k * _step;
function baffle_cage_lock_arcs(blade_at, gap_at) =
  let (_s = baffle_cage_lock_split(blade_at, gap_at), _c = baffle_cage_split_clearance())
    [[gap_at[1], _s - _c], [_s + _c, gap_at[0] + 360]];
// the skirt, out to the hoop's inside less its clearance
function baffle_cage_skirt_outer(mouth_radius) = baffle_cage_hoop_inner(mouth_radius) - baffle_cage_lock_clearance();
function baffle_cage_skirt_inner(mouth_radius) = baffle_cage_skirt_outer(mouth_radius) - baffle_cage_lock_skirt();

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

// an annular arc from a0 to a1, deg
module baffle_cage_arc_2d(r0, r1, a0, a1) {
  intersection() {
    difference() { circle(r=r1); circle(r=r0); }
    polygon([[0, 0], for (a = [a0:2:a1]) 2 * r1 * [cos(a), sin(a)], 2 * r1 * [cos(a1), sin(a1)]]);
  }
}

module baffle_cage_wedge_2d(a0, a1, r) polygon([[0, 0], r * [cos(a0), sin(a0)], r * [cos(a1), sin(a1)]]);

// where each half-ring's key sits: the middle of its arc, on the band
function baffle_cage_key_at(arc) = (arc[0] + arc[1]) / 2;
// whether an angle falls on an arc, whichever turn either is written in
function baffle_cage_angle_on(a, arc) = let (_a = a + 360 * ceil((arc[0] - a) / 360)) _a <= arc[1];

// ----- the hoop -----

/**
 * @brief The top hoop in its own frame: z 0 its underside, where the channels open
 * @param ri, ro Inner and outer radius
 * @param blade_at Where the blades stand, deg
 * @param gap_at The C's gap, deg
 * @param pockets Angles of the pockets the top half-rings key into, in its top face; [] for none
 */
module baffle_cage_hoop(ri, ro, blade_at, gap_at, pockets = []) {
  h = baffle_cage_hoop_height();
  hb = baffle_cage_band_height();
  blk = baffle_cage_block();
  tp = baffle_cage_taper();
  kw = baffle_cage_key_width();

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
    }
    for (a = blade_at) rotate([0, 0, a]) rotate([90, 0, 90]) translate([0, 0, ri - 5])
      linear_extrude(ro - ri + 10) baffle_cage_channel_2d();
    // the half-rings' key pockets, in the face that prints on the bed
    for (a = pockets) rotate([0, 0, a])
      translate([ri - 1, -kw / 2, h - baffle_cage_key_depth()]) cube([baffle_cage_key_reach() + 1, kw, baffle_cage_key_depth() + 1]);
  }
}

// the bottom hoop as it sits: the top one mirrored in z, on its footing
module baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot) {
  h = baffle_cage_hoop_height();
  translate([0, 0, h + foot]) mirror([0, 0, 1]) {
    baffle_cage_hoop(ri, ro, blade_at, gap_at);
    translate([0, 0, h - z_fight]) linear_extrude(foot + z_fight) baffle_cage_ring_2d(ri, ro, gap_at);
  }
}

// ----- the half-rings -----

/**
 * @brief A top half-ring as it sits on the top hoop, in the hoop's frame: z 0 the hoop's underside
 * @param arc [from, to], deg
 * @param key [angle, radius, diameter] of the tube its arm catches, or undef when the arm is on the
 *   other half-ring or the tube's angle is outside this arc
 */
module baffle_cage_lock_top(mouth_radius, arc, key = undef) {
  h = baffle_cage_hoop_height();
  ri = baffle_cage_hoop_inner(mouth_radius);
  so = baffle_cage_skirt_outer(mouth_radius);
  si = baffle_cage_skirt_inner(mouth_radius);
  fl = baffle_cage_lock_flange();
  kw = baffle_cage_key_width();
  c = baffle_cage_lock_clearance();
  aw = baffle_cage_arm_width();
  at = baffle_cage_arm_thickness();
  fr = baffle_cage_arm_fillet();
  _arm = !is_undef(key) && baffle_cage_angle_on(key[0], arc);

  difference() {
    union() {
      // the skirt down the hoop's inside to its underside, and the flange over its top face
      linear_extrude(h + fl) baffle_cage_arc_2d(si, so, arc[0], arc[1]);
      translate([0, 0, h]) linear_extrude(fl) baffle_cage_arc_2d(si, ri + baffle_cage_lock_flange_reach(), arc[0], arc[1]);
      // the key, down into its pocket
      rotate([0, 0, baffle_cage_key_at(arc)])
        translate([si, -(kw - 2 * c) / 2, h - baffle_cage_key_depth() + c])
          cube([ri + baffle_cage_key_reach() - c - si, kw - 2 * c, baffle_cage_key_depth() - c + 0.01]);
      // the arm, flush with the flange's top, and a fillet each side where it meets the skirt
      if (_arm) {
        r0 = key[1] - baffle_cage_arm_reach();
        cc = [sqrt((si - fr) ^ 2 - (aw / 2 + fr) ^ 2), aw / 2 + fr];
        translate([0, 0, h + fl - at]) linear_extrude(at) rotate(key[0]) {
          translate([r0, -aw / 2]) square([si - r0 + 1, aw]);
          for (s = [0, 1]) mirror([0, s]) difference() {
            intersection() { translate([cc[0], aw / 2]) square([si, fr]); circle(r=si + 0.5); }
            translate(cc) circle(r=fr, $fn=48);
          }
        }
      }
    }
    // the tube's slot, open toward the axis, its lead-in on the arm's upper face where the tube
    // comes down
    if (_arm) {
      r0 = key[1] - baffle_cage_arm_reach();
      r1 = key[1] + key[2] / 2 + 1;
      w = key[2] + 4 * baffle_cage_fit();
      ld = baffle_cage_lead();
      rotate([0, 0, key[0]]) translate([0, 0, h + fl]) mirror([0, 0, 1]) {
        hull() {
          translate([r0 - ld, -w / 2 - ld, -1]) cube([r1 - r0 + ld, w + 2 * ld, 1]);
          translate([r0, -w / 2, ld - 0.01]) cube([r1 - r0, w, 0.01]);
        }
        translate([r0 - 1, -w / 2, -1]) cube([r1 - r0 + 1, w, at + 2]);
      }
    }
  }
}

/**
 * @brief A bottom half-ring as it sits on the bottom hoop's band, in that hoop's frame: z 0 the
 *   footing's underside. Its flange is cut clear of each block and its ramps, which key it.
 */
module baffle_cage_lock_bottom(mouth_radius, blade_at, arc, foot) {
  h = baffle_cage_hoop_height();
  hb = baffle_cage_band_height();
  ri = baffle_cage_hoop_inner(mouth_radius);
  so = baffle_cage_skirt_outer(mouth_radius);
  si = baffle_cage_skirt_inner(mouth_radius);
  fl = baffle_cage_lock_flange();
  sk = baffle_cage_lock_bottom_skirt();
  band_top = foot + hb;
  clear = baffle_cage_block() + baffle_cage_taper() + 1;

  translate([0, 0, band_top - sk]) linear_extrude(sk + fl) baffle_cage_arc_2d(si, so, arc[0], arc[1]);
  translate([0, 0, band_top]) linear_extrude(fl) difference() {
    baffle_cage_arc_2d(si, ri + baffle_cage_lock_flange_reach(), arc[0], arc[1]);
    for (a = blade_at) difference() {
      baffle_cage_wedge_2d(a - clear, a + clear, 4 * ri);
      circle(r=so);
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
  fl = baffle_cage_flange();
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
  sl = baffle_cage_stop_length();
  h = baffle_cage_hoop_height();
  ri = baffle_cage_hoop_inner(mouth_radius);
  z_bt = baffle_cage_blade_top(top_z);
  z_bb = baffle_cage_blade_bottom(bottom_z, foot);
  b_ref = bottom_z + foot + h; // the bottom hoop's channel mouth, its frame's z 0 mirrored
  // the detent sits just inside the hoop's inside with the blade slid in to its stop
  hump_at = ri - baffle_cage_hump_play() - hl + baffle_cage_travel(bore_radius, mouth_radius);

  // a profile in (r, z) made into a piece of the plate
  module in_plate(y0 = -tb / 2, y1 = tb / 2) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
  module bar() rotate([90, 0, 90]) translate([0, 0, r_tip]) linear_extrude(r_out - r_tip) baffle_cage_bar_2d();
  module hump() in_plate(-tb / 2, tb / 2 + fl)
    polygon([[hump_at, bt - 0.01], [hump_at + hr, bt + hh], [hump_at + hl - hr, bt + hh], [hump_at + hl, bt - 0.01]]);
  // the stop: the flange carried out past the channel's width over the bar's last `sl`
  module stop() translate([r_out - sl, tb / 2 + fl - 0.01, baffle_cage_flange_start() + fl])
    cube([sl, baffle_cage_stop_proud() + 0.01, bt - baffle_cage_flange_start() - fl]);
  // the corner at p, between a bar running inward and the blade's inner edge running away in dz
  module corner_fillet(p, dz) difference() {
    translate([p[0] - rf, dz > 0 ? p[1] : p[1] - rf]) square([rf + 0.01, rf]);
    translate([p[0] - rf, p[1] + dz * rf]) circle(r=rf, $fn=48);
  }

  translate([r_in, -tb / 2, z_bb]) cube([r_out - r_in, tb, z_bt - z_bb]);
  translate([0, 0, top_z]) { bar(); hump(); stop(); }
  translate([0, 0, b_ref]) mirror([0, 0, 1]) { bar(); hump(); stop(); }
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
 * @param key [angle, radius, diameter] of the tube the top half-rings' arm catches
 * @param slide How far every blade is slid in, 0 to baffle_cage_travel()
 * @param locked Whether the half-rings are in, which only goes with the blades out
 * @param part "cage", or a print file: "hoop_top", "hoop_bottom", "blade", "lock_top_<i>",
 *   "lock_bottom_<i>"
 */
module baffle_cage(bore_radius, mouth_radius, blade_at, gap_at, top_z, bottom_z, foot, key, slide = 0, locked = true, part = "cage") {
  ri = baffle_cage_hoop_inner(mouth_radius);
  ro = baffle_cage_hoop_outer(mouth_radius);
  h = baffle_cage_hoop_height();
  fl = baffle_cage_lock_flange();
  arcs = baffle_cage_lock_arcs(blade_at, gap_at);
  pockets = [for (a = arcs) baffle_cage_key_at(a)];
  assert(gap_at[0] < gap_at[1], "baffle_cage: the gap runs from the lower angle to the higher");
  assert(slide >= 0 && slide <= baffle_cage_travel(bore_radius, mouth_radius), "baffle_cage: a blade slides between out and its travel in");
  assert(!locked || slide == 0, "baffle_cage: the half-rings go in with the blades out");

  if (part == "cage") {
    translate([0, 0, top_z]) baffle_cage_hoop(ri, ro, blade_at, gap_at, pockets);
    translate([0, 0, bottom_z]) baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot);
    for (a = blade_at) rotate([0, 0, a]) translate([-slide, 0, 0])
      baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot);
    if (locked) for (a = arcs) {
      translate([0, 0, top_z]) baffle_cage_lock_top(mouth_radius, a, key);
      translate([0, 0, bottom_z]) baffle_cage_lock_bottom(mouth_radius, blade_at, a, foot);
    }
  }
  // Both hoops print channels up, so the lip's underside is a 45 deg overhang: the top one turned
  // over, its pockets on the bed, the bottom one as it sits. The dovetail is on one side only, so
  // they are two parts, mirror images, not one turned over.
  else if (part == "hoop_top") translate([0, 0, h]) rotate([180, 0, 0]) baffle_cage_hoop(ri, ro, blade_at, gap_at, pockets);
  else if (part == "hoop_bottom") baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot);
  // flat, the flange up
  else if (part == "blade")
    rotate([90, 0, 0])
      translate([-baffle_cage_bar_tip(mouth_radius), baffle_cage_thickness() / 2, -baffle_cage_bar_low(bottom_z, foot)])
        baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot);
  // the half-rings print flange down, skirt up
  else if (part == "lock_top_0" || part == "lock_top_1")
    translate([0, 0, h + fl]) rotate([180, 0, 0]) baffle_cage_lock_top(mouth_radius, arcs[part == "lock_top_0" ? 0 : 1], key);
  else if (part == "lock_bottom_0" || part == "lock_bottom_1")
    translate([0, 0, foot + baffle_cage_band_height() + fl]) rotate([180, 0, 0])
      baffle_cage_lock_bottom(mouth_radius, blade_at, arcs[part == "lock_bottom_0" ? 0 : 1], foot);
  else assert(false, str("baffle_cage: no part named \"", part, "\""));
}

baffle_cage(bore_radius, mouth_radius, blade_at, gap_at, top_z, bottom_z, foot, key, slide, locked && slide == 0, part);
