import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs
import qs.Components.Calendar

PopupWindow {
  id: root

  required property Item target
  property bool shown: false
  property int gap: 6

  // ---- view state ----
  property string viewMode: "month"
  property date monthAnchor: firstOfMonth(new Date())
  property date weekAnchor: mondayOf(new Date())
  property date selectedDate: new Date()
  property date now: new Date()
  property var events: []
  property bool loading: false

  readonly property var anchorWindow: root.target && root.target.QsWindow ? root.target.QsWindow.window : null

  visible: root.shown
  color: "transparent"
  implicitWidth: root.cardWidth
  implicitHeight: root.cardHeight

  property int cardWidth: root.viewMode === "month" ? 336 : 700
  property int cardHeight: root.viewMode === "month" ? 332 : 430

  // ---- date helpers ----
  function startOfDay(d) {
    var x = new Date(d)
    x.setHours(0, 0, 0, 0)
    return x
  }

  function mondayOf(d) {
    var x = startOfDay(d)
    x.setDate(x.getDate() - ((x.getDay() + 6) % 7))
    return x
  }

  function addDays(d, n) {
    var x = new Date(d)
    x.setDate(x.getDate() + n)
    return x
  }

  function firstOfMonth(d) {
    var x = startOfDay(d)
    x.setDate(1)
    return x
  }

  function addMonths(d, n) {
    var x = firstOfMonth(d)
    x.setMonth(x.getMonth() + n)
    return x
  }

  function sameDay(a, b) {
    return a.getFullYear() === b.getFullYear()
      && a.getMonth() === b.getMonth()
      && a.getDate() === b.getDate()
  }

  function ymd(d) {
    return d.getFullYear() + "-"
      + ("0" + (d.getMonth() + 1)).slice(-2) + "-"
      + ("0" + d.getDate()).slice(-2)
  }

  function weekTitle() {
    var a = weekAnchor
    var b = addDays(a, 6)
    if (a.getMonth() === b.getMonth())
      return Qt.formatDate(a, "MMM d") + " – " + Qt.formatDate(b, "d, yyyy")
    return Qt.formatDate(a, "MMM d") + " – " + Qt.formatDate(b, "MMM d, yyyy")
  }

  function fmtTime(d) {
    return Qt.formatTime(d, "HH:mm")
  }

  function fmtRange(a, b) {
    return fmtTime(a) + "–" + fmtTime(b)
  }

  function tint(c, a) {
    var col = Qt.color(String(c))
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  function overlapsDay(e, day) {
    var ds = startOfDay(day)
    return e.endDate > ds && e.startDate < addDays(ds, 1)
  }

  readonly property var calPalette: [Colors.color1, Colors.color2, Colors.color3, Colors.color4, Colors.color5, Colors.color6]

  function calColorIndex(e) {
    if (e.calendar_color) return -1
    var s = e.calendar_label || ""
    var h = 0
    for (var i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0
    return h % root.calPalette.length
  }

  // ---- navigation ----
  function goPrev() {
    if (viewMode === "month") monthAnchor = addMonths(monthAnchor, -1)
    else weekAnchor = addDays(weekAnchor, -7)
    reload()
  }

  function goNext() {
    if (viewMode === "month") monthAnchor = addMonths(monthAnchor, 1)
    else weekAnchor = addDays(weekAnchor, 7)
    reload()
  }

  function goToday() {
    var n = new Date()
    monthAnchor = firstOfMonth(n)
    weekAnchor = mondayOf(n)
    selectedDate = startOfDay(n)
    reload()
  }

  function showWeekFor(day) {
    selectedDate = startOfDay(day)
    weekAnchor = mondayOf(day)
    viewMode = "week"
    reload()
  }

  function setMonth() {
    monthAnchor = firstOfMonth(selectedDate)
    viewMode = "month"
    reload()
  }

  function setWeek() {
    weekAnchor = mondayOf(selectedDate)
    viewMode = "week"
    reload()
  }

  function toggle() {
    root.shown = !root.shown
  }

  function openEvent(e) {
    var d = e && e.startDate ? e.startDate : new Date()
    openDay(d)
  }

  function openDay(d) {
    var url = "https://calendar.google.com/calendar/u/0/r/day/"
      + d.getFullYear() + "/" + (d.getMonth() + 1) + "/" + d.getDate()
    openProc.command = ["chromium", "--app=" + url]
    openProc.running = false
    openProc.running = true
    root.shown = false
  }

  // ---- data ----
  function viewStartDate() {
    if (viewMode === "month") return mondayOf(firstOfMonth(monthAnchor))
    return mondayOf(weekAnchor)
  }

  function reload() {
    if (loading) return
    loading = true
    var start = viewStartDate()
    eventsProc.command = [
      "calendar-sync", "list",
      "--from", ymd(start),
      "--to", ymd(addDays(start, 42)),
      "--json"
    ]
    eventsProc.running = false
    eventsProc.running = true
  }

  Timer {
    interval: 30 * 1000
    running: root.shown
    repeat: true
    onTriggered: root.now = new Date()
  }

  Timer {
    interval: 5 * 60 * 1000
    running: root.shown
    repeat: true
    onTriggered: root.reload()
  }

  onShownChanged: {
    if (root.shown) {
      root.now = new Date()
      reload()
    }
  }

  Process {
    id: eventsProc
    stdout: StdioCollector { id: eventsOut }
    onExited: {
      var text = eventsOut.text.trim()
      try {
        var d = JSON.parse(text)
        root.events = (d.events || []).map(function(e) {
          e.startDate = new Date(e.start)
          e.endDate = new Date(e.end)
          return e
        })
      } catch (err) {
        console.warn("calendar: failed to parse events:", err)
      }
      root.loading = false
    }
  }

  Process {
    id: openProc
    command: ["true"]
    running: false
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
    width: root.cardWidth
    height: root.cardHeight
    color: Colors.background
    border.color: Colors.color0
    border.width: 1
    radius: 8

    Column {
      anchors.fill: parent
      anchors.margins: 8
      spacing: 6

      RowLayout {
        width: parent.width
        height: 28
        spacing: 4

        Text {
          text: root.viewMode === "month"
            ? Qt.formatDate(root.monthAnchor, "MMMM yyyy")
            : root.weekTitle()
          color: Colors.foreground
          font.family: Constants.fontFamily
          font.pixelSize: 12
          font.weight: Font.DemiBold
          elide: Text.ElideRight
          Layout.fillWidth: true
        }

        CalButton { glyph: "‹"; onClickedBtn: root.goPrev() }
        CalButton { glyph: "•"; onClickedBtn: root.goToday() }
        CalButton { glyph: "›"; onClickedBtn: root.goNext() }

        Rectangle {
          width: 6
          height: 1
          color: "transparent"
        }

        CalToggleButton { text: "Month"; active: root.viewMode === "month"; onClickedBtn: root.setMonth() }
        CalToggleButton { text: "Week"; active: root.viewMode === "week"; onClickedBtn: root.setWeek() }
        CalButton { glyph: root.loading ? "⏳" : "⟳"; onClickedBtn: root.reload() }
      }

      Item {
        width: parent.width
        height: root.cardHeight - 16 - 28 - parent.spacing
        clip: true

        MonthGrid {
          anchors.fill: parent
          visible: root.viewMode === "month"
          theme: root
          events: root.events
          onDayClicked: function(day) { root.showWeekFor(day) }
        }

        WeekGrid {
          anchors.fill: parent
          visible: root.viewMode === "week"
          theme: root
          events: root.events
        }
      }
    }
  }

  component CalButton: Rectangle {
    property string glyph: ""
    signal clickedBtn()
    width: 26
    height: 26
    radius: 6
    color: btnHover.containsMouse ? Colors.color0 : "transparent"

    Text {
      anchors.centerIn: parent
      text: parent.glyph
      color: Colors.foreground
      font.family: Constants.fontFamily
      font.pixelSize: 12
    }

    MouseArea {
      id: btnHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: parent.clickedBtn()
    }
  }

  component CalToggleButton: Rectangle {
    property string text: ""
    property bool active: false
    signal clickedBtn()
    width: toggleLabel.implicitWidth + 14
    height: 26
    radius: 6
    color: active
      ? Colors.color0
      : (toggleHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

    Text {
      id: toggleLabel
      anchors.centerIn: parent
      text: parent.text
      color: parent.active ? Colors.accent : Colors.foreground
      font.family: Constants.fontFamily
      font.pixelSize: Constants.fontSizeSmall
      font.weight: parent.active ? Font.DemiBold : Font.Normal
    }

    MouseArea {
      id: toggleHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: parent.clickedBtn()
    }
  }
}
