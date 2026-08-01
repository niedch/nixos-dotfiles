import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs
import qs.Components.Bluetooth

Widget {
  id: widget

  text: {
    if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "󰂲"
    if (Bluetooth.defaultAdapter.discovering) return "󰂯"
    var vals = Bluetooth.devices.values
    for (var i = 0; i < vals.length; i++) {
      if (vals[i].connected) return "󰂱"
    }
    return ""
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: btPopup.toggle()
  }

  BluetoothPopup {
    id: btPopup
    target: widget
  }
}
