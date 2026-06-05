// =====================================================================
// Can Opener Holder  (2 x 5 cells = 84 x 209.5 mm)
//
// Holds a single-piece can opener laid flat: wing-knob end at the back
// (high Y), long ergonomic handle running toward the front (low Y).
//
// Layout (top-down, looking +Z down at the bin):
//
//                     +Y (back)
//   +X (right)
//
//   +-------------+  Y=OUTER_Y
//   |   _______   |
//   |  /       \  |  <- WING KNOB (wide, at the back)
//   |  |       |  |
//   |   \-----/   |
//   |     |  |    |
//   |     |  |    |
//   |     |  |    |  <- HANDLE (narrow, running toward front)
//   |     |  |    |
//   |     |  |    |
//   |     |__|    |
//   |             |
//   +-------------+  Y=0
//      X=0    X=OUTER_X
// =====================================================================


// ====================== EDIT ME (mm) =================================
// Replace placeholder values with your measurements.

// --- WING KNOB (the wide butterfly/wing piece at the top) ---
WING_WID            = 74;    // X dimension (across the bin)
WING_LEN            = 28;    // Y dimension (along the bin)
WING_THK            = 43;    // Z thickness (cavity depth at the knob)

// --- HANDLE (the long ergonomic body below the knob) ---
HANDLE_WID          = 32;    // X dimension
HANDLE_LEN          = 175;   // Y dimension
HANDLE_THK          = 17;    // Z thickness

// --- FIT / BUILD ---
CAVITY_CLEAR        = 0.6;
WALL                = 1.6;
FLOOR               = 1.6;

// --- FINE TUNING ---
OPENER_X_SHIFT      = 0;     // shift cavity in X
OPENER_Y_SHIFT      = 0;     // shift cavity in Y
OPENER_ROTATE       = 0;     // degrees (CCW from above)

// Override the cavity depth. Default 0 = auto (= max of WING_THK and
// HANDLE_THK, a snug fit but a tall bin). Set a smaller value to make
// the pocket shallower so the wing knob sticks up proud of the bin.
CAVITY_DEPTH_OVERRIDE = 20;

$fn                 = 64;


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

CAVITY_DEPTH = (CAVITY_DEPTH_OVERRIDE > 0)
             ? CAVITY_DEPTH_OVERRIDE
             : max(WING_THK, HANDLE_THK);
BODY_H = CAVITY_DEPTH + FLOOR;


// ====================== MAIN =========================================
difference() {
    union() {
        feet();
        bin_body();
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
// 2 across by 5 deep = 10 standard feet
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


// ====================== CAVITIES =====================================
// Single tapered cavity for the opener body (hull of wing-knob rectangle
// + handle rectangle).
module cavities() {
    z_top        = FOOT_H + BODY_H;
    cavity_depth = CAVITY_DEPTH;

    // Y positions: handle at the front, wing knob behind it
    handle_y_start = WALL;
    handle_y_end   = handle_y_start + HANDLE_LEN;
    wing_y_center  = handle_y_end + WING_LEN/2;
    wing_y_end     = handle_y_end + WING_LEN;

    // X positions: both centered along the bin
    x_center = OUTER_X / 2 + OPENER_X_SHIFT;

    // Rotation pivot: where the handle meets the wing knob
    pivot_y = handle_y_end;

    // ---- Main cavity (hull of handle + wing knob) ----
    translate([0, OPENER_Y_SHIFT, z_top - cavity_depth])
        translate([x_center, pivot_y, 0])
            rotate([0, 0, OPENER_ROTATE])
                translate([-x_center, -pivot_y, 0])
                    linear_extrude(height = cavity_depth + 0.1)
                        hull() {
                            // Handle: long narrow rectangle
                            translate([x_center, (handle_y_start + handle_y_end)/2])
                                offset(r = 2)
                                    square([HANDLE_WID + 2*CAVITY_CLEAR - 4,
                                            HANDLE_LEN - 4],
                                           center = true);
                            // Wing knob: wide rectangle
                            translate([x_center, wing_y_center])
                                offset(r = 2)
                                    square([WING_WID + 2*CAVITY_CLEAR - 4,
                                            WING_LEN + 2*CAVITY_CLEAR - 4],
                                           center = true);
                        }
}
