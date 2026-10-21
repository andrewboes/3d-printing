// Powermatic 64 table saw - existing leg stand (reference model)
// All units are INCHES. Values marked GUESS need to be measured.
// Axes: X = left/right, Y = front/back (front is -Y), Z = up. Origin = floor, center of footprint.

/* [Leg footprint] */
// Front-to-back, center of foot to center of foot, at the floor (MEASURED)
floor_depth = 23.5;
// Side-to-side, center of foot to center of foot, at the floor (MEASURED)
floor_width = 20;
// Front-to-back, at the top of the legs, OUTSIDE corner to OUTSIDE corner (MEASURED)
top_depth = 20.75;
// Side-to-side, at the top of the legs, OUTSIDE corner to OUTSIDE corner (MEASURED)
top_width = 17;
// Straight up from the floor to the top of the legs, not along the slant (MEASURED)
leg_height = 21.75;

/* [Leg shape] */
// The legs taper. Width of each side of the L at the TOP of the leg (MEASURED)
leg_flange_top = 3.5;
// Width of each side of the L at the BOTTOM of the leg (MEASURED)
leg_flange_bottom = 1.75;
// Metal thickness (GUESS, about 14 gauge)
leg_thickness = 0.075;

/* [Feet] */
// true = flat pad at the bottom of each leg, false = bare leg end (GUESS)
has_foot_pad = true;
// Pad size, square. Must fit inside the L: no bigger than leg_flange_bottom - leg_thickness (GUESS)
foot_pad_size = 1.375;
// Pad thickness (GUESS)
foot_pad_thickness = 0.25;
// Bolt hole diameter in the pad, 0 = no hole (GUESS)
foot_hole_dia = 0.3125;

// The pad sits completely inside the L, tucked against the inside faces of the metal.
// Distance from the leg's outside corner to the center of the pad, along one side.
foot_inset = leg_thickness + foot_pad_size / 2;

/* [Cross braces] */
// Height of the lower braces off the floor, center of brace (GUESS)
brace_height = 7;
// Brace width, vertical (GUESS)
brace_width = 1.5;
// Which sides have a lower brace (GUESS)
brace_front = true;
brace_back = true;
brace_left = true;
brace_right = true;
// Top apron band around the top of the stand (GUESS)
has_top_apron = true;
apron_width = 2;

/* [Wood band] */
show_band = true;
// Height of the middle of the 2x4s off the floor, at the existing square hole (MEASURED)
band_center_height = 4.5;
// Lumber thickness (2x4 actual size)
lumber_thickness = 1.5;
// Lumber width, standing on edge (2x4 actual size)
lumber_width = 3.5;
// Thinnest point of each shim, at the bottom of the band
shim_min = 0.125;
// Carriage bolt diameter
bolt_dia = 0.375;
// Distance from the leg's outside corner to the bolt hole, along the flange. 0 = centered on the flange (GUESS)
bolt_offset = 0;
// true = square holes on both sides of each leg, false = front/back sides only (GUESS)
bolts_both_faces = true;

/* [Saw body (context)] */
show_saw = true;
// Floor to the top of the cast-iron table (GUESS, typical is 34)
table_height = 34;
// Main cast-iron top, side-to-side (GUESS)
table_width = 27;
// Main cast-iron top, front-to-back (GUESS)
table_depth = 27;
// Table thickness (GUESS)
table_thickness = 1.5;
// Lowest point of the saw body, floor to bottom. 0 = sits right on top of the legs
saw_body_bottom = 0;
// Saw body (trunnion housing) size under the table (GUESS)
saw_body_width = 18;
saw_body_depth = 18;

/* [Extension and router table (context)] */
// Width of extension wing + router table combined, added to one side (GUESS)
extension_width = 20;
// Which side the extension is on: 1 = right, -1 = left (GUESS)
extension_side = 1;

/* [Motor (context)] */
// How far the motor sticks out past the back legs, measured at the floor line (GUESS)
motor_overhang = 10;
// Floor to the bottom of the motor (GUESS)
motor_bottom = 18;
// Motor diameter (GUESS)
motor_dia = 7;
// Motor length, side-to-side (GUESS)
motor_length = 11;

$fn = 32;

// ---------- Geometry helpers ----------

// Saw body bottom: on top of the legs unless set by hand
body_bottom = saw_body_bottom > 0 ? saw_body_bottom : leg_height;

// Outside-corner spread at the floor (feet sit inside the L, so corners are farther out)
corner_width = floor_width + 2 * foot_inset;
corner_depth = floor_depth + 2 * foot_inset;

