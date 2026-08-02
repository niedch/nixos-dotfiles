import Quickshell.Networking
import QtQuick
import qs
import qs.Components

Item {
  id: nr
  required property var modelData
  property int rowWidth: 0
  property int rowHeight: 44
  readonly property var net: nr.modelData
  property bool pskEntry: false

  width: nr.rowWidth
  height: nr.pskEntry ? nr.rowHeight + 32 : nr.rowHeight

  function signalGlyph() {
    var s = nr.net.signalStrength * 100
    if (s > 75) return "󰤨"
    if (s > 50) return "󰤥"
    if (s > 25) return "󰤢"
    if (s > 10) return "󰤟"
    return "󰤯"
  }

  function securityLabel() {
    switch (nr.net.security) {
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

  function stateLabel() {
    switch (nr.net.state) {
      case ConnectionState.Connecting: return "Connecting…"
      case ConnectionState.Connected: return ""
      case ConnectionState.Disconnecting: return "Disconnecting…"
      default: return ""
    }
  }

  function action() {
    if (nr.net.connected) {
      nr.net.disconnect()
    } else if (nr.net.known || nr.net.security === WifiSecurityType.Open) {
      nr.net.connect()
    } else {
      nr.pskEntry = true
      nr.psFocus()
    }
  }

  function connectWithPsk() {
    if (pskField.text.length === 0) return
    nr.net.connectWithPsk(pskField.text)
    nr.pskEntry = false
  }

  function psFocus() {
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
    height: nr.rowHeight

    Text {
      id: nrIcon
      anchors.left: parent.left
      anchors.leftMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      text: nr.signalGlyph()
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
      spacing: 2

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
        text: nr.securityLabel()
        color: nr.net.security === WifiSecurityType.Open ? Colors.color8 : Colors.color3
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      Text {
        text: nr.stateLabel()
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
        onClickedBtn: nr.action()
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
        nr.psFocus()
      }
    }
  }

  HoverHandler {
    id: nrHover
    cursorShape: Qt.PointingHandCursor
  }
}
