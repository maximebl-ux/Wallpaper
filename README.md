# Neon Hong Kong — Live Audio Wallpaper

Neon Hong Kong skyline with audio-reactive bars rising into the sky and a live 12-hour (AM/PM) clock in the top right.

## Lively Wallpaper (recommended)

1. Download this repository: green **Code** button → **Download ZIP**.
2. Extract the ZIP (or use it as-is — Lively accepts both).
3. Open Lively Wallpaper → **+ Add Wallpaper** → drag the extracted folder (or the ZIP) in.
4. Right-click the wallpaper in the gallery → **Customise** → set **Audio Source** to your speakers/headphones.
5. Play any sound (YouTube, Spotify, a game) — the bars react automatically to everything your PC plays.

The `LivelyInfo.json` contains `"Arguments": "--audio"`, which is what tells Lively to feed system audio into the page via `livelyAudioListener()`.

If the bars do not move in Lively:
- Check **Settings → Audio** in Lively and make sure the capture device is your output device and volume/mute settings allow capture.
- If using the WebView2 renderer and audio still fails, try switching the renderer for this wallpaper to **CEF** (known WebView2 audio-listener bug).

## Wallpaper Engine

Import `wallpaper.html` (or `index.html`) as a **Web** wallpaper and enable **Audio responsive** in its properties.

## Browser preview

Open `wallpaper.html` in Chrome/Edge. Browsers cannot read system audio directly; click the hint pill at the bottom and share a Chrome tab with "share tab audio" checked to see the bars react to that tab.
