import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs
import qs.Components

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []

  readonly property var sinks: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && n.isSink && !n.isStream && n.audio) list.push(n)
    }
    return list
  }

  readonly property var sources: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && !n.isSink && !n.isStream && n.audio) list.push(n)
    }
    return list
  }

  readonly property var streams: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && n.isStream && n.isSink && n.audio) list.push(n)
    }
    return list
  }

  property var displayStreams: []
  property int currentSinkIndex: 0

  visible: root.shown
  color: "transparent"
  implicitWidth: 360
  implicitHeight: Math.ceil(card.implicitHeight)

  function toggle() { root.shown = !root.shown }

  function cycleSink() {
    if (sinks.length < 2) return
    root.currentSinkIndex = (root.currentSinkIndex + 1) % sinks.length
    Pipewire.preferredDefaultAudioSink = sinks[root.currentSinkIndex]
  }

  function openWiremix() {
    wiremixProc.command = ["ghostty", "--class=org.tui.Wiremix", "-e", "wiremix"]
    wiremixProc.running = true
  }

  function getSinkDisplayName(node) {
    if (!node) return ""
    return node.description || node.name || ""
  }

  function getStreamDisplayName(node) {
    if (!node) return ""
    var app = node.properties["application.name"]
    if (app) return app
    return node.description || node.name || ""
  }

  PwObjectTracker { objects: root.sinks }
  PwObjectTracker { objects: root.sources }
  PwObjectTracker { objects: root.streams }

  Timer {
    id: streamSnapshotTimer
    interval: 75
    repeat: false
    onTriggered: {
      root.displayStreams = root.streams
    }
  }

  onStreamsChanged: { streamSnapshotTimer.restart() }

  onShownChanged: {
    if (root.shown) {
      root.displayStreams = root.streams
      var def = Pipewire.defaultAudioSink
      for (var i = 0; i < sinks.length; i++) {
        if (sinks[i] === def) { root.currentSinkIndex = i; break }
      }
    }
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

  Process {
    id: wiremixProc
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

      // ---- Header ----
      Row {
        width: parent.width
        spacing: 8

        Text {
          id: titleText
          anchors.verticalCenter: parent.verticalCenter
          text: "Audio"
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          font.bold: true
        }

        Item {
          height: 1
          width: parent.width - titleText.implicitWidth - cycleBtn.width - parent.spacing
        }

        ControlButton {
          id: cycleBtn
          label: "󰓛 " + (root.sinks.length > 1 ? root.sinks.length : "1")
          enabled: root.sinks.length > 1
          onClickedBtn: root.cycleSink()
        }
      }

      // ---- Output section ----
      Text {
        width: parent.width
        text: "Output"
        color: Colors.color6
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
      }

      Text {
        width: parent.width
        visible: root.sinks.length > 0
        text: "󰓃 " + root.getSinkDisplayName(Pipewire.defaultAudioSink)
        color: Colors.color6
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        elide: Text.ElideRight
      }

      Row {
        width: parent.width
        spacing: 8

        Text {
          id: outputMute
          anchors.verticalCenter: parent.verticalCenter
          text: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio && Pipewire.defaultAudioSink.audio.muted ? "" : ""
          color: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio && Pipewire.defaultAudioSink.audio.muted ? Colors.color1 : Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: 16

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
                Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
            }
          }
        }

        Item {
          id: outputSlider
          height: 6
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - outputMute.width - outputVol.width - parent.spacing * 2

          Rectangle {
            anchors.fill: parent
            color: Colors.color0
            radius: 3
          }

          Rectangle {
            height: parent.height
            width: {
              if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return 0
              return parent.width * Math.max(0, Math.min(1, Pipewire.defaultAudioSink.audio.volume))
            }
            color: Colors.accent
            radius: 3
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: function(mouse) {
              if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, mouse.x / outputSlider.width))
            }
            onPositionChanged: function(mouse) {
              if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, mouse.x / outputSlider.width))
            }
            onWheel: function(wheel) {
              if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, Pipewire.defaultAudioSink.audio.volume + step))
              }
            }
          }
        }

        Text {
          id: outputVol
          anchors.verticalCenter: parent.verticalCenter
          text: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : ""
          color: Colors.color6
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          width: 36
          horizontalAlignment: Text.AlignRight
        }
      }

      // ---- Divider ----
      Rectangle {
        width: parent.width
        height: 1
        color: Colors.color0
      }

      // ---- Input section ----
      Text {
        width: parent.width
        text: "Input"
        color: Colors.color6
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
      }

      Text {
        width: parent.width
        visible: Pipewire.defaultAudioSource
        text: "󰍬 " + (Pipewire.defaultAudioSource ? (Pipewire.defaultAudioSource.description || Pipewire.defaultAudioSource.name || "") : "")
        color: Colors.color6
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        elide: Text.ElideRight
      }

      Row {
        width: parent.width
        spacing: 8

        Text {
          id: inputMute
          anchors.verticalCenter: parent.verticalCenter
          text: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio && Pipewire.defaultAudioSource.audio.muted ? "" : ""
          color: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio && Pipewire.defaultAudioSource.audio.muted ? Colors.color1 : Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: 16

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio)
                Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted
            }
          }
        }

        Item {
          id: inputSlider
          height: 6
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - inputMute.width - inputVol.width - parent.spacing * 2

          Rectangle {
            anchors.fill: parent
            color: Colors.color0
            radius: 3
          }

          Rectangle {
            height: parent.height
            width: {
              if (!Pipewire.defaultAudioSource || !Pipewire.defaultAudioSource.audio) return 0
              return parent.width * Math.max(0, Math.min(1, Pipewire.defaultAudioSource.audio.volume))
            }
            color: Colors.accent
            radius: 3
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: function(mouse) {
              if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio)
                Pipewire.defaultAudioSource.audio.volume = Math.max(0, Math.min(1, mouse.x / inputSlider.width))
            }
            onPositionChanged: function(mouse) {
              if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio)
                Pipewire.defaultAudioSource.audio.volume = Math.max(0, Math.min(1, mouse.x / inputSlider.width))
            }
            onWheel: function(wheel) {
              if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio) {
                var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                Pipewire.defaultAudioSource.audio.volume = Math.max(0, Math.min(1, Pipewire.defaultAudioSource.audio.volume + step))
              }
            }
          }
        }

        Text {
          id: inputVol
          anchors.verticalCenter: parent.verticalCenter
          text: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio ? Math.round(Pipewire.defaultAudioSource.audio.volume * 100) + "%" : ""
          color: Colors.color6
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          width: 36
          horizontalAlignment: Text.AlignRight
        }
      }

      // ---- Per-app streams divider ----
      Rectangle {
        width: parent.width
        height: 1
        color: Colors.color0
        visible: root.displayStreams.length > 0
      }

      // ---- Per-app streams section ----
      Text {
        width: parent.width
        visible: root.displayStreams.length > 0
        text: "Applications"
        color: Colors.color6
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
        font.bold: true
      }

      Repeater {
        model: root.displayStreams
        delegate: Item {
          width: column.width
          height: 34

          Row {
            anchors.fill: parent
            spacing: 8

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.getStreamDisplayName(modelData)
              color: Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSizeSmall
              elide: Text.ElideRight
              width: 90
            }

            Text {
              id: streamMute
              anchors.verticalCenter: parent.verticalCenter
              text: modelData.audio && modelData.audio.muted ? "" : ""
              color: modelData.audio && modelData.audio.muted ? Colors.color1 : Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 14

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (modelData.audio) modelData.audio.muted = !modelData.audio.muted
                }
              }
            }

            Item {
              id: streamSlider
              anchors.verticalCenter: parent.verticalCenter
              height: 4
              width: parent.width - 90 - streamMute.width - streamVol.width - parent.spacing * 3

              Rectangle {
                anchors.fill: parent
                color: Colors.color0
                radius: 2
              }

              Rectangle {
                height: parent.height
                width: {
                  if (!modelData.audio) return 0
                  return parent.width * Math.max(0, Math.min(1.5, modelData.audio.volume)) / 1.5
                }
                color: Colors.accent
                radius: 2
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: function(mouse) {
                  if (modelData.audio)
                    modelData.audio.volume = Math.max(0, Math.min(1.5, (mouse.x / streamSlider.width) * 1.5))
                }
                onPositionChanged: function(mouse) {
                  if (modelData.audio)
                    modelData.audio.volume = Math.max(0, Math.min(1.5, (mouse.x / streamSlider.width) * 1.5))
                }
                onWheel: function(wheel) {
                  if (modelData.audio) {
                    var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                    modelData.audio.volume = Math.max(0, Math.min(1.5, modelData.audio.volume + step))
                  }
                }
              }
            }

            Text {
              id: streamVol
              anchors.verticalCenter: parent.verticalCenter
              text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : ""
              color: Colors.color6
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSizeSmall
              width: 36
              horizontalAlignment: Text.AlignRight
            }
          }
        }
      }

      // ---- Footer divider ----
      Rectangle {
        width: parent.width
        height: 1
        color: Colors.color0
      }

      // ---- Footer: wiremix button ----
      Item {
        width: parent.width
        height: 24

        ControlButton {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          label: "󰘺 Open wiremix"
          onClickedBtn: root.openWiremix()
        }
      }
    }
  }
}
