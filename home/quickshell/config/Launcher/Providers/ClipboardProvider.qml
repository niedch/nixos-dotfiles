import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property var clipboardEntries: []
  signal resultsReady(var results)
  signal historyChanged()

  function search(query) {
    const q = query.trim().toLowerCase()
    const filtered = []
    for (let i = 0; i < root.clipboardEntries.length; i++) {
      const c = root.clipboardEntries[i]
      if (q === "" || c.preview.toLowerCase().includes(q)) {
        filtered.push({
          key: c.hash,
          kind: "clipboard",
          hash: c.hash,
          line: c.line,
          preview: c.preview,
        })
      }
    }
    root.resultsReady(filtered)
  }

  function loadHistory() {
    cliphistProc.buffer = []
    cliphistProc.running = true
  }

  function activate(item) {
    const safe = item.line.replace(/'/g, "'\\''")
    Quickshell.execDetached({ command: ["bash", "-c", `printf '%s' '${safe}' | cliphist decode | wl-copy`] })
  }

  Process {
    id: cliphistProc
    property var buffer: []
    command: ["cliphist", "list"]
    stdout: SplitParser {
      onRead: function (line) {
        cliphistProc.buffer.push(line)
      }
    }
    onExited: {
      const entries = []
      for (let i = 0; i < cliphistProc.buffer.length; i++) {
        const line = cliphistProc.buffer[i]
        const tab = line.indexOf("\t")
        const hash = tab >= 0 ? line.slice(0, tab) : line
        const preview = tab >= 0 ? line.slice(tab + 1) : line
        entries.push({ hash: hash, line: line, preview: preview })
      }
      root.clipboardEntries = entries
      root.historyChanged()
    }
  }
}