// Outside-corner spread at height z (legs flare linearly from top to floor)
function width_at(z) = corner_width + (top_width - corner_width) * z / leg_height;
function depth_at(z) = corner_depth + (top_depth - corner_depth) * z / leg_height;

// Tapered L-shaped angle, corner at the origin, flanges along +X and +Y.
// Each side tapers from leg_flange_bottom at the floor to leg_flange_top at the top.
module tapered_angle(h) {
    t = leg_thickness;
    e = 0.001;
    hull() {
        cube([leg_flange_bottom, t, e]);
        translate([0, 0, h - e]) cube([leg_flange_top, t, e]);
    }
    hull() {
        cube([t, leg_flange_bottom, e]);
        translate([0, 0, h - e]) cube([t, leg_flange_top, e]);
    }
}

// One leg at corner (sx, sy), each +1 or -1. The L corner sits on the outside,
// and the foot pad sits inside the L.
module leg(sx, sy) {
    foot = [sx * floor_width / 2, sy * floor_depth / 2, 0];
    corner = [sx * corner_width / 2, sy * corner_depth / 2, 0];
    dx = sx * (top_width - corner_width) / 2;
    dy = sy * (top_depth - corner_depth) / 2;
    translate(corner)
        multmatrix([[1, 0, dx / leg_height, 0],
                    [0, 1, dy / leg_height, 0],
                    [0, 0, 1, 0]])
            scale([-sx, -sy, 1])
                tapered_angle(leg_height);
    if (has_foot_pad)
        translate(foot) foot_pad();
}

module foot_pad() {
    difference() {
        translate([-foot_pad_size / 2, -foot_pad_size / 2, 0])
            cube([foot_pad_size, foot_pad_size, foot_pad_thickness]);
        if (foot_hole_dia > 0)
            translate([0, 0, -0.1]) cylinder(d = foot_hole_dia, h = foot_pad_thickness + 0.2);
    }
}

// Flat band around the stand, centered at height z
module band(z, w, front, back, left, right) {
    W = width_at(z);
    D = depth_at(z);
    t = leg_thickness;
    if (front) translate([-W / 2, -D / 2, z - w / 2]) cube([W, t, w]);
    if (back)  translate([-W / 2, D / 2 - t, z - w / 2]) cube([W, t, w]);
    if (left)  translate([-W / 2, -D / 2, z - w / 2]) cube([t, D, w]);
    if (right) translate([W / 2 - t, -D / 2, z - w / 2]) cube([t, D, w]);
}

module stand() {
    color("DimGray") {
        for (sx = [-1, 1], sy = [-1, 1]) leg(sx, sy);
        band(brace_height, brace_width, brace_front, brace_back, brace_left, brace_right);
        if (has_top_apron)
            band(leg_height - apron_width / 2, apron_width, true, true, true, true);
    }
}

module saw() {
    // Saw body (trunnion housing) between stand and table
    color("SlateGray", 0.6)
        translate([-saw_body_width / 2, -saw_body_depth / 2, body_bottom])
            cube([saw_body_width, saw_body_depth, table_height - table_thickness - body_bottom]);
    // Main cast-iron table
    color("Silver", 0.7)
        translate([-table_width / 2, -table_depth / 2, table_height - table_thickness])
            cube([table_width, table_depth, table_thickness]);
    // Extension wing + router table
    color("BurlyWood", 0.7)
        translate([extension_side > 0 ? table_width / 2 : -table_width / 2 - extension_width,
                   -table_depth / 2, table_height - table_thickness])
            cube([extension_width, table_depth, table_thickness]);
    // Motor hanging off the back
    color("SteelBlue", 0.7)
        translate([0, floor_depth / 2 + motor_overhang - motor_dia / 2, motor_bottom + motor_dia / 2])
            rotate([0, 90, 0]) cylinder(d = motor_dia, h = motor_length, center = true);
}

// ---------- Wood band ----------

band_z0 = band_center_height - lumber_width / 2;   // bottom of the 2x4s
band_z1 = band_center_height + lumber_width / 2;   // top of the 2x4s

// Width of each side of the L at height z
function flange_at(z) = leg_flange_bottom + (leg_flange_top - leg_flange_bottom) * z / leg_height;

// Inside faces of the band (distance from center). The legs lean in going up, so the
// band touches the shim's thin end at the bottom and the shims thicken toward the top.
band_in_x = width_at(band_z0) / 2 + shim_min;
band_in_y = depth_at(band_z0) / 2 + shim_min;
band_out_w = 2 * (band_in_x + lumber_thickness);
band_out_d = 2 * (band_in_y + lumber_thickness);

