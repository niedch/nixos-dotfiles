import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs

Scope {
  id: root

  property bool open: false
  property var results: []
  property var symbols: []
  property var clipboardEntries: []

  readonly property string prefixSymbols: ":"
  readonly property string prefixCalc: "="
  readonly property string prefixWeb: "@"
  readonly property string prefixClipboard: "$"
  readonly property string webSearchUrl: "https://duckduckgo.com/?q="

  IpcHandler {
    target: "launcher"
    function toggle() { root.toggle() }
    function symbols() { root.openWith(":") }
    function clipboard() { root.openWith("$") }
  }

  function toggle() {
    if (root.open) root.closeLauncher()
    else root.openWith("")
  }

  function openWith(prefix) {
    searchInput.text = prefix
    root.results = []
    root.open = true
    win.visible = true
    searchInput.forceActiveFocus()
    if (prefix === root.prefixSymbols) symbolsFile.reload()
    if (prefix === root.prefixClipboard) {
      cliphistProc.buffer = []
      cliphistProc.running = true
    }
    root.updateResults()
  }

  function closeLauncher() {
    root.open = false
    win.visible = false
    searchInput.text = ""
    root.results = []
  }

  function setResults(arr) {
    root.results = arr
    if (listView.currentIndex >= root.results.length) listView.currentIndex = 0
  }

  function detectMode() {
    const text = searchInput.text
    if (text.startsWith(root.prefixSymbols)) return root.prefixSymbols
    if (text.startsWith(root.prefixCalc)) return root.prefixCalc
    if (text.startsWith(root.prefixWeb)) return root.prefixWeb
    if (text.startsWith(root.prefixClipboard)) return root.prefixClipboard
    return ""
  }

  function placeholderText() {
    switch (root.detectMode()) {
      case root.prefixSymbols: return "Search symbols…"
      case root.prefixCalc: return "Calculate…"
      case root.prefixWeb: return "Search the web…"
      case root.prefixClipboard: return "Search clipboard…"
      default: return "Search apps…"
    }
  }

  function modeLabel() {
    switch (root.detectMode()) {
      case root.prefixSymbols: return "Symbols"
      case root.prefixCalc: return "Calculate"
      case root.prefixWeb: return "Web Search"
      case root.prefixClipboard: return "Clipboard"
      default: return "Apps"
    }
  }

  function updateResults() {
    const text = searchInput.text
    if (text.startsWith(root.prefixSymbols)) { root.updateSymbols(text.slice(1)); return }
    if (text.startsWith(root.prefixCalc)) { root.updateCalc(text.slice(1)); return }
    if (text.startsWith(root.prefixWeb)) { root.updateWeb(text.slice(1)); return }
    if (text.startsWith(root.prefixClipboard)) { root.updateClipboard(text.slice(1)); return }
    root.updateApps(text)
  }

  function updateApps(q) {
    const query = q.trim().toLowerCase()
    const all = DesktopEntries.applications.values
    const filtered = []
    for (let i = 0; i < all.length; i++) {
      const e = all[i]
      if (!e.name) continue
      const name = e.name.toLowerCase()
      let generic = ""
      if (e.genericName) generic = e.genericName.toLowerCase()
      let keywords = []
      if (e.keywords) keywords = e.keywords.map(k => k.toLowerCase())
      let categories = []
      if (e.categories) categories = e.categories.map(c => c.toLowerCase())

      let match = false
      if (query === "") {
        match = true
      } else if (name.startsWith(query)) {
        match = true
      } else if (name.includes(query)) {
        match = true
      } else if (generic.includes(query)) {
        match = true
      } else if (keywords.some(k => k.includes(query))) {
        match = true
      } else if (categories.some(c => c.includes(query))) {
        match = true
      }
      if (match) {
        filtered.push({
          key: e.id,
          kind: "app",
          entry: e,
          name: e.name,
          genericName: e.genericName,
          icon: e.icon,
          comment: e.comment,
        })
      }
    }

    filtered.sort(function (a, b) {
      const aPrefix = a.name.toLowerCase().startsWith(query) ? 0 : 1
      const bPrefix = b.name.toLowerCase().startsWith(query) ? 0 : 1
      if (aPrefix !== bPrefix) return aPrefix - bPrefix
      return a.name.localeCompare(b.name)
    })

    root.setResults(filtered)
  }

  function updateSymbols(q) {
    const query = q.trim().toLowerCase()
    const filtered = []
    for (let i = 0; i < root.symbols.length; i++) {
      const s = root.symbols[i]
      if (query === "" || s.name.toLowerCase().includes(query) || s.symbol.toLowerCase().includes(query)) {
        filtered.push({
          key: s.symbol,
          kind: "symbol",
          symbol: s.symbol,
          name: s.name,
        })
      }
    }
    root.setResults(filtered)
  }

  function updateCalc(q) {
    const expr = q.trim()
    if (expr === "") {
      calcDebounce.stop()
      root.setResults([])
      return
    }
    calcDebounce.restart()
  }

  function updateWeb(q) {
    const query = q.trim()
    if (query === "") {
      root.setResults([])
      return
    }
    root.setResults([{
      key: "web",
      kind: "web",
      query: query,
      url: root.webSearchUrl + encodeURIComponent(query),
    }])
  }

  function updateClipboard(q) {
    const query = q.trim().toLowerCase()
    const filtered = []
    for (let i = 0; i < root.clipboardEntries.length; i++) {
      const c = root.clipboardEntries[i]
      if (query === "" || c.preview.toLowerCase().includes(query)) {
        filtered.push({
          key: c.hash,
          kind: "clipboard",
          hash: c.hash,
          line: c.line,
          preview: c.preview,
        })
      }
    }
    root.setResults(filtered)
  }

  function runCalc() {
    const expr = searchInput.text.slice(root.prefixCalc.length).trim()
    if (expr === "") {
      root.setResults([])
      return
    }
    calcProc.running = false
    calcProc.command = ["qalc", "-t", expr]
    calcProc.running = true
  }

  function activate(index) {
    const item = root.results[index]
    if (!item) return
    if (item.kind === "app") {
      item.entry.execute()
      root.closeLauncher()
      return
    }
    if (item.kind === "symbol") {
      Quickshell.clipboardText = item.symbol
      root.closeLauncher()
      pasteDelay.start()
      return
    }
    if (item.kind === "calc") {
      Quickshell.clipboardText = item.result
      root.closeLauncher()
      return
    }
    if (item.kind === "web") {
      Qt.openUrlExternally(item.url)
      root.closeLauncher()
      return
    }
    if (item.kind === "clipboard") {
      root.restoreClipboard(item.line)
      root.closeLauncher()
      return
    }
  }

  function restoreClipboard(line) {
    const safe = line.replace(/'/g, "'\\''")
    Quickshell.execDetached({ command: ["bash", "-c", `printf '%s' '${safe}' | cliphist decode | wl-copy`] })
  }

  function moveSelection(delta) {
    if (root.results.length === 0) return
    let idx = listView.currentIndex + delta
    if (idx < 0) idx = root.results.length - 1
    if (idx >= root.results.length) idx = 0
    listView.currentIndex = idx
    listView.positionViewAtIndex(idx, ListView.Contain)
  }

  function autocomplete() {
    const item = root.results[listView.currentIndex]
    if (!item) return
    if (item.kind === "app") {
      searchInput.text = item.name
      searchInput.cursorPosition = searchInput.text.length
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

  Timer {
    id: calcDebounce
    interval: 250
    onTriggered: root.runCalc()
  }

  Process {
    id: calcProc
    stdout: SplitParser {
      onRead: function (data) {
        root.setResults([{
          key: "calc",
          kind: "calc",
          expr: searchInput.text,
          result: data.trim(),
        }])
      }
    }
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
      root.updateResults()
    }
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
      root.updateResults()
    }
  }

  PanelWindow {
    id: win
    visible: root.open
    color: "transparent"
    focusable: true
    screen: Quickshell.primaryScreen

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"
    exclusionMode: ExclusionMode.Ignore

    MouseArea {
      id: backdrop
      anchors.fill: parent
      onClicked: root.closeLauncher()
    }

    Rectangle {
      id: card
      anchors.centerIn: parent
      width: 644
      height: 560
      color: Colors.background
      border.color: Colors.color0
      border.width: 1
      radius: 12

      Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.background
        opacity: 0.92
      }

      ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
          id: searchBox
          Layout.fillWidth: true
          Layout.preferredHeight: 56
          color: Colors.color0
          opacity: 0.35

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            Text {
              text: "󰀻"
              color: Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 18
            }

            TextInput {
              id: searchInput
              Layout.fillWidth: true
              color: Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 18
              selectByMouse: true
              activeFocusOnTab: false
              inputMethodHints: Qt.ImhNoPredictiveText

              onTextChanged: root.updateResults()

              Keys.onEscapePressed: root.closeLauncher()
              Keys.onUpPressed: root.moveSelection(-1)
              Keys.onDownPressed: root.moveSelection(1)
              Keys.onTabPressed: {
                root.autocomplete()
                event.accepted = true
              }
              Keys.onReturnPressed: root.activate(listView.currentIndex)

              Text {
                visible: searchInput.text === ""
                text: root.placeholderText()
                color: Colors.color8
                font.family: Constants.fontFamily
                font.pixelSize: 18
              }
            }
          }
        }

        Text {
          Layout.alignment: Qt.AlignRight
          Layout.rightMargin: 12
          Layout.topMargin: 4
          text: root.modeLabel()
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }

        ListView {
          id: listView
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredHeight: 420
          clip: true
          currentIndex: 0
          highlightFollowsCurrentItem: true
          model: ScriptModel {
            objectProp: "key"
            values: root.results
          }

          delegate: Rectangle {
            required property var modelData
            required property int index

            width: ListView.view.width
            height: 44
            color: ListView.isCurrentItem ? Colors.color0 : "transparent"
            opacity: ListView.isCurrentItem ? 0.6 : 1.0

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onPositionChanged: listView.currentIndex = index
              onClicked: root.activate(index)
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 16
              anchors.rightMargin: 16
              spacing: 12

              Text {
                Layout.preferredWidth: 24
                text: root.delegateGlyph(modelData)
                color: Colors.foreground
                font.family: Constants.fontFamily
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                  Layout.fillWidth: true
                  text: root.delegateTitle(modelData)
                  color: Colors.foreground
                  font.family: Constants.fontFamily
                  font.pixelSize: Constants.fontSize
                  elide: Text.ElideRight
                }

                Text {
                  Layout.fillWidth: true
                  visible: root.delegateSubtitle(modelData) !== ""
                  text: root.delegateSubtitle(modelData)
                  color: Colors.color8
                  font.family: Constants.fontFamily
                  font.pixelSize: Constants.fontSizeSmall
                  elide: Text.ElideRight
                }
              }
            }
          }
        }

        Text {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignHCenter
          Layout.bottomMargin: 8
          Layout.topMargin: 4
          text: "↑↓ navigate · Enter open · Esc close"
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }

  function delegateGlyph(item) {
    if (item.kind === "app") return "󰘔"
    if (item.kind === "symbol") return item.symbol
    if (item.kind === "calc") return "󰃬"
    if (item.kind === "web") return "󰇧"
    if (item.kind === "clipboard") return "󰆏"
    return "󰘔"
  }

  function delegateTitle(item) {
    if (item.kind === "app") return item.name
    if (item.kind === "symbol") return item.symbol + "  " + item.name
    if (item.kind === "calc") return item.result
    if (item.kind === "web") return "Search: " + item.query
    if (item.kind === "clipboard") return item.preview
    return ""
  }

  function delegateSubtitle(item) {
    if (item.kind === "app") return item.genericName || item.comment || ""
    if (item.kind === "symbol") return item.name
    if (item.kind === "calc") return item.expr
    if (item.kind === "web") return item.url
    if (item.kind === "clipboard") return ""
    return ""
  }
}
