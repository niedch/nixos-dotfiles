pragma Singleton
import QtQuick
import qs

// Color surfaces for the shell. The foundational palette (foreground,
// background, accent, urgent, muted) comes from the user's theme-driven
// qs.Colors singleton. Per-surface roles are derived from those
// foundational colors; there is no shell.toml in this config, so
// shellValues stays empty and every token resolves to its fallback.
QtObject {
  id: root

  readonly property color foreground: Colors.foreground
  readonly property color background: Colors.background
  readonly property color accent: Colors.accent
  readonly property color urgent: Colors.color1
  readonly property color muted: Colors.color8

  // Flat dictionary of "section.key" -> raw string from shell.toml. Always
  // empty here; pick()/pickAlpha() fall through to fallbacks.
  property var shellValues: ({})

  function pick(key, fallback) {
    return fallback
  }

  function pickAlpha(key, fallback) {
    return fallback
  }

  // Resolve a flat color token: named roles map to the foundational palette,
  // a valid hex/rgb string passes through, anything else resolves to the
  // fallback.
  function flatColor(value, fallback) {
    var token = String(value || "").replace(/^\s+|\s+$/g, "")
    var role = token.toLowerCase()
    if (role === "transparent") return Qt.rgba(0, 0, 0, 0)
    if (role === "foreground" || role === "text") return root.foreground
    if (role === "accent") return root.accent
    if (role === "urgent") return root.urgent
    if (role === "muted") return root.muted
    if (role === "background") return root.background

    if (
      token.match(/^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$/)
      || token.match(/^[Rr][Gg][Bb][Aa]?\(/)
    ) return token

    return fallback
  }

  // Compose a color from a base-color key and its `-alpha` companion. With
  // shellValues empty both keys resolve to their fallbacks.
  function composed(colorKey, alphaKey, colorFallback, alphaFallback) {
    return Util.alpha(flatColor(pick(colorKey, colorFallback), colorFallback), pickAlpha(alphaKey, alphaFallback))
  }

  readonly property QtObject bar: QtObject {
    readonly property color background: root.background
    readonly property color text: root.foreground
    readonly property color active: root.urgent
  }
  readonly property QtObject popups: QtObject {
    readonly property color background: root.background
    readonly property color text: root.foreground
    readonly property color border: Colors.color0
  }
  readonly property QtObject tooltip: QtObject {
    readonly property color background: root.background
    readonly property color text: root.foreground
    readonly property color border: Colors.color0
  }
  readonly property QtObject notifications: QtObject {
    readonly property color background: root.background
    readonly property color text: root.foreground
    readonly property color border: Colors.color0
    readonly property color countdown: root.accent
  }
  readonly property QtObject menu: QtObject {
    readonly property color background: root.background
    readonly property color text: root.foreground
    readonly property color border: Colors.color0
    readonly property color scrim: Util.alpha(root.background, 0.5)
    readonly property color selectedBackground: Util.alpha(root.foreground, 0.08)
    readonly property color selectedText: root.accent
    readonly property color selectedBorder: Qt.rgba(0, 0, 0, 0)
  }
  // polkit + lock share a single border-alpha across border / border-active /
  // border-error: the three states are mutually exclusive in time, so one
  // companion is enough.
  readonly property QtObject polkit: QtObject {
    readonly property color background: root.background
    readonly property color text: root.foreground
    readonly property color textError: root.urgent
    readonly property color border: Colors.color0
    readonly property color borderError: root.urgent
    readonly property color accent: root.accent
    readonly property color scrim: Util.alpha(root.background, 0.5)
  }
  readonly property QtObject lock: QtObject {
    readonly property color background: Util.alpha(root.background, 0.8)
    readonly property color text: root.foreground
    readonly property color placeholder: Util.alpha(root.foreground, 0.66)
    readonly property color textError: root.urgent
    readonly property color border: Colors.color0
    readonly property color borderActive: root.accent
    readonly property color borderError: root.urgent
    readonly property color selection: Util.alpha(root.accent, 0.45)
  }
  // The image picker has no card surface; `scrim` is the full-screen dim
  // wash, and per-slice dim overlays / text outlines use the foundational
  // `background` color directly.
  readonly property QtObject imagePicker: QtObject {
    readonly property color scrim: Util.alpha(root.background, 0.5)
    readonly property color text: root.foreground
    readonly property color selectedBorder: root.accent
    readonly property color unselectedBorder: Util.alpha(root.foreground, 0.28)
  }
}
