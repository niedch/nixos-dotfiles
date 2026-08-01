import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick
import qs

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  readonly property var player: {
    var players = Mpris.players.values
    if (players.length === 0) return null
    for (var i = 0; i < players.length; i++) {
      if (players[i].playbackState === MprisPlaybackState.Playing) return players[i]
    }
    return players[0]
  }

  property real currentPos: 0
  property real lastVolume: 0

  visible: root.shown && root.player !== null
  color: "transparent"
  implicitWidth: 360
  implicitHeight: Math.ceil(card.implicitHeight)

  function toggle() {
    root.shown = !root.shown
  }

  function formatTime(secs) {
    if (!isFinite(secs) || secs < 0) secs = 0
    var m = Math.floor(secs / 60)
    var s = Math.floor(secs % 60)
    return m + ":" + (s < 10 ? "0" : "") + s
  }

  function setVolume(v) {
    var p = root.player
    if (!p || !p.volumeSupported) return
    p.volume = Math.max(0, Math.min(1, v))
  }

  Timer {
    id: posTimer
    interval: 500
    repeat: true
    running: root.visible && root.player !== null && root.player.isPlaying
    onTriggered: {
      if (root.player) root.currentPos = root.player.position
    }
  }

  onShownChanged: {
    if (root.shown && root.player) root.currentPos = root.player.position
  }

  HyprlandFocusGrab {
    windows: [root]
    active: root.shown
    onCleared: root.shown = false
  }

  anchor {
    id: popAnchor
    window: root.anchorWindow
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: {
      if (!root.target || !root.anchorWindow) return
      var pt = root.anchorWindow.contentItem.mapFromItem(root.target, 0, root.target.height + root.gap)
      popAnchor.rect.x = Math.round(pt.x)
      popAnchor.rect.y = Math.round(pt.y)
    }
  }

  Rectangle {
    id: card
    width: 360
    implicitHeight: column.implicitHeight + 24
    color: Colors.background
    border.color: Colors.color0
    border.width: 1
    radius: 8

    Column {
      id: column
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 12
      spacing: 10

      Row {
        width: parent.width
        spacing: 12

        Rectangle {
          id: art
          width: 64
          height: 64
          radius: 6
          clip: true
          color: Colors.color0

          Image {
            anchors.fill: parent
            source: root.player ? root.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 128
            sourceSize.height: 128
            visible: status === Image.Ready
          }

          Text {
            anchors.centerIn: parent
            text: "󰎈"
            visible: art.status !== Image.Ready || (root.player && root.player.trackArtUrl === "")
            color: Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: 26
          }
        }

        Column {
          width: parent.width - art.width - parent.spacing
          spacing: 2
          anchors.verticalCenter: art.verticalCenter

          Text {
            width: parent.width
            text: root.player ? root.player.trackTitle : "No track"
            color: Colors.foreground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSize
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: root.player ? root.player.trackArtist : ""
            color: Colors.foreground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSmall
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: root.player ? root.player.trackAlbum : ""
            color: Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSmall
            elide: Text.ElideRight
          }
        }
      }

      Item {
        width: parent.width
        height: 20

        Text {
          id: curLabel
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          text: root.formatTime(root.currentPos)
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }

        Item {
          id: seek
          anchors.left: curLabel.right
          anchors.right: totalLabel.left
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          height: 4

          Rectangle {
            anchors.fill: parent
            color: Colors.color0
            radius: 2
          }

          Rectangle {
            height: parent.height
            width: root.player && root.player.length > 0
              ? parent.width * Math.min(1, Math.max(0, root.currentPos / root.player.length))
              : 0
            color: Colors.accent
            radius: 2
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: function(mouse) {
              var p = root.player
              if (!p || !p.canSeek || p.length <= 0) return
              p.position = (mouse.x / seek.width) * p.length
            }
          }
        }

        Text {
          id: totalLabel
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: root.player ? root.formatTime(root.player.length) : ""
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }
      }

      Row {
        spacing: 4
        anchors.horizontalCenter: parent.horizontalCenter

        MediaButton {
          glyph: "󰒝"
          btnSize: 22
          isEnabled: root.player !== null && root.player.shuffleSupported
          isActive: root.player !== null && root.player.shuffle
          onClickedBtn: {
            var p = root.player
            if (p && p.shuffleSupported) p.shuffle = !p.shuffle
          }
        }

        MediaButton {
          glyph: "󰒮"
          btnSize: 22
          isEnabled: root.player !== null && root.player.canGoPrevious
          onClickedBtn: {
            var p = root.player
            if (p && p.canGoPrevious) p.previous()
          }
        }

        MediaButton {
          glyph: root.player !== null && root.player.isPlaying ? "󰏤" : "󰐊"
          btnSize: 34
          isEnabled: root.player !== null && root.player.canTogglePlaying
          onClickedBtn: {
            var p = root.player
            if (p) p.togglePlaying()
          }
        }

        MediaButton {
          glyph: "󰒭"
          btnSize: 22
          isEnabled: root.player !== null && root.player.canGoNext
          onClickedBtn: {
            var p = root.player
            if (p && p.canGoNext) p.next()
          }
        }

        MediaButton {
          glyph: "󰕗"
          btnSize: 22
          isEnabled: root.player !== null && root.player.loopSupported
          isActive: root.player !== null && root.player.loopState !== MprisLoopState.None
          onClickedBtn: {
            var p = root.player
            if (!p || !p.loopSupported) return
            if (p.loopState === MprisLoopState.None) p.loopState = MprisLoopState.Playlist
            else if (p.loopState === MprisLoopState.Playlist) p.loopState = MprisLoopState.Track
            else p.loopState = MprisLoopState.None
          }
        }

        MediaButton {
          glyph: {
            if (root.player === null || root.player.volume <= 0) return "󰝟"
            if (root.player.volume < 0.5) return "󰖀"
            return "󰕾"
          }
          btnSize: 22
          isEnabled: root.player !== null && root.player.volumeSupported
          onClickedBtn: {
            var p = root.player
            if (!p || !p.volumeSupported) return
            if (p.volume > 0) {
              root.lastVolume = p.volume
              p.volume = 0
            } else {
              p.volume = root.lastVolume > 0 ? root.lastVolume : 0.5
            }
          }
          onWheeled: function(delta) {
            var p = root.player
            if (p && p.volumeSupported) root.setVolume(p.volume + delta)
          }
        }
      }
    }
  }
}
