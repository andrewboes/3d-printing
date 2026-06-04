// =====================================================================
// Cheese Grater Holder  (6 wide x 0.5 deep)
//
// Holds a paddle grater on its long edge in a half-cell strip, with a
// cradle at one end supporting the handle so the grater stays upright.
//
// Layout (top-down):
//
//   +Y
//    +-------------------------------------------------+
//    |  ===== paddle slot =====        [ cradle ]      |
//    +-------------------------------------------------+ +X
//
// The paddle slot cuts straight through the body AND the feet to the
// baseplate pocket bottom -- this gains ~4.75 mm of vertical room so
// the 85 mm paddle fits in the 87 mm drawer.
//
// Edit the grater dimensions below after measuring with your caliper.
// =====================================================================


// ====================== EDIT ME (all values in mm) ===================

// --- PADDLE (the grating blade) ---
PADDLE_LEN          = 150;   // long axis (along +X)
PADDLE_WIDTH        = 85;    // short axis -- vertical when stored
PADDLE_THICK        = 4;     // blade thickness

// --- HANDLE (extends past the paddle in +X) ---
HANDLE_LEN          = 124;   // length past the paddle end
HANDLE_WID          = 26;    // wider oval dimension (vertical when stored)
HANDLE_THK          = 7;     // narrower oval dimension (horizontal)

// Height of the handle's bottom edge above the paddle's bottom edge.
// If the handle is centered on the paddle's width, this is roughly
// (PADDLE_WIDTH - HANDLE_WID) / 2.
HANDLE_OFFSET_Z     = 28;

// --- FIT / BUILD ---
PADDLE_SLOT_CLEAR   = 1;     // total extra width on the paddle slot
HANDLE_CLEAR        = 0.6;   // clearance around the handle in the cradle
BODY_H              = 6;     // height of bin body above baseplate top
CRADLE_X_WIDTH      = 14;    // X length of the cradle post
SLOT_LEAD_IN        = 1.5;   // chamfer at the top of the paddle slot

WALL                = 1.6;

// --- FINE TUNING ---
PADDLE_X_SHIFT      = 0;     // shift paddle slot along X
CRADLE_X_OFFSET     = 0;     // shift cradle inward from the right wall

$fn                 = 64;


// ====================== GRIDFINITY CONSTANTS =========================
PITCH       = 42;
CELLS_X     = 6;
CELLS_Y     = 0.5;
OUTER_X     = CELLS_X * PITCH - 0.5;        // 251.5
OUTER_Y     = CELLS_Y * PITCH - 0.5;        // 20.5
CORNER_R    = 4;

// Foot profile (total 4.75 mm)
FOOT_H1     = 0.8;
FOOT_H2     = 1.8;
FOOT_H3     = 2.15;
FOOT_H      = FOOT_H1 + FOOT_H2 + FOOT_H3;


// ====================== MAIN =========================================
difference() {
    union() {
        feet();
        bin_body();
        handle_cradle();
    }
    cavities();
}


// ====================== BIN BODY =====================================
module bin_body() {
    translate([0, 0, FOOT_H])
        rounded_box(OUTER_X, OUTER_Y, BODY_H, CORNER_R);
}

module rounded_box(w, d, h, r) {
    translate([w/2, d/2, 0])
        linear_extrude(height = h)
            offset(r = r) square([w - 2*r, d - 2*r], center = true);
}


// ====================== FEET =========================================
// Row of half-feet across the half-cell strip. The paddle slot will
// later cut these in half, leaving two narrow strips per foot.
module feet() {
    half_y_size = CELLS_Y * PITCH - 0.5;     // 20.5
    for (ix = [0 : CELLS_X - 1])
        translate([ix*PITCH + PITCH/2, OUTER_Y/2, 0])
            rect_foot(PITCH - 0.5, half_y_size);
}

