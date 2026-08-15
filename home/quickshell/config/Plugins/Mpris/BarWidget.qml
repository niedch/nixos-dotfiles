import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: widget
  moduleName: "quickshell.mpris"

  property bool active: mediaPopup.player !== null
  property bool playing: mediaPopup.player !== null && mediaPopup.player.isPlaying

  // Cava state
  property string cavaOutput: ""

  // Auto-hide when no player
  implicitWidth: {
    if (!active) return separatorText.implicitWidth + 4
    return mprisText.implicitWidth + (playing ? cavaText.implicitWidth + 8 : 0) + 8
  }
  implicitHeight: Constants.barHeight

  // Separator (visible when no player)
  Text {
    id: separatorText
    anchors.centerIn: parent
    visible: !widget.active
    color: Color.foreground
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSize
    text: Constants.separatorText
  }

  // Mpris + Cava row (visible when player active)
  Row {
    id: mprisRow
    anchors.centerIn: parent
    visible: widget.active
    spacing: 0

    // Mpris text
    Text {
      id: mprisText
      anchors.verticalCenter: parent.verticalCenter
      color: Color.foreground
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSize
      elide: Text.ElideRight
      maximumLineCount: 1
      text: {
        var p = mediaPopup.player
        if (!p) return ""
        var info = p.trackArtist + " - " + p.trackTitle
        if (info.length > 30) info = info.substring(0, 27) + "..."
        if (p.isPlaying) return "󰛚 " + info
        if (p.playbackState === MprisPlaybackState.Paused) return "󰝛 " + info
        return ""
      }
    }

    // Cava visualizer (only when playing)
    Text {
      id: cavaText
      visible: widget.playing
      anchors.verticalCenter: parent.verticalCenter
      color: Color.foreground
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSize
      text: widget.cavaOutput
    }
  }

  // Click to toggle media popup
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: mediaPopup.toggle()
  }

  // Media popup
  MediaPopup {
    id: mediaPopup
    target: widget
  }

  // Cava process (only runs when playing)
  Process {
    id: cavaProc
    command: ["bash", "-c", (Quickshell.env("QS_CONFIG_PATH") ?? "") + "/scripts/cava.sh"]
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(data) {
        widget.cavaOutput = data.trim()
      }
    }
    onRunningChanged: {
      if (!running && widget.playing) restartTimer.start()
    }
  }

  Timer {
    id: restartTimer
    interval: 1000
    onTriggered: cavaProc.running = true
  }

  // Gate cava on playing state
  onPlayingChanged: {
    if (playing) {
      if (!cavaProc.running) cavaProc.running = true
    } else {
      cavaProc.running = false
      cavaOutput = ""
      restartTimer.stop()
    }
  }

  Component.onCompleted: {
    if (widget.playing) cavaProc.running = true
  }

  Component.onDestruction: {
    restartTimer.stop()
    cavaProc.running = false
  }
}
