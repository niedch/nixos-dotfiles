import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import qs

Widget {
  textItem.elide: Text.ElideRight
  textItem.maximumLineCount: 1
  textVisible: Mpris.players.values.length > 0

  text: {
    var players = Mpris.players.values
    var player = players.length > 0 ? players[0] : null
    if (!player) return ""
    var info = player.artist + " - " + player.title
    if (info.length > 30) info = info.substring(0, 27) + "..."

    if (player.playbackState === MprisPlaybackState.Playing) {
      return " " + info
    }
    if (player.playbackState === MprisPlaybackState.Paused) {
      return "󰝛 " + info
    }
    return ""
  }
}
