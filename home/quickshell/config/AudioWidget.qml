import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

Item {
  id: root

  width: textItem.implicitWidth + 16
  implicitHeight: 26

  readonly property var defaultSink: Pipewire.defaultAudioSink

  Text {
    id: textItem
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: {
      if (!root.defaultSink || !root.defaultSink.audio) return ""
      if (root.defaultSink.audio.mute) return ""
      var vol = Math.round(root.defaultSink.audio.volume * 100)
      var icon = ""
      if (vol > 50) icon = ""
      else if (vol > 25) icon = ""
      return icon
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        toggleProc.command = ["pamixer", "-t"]
        toggleProc.running = true
      } else {
        audioProc.command = ["ghostty", "--class=org.omarchy.Wiremix", "-e", "wiremix"]
        audioProc.running = true
      }
    }
    onWheel: function(wheel) {
      if (!root.defaultSink || !root.defaultSink.audio) return
      var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
      root.defaultSink.audio.volume = Math.max(0, Math.min(1, root.defaultSink.audio.volume + step))
    }
  }

  Process {
    id: audioProc
  }

  Process {
    id: toggleProc
  }
}