// Rectangular Gridfinity foot. Standard chamfered profile.
module rect_foot(top_x, top_y) {
    bot_x = top_x - 2*(FOOT_H1 + FOOT_H3);
    bot_y = top_y - 2*(FOOT_H1 + FOOT_H3);
    mid_x = top_x - 2*FOOT_H3;
    mid_y = top_y - 2*FOOT_H3;
    bot_r = max(CORNER_R - (FOOT_H1 + FOOT_H3), 0.5);
    mid_r = max(CORNER_R - FOOT_H3, 0.5);

    linear_extrude(height = FOOT_H1, scale = [mid_x/bot_x, mid_y/bot_y])
        offset(r = bot_r) square([bot_x - 2*bot_r, bot_y - 2*bot_r], center = true);

    translate([0, 0, FOOT_H1])
        linear_extrude(height = FOOT_H2)
            offset(r = mid_r) square([mid_x - 2*mid_r, mid_y - 2*mid_r], center = true);

    translate([0, 0, FOOT_H1 + FOOT_H2])
        linear_extrude(height = FOOT_H3, scale = [top_x/mid_x, top_y/mid_y])
            offset(r = mid_r) square([mid_x - 2*mid_r, mid_y - 2*mid_r], center = true);
}


// ====================== HANDLE CRADLE =================================
// A solid post at the right end. The cavities module will cut an oval
// saddle into the top so the handle drops in from above.
module handle_cradle() {
    post_w_x = CRADLE_X_WIDTH;
    post_w_y = OUTER_Y - 2*WALL;
    post_x_center = OUTER_X - WALL - post_w_x/2 - CRADLE_X_OFFSET;

    handle_z_center = FOOT_H + BODY_H + HANDLE_OFFSET_Z + HANDLE_WID/2;
    post_z_top      = handle_z_center;     // saddle holds lower half
    post_z_bot      = FOOT_H;
    post_h          = post_z_top - post_z_bot;

    translate([post_x_center, OUTER_Y/2, post_z_bot + post_h/2])
        cube([post_w_x, post_w_y, post_h], center = true);
}


// ====================== CAVITIES =====================================
module cavities() {
    // ---- Paddle slot (through body AND feet, down to pocket bottom) ----
    slot_w = PADDLE_THICK + PADDLE_SLOT_CLEAR;
    slot_l = PADDLE_LEN + 2;
    slot_x_center = WALL + slot_l/2 + PADDLE_X_SHIFT;
    slot_y_center = OUTER_Y/2;

    // Main slot: full Z extent (cut feet in half too)
    translate([slot_x_center, slot_y_center, (FOOT_H + BODY_H)/2])
        cube([slot_l, slot_w, FOOT_H + BODY_H + 2], center = true);

    // Lead-in chamfer at the top of the slot for easier insertion
    if (SLOT_LEAD_IN > 0)
        translate([slot_x_center, slot_y_center, FOOT_H + BODY_H])
            linear_extrude(height = SLOT_LEAD_IN, scale = 1)
                square([slot_l, slot_w + 2*SLOT_LEAD_IN], center = true);

    // ---- Handle saddle (oval channel along X, open at the top) ----
    post_w_x = CRADLE_X_WIDTH;
    post_x_center = OUTER_X - WALL - post_w_x/2 - CRADLE_X_OFFSET;
    handle_z_center = FOOT_H + BODY_H + HANDLE_OFFSET_Z + HANDLE_WID/2;

    // Oval tube along X with cross-section HANDLE_WID (Z) x HANDLE_THK (Y).
    // Center of the oval is at z = handle_z_center. The post ends at this
    // z, so the upper half of the oval is in free space -- the lower half
    // gets subtracted, leaving an oval notch open at the top.
    translate([post_x_center, OUTER_Y/2, handle_z_center])
        rotate([0, 90, 0])
            linear_extrude(height = post_w_x + 2, center = true)
                scale([HANDLE_WID/2 + HANDLE_CLEAR,
                       HANDLE_THK/2 + HANDLE_CLEAR])
                    circle(r = 1);
}
