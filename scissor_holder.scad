// =====================================================================
// Scissors Holder  (L-shape: 2x2 handles + 1x3 blades = 7 cells)
//
// Sits to the LEFT of the Peeler Holder. Holds the scissors laid flat,
// rings (handle loops) at the front, blades pointing to the back. The
// RIGHT handle ring is centered on the boundary between this bin and
// the peeler bin -- half the ring's cavity is in this file, the other
// half is in peeler_holder.scad.
//
// Layout (top-down, looking +Z down at the bin):
//
//                          +Y (back)
//   +X (right)
//
//   +-----+               <- back of blade column (single col, 1x3)
//   |blade|
//   | tip |
//   |-----|
//   |     |
//   |blade|
//   |     |
//   |-----|
//   |pivot|               <- pivot screw area
//   +-----+-----+         <- handle area starts (2x2)
//   |     |     |
//   | LH  | RH  |         <- left & right handle rings
//   |ring | ring|            (right ring half-overhangs into peeler bin)
//   |     |     |
//   +-----+-----+         Y=0
//
// =====================================================================


// ====================== EDIT ME (mm) =================================
// Replace placeholder values with your measurements.

// --- SCISSORS (closed, laying flat) ---
// Total overall, ring-bottom to blade-tip:
SCISSOR_TOTAL_LEN       = 208;

// Ring (one of the two finger loops):
SCISSOR_RING_OUTER_W    = 42;    // outer width across the ring (X direction)
SCISSOR_RING_OUTER_L    = 77;    // outer length of the ring (Y direction)
SCISSOR_RING_GAP        = 5;     // gap between the two rings, edge to edge
SCISSOR_RING_THK        = 14;    // handle thickness at the ring (cavity depth)

// Pivot screw (the metal stud where the two halves connect):
SCISSOR_PIVOT_FROM_RING = 118;    // distance from ring-bottom (Y=0) to pivot center
SCISSOR_PIVOT_DIA       = 16;    // diameter around the screw head
SCISSOR_PIVOT_THK       = 14;    // scissor thickness at the pivot

// Blades (closed):
// SCISSOR_BLADE_LEN is auto-derived: SCISSOR_TOTAL_LEN - SCISSOR_PIVOT_FROM_RING
SCISSOR_BLADE_W_TIP     = 5;     // combined blade width at the tip
SCISSOR_BLADE_THK       = 6;     // blade pair thickness (closed)

// --- LAYOUT ---
// Which X-column holds the blade strip?
//   true  = blade in the LEFT column of the handle area
//   false = blade in the RIGHT column
BLADE_COL_LEFT          = false;

// --- FINE TUNING ---
// Nudge / rotate the scissor cavity. Rotation pivots around the pivot
// screw position (SCISSOR_PIVOT_FROM_RING along Y, between rings on X).
SCISSOR_X_SHIFT         = -1;    // mm to shift cavity in X
SCISSOR_Y_SHIFT         = 0;     // mm to shift cavity in Y
SCISSOR_ROTATE          = -8;     // degrees (CCW viewed from above)

// --- FIT / BUILD ---
CAVITY_CLEAR            = 0.6;
WALL                    = 1.6;
FLOOR                   = 1.6;

$fn                     = 64;


// ====================== GRIDFINITY CONSTANTS =========================
PITCH       = 42;
GAP         = 0.5;                       // outer perimeter gap (0.25mm each side)
HALF_GAP    = GAP / 2;
CORNER_R    = 4;

FOOT_H1     = 0.8;
FOOT_H2     = 1.8;
FOOT_H3     = 2.15;
FOOT_H      = FOOT_H1 + FOOT_H2 + FOOT_H3;

// L-shape cell layout
CELLS_HANDLE_X = 2;
CELLS_HANDLE_Y = 2;
CELLS_BLADE_X  = 1;
CELLS_BLADE_Y  = 3;

HANDLE_W  = CELLS_HANDLE_X * PITCH;      // 84
HANDLE_D  = CELLS_HANDLE_Y * PITCH;      // 84
BLADE_W   = CELLS_BLADE_X  * PITCH;      // 42
BLADE_D   = CELLS_BLADE_Y  * PITCH;      // 126
BLADE_X   = BLADE_COL_LEFT ? 0 : (HANDLE_W - BLADE_W);
TOTAL_Y   = HANDLE_D + BLADE_D;          // 210

BODY_H = max(SCISSOR_RING_THK, SCISSOR_PIVOT_THK, SCISSOR_BLADE_THK) + FLOOR;


