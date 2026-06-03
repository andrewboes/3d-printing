// =====================================================================
// Gridfinity Spoon Holder  (3 wide x 2.5 deep)
//
// One-piece bin with three compartments, top-down layout:
//
//   +Y (back)
//    +-----------------------------------------------+
//    |  [ bowl ]==================== TABLESPOON      |
//    |  ====================[ bowl ] TEASPOON        |
//    |  --------- open tray (measuring spoons) ----- |
//    +-----------------------------------------------+ +X (right)
//
// The 0.5-cell extension sits on the BACK side (no foot under it).
// Edit the spoon dimensions below after measuring with your caliper.
// =====================================================================


// ====================== EDIT ME (all values in mm) ===================

// --- TABLESPOON ---
TBSP_BOWL_LEN     = 28;    // bowl long axis (bowl tip to where the neck meets the handle)
TBSP_BOWL_WID     = 28;    // bowl widest dimension across
TBSP_BOWL_DEPTH   = 15;    // how deep the bowl sits (cavity depth at the bowl)
TBSP_HANDLE_LEN   = 87;    // handle length from neck to tip
TBSP_HANDLE_W_NK  = 13;    // handle width at the neck (near bowl)
TBSP_HANDLE_W_TP  = 19;    // handle width at the tip
TBSP_HANDLE_THK   = 2.5;     // handle thickness (cavity depth in the handle slot)

// --- TEASPOON ---
TSP_BOWL_LEN      = 40;
TSP_BOWL_WID      = 40;
TSP_BOWL_DEPTH    = 19;
TSP_HANDLE_LEN    = 85;
TSP_HANDLE_W_NK   = 13;
TSP_HANDLE_W_TP   = 19;
TSP_HANDLE_THK    = 2.5;

// --- PICKUP POCKET (deeper recess under each handle tip for fingers) ---
PICKUP_LEN        = 28;    // length along the handle (from tip back toward bowl)
PICKUP_WIDTH      = 22;    // width across the handle
PICKUP_EXTRA_D    = 6;     // extra depth below the handle floor

// --- TRAY (open bin for misc measuring spoons, front band) ---
TRAY_BAND_DEPTH   = 32;    // Y-size of the tray band
TRAY_INSIDE_DEPTH = 22;    // how deep the open tray pocket is

// --- FIT / BUILD ---
SPOON_CLEAR       = 0.6;   // clearance added around every spoon dimension
WALL              = 1.6;
FLOOR             = 1.6;

$fn               = 80;


// ====================== GRIDFINITY CONSTANTS =========================
PITCH       = 42;
CELLS_X     = 3;
CELLS_Y     = 2.5;          // half-cell is on the BACK (high-Y) side
OUTER_X     = CELLS_X * PITCH - 0.5;    // 125.5
OUTER_Y     = CELLS_Y * PITCH - 0.5;    // 104.5
CORNER_R    = 4;

// Foot profile (total 4.75 mm)
FOOT_H1     = 0.8;          // bottom chamfer
FOOT_H2     = 1.8;          // straight middle
FOOT_H3     = 2.15;         // top chamfer
FOOT_H      = FOOT_H1 + FOOT_H2 + FOOT_H3;

// Body height = deepest feature + floor
BODY_H = max(
    TBSP_BOWL_DEPTH,
    TSP_BOWL_DEPTH,
    TBSP_HANDLE_THK + PICKUP_EXTRA_D,
    TSP_HANDLE_THK  + PICKUP_EXTRA_D,
    TRAY_INSIDE_DEPTH
) + FLOOR + 1;


// ====================== MAIN =========================================
difference() {
    bin_solid();
    cavities();
}


// ====================== BIN BODY =====================================
module bin_solid() {
    feet();
    translate([0, 0, FOOT_H])
        rounded_box(OUTER_X, OUTER_Y, BODY_H, CORNER_R);
}

module rounded_box(w, d, h, r) {
    translate([w/2, d/2, 0])
        linear_extrude(height = h)
            offset(r = r) square([w - 2*r, d - 2*r], center = true);
}


// ====================== FEET =========================================
// Standard Gridfinity foot profile, placed at every FULL cell.
// 3 across by 2 deep (front rows). No foot on the back 0.5 cell.
module feet() {
    for (ix = [0 : CELLS_X - 1])
        for (iy = [0 : 1])
            translate([ix*PITCH + PITCH/2, iy*PITCH + PITCH/2, 0])
                single_foot();
}

