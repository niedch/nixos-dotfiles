import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs
import qs.Components.Weather

Item {
  id: scene
  width: 300
  height: 193
  clip: true

  required property var target
  property int dayIndex: 0
  property bool settled: false

  // Force dependency tracking by reading properties first
  readonly property var hourlyData: {
    if (!settled) return []
    if (!target || !target.forecastHourly || !target.forecastHourly[dayIndex]) return []
    return target.forecastHourly[dayIndex].hours || []
  }
  readonly property int itemCount: hourlyData.length

  // Active hour index (today only) - finds the hourly entry closest to current time
  property int activeIndex: -1
  property int selectedIndex: -1

  function updateActiveIndex() {
    if (dayIndex !== 0) { activeIndex = -1; return }
    if (!target || !target.forecastHourly || !target.forecastHourly[0] || !target.forecastHourly[0].hours) {
      activeIndex = 0; return
    }
    var data = target.forecastHourly[0].hours
    var now = new Date()
    var curHour = now.getHours()
    var bestIdx = 0
    var bestDiff = 24
    for (var i = 0; i < data.length; i++) {
      var parts = String(data[i].time).split(":")
      var h = parseInt(parts[0])
      var diff = Math.abs(h - curHour)
      if (diff < bestDiff) { bestDiff = diff; bestIdx = i }
    }
    activeIndex = bestIdx
  }

  onDayIndexChanged: {
    settled = false
    selectedIndex = -1
    updateActiveIndex()
    settledTimer.start()
  }
  Component.onCompleted: {
    updateActiveIndex()
    settledTimer.start()
  }

  Timer {
    id: settledTimer
    interval: 0
    running: false
    onTriggered: scene.settled = true
  }

  // Day navigation
  function prevDay() { if (dayIndex > 0) dayIndex-- }
  function nextDay() {
    var max = target && target.forecastHourly ? target.forecastHourly.length - 1 : 0
    if (dayIndex < max) dayIndex++
  }
  function dayLabel() {
    if (!target || !target.forecastHourly || !target.forecastHourly[dayIndex]) return ""
    var d = target.forecastHourly[dayIndex]
    var parts = String(d.date).split("-")
    if (parts.length !== 3) return ""
    var dt = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
    var today = new Date()
    if (dt.getFullYear() === today.getFullYear()
        && dt.getMonth() === today.getMonth()
        && dt.getDate() === today.getDate()) return "Today"
    var names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    return names[dt.getDay()]
  }

  Connections {
    target: scene.target
    function onForecastHourlyChanged() {
      settled = false
      updateActiveIndex()
      settledTimer.start()
    }
  }

  // Ring geometry
  readonly property real rx: 120
  readonly property real ry: 48

  // Animatable properties
  property real orbitAngle: 0
  property real orbitBreath: 1.0

  // Continuous orbit rotation (used for non-today days)
  NumberAnimation on orbitAngle {
    from: 0
    to: Math.PI * 2
    duration: 90000
    loops: Animation.Infinite
    running: true
    easing.type: Easing.Linear
  }

  // Subtle breathing of the ring
  SequentialAnimation on orbitBreath {
    loops: Animation.Infinite
    NumberAnimation { from: 1.0; to: 1.03; duration: 3500; easing.type: Easing.InOutSine }
    NumberAnimation { from: 1.03; to: 1.0; duration: 3500; easing.type: Easing.InOutSine }
  }

  // Central hub with wobble transforms
  Item {
    id: centralHub
    anchors.horizontalCenter: parent.horizontalCenter
    y: 30 + ry
    width: 1
    height: 1

    transform: [
      Rotation {
        id: pitchRot
        axis { x: 1; y: 0; z: 0 }
        origin.x: 0; origin.y: 0
        angle: 0
      },
      Rotation {
        id: yawRot
        axis { x: 0; y: 1; z: 0 }
        origin.x: 0; origin.y: 0
        angle: 0
      }
    ]

    // Subtle wobble animations
    SequentialAnimation {
      loops: Animation.Infinite
      NumberAnimation { target: pitchRot; property: "angle"; from: -2.5; to: 2.5; duration: 4200; easing.type: Easing.InOutSine }
      NumberAnimation { target: pitchRot; property: "angle"; from: 2.5; to: -2.5; duration: 4200; easing.type: Easing.InOutSine }
    }

    SequentialAnimation {
      loops: Animation.Infinite
      NumberAnimation { target: yawRot; property: "angle"; from: -2; to: 2; duration: 5100; easing.type: Easing.InOutSine }
      NumberAnimation { target: yawRot; property: "angle"; from: 2; to: -2; duration: 5100; easing.type: Easing.InOutSine }
    }

    // Dashed ellipse guide ring
    Canvas {
      id: orbitCanvas
      width: rx * 2 + 40
      height: ry * 2 + 40
      anchors.centerIn: parent
      opacity: 0.2
      scale: orbitBreath
      z: -1

      onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.strokeStyle = Colors.color8
        ctx.lineWidth = 1
        ctx.setLineDash([3, 8])
        ctx.beginPath()
        ctx.ellipse(width / 2, height / 2, rx, ry)
        ctx.stroke()
      }
    }

    // Orbit nodes
    Repeater {
      model: hourlyData
      delegate: Item {
        id: node
        width: 48
        height: 65

        readonly property int idx: index
        readonly property int activeIdx: scene.activeIndex
        readonly property bool isActive: dayIndex === 0 && index === scene.activeIndex

        // Compute angle: uniform spacing around the ring
        // Today: static ring with current hour at the front (bottom of ellipse)
        // Other days: rotating ring
        readonly property real angle: {
          if (dayIndex === 0 && scene.activeIndex >= 0) {
            return (Math.PI / 2) + (index - scene.activeIndex) * Math.PI * 2 / 8
          }
          return orbitAngle + index * Math.PI * 2 / 8
        }

        readonly property real cosVal: Math.cos(angle)
        readonly property real sinVal: Math.sin(angle)

        x: cosVal * rx * orbitBreath - width / 2
        y: sinVal * ry * orbitBreath - height / 2
        z: Math.round(sinVal * 100)

        scale: isActive ? 1.25 : 0.85 + 0.15 * ((sinVal + 1) / 2)
        opacity: isActive ? 1.0 : 0.5 + 0.35 * ((sinVal + 1) / 2)

        Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 600 } }

        Rectangle {
          anchors.fill: parent
          radius: 8
          color: scene.selectedIndex === index ? Colors.accent : (isActive ? Colors.color3 : Colors.background)
          border.color: scene.selectedIndex === index ? Colors.accent : (isActive ? Colors.color3 : Colors.color8)
          border.width: scene.selectedIndex === index ? 2 : (isActive ? 1.5 : 0.5)

          Behavior on color { ColorAnimation { duration: 600 } }
          Behavior on border.color { ColorAnimation { duration: 600 } }

          Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.time || ""
              color: (scene.selectedIndex === index || isActive) ? Colors.background : Colors.color8
              font.family: Constants.fontFamily
              font.pixelSize: 9
              font.bold: true
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.icon || ""
              color: Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 14
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: (modelData.tempC || "") + "°"
              color: Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 10
              font.bold: true
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (scene.selectedIndex === index) {
                scene.selectedIndex = -1
              } else {
                scene.selectedIndex = index
              }
            }
          }
        }
      }
    }

    // Day label centered in the ring
    Text {
      anchors.centerIn: parent
      text: dayLabel()
      color: Colors.accent
      font.family: Constants.fontFamily
      font.pixelSize: 14
      font.bold: true
      z: -1
    }
  }

  // Day navigation arrows
  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 4
    spacing: 24
    z: 100

    Text {
      text: "◀"
      color: dayIndex > 0 ? Colors.foreground : Colors.color8
      font.family: Constants.fontFamily
      font.pixelSize: 12
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: scene.prevDay()
      }
    }

    Text {
      text: "▶"
      color: {
        var max = target && target.forecastHourly ? target.forecastHourly.length - 1 : 0
        return dayIndex < max ? Colors.foreground : Colors.color8
      }
      font.family: Constants.fontFamily
      font.pixelSize: 12
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: scene.nextDay()
      }
    }
  }
}
