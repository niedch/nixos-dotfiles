import QtQuick

QtObject {
  id: root

  readonly property string prefixSymbols: ":"
  readonly property string prefixCalc: "="
  readonly property string prefixWeb: "@"
  readonly property string prefixClipboard: "$"
  readonly property string webSearchUrl: "https://duckduckgo.com/?q="

  function detectMode(text) {
    if (text.startsWith(root.prefixSymbols)) return root.prefixSymbols
    if (text.startsWith(root.prefixCalc)) return root.prefixCalc
    if (text.startsWith(root.prefixWeb)) return root.prefixWeb
    if (text.startsWith(root.prefixClipboard)) return root.prefixClipboard
    return ""
  }

  function placeholderText(mode) {
    switch (mode) {
      case root.prefixSymbols: return "Search symbols…"
      case root.prefixCalc: return "Calculate…"
      case root.prefixWeb: return "Search the web…"
      case root.prefixClipboard: return "Search clipboard…"
      default: return "Search apps…"
    }
  }

  function modeLabel(mode) {
    switch (mode) {
      case root.prefixSymbols: return "Symbols"
      case root.prefixCalc: return "Calculate"
      case root.prefixWeb: return "Web Search"
      case root.prefixClipboard: return "Clipboard"
      default: return "Apps"
    }
  }
}