// Shim thickness at the top of the band
shim_max_front = band_in_y - depth_at(band_z1) / 2;
shim_max_side = band_in_x - width_at(band_z1) / 2;

// Lean angle of the legs
lean_front = atan((corner_depth - top_depth) / 2 / leg_height);
lean_side = atan((corner_width - top_width) / 2 / leg_height);

function bolt_pos() = bolt_offset > 0 ? bolt_offset : flange_at(band_center_height) / 2;

// Front and back boards run the full outside width; side boards fit between them
module band_boards() {
    color("BurlyWood") {
        for (sy = [-1, 1])
            translate([-band_out_w / 2, sy > 0 ? band_in_y : -band_in_y - lumber_thickness, band_z0])
                cube([band_out_w, lumber_thickness, lumber_width]);
        for (sx = [-1, 1])
            translate([sx > 0 ? band_in_x : -band_in_x - lumber_thickness, -band_in_y, band_z0])
                cube([lumber_thickness, 2 * band_in_y, lumber_width]);
    }
}

// Wedge shim between a leg's front/back face and the front/back board
module shim_front(sx, sy) {
    w = flange_at(band_center_height);
    xc = sx * width_at(band_center_height) / 2;
    e = 0.001;
    color("Peru")
        hull()
            for (z = [band_z0, band_z1 - e]) {
                t = band_in_y - depth_at(z) / 2;
                translate([min(xc, xc - sx * w), sy > 0 ? depth_at(z) / 2 : -band_in_y, z])
                    cube([w, t, e]);
            }
}

// Wedge shim between a leg's side face and the side board
module shim_side(sx, sy) {
    w = flange_at(band_center_height);
    yc = sy * depth_at(band_center_height) / 2;
    e = 0.001;
    color("Peru")
        hull()
            for (z = [band_z0, band_z1 - e]) {
                t = band_in_x - width_at(z) / 2;
                translate([sx > 0 ? width_at(z) / 2 : -band_in_x, min(yc, yc - sy * w), z])
                    cube([t, w, e]);
            }
}

// Carriage bolt: head inside the leg, nut outside the 2x4
module carriage_bolt(len) {
    color("Silver") {
        cylinder(d = bolt_dia, h = len, $fn = 16);
        translate([0, 0, -0.2]) cylinder(d = bolt_dia * 2.2, h = 0.2, $fn = 24);
    }
}

module band_bolts() {
    zc = band_center_height;
    for (sx = [-1, 1], sy = [-1, 1]) {
        // Through the front/back face of the leg
        translate([sx * (width_at(zc) / 2 - bolt_pos()), sy * (depth_at(zc) / 2 - leg_thickness), zc])
            rotate([sy > 0 ? -90 : 90, 0, 0])
                carriage_bolt(band_in_y - depth_at(zc) / 2 + lumber_thickness + 0.6);
        // Through the side face of the leg
        if (bolts_both_faces)
            translate([sx * (width_at(zc) / 2 - leg_thickness), sy * (depth_at(zc) / 2 - bolt_pos()), zc])
                rotate([0, sx > 0 ? 90 : -90, 0])
                    carriage_bolt(band_in_x - width_at(zc) / 2 + lumber_thickness + 0.6);
    }
}

module wood_band() {
    band_boards();
    for (sx = [-1, 1], sy = [-1, 1]) {
        shim_front(sx, sy);
        shim_side(sx, sy);
    }
    band_bolts();
}

// Cut list, printed in the OpenSCAD console
echo(str("BAND: front/back boards (2) = ", band_out_w, " in long"));
echo(str("BAND: side boards (2) = ", 2 * band_in_y, " in long"));
echo(str("BAND: outside size = ", band_out_w, " x ", band_out_d, " in"));
echo(str("SHIMS front/back (4): ", shim_min, " in at bottom to ", shim_max_front, " in at top, ",
         flange_at(band_center_height), " in wide, lean ", lean_front, " deg"));
echo(str("SHIMS sides (4): ", shim_min, " in at bottom to ", shim_max_side, " in at top, ",
         flange_at(band_center_height), " in wide, lean ", lean_side, " deg"));

// ---------- Assembly ----------

stand();
if (show_band) wood_band();
if (show_saw) saw();

// Floor reference
color("LightGray", 0.3) translate([-25, -20, -0.02]) cube([50, 40, 0.02]);
