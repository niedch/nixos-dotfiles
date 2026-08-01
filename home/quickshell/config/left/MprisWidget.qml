import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import qs

Widget {
  id: widget

  textItem.elide: Text.ElideRight
  textItem.maximumLineCount: 1
  textVisible: mediaPopup.player !== null

  text: {
    var p = mediaPopup.player
    if (!p) return ""
    var info = p.trackArtist + " - " + p.trackTitle
    if (info.length > 30) info = info.substring(0, 27) + "..."

    if (p.isPlaying) {
      return "󰛚 " + info
    }
    if (p.playbackState === MprisPlaybackState.Paused) {
      return "󰝛 " + info
    }
    return ""
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: mediaPopup.toggle()
  }

  MediaPopup {
    id: mediaPopup
    target: widget
  }
}
