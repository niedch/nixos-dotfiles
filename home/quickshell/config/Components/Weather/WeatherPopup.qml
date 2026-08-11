import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs
import qs.Components.Weather

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  visible: root.shown
  color: "transparent"
  implicitWidth: 360
  implicitHeight: Math.ceil(card.implicitHeight)

  function toggle() {
    root.shown = !root.shown
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
      var lx = root.target.width / 2 - root.implicitWidth / 2
      var ly = root.target.height + root.gap
      var pt = root.anchorWindow.contentItem.mapFromItem(root.target, lx, ly)
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
      spacing: 4

      Row {
        width: parent.width
        spacing: 8

        Text {
          id: title
          anchors.verticalCenter: parent.verticalCenter
          text: "Weather"
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
          font.bold: true
        }

        Item {
          height: 1
          width: parent.width - title.implicitWidth - descText.implicitWidth - parent.spacing * 2
        }

        Text {
          id: descText
          anchors.verticalCenter: parent.verticalCenter
          text: root.target ? root.target.description : ""
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          elide: Text.ElideRight
        }
      }

      Row {
        width: parent.width
        spacing: 12

        WeatherScene {
          id: weatherScene
          width: 110
          height: 75
          anchors.verticalCenter: parent.verticalCenter
          weatherCode: root.target ? root.target.weatherCode : ""
          isNight: root.target ? root.target.isNight : false
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2

          Row {
      spacing: 4

            Text {
              text: (root.target ? root.target.tempC : "") + "°C"
              color: Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 22
              font.bold: true
            }

            Text {
              text: "Feels " + (root.target ? root.target.feelsLikeC : "") + "°C"
              anchors.verticalCenter: parent.verticalCenter
              color: Colors.color8
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSizeSmall
            }
          }

          Row {
            spacing: 14

            Text {
              text: "󰜃 " + (root.target ? root.target.humidity : "") + "%"
              color: Colors.color8
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSizeSmall
            }

            Text {
              text: "󰖝 " + (root.target ? root.target.windSpeed : "") + " km/h"
              color: Colors.color8
              font.family: Constants.fontFamily
              font.pixelSize: Constants.fontSizeSmall
            }
          }
        }
      }

      OrbitScene {
        id: orbitScene
        anchors.horizontalCenter: parent.horizontalCenter
        target: root.target
        visible: orbitScene.hasData
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Colors.color0
        visible: orbitScene.visible
      }

      Row {
        width: parent.width
        spacing: 8
        visible: root.target && root.target.weatherIcon !== ""

        Text {
          id: forecastLabel
          text: "Forecast"
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
          font.bold: true
        }

        Item {
          height: 1
          width: parent.width - forecastLabel.implicitWidth - moonIcon.implicitWidth - moonText.implicitWidth - parent.spacing * 3
        }

        Text {
          id: moonIcon
          text: root.target ? WeatherCodes.moonIcon(root.target.moonPhase) : ""
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSize
        }

        Text {
          id: moonText
          text: (root.target ? root.target.moonPhase : "")
            + (root.target && root.target.moonIllumination !== "" ? " (" + root.target.moonIllumination + "%)" : "")
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }
      }

      Repeater {
        model: root.target ? root.target.forecast : []
        delegate: Row {
          width: column.width
          spacing: 8

          Text {
            width: 44
            text: WeatherCodes.dayLabel(modelData.date)
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.foreground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSmall
            font.bold: true
          }

          Text {
            width: 24
            text: modelData.icon
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.foreground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSize
          }

          Text {
            width: 60
            text: modelData.maxC + "° / " + modelData.minC + "°"
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.foreground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSmall
          }

          Text {
            text: modelData.desc
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSmall
            elide: Text.ElideRight
          }
        }
      }

      Text {
        width: parent.width
        visible: !root.target || root.target.weatherIcon === ""
        text: "Weather unavailable"
        color: Colors.color8
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }
    }
  }
}
