/**
 * @file baffle_cage.scad
 * @brief Four wall baffles on two hoops, assembled on the bench and lowered whole through the mouth
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The standard baffle set (four baffles of width T/12, T/72 off the wall, floor to surface) for a
 * jar whose mouth is narrower than the spacing of the baffles. Two rigid hoops pass through the
 * mouth lying flat. Each blade hangs between the hoops on a radial bar at each end, and each
 * bar slides in a dovetail channel in the hoop. With the blades slid in, the cage goes down through
 * the mouth, with the hoops flexed if necessary. Inside the jar, each blade is pushed out until its
 * pads stop just short of the glass.
 *
 * The dovetails hold the cage together. The outer end of each bar is closed under the flange, so
 * it stops against the outside of the hoop and a blade cannot slide through into the middle. Three
 * humps on each bar act as detents. Each is taller than the bar clearance in its channel, so it
 * must be pushed through and clicks out the other side. With the blade out against the wall, one
 * hump sits outside the hoop and one, at the bar tip, sits inside it. Each is steep on the face
 * toward the hoop, so the blade is held in both directions. The third hump holds the blade in the
 * slid-in position. The top hoop sits above the culture and has an arm that engages a tube from
 * the lid, so the cage cannot rotate. It is C-shaped, and the probes hang in the gap. The bottom
 * hoop is the top hoop mirrored in z, on a footing, without the arm.
 *
 * A blade must match its hoops in three places: the bar section, the outer face of the hoop (where
 * the out-detent and the closed end bear), and the inner face of the hoop (where the tip detent and
 * in-detent sit). The sliding fit is set only by the hoop channel, so a hoop change that keeps
 * those faces requires reprinting only the hoops.
 *
 * DATUM: z = 0 is the floor datum the caller measures the hoops from; x, y on the jar axis.
 * Blade angles are the angular positions of the blades, the first one along +x.
 */

$fn = $preview ? 64 : 128;
z_fight = $preview ? 0.05 : 0;

/* [Preview] */

// bore radius of the jar
bore_radius = 105;
// radius of the jar mouth
mouth_radius = 71.1;
// angular positions of the blades, in degrees
blade_at = [0, 90, 180, 270];
// gap in the top hoop, start and end angle, in degrees
gap_at = [17, 81];
// height of the underside of the top hoop
top_z = 245.5;
// height of the underside of the bottom hoop footing
bottom_z = 4.3;
// height of the footing under the bottom hoop
foot = 2.2;
// tube the arm engages: angle, radius and tube diameter
key = [0, 56.5, 4];
// distance the blades are slid in, from 0 to the full travel
slide = 0;
// what to draw: the cage, hoops or blades in place, or one print file in its bed orientation
part = "cage"; // [cage, hoops, blades, hoop_top, hoop_bottom, blade]

module dummy() {
  // stop the customizer detection from here onwards
}

// ----- part dimensions -----
// The wall gap and width follow the standard. The rest are design choices with reasons given, not
// cited values.

