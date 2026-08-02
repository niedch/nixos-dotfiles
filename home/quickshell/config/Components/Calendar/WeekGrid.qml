import QtQuick
import qs

Item {
  id: weekGrid

  required property var theme
  required property var events

  readonly property int headerHeight: 36
  readonly property int allDayRowHeight: 24
  readonly property int gutterWidth: 36
  readonly property real hourHeight: 42
  readonly property int hourStart: 0
  readonly property int hourEnd: 24
  readonly property int gridHeight: (hourEnd - hourStart) * hourHeight
  readonly property real dayWidth: (width - gutterWidth) / 7
  readonly property var weekStart: theme.mondayOf(theme.weekAnchor)

  property var laidOut: []
  property var laidOutAllDay: []
  property bool hasAllDay: false
  property int todayCol: -1
  property bool _initialScrollDone: false

  function yFor(d) {
    var mins = d.getHours() * 60 + d.getMinutes() + d.getSeconds() / 60
    return (mins - hourStart * 60) / ((hourEnd - hourStart) * 60) * gridHeight
  }

  function tryInitialScroll() {
    if (_initialScrollDone) return
    if (flick.height < 50) return
    flick.contentY = weekGrid.yFor(new Date(2000, 0, 1, 8, 0))
    _initialScrollDone = true
  }

  function relayout() {
    var out = []
    var outAll = []
    var todayIdx = -1
    for (var day = 0; day < 7; day++) {
      var dayStart = theme.addDays(weekStart, day)
      var dayEnd = theme.addDays(dayStart, 1)
      if (theme.sameDay(dayStart, theme.now)) todayIdx = day
      for (var i = 0; i < events.length; i++) {
        var e = events[i]
        if (e.endDate <= dayStart || e.startDate >= dayEnd) continue
        if (e.all_day) {
          outAll.push({
            event: e,
            x: gutterWidth + day * dayWidth + 3,
            w: dayWidth - 6
          })
          continue
        }
        var s = e.startDate < dayStart ? dayStart : e.startDate
        var en = e.endDate > dayEnd ? dayEnd : e.endDate
        out.push({
          event: e,
          x: gutterWidth + day * dayWidth + 3,
          y: yFor(s),
          w: dayWidth - 6,
          h: Math.max(16, yFor(en) - yFor(s))
        })
      }
    }
    laidOut = out
    laidOutAllDay = outAll
    hasAllDay = outAll.length > 0
    todayCol = todayIdx
  }

  onEventsChanged: relayout()
  onWidthChanged: relayout()
  Component.onCompleted: Qt.callLater(relayout)

  Connections {
    target: theme
    function onWeekAnchorChanged() { relayout() }
    function onNowChanged() { relayout() }
  }

  Item {
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: weekGrid.headerHeight

    Repeater {
      model: 7
      delegate: Item {
        id: dh
        x: weekGrid.gutterWidth + index * weekGrid.dayWidth
        width: weekGrid.dayWidth
        height: parent.height

        property var day: theme.addDays(weekGrid.weekStart, index)
        property bool isToday: theme.sameDay(day, theme.now)

        Column {
          anchors.centerIn: parent
          spacing: 2

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(dh.day, "ddd").toUpperCase()
            color: dh.isToday ? theme.tint(Colors.accent, 0.9) : Colors.color8
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSmall
            font.weight: Font.DemiBold
          }

          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 22
            height: 22
            radius: 11
            color: dh.isToday ? Colors.accent : "transparent"

            Text {
              anchors.centerIn: parent
              text: dh.day.getDate()
              color: dh.isToday ? "#ffffff" : Colors.foreground
              font.family: Constants.fontFamily
              font.pixelSize: 10
            }
          }
        }

        Rectangle {
          x: 0
          y: 4
          width: 1
          height: parent.height - 8
          color: Colors.color0
          opacity: 0.5
        }

        Rectangle {
          anchors.fill: parent
          radius: 6
          color: dayHover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
        }

        MouseArea {
          id: dayHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: theme.openDay(dh.day)
        }
      }
    }

    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: 1
      color: Colors.color0
      opacity: 0.5
    }
  }

  Item {
    id: allDayHeader
    anchors {
      top: header.bottom
      left: parent.left
      right: parent.right
    }
    height: weekGrid.allDayRowHeight
    visible: weekGrid.hasAllDay
    clip: true

    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: 1
      color: Colors.color0
      opacity: 0.3
    }

    Repeater {
      model: 7
      delegate: Rectangle {
        x: weekGrid.gutterWidth + index * weekGrid.dayWidth
        y: 0
        width: 1
        height: parent.height
        color: Colors.color0
        opacity: 0.3
      }
    }

    Repeater {
      model: weekGrid.laidOutAllDay.length
      delegate: Item {
        readonly property var item: weekGrid.laidOutAllDay[index]
        x: item ? item.x : 0
        y: 2
        width: item ? item.w : 0
        height: weekGrid.allDayRowHeight - 4

        EventChip {
          anchors.fill: parent
          theme: weekGrid.theme
          eventData: parent.item ? parent.item.event : null
          onClicked: if (parent.item) weekGrid.theme.openEvent(parent.item.event)
        }
      }
    }
  }

  Flickable {
    id: flick
    anchors {
      top: allDayHeader.bottom
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
    contentWidth: width
    contentHeight: weekGrid.gridHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    onHeightChanged: weekGrid.tryInitialScroll()
    Component.onCompleted: Qt.callLater(weekGrid.tryInitialScroll)

    Repeater {
      model: 24
      delegate: Item {
        y: index * weekGrid.hourHeight
        width: weekGrid.gutterWidth
        height: weekGrid.hourHeight

        Text {
          anchors.right: parent.right
          anchors.rightMargin: 6
          y: -6
          text: index + ":00"
          color: Colors.color8
          font.family: Constants.fontFamily
          font.pixelSize: Constants.fontSizeSmall
        }
      }
    }

    Repeater {
      model: 7
      delegate: Rectangle {
        x: weekGrid.gutterWidth + index * weekGrid.dayWidth
        y: 0
        width: weekGrid.dayWidth
        height: weekGrid.gridHeight
        color: theme.sameDay(theme.addDays(weekGrid.weekStart, index), theme.now)
          ? theme.tint(Colors.accent, 0.07)
          : "transparent"
      }
    }

    Repeater {
      model: 24
      delegate: Rectangle {
        x: weekGrid.gutterWidth
        y: index * weekGrid.hourHeight
        width: weekGrid.width - weekGrid.gutterWidth
        height: 1
        color: Colors.color0
        opacity: 0.4
        visible: index > 0
      }
    }

    Repeater {
      model: weekGrid.laidOut.length
      delegate: Item {
        readonly property var item: weekGrid.laidOut[index]
        x: item ? item.x : 0
        y: item ? item.y : 0
        width: item ? item.w : 0
        height: item ? item.h : 0

        EventChip {
          anchors.fill: parent
          theme: weekGrid.theme
          eventData: parent.item ? parent.item.event : null
          onClicked: if (parent.item) weekGrid.theme.openEvent(parent.item.event)
        }
      }
    }

    Item {
      id: nowLine
      visible: weekGrid.todayCol >= 0
      x: weekGrid.todayCol >= 0 ? weekGrid.gutterWidth + weekGrid.todayCol * weekGrid.dayWidth : 0
      y: weekGrid.yFor(theme.now)
      width: visible ? weekGrid.dayWidth : 0
      height: 2
      z: 5

      Rectangle {
        anchors.fill: parent
        color: Colors.color1
      }

      Rectangle {
        x: -4
        y: -3
        width: 8
        height: 8
        radius: 4
        color: Colors.color1
      }
    }
  }
}
