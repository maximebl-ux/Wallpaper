// ============================================================
//  Neon Skyline — user-facing settings
//  Parsed by Iris / OptiFine; editable in-game via
//  Options > Video Settings > Shader Packs > Shader Pack Settings
// ============================================================

// Shadows: 0 = off (flat lighting), 1 = PCF, 2 = wider soft PCF
#define SHADOW_QUALITY 1 // [0 1 2]
// Shadow map resolution (squared)
#define SHADOW_RES 2048 // [1024 2048 4096]

// Screen-space reflection ray-march steps for water (0 = sky-only reflections)
#define SSR_STEPS 20 // [0 8 12 16 20 24 32 48]
// Binary-search refinement of SSR hits (sharper reflections, small cost)
#define SSR_REFINE 1 // [0 1]
// Master toggle for water reflections
#define WATER_REFLECT 1 // [0 1]
// Overall reflectivity of the water surface
#define WATER_REFLECTIVITY 0.85 // [0.50 0.60 0.70 0.80 0.85 0.90 0.95 1.00]
// Height of the animated water ripples
#define RIPPLE_HEIGHT 1.00 // [0.00 0.50 1.00 1.50 2.00]

// Bloom master toggle and strength
#define BLOOM 1 // [0 1]
#define BLOOM_STRENGTH 0.55 // [0.25 0.35 0.45 0.55 0.70 0.85 1.00]

// Atmospheric fog density multiplier
#define FOG_DENSITY 1.00 // [0.00 0.25 0.50 0.75 1.00 1.25 1.50 2.00 3.00]

// Star brightness at night
#define STAR_BRIGHTNESS 1.00 // [0.00 0.50 1.00 1.50 2.00]

// Post-processing
#define EXPOSURE 1.00 // [0.60 0.70 0.80 0.90 1.00 1.10 1.20 1.40 1.60]
#define SATURATION 1.05 // [0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20]
#define CONTRAST 1.04 // [0.95 1.00 1.04 1.08 1.12]
#define VIGNETTE 1 // [0 1]
