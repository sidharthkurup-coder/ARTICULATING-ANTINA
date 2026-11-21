# ARTEMIS — Dual 2.4 GHz Articulating Antenna Suite (Helical & Yagi-Uda)

Interactive 3D CAD studio, real-world RF mission simulator, parametric OpenSCAD/STL models, product engineering brief, and ESP32 closed-loop tracking firmware for two tripod-mounted **2.4 GHz (2400–2483.5 MHz, $f_0 = 2.45\text{ GHz}$, $\lambda = 122.36\text{ mm}$)** articulating high-gain antenna systems on a unified two-axis gimbal.

---

## Antenna Heads & RF Specifications

| Parameter | ARTEMIS-24H (7-Turn Axial-Mode Helical) | ARTEMIS-24Y (9-Element Yagi-Uda) |
| :--- | :--- | :--- |
| **Frequency Band** | 2400–2483.5 MHz ($f_0 = 2.45\text{ GHz}$) | 2400–2483.5 MHz ($f_0 = 2.45\text{ GHz}$) |
| **Gain / Beamwidth** | ~12.5 dBi / ~41° HPBW | ~13.0 dBi / ~38° E-plane HPBW |
| **Polarization** | Circular (RHCP) | Linear (0°–90° Indexed V/H Collar) |
| **Front-to-Back Ratio** | ~15 dB | >18 dB |
| **Radiator Geometry** | Ø39.0 mm × 7 turns C110 copper (3.2 mm wire, 28.0 mm pitch, 196 mm length) on Ø16 mm PTFE core | 15 × 15 × 264 mm 6061-T6 square boom, Ø3.2 mm brass rods (61.5 mm reflector, 57.5 mm folded dipole + 4:1 balun, 7 tapered directors 53.0 → 47.6 mm) |
| **Feed / Reflector** | Ø110 × 22 mm aluminum reflector cup, N-Female 50 Ω bulkhead + $\lambda/4$ copper matching tab | Weatherproof 4:1 balun box + N-Female 50 Ω bulkhead, 9× UV-ASA boom clips |
| **Envelope / Radome** | Ø68 × 225 mm translucent UV-ASA radome + rear counterweight pod | CG cradle at $z = 78\text{ mm}$, blue V/H collar, rear counterweight pod, optional weather shroud |
| **U-Fork Clearance** | 82 mm compact U-fork arms | 122 mm tall zenith-cleared U-fork arms |
| **Primary Mission** | Agile banking UAV telemetry (0 dB cross-pol fade) | Long-range ground relays & off-axis ISM jammer rejection |

### Unified Two-Axis Articulating Gimbal
- **Range of Motion**: ±180° Azimuth (with physical hard-stop & zenith azimuth hold above 85° elevation), 0°–90° Elevation.
- **Mounting & Bearings**: Collapsible field tripod with dual-thread C360 brass `3/8"-16` & `1/4"-20` UNC mounting insert, `6808-2RS` azimuth slewing bearing, and dual `608ZZ` elevation bearings.
- **Actuation & Avionics**: Dual NEMA 17 steppers, anti-backlash 3:1 GT2 toothed belt drives, `AS5600` 12-bit magnetic absolute encoder, and transparent avionics bay housing ESP32-S3, dual `TMC2209` drivers, and `u-blox NEO-M8N` GPS.

---

## Repository Structure

```text
ARTICULATING-ANTINA/
├── index.html                                 # Self-contained Three.js 3D CAD studio & dual RF mission simulator
├── README.md                                  # Dual-system engineering overview & run instructions
├── cad/
│   ├── artemis_24ghz_helical_tracker.scad     # Parametric OpenSCAD model — ARTEMIS-24H (Helical)
│   ├── artemis_24ghz_helical_tracker.stl      # Watertight 3D mesh — ARTEMIS-24H (Helical)
│   ├── artemis_24ghz_yagi_tracker.scad        # Parametric OpenSCAD model — ARTEMIS-24Y (Yagi-Uda)
│   └── artemis_24ghz_yagi_tracker.stl         # Watertight 3D mesh — ARTEMIS-24Y (Yagi-Uda)
├── docs/
│   └── artemis_24ghz_antenna_designs_brief.pdf # 4-page product engineering & selection brief
└── firmware/
    ├── skylock_firmware.ino                   # ESP32 closed-loop stepper/encoder tracking firmware
    └── tracker_math.h                         # ENU transform, 300 ms dead-reckoning & curvature-corrected aiming
```

---

## Interactive Features in `index.html`

- **Dual Mission Usage Simulator** (exact JavaScript port of `firmware/tracker_math.h`):
  - **Helical Mission (24H)**: Agile banking 3D UAV flying a figure-8 corridor with 300 ms dead-reckoning (`predict`), animated RHCP wave rings, and a live rolling telemetry graph contrasting `0 dB` RHCP cross-pol fade against linear polarization roll fade.
  - **Yagi-Uda Mission (24Y)**: Long-range mobile ground relay rover with selectable Vertical (`0°`) / Horizontal (`90°`) target polarization, pulsing off-axis 2.4 GHz jammer tower, live $-20\log_{10}|\cos\Delta\phi|$ collar mismatch loss, >18 dB jammer rejection, and a live RSSI vs. jammer-floor graph.
- **High-Detail 3D CAD Studio**:
  - PBR metallic reflections (procedural studio PMREM environment), socket-head fasteners, flanged GT2 belt drives, exploded assembly (`0–100%`), manual Az/El/Pol sliders, tripod toggle, radome glass/solid/off toggle, wireframe view, and clickable 3D part callout pins.

---

## Running Locally

Serve the repository root with any local HTTP server (zero build step):

```bash
python -m http.server 8080
```

Then open [http://localhost:8080/](http://localhost:8080/) in your browser.
