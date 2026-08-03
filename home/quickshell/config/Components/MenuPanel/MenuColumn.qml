import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

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
  property var displayItems: []
  property var themes: []

  // ── menu tree ──
  readonly property var menuTree: [
    // ─────────────── Apps ───────────────
    { label: "Apps", icon: "󰘔", kind: "action", action: "launch-apps" },

    // ─────────────── Learn ───────────────
    { label: "Learn", icon: "󰊩", kind: "group", children: [
      { label: "Keybindings",   icon: "⌨",  kind: "action", action: "keybindings" },
      { label: "Hyprland Wiki", icon: "󰖳",  kind: "action", action: "url", url: "https://wiki.hyprland.org" },
      { label: "NixOS Wiki",    icon: "󱄅",  kind: "action", action: "url", url: "https://wiki.nixos.org" },
      { label: "Neovim Docs",   icon: "󰵀",  kind: "action", action: "url", url: "https://neovim.io/doc/" },
      { label: "Bash Manual",   icon: "󰌢",  kind: "action", action: "url", url: "https://www.gnu.org/software/bash/manual/" },
    ]},

    // ─────────────── Capture ───────────────
    { label: "Capture", icon: "󰇂", kind: "group", children: [
      { label: "Screenshot", icon: "󰆟", kind: "group", children: [
        { label: "Snap with Editing",     icon: "󰏬", kind: "action", action: "exec", cmd: ["cmd-screenshot", "smart"] },
        { label: "Straight to Clipboard", icon: "󰆏", kind: "action", action: "exec", cmd: ["cmd-screenshot", "smart", "clipboard"] },
      ]},
      { label: "Screenrecord", icon: "󰀽", kind: "group", children: [
        { label: "Record Screen",          icon: "󰨊", kind: "action", action: "exec", cmd: ["cmd-screenrecord"] },
        { label: "Record + Desktop Audio", icon: "󰋋", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--with-desktop-audio"] },
        { label: "Record + Microphone",    icon: "󰍬", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--with-microphone-audio"] },
        { label: "Record + All Audio",     icon: "󰋎", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--with-desktop-audio", "--with-microphone-audio"] },
        { label: "Stop Recording",         icon: "󰓛", kind: "action", action: "exec", cmd: ["cmd-screenrecord", "--stop-recording"] },
      ]},
    ]},

    // ─────────────── Share ───────────────
    { label: "Share", icon: "󰈁", kind: "group", children: [
      { label: "Clipboard", icon: "󰆏", kind: "action", action: "exec", cmd: ["cmd-share", "clipboard"] },
      { label: "File",      icon: "󰈔", kind: "action", action: "exec", cmd: ["ghostty", "--class=org.tui.share", "--", "bash", "-c", "cmd-share file"] },
      { label: "Folder",    icon: "󰉋", kind: "action", action: "exec", cmd: ["ghostty", "--class=org.tui.share", "--", "bash", "-c", "cmd-share folder"] },
    ]},

    // ─────────────── Tools ───────────────
    { label: "Color Picker", icon: "󰋞", kind: "action", action: "exec", cmd: ["hyprpicker", "-a"] },

    // ─────────────── Themes ───────────────
    { label: "Themes", icon: "󰉼", kind: "themes" },

    // ─────────────── Setup ───────────────
    { label: "Setup", icon: "󰒓", kind: "group", children: [
      { label: "Audio",     icon: "󰕾", kind: "action", action: "exec", cmd: ["pavucontrol"] },
      { label: "WiFi",      icon: "󰖩", kind: "action", action: "exec", cmd: ["launch-or-focus-tui", "wlctl"] },
      { label: "Bluetooth", icon: "󰂯", kind: "action", action: "exec", cmd: ["launch-or-focus-tui", "bluetui"] },
    ]},

    // ─────────────── System ───────────────
    { label: "System", icon: "󰔟", kind: "group", children: [
      { label: "Lock",        icon: "󰌾", kind: "action", action: "exec", cmd: ["lock-screen"] },
      { label: "Toggle Idle", icon: "󱫖", kind: "action", dynamic: true },
      { label: "Logout",      icon: "󰍃", kind: "action", danger: true, action: "exec", cmd: ["cmd-logout"] },
      { label: "Suspend",     icon: "󰤄", kind: "action", danger: true, action: "exec", cmd: ["systemctl", "suspend"] },
      { label: "Restart",     icon: "󰜉", kind: "action", danger: true, action: "exec", cmd: ["cmd-reboot"] },
      { label: "Shutdown",    icon: "󰐥", kind: "action", danger: true, action: "exec", cmd: ["cmd-shutdown"] },
    ]},
  ]

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
    var node = root.findGroup(root.menuTree, label)
    if (node) root.browseStack = [node]
    root.rebuild()
  }

  function findGroup(nodes, label) {
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n.kind === "group") {
        if (n.label === label) return n
        var found = root.findGroup(n.children, label)
        if (found) return found
      }
    }
    return null
  }

  // ── display list building ──
  function rebuild() {
    if (root.showKeybindings) {
      root.displayItems = root.filterKeybindings()
    } else if (root.searchText.trim() !== "") {
      root.displayItems = root.searchTree()
    } else {
      // browse current level
      var prefix = []
      for (var i = 0; i < root.browseStack.length; i++) {
        prefix.push(root.browseStack[i].label)
      }

      // when we've navigated into the themes group, list the loaded themes
      if (root.browseStack.length > 0 && root.browseStack[root.browseStack.length - 1].kind === "themes") {
        var out = []
        for (var t = 0; t < root.themes.length; t++) {
          out.push({
            node: { label: root.themes[t], icon: "󰉼", kind: "action", action: "theme", theme: root.themes[t] },
            path: prefix.concat([root.themes[t]])
          })
        }
        root.displayItems = out
        listView.currentIndex = root.displayItems.length > 0 ? 0 : -1
        return
      }

      // browse current level (menuTree top level or group children)
      var level = root.browseStack.length === 0 ? root.menuTree : root.browseStack[root.browseStack.length - 1].children
      var out2 = []
      for (var j = 0; j < level.length; j++) {
        out2.push({ node: level[j], path: prefix.concat([level[j].label]) })
      }
      root.displayItems = out2
    }
    listView.currentIndex = root.displayItems.length > 0 ? 0 : -1
  }

  function searchTree() {
    var q = root.searchText.trim().toLowerCase()
    var leaves = []
    root.collectLeaves(root.menuTree, [], leaves)
    var out = []
    for (var i = 0; i < leaves.length; i++) {
      var item = leaves[i]
      var hay = (item.node.label + " " + item.path.join(" ")).toLowerCase()
      if (hay.indexOf(q) !== -1) {
        out.push({ node: item.node, path: item.path })
      }
    }
    return out
  }

  function collectLeaves(nodes, trail, out) {
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n.kind === "themes") {
        var themePath = trail.concat([n.label])
        for (var t = 0; t < root.themes.length; t++) {
          out.push({
            node: { label: root.themes[t], icon: "󰉼", kind: "action", action: "theme", theme: root.themes[t] },
            path: themePath.concat([root.themes[t]])
          })
        }
      } else if (n.kind === "group") {
        root.collectLeaves(n.children, trail.concat([n.label]), out)
      } else {
        out.push({ node: n, path: trail.concat([n.label]) })
      }
    }
  }

  function itemLabel(item) {
    if (item.node.dynamic) return root.idleOn ? "Inhibit Idle" : "Enable Idle"
    return item.node.label
  }

  function itemSubtitle(item) {
    var path = item.path
    if (path.length <= 1) return ""
    var sub = path.slice(0, path.length - 1).join(" / ")
    return sub
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
      Quickshell.execDetached(["theme-switcher-set", node.theme])
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
      root.keymap = root.parseKeymap(keymapOut.text)
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

  property bool keymapDone: false
  property bool bindsDone: false

  function tryBuildKeybindings() {
    if (!root.keymapDone || !root.bindsDone) return
    root.keybindings = root.parseBinds(root.rawBinds)
    root.keybindingsLoaded = true
    if (root.showKeybindings) root.rebuild()
  }

  function parseKeymap(text) {
    var codeByName = {}
    var symByName = {}
    var sec = ""
    var lines = text.split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (line.indexOf("xkb_keycodes") !== -1) { sec = "codes"; continue }
      if (line.indexOf("xkb_symbols") !== -1) { sec = "syms"; continue }
      if (sec === "codes") {
        var m = line.match(/<([A-Za-z0-9_]+)>\s*=\s*([0-9]+)\s*;/)
        if (m) codeByName[m[1]] = m[2]
      } else if (sec === "syms") {
        var m2 = line.match(/key\s*<([A-Za-z0-9_]+)>\s*\{\s*\[\s*([^, \]]+)/)
        if (m2) symByName[m2[1]] = m2[2]
      }
    }
    var map = {}
    for (var k in codeByName) {
      var c = codeByName[k]
      var s = symByName[k]
      if (c && s && s !== "NoSymbol") map[c] = s
    }
    return map
  }

  function modsFor(mask) {
    switch (mask) {
      case 0: return ""
      case 1: return "SHIFT"
      case 4: return "CTRL"
      case 5: return "SHIFT CTRL"
      case 8: return "ALT"
      case 9: return "SHIFT ALT"
      case 12: return "CTRL ALT"
      case 13: return "SHIFT CTRL ALT"
      case 64: return "SUPER"
      case 65: return "SUPER SHIFT"
      case 68: return "SUPER CTRL"
      case 69: return "SUPER SHIFT CTRL"
      case 72: return "SUPER ALT"
      case 73: return "SUPER SHIFT ALT"
      case 76: return "SUPER CTRL ALT"
      case 77: return "SUPER SHIFT CTRL ALT"
      default: return ""
    }
  }

  function resolveKey(b) {
    var key = b.key || ""
    var keycode = b.keycode || 0
    if (b.mouse) {
      var mm = key.match(/mouse:([0-9]+)/)
      if (mm) {
        switch (mm[1]) {
          case "272": return "LEFT MOUSE BUTTON"
          case "273": return "RIGHT MOUSE BUTTON"
          case "274": return "MIDDLE MOUSE BUTTON"
          default: return "mouse:" + mm[1]
        }
      }
      return key
    }
    if (key.indexOf("code:") === 0) {
      var c = key.slice(5)
      return root.keymap[c] || key
    }
    if (key === "" && keycode) {
      return root.keymap[String(keycode)] || "code:" + keycode
    }
    return key
  }

  function parseBinds(text) {
    var out = []
    var arr = []
    try {
      arr = JSON.parse(text)
    } catch (e) {
      return out
    }
    for (var i = 0; i < arr.length; i++) {
      var b = arr[i]
      var combo = root.modsFor(b.modmask)
      var k = root.resolveKey(b)
      if (k && combo) combo += " + "
      combo += k

      var action = b.description || ""
      if (!action) {
        action = (b.dispatcher || "") + (b.arg ? " " + b.arg : "")
        action = action.replace(/^exec\s*[,]?\s*/, "")
      }
      if (!action) continue

      out.push({
        combo: combo,
        action: action,
        hay: (combo + " " + action).toLowerCase()
      })
    }
    out.sort(function (a, b) { return a.combo.localeCompare(b.combo) })
    return out
  }

  function filterKeybindings() {
    var q = root.searchText.trim().toLowerCase()
    var out = []
    for (var i = 0; i < root.keybindings.length; i++) {
      var k = root.keybindings[i]
      if (q === "" || k.hay.indexOf(q) !== -1) out.push(k)
    }
    return out
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
    if (item && item.node) return root.itemLabel(item)
    if (item && item.combo) return item.combo
    return ""
  }

  function displayItemSub(item) {
    if (item && item.node) return root.itemSubtitle(item)
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
