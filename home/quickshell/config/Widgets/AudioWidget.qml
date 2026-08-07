import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import qs
import qs.Components.Audio

Widget {
  id: widget

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  readonly property bool isHeadphone: {
    if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.properties) return false
    var ff = Pipewire.defaultAudioSink.properties["device.form-factor"]
    if (ff === "headphone" || ff === "headset" || ff === "hands-free") return true
    var icon = Pipewire.defaultAudioSink.properties["device.icon-name"]
    if (icon && (icon.indexOf("headphone") >= 0 || icon.indexOf("headset") >= 0)) return true
    return false
  }

  text: {
    if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return ""
    if (Pipewire.defaultAudioSink.audio.muted) return ""
    if (isHeadphone) return ""
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
        audioPopup.toggle()
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

  AudioPopup {
    id: audioPopup
    target: widget
  }
}
