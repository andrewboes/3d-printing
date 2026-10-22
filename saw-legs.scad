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

/* [Wheel arms] */
show_arms = true;
// Checked = arms on the outside of the band (wheels near the corners), unchecked = inside
arms_outside = true;
// Unchecked = parked (saw on its feet). Checked = rolling (pedals down, saw lifted)
rolling = false;
// Which arms to show (more coming later)
show_front_arm = true;
show_right_arm = true;
// Which way the pinwheel turns, seen from above
pinwheel_counterclockwise = true;
// Longest the arms can be; each arm is shortened automatically to clear its neighbor
arm_length = 20;
// Arm cross-section (hardwood)
arm_thickness = 1.5;
arm_height = 3.5;
// Pivot bolt distance from the corner end of the arm
arm_pivot_from_end = 1.75;
// Pivot bolt diameter
pivot_bolt_dia = 0.375;
// Wheel (caster) center distance from the pivot bolt
caster_from_pivot = 3;
// How far the wheels lift the saw
lift_height = 0.5;
// Wheel clearance off the floor when parked
park_clearance = 0.25;
// Pivot block: hardwood block glued and screwed to the band at each pivot, so the pivot
// bolt has solid wood around it above the top of the band
pivot_block_thickness = 0.75;
pivot_block_length = 4;
// Gap (washers) between pivot block and arm
pivot_gap = 0.125;

/* [Casters] */
// Floor to top of mounting plate (MEASURED)
caster_height = 4.675;
// Mounting plate, along the arm (GUESS)
caster_plate_length = 3.125;
// Mounting plate, across the arm (GUESS)
caster_plate_width = 2.625;
// Wheel diameter (MEASURED)
caster_wheel_dia = 3;
// Wheel width (GUESS)
caster_wheel_width = 1.25;

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

// ---------- Wheel arms ----------
// Pinwheel layout: one arm on the inside of each side of the band. Each arm's pivot
// and wheel are near one corner; the pedal end points toward the next corner.

lift = rolling ? lift_height : 0;

// Arm angle when parked: pedal end up, wheel raised by lift + clearance
park_angle = asin((lift_height + park_clearance) / caster_from_pivot);
arm_angle = rolling ? 0 : park_angle;

// Pivot height in the saw's frame (saw on its feet). When rolling the arm is level
// and the caster plate sits at caster_height.
pivot_z = caster_height + arm_height / 2 - lift_height;

// Distance from the band's inside face to the arm's band-side face
arm_standoff = pivot_block_thickness + pivot_gap;

// Pivot block: its corner-side end sits 1/8 in past the leg flange; the pivot is 1 1/4 in
// from that end and 1 1/4 in below the block's top
block_pivot_edge = 1.25;
block_top_z = pivot_z + block_pivot_edge;

// Where the leg's flange ends along each side of the band, checked at the top of the
// pivot block (the legs lean in and widen going up, so that's where they reach farthest)
flange_end_x = width_at(block_top_z) / 2 - flange_at(block_top_z);   // along front/back boards
flange_end_y = depth_at(block_top_z) / 2 - flange_at(block_top_z);   // along side boards

// Inside: far end of each arm stops 1/4 in short of the next arm's inside face
far_limit_front = band_in_x - arm_standoff - caster_plate_width - 0.25;
far_limit_side = band_in_y - arm_standoff - caster_plate_width - 0.25;

// Pivot position along each side (distance from the center of the saw), and arm lengths.
// Inside: the pivot block has to start past the leg.
// Outside: the pivot bolt goes through the band just past the leg, so its nut and washer
// on the inside of the band clear the leg and are easy to reach.
nut_clearance = 0.625;   // washer radius plus 1/8 in
pivot_along_front = arms_outside ? flange_end_x - nut_clearance
                                 : flange_end_x - 0.125 - block_pivot_edge;
pivot_along_side = arms_outside ? flange_end_y - nut_clearance
                                : flange_end_y - 0.125 - block_pivot_edge;
arm_len_front = min(arm_length, pivot_along_front + arm_pivot_from_end
                                + (arms_outside ? band_out_w / 2 - 0.25 : far_limit_front));
arm_len_side = min(arm_length, pivot_along_side + arm_pivot_from_end
                               + (arms_outside ? band_out_d / 2 - 0.25 : far_limit_side));

// Band face the arms mount to (distance from the center of the saw)
face_front = arms_outside ? band_out_d / 2 : band_in_y;
face_side = arms_outside ? band_out_w / 2 : band_in_x;
// +1 = arm sits toward the saw's center from the band, -1 = arm sits outside the band
arm_dir = arms_outside ? -1 : 1;

