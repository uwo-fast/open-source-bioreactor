/**
 * @file baffle_cage.scad
 * @brief Four wall baffles on two hoops, built on the bench and lowered into the jar whole
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The standard baffle set - four at T/12, T/72 off the wall, floor to surface - on a jar whose
 * mouth is narrower than the blades are apart. Two C-shaped hoops carry a radial lug at each blade,
 * and each blade hangs between them on a radial bar at each end that slides in a dovetail channel
 * in the lug. The channel is closed at its inner end: slid in against it, the blade is wholly
 * inside the lugs' reach, and the hoops are bent to pass the mouth. Inside the jar each blade is
 * pushed out until a tooth on its bar snaps up into a window in the lug, which holds it there with
 * its pads just short of the glass.
 *
 * The dovetail holds the cage together. The tooth's outer face is square, so it stops the blade
 * going further out; its inner face is 45 deg, so a firm push in releases it. The top hoop stands
 * above the culture, and an arm on one lug catches a tube from the lid, so the cage cannot turn.
 * The hoops' gap is where the probes hang. The bottom hoop is the top one mirrored in z.
 *
 * DATUM: z = 0 is the floor datum the caller measures the hoops from; x, y on the jar's axis.
 * Blade angles are where the blades stand, the first one along +x.
 */

$fn = $preview ? 64 : 128;
z_fight = $preview ? 0.05 : 0;

/* [Preview] */

// the jar's bore radius
bore_radius = 105;
// the radius the lugs and channels start at, clear of the lid's tubes
inner_radius = 60;
// where the blades stand, in degrees
blade_at = [0, 90, 180, 270];
// the hoops' gap, from and to, in degrees
gap_at = [17, 81];
// height of the top hoop's underside
top_z = 240.5;
// height of the bottom hoop's underside
bottom_z = 4.6;
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
function baffle_cage_hoop_height() = 10;
// the band joining the lugs: its radial width, and this tall, flush with the face that prints on
// the bed
function baffle_cage_band_width() = 6;
function baffle_cage_band_height() = 6;
function baffle_cage_lug_width() = 14;
function baffle_cage_lug_fillet() = 3; // where a lug meets the band, in plan
function baffle_cage_end_wall() = 2; // closing each channel's inner end
// how much of a bar stays in its channel with the blade out
function baffle_cage_engagement() = 6;
// how far inside the lugs' reach a slid-in blade's pads stop
function baffle_cage_retract_margin() = 0.5;
function baffle_cage_flange() = 2; // the dovetail's step
function baffle_cage_flange_start() = 2.5; // where it starts to widen, off the channel's mouth
function baffle_cage_channel_depth() = 7;
// the pads stop this far off the glass; the cage is centred within it
function baffle_cage_pad_clearance() = 0.4;
function baffle_cage_pad_height() = 10;
function baffle_cage_pad_from_top() = 25;
function baffle_cage_pad_from_bottom() = 10;
function baffle_cage_bar_fillet() = 5;
// The tooth: a finger cut along the bar's edge toward the channel's ceiling, the tooth on its free
// end, which is toward the bar's tip. Slid in, the ceiling holds it down; out, it springs up into
// a window through the ceiling.
function baffle_cage_finger_length() = 15;
function baffle_cage_finger_thickness() = 2;
function baffle_cage_finger_slit() = 0.8;
function baffle_cage_finger_from_tip() = 2; // bar left beyond the finger's free end
function baffle_cage_tooth_height() = 0.8;
function baffle_cage_tooth_flat() = 1.5;
function baffle_cage_window_play() = 0.3; // the window's length over the tooth's, toward the tip
// the arm on the top hoop's key lug: its width, how far inboard of the tube it reaches
function baffle_cage_arm_width() = 12;
function baffle_cage_arm_reach() = 6.5;
function baffle_cage_lead() = 1.2; // the lead-in round the arm's slot

// ----- derived from the jar -----

