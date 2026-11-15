// SkyLock - GPS-based 2-axis 2.4 GHz antenna tracker (ESP32)
// Libraries: FastAccelStepper, TinyGPSPlus, MAVLink c_library_v2 (common)
#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <Wire.h>
#include <FastAccelStepper.h>
#include <TinyGPSPlus.h>
#include <common/mavlink.h>
#include "tracker_math.h"

// ---------- hardware config ----------
constexpr int PAN_STEP = 18, PAN_DIR = 19, TILT_STEP = 23, TILT_DIR = 27, EN_PIN = 13;
constexpr float STEPS_PER_DEG = 200 * 16 * 5 / 360.0f;   // 1.8 deg motor x 1/16 microstep x 5:1 belt
constexpr uint32_t MAX_HZ = 90 * STEPS_PER_DEG;          // 90 deg/s slew
constexpr int32_t  ACCEL  = 300 * STEPS_PER_DEG;         // 300 deg/s^2
constexpr float PAN_SIGN = 1, TILT_SIGN = 1;             // set -1 if an encoder counts the wrong way

// ---------- state ----------
struct Drone { Geo g; Vec3 v; uint32_t t; bool ok; };
Drone drone{};
Geo ground{};  bool locked = false;
Aim aim{};
float heading = 0, panZero = 0, tiltZero = 0;            // heading = true bearing of pan zero

FastAccelStepperEngine engine;
FastAccelStepper *pan, *tilt;
TinyGPSPlus gps;
Preferences prefs;
WebServer web(80);

bool link() { return drone.ok && millis() - drone.t < 3000; }
int32_t steps(double deg) { return (int32_t)(deg * STEPS_PER_DEG); }

// ---------- encoders (AS5600, 12-bit absolute) ----------
float readAS5600(TwoWire& w) {
  w.beginTransmission(0x36); w.write(0x0C);
  if (w.endTransmission(false) != 0 || w.requestFrom(0x36, 2) != 2) return NAN;
  uint8_t hi = w.read(), lo = w.read();
  return (((hi << 8) | lo) & 0x0FFF) * 360.0f / 4096.0f;
}
float axisDeg(TwoWire& w, float zero, float sign, float fallback) {
  float a = readAS5600(w);
  return isnan(a) ? fallback : wrap180((a - zero) * sign);
}
// Encoder is ground truth: if the axis lost steps, snap the stepper position back to it
void resync(FastAccelStepper* s, TwoWire& w, float zero, float sign) {
  float now = s->getCurrentPosition() / STEPS_PER_DEG;
  float err = wrap180(axisDeg(w, zero, sign, now) - now);
  if (fabsf(err) > 3) s->forceStopAndNewPosition(steps(now + err));   // aimTick re-targets
}

// ---------- inputs ----------
void readMavlink() {
  mavlink_message_t m; mavlink_status_t st;
  while (Serial2.available())
    if (mavlink_parse_char(MAVLINK_COMM_0, Serial2.read(), &m, &st) && m.msgid == MAVLINK_MSG_ID_GLOBAL_POSITION_INT) {
      mavlink_global_position_int_t p; mavlink_msg_global_position_int_decode(&m, &p);
      if (p.lat || p.lon)
        drone = { {p.lat / 1e7, p.lon / 1e7, p.alt / 1000.0}, {p.vy / 100.0, p.vx / 100.0, -p.vz / 100.0}, millis(), true };
    }
}
// Average 30 good fixes, then freeze: the base is stationary
void updateGround() {
  static Geo sum{}; static int n = 0;
  while (Serial1.available()) gps.encode(Serial1.read());
  if (locked || !gps.location.isUpdated() || !gps.location.isValid() || gps.hdop.hdop() > 2.0 || gps.satellites.value() < 8) return;
  sum.lat += gps.location.lat(); sum.lon += gps.location.lng(); sum.alt += gps.altitude.meters();
  if (++n == 30) { ground = {sum.lat / n, sum.lon / n, sum.alt / n}; locked = true; }
}

// ---------- control ----------
void aimTick() {                                          // 20 Hz
  if (!locked || !drone.ok) return;
  double dt = fmin((millis() - drone.t) / 1000.0, 5.0);   // dead-reckon through telemetry gaps, then hold
  aim = aimAt(predict(toENU(ground, drone.g), drone.v, dt));
  if (aim.el < 85) pan->moveTo(steps(wrap180(aim.az - heading)));   // hold azimuth near zenith
  tilt->moveTo(steps(fmax(0.0, fmin(90.0, aim.el))));
}