module single_foot() {
    cell = PITCH - 0.5;                  // 41.5
    bot  = cell - 2*(FOOT_H1 + FOOT_H3); // 35.6
    mid  = cell - 2*FOOT_H3;             // 37.2
    top  = cell;                         // 41.5

    // bottom chamfer (bot -> mid)
    linear_extrude(height = FOOT_H1, scale = mid/bot)
        rounded_sq(bot, max(CORNER_R - (FOOT_H1 + FOOT_H3), 0.5));

    // straight middle
    translate([0, 0, FOOT_H1])
        linear_extrude(height = FOOT_H2)
            rounded_sq(mid, max(CORNER_R - FOOT_H3, 0.5));

    // top chamfer (mid -> top)
    translate([0, 0, FOOT_H1 + FOOT_H2])
        linear_extrude(height = FOOT_H3, scale = top/mid)
            rounded_sq(mid, max(CORNER_R - FOOT_H3, 0.5));
}

module rounded_sq(side, r) {
    offset(r = r) square(side - 2*r, center = true);
}


// ====================== CAVITIES =====================================
module cavities() {
    // Band Y centers (front -> back)
    spoon_y_avail = OUTER_Y - TRAY_BAND_DEPTH - 2*WALL;
    band_h        = spoon_y_avail / 2;
    y_tsp_c       = TRAY_BAND_DEPTH + WALL + band_h/2;
    y_tbsp_c      = TRAY_BAND_DEPTH + WALL + band_h + band_h/2;

    z_top = FOOT_H + BODY_H;

    // ---- Tray (open rectangle, front band) ----
    translate([OUTER_X/2,
               WALL + (TRAY_BAND_DEPTH - WALL)/2,
               z_top - TRAY_INSIDE_DEPTH])
        linear_extrude(height = TRAY_INSIDE_DEPTH + 0.1)
            offset(r = 2)
                square([OUTER_X - 2*WALL - 4,
                        TRAY_BAND_DEPTH - 2*WALL - 4],
                       center = true);

    // ---- Tablespoon (bowl LEFT, handle RIGHT) ----
    translate([WALL + SPOON_CLEAR, y_tbsp_c, z_top])
        spoon_cavity(TBSP_BOWL_LEN, TBSP_BOWL_WID, TBSP_BOWL_DEPTH,
                     TBSP_HANDLE_LEN, TBSP_HANDLE_W_NK,
                     TBSP_HANDLE_W_TP, TBSP_HANDLE_THK);

    // ---- Teaspoon (bowl RIGHT, handle LEFT) -- rotate 180 around Z ----
    translate([OUTER_X - WALL - SPOON_CLEAR, y_tsp_c, z_top])
        rotate([0, 0, 180])
            spoon_cavity(TSP_BOWL_LEN, TSP_BOWL_WID, TSP_BOWL_DEPTH,
                         TSP_HANDLE_LEN, TSP_HANDLE_W_NK,
                         TSP_HANDLE_W_TP, TSP_HANDLE_THK);
}


// Spoon cavity anchored at BOWL TIP, handle extends in +X.
// Top of cavity is at z = 0, cavity descends into -Z.
module spoon_cavity(bowl_l, bowl_w, bowl_d, hl, h_wn, h_wt, h_t) {
    c   = SPOON_CLEAR;
    eps = 0.1;

    // Bowl pocket (ellipse, centered at x = bowl_l/2)
    translate([bowl_l/2, 0, -bowl_d])
        linear_extrude(height = bowl_d + eps)
            scale([1, bowl_w / bowl_l, 1])
                circle(r = bowl_l/2 + c);

    // Handle slot (tapered trapezoid), starts at neck (overlaps bowl slightly)
    overlap = 1;
    translate([0, 0, -h_t])
        linear_extrude(height = h_t + eps)
            polygon([
                [bowl_l - overlap, -(h_wn/2 + c)],
                [bowl_l + hl,      -(h_wt/2 + c)],
                [bowl_l + hl,       (h_wt/2 + c)],
                [bowl_l - overlap,  (h_wn/2 + c)]
            ]);

    // Pickup pocket (deeper recess under the last bit of handle, near tip)
    translate([bowl_l + hl - PICKUP_LEN/2, 0,
               -(h_t + PICKUP_EXTRA_D)])
        linear_extrude(height = PICKUP_EXTRA_D + eps)
            offset(r = 3)
                square([max(PICKUP_LEN  - 6, 1),
                        max(PICKUP_WIDTH - 6, 1)], center = true);
}
