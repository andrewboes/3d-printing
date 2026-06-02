// ============================================================
//  Hazard-switch trim bezel — parametric
//  Units: millimetres. Tweak the PARAMETERS block, then F5 / F6.
// ============================================================

// ---------- PARAMETERS ----------
face_length     = 82;    // bezel long axis
face_width      = 50;    // bezel short axis
face_thickness  = 2;     // flange thickness

hole_length     = 48;    // cutout long axis
hole_width      = 31;    // cutout short axis
hole_offset     = 9;     // cutout shift from centre, along the long axis
hole_offset_dir = 1;     // 1 or -1 → which END the cutout sits toward

wall            = 2.0;   // tube wall thickness
tube_len        = 20;    // how far the tube projects past the flange

tilt_deg        = 25;    // tube lean angle
tilt_dir        = 1;     // 1 or -1 → which WAY the tube leans (flip if wrong side)

smooth          = 120;   // facet count (higher = smoother ovals)

// ---------- MODEL ----------
$fn = smooth;

module eprism(L, W, h) {            // elliptical prism: L × W footprint, height h
    linear_extrude(height = h)
        scale([L/2, W/2]) circle(r = 1);
}

intersection() {
    difference() {
        union() {
            // flange
            eprism(face_length, face_width, face_thickness);

            // tube (solid outer, tilted) — extended below z=0 for a clean base
            translate([hole_offset_dir * hole_offset, 0, 0])
                rotate([tilt_dir * tilt_deg, 0, 0])
                    translate([0, 0, -tube_len])
                        eprism(hole_length + 2*wall,
                               hole_width  + 2*wall,
                               2*tube_len + face_thickness);
        }
        // cavity / hole (tilted, cut right through)
        translate([hole_offset_dir * hole_offset, 0, 0])
            rotate([tilt_dir * tilt_deg, 0, 0])
                translate([0, 0, -10])
                    eprism(hole_length, hole_width,
                           face_thickness + tube_len + 20);
    }
    // trim flush with the front face (z = 0) so the front stays flat
    translate([-250, -250, 0]) cube([500, 500, 500]);
}
