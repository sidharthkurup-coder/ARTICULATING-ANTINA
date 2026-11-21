// ============================================================================
// ARTEMIS-24Y — 2.4 GHz 9-Element Yagi-Uda Articulating Antenna Tracker
// Parametric Product-Grade CAD Assembly (OpenSCAD)
// Band: 2.400 - 2.4835 GHz (f0 = 2.45 GHz, lambda = 122.36 mm)
// Gain: ~13.0 dBi | Polarization: Linear (V/H Rotatable) | Az: +-180 | El: 0..90
// Units: Millimeters (mm)
// ============================================================================

$fn = 64;

// --- Kinematic & Display Parameters ---
az_angle       = 25;    // Azimuth rotation [-180 .. +180] deg
el_angle       = 30;    // Elevation tilt [0 .. +90] deg
pol_angle      = 0;     // Polarization roll [0 = Vertical, 90 = Horizontal] deg
explode_factor = 0.0;   // 0.0 = assembled, 1.0 = fully exploded
show_radome    = false; // Toggle aerodynamic weather shroud

// --- RF Yagi-Uda Parameters (2.45 GHz, 9-Element) ---
// [z_from_reflector_mm, length_mm]
yagi_elements = [
    [  0.0, 61.5], // Reflector (R)
    [ 24.5, 57.5], // Driven Element (DE - Folded Dipole)
    [ 42.9, 53.0], // Director 1 (D1)
    [ 67.4, 51.5], // Director 2 (D2)
    [ 96.8, 50.5], // Director 3 (D3)
    [129.8, 49.6], // Director 4 (D4)
    [165.3, 48.8], // Director 5 (D5)
    [202.0, 48.2], // Director 6 (D6)
    [238.7, 47.6]  // Director 7 (D7)
];
elem_dia       = 3.2;   // 3.2 mm Brass/Aluminum rod
boom_size      = 15.0;  // 15x15 mm 6061-T6 square boom
boom_len       = 264.0; // Total boom length (-14 mm to +250 mm)
pivot_z_offset = 78.0;  // CG-balanced elevation pivot position along boom

// --- Mechanical & Gimbal Parameters ---
base_dia       = 120.0;
base_h         = 18.0;
turret_dia     = 104.0;
turret_h       = 48.0;
yoke_span      = 146.0;
yoke_arm_t     = 12.0;
yoke_arm_w     = 34.0;
arm_h          = 122.0; // Tall U-fork clearance for 90 deg zenith tilt
nema17_w       = 42.3;
nema17_len     = 34.0;

// --- Colors ---
c_anodized     = [0.16, 0.19, 0.23];
c_steel        = [0.68, 0.72, 0.76];
c_brass        = [0.82, 0.65, 0.26];
c_accent       = [0.14, 0.50, 0.85];
c_radome       = [0.90, 0.94, 0.98, 0.28];

// ============================================================================
// 1. Tripod Base & Azimuth Bearing Seat
// ============================================================================
module tripod_base_assembly() {
    color(c_anodized)
    difference() {
        union() {
            cylinder(d = base_dia, h = base_h - 3);
            translate([0, 0, base_h - 3])
                cylinder(d1 = base_dia, d2 = turret_dia + 4, h = 3);
            translate([0, 0, base_h])
                cylinder(d = 54, h = 10);
        }
        translate([0, 0, -0.1]) cylinder(d = 9.5, h = 14);
        for (a = [45 : 90 : 315])
            rotate([0, 0, a]) translate([50, 0, -0.1]) cylinder(d = 4.4, h = base_h + 1);
        translate([0, 0, base_h + 3.1]) cylinder(d = 52.1, h = 7.5);
        translate([0, 0, -0.1]) cylinder(d = 18, h = base_h + 11);
    }

    // Dual-thread Brass Tripod Insert (3/8"-16 / 1/4"-20 UNC)
    color(c_brass)
    translate([0, 0, 0.5])
    difference() {
        cylinder(d = 14, h = 10);
        translate([0, 0, -0.1]) cylinder(d = 6.35, h = 10.2);
    }

    // Azimuth physical hard-stop pin (+-180 deg)
    color(c_steel)
    translate([38, 0, base_h]) cylinder(d = 6, h = 8);
}

// ============================================================================
// 2. Azimuth Turret & Drive Housing
// ============================================================================
module azimuth_turret_assembly() {
    color(c_anodized)
    difference() {
        union() {
            cylinder(d = turret_dia, h = turret_h);
            translate([-24, -22, 4]) cube([48, 44, 40]);
        }
        translate([0, 0, -0.1]) cylinder(d = 24, h = turret_h + 0.2);
    }
    color([0.1, 0.1, 0.12])
    translate([-nema17_w/2, -nema17_w/2, 6]) cube([nema17_w, nema17_w, nema17_len]);
    color(c_steel)
    translate([0, 0, 4]) cylinder(d = 40, h = 9);
}

