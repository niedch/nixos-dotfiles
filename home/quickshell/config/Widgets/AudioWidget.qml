import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import qs

Widget {
  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  text: {
    if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return ""
    if (Pipewire.defaultAudioSink.audio.muted) return ""
    var vol = Math.round(Pipewire.defaultAudioSink.audio.volume * 100)
    var icon = ""
    if (vol > 50) icon = ""
    else if (vol > 25) icon = ""
    return icon
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
        audioProc.command = ["ghostty", "--class=org.tui.Wiremix", "-e", "wiremix"]
        audioProc.running = true
      }
    }
    onWheel: function(wheel) {
      if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return
      var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
      Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, Pipewire.defaultAudioSink.audio.volume + step))
    }
  }

  Process {
    id: audioProc
  }

  Process {
    id: toggleProc
  }
}
