// Deferred lighting: shadows, ambient, block light, water reflections,
// volumetric light and fog. Reads albedo/normal/lightmap from the
// gbuffers, writes the lit scene to colortex0.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
#ifndef DIM_NETHER
#ifndef DIM_END
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
#endif
#endif

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform int isEyeInWater;

in vec2 uv;

vec3 screenToView(vec2 uvIn, float depth) {
    vec4 ndc = vec4(uvIn, depth, 1.0) * 2.0 - 1.0;
    vec4 view = gbufferProjectionInverse * ndc;
    return view.xyz / view.w;
}

// ------------------------------------------------ shadows
#if !defined(DIM_NETHER) && !defined(DIM_END) && defined(SHADOWS)
float sampleShadow(vec3 playerPos, vec3 viewNormal, float NdotL) {
    vec4 shadowClip = shadowProjection * (shadowModelView * vec4(playerPos, 1.0));
    vec2 sv = distortShadow(shadowClip.xy);
    float distortFactor = (1.0 - SHADOW_DISTORT_STRENGTH) + length(shadowClip.xy) * SHADOW_DISTORT_STRENGTH;
    vec3 sp3 = vec3(sv, shadowClip.z) * 0.5 + 0.5;

    // Slope- and distortion-scaled depth bias against shadow acne
    float bias = (0.0006 + 0.0018 * (1.0 - NdotL)) * distortFactor * distortFactor * 4.0;
    float ref = sp3.z - bias;

    float dither = interleavedGradientNoise(gl_FragCoord.xy) * 6.2831853;
    mat2 rot = mat2(cos(dither), -sin(dither), sin(dither), cos(dither));
    float texel = 1.0 / float(shadowMapResolution);
    float radius = texel * SHADOW_SOFTNESS * 2.0;

    float sum = 0.0;
    float wsum = 0.0;
#if SHADOW_FILTER == 0
    float s1 = texture(shadowtex1, sp3.xy).r;
    float s0 = texture(shadowtex0, sp3.xy).r;
    if (s1 < ref) sum = 0.0;
    else if (s0 < ref) {
#ifdef SHADOW_COLOR
        vec4 sc = texture(shadowcolor0, sp3.xy);
        sum = luma(sc.rgb) * sc.a;
#else
        sum = 0.0;
#endif
    } else sum = 1.0;
    wsum = 1.0;
#else
#if SHADOW_FILTER == 1
    const int TAPS = 4;
#elif SHADOW_FILTER == 2
    const int TAPS = 8;
#else
    const int TAPS = 16;
#endif
    for (int i = 0; i < TAPS; i++) {
        float a = (float(i) + interleavedGradientNoise(gl_FragCoord.xy)) * 2.3999632;
        vec2 offs = rot * vec2(cos(a), sin(a)) * radius * (0.5 + 0.5 * float(i) / float(TAPS));
        vec2 sp = sp3.xy + offs;
        float s1 = texture(shadowtex1, sp).r;
        float s0 = texture(shadowtex0, sp).r;
        float sh;
        if (s1 < ref) sh = 0.0;
        else if (s0 < ref) {
#ifdef SHADOW_COLOR
            vec4 sc = texture(shadowcolor0, sp);
            sh = luma(sc.rgb) * sc.a;
#else
            sh = 0.0;
#endif
        } else sh = 1.0;
        sum += sh;
        wsum += 1.0;
    }
#endif
    return sum / wsum;
}
#endif // shadows

// ------------------------------------------------ screen space AO
#ifdef SSAO
float computeSSAO(vec2 uvIn, vec3 viewPos, vec3 viewNormal) {
    float occl = 0.0;
    float dither = interleavedGradientNoise(gl_FragCoord.xy);
    float radius = clamp(24.0 / max(-viewPos.z, 0.5), 1.0, 48.0);
    vec2 scale = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    for (int i = 0; i < 8; i++) {
        float a = (float(i) + dither) * 2.3999632;
        float r = radius * (0.35 + 0.65 * fract(float(i) * 0.618 + dither));
        vec2 offs = vec2(cos(a), sin(a)) * r * scale;
        float sd = texture(depthtex0, uvIn + offs).r;
        vec3 sp = screenToView(uvIn + offs, sd);
        vec3 dv = sp - viewPos;
        float len = length(dv);
        if (len > 0.05 && len < radius * 2.0) {
            // Point above the surface plane occludes it
            float planeDist = dot(viewNormal, dv);
            occl += clamp(planeDist / len, 0.0, 1.0) * clamp(1.0 - len / (radius * 2.0), 0.0, 1.0);
        }
    }
    return clamp(1.0 - occl / 8.0, 0.0, 1.0);
}
#endif