function baffle_cage_wall_gap(bore_radius) = 2 * bore_radius / 72; // T/72, the industry standard
function baffle_cage_width(bore_radius) = 2 * bore_radius / 12; // T/12, as for the standard turbine
function baffle_cage_thickness() = 4;
// Sliding clearance in a channel, per side, set only in the hoops. At 0.15 the bottom bars of the
// first cage were loose enough to push in; a bottom hoop reprinted at 0.10 held them.
function baffle_cage_fit() = 0.10;
// clearance the blade bars are drawn to, kept separate so a fit change reprints only the hoops
function baffle_cage_bar_fit() = 0.15;
// clearance between the outer edge of each hoop and the mouth on the way down
function baffle_cage_mouth_clearance() = 1.1;
function baffle_cage_hoop_width() = 6;
function baffle_cage_hoop_height() = 10;
// the band between the blocks: full width, this tall, flush with the face that prints on the bed
function baffle_cage_band_height() = 6;
function baffle_cage_block() = 9; // half-width of the full block around each channel, deg
function baffle_cage_taper() = 8; // angle over which each block ramps down, deg
function baffle_cage_flange() = 2; // dovetail step
function baffle_cage_flange_start() = 2.5; // distance from the channel mouth where it widens
function baffle_cage_channel_depth() = 7;
function baffle_cage_tip_overlap() = 3; // distance a bar extends inside its hoop with the blade out
// gap between the pads and the glass; the cage is centred within it
function baffle_cage_pad_clearance() = 0.4;
function baffle_cage_pad_height() = 10;
function baffle_cage_pad_from_top() = 25;
function baffle_cage_pad_from_bottom() = 10;
function baffle_cage_bar_fillet() = 5;
// Detents: humps on the bar, facing the channel ceiling. They are taller than the bar clearance
// there (the fit at the ceiling plus the fit at the 45 deg lip), so each must be pushed through.
function baffle_cage_hump_height() = 0.5;
function baffle_cage_hump_ramp() = 1.5;
function baffle_cage_hump_flat() = 1;
function baffle_cage_hump_play() = 0.2; // free travel before a hump bears on its channel
// inner face of the out-detent, which a blade pushed back in must climb: 45 deg
function baffle_cage_hump_back() = baffle_cage_hump_height();
// length of the closed section under the flange at the outer end of the bar; the lip it meets
// stops the slide
function baffle_cage_stop_length() = 1.5;
// the arm: width, distance inside the tube where it starts, and root fillet radius
function baffle_cage_arm_width() = 12;
function baffle_cage_arm_reach() = 6.5;
function baffle_cage_arm_fillet() = 3;
function baffle_cage_lead() = 1.2; // lead-in around the arm slot

// ----- derived from the jar -----

function baffle_cage_outer_edge(bore_radius) = bore_radius - baffle_cage_wall_gap(bore_radius);
function baffle_cage_inner_edge(bore_radius) = baffle_cage_outer_edge(bore_radius) - baffle_cage_width(bore_radius);
function baffle_cage_pad_proud(bore_radius) = baffle_cage_wall_gap(bore_radius) - baffle_cage_pad_clearance();
function baffle_cage_hoop_outer(mouth_radius) = mouth_radius - baffle_cage_mouth_clearance();
function baffle_cage_hoop_inner(mouth_radius) = baffle_cage_hoop_outer(mouth_radius) - baffle_cage_hoop_width();
// travel: slid in until the closed end meets the outside of the hoop
function baffle_cage_travel(bore_radius, mouth_radius) =
  baffle_cage_outer_edge(bore_radius) - baffle_cage_stop_length() - baffle_cage_hoop_outer(mouth_radius);
// radial extent of the pads when slid in to the stop
function baffle_cage_slid_pad(bore_radius, mouth_radius) =
  baffle_cage_outer_edge(bore_radius) + baffle_cage_pad_proud(bore_radius) - baffle_cage_travel(bore_radius, mouth_radius);
// A blade slides freely between detents only after one detent has cleared the hoop and before the
// next one reaches it. That needs the hoop width, one hump and its play at each end. With less
// travel the bar never slides freely, so the cage cannot be built this way for that jar.
function baffle_cage_travel_min() = baffle_cage_hoop_width() + baffle_cage_hump_length() + 2 * baffle_cage_hump_play();
function baffle_cage_bar_tip(mouth_radius) = baffle_cage_hoop_inner(mouth_radius) - baffle_cage_tip_overlap();
// top of the bar, in the top hoop frame: z 0 is the hoop underside, where the channel opens
function baffle_cage_bar_top() = baffle_cage_channel_depth() - baffle_cage_bar_fit();
function baffle_cage_hump_length() = 2 * baffle_cage_hump_ramp() + baffle_cage_hump_flat();
// the arm sits above the bar and its humps, which slide in under it
function baffle_cage_arm_z() = baffle_cage_bar_top() + baffle_cage_hump_height() + baffle_cage_fit();
// ends of the blade, from the hoop undersides
function baffle_cage_blade_top(top_z) = top_z + baffle_cage_bar_top();
function baffle_cage_blade_bottom(bottom_z, foot) =
  bottom_z + foot + baffle_cage_hoop_height() - baffle_cage_bar_top();
// lowest point of a slid-in bottom bar, including its detents, from the footing underside
function baffle_cage_bar_low(bottom_z, foot) = baffle_cage_blade_bottom(bottom_z, foot) - baffle_cage_hump_height();

