// =====================================================================
// Can Opener Holder  (2 x 5 cells = 84 x 209.5 mm)
//
// Starting from scratch: just a Gridfinity 2x5 bin body with feet.
// Cutouts get added one at a time below.
// =====================================================================


// ====================== EDIT ME ======================================
BODY_H              = 23;    // height of the bin body above the feet
WALL                = 1.6;
FLOOR               = 1.6;
$fn                 = 64;

// --- HANDLE (rectangular cutout in the middle of the bin) ---
HANDLE_WID          = 35;    // X dimension
HANDLE_LEN          = 180;   // Y dimension
HANDLE_THK          = 17;    // cavity depth (Z)
HANDLE_RADIUS       = 4;     // corner radius
HANDLE_X_CENTER     = 44;    // X position of cavity center
HANDLE_Y_CENTER     = 100;   // Y position of cavity center

// --- RING (circular cutout in the top-right of the bin) ---
RING_DIA            = 40;    // diameter
RING_THK            = 17;    // cavity depth (Z)
RING_X_FROM_RIGHT   = 23;    // distance from the right wall to ring center
RING_Y_FROM_BACK    = 45;    // distance from the back wall to ring center

// --- BUTTERFLY HANDLE (rectangular cutout, rounded corners) ---
BUTTERFLY_WID       = 33;    // X dimension
BUTTERFLY_LEN       = 85;    // Y dimension
BUTTERFLY_THK       = 17;    // cavity depth (Z)
BUTTERFLY_RADIUS    = 9;     // corner radius
BUTTERFLY_X_CENTER  = 19;    // X position of cavity center
BUTTERFLY_Y_CENTER  = 165;   // Y position of cavity center

CAVITY_CLEAR        = 0.6;


// ====================== GRIDFINITY CONSTANTS =========================
PITCH       = 42;
CELLS_X     = 2;
CELLS_Y     = 5;
OUTER_X     = CELLS_X * PITCH - 0.5;        // 83.5
OUTER_Y     = CELLS_Y * PITCH - 0.5;        // 209.5
CORNER_R    = 4;

FOOT_H1     = 0.8;
FOOT_H2     = 1.8;
FOOT_H3     = 2.15;
FOOT_H      = FOOT_H1 + FOOT_H2 + FOOT_H3;


// ====================== MAIN =========================================
difference() {
    union() {
        feet();
        bin_body();
    }
    handle_cutout();
    ring_cutout();
    butterfly_cutout();
}


// ====================== CUTOUTS ======================================
// Rectangular cutout for the handle (positioned via HANDLE_X/Y_CENTER).
module handle_cutout() {
    z_top = FOOT_H + BODY_H;
    translate([HANDLE_X_CENTER, HANDLE_Y_CENTER, z_top - HANDLE_THK])
        linear_extrude(height = HANDLE_THK + 0.1)
            offset(r = HANDLE_RADIUS)
                square([HANDLE_WID + 2*CAVITY_CLEAR - 2*HANDLE_RADIUS,
                        HANDLE_LEN + 2*CAVITY_CLEAR - 2*HANDLE_RADIUS],
                       center = true);
}

// Circular cutout for the ring, in the top-right (high X, high Y).
module ring_cutout() {
    z_top = FOOT_H + BODY_H;
    translate([OUTER_X - RING_X_FROM_RIGHT,
               OUTER_Y - RING_Y_FROM_BACK,
               z_top - RING_THK])
        linear_extrude(height = RING_THK + 0.1)
            circle(d = RING_DIA + 2*CAVITY_CLEAR);
}

// Rounded-rectangle cutout for the butterfly handle.
module butterfly_cutout() {
    z_top = FOOT_H + BODY_H;
    translate([BUTTERFLY_X_CENTER, BUTTERFLY_Y_CENTER, z_top - BUTTERFLY_THK])
        linear_extrude(height = BUTTERFLY_THK + 0.1)
            offset(r = BUTTERFLY_RADIUS)
                square([BUTTERFLY_WID + 2*CAVITY_CLEAR - 2*BUTTERFLY_RADIUS,
                        BUTTERFLY_LEN + 2*CAVITY_CLEAR - 2*BUTTERFLY_RADIUS],
                       center = true);
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
// 2 across by 5 deep = 10 standard Gridfinity feet
module feet() {
    for (ix = [0 : CELLS_X - 1])
        for (iy = [0 : CELLS_Y - 1])
            translate([ix*PITCH + PITCH/2,
                       iy*PITCH + PITCH/2, 0])
                rect_foot(PITCH - 0.5, PITCH - 0.5);
}

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