// ------------------------------------------------ water reflections
#if WATER_QUALITY >= 2
bool ssrTrace(vec3 viewPos, vec3 reflDir, out vec3 hitColor) {
    hitColor = vec3(0.0);
    vec3 pos = viewPos + reflDir * 0.15;
    float stepLen = 0.35 + 0.02 * length(viewPos);
    vec4 clip = gbufferProjection * vec4(pos, 1.0);
    if (clip.w <= 0.0) return false;
    vec2 suv = (clip.xy / clip.w) * 0.5 + 0.5;
    if (any(lessThan(suv, vec2(0.0))) || any(greaterThan(suv, vec2(1.0)))) return false;

#if WATER_QUALITY == 3
    const int STEPS = 24;
#else
    const int STEPS = 14;
#endif
    for (int i = 0; i < STEPS; i++) {
        pos += reflDir * stepLen;
        stepLen *= 1.35;
        clip = gbufferProjection * vec4(pos, 1.0);
        if (clip.w <= 0.0) return false;
        suv = (clip.xy / clip.w) * 0.5 + 0.5;
        if (any(lessThan(suv, vec2(0.0))) || any(greaterThan(suv, vec2(1.0)))) return false;
        float sd = texture(depthtex0, suv).r;
        vec3 sp = screenToView(suv, sd);
        float posDepth = length(pos);
        float sceneDepth = length(sp);
        if (sceneDepth < posDepth - 0.05 && sceneDepth > posDepth - 12.0) {
            // Fade near screen edges so reflections never tear at borders
            vec2 fade = smoothstep(vec2(0.0), vec2(0.08), suv) * smoothstep(vec2(0.0), vec2(0.08), 1.0 - suv);
            float w = fade.x * fade.y;
            hitColor = texture(colortex0, suv).rgb;
            return w > 0.01;
        }
    }
    return false;
}
#endif

// ------------------------------------------------ volumetric light
#if VOLUMETRIC_LIGHT > 0
vec3 volumetricLight(vec2 uvIn, vec3 sunCol, float dayF, float duskF, float nightF, float rain) {
#if VOLUMETRIC_LIGHT == 2
    const int SAMPLES = 24;
#else
    const int SAMPLES = 14;
#endif
    vec4 lightClip = gbufferProjection * vec4(shadowLightPosition, 1.0);
    if (lightClip.w <= 0.0 || abs(lightClip.x) > 1.6 || abs(lightClip.y) > 1.6) return vec3(0.0);
    vec2 lightUv = (lightClip.xy / lightClip.w) * 0.5 + 0.5;
    vec2 delta = (lightUv - uvIn) / float(SAMPLES);
    vec2 p = uvIn;
    float weight = 1.0;
    float acc = 0.0;
    float tot = 0.0;
    for (int i = 0; i < SAMPLES; i++) {
        p += delta;
        p = clamp(p, vec2(0.0), vec2(1.0));
        float d = texture(depthtex0, p).r;
        acc += (d > 0.9999 ? weight : 0.0);
        tot += weight;
        weight *= 0.93;
    }
    float shaft = acc / max(tot, 1e-4);
    vec3 vlCol = sunCol * mix(0.35, 0.9, duskF) * (0.25 + 0.75 * (dayF + duskF));
    return vlCol * shaft * (1.0 - rain) * 0.35;
}
#endif