function baffle_cage_outer_edge(bore_radius) = bore_radius - baffle_cage_wall_gap(bore_radius);
function baffle_cage_inner_edge(bore_radius) = baffle_cage_outer_edge(bore_radius) - baffle_cage_width(bore_radius);
function baffle_cage_pad_proud(bore_radius) = baffle_cage_wall_gap(bore_radius) - baffle_cage_pad_clearance();
function baffle_cage_pad_reach(bore_radius) = baffle_cage_outer_edge(bore_radius) + baffle_cage_pad_proud(bore_radius);
// where a channel's closed end stops a bar's tip
function baffle_cage_channel_end(inner_radius) = inner_radius + baffle_cage_end_wall();
// The lug reaches out until a blade slid in to the channel's end is wholly inside it, by the
// margin, and, out, still has `engagement` of bar in the channel: travel = pad reach + margin -
// lug, and the tip out at channel end + travel must sit `engagement` inside the lug.
function baffle_cage_lug_outer(bore_radius, inner_radius) =
  (baffle_cage_pad_reach(bore_radius) + baffle_cage_retract_margin() + baffle_cage_channel_end(inner_radius) + baffle_cage_engagement()) / 2;
function baffle_cage_travel(bore_radius, inner_radius) =
  baffle_cage_pad_reach(bore_radius) + baffle_cage_retract_margin() - baffle_cage_lug_outer(bore_radius, inner_radius);
// out, the bar's tip
function baffle_cage_bar_tip(bore_radius, inner_radius) =
  baffle_cage_channel_end(inner_radius) + baffle_cage_travel(bore_radius, inner_radius);
function baffle_cage_band_inner(inner_radius) = inner_radius + baffle_cage_end_wall() + 2;
function baffle_cage_band_outer(inner_radius) = baffle_cage_band_inner(inner_radius) + baffle_cage_band_width();
// The hoops' gap: from `lip_backing` of band past the lug and its fillet on the dovetail's side of
// the blade at `from`, so the lip that holds the flange has the band behind it, to the lug and its
// fillet on the next blade's other side. Angles at the band's inside.
function baffle_cage_lip_backing() = 8;
function baffle_cage_gap(from, step, inner_radius) =
  let (_side = baffle_cage_lug_width() / 2 + baffle_cage_lug_fillet(), _r = baffle_cage_band_inner(inner_radius))
    [from + asin((_side + baffle_cage_lip_backing()) / _r), from + step - asin(_side / _r)];
// the bar's top, in the top hoop's frame: z 0 is its underside, where the channel opens
function baffle_cage_bar_top() = baffle_cage_channel_depth() - baffle_cage_fit();
// the blade's ends, from the hoops' undersides
function baffle_cage_blade_top(top_z) = top_z + baffle_cage_bar_top();
function baffle_cage_blade_bottom(bottom_z) = bottom_z + baffle_cage_hoop_height() - baffle_cage_bar_top();
// out, where the tooth's square face stands: the window's outer edge
function baffle_cage_tooth_at(bore_radius, inner_radius) =
  baffle_cage_bar_tip(bore_radius, inner_radius) + baffle_cage_finger_from_tip() + baffle_cage_tooth_height() + baffle_cage_tooth_flat();

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

module baffle_cage_wedge_2d(a0, a1, r) polygon([[0, 0], for (a = [a0:2:a1]) r * [cos(a), sin(a)], r * [cos(a1), sin(a1)]]);

// the band, a C, and a lug at each blade with a fillet each side where it meets the band
module baffle_cage_hoop_2d(inner_radius, ro, blade_at, gap_at, band = true, lugs = true) {
  bi = baffle_cage_band_inner(inner_radius);
  bo = baffle_cage_band_outer(inner_radius);
  lw = baffle_cage_lug_width();
  fr = baffle_cage_lug_fillet();
  difference() {
    union() {
      if (band) difference() { circle(r=bo); circle(r=bi); }
      if (lugs) for (a = blade_at) rotate(a) {
        translate([inner_radius, -lw / 2]) square([ro - inner_radius, lw]);
        // fillets in the four corners a lug makes with the band, inside and out
        for (s = [1, -1], r = [bi, bo]) let (o = r == bo ? 1 : -1)
          mirror([0, s < 0 ? 1 : 0]) difference() {
            translate([r - (o > 0 ? 1 : fr), lw / 2]) square([fr + 1, fr]); // into the band, past its curve
            translate([r + o * fr, lw / 2 + fr]) circle(r=fr, $fn=48);
          }
      }
    }
    baffle_cage_wedge_2d(gap_at[0], gap_at[1], 2 * ro);
  }
}

// ----- the hoop -----