// ====================== MAIN =========================================
difference() {
    union() {
        feet();
        bin_body();
    }
    cavities();
}


// ====================== BIN BODY =====================================
// L-shape outline, inset by HALF_GAP to give the standard Gridfinity
// 0.25mm offset on all outer perimeter edges.
module bin_body() {
    translate([0, 0, FOOT_H])
        linear_extrude(height = BODY_H)
            offset(r = -HALF_GAP)
                l_polygon();
}

module l_polygon() {
    // CCW traversal of the L outline
    polygon([
        [0, 0],
        [HANDLE_W, 0],
        [HANDLE_W, HANDLE_D],
        [BLADE_X + BLADE_W, HANDLE_D],
        [BLADE_X + BLADE_W, TOTAL_Y],
        [BLADE_X, TOTAL_Y],
        [BLADE_X, HANDLE_D],
        [0, HANDLE_D]
    ]);
}


// ====================== FEET =========================================
// 7 feet total: 4 in the 2x2 handle area, 3 in the 1x3 blade strip.
module feet() {
    // Handle area (2x2)
    for (ix = [0 : CELLS_HANDLE_X - 1])
        for (iy = [0 : CELLS_HANDLE_Y - 1])
            translate([ix*PITCH + PITCH/2,
                       iy*PITCH + PITCH/2, 0])
                rect_foot(PITCH - GAP, PITCH - GAP);
    // Blade strip (1x3)
    for (iy = [0 : CELLS_BLADE_Y - 1])
        translate([BLADE_X + PITCH/2,
                   HANDLE_D + iy*PITCH + PITCH/2, 0])
            rect_foot(PITCH - GAP, PITCH - GAP);
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
// Single continuous cavity for the closed scissors. A hull connects:
//   - the LEFT ring oval (at the front)
//   - the RIGHT ring oval (centered on the bin's right boundary)
//   - the pivot screw (at SCISSOR_PIVOT_FROM_RING along Y)
//   - the blade tip (at SCISSOR_TOTAL_LEN along Y)
// The hull captures the body region between the rings and the pivot,
// and tapers smoothly into the blade slot above the pivot.
module cavities() {
    z_top = FOOT_H + BODY_H;
    cavity_depth = max(SCISSOR_RING_THK, SCISSOR_PIVOT_THK, SCISSOR_BLADE_THK);

    // Ring positions
    ring_y_center = WALL + SCISSOR_RING_OUTER_L/2;
    right_ring_x  = HANDLE_W;                          // on the bin's right edge
    left_ring_x   = right_ring_x
                  - (SCISSOR_RING_OUTER_W + SCISSOR_RING_GAP);

    // Pivot: centered between the two rings (along X)
    pivot_x = (left_ring_x + right_ring_x) / 2;
    pivot_y = SCISSOR_PIVOT_FROM_RING;

    // Blade tip: same X as the pivot, at the end of the bin
    blade_tip_y = SCISSOR_TOTAL_LEN;

    translate([0, 0, z_top - cavity_depth])
        // Shift + rotate around the pivot
        translate([SCISSOR_X_SHIFT, SCISSOR_Y_SHIFT, 0])
            translate([pivot_x, pivot_y, 0])
                rotate([0, 0, SCISSOR_ROTATE])
                    translate([-pivot_x, -pivot_y, 0])
                        linear_extrude(height = cavity_depth + 0.1)
                            hull() {
                                // Left ring oval
                                translate([left_ring_x, ring_y_center])
                                    scale([SCISSOR_RING_OUTER_W/2 + CAVITY_CLEAR,
                                           SCISSOR_RING_OUTER_L/2 + CAVITY_CLEAR])
                                        circle(r = 1);
                                // Right ring oval (half overhangs into the peeler bin)
                                translate([right_ring_x, ring_y_center])
                                    scale([SCISSOR_RING_OUTER_W/2 + CAVITY_CLEAR,
                                           SCISSOR_RING_OUTER_L/2 + CAVITY_CLEAR])
                                        circle(r = 1);
                                // Pivot
                                translate([pivot_x, pivot_y])
                                    circle(d = SCISSOR_PIVOT_DIA + 2*CAVITY_CLEAR);
                                // Blade tip
                                translate([pivot_x, blade_tip_y])
                                    circle(d = SCISSOR_BLADE_W_TIP + 2*CAVITY_CLEAR);
                            }
}
