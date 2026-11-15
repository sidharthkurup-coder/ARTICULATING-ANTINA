# SkyLock: GPS-Based 2.4 GHz Articulating High-Gain Antenna System for UAVs

An automated two-axis antenna tracking system that uses real-time GPS coordinates and velocity prediction to continuously track unmanned aerial vehicles (UAVs) and maintain high-gain, long-range stable communication links.

![SkyLock Antenna Tracker](skylock_design_doc.pdf)

## 📌 Problem & Overview

A standard 2.4 GHz omnidirectional antenna (~2 dBi) on UAV video or data links rapidly exhausts link margin beyond a few kilometers. A **14 dBi directional patch antenna** adds **+12 dB of gain**, quadrupling operational range, but features a narrow **~30° half-power beamwidth**. 

**SkyLock** continuously aims this high-gain beam directly at the drone in real time:
- Ingests drone GPS coordinates and velocity via standard MAVLink telemetry (`GLOBAL_POSITION_INT`).
- Computes spherical pointing angles (true bearing azimuth & curvature-compensated elevation) at 20 Hz.
- Drives an articulating pan-tilt gimbal head with dual NEMA17 steppers via 5:1 GT2 belt reductions and dual AS5600 12-bit magnetic absolute encoders for closed-loop recovery.

---

## 🚀 Key Engineering Highlights

1. **Independent Telemetry & Payload Links**:
   Telemetry runs on a separate sub-GHz omnidirectional link (433/915 MHz SiK radio). A temporary pointing error on the 2.4 GHz payload beam never cuts position telemetry needed to recover.
2. **Predictive Dead-Reckoning**:
   Compensates for 300 ms telemetry packet latency by extrapolating drone position forward using reported 3D velocity vectors:
   $$\vec{P}_{\text{aim}} = \vec{P} + \vec{V} \cdot \Delta t$$
3. **Closed-Loop Absolute Encoders**:
   On-axis AS5600 12-bit magnetic encoders maintain ground truth orientation across reboots and automatically snap back step position in case of external wind gusts or bumps without homing switches.
4. **Sight-In Heading Calibration**:
   Compass-free heading reference avoids motor EMI distortion. Point tracker at hovering drone, press ALIGN, and true heading is resolved from GPS geometry.
5. **Zenith Azimuth Hold**:
   Freezes azimuth drive above 85° elevation where gimbal rate singularity occurs.

---

## 📊 Specifications & Link Budget

| Parameter | Specification |
| :--- | :--- |
| **Payload Antenna** | 14 dBi 2.4 GHz 2×2 Phased Patch Array (~30° Beamwidth, RHCP) |
| **Pan Travel** | ±180° (360° total about mount forward axis) |
| **Tilt Travel** | 0° to 90° (horizontal to zenith) |
| **Slew Performance** | 90°/s maximum slew rate, 300°/s² acceleration |
| **Step Resolution** | 0.0225° / step (1/16 microstepping, 5:1 belt reduction) |
| **Encoder Resolution**| 0.088° (12-bit AS5600, 4096 counts/rev) |
| **Aim Update Rate** | 20 Hz (50 ms cycle) |
| **Telemetry Rate** | 5 Hz MAVLink (`GLOBAL_POSITION_INT`) with 300 ms simulated latency |

### Link Budget (Free-Space, 2.4 GHz)

$$\text{FSPL} = 20 \log_{10}(d_{\text{km}}) + 20 \log_{10}(f_{\text{MHz}}) + 32.44$$
$$\text{Pointing Loss} \approx 12 \left(\frac{\theta_{\text{err}}}{\theta_{3\text{dB}}}\right)^2 \text{dB}$$

| Item | Stock Omni (2 dBi) | SkyLock Tracked (14 dBi) |
| :--- | :---: | :---: |
| Drone Tx Power | +27 dBm | +27 dBm |
| Drone Antenna Gain | +2 dBi | +2 dBi |
| Ground Antenna Gain | +2 dBi | **+14 dBi** |
| Cable & Insertion Loss | -1 dB | -1 dB |
| Path Loss (10 km) | -120 dB | -120 dB |
| **Received Power** | **-90 dBm** | **-78 dBm** (+12 dB) |
| Receiver Sensitivity | -95 dBm | -95 dBm |
| **Fade Margin (10 km)** | **5 dB (Marginal)** | **17 dB (Robust)** |

---

## 🛠️ Repository Contents

- **`index.html`**: Interactive, self-contained 3D simulation built with Three.js (CDN-based, zero build step):
  - **Photorealistic PBR 3D Model**: Heavy-duty tripod, pan-tilt gimbal, dual NEMA17 steppers, 5:1 GT2 flanged pulleys, dual AS5600 encoder boards, transparent ESP32 + TMC2209 avionics bay, u-blox NEO-M8N GPS, and Sub-GHz radio.
  - **14 dBi 2×2 Phased Patch Array**: High-resolution Rogers/FR4 substrate, Wilkinson microstrip feed network, raised 3D gold mitered patch plates, polycarbonate radome, and traveling-wave RF beam cone.
  - **Interactive Flight Path**: 100 m to 1500 m 3D figure-8 flight corridor with range rings and drop shadow.
  - **Exact Math Port**: Exact JavaScript implementation of `tracker_math.h` (`wrap180`, `toENU`, `predict`, `aimAt`).
  - **Exploded View & 3D Callouts**: Inspect all internal avionics, motors, and transmission systems.
  - **Live HUD Panel**: Real-time target vs actual angles, pointing error, pointing loss, and comparative link budget.
- **`skylock_firmware.ino`**: ESP32 C++ firmware utilizing `FastAccelStepper`, `TinyGPSPlus`, and `MAVLink c_library_v2`.
- **`tracker_math.h`**: Header-only math library for local ENU coordinates, dead-reckoning prediction, and curvature-corrected elevation calculation.
- **`skylock_design_doc.pdf`**: Complete architectural design and engineering specification document.

---

## 🖥️ Running the Interactive 3D Demo

Simply serve the repository folder with any local HTTP server:

```bash
# Using Python
python -m http.server 8080

# Or with Node.js
npx serve .
```

Open `http://localhost:8080/` in your browser.
