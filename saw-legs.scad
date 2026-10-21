// Powermatic 64 table saw - existing leg stand (reference model)
// All units are INCHES. Values marked GUESS need to be measured.
// Axes: X = left/right, Y = front/back (front is -Y), Z = up. Origin = floor, center of footprint.

/* [Leg footprint] */
// Front-to-back, center of foot to center of foot, at the floor (MEASURED)
floor_depth = 23.5;
// Side-to-side, center of foot to center of foot, at the floor (MEASURED)
floor_width = 20;
// Front-to-back, at the top of the legs, OUTSIDE corner to OUTSIDE corner (GUESS)
top_depth = 19;
// Side-to-side, at the top of the legs, OUTSIDE corner to OUTSIDE corner (GUESS)
top_width = 16;
// Straight up from the floor to the top of the legs, not along the slant (GUESS)
leg_height = 25;

/* [Leg shape] */
// Width of each side of the L-shaped leg (GUESS)
leg_flange = 1.5;
// Metal thickness (GUESS, about 14 gauge)
leg_thickness = 0.075;

/* [Feet] */
// true = flat pad at the bottom of each leg, false = bare leg end (GUESS)
has_foot_pad = true;
// Pad size, square. Must fit inside the L: no bigger than leg_flange - leg_thickness (GUESS)
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
// Lowest point of the saw body between the legs, floor to bottom (GUESS)
saw_body_bottom = 25;
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

// Outside-corner spread at the floor (feet sit inside the L, so corners are farther out)
corner_width = floor_width + 2 * foot_inset;
corner_depth = floor_depth + 2 * foot_inset;

// Outside-corner spread at height z (legs flare linearly from top to floor)
function width_at(z) = corner_width + (top_width - corner_width) * z / leg_height;
function depth_at(z) = corner_depth + (top_depth - corner_depth) * z / leg_height;

// L-shaped angle profile, corner at the origin, flanges along +X and +Y
module angle_profile() {
    square([leg_flange, leg_thickness]);
    square([leg_thickness, leg_flange]);
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
                linear_extrude(leg_height) angle_profile();
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
        translate([-saw_body_width / 2, -saw_body_depth / 2, saw_body_bottom])
            cube([saw_body_width, saw_body_depth, table_height - table_thickness - saw_body_bottom]);
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

// ---------- Assembly ----------

stand();
if (show_saw) saw();

// Floor reference
color("LightGray", 0.3) translate([-25, -20, -0.02]) cube([50, 40, 0.02]);
