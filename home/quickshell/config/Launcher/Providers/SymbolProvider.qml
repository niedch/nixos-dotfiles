import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property var symbols: []
  signal resultsReady(var results)
  signal symbolsLoaded()

  function search(query) {
    const q = query.trim().toLowerCase()
    const filtered = []
    for (let i = 0; i < root.symbols.length; i++) {
      const s = root.symbols[i]
      if (q === "" || s.name.toLowerCase().includes(q) || s.symbol.toLowerCase().includes(q)) {
        filtered.push({
          key: s.symbol,
          kind: "symbol",
          symbol: s.symbol,
          name: s.name,
        })
      }
    }
    root.resultsReady(filtered)
  }

  function reload() {
    symbolsFile.reload()
  }

  function activate(item) {
    Quickshell.clipboardText = item.symbol
    pasteDelay.start()
  }

  FileView {
    id: symbolsFile
    path: (Quickshell.env("HOME") ?? "") + "/.config/quickshell/data/symbols.txt"
    onLoaded: {
      if (!symbolsFile.loaded) return
      const parsed = []
      const lines = symbolsFile.text().split("\n")
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim()
        if (line === "") continue
        const space = line.indexOf(" ")
        if (space > 0) {
          parsed.push({ symbol: line.slice(0, space), name: line.slice(space + 1) })
        } else {
          parsed.push({ symbol: line, name: line })
        }
      }
      root.symbols = parsed
      root.symbolsLoaded()
    }
  }

  Timer {
    id: pasteDelay
    interval: 100
    onTriggered: {
      pasteProc.command = ["hyprctl", "dispatch", "sendshortcut", "SHIFT,Insert,activewindow"]
      pasteProc.running = true
    }
  }

  Process { id: pasteProc }
}
