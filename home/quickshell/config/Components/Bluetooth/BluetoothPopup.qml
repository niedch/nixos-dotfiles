import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs
import qs.Components
import qs.Components.Bluetooth

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6
  property int scanDuration: 30

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  readonly property var adapter: Bluetooth.defaultAdapter
  property bool scanning: false

  readonly property var pairedDevices: filteredDevices(true)
  readonly property var discoveredDevices: filteredDevices(false)

  visible: root.shown
  color: "transparent"
  implicitWidth: 360
  implicitHeight: Math.ceil(card.implicitHeight)

  // ---- helpers ----

  function filteredDevices(known) {
    var out = []
    if (!root.adapter) return out
    var vals = root.adapter.devices.values
    for (var i = 0; i < vals.length; i++) {
      var isKnown = vals[i].paired || vals[i].trusted
      if (known === isKnown) out.push(vals[i])
    }
    return out
  }

  function toggle() {
    root.shown = !root.shown
  }

  function togglePower() {
    if (root.adapter) root.adapter.enabled = !root.adapter.enabled
  }

  function toggleScan() {
    if (root.scanning) {
      stopScan()
    } else {
      root.scanning = true
      if (root.adapter) root.adapter.discovering = true
      scanTimer.start()
    }
  }

  function stopScan() {
    scanTimer.stop()
    root.scanning = false
    if (root.adapter) root.adapter.discovering = false
  }

  function stateLabel() {
    if (!root.adapter) return "Unavailable"
    switch (root.adapter.state) {
      case BluetoothAdapterState.Disabled: return "Off"
      case BluetoothAdapterState.Enabled: return "On"
      case BluetoothAdapterState.Enabling: return "Enabling…"
      case BluetoothAdapterState.Disabling: return "Disabling…"
      case BluetoothAdapterState.Blocked: return "Blocked"
    }
    return "Unknown"
  }

  function openBluetui() {
    btProc.command = ["ghostty", "--class=org.tui.Bluetui", "-e", "bluetui"]
    btProc.running = true
  }

  onShownChanged: {
    if (!root.shown) root.stopScan()
  }

  Timer {
    id: scanTimer
    interval: root.scanDuration * 1000
    repeat: false
    onTriggered: root.stopScan()
  }

  Process {
    id: btProc
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
    implicitHeight: column.implicitHeight + 24
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
          text: "Bluetooth"
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
            label: root.adapter && root.adapter.enabled ? "󰂲 Turn Off" : "󰂲 Turn On"
            active: root.adapter !== null && root.adapter.enabled
            enabled: root.adapter !== null
            onClickedBtn: root.togglePower()
          }

          ControlButton {
            label: root.scanning ? "󰂯 Stop Scan" : "󰂯 Scan"
            active: root.scanning
            enabled: root.adapter !== null && root.adapter.enabled
            onClickedBtn: root.toggleScan()
          }
        }
      }

      Row {
        width: parent.width
        spacing: 6

        Text {
          text: root.adapter ? root.adapter.name : "No adapter"
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }

        Text {
          text: root.stateLabel()
          color: root.adapter && root.adapter.state === BluetoothAdapterState.Blocked
            ? Colors.color1
            : Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }

        Text {
          visible: root.scanning
          text: "󰂯"
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
        visible: !root.adapter
        text: "No Bluetooth adapter available"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        wrapMode: Text.WordWrap
      }

      Text {
        width: parent.width
        visible: root.adapter && root.adapter.state === BluetoothAdapterState.Blocked
        text: "Adapter is blocked by rfkill."
        color: Colors.color1
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      Text {
        width: parent.width
        visible: root.adapter && !root.adapter.enabled
          && root.adapter.state !== BluetoothAdapterState.Blocked
        text: "Bluetooth is off"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      Text {
        width: parent.width
        visible: root.adapter && root.adapter.enabled && root.pairedDevices.length > 0
        text: "Devices"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
      }

      Repeater {
        model: root.adapter && root.adapter.enabled ? root.pairedDevices : []
        delegate: DeviceRow {
          rowWidth: column.width
        }
      }

      Text {
        width: parent.width
        visible: root.scanning && root.discoveredDevices.length > 0
        text: "Discovered"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
      }

      Repeater {
        model: root.adapter && root.adapter.enabled && root.scanning ? root.discoveredDevices : []
        delegate: DeviceRow {
          rowWidth: column.width
        }
      }

      Text {
        width: parent.width
        visible: root.adapter && root.adapter.enabled
          && root.pairedDevices.length === 0 && root.discoveredDevices.length === 0
        text: root.scanning ? "Searching for devices…" : "No devices found"
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
          label: "󰘺 Open bluetui"
          onClickedBtn: root.openBluetui()
        }
      }
    }
  }
}