// ============================================================================
// 3. Tall Elevation U-Fork Yoke (Zenith-Cleared for Yagi Boom)
// ============================================================================
module elevation_yoke_assembly() {
    color(c_anodized) {
        translate([-(yoke_span/2 + yoke_arm_t), -yoke_arm_w/2, 0])
            cube([yoke_span + 2*yoke_arm_t, yoke_arm_w, 12]);
        for (side = [-1, 1]) {
            translate([side * (yoke_span/2 + yoke_arm_t/2), 0, 0])
            difference() {
                union() {
                    translate([-yoke_arm_t/2, -yoke_arm_w/2, 12])
                        cube([yoke_arm_t, yoke_arm_w, arm_h - 12]);
                    translate([0, 0, arm_h])
                        rotate([0, 90, 0])
                            cylinder(d = yoke_arm_w, h = yoke_arm_t, center = true);
                }
                translate([0, 0, arm_h])
                    rotate([0, 90, 0])
                        cylinder(d = 22.1, h = yoke_arm_t + 1, center = true);
            }
        }
    }
    color([0.1, 0.1, 0.12])
    translate([-(yoke_span/2 + yoke_arm_t + nema17_len), -nema17_w/2, arm_h - 22])
        cube([nema17_len, nema17_w, nema17_w]);
    color(c_accent)
    translate([-(yoke_span/2 + yoke_arm_t + 6), 0, arm_h])
        rotate([0, 90, 0]) cylinder(d = 38, h = 8, center = true);
}

// ============================================================================
// 4. 9-Element 2.45 GHz Yagi-Uda Array & Polarization Collar
// ============================================================================
module yagi_antenna_assembly() {
    // Elevation Pivot Axle & Trunnion Saddle
    color(c_steel)
    rotate([0, 90, 0])
        cylinder(d = 12, h = yoke_span + 2*yoke_arm_t + 16, center = true);

    color(c_anodized)
    translate([-17, -14, -14])
        cube([34, 28, 28]);

    // Polarization Indexing Collar (0 deg V-Pol / 90 deg H-Pol)
    color(c_accent)
    rotate([0, 0, pol_angle])
        cylinder(d = 34, h = 16, center = true);

    // Rotatable Yagi Boom & Elements (aligned along +Z boresight)
    rotate([0, 0, pol_angle]) {
        // 15x15 mm 6061-T6 Square Boom
        color(c_steel)
        translate([-boom_size/2, -boom_size/2, -pivot_z_offset - 14])
            cube([boom_size, boom_size, boom_len]);

        // Rear Counterweight & Shielded LNA/Balun Pod behind Reflector
        color(c_anodized)
        translate([-24, -18, -pivot_z_offset - 28])
            cube([48, 36, 20]);

        // Weatherproof Driven Element Balun Feed Box & N-Female Bulkhead
        color(c_anodized)
        translate([-15, -14, 24.5 - pivot_z_offset - 10])
            cube([30, 28, 20]);
        color(c_brass)
        translate([0, -21, 24.5 - pivot_z_offset])
            rotate([90, 0, 0]) cylinder(d = 14, h = 12);

        // 9 Parasitic & Driven Elements (Vertical when pol_angle = 0)
        for (i = [0 : len(yagi_elements) - 1]) {
            ez = yagi_elements[i][0] - pivot_z_offset;
            el_len = yagi_elements[i][1];

            // Insulated ASA Element Mounting Clip
            color([0.12, 0.14, 0.18])
            translate([-8.75, -8.75, ez - 2.25])
                cube([17.5, 17.5, 4.5]);

            if (i == 1) {
                // Folded Dipole Driven Element
                color(c_brass) {
                    translate([0, 0, ez - 3])
                        rotate([90, 0, 0]) cylinder(d = elem_dia, h = el_len, center = true);
                    translate([0, 0, ez + 3])
                        rotate([90, 0, 0]) cylinder(d = elem_dia, h = el_len, center = true);
                    for (end = [-1, 1])
                        translate([0, end * el_len / 2, ez])
                            cylinder(d = elem_dia, h = 6, center = true);
                }
            } else {
                // Reflector & Directors (3.2 mm Brass Rods)
                color(c_brass)
                translate([0, 0, ez])
                    rotate([90, 0, 0])
                        cylinder(d = elem_dia, h = el_len, center = true);
            }
        }

        // Optional Aerodynamic Protective Radome Shell
        if (show_radome) {
            color(c_radome)
            translate([0, 0, -pivot_z_offset - 18])
                cylinder(d = 82, h = boom_len + 26);
        }
    }
}

// ============================================================================
// Master Articulated Assembly
// ============================================================================
module artemis_yagi_assembly() {
    tripod_base_assembly();

    translate([0, 0, base_h + explode_factor * 35])
    rotate([0, 0, az_angle]) {
        azimuth_turret_assembly();

        translate([0, 0, turret_h + explode_factor * 45])
            elevation_yoke_assembly();

        translate([0, 0, turret_h + arm_h + explode_factor * 85])
        rotate([90 - el_angle, 0, 0])
            yagi_antenna_assembly();
    }
}

artemis_yagi_assembly();
