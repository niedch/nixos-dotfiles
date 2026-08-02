import Quickshell
import Quickshell.Networking
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs
import qs.Components
import qs.Components.Network

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6
  property int scanDuration: 15

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  property bool scanning: false
  property var sortedNetworks: []

  visible: root.shown
  color: "transparent"
  implicitWidth: 360

  property int rowHeight: 48
  readonly property int headerHeight: 90
  readonly property int footerHeight: 40
  readonly property int baseHeight: root.headerHeight + root.footerHeight + 48
  implicitHeight: root.baseHeight + root.sortedNetworks.length * root.rowHeight

  // ---- data ----

  function wifiDevices() {
    var out = []
    var vals = Networking.devices.values
    for (var i = 0; i < vals.length; i++) {
      if (vals[i].type === DeviceType.Wifi) out.push(vals[i])
    }
    return out
  }

  function refreshNetworks() {
    var out = []
    var devices = Networking.devices.values
    for (var i = 0; i < devices.length; i++) {
      var dev = devices[i]
      if (dev.type !== DeviceType.Wifi) continue
      var nets = dev.networks.values
      for (var j = 0; j < nets.length; j++) {
        out.push(nets[j])
      }
    }
    out.sort(function (a, b) {
      if (a.connected !== b.connected) return a.connected ? -1 : 1
      return b.signalStrength - a.signalStrength
    })
    root.sortedNetworks = out
  }

  // ---- actions ----

  function toggle() {
    root.shown = !root.shown
  }

  function toggleWifi() {
    Networking.wifiEnabled = !Networking.wifiEnabled
  }

  function toggleScan() {
    if (root.scanning) {
      scanTimer.stop()
      root.scanning = false
    } else {
      root.scanning = true
      scanTimer.start()
    }
  }

  function stopScan() {
    scanTimer.stop()
    root.scanning = false
  }

  function setScanner(enabled) {
    var devs = root.wifiDevices()
    for (var i = 0; i < devs.length; i++) devs[i].scannerEnabled = enabled
  }

  // ---- display ----

  function connectivityLabel() {
    switch (Networking.connectivity) {
      case NetworkConnectivity.Full: return "Online"
      case NetworkConnectivity.Limited: return "Limited"
      case NetworkConnectivity.Portal: return "Captive portal"
      case NetworkConnectivity.None: return "Offline"
      default: return "Unknown"
    }
  }

  function openWlctl() {
    netProc.command = ["ghostty", "--class=org.tui.wlctl", "-e", "wlctl"]
    netProc.running = true
  }

  onShownChanged: {
    if (root.shown) {
      root.refreshNetworks()
      if (Networking.wifiEnabled) {
        root.setScanner(true)
        root.toggleScan()
      }
      refreshTimer.start()
    } else {
      root.setScanner(false)
      root.stopScan()
      refreshTimer.stop()
    }
  }

  Timer {
    id: scanTimer
    interval: root.scanDuration * 1000
    repeat: false
    onTriggered: root.stopScan()
  }

  Timer {
    id: refreshTimer
    interval: 2000
    repeat: true
    onTriggered: root.refreshNetworks()
  }

  Process {
    id: netProc
  }

  HyprlandFocusGrab {
    windows: [root]
    active: root.shown
    onCleared: root.shown = false
  }

  anchor {
    id: popAnchor
    window: root.anchorWindow
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: {
      if (!root.target || !root.anchorWindow) return
      var pt = root.anchorWindow.contentItem.mapFromItem(root.target, 0, root.target.height + root.gap)
      popAnchor.rect.x = Math.round(pt.x)
      popAnchor.rect.y = Math.round(pt.y)
    }
  }

  Rectangle {
    id: card
    width: 360
    height: root.implicitHeight
    color: Colors.background
    border.color: Colors.color0
    border.width: 1
    radius: 8

    Column {
      id: column
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 12
      spacing: 8

      Row {
        width: parent.width
        spacing: 8

        Text {
          id: title
          anchors.verticalCenter: parent.verticalCenter
          text: "Network"
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          font.bold: true
        }

        Item {
          height: 1
          width: parent.width - title.implicitWidth - controlsRow.width - parent.spacing
        }

        Row {
          id: controlsRow
          spacing: 6

          ControlButton {
            label: Networking.wifiEnabled ? "󰤨 Turn Off" : "󰤮 Turn On"
            active: Networking.wifiEnabled
            onClickedBtn: root.toggleWifi()
          }

          ControlButton {
            label: root.scanning ? "󰂯 Stop Scan" : "󰂯 Scan"
            active: root.scanning
            enabled: Networking.wifiEnabled && root.wifiDevices().length > 0
            onClickedBtn: root.toggleScan()
          }
        }
      }

      Row {
        width: parent.width
        spacing: 6

        Text {
          text: "󰀂 " + root.connectivityLabel()
          color: Networking.connectivity === NetworkConnectivity.Full ? Colors.color2 : Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }

        Text {
          visible: root.scanning
          text: "󰂯 Scanning…"
          color: Colors.accent
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Colors.color0
      }

      Text {
        width: parent.width
        visible: !Networking.wifiEnabled
        text: "WiFi is off"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      Text {
        width: parent.width
        visible: Networking.wifiEnabled && root.sortedNetworks.length > 0
        text: "Available"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
      }

      Repeater {
        model: Networking.wifiEnabled ? root.sortedNetworks : []
        width: parent.width
        height: root.sortedNetworks.length * root.rowHeight
        implicitHeight: root.sortedNetworks.length * root.rowHeight
        delegate: NetworkRow {
          rowWidth: column.width
          rowHeight: root.rowHeight
        }
      }

      Text {
        width: parent.width
        visible: Networking.wifiEnabled && root.sortedNetworks.length === 0
        text: root.scanning ? "Scanning for networks…" : "No networks found"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Colors.color0
      }

      Item {
        width: parent.width
        height: 24

        ControlButton {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          label: "󰘺 Open wlctl"
          onClickedBtn: root.openWlctl()
        }
      }
    }
  }
}

