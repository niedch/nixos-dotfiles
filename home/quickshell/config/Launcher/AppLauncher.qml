import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs
import qs.Launcher
import qs.Launcher.Providers

Scope {
  id: root

  property bool open: false
  property var results: []

  ModeConfig { id: modeConfig }

  AppsProvider {
    id: appsProvider
    webSearchUrl: modeConfig.webSearchUrl
    onResultsReady: function (results) { root.setResults(results) }
  }

  SymbolProvider {
    id: symbolProvider
    onResultsReady: function (results) { root.setResults(results) }
    onSymbolsLoaded: root.updateResults()
  }

  CalcProvider {
    id: calcProvider
    onResultsReady: function (results) { root.setResults(results) }
  }

  WebProvider {
    id: webProvider
    webSearchUrl: modeConfig.webSearchUrl
    onResultsReady: function (results) { root.setResults(results) }
  }

  ClipboardProvider {
    id: clipboardProvider
    onResultsReady: function (results) { root.setResults(results) }
    onHistoryChanged: root.updateResults()
  }

  IpcHandler {
    target: "launcher"
    function toggle() { root.toggle() }
    function symbols() { root.openWith(modeConfig.prefixSymbols) }
    function clipboard() { root.openWith(modeConfig.prefixClipboard) }
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
    if (prefix === modeConfig.prefixSymbols) symbolProvider.reload()
    if (prefix === modeConfig.prefixClipboard) clipboardProvider.loadHistory()
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
    listView.currentIndex = 0
  }

  function updateResults() {
    const text = searchInput.text
    const mode = modeConfig.detectMode(text)
    const query = text.slice(mode.length)
    switch (mode) {
      case modeConfig.prefixSymbols: symbolProvider.search(query); break
      case modeConfig.prefixCalc: calcProvider.search(query, text); break
      case modeConfig.prefixWeb: webProvider.search(query); break
      case modeConfig.prefixClipboard: clipboardProvider.search(query); break
      default: appsProvider.search(text); break
    }
  }

  function activate(index) {
    const item = root.results[index]
    if (!item) return
    switch (item.kind) {
      case "app": appsProvider.activate(item); break
      case "symbol": symbolProvider.activate(item); break
      case "calc": calcProvider.activate(item); break
      case "web": webProvider.activate(item); break
      case "clipboard": clipboardProvider.activate(item); break
    }
    root.closeLauncher()
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
              Keys.onReturnPressed: {
                if (root.results.length === 0 && modeConfig.detectMode(searchInput.text) === "") {
                  const q = searchInput.text.trim()
                  if (q !== "") Qt.openUrlExternally(modeConfig.webSearchUrl + encodeURIComponent(q))
                  root.closeLauncher()
                } else {
                  root.activate(listView.currentIndex)
                }
              }

              Text {
                visible: searchInput.text === ""
                text: modeConfig.placeholderText(modeConfig.detectMode(searchInput.text))
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
          text: modeConfig.modeLabel(modeConfig.detectMode(searchInput.text))
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

          delegate: ResultRow {
            isCurrent: listView.currentIndex === index
            onHovered: listView.currentIndex = index
            onActivated: root.activate(index)
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
}
