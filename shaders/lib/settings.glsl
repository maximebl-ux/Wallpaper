// ============================================================
//  Neon Horizons - user settings
//  These defines are parsed by Iris/OptiFine and become the
//  in-game shader options. The values below are the shipped
//  defaults = the "Balanced (Stock)" profile, tuned first for
//  an RTX 3050 6 GB at 3840x2160.
// ============================================================

// ---------------- Shadows ----------------
#define SHADOWS
#define SHADOW_COLOR
const int shadowMapResolution = 2048; // [1024 1536 2048 3072 4096]
const float shadowDistance = 160.0; // [96.0 128.0 160.0 224.0 320.0]
#define SHADOW_FILTER 2 // [0 1 2 3]
#define SHADOW_SOFTNESS 1.0 // [0.5 0.75 1.0 1.25 1.5 2.0]
#define SHADOW_DISTORT_STRENGTH 0.85 // [0.70 0.75 0.80 0.85 0.90 0.95]
const float sunPathRotation = -35.0; // [-45.0 -35.0 -25.0 -15.0 0.0]

// ---------------- Lighting ----------------
#define AO_STRENGTH 1.0 // [0.0 0.5 1.0 1.5]
#define SSAO
#define SSAO_STRENGTH 0.6 // [0.3 0.45 0.6 0.7 0.75 0.8 0.9]
#define MIN_LIGHT 0.03 // [0.0 0.03 0.06 0.10]
#define EMISSIVE_STRENGTH 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define BLOCKLIGHT_TINT

// ---------------- Water ----------------
#define WATER_QUALITY 2 // [0 1 2 3]
#define WATER_WAVE_SIZE 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define WATER_WAVE_SPEED 1.0 // [0.5 0.75 1.0 1.25 1.5]
#define WATER_SPECULAR

// ---------------- Atmosphere ----------------
#define ATMOSPHERE
#define FOG_DENSITY 1.0 // [0.5 0.75 1.0 1.25 1.5 2.0]
#define VOLUMETRIC_LIGHT 1 // [0 1 2]
#define CLOUD_QUALITY 2 // [0 1 2]
#define CLOUD_COVERAGE 0.5 // [0.3 0.4 0.5 0.55 0.6 0.7]
#define STAR_BRIGHTNESS 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define RAIN_FOG

// ---------------- Post processing ----------------
#define BLOOM
#define BLOOM_STRENGTH 0.12 // [0.06 0.09 0.12 0.16 0.22]
#define BLOOM_THRESHOLD 0.65 // [0.5 0.55 0.6 0.65 0.7 0.8]
#define EXPOSURE 1.0 // [0.85 1.0 1.15 1.3]
#define SATURATION 1.08 // [0.9 1.0 1.08 1.15 1.25]
#define CONTRAST 1.03 // [0.95 1.0 1.03 1.06 1.1]
#define DITHERING
