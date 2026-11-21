// ============================================================================
// ARTEMIS 2.4 GHz Axial-Mode Helical Articulating Antenna Tracker
// Parametric Product-Grade CAD Assembly (OpenSCAD)
// Band: 2.400 - 2.4835 GHz (f0 = 2.45 GHz, lambda = 122.36 mm)
// Polarization: RHCP | Gain: ~12.5 dBi | Az: -180..+180 deg | El: 0..+90 deg
// Units: Millimeters (mm)
// ============================================================================

$fn = 64;

// --- Kinematic & Display Parameters ---
az_angle       = 25;    // Azimuth rotation [-180 .. +180] deg
el_angle       = 35;    // Elevation tilt [0 .. +90] deg
explode_factor = 0.0;   // 0.0 = assembled, 1.0 = fully exploded
show_radome    = true;  // Toggle translucent radome shroud

// --- RF Helical Parameters (2.45 GHz) ---
lambda_mm      = 122.36;
helix_dia      = 39.0;  // Mean coil diameter (~lambda / pi)
helix_pitch    = 28.0;  // Turn-to-turn spacing (~0.23 * lambda)
helix_turns    = 7;     // 7 turns -> ~12.5 dBi gain, ~41 deg HPBW
wire_dia       = 3.2;   // 8 AWG / 3.2 mm copper conductor
cup_od         = 110.0; // Reflector cup outer diameter (~0.9 * lambda)
cup_wall       = 2.5;
cup_lip_h      = 22.0;  // Cylindrical rim height
radome_od      = 68.0;  // Protective ASA/fiberglass radome OD
radome_len     = 225.0; // Total radome length

// --- Mechanical & Gimbal Parameters ---
base_dia       = 120.0;
base_h         = 18.0;
turret_dia     = 104.0;
turret_h       = 48.0;
yoke_span      = 146.0; // Inner clearance between U-fork arms
yoke_arm_t     = 12.0;
yoke_arm_w     = 34.0;
el_axis_z      = base_h + turret_h + 78.0; // Elevation pivot height
nema17_w       = 42.3;
nema17_len     = 34.0;

// --- Colors ---
c_anodized     = [0.16, 0.19, 0.23];
c_steel        = [0.65, 0.68, 0.72];
c_brass        = [0.80, 0.62, 0.25];
c_copper       = [0.85, 0.45, 0.22];
c_radome       = [0.92, 0.94, 0.96, 0.35];
c_accent       = [0.12, 0.48, 0.78];

// ============================================================================
// 1. Tripod Base & Azimuth Bearing Seat (Fixed)
// ============================================================================
module tripod_base_assembly() {
    color(c_anodized)
    difference() {
        union() {
            // Main base flange
            cylinder(d = base_dia, h = base_h - 3);
            // Chamfered upper shoulder
            translate([0, 0, base_h - 3])
                cylinder(d1 = base_dia, d2 = turret_dia + 4, h = 3);
            // Central bearing boss
            translate([0, 0, base_h])
                cylinder(d = 54, h = 10);
        }
        // Tripod 3/8"-16 UNC central mounting bore (9.5 mm)
        translate([0, 0, -0.1])
            cylinder(d = 9.5, h = 14);
        // 4x M4 perimeter mounting holes (100 mm BCD)
        for (a = [45 : 90 : 315]) {
            rotate([0, 0, a])
                translate([50, 0, -0.1])
                    cylinder(d = 4.4, h = base_h + 1);
        }
        // 6808-2RS bearing seat bore (52 mm OD x 7 mm)
        translate([0, 0, base_h + 3.1])
            cylinder(d = 52.1, h = 7.5);
        // Central slip-free wire pass-through
        translate([0, 0, -0.1])
            cylinder(d = 18, h = base_h + 11);
    }

    // Brass 3/8"-16 to 1/4"-20 tripod insert bushing
    color(c_brass)
    translate([0, 0, 0.5])
        difference() {
            cylinder(d = 14, h = 10);
            translate([0, 0, -0.1])
                cylinder(d = 6.35, h = 10.2);
        }

    // Azimuth physical hard-stop pin (+-180 deg)
    color(c_steel)
    translate([38, 0, base_h])
        cylinder(d = 6, h = 8);
}

// ============================================================================
// 2. Azimuth Turret & Drive Housing
// ============================================================================
module azimuth_turret_assembly() {
    color(c_anodized)
    difference() {
        union() {
            cylinder(d = turret_dia, h = turret_h);
            // Side NEMA 17 drive blister
            translate([-24, -22, 4])
                cube([48, 44, 40]);
        }
        // Hollow core for bearing shaft & harness
        translate([0, 0, -0.1])
            cylinder(d = 24, h = turret_h + 0.2);
        // Side cable gland port
        translate([0, turret_dia/2 - 2, 18])
            rotate([-90, 0, 0])
                cylinder(d = 12, h = 10);
    }

    // NEMA 17 Stepper (Azimuth)
    color([0.1, 0.1, 0.12])
    translate([-nema17_w/2, -nema17_w/2, 6])
        cube([nema17_w, nema17_w, nema17_len]);

    // Azimuth 60T GT2 Driven Pulley
    color(c_steel)
    translate([0, 0, 4])
        cylinder(d = 40, h = 9);
}

// ============================================================================
// 3. Elevation U-Fork Yoke
// ============================================================================
module elevation_yoke_assembly() {
    yoke_h = el_axis_z - (base_h + turret_h);