/**
 * @brief The top hoop in its own frame: z 0 its underside, where the channels open
 * @param key [angle, radius, diameter] of the tube its arm catches, or undef for none
 */
module baffle_cage_hoop(bore_radius, inner_radius, blade_at, gap_at, key = undef) {
  h = baffle_cage_hoop_height();
  hb = baffle_cage_band_height();
  ro = baffle_cage_lug_outer(bore_radius, inner_radius);
  fit = baffle_cage_fit();
  ce = baffle_cage_channel_end(inner_radius);
  tb = baffle_cage_thickness();
  fl = baffle_cage_flange();
  aw = baffle_cage_arm_width();
  ta = baffle_cage_tooth_at(bore_radius, inner_radius);
  wl = baffle_cage_tooth_height() + baffle_cage_tooth_flat() + baffle_cage_window_play();

  difference() {
    union() {
      translate([0, 0, h - hb]) linear_extrude(hb) baffle_cage_hoop_2d(inner_radius, ro, blade_at, gap_at, lugs=false);
      linear_extrude(h) baffle_cage_hoop_2d(inner_radius, ro, blade_at, gap_at, band=false);
      // the arm, on the lug at the tube's angle, reaching in round the tube
      if (!is_undef(key)) rotate(key[0]) translate([key[1] - baffle_cage_arm_reach(), -aw / 2, 0])
        cube([inner_radius - key[1] + baffle_cage_arm_reach() + 1, aw, h]);
    }
    // each channel, from the lug's outside in to its closed end
    for (a = blade_at) rotate([0, 0, a]) {
      rotate([90, 0, 90]) translate([0, 0, ce]) linear_extrude(ro - ce + 1) baffle_cage_channel_2d();
      // the window the tooth snaps up into, through the ceiling, across the bar and its flange
      translate([ta - wl, -tb / 2 - fit, baffle_cage_channel_depth() - 0.01]) cube([wl, tb + fl + 2 * fit, h]);
    }
    // the tube's slot, open toward the axis, with a lead-in on the face the tube comes down through
    if (!is_undef(key)) {
      r0 = key[1] - baffle_cage_arm_reach();
      r1 = key[1] + key[2] / 2 + 1;
      w = key[2] + 4 * fit;
      ld = baffle_cage_lead();
      rotate([0, 0, key[0]]) translate([0, 0, h]) mirror([0, 0, 1]) {
        hull() {
          translate([r0 - ld, -w / 2 - ld, -1]) cube([r1 - r0 + ld, w + 2 * ld, 1]);
          translate([r0, -w / 2, ld - 0.01]) cube([r1 - r0, w, 0.01]);
        }
        translate([r0 - 1, -w / 2, -1]) cube([r1 - r0 + 1, w, h + 2]);
      }
    }
  }
}

// the bottom hoop as it sits: the top one mirrored in z, without the arm
module baffle_cage_hoop_bottom(bore_radius, inner_radius, blade_at, gap_at) {
  translate([0, 0, baffle_cage_hoop_height()]) mirror([0, 0, 1]) baffle_cage_hoop(bore_radius, inner_radius, blade_at, gap_at);
}

// ----- the blade -----

/**
 * @brief One blade at +x, out against the wall, in the caller's frame
 * @param top_z The top hoop's underside
 * @param bottom_z The bottom hoop's underside
 */
module baffle_cage_blade(bore_radius, inner_radius, top_z, bottom_z) {
  tb = baffle_cage_thickness();
  fl = baffle_cage_flange();
  r_out = baffle_cage_outer_edge(bore_radius);
  r_in = baffle_cage_inner_edge(bore_radius);
  r_tip = baffle_cage_bar_tip(bore_radius, inner_radius);
  pp = baffle_cage_pad_proud(bore_radius);
  ph = baffle_cage_pad_height();
  rf = baffle_cage_bar_fillet();
  bt = baffle_cage_bar_top();
  h = baffle_cage_hoop_height();
  z_bt = baffle_cage_blade_top(top_z);
  z_bb = baffle_cage_blade_bottom(bottom_z);
  b_ref = bottom_z + h; // the bottom hoop's channel mouth, its frame's z 0 mirrored
  // the finger, along the bar's top edge, its free end toward the tip
  f0 = r_tip + baffle_cage_finger_from_tip();
  f1 = f0 + baffle_cage_finger_length();
  ft = baffle_cage_finger_thickness();
  fs = baffle_cage_finger_slit();
  th = baffle_cage_tooth_height();
  ta = baffle_cage_tooth_at(bore_radius, inner_radius);

