import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Item {
  id: root

  width: textItem.implicitWidth + 16
  implicitHeight: 26

  readonly property var player: Mpris.players.count > 0 ? Mpris.players.get(0) : null

  Text {
    id: textItem
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    elide: Text.ElideRight
    maximumLineCount: 1
    text: {
      if (!root.player) return ""
      var info = root.player.artist + " - " + root.player.title
      if (info.length > 30) info = info.substring(0, 27) + "..."

      if (root.player.playbackState === MprisPlaybackState.Playing) {
        return " " + info
      }
      if (root.player.playbackState === MprisPlaybackState.Paused) {
        return "󰝛 " + info
      }
      return ""
    }
    visible: root.player !== null
  }
}
