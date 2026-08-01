import Quickshell
import Quickshell.Networking
import QtQuick
import qs
import qs.Components.Network

Widget {
  id: widget

  text: {
    if (Networking.connectivity !== NetworkConnectivity.Full) return "󰤮"

    var devices = Networking.devices.values
    for (var i = 0; i < devices.length; i++) {
      var dev = devices[i]

      if (dev.type === DeviceType.Wifi && dev.state === ConnectionState.Connected) {
        var nets = dev.networks.values
        for (var j = 0; j < nets.length; j++) {
          var net = nets[j]
          if (net.state === ConnectionState.Connected) {
            var strength = net.signalStrength * 100
            if (strength > 75) return "󰤨"
            if (strength > 50) return "󰤥"
            if (strength > 25) return "󰤢"
            if (strength > 10) return "󰤟"
            return "󰤯"
          }
        }
        return "󰤨"
      }

      if (dev.type === DeviceType.Wired && dev.state === ConnectionState.Connected) {
        return "󰀂"
      }
    }
    return "󰤨"
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: netPopup.toggle()
  }

  NetworkPopup {
    id: netPopup
    target: widget
  }
}