// ---------- calibration ----------
bool align() {                                            // antenna hand-aimed at a hovering drone
  if (!locked || !drone.ok) return false;
  float p = axisDeg(Wire, panZero, PAN_SIGN, 0), t = axisDeg(Wire1, tiltZero, TILT_SIGN, 0);
  heading = wrap180(aimAt(toENU(ground, drone.g)).az - p);
  prefs.putFloat("hdg", heading);
  pan->forceStopAndNewPosition(steps(p)); tilt->forceStopAndNewPosition(steps(t));
  digitalWrite(EN_PIN, LOW);
  return true;
}
void zeroAxes() {                                         // antenna facing mount-forward and level
  float a = readAS5600(Wire), b = readAS5600(Wire1);
  if (isnan(a) || isnan(b)) return;
  panZero = a; tiltZero = b;
  prefs.putFloat("pz", a); prefs.putFloat("tz", b);
}

// ---------- phone dashboard ----------
const char PAGE[] PROGMEM = R"HTML(<meta name=viewport content="width=device-width"><body style="font:18px system-ui;background:#0b0f14;color:#e6edf3;padding:12px">
<h2>SkyLock Tracker</h2><pre id=s></pre>
<button onclick="c('/free')">1 FREE</button> <button onclick="c('/align')">2 ALIGN</button> <button onclick="c('/zero')">ZERO</button>
<script>const c=p=>fetch(p).then(r=>r.text()).then(alert);
setInterval(async()=>s.textContent=JSON.stringify(await(await fetch('/status')).json(),null,1),500)</script>)HTML";

void setup() {
  Serial1.begin(9600, SERIAL_8N1, 32, 33);                // GPS
  Serial2.begin(57600, SERIAL_8N1, 16, 17);               // MAVLink telemetry radio
  Wire.begin(21, 22); Wire1.begin(25, 26);                // pan / tilt encoders
  pinMode(EN_PIN, OUTPUT); digitalWrite(EN_PIN, LOW);     // drivers on (active low)

  prefs.begin("trk", false);
  heading = prefs.getFloat("hdg", 0); panZero = prefs.getFloat("pz", 0); tiltZero = prefs.getFloat("tz", 0);

  engine.init();
  pan  = engine.stepperConnectToPin(PAN_STEP);  pan->setDirectionPin(PAN_DIR);
  tilt = engine.stepperConnectToPin(TILT_STEP); tilt->setDirectionPin(TILT_DIR);
  for (auto s : {pan, tilt}) { s->setSpeedInHz(MAX_HZ); s->setAcceleration(ACCEL); }
  pan->setCurrentPosition(steps(axisDeg(Wire, panZero, PAN_SIGN, 0)));     // absolute position survives power cycles
  tilt->setCurrentPosition(steps(axisDeg(Wire1, tiltZero, TILT_SIGN, 0)));

  WiFi.softAP("SkyLock", "skylock2g4");
  web.on("/", [] { web.send(200, "text/html", PAGE); });
  web.on("/status", [] {
    char b[256];
    snprintf(b, sizeof b, "{\"gps_lock\":%d,\"sats\":%u,\"link\":%d,\"az\":%.1f,\"el\":%.1f,\"range_m\":%.0f,\"pan\":%.1f,\"tilt\":%.1f,\"heading\":%.1f}",
             locked, (unsigned)gps.satellites.value(), link(), aim.az, aim.el, aim.range,
             pan->getCurrentPosition() / STEPS_PER_DEG, tilt->getCurrentPosition() / STEPS_PER_DEG, heading);
    web.send(200, "application/json", b);
  });
  web.on("/free",  [] { digitalWrite(EN_PIN, HIGH); web.send(200, "text/plain", "motors released: aim by hand, then ALIGN"); });
  web.on("/align", [] { web.send(200, "text/plain", align() ? "aligned" : "needs GPS lock + live telemetry"); });
  web.on("/zero",  [] { zeroAxes(); web.send(200, "text/plain", "axes zeroed"); });
  web.begin();
}

void loop() {
  updateGround(); readMavlink(); web.handleClient();
  static uint32_t tAim, tSync;
  if (millis() - tAim >= 50)    { tAim = millis();  aimTick(); }
  if (millis() - tSync >= 1000) { tSync = millis(); resync(pan, Wire, panZero, PAN_SIGN); resync(tilt, Wire1, tiltZero, TILT_SIGN); }
}