// One arm in its own frame: pivot at origin, arm points +X, band is toward -Y.
// The caster pad is glued to the far face of the arm so the plate clears the pivot block.
module arm_local(len) {
    u0 = -arm_pivot_from_end;
    // Pivot block (fixed to the band, does not swing)
    color("SaddleBrown")
        translate([-block_pivot_edge, -arm_standoff, band_z0 - pivot_z])
            cube([pivot_block_length, pivot_block_thickness, block_top_z - band_z0]);
    // Pivot bolt: head on the arm, runs through the block and the band,
    // washer and nut on the other side of the band
    back = -arm_standoff - lumber_thickness;   // far face of the band
    color("Silver") {
        translate([0, back - 0.45, 0]) rotate([-90, 0, 0])
            cylinder(d = pivot_bolt_dia, h = -back + 0.45 + arm_thickness, $fn = 16);
        translate([0, arm_thickness, 0]) rotate([-90, 0, 0])
            cylinder(d = pivot_bolt_dia * 1.8, h = 0.25, $fn = 6);           // head
        translate([0, back - 0.08, 0]) rotate([-90, 0, 0])
            cylinder(d = 1, h = 0.08, $fn = 24);                             // washer
        translate([0, back - 0.41, 0]) rotate([-90, 0, 0])
            cylinder(d = pivot_bolt_dia * 1.8, h = 0.33, $fn = 6);           // nut
    }
    // Swinging parts
    rotate([0, -arm_angle, 0]) {
        color("Tan")
            translate([u0, 0, -arm_height / 2]) cube([len, arm_thickness, arm_height]);
        // Caster pad
        color("Tan")
            translate([caster_from_pivot - caster_plate_length / 2 - 0.25, arm_thickness, -arm_height / 2])
                cube([caster_plate_length + 0.5, caster_plate_width - arm_thickness, 1.5]);
        translate([caster_from_pivot, caster_plate_width / 2, -arm_height / 2]) caster();
    }
}

// Swivel caster hanging from its mounting plate (origin = top center of plate)
module caster() {
    h = caster_height;
    r = caster_wheel_dia / 2;
    color("Silver") {
        translate([-caster_plate_length / 2, -caster_plate_width / 2, -0.12])
            cube([caster_plate_length, caster_plate_width, 0.12]);
        translate([0, 0, -0.5]) cylinder(d = 1.75, h = 0.38, $fn = 24);
        // Fork
        for (s = [-1, 1])
            translate([-0.6, s * (caster_wheel_width / 2 + 0.06) - 0.05, -(h - r)])
                cube([1.2, 0.1, h - r - 0.5]);
    }
    color("DimGray")
        translate([0, 0, -(h - r)]) rotate([90, 0, 0])
            cylinder(r = r, h = caster_wheel_width, center = true, $fn = 32);
}

// Place an arm on side k (0 = front, 1 = right, 2 = back, 3 = left)
module place_arm(k) {
    d = pinwheel_counterclockwise ? 1 : -1;
    front_back = (k % 2 == 0);
    face = front_back ? face_front : face_side;
    along = front_back ? pivot_along_front : pivot_along_side;
    len = front_back ? arm_len_front : arm_len_side;
    // Sides: counterclockwise turns front -> right -> back -> left.
    // Outside arms are mirrored so the band is on their inner side.
    rotate([0, 0, d * k * 90])
        translate([-d * along, -face + arm_dir * arm_standoff, pivot_z])
            scale([d, arm_dir, 1]) arm_local(len);
}

module wheel_arms() {
    if (show_front_arm) place_arm(0);
    if (show_right_arm) place_arm(pinwheel_counterclockwise ? 1 : 3);
}

// Wheel positions (rolling), for stance check. Front wheel, then right/left side wheel.
wf = [-pivot_along_front + caster_from_pivot, -face_front + arm_dir * (arm_standoff + caster_plate_width / 2)];
ws0 = [-pivot_along_side + caster_from_pivot, -face_side + arm_dir * (arm_standoff + caster_plate_width / 2)];
ws = [-ws0[1], ws0[0]];   // rotate 90 degrees onto the right side
function edge_dist(a, b) = abs(a[0] * b[1] - b[0] * a[1]) / norm(b - a);
stance = 2 * min(edge_dist(wf, ws), edge_dist(ws, -wf));
pedal_rise = (arm_len_side - arm_pivot_from_end) * sin(park_angle);

echo(str("ARMS: front/back arms = ", arm_len_front, " in long, side arms = ", arm_len_side, " in long"));
echo(str("ARMS: parked angle = ", park_angle, " deg, pedal end rises ", pedal_rise, " in (side arm)"));
echo(str("ARMS: pedal leverage front = ", (arm_len_front - arm_pivot_from_end) / caster_from_pivot,
         ":1, side = ", (arm_len_side - arm_pivot_from_end) / caster_from_pivot, ":1"));
echo(str("STANCE: narrowest width on wheels = ", stance, " in (on its feet: ", min(floor_width, floor_depth), " in)"));

// ---------- Assembly ----------

translate([0, 0, lift]) {
    stand();
    if (show_band) wood_band();
    if (show_arms) wheel_arms();
    if (show_saw) saw();
}

// Floor reference
color("LightGray", 0.3) translate([-25, -20, -0.02]) cube([50, 40, 0.02]);
