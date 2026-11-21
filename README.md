# ARTEMIS — Dual 2.4 GHz Articulating Antenna Suite (Helical & Yagi-Uda)

Upgraded interactive 3D CAD studio, real-world RF mission simulator, parametric OpenSCAD/STL models, engineering brief PDF, and ESP32 tracking firmware for two tripod-mounted 2.4 GHz (2400–2483.5 MHz) articulating antenna systems:

1. **ARTEMIS-24H — 7-Turn Axial-Mode Helical Articulating Antenna** (~12.5 dBi, RHCP circular polarization, 41° HPBW, Ø110 mm aluminum reflector cup, Ø68×225 mm UV-ASA radome).
2. **ARTEMIS-24Y — 9-Element Yagi-Uda Articulating Antenna** (~13.0 dBi, linear polarization with indexed 0°–90° V/H collar, 38° E-plane HPBW, >18 dB F/B ratio, 264 mm square boom, tall 122 mm zenith-cleared U-fork).

## Repository Contents

- `index.html` — Self-contained Three.js 3D CAD studio & dual RF mission simulator (zero build step):
  - **Mission A (Helical):** Agile banking 3D UAV figure-8 telemetry link with 300 ms dead-reckoning (`tracker_math.h` port) and live RHCP vs. linear cross-polarization fade comparison.
  - **Mission B (Yagi-Uda):** Long-range mobile ground relay link with live V/H polarization collar matching and off-axis 2.4 GHz ISM interference rejection.
  - **CAD Studio & Explode:** Interactive exploded assembly (`0–100%`), field tripod, transparent ESP32 + TMC2209 avionics bay, NEMA 17 + 3:1 GT2 belt drives, AS5600 encoders, radome/shroud modes, and wireframe view.
- `cad/artemis_24ghz_helical_tracker.scad` & `.stl` — Parametric OpenSCAD source and watertight 3D mesh for ARTEMIS-24H.
- `cad/artemis_24ghz_yagi_tracker.scad` & `.stl` — Parametric OpenSCAD source and watertight 3D mesh for ARTEMIS-24Y.
- `docs/artemis_24ghz_antenna_designs_brief.pdf` — Concise 4-page product engineering brief covering both designs, components, functions, and selection guide.
- `firmware/skylock_firmware.ino` & `firmware/tracker_math.h` — ESP32 closed-loop tracking firmware and ENU/dead-reckoning math header.

## Running Locally

```bash
python -m http.server 8080
# Open http://localhost:8080/
```