  // a profile in (r, z) made into a piece of the bar, across the plate and its flange
  module in_bar() translate([0, tb / 2 + fl, 0]) rotate([90, 0, 0]) linear_extrude(tb + fl) children();
  module in_plate() translate([0, tb / 2, 0]) rotate([90, 0, 0]) linear_extrude(tb) children();
  module bar() difference() {
    union() {
      rotate([90, 0, 90]) translate([0, 0, r_tip]) linear_extrude(r_out - r_tip) baffle_cage_bar_2d();
      // the tooth on the finger's free end: 45 deg toward the tip, square toward the blade
      in_bar() polygon([[f0, bt - 0.01], [f0 + th, bt + th], [ta, bt + th], [ta, bt - 0.01]]);
    }
    // the slit under the finger, and across its free end
    in_bar() {
      translate([f0, bt - ft - fs]) square([f1 - f0, fs]);
      translate([f0 - fs, bt - ft - fs]) square([fs, ft + fs + 1]);
    }
  }
  // the corner at p, between a bar running inward and the blade's inner edge running away in dz
  module corner_fillet(p, dz) difference() {
    translate([p[0] - rf, dz > 0 ? p[1] : p[1] - rf]) square([rf + 0.01, rf]);
    translate([p[0] - rf, p[1] + dz * rf]) circle(r=rf, $fn=48);
  }

  translate([r_in, -tb / 2, z_bb]) cube([r_out - r_in, tb, z_bt - z_bb]);
  translate([0, 0, top_z]) bar();
  translate([0, 0, b_ref]) mirror([0, 0, 1]) bar();
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
 * @param inner_radius Where the lugs and channels start
 * @param blade_at Where the blades stand, deg
 * @param gap_at The hoops' gap, deg: from and to, between two blades
 * @param top_z The top hoop's underside
 * @param bottom_z The bottom hoop's underside
 * @param key [angle, radius, diameter] of the tube the top hoop's arm catches
 * @param slide How far every blade is slid in, 0 to baffle_cage_travel()
 * @param part "cage", or a print file: "hoop_top", "hoop_bottom", "blade"
 */
module baffle_cage(bore_radius, inner_radius, blade_at, gap_at, top_z, bottom_z, key, slide = 0, part = "cage") {
  h = baffle_cage_hoop_height();
  assert(gap_at[0] < gap_at[1], "baffle_cage: the gap runs from the lower angle to the higher");
  assert(slide >= 0 && slide <= baffle_cage_travel(bore_radius, inner_radius), "baffle_cage: a blade slides between out and its travel in");

  if (part == "cage") {
    translate([0, 0, top_z]) baffle_cage_hoop(bore_radius, inner_radius, blade_at, gap_at, key);
    translate([0, 0, bottom_z]) baffle_cage_hoop_bottom(bore_radius, inner_radius, blade_at, gap_at);
    for (a = blade_at) rotate([0, 0, a]) translate([-slide, 0, 0]) baffle_cage_blade(bore_radius, inner_radius, top_z, bottom_z);
  }
  // Both hoops print channels up, so the lip's underside is a 45 deg overhang: the top one turned
  // over, the bottom one as it sits. The dovetail is on one side only, so they are two parts,
  // mirror images, not one turned over.
  else if (part == "hoop_top") translate([0, 0, h]) rotate([180, 0, 0]) baffle_cage_hoop(bore_radius, inner_radius, blade_at, gap_at, key);
  else if (part == "hoop_bottom") baffle_cage_hoop_bottom(bore_radius, inner_radius, blade_at, gap_at);
  // flat, the flange and the teeth up
  else if (part == "blade")
    rotate([90, 0, 0])
      translate([-baffle_cage_bar_tip(bore_radius, inner_radius), baffle_cage_thickness() / 2, -baffle_cage_blade_bottom(bottom_z) - 1])
        baffle_cage_blade(bore_radius, inner_radius, top_z, bottom_z);
  else assert(false, str("baffle_cage: no part named \"", part, "\""));
}

baffle_cage(bore_radius, inner_radius, blade_at, gap_at, top_z, bottom_z, key, slide, part);
