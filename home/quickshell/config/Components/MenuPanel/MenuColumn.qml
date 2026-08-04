import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs
import "MenuTree.js" as MenuTree
import "MenuModel.js" as MenuModel
import "Keybindings.js" as Keybindings

Item {
  id: root

  signal actionActivated()

  // ── state ──
  property string searchText: ""
  property var browseStack: []
  property bool showKeybindings: false
  property bool idleOn: false
  property var keybindings: []
  property var keymap: ({})
  property string rawBinds: ""
  property bool keybindingsLoaded: false
  property bool keymapDone: false
  property bool bindsDone: false
  property var displayItems: []
  property var themes: []

  readonly property var menuTree: MenuTree.menuTree

  function reset() {
    root.browseStack = []
    root.showKeybindings = false
    root.searchText = ""
    root.keybindingsLoaded = false
    root.keymapDone = false
    root.bindsDone = false
    root.rawBinds = ""
    root.idleOn = false
    idleCheck.running = true
    themesProc.running = true
    keymapProc.running = true
    bindsProc.running = true
    root.rebuild()
  }

  function clearSearch() {
    searchInput.text = ""
  }

  function focusSearch() {
    searchInput.forceActiveFocus()
  }

  function navigateTo(label) {
    root.browseStack = []
    root.showKeybindings = false
    root.searchText = ""
    var node = MenuModel.findGroup(root.menuTree, label)
    if (node) root.browseStack = [node]
    root.rebuild()
  }

  // ── display list building ──
  function rebuild() {
    if (root.showKeybindings) {
      root.displayItems = Keybindings.filterKeybindings(root)
    } else if (root.searchText.trim() !== "") {
      root.displayItems = MenuModel.searchTree(root)
    } else {
      root.displayItems = MenuModel.buildDisplayItems(root)
    }
    listView.currentIndex = root.displayItems.length > 0 ? 0 : -1
  }

  // ── activation ──
  function activate(item) {
    if (!item) return
    var node = item.node
    if (!node) return // keybinding rows are display-only
    if (node.kind === "group" || node.kind === "themes") {
      root.browseStack.push(node)
      root.searchText = ""
      root.rebuild()
      return
    }
    if (node.action === "launch-apps") {
      Quickshell.execDetached(["quickshell-launcher", "toggle"])
      root.actionActivated()
      return
    }
    if (node.action === "keybindings") {
      root.showKeybindings = true
      root.searchText = ""
      root.rebuild()
      return
    }
    if (node.action === "url") {
      Qt.openUrlExternally(node.url)
      root.actionActivated()
      return
    }
    if (node.action === "exec") {
      Quickshell.execDetached(node.cmd)
      root.actionActivated()
      return
    }
    if (node.action === "theme") {
      Quickshell.execDetached(["theme-switcher", node.theme])
      root.actionActivated()
      return
    }
    if (node.dynamic) {
      var idleCmd = root.idleOn ? ["toggle-idle", "--off"] : ["toggle-idle", "--on"]
      Quickshell.execDetached(idleCmd)
      root.actionActivated()
      return
    }
  }

  function goBack() {
    if (root.searchText !== "") {
      searchInput.text = ""
      root.rebuild()
      return
    }
    if (root.showKeybindings) {
      root.showKeybindings = false
      root.rebuild()
      return
    }
    if (root.browseStack.length > 0) {
      root.browseStack = root.browseStack.slice(0, root.browseStack.length - 1)
      root.rebuild()
    }
  }

  // ── idle status polling ──
  Process {
    id: idleCheck
    command: ["toggle-idle", "--status"]
    running: false
    onExited: function(exitCode) {
      root.idleOn = exitCode === 0
      root.rebuild()
    }
  }

  // ── theme loading ──
  Process {
    id: themesProc
    command: ["bash", "-c", "ls -1 \"$HOME/.local/share/themes\" | grep -v -E '^(current|current-background)$' | sort"]
    stdout: StdioCollector { id: themesOut }
    onExited: {
      var names = themesOut.text.trim().split("\n").filter(function (x) { return x !== "" })
      root.themes = names
      root.rebuild()
    }
  }

  Timer {
    id: idleTimer
    interval: Constants.pollNormal
    running: true
    repeat: true
    onTriggered: idleCheck.running = true
  }

  // ── keybinding loading ──
  Process {
    id: keymapProc
    command: ["xkbcli", "compile-keymap"]
    stdout: StdioCollector { id: keymapOut }
    onExited: {
      root.keymap = Keybindings.parseKeymap(keymapOut.text)
      root.keymapDone = true
      root.tryBuildKeybindings()
    }
  }

  Process {
    id: bindsProc
    command: ["bash", "-c", "hyprctl -j binds"]
    stdout: StdioCollector { id: bindsOut }
    onExited: {
      root.rawBinds = bindsOut.text
      root.bindsDone = true
      root.tryBuildKeybindings()
    }
  }

  function tryBuildKeybindings() {
    if (!root.keymapDone || !root.bindsDone) return
    root.keybindings = Keybindings.parseBinds(root, root.rawBinds)
    root.keybindingsLoaded = true
    if (root.showKeybindings) root.rebuild()
  }

  // ── search input ──
  function setSearch(text) {
    root.searchText = text
    root.rebuild()
  }

  // ── layout ──
  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 38
      color: "transparent"

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
          text: "󰀻"
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: 14
        }

        TextInput {
          id: searchInput
          Layout.fillWidth: true
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          selectByMouse: true
          activeFocusOnTab: false
          onTextChanged: root.setSearch(text)

          Keys.onEscapePressed: root.actionActivated()
          Keys.onUpPressed: {
            if (listView.currentIndex > 0) listView.currentIndex--
          }
          Keys.onDownPressed: {
            if (listView.currentIndex < listView.count - 1) listView.currentIndex++
          }
          Keys.onReturnPressed: {
            if (root.displayItems.length > 0) root.activate(root.displayItems[listView.currentIndex])
          }

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: parent.text === ""
            text: root.showKeybindings ? "Search keybindings…" : "Search menu…"
            color: Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSize
          }
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Colors.color0
    }

    // breadcrumb / header
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 30
      color: "transparent"

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4

        Text {
          text: "󰁍"
          visible: root.browseStack.length > 0 || root.showKeybindings
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: 12

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.goBack()
          }
        }

        Text {
          Layout.fillWidth: true
          text: root.crumbLabel()
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          elide: Text.ElideRight
        }
      }
    }

    ListView {
      id: listView
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: root.displayItems

      delegate: Item {
        required property var modelData
        required property int index
        property bool isCurrent: listView.currentIndex === index
        readonly property bool isDanger: modelData.node && modelData.node.danger === true
        readonly property bool isGroup: modelData.node && (modelData.node.kind === "group" || modelData.node.kind === "themes")

        width: listView.width
        height: 38

        Rectangle {
          anchors.fill: parent
          color: isCurrent ? Colors.selectionBackground : (rowMouse.containsMouse ? Colors.selectionBackground : "transparent")
          opacity: isCurrent || rowMouse.containsMouse ? 0.7 : 1.0
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          spacing: 10

          Text {
            Layout.preferredWidth: 18
            text: root.displayItemIcon(modelData)
            color: isDanger ? Colors.color1 : Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
              Layout.fillWidth: true
              text: root.displayItemLabel(modelData)
              color: isDanger ? Colors.color1 : Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSize
              elide: Text.ElideRight
            }

            Text {
              Layout.fillWidth: true
              visible: root.displayItemSub(modelData) !== ""
              text: root.displayItemSub(modelData)
              color: Colors.color8
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSizeSmall
              elide: Text.ElideRight
            }
          }

          Text {
            visible: isGroup
            text: "󰁔"
            color: Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: 10
          }
        }

        MouseArea {
          id: rowMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPositionChanged: listView.currentIndex = index
          onClicked: root.activate(modelData)
        }
      }
    }
  }

  function displayItemLabel(item) {
    if (item && item.node) return MenuModel.itemLabel(root, item)
    if (item && item.combo) return item.combo
    return ""
  }

  function displayItemSub(item) {
    if (item && item.node) return MenuModel.itemSubtitle(item)
    if (item && item.action) return item.action
    return ""
  }

  function displayItemIcon(item) {
    if (item && item.node) return item.node.icon
    return "⌨"
  }

  function crumbLabel() {
    if (root.showKeybindings) return "Keybindings"
    if (root.searchText.trim() !== "") return "Search results"
    var parts = []
    for (var i = 0; i < root.browseStack.length; i++) {
      parts.push(root.browseStack[i].label)
    }
    return parts.join(" › ")
  }
}
