#pragma once
#include <math.h>

struct Geo  { double lat, lon, alt; };      // deg, deg, metres MSL
struct Vec3 { double e, n, u; };            // metres (or m/s): east, north, up
struct Aim  { double az, el, range; };      // true bearing deg, elevation deg, metres

constexpr double R_EARTH = 6371000.0;
constexpr double D2R     = M_PI / 180.0;

// Wrap any angle to [-180, 180)
inline double wrap180(double a) { a = fmod(a + 180.0, 360.0); if (a < 0) a += 360.0; return a - 180.0; }

// Drone position relative to the tracker (local tangent plane, <5 m error out to ~50 km)
inline Vec3 toENU(const Geo& g, const Geo& d) {
  double mlat = 0.5 * (g.lat + d.lat) * D2R;
  return { (d.lon - g.lon) * D2R * cos(mlat) * R_EARTH,
           (d.lat - g.lat) * D2R * R_EARTH,
            d.alt - g.alt };
}

// Dead-reckon a position forward by dt seconds
inline Vec3 predict(const Vec3& p, const Vec3& v, double dt) {
  return { p.e + v.e * dt, p.n + v.n * dt, p.u + v.u * dt };
}

// Azimuth / elevation / range; elevation includes the earth-curvature drop h^2 / 2R
inline Aim aimAt(const Vec3& v) {
  double h  = hypot(v.e, v.n);
  double az = atan2(v.e, v.n) / D2R;
  if (az < 0) az += 360.0;
  double el = atan2(v.u - h * h / (2.0 * R_EARTH), h) / D2R;
  return { az, el, sqrt(h * h + v.u * v.u) };
}