// parts drawn in the jar, assembled or separately, instead of as one print file on the bed
function baffle_cage_in_place(part) = part == "cage" || part == "hoops" || part == "blades";

// ----- profiles -----

// bar section (y, z) in the top hoop frame: the plate, and the dovetail flange on +y
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
 * @brief The top hoop in its own frame: z 0 is its underside, where the channels open
 * @param ri, ro Inner and outer radius
 * @param blade_at Angular positions of the blades, deg
 * @param gap_at Gap in the C, deg
 * @param key [angle, radius, diameter] of the tube the arm engages; undef for none
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
      // Each block ramps down to the band, trimmed to the curved faces of the hoop so it blends
      // into them without a seam. There is no ramp on a side where the gap of the C starts.
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
    // the tube slot, open toward the axis, with its lead-in on the upper face of the arm where the
    // tube comes down
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

// the bottom hoop in place: the top hoop mirrored in z, on its footing
module baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot) {
  h = baffle_cage_hoop_height();
  translate([0, 0, h + foot]) mirror([0, 0, 1]) {
    baffle_cage_hoop(ri, ro, blade_at, gap_at);
    translate([0, 0, h - z_fight]) linear_extrude(foot + z_fight) intersection() {
      baffle_cage_ring_2d(ri, ro, gap_at);
      // under the band and the blocks; the ramps sit on the band footprint
      circle(r=ro);
    }
  }
}

// ----- the blade -----

/**
 * @brief One blade at +x, out against the wall, in the caller's frame
 * @param top_z Underside of the top hoop
 * @param bottom_z Underside of the bottom hoop footing
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
  hk = baffle_cage_hump_back();
  hf = baffle_cage_hump_flat();
  sl = baffle_cage_stop_length();
  bt = baffle_cage_bar_top();
  h = baffle_cage_hoop_height();
  ro = baffle_cage_hoop_outer(mouth_radius);
  ri = baffle_cage_hoop_inner(mouth_radius);
  z_bt = baffle_cage_blade_top(top_z);
  z_bb = baffle_cage_blade_bottom(bottom_z, foot);
  b_ref = bottom_z + foot + h; // channel mouth of the bottom hoop, z 0 of its mirrored frame
  // out-detent: just outside the hoop with the blade out. in-detent: just inside the hoop with the
  // blade slid in. tip detent: just inside the hoop with the blade out, at the bar tip
  hump_at = [
    ro + baffle_cage_hump_play(),
    ri - baffle_cage_hump_play() - hl + baffle_cage_travel(bore_radius, mouth_radius),
    r_tip,
  ];
  tip_ramp = ri - baffle_cage_hump_play() - hk - hf - r_tip;
  assert(tip_ramp >= hh, "baffle_cage: the tip detent's ramp is steeper than its back; the bar's tip is too close to the hoop");

  // extrudes a profile in (r, z) through the plate thickness
  module in_plate(y0 = -tb / 2, y1 = tb / 2) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
  module bar() rotate([90, 0, 90]) {
    translate([0, 0, r_tip]) linear_extrude(r_out - r_tip) baffle_cage_bar_2d();
    // the closed end: the undercut under the flange is filled
    translate([0, 0, r_out - sl]) linear_extrude(sl) translate([-tb / 2, 0]) square([tb + baffle_cage_flange(), bt]);
  }
  // The out-detent is steep on its inner face, which holds the blade out. The tip detent is steep
  // on its outer face, which holds it in, and ramped toward the tip, which guides it through the
  // channel during assembly on the bench. The in-detent is symmetric.
  module humps() in_plate(-tb / 2, tb / 2 + baffle_cage_flange()) {
    polygon([[hump_at[0], bt - 0.01], [hump_at[0] + hk, bt + hh], [hump_at[0] + hk + hf, bt + hh], [hump_at[0] + hk + hf + hr, bt - 0.01]]);
    polygon([[hump_at[1], bt - 0.01], [hump_at[1] + hr, bt + hh], [hump_at[1] + hl - hr, bt + hh], [hump_at[1] + hl, bt - 0.01]]);
    polygon([[hump_at[2], bt - 0.01], [hump_at[2] + tip_ramp, bt + hh], [hump_at[2] + tip_ramp + hf, bt + hh], [hump_at[2] + tip_ramp + hf + hk, bt - 0.01]]);
  }
  // fillet for the corner at p, between a bar running inward and the inner edge of the blade
  // running away in dz
  module corner_fillet(p, dz) difference() {
    translate([p[0] - rf, dz > 0 ? p[1] : p[1] - rf]) square([rf + 0.01, rf]);
    translate([p[0] - rf, p[1] + dz * rf]) circle(r=rf, $fn=48);
  }

  translate([r_in, -tb / 2, z_bb]) cube([r_out - r_in, tb, z_bt - z_bb]);
  translate([0, 0, top_z]) { bar(); humps(); }
  translate([0, 0, b_ref]) mirror([0, 0, 1]) { bar(); humps(); }
  // pads with 45 deg ends, with a flat of pad height facing the glass
  for (z = [z_bt - baffle_cage_pad_from_top() - ph, z_bb + baffle_cage_pad_from_bottom()]) in_plate()
    polygon([[r_out - 0.01, z - pp], [r_out + pp, z], [r_out + pp, z + ph], [r_out - 0.01, z + ph + pp]]);
  in_plate() {
    corner_fillet([r_in, top_z - 1], -1);
    corner_fillet([r_in, b_ref + 1], 1);
  }
}

// ----- the cage -----

/**
 * @brief The cage in the caller's frame, or one print file in its bed orientation
 * @param bore_radius Bore radius of the jar
 * @param mouth_radius Radius of the jar mouth
 * @param blade_at Angular positions of the blades, deg
 * @param gap_at Gap in the hoops, deg: start and end angle, between two blades
 * @param top_z Underside of the top hoop
 * @param bottom_z Underside of the bottom hoop footing
 * @param foot Height of the footing
 * @param key [angle, radius, diameter] of the tube the top hoop arm engages
 * @param slide Distance every blade is slid in, 0 to baffle_cage_travel()
 * @param part "cage", or "hoop_top", "hoop_bottom", "blade" in print orientation
 */