    color(c_anodized) {
        // Crossbar plate
        translate([-(yoke_span/2 + yoke_arm_t), -yoke_arm_w/2, 0])
            cube([yoke_span + 2*yoke_arm_t, yoke_arm_w, 12]);

        // Left & Right U-Fork Arms
        for (side = [-1, 1]) {
            translate([side * (yoke_span/2 + yoke_arm_t/2), 0, 0])
            difference() {
                union() {
                    translate([-yoke_arm_t/2, -yoke_arm_w/2, 12])
                        cube([yoke_arm_t, yoke_arm_w, yoke_h]);
                    // Rounded bearing boss at top
                    translate([0, 0, yoke_h + 12])
                        rotate([0, 90, 0])
                            cylinder(d = yoke_arm_w, h = yoke_arm_t, center = true);
                }
                // 608ZZ Bearing bore (22 mm)
                translate([0, 0, yoke_h + 12])
                    rotate([0, 90, 0])
                        cylinder(d = 22.1, h = yoke_arm_t + 1, center = true);
            }
        }
    }

    // Elevation NEMA 17 Stepper & Gearbox (Left Arm Outer Mount)
    color([0.1, 0.1, 0.12])
    translate([-(yoke_span/2 + yoke_arm_t + nema17_len), -nema17_w/2, yoke_h - 10])
        cube([nema17_len, nema17_w, nema17_w]);

    // Elevation Drive Pulley / Anti-backlash Gear
    color(c_accent)
    translate([-(yoke_span/2 + yoke_arm_t + 8), 0, yoke_h + 12])
        rotate([0, 90, 0])
            cylinder(d = 38, h = 8, center = true);
}

// ============================================================================
// 4. 2.4 GHz 7-Turn Axial-Mode Helical Antenna & Reflector Cup
// ============================================================================
module helical_coil(dia, pitch, turns, w_dia, steps_per_turn = 32) {
    r = dia / 2;
    total_steps = turns * steps_per_turn;
    for (i = [0 : total_steps - 1]) {
        a1 = i * 360 / steps_per_turn;
        a2 = (i + 1) * 360 / steps_per_turn;
        z1 = i * pitch / steps_per_turn;
        z2 = (i + 1) * pitch / steps_per_turn;
        hull() {
            translate([r * cos(a1), r * sin(a1), z1])
                sphere(d = w_dia, $fn = 12);
            translate([r * cos(a2), r * sin(a2), z2])
                sphere(d = w_dia, $fn = 12);
        }
    }
}

module helical_antenna_assembly() {
    // Elevation pivot trunnion cradle
    color(c_anodized)
    difference() {
        union() {
            // Lateral pivot axle
            rotate([0, 90, 0])
                cylinder(d = 12, h = yoke_span + 2*yoke_arm_t + 16, center = true);
            // Saddle clamp around reflector cup
            translate([0, 0, -10])
                cylinder(d = cup_od + 8, h = 20, center = true);
        }
        translate([0, 0, -10])
            cylinder(d = cup_od + 0.4, h = 22, center = true);
    }

    // Aluminum Reflector Cup (110 mm OD x 22 mm lip)
    color(c_steel)
    translate([0, 0, -2]) {
        cylinder(d = cup_od, h = cup_wall);
        difference() {
            cylinder(d = cup_od, h = cup_lip_h);
            translate([0, 0, cup_wall])
                cylinder(d = cup_od - 2*cup_wall, h = cup_lip_h);
        }
    }

    // Rear Counterweight & Shielded RF/Stepper Electronics Pod
    color(c_anodized)
    translate([-36, -32, -44])
        cube([72, 64, 42]);

    // N-Type Bulkhead Connector on rear of reflector
    color(c_brass)
    translate([0, 0, -16])
        cylinder(d = 16, h = 14);

    // Central Dielectric Support Boom (PTFE / ASA)
    color([0.95, 0.95, 0.95])
    translate([0, 0, 0])
        cylinder(d = 16, h = helix_turns * helix_pitch + 14);

    // 7-Turn RHCP Copper Helix
    color(c_copper)
    translate([0, 0, 10])
        helical_coil(helix_dia, helix_pitch, helix_turns, wire_dia, 28);

    // Translucent Protective Radome Tube + Hemispherical Cap
    if (show_radome) {
        color(c_radome)
        translate([0, 0, 2]) {
            difference() {
                cylinder(d = radome_od, h = radome_len);
                translate([0, 0, -0.5])
                    cylinder(d = radome_od - 4, h = radome_len + 1);
            }
            translate([0, 0, radome_len])
                sphere(d = radome_od);
        }
    }
}

// ============================================================================
// Master Articulated Assembly
// ============================================================================
module artemis_assembly() {
    // 1. Tripod Base
    tripod_base_assembly();

    // 2. Azimuth Turret (rotates around Z)
    translate([0, 0, base_h + explode_factor * 35])
    rotate([0, 0, az_angle]) {
        azimuth_turret_assembly();

        // 3. Elevation Yoke
        translate([0, 0, turret_h + explode_factor * 45])
            elevation_yoke_assembly();

        // 4. Helical Antenna Payload (rotates around X for elevation: 0=horizon, 90=zenith)
        translate([0, 0, turret_h + (el_axis_z - base_h - turret_h) + explode_factor * 85])
        rotate([90 - el_angle, 0, 0])
            helical_antenna_assembly();
    }
}

artemis_assembly();
