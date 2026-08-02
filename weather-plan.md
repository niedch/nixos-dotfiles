# Weather Popup Animation Plan

## Goal

Replace the static weather icon in the current-conditions row of the weather popup with a self-contained `WeatherScene` component that renders **animated weather visuals** based on the current WMO weather code (sun, clouds, rain, snow, thunder, fog). Add a **debug flag** to preview every animation type by cycling through all weather codes.

## Files

| Action | File |
|--------|------|
| **Create** | `home/quickshell/config/Components/Weather/WeatherScene.qml` |
| **Modify** | `home/quickshell/config/Components/Weather/WeatherPopup.qml` |

No changes needed in `WeatherWidget.qml` — it already exposes `weatherCode` and `isNight` as reactive properties.

## New component: `WeatherScene.qml`

### Public properties

```qml
property string weatherCode: ""   // WMO code from the widget (e.g. "113")
property bool isNight: false      // day/night, affects sun vs moon visuals
property bool debugCycle: false   // DEBUG FLAG: when true, cycles through all animations
```

### Debug flag (`debugCycle`)

- Set to `true` in code to preview every animation type; `false` for normal behavior.
- When enabled, `effectiveCode` cycles through a fixed list every 2 s:

```js
debugCodes = ["113", "116", "119", "143", "176", "179", "200", "266", "329"]
```

one code per animation category (clear, partly cloudy, cloudy, fog, rain, snow, thunder, heavy rain, heavy snow).

- `effectiveCode = debugCycle ? debugCodes[debugIndex] : weatherCode` — this single value drives all layer visibility.
- A small debug label (`debug: <code>`) overlays the scene while active.
- No mouse interaction — editing the property + Quickshell hot-reload is the only "toggle".

### Scene geometry

- `width: 110`, `height: 75` — fits the popup's 360 px card next to the temperature column.
- Layers are stacked inside an `Item` with `clip: true` so particles vanish cleanly at the edges.

### Layers & conditions

All layers coexist in the scene; visibility is driven by `effectiveCode` via boolean helper functions (`isSun`, `isCloudy`, `isRain`, `isSnow`, `isThunder`, `isFog`).

| Layer | Weather codes | Visual effect | Animation classes |
|-------|---------------|---------------|-------------------|
| **Sun** | 113 (day) | 3 crossing ray `Rectangle`s rotating slowly + pulsing center circle (yellow) | `RotationAnimation` (infinite), `SequentialAnimation` on `scale` |
| **Moon** | 113 (night) | Dim glow circle + 3 star dots twinkling | `SequentialAnimation`/`NumberAnimation` on `opacity` (staggered, infinite) |
| **Clouds** | 116, 119, 122, 143, 200 | 2–3 rounded `Rectangle` shapes drifting left→right | `NumberAnimation` on `x` (infinite, different durations, wrap-around via `onXChanged`) |
| **Rain** | 176, 263, 266, 293–308, 356, 359, 182–377 (rain group) | 25–45 falling slanted line drops | `Canvas` + `requestPaint()` driven by 30 fps `Timer` |
| **Snow** | 179, 227, 230, 323–338, 368, 371 | 25–50 white dots falling with sinusoidal horizontal drift | `Canvas` + `requestPaint()` driven by 30 fps `Timer` |
| **Thunder** | 200, 386, 389, 392, 395 | Rain canvas + dark cloud layer + random lightning flash | Rain (`Canvas`) + `SequentialAnimation` on `opacity` of a white overlay `Rectangle`, triggered by random `Timer` |
| **Fog** | 143, 248, 260 | 3 translucent horizontal bars drifting at different speeds with opacity fade | `NumberAnimation` on `x` + `NumberAnimation` on `opacity` |

### Particle systems (rain & snow)

Implemented on a **single** `Canvas` (one paint function, less overhead):

```js
// internal state
property var raindrops: []    // { x, y, len, speed }
property var snowflakes: []   // { x, y, r, speed, phase, driftAmp }

function step() { /* advance positions, reset off-screen particles to top */ }
function paintParticles(ctx) { /* switch on isRain/isSnow */ }
```

- A 30 fps `Timer` (`interval: 33`, `running: scene.visible`, `repeat: true`) calls `step()` then `canvas.requestPaint()`.
- Rain: slanted lines drawn with `ctx.strokeStyle = Colors.color6` (cyan), length ~6–12 px, speed ~150–300 px/s.
- Snow: filled circles, `ctx.fillStyle` white with alpha, slower speed, x position = `baseX + sin(phase) * driftAmp`.
- Particle arrays (re)initialized lazily on first visible frame and kept stable while visible.

### Cloud drift

- Rounded `Rectangle` shapes using `Colors.color8` at ~0.4 opacity.
- Each cloud has `NumberAnimation on x` looping with a `from`/`to` spanning the scene width; when `x` passes `scene.width`, the JS handler resets `x` to `-cloudWidth` so the loop reads as continuous travel.

### Lightning flash

- White full-scene `Rectangle` (opacity 0 by default).
- A random `Timer` (interval 3000–8000 ms) fires `SequentialAnimation`: `opacity 1 → 0.3 → 0` over ~200 ms. Repeats automatically via the timer.

## Popup modification

In `WeatherPopup.qml` (current-conditions `Row`, replacing the static `bigIcon` `Text`, lines 112–121):

```qml
WeatherScene {
  id: weatherScene
  width: 110
  height: 75
  anchors.verticalCenter: parent.verticalCenter
  weatherCode: root.target ? root.target.weatherCode : ""
  isNight: root.target ? root.target.isNight : false
}
```

- `import qs.Components.Weather` already present in the popup — the new type resolves automatically by directory layout (same as `BluetoothPopup`, `CalendarPopup`).
- The temperature/humidity column already sits next to it; no layout rework required.

## Quickshell animation classes used

All animations run through standard **QtQuick** animation types (Quickshell configs are QML, so the full QtQuick module is available):

| Class | Purpose here |
|-------|--------------|
| `NumberAnimation` | animate `x` (cloud drift), `y`, `scale` (sun pulse), `opacity` (fog fade) |
| `RotationAnimation` | rotate sun rays continuously (`loops: Animation.Infinite`) |
| `SequentialAnimation` | sun pulse (scale up/down), lightning flash (1→0.3→0), star twinkle |
| `ParallelAnimation` | run cloud x-drift + opacity together |
| `Behavior` | (optional) smooth day/night transitions if reused for icon color |
| `Animation.Infinite` | `loops` constant for endless sun/cloud/star loops |
| `Easing` types | `Easing.InOutSine` for breathing pulse, `Easing.OutCubic` for fades |
| `Timer` | 30 fps render ticker, random lightning trigger, debug code cycling |
| `Canvas` + `requestPaint()` | particle rendering (rain, snow) |
| `Quickshell.EasingCurve` (optional) | manual easing math if per-particle interpolation is needed |

Quickshell-specific: the scene lives inside a `PopupWindow`, so it should pause animation work when the popup is hidden (`Timer.running: weatherPopup.shown`) to save CPU.

## Verification

1. `mise run build desktop` — Nix build must pass.
2. Set `debugCycle: true`, run `mise run quickshell`, click the weather widget, and visually confirm each animation cycle.
3. Set `debugCycle` back to `false`, confirm real current weather renders correctly.
4. `mise run format` before committing.
