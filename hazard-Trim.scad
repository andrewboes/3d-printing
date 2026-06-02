// ============================================================
//  Hazard-switch trim bezel — parametric
// ============================================================

// ---------- PARAMETERS ----------
face_length     = 82;
face_width      = 50;
face_thickness  = 2;
round_r         = 1.5;     // front-edge roundover radius (0 = sharp; max ≈ face_thickness)
round_steps     = 24;    // roundover smoothness (more = smoother)

hole_length     = 48;
hole_width      = 31;
hole_offset     = 9;
hole_offset_dir = 1;

wall            = 2.5;
tube_len        = 20;

tilt_deg        = 25;
tilt_dir        = 1;

smooth          = 120;

// ---------- MODEL ----------
$fn = smooth;

module eprism(L, W, h) {
    linear_extrude(height = h) scale([L/2, W/2]) circle(r = 1);
}

module flange_round(L, W, h, r, steps) {   // curved roundover on front edge (z=0)
    union() {
        // straight side wall, z=r up to h
        translate([0, 0, r]) eprism(L, W, h - r);
        // rounded front edge: quarter-circle arc from z=0 to z=r
        for (i = [0 : steps - 1]) {
            a0 = i     * 90 / steps;   a1 = (i + 1) * 90 / steps;
            z0 = r * (1 - cos(a0));    in0 = r * (1 - sin(a0));
            z1 = r * (1 - cos(a1));    in1 = r * (1 - sin(a1));
            hull() {
                translate([0,0,z0]) linear_extrude(0.01)
                    scale([(L-2*in0)/2, (W-2*in0)/2]) circle(r = 1);
                translate([0,0,z1]) linear_extrude(0.01)
                    scale([(L-2*in1)/2, (W-2*in1)/2]) circle(r = 1);
            }
        }
    }
}

intersection() {
    difference() {
        union() {
            flange_round(face_length, face_width, face_thickness, round_r, round_steps);

            translate([hole_offset_dir * hole_offset, 0, 0])
                rotate([tilt_dir * tilt_deg, 0, 0])
                    translate([0, 0, -tube_len])
                        eprism(hole_length + 2*wall,
                               hole_width  + 2*wall,
                               2*tube_len + face_thickness);
        }
        translate([hole_offset_dir * hole_offset, 0, 0])
            rotate([tilt_dir * tilt_deg, 0, 0])
                translate([0, 0, -10])
                    eprism(hole_length, hole_width,
                           face_thickness + tube_len + 20);
    }
    translate([-250, -250, 0]) cube([500, 500, 500]);
}