void main() {
    vec3 albedo = texture(colortex0, uv).rgb;
    vec4 nm = texture(colortex1, uv);
    vec4 lmData = texture(colortex2, uv);
    float depth = texture(depthtex0, uv).r;
    float matFlag = lmData.b;

    vec3 color = albedo;

    vec2 lm = lmData.rg;
    vec3 sunDirW = normalize(mat3(gbufferModelViewInverse) * normalize(sunPosition));
    float dayF, duskF, nightF;
    timeFactors(sunDirW.y, dayF, duskF, nightF);

    if (matFlag < 0.45 && depth < 1.0) {
        vec3 viewPos = screenToView(uv, depth);
        vec3 viewNormal = decodeNormal(nm.rg);
        vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);

        vec3 sunCol = sunLightColor(dayF, duskF, nightF, rainStrength);
        vec3 ambCol = ambientColor(dayF, duskF, nightF, rainStrength);

        // ---- direct light + shadow
        vec3 lightDirView = normalize(shadowLightPosition);
        float NdotL = dot(viewNormal, lightDirView);
        float shadow = 1.0;
#if !defined(DIM_NETHER) && !defined(DIM_END) && defined(SHADOWS)
        if (NdotL > 0.0) {
            vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
            shadow = sampleShadow(playerPos, viewNormal, NdotL);
        } else {
            shadow = 0.0;
        }
        if (matFlag > 0.2 && matFlag < 0.3) shadow = shadow * 0.6 + 0.4; // leaves transmit light
#endif
#ifdef DIM_NETHER
        vec3 direct = vec3(0.0);
        vec3 ambCol2 = vec3(0.22, 0.07, 0.05);
#elif defined(DIM_END)
        vec3 direct = vec3(0.0);
        vec3 ambCol2 = vec3(0.10, 0.08, 0.17);
#else
        vec3 direct = sunCol * shadow * clamp(NdotL, 0.0, 1.0) * (0.15 + 0.85 * smoothstep(0.0, 0.4, lm.y));
        vec3 ambCol2 = ambCol;
#endif

        // ---- ambient (hemispheric + skylight falloff into caves)
        float skyLight = lm.y * lm.y;
        float hemi = 0.75 + 0.25 * viewNormal.y;
        vec3 ambient = ambCol2 * (0.10 + 0.90 * skyLight) * hemi;

#ifdef SSAO
#ifndef DIM_NETHER
        #ifndef DIM_END
        if (matFlag < 0.95) {
            float ao = computeSSAO(uv, viewPos, viewNormal);
            ambient *= mix(1.0, ao, SSAO_STRENGTH);
        }
        #endif
#endif
#endif

        // ---- block light (vanilla lightmap value; the only real
        //      per-block light source information available here)
        float bl = lm.x;
        vec3 block = blockLightColor() * (bl * bl * bl * 2.4 + bl * 0.12);

        vec3 lighting = direct + ambient + block + MIN_LIGHT;
        color = albedo * lighting;

        // Surfaces hit by strong block light are pushed into HDR so the
        // bloom pass picks them up as a glow
        float emissive = smoothstep(0.82, 1.0, lm.x);
        color += albedo * emissive * 1.4 * EMISSIVE_STRENGTH;

        if (matFlag > 0.95) color = albedo * 2.2; // beacon beams, spider eyes

        // ---- water reflections and sun glint
        if (matFlag > 0.7 && matFlag < 0.8) {
            vec3 viewDir = normalize(viewPos);
            float cosTheta = clamp(dot(-viewDir, viewNormal), 0.0, 1.0);
            float F = 0.02 + 0.98 * pow(1.0 - cosTheta, 5.0);
            vec3 reflection = vec3(0.0);
#if WATER_QUALITY >= 1
            vec3 reflWorld = normalize(mat3(gbufferModelViewInverse) * reflect(viewDir, viewNormal));
            reflWorld.y = max(reflWorld.y, 0.02);
            reflection = renderSky(reflWorld, sunDirW, cameraPosition, dayF, duskF, nightF, rainStrength, frameTimeCounter);
#endif
#if WATER_QUALITY >= 2
            vec3 hitColor;
            if (ssrTrace(viewPos, reflect(viewDir, viewNormal), hitColor)) {
                vec2 edgeFade = smoothstep(vec2(0.0), vec2(0.1), uv) * smoothstep(vec2(0.0), vec2(0.1), 1.0 - uv);
                reflection = mix(reflection, hitColor, clamp(edgeFade.x * edgeFade.y, 0.0, 1.0) * 0.85);
            }
#endif
            color = mix(color, reflection, clamp(0.25 + F * 0.75, 0.0, 1.0));
#ifdef WATER_SPECULAR
            vec3 h = normalize(lightDirView - viewDir);
            float spec = pow(max(dot(viewNormal, h), 0.0), 240.0) * shadow;
            color += sunCol * spec * 2.0;
#endif
        }

        // ---- volumetric light shafts
#if VOLUMETRIC_LIGHT > 0
#ifndef DIM_NETHER
        #ifndef DIM_END
        if (isEyeInWater == 0) {
            color += volumetricLight(uv, sunCol, dayF, duskF, nightF, rainStrength);
        }
        #endif
#endif
#endif

        // ---- fog
        float dist = length(viewPos);
#if defined(DIM_NETHER)
        vec3 fogCol = vec3(0.10, 0.045, 0.035);
        float fogF = 1.0 - exp(-dist * dist * 4.0e-7 * FOG_DENSITY);
#elif defined(DIM_END)
        vec3 fogCol = vec3(0.025, 0.02, 0.05);
        float fogF = 1.0 - exp(-dist * dist * 1.2e-7 * FOG_DENSITY);
#else
        vec3 fogCol = skyGradient(worldDir, sunDirW, dayF, duskF, nightF, rainStrength);
        fogCol = mix(fogCol, fogCol * vec3(0.55, 0.58, 0.65), rainStrength * 0.7);
        float fogF = 1.0 - exp(-dist * dist * 1.6e-7 * FOG_DENSITY);
        // Low mist at dawn and dusk
        float mist = duskF * exp(-max(viewPos.y, 0.0) * 0.08) * 0.25 * FOG_DENSITY;
        fogF = 1.0 - (1.0 - fogF) * (1.0 - mist * smoothstep(0.4, 0.9, lm.y));
#endif
        fogF *= smoothstep(0.25, 0.85, lm.y); // no sky fog inside caves
        if (isEyeInWater == 1) {
            fogCol = vec3(0.016, 0.10, 0.14) * (0.3 + 0.7 * lm.y);
            fogF = 1.0 - exp(-dist * 0.09);
        } else if (isEyeInWater == 2) {
            fogCol = vec3(0.45, 0.16, 0.02);
            fogF = 1.0 - exp(-dist * 2.0);
        }
        color = mix(color, fogCol, clamp(fogF, 0.0, 1.0));
    } else if (isEyeInWater == 1) {
        // Underwater fog also covers the sky visible through the surface
        float dist = far;
        vec3 fogCol = vec3(0.016, 0.10, 0.14);
        color = mix(color, fogCol, clamp(1.0 - exp(-dist * 0.09), 0.0, 1.0));
    }

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}
