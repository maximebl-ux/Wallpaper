#include "/lib/water.glsl"
#include "/lib/sky.glsl"

varying vec2 texcoord;

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;
    float depth0 = texture2D(depthtex0, texcoord).r;
    float depth1 = texture2D(depthtex1, texcoord).r;
    float waterFlag = texture2D(colortex1, texcoord).r;
    vec3 viewPos = toView(texcoord, depth0);
    vec3 worldRay = normalize(toMat3(gbufferModelViewInverse) * viewPos);
    float h = worldSunDirW().y;

    // ---- Water: reflections, fresnel, sun glint ----
    if (depth0 < 1.0 && waterFlag > 0.5) {
        vec3 worldPos = toMat3(gbufferModelViewInverse) * viewPos + cameraPosition;
        vec3 nWorld = waterNormal(worldPos.xz);

#if WATER_REFLECT == 1
        vec3 nView = normalize(toMat3(gbufferModelView) * nWorld);
        vec2 hitUv = vec2(0.0);
        float hitW = 0.0;
        vec3 ssr = ssrReflection(viewPos, nView, hitUv, hitW);

        // Sky reflection as the fallback keeps edges of the screen stable
        vec3 reflWorldRay = normalize(reflect(worldRay, nWorld));
#if defined(DIM_NETHER) || defined(DIM_END)
        vec3 skyRefl = skyAmbient(h) * 0.5;
#else
        vec3 skyRefl = renderSky(reflWorldRay, worldSunDirW(), h);
#endif
        vec3 reflection = mix(skyRefl, ssr, hitW);

        // Schlick fresnel; grazing views become mirror-like
        float fres = 0.02 + 0.98 * pow(1.0 - max(dot(-worldRay, nWorld), 0.0), 5.0);
        fres = clamp(fres * 1.6, 0.0, 1.0) * WATER_REFLECTIVITY;
        color = mix(color, reflection, fres);

        // Tight golden glint from the low sun
        vec3 lightDir = worldLightDirW();
        vec3 hv = normalize(lightDir - worldRay);
        float spec = pow(max(dot(nWorld, hv), 0.0), 220.0);
        color += sunLightColor(h) * spec * 2.5;
#endif
    }

    // ---- Atmospheric / dimensional fog ----
    if (isEyeInWater == 1) {
        float dist = length(viewPos);
        vec3 underwaterCol = vec3(0.05, 0.15, 0.22) * (0.25 + 0.75 * dayAmt(h));
        float f = 1.0 - exp2(-dist * 0.06);
        color = mix(color, underwaterCol, clamp(f, 0.0, 1.0));
    } else if (depth0 < 1.0) {
        float dist = length(viewPos);
#if defined(DIM_NETHER)
        vec3 fogCol = vec3(0.24, 0.06, 0.05);
        float f = 1.0 - exp2(-dist * 0.020 * FOG_DENSITY);
#elif defined(DIM_END)
        vec3 fogCol = vec3(0.06, 0.04, 0.10);
        float f = 1.0 - exp2(-dist * 0.008 * FOG_DENSITY);
#else
        vec3 fogCol = mix(skyHorizon(h), skyMid(h), clamp(worldRay.y, 0.0, 1.0));
        // Denser, warmer haze while the sun sits low
        float dens = (0.0016 + 0.0012 * duskAmt(h)) * FOG_DENSITY;
        float f = 1.0 - exp2(-dist * dens);
#endif
        color = mix(color, fogCol, clamp(f, 0.0, 1.0));
    }

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}
