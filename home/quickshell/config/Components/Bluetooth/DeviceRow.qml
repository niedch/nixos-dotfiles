import Quickshell.Bluetooth
import QtQuick
import qs
import qs.Components

Item {
  id: dr
  required property var modelData
  property int rowWidth: 0
  readonly property var dev: dr.modelData

  width: dr.rowWidth
  height: 44

  function glyph() {
    var map = {
      "audio-headset": "󰋋",
      "audio-card": "󰋋",
      "audio-input-microphone": "󰍬",
      "input-keyboard": "󰌌",
      "input-mouse": "󰍽",
      "input-gaming": "󰊕",
      "input-tablet": "󰓡",
      "phone": "󰏲",
      "computer": "󰖩",
      "camera-video": "󰄀"
    }
    return map[dr.dev.icon] || "󰂯"
  }

  function stateLabel() {
    if (dr.dev.pairing) return "Pairing…"
    switch (dr.dev.state) {
      case BluetoothDeviceState.Connected: return "Connected"
      case BluetoothDeviceState.Connecting: return "Connecting…"
      case BluetoothDeviceState.Disconnecting: return "Disconnecting…"
      default: return dr.dev.paired ? "Paired" : (dr.dev.trusted ? "Trusted" : "Discovered")
    }
  }

  function battery() {
    if (!dr.dev.batteryAvailable) return ""
    return "󰁹 " + Math.round(dr.dev.battery * 100) + "%"
  }

  function actionLabel() {
    if (dr.dev.pairing) return "Cancel"
    if (dr.dev.connected) return "Disconnect"
    if (dr.dev.paired || dr.dev.trusted) return "Connect"
    return "Pair"
  }

  function action() {
    if (dr.dev.pairing) {
      dr.dev.cancelPair()
    } else if (dr.dev.paired || dr.dev.trusted) {
      dr.dev.connected = !dr.dev.connected
    } else {
      dr.dev.pair()
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: drHover.hovered ? Colors.color1 : "transparent"
  }

  Text {
    id: drIcon
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: dr.glyph()
    color: Colors.foreground
    font.family: Constants.fontFamily
    font.pixelSize: 16
  }

  Column {
    id: drInfo
    anchors.left: drIcon.right
    anchors.right: drActions.left
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 1

    Row {
      width: parent.width
      spacing: 6

      Text {
        width: parent.width - batteryText.implicitWidth - parent.spacing
        text: dr.dev.name
        color: Colors.foreground
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSize
        elide: Text.ElideRight
      }

      Text {
        id: batteryText
        text: dr.battery()
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }
    }

    Row {
      width: parent.width
      spacing: 6

      Text {
        text: dr.dev.address
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      Text {
        text: dr.stateLabel()
        color: dr.dev.connected ? Colors.accent : Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }
    }
  }

  Row {
    id: drActions
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    ControlButton {
      label: dr.actionLabel()
      active: dr.dev.connected
      onClickedBtn: dr.action()
    }

    ControlButton {
      label: "Forget"
      visible: (dr.dev.paired || dr.dev.trusted) && !dr.dev.pairing
      onClickedBtn: dr.dev.forget()
    }
  }

  HoverHandler {
    id: drHover
    cursorShape: Qt.PointingHandCursor
  }
}
