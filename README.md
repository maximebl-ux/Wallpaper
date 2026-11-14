# Neon Horizons

A dawn/dusk-focused shader pack for Minecraft: Java Edition, inspired by the
mood and palette of a neon skyline at sunrise and sunset: deep indigo zenith,
magenta/coral/gold horizon band, violet shadow tones and strong water
reflections. Runs on the OptiFine/Iris shader-pack format.

## Verified target

| Component | Version |
|---|---|
| Minecraft | 26.2 (Java) |
| Loader | Fabric |
| Shader loader | Iris 1.11.4+26.2-fabric (with Sodium 0.9.2) |

The pack uses only standard OptiFine-format features Iris supports:
`shaders.properties` options/profiles, `block.properties`, gbuffers +
composite/final passes, screen-space and shadow effects. It is **not** a Fabric
mod - it is a shader pack.

## Install

1. Install Iris (Iris + Sodium) for Minecraft 26.2 on Fabric from
   https://irisshaders.dev or Modrinth.
2. Drop `NeonHorizons.zip` (or the unzipped `NeonHorizons` folder) into
   `.minecraft/shaderpacks/`.
3. In game: Options -> Video Settings -> Shader Packs -> select
   **NeonHorizons** -> Apply.

## Presets

Select in Shader Pack Settings -> Profile:

- **Performance** - 1024px shadows at short range, sky-only water reflections,
  no SSAO/volumetric light, low clouds. Keeps the full dawn/dusk palette.
- **Balanced (Stock)** - the shipped default, tuned first for an RTX 3050
  6 GB at 3840x2160. 2048px shadows, screen-space water reflections, SSAO,
  fast volumetric light. This is a design target, not a measured guarantee.
- **High** - 3072px shadows, longer SSR ray march, high volumetric light.
- **Ultra** - 4096px shadows, widest shadow distance, softest filtering.

Most expensive settings, in rough order: Shadow Resolution, Shadow Distance,
Water Reflections (screen-space ray march), Volumetric Light, Screen Space AO,
Shadow Filtering, Clouds. If you need more FPS, lower those first - the
dawn/dusk palette, water reflections and bloom stay on in every preset.

## Notes

- Block light comes from the vanilla lightmap value (torches, lava, glowstone
  etc. as Minecraft computes it). Surfaces with strong block light are pushed
  into bloom. Texture emissiveness alone is not treated as a light source.
- Nether and End have dedicated dimension programs (separate palettes, no
  sun shadows).
- Vanilla clouds are replaced by a procedural cloud layer
  (Clouds setting: Off / Low / High).
