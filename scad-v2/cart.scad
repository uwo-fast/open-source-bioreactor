/**
 * @file cart.scad
 * @brief Rolling cart for the open-source-bioreactor setup
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A two-tier rolling cart built from NopSCADlib aluminium extrusion, joined
 * with 3D corner brackets and rolling on four swivel plate castors. It holds
 * four bioreactors: two per tier, arranged one in front of the other (along X).
 *
 * Layout (looking down):
 *
 *     +X (depth / front-back)
 *     ^   +---------+
 *     |   |  o   o  |   two bioreactors per tier, front-to-back
 *     |   +---------+
 *     +-------------> +Y (width)
 *
 * Frame topology: four vertical corner posts tied together by three horizontal
 * rectangles of rails - a bottom tier, a middle tier, and a top brace. Each of
 * the twelve rail corners is fastened with a 3D corner bracket; the castors bolt
 * to the underside of the four posts.
 */

include <NopSCADlib/core.scad>; // core utils (also silences the inch() warning)
include <NopSCADlib/vitamins/extrusions.scad>; // extrusion types + extrusion()
include <NopSCADlib/vitamins/extrusion_brackets.scad>; // 3D corner bracket + screws

include <purchased/castors.scad>; // swivel plate castor vitamin

$fn = $preview ? 48 : 96;

/* [Part Render Selection] */

render_frame = true;
render_castors = true;
// translucent bioreactor envelopes, to check the fit
show_bioreactors = true;

/* [Bioreactor Envelope] */

// outer diameter of one bioreactor (matches vessel_outer_diameter)
bioreactor_diameter = 220;
// full height of one bioreactor unit (vessel + head + frame)
bioreactor_height = 450;
// clearance around a bioreactor on every side
side_clearance = 20;
// vertical gap above a bioreactor before the next tier
tier_gap = 60;

/* [Frame] */

// extrusion profile and matching 3D corner bracket (must be the same size)
cart_extrusion = E3030;
cart_bracket = extrusion_corner_bracket_3D_3030;

module dummy() {
  // stop the customizer detection from here onwards
}

// --- derived geometry -------------------------------------------------------

ew = extrusion_width(cart_extrusion);

// interior the frame must enclose: 2 bioreactors deep (X), 1 wide (Y)
inner_x = 2 * bioreactor_diameter + 3 * side_clearance;
inner_y = bioreactor_diameter + 2 * side_clearance;

// post centreline positions (posts sit just outside the interior)
post_cx = inner_x / 2 + ew / 2;
post_cy = inner_y / 2 + ew / 2;

// rails run between the post inner faces
rail_x = 2 * post_cx - ew;
rail_y = 2 * post_cy - ew;

// tier heights: bottom rail, middle rail, top brace
tier_height = bioreactor_height + tier_gap;
z_bottom = ew / 2; // bottom rail centre sits flush with the post base
z_middle = z_bottom + tier_height;
z_top = z_middle + tier_height;

z_post_bottom = 0;
z_post_top = z_top + ew / 2;
post_len = z_post_top - z_post_bottom;

// bioreactor centres: two along X, centred on Y
bio_x = (bioreactor_diameter + side_clearance) / 2;

corners = [[-1, -1], [1, -1], [1, 1], [-1, 1]];

// Z-rotation that aligns the bracket's native (+X, -Y) arms with the inward
// rail directions at corner (sx, sy). Top corners additionally mirror in Z.
function corner_angle(sx, sy) = sx < 0 ? (sy > 0 ? 0 : 90) : (sy < 0 ? 180 : 270);

echo("cart footprint (mm): ", [2 * post_cx + ew, 2 * post_cy + ew]);
echo("cart height incl. castor (mm): ", post_len + castor_mount_height(generic_castor));

// --- modules ----------------------------------------------------------------

// one horizontal rectangle of rails at height z
module rail_rectangle(z) {
  for (sy = [-1, 1]) // rails along X (depth), on each Y side
    translate([0, sy * post_cy, z]) rotate([0, 90, 0]) extrusion(cart_extrusion, rail_x);
  for (sx = [-1, 1]) // rails along Y (width), on each X end
    translate([sx * post_cx, 0, z]) rotate([90, 0, 0]) extrusion(cart_extrusion, rail_y);
}

module cart() {

  if (render_frame) {
    // four vertical corner posts
    for (c = corners)
      translate([c[0] * post_cx, c[1] * post_cy, (z_post_bottom + z_post_top) / 2])
        extrusion(cart_extrusion, post_len);

    // three tiers of rails
    rail_rectangle(z_bottom);
    rail_rectangle(z_middle);
    rail_rectangle(z_top);

    // corner brackets: arms up at the two lower tiers, arms down at the top
    for (c = corners) {
      angle = corner_angle(c[0], c[1]);
      for (z = [z_bottom, z_middle])
        translate([c[0] * post_cx, c[1] * post_cy, z])
          rotate([0, 0, angle]) extrusion_corner_bracket_3D(cart_bracket);
      translate([c[0] * post_cx, c[1] * post_cy, z_top])
        mirror([0, 0, 1]) rotate([0, 0, angle]) extrusion_corner_bracket_3D(cart_bracket);
    }
  }

  // four swivel castors under the posts
  if (render_castors)
    for (c = corners)
      translate([c[0] * post_cx, c[1] * post_cy, z_post_bottom])
        castor(generic_castor, swivel=corner_angle(c[0], c[1]));

  // translucent bioreactor envelopes resting on the two lower tiers
  if (show_bioreactors)
    for (sx = [-1, 1], z = [z_bottom, z_middle])
      color("SeaGreen", alpha=0.15)
        translate([sx * bio_x, 0, z + ew / 2])
          cylinder(d=bioreactor_diameter, h=bioreactor_height);
}

cart();
