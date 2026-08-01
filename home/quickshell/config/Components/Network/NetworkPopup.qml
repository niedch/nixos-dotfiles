import Quickshell
import Quickshell.Networking
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs

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

  property int rowHeight: 44
  readonly property int headerHeight: 90
  readonly property int footerHeight: 40
  readonly property int baseHeight: root.headerHeight + root.footerHeight + 48
  implicitHeight: root.baseHeight + root.sortedNetworks.length * root.rowHeight

  // ---- helpers ----

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

  function signalGlyph(strength) {
    var s = strength * 100
    if (s > 75) return "󰤨"
    if (s > 50) return "󰤥"
    if (s > 25) return "󰤢"
    if (s > 10) return "󰤟"
    return "󰤯"
  }

  function securityLabel(net) {
    switch (net.security) {
      case WifiSecurityType.Sae: return "WPA3"
      case WifiSecurityType.Wpa3SuiteB192: return "WPA3-192"
      case WifiSecurityType.Wpa2Psk: return "WPA2"
      case WifiSecurityType.Wpa2Eap: return "WPA2-EAP"
      case WifiSecurityType.WpaPsk: return "WPA"
      case WifiSecurityType.WpaEap: return "WPA-EAP"
      case WifiSecurityType.Owe: return "OWE"
      case WifiSecurityType.Open: return "Open"
      default: return "Secured"
    }
  }

  function stateLabel(net) {
    switch (net.state) {
      case ConnectionState.Connecting: return "Connecting…"
      case ConnectionState.Connected: return "Connected"
      case ConnectionState.Disconnecting: return "Disconnecting…"
      default: return ""
    }
  }

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

  function networkAction(row) {
    if (row.net.connected) {
      row.net.disconnect()
    } else if (row.net.known || row.net.security === WifiSecurityType.Open) {
      row.net.connect()
    } else {
      row.pskEntry = true
      row.pskFocus()
    }
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
        height: root.sortedNetworks.length * 44
        implicitHeight: root.sortedNetworks.length * 44
        delegate: Item {
          id: nr
          required property var modelData
          readonly property var net: nr.modelData

          property bool pskEntry: false

          width: parent.width
          height: nr.pskEntry ? 76 : 44

          function connectWithPsk() {
            if (pskField.text.length === 0) return
            nr.net.connectWithPsk(pskField.text)
            nr.pskEntry = false
          }

          function pskFocus() {
            pskField.forceActiveFocus()
          }

          Rectangle {
            anchors.fill: parent
            radius: 6
            color: nr.net.connected ? Qt.alpha(Colors.accent, 0.15) : (nrHover.hovered ? Colors.color1 : "transparent")
            border.color: nr.net.connected ? Colors.accent : "transparent"
            border.width: nr.net.connected ? 1 : 0
          }

          Item {
            id: mainRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 44

            Text {
              id: nrIcon
              anchors.left: parent.left
              anchors.leftMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              text: root.signalGlyph(nr.net.signalStrength)
              color: nr.net.connected ? Colors.accent : Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 16
            }

            Column {
              id: nrInfo
              anchors.left: nrIcon.right
              anchors.right: nrActions.left
              anchors.leftMargin: 8
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              spacing: 1

              Text {
                width: parent.width - secLabel.implicitWidth - parent.spacing
                text: nr.net.name
                color: Colors.foreground
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSize
                elide: Text.ElideRight
              }

              Text {
                id: secLabel
                text: root.securityLabel(nr.net)
                color: nr.net.security === WifiSecurityType.Open ? Colors.color8 : Colors.color3
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeSmall
              }

              Text {
                text: root.stateLabel(nr.net)
                color: nr.net.connected ? Colors.accent : Colors.color8
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeSmall
              }
            }

            Row {
              id: nrActions
              anchors.right: parent.right
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              spacing: 4

              ControlButton {
                label: nr.net.connected ? "Disconnect" : "Connect"
                active: nr.net.connected
                onClickedBtn: root.networkAction(nr)
              }

              ControlButton {
                label: "Forget"
                visible: nr.net.known && !nr.net.connected
                onClickedBtn: nr.net.forget()
              }
            }
          }

          Row {
            id: nrPsk
            visible: nr.pskEntry
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            spacing: 6

            Rectangle {
              height: 24
              width: parent.width - pskBtn.width - parent.spacing
              radius: 4
              color: Colors.background
              border.color: Colors.color0
              border.width: 1

              TextInput {
                id: pskField
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                color: Colors.foreground
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeSmall
                clip: true
                echoMode: TextInput.Password
                onAccepted: nr.connectWithPsk()
              }
            }

            ControlButton {
              id: pskBtn
              label: "Connect"
              onClickedBtn: nr.connectWithPsk()
            }
          }

          Connections {
            target: nr.net
            function onConnectionFailed(reason) {
              if (reason === ConnectionFailReason.NoSecrets) {
                nr.pskEntry = true
                nr.pskFocus()
              }
            }
          }

          HoverHandler {
            id: nrHover
            cursorShape: Qt.PointingHandCursor
          }
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

  component ControlButton: Rectangle {
  id: cb
  required property string label
  property bool active: false
  property bool enabled: true
  signal clickedBtn

  height: 22
  radius: 4
  color: cbHover.containsMouse ? Colors.color1 : (cb.active ? Colors.accent : "transparent")
  border.color: cb.active ? "transparent" : Colors.color0
  border.width: 1
  opacity: cb.enabled ? 1 : 0.4
  width: cbLabel.implicitWidth + 14

  Text {
    id: cbLabel
    anchors.centerIn: parent
    text: cb.label
    color: cb.active ? Colors.background : Colors.foreground
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSizeSmall
  }

  MouseArea {
    id: cbHover
    anchors.fill: parent
    enabled: cb.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: cb.clickedBtn()
  }
}
}