module baffle_cage(bore_radius, mouth_radius, blade_at, gap_at, top_z, bottom_z, foot, key, slide = 0, part = "cage") {
  ri = baffle_cage_hoop_inner(mouth_radius);
  ro = baffle_cage_hoop_outer(mouth_radius);
  h = baffle_cage_hoop_height();
  assert(gap_at[0] < gap_at[1], "baffle_cage: the gap runs from the lower angle to the higher");
  assert(slide >= 0 && slide <= baffle_cage_travel(bore_radius, mouth_radius), "baffle_cage: a blade slides between out and its travel in");

  // in place, assembled or separately; separate parts are for checking one against the other
  if (baffle_cage_in_place(part)) {
    if (part != "blades") {
      translate([0, 0, top_z]) baffle_cage_hoop(ri, ro, blade_at, gap_at, key);
      translate([0, 0, bottom_z]) baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot);
    }
    if (part != "hoops")
      for (a = blade_at) rotate([0, 0, a]) translate([-slide, 0, 0])
        baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot);
  }
  // Both hoops print with the channels up, so the underside of the lip is a 45 deg overhang. The
  // top hoop is turned over with its arm on the bed; the bottom hoop prints as installed. The
  // dovetail is on one side only, so they are two mirror-image parts, not one part turned over.
  else if (part == "hoop_top") translate([0, 0, h]) rotate([180, 0, 0]) baffle_cage_hoop(ri, ro, blade_at, gap_at, key);
  else if (part == "hoop_bottom") baffle_cage_hoop_bottom(ri, ro, blade_at, gap_at, foot);
  // flat, flange up
  else if (part == "blade")
    rotate([90, 0, 0])
      translate([-baffle_cage_bar_tip(mouth_radius), baffle_cage_thickness() / 2, -baffle_cage_bar_low(bottom_z, foot)])
        baffle_cage_blade(bore_radius, mouth_radius, top_z, bottom_z, foot);
  else assert(false, str("baffle_cage: no part named \"", part, "\""));
}

baffle_cage(bore_radius, mouth_radius, blade_at, gap_at, top_z, bottom_z, foot, key, slide, part);
