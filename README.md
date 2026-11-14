# Neon Skyline Shaders

A premium-feeling Minecraft Java shader pack with a Hong Kong neon-skyline mood:
deep indigo and magenta skies that burn into coral and gold at dawn and dusk,
strongly reflective animated water, long soft shadows with violet shadow tones,
and a controlled filmic post pipeline.

Built for the **Iris** shader loader (**OptiFine-format pack**). Verified against
Iris **1.11.4+26.2-fabric** on Minecraft **26.2** (Fabric). Iris supports
Minecraft 1.16.5 through 26.3 on Fabric; this pack uses only long-established
OptiFine-format features and should also load under other Iris versions and
OptiFine-style loaders that support the same format.

## Install

1. Install Iris (with Sodium) for Minecraft 26.2 Fabric — e.g. Iris
   `1.11.4+26.2-fabric` from Modrinth/CurseForge — into your `mods` folder.
2. Copy `neon-skyline-shaders` (the folder) **or** `NeonSkyline_v1.0.0.zip` into
   `.minecraft/shaderpacks/`.
3. In-game: Options → Video Settings → Shader Packs → select *Neon Skyline*.

## Settings (Options → Video Settings → Shader Pack Settings)

Three quality **profiles**:

| Profile   | Shadows | Water SSR | Bloom |
|-----------|---------|-----------|-------|
| POTATO    | off     | sky-only  | off   |
| BALANCED  | PCF     | 16 steps  | on    |
| CINEMATIC | soft PCF| 32 steps + refine | on |

Individual options: shadow quality & resolution, water reflections,
reflectivity, ripple height, SSR steps/refinement, bloom strength, fog density,
star brightness, exposure, saturation, contrast, vignette.

**Most demanding features** (documented for performance):

- Water screen-space reflections (`SSR_STEPS`/`SSR_REFINE`) — the heaviest
  per-pixel cost; lower steps or disable for big gains.
- Shadow quality 2 (wider PCF radius) plus 4096 shadow maps.
- Bloom adds two cheap fullscreen passes; negligible on modern GPUs.

## Design notes

- Light from glowing blocks uses the **supported block-light data** (the vanilla
  lightmap channel), not texture emissiveness. Glowing textures do not cast
  light unless they also produce real block light (torches, lava, glowstone,
  etc. do). Beacon beams and spider eyes are rendered fullbright emissive.
- Dimensions are handled separately: Overworld (full pipeline), Nether
  (world-1: warm ambient, maroon fog, no sun shadows), End (world1: violet
  ambient, dimmed End sky, subtle fog).
- Water stays recognizably Minecraft: vanilla water texture/tint is preserved;
  reflections are blended with a Schlick fresnel and fade to the procedural sky
  at screen edges so reflections never break at borders.
- All code is original; the palette is inspired by stylized Hong Kong skyline
  artwork (used as a mood/palette reference only).

## Layout

```
shaders/
  shaders.properties   options, profiles, screens
  block.properties     water block-id mapping
  settings.glsl        user-facing defines
  lib/                 palette, sky, lighting, shadows, water, noise
  src/                 shared program sources (dimension-agnostic)
  world-1/             Nether program variants
  world1/              End program variants
  gbuffers_*.vsh/.fsh  geometry passes (terrain, entities, hand, water, sky…)
  shadow.vsh/.fsh      shadow map pass
  composite*.fsh       fog + water reflections, bloom blur
  final.fsh            bloom composite, ACES tonemap, grade, vignette, dither
```
