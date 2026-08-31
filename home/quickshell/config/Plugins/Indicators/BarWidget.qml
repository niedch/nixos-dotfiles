import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "quickshell.indicators"

  property bool hovered: false

  // 150ms Debounce timer to prevent rapid open/close on small mouse exits
  Timer {
    id: hoverDebounceTimer
    interval: 150
    onTriggered: {
      if (!barHoverHandler.hovered) {
        root.hovered = false
      }
    }
  }

  // Monitor hover events directly on the BarWidget root.
  // Because we physically expand 'width' and translate it to the left,
  // the root's own hit-testing box is always perfectly aligned with the visual icons!
  HoverHandler {
    id: barHoverHandler
    onHoveredChanged: {
      if (barHoverHandler.hovered) {
        hoverDebounceTimer.stop()
        root.hovered = true
      } else {
        hoverDebounceTimer.start()
      }
    }
  }

  // Base sizing driven by the bar geometry and dynamic children widths
  implicitHeight: Constants.barHeight
  implicitWidth: handleText.implicitWidth + 12 + collapsedRowWidth

  // We expand the physical width on hover, but we keep implicitWidth constant
  // so the layout engine never shifts the clock or center section!
  width: root.hovered ? root.expandedRowWidth : implicitWidth

  // Translate transform shifts both the visual rendering AND the mouse coordinates
  // to the left, aligning the right edge of the expanded widget perfectly with the clock!
  transform: Translate {
    x: -(root.width - root.implicitWidth)
  }

  // --- 1. Reactive State Properties ---
  property bool stayAwakeActive: false
  property bool sunsetActive: false
  property bool dndActive: Notifications.dnd
  property bool screenRecordingActive: false

  readonly property real collapsedRowWidth: {
    var w = 0
    var count = 0
    if (stayAwakeActive) { w += stayAwakeText.implicitWidth + 8; count++; }
    if (sunsetActive) { w += sunsetText.implicitWidth + 8; count++; }
    if (dndActive) { w += dndText.implicitWidth + 8; count++; }
    if (screenRecordingActive) { w += screenRecordingText.implicitWidth + 8; count++; }

    if (count === 0) return 0
    return w + (count - 1) * 12
  }

  readonly property real expandedRowWidth: {
    var w = 0
    w += stayAwakeText.implicitWidth + 8
    w += sunsetText.implicitWidth + 8
    w += dndText.implicitWidth + 8
    w += screenRecordingText.implicitWidth + 8
    return w + 3 * 12
  }

  // Sync DND state with central Notifications singleton
  onDndActiveChanged: {
    if (dndActive !== Notifications.dnd) {
      Notifications.dnd = dndActive
    }
  }

  Connections {
    target: Notifications
    function onDndChanged() {
      root.dndActive = Notifications.dnd
    }
  }

  // --- 2. Stay Awake File Monitoring ---
  readonly property string stayAwakePath: (Quickshell.env("HOME") ?? "") + "/.local/state/qs/indicators/stay-awake"

  FileView {
    id: stayAwakeFile
    path: root.stayAwakePath
    watchChanges: true
    printErrors: false

    onLoaded: updateStayAwakeState()
    onLoadFailed: root.stayAwakeActive = false
    onFileChanged: reload()
  }

  function updateStayAwakeState() {
    if (!stayAwakeFile.loaded) {
      root.stayAwakeActive = false
      return
    }
    var content = String(stayAwakeFile.text()).trim().toLowerCase()
    root.stayAwakeActive = (content === "true" || content === "on" || content === "1" || content === "")
  }

  // --- 3. Screen Recording File Monitoring ---
  readonly property string screenRecordingPath: (Quickshell.env("XDG_RUNTIME_DIR") ?? "/run/user/1000") + "/screenrecording"

  FileView {
    id: screenRecordingFile
    path: root.screenRecordingPath
    watchChanges: true
    printErrors: false

    onLoaded: updateScreenRecordingState()
    onLoadFailed: root.screenRecordingActive = false
    onFileChanged: reload()
  }

  function updateScreenRecordingState() {
    if (!screenRecordingFile.loaded) {
      root.screenRecordingActive = false
      return
    }
    var content = String(screenRecordingFile.text()).trim()
    root.screenRecordingActive = (content !== "")
  }

  // --- 4. Event-Driven Processes ---
  // Sunset Status Query (Runs only during initialization, post-toggle, or IPC calls)
  Process {
    id: sunsetStatusQuery
    command: ["toggle-sunset", "--status"]
    onExited: function(exitCode) {
      root.sunsetActive = (exitCode === 0)
    }
  }

  // Sunset Toggling Process
  Process {
    id: sunsetToggle
    command: []
    onExited: {
      // Re-trigger the query status check immediately after toggle completes
      sunsetStatusQuery.running = true
    }
  }

  // Stay Awake File Toggling Process
  Process {
    id: stayAwakeToggle
    command: ["bash", "-c", "mkdir -p $(dirname " + root.stayAwakePath + ") && if [ -f " + root.stayAwakePath + " ] && grep -q -E 'true|on|1|^$' " + root.stayAwakePath + "; then echo 'false' > " + root.stayAwakePath + "; else echo 'true' > " + root.stayAwakePath + "; fi"]
  }

  // Screen Recording Toggle Process
  Process {
    id: screenRecordingToggle
    command: ["cmd-screenrecord"]
  }

  // Initialize status on completion
  Component.onCompleted: {
    sunsetStatusQuery.running = true
    updateStayAwakeState()
    updateScreenRecordingState()
  }

  // --- 5. IPC Handler for On-Demand Refreshes ---
  IpcHandler {
    target: "indicators-refresh"
    function refresh(): void {
      sunsetStatusQuery.running = true
      stayAwakeFile.reload()
      screenRecordingFile.reload()
    }
  }

  // --- 6. Horizontal layout of active status indicators ---
  Text {
    id: handleText
    text: "󰇙"
    color: Color.accent
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSizeSmall
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    opacity: root.hovered ? 0.0 : 0.6
    visible: true
    Behavior on opacity { NumberAnimation { duration: 120 } }
  }

  Row {
    id: indicatorsRow
    height: parent.height
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: 12
    opacity: 1.0
    visible: true
    clip: false
    width: root.hovered ? root.expandedRowWidth : root.collapsedRowWidth
    Behavior on width {
      NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }

    // Stay Awake Indicator Button
    Item {
      id: stayAwakeIndicator
      visible: root.hovered || root.stayAwakeActive
      opacity: root.stayAwakeActive ? 1.0 : 0.55
      width: stayAwakeText.implicitWidth + 8
      height: parent.height

      Text {
        id: stayAwakeText
        anchors.centerIn: parent
        text: "󰛊"
        color: Color.accent
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      MouseArea {
        id: stayAwakeMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
          stayAwakeToggle.running = true
        }
      }

      StyledTooltip {
        target: stayAwakeIndicator
        hovered: stayAwakeMouse.containsMouse
        tooltipText: root.stayAwakeActive ? "Stay Awake: Active" : "Stay Awake: Inactive"
      }
    }

    // Sunset Indicator Button
    Item {
      id: sunsetIndicator
      visible: root.hovered || root.sunsetActive
      opacity: root.sunsetActive ? 1.0 : 0.55
      width: sunsetText.implicitWidth + 8
      height: parent.height

      Text {
        id: sunsetText
        anchors.centerIn: parent
        text: "󰛨"
        color: Color.urgent
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      MouseArea {
        id: sunsetMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
          sunsetToggle.command = root.sunsetActive ? ["toggle-sunset", "--off"] : ["toggle-sunset", "--on"]
          sunsetToggle.running = true
        }
      }

      StyledTooltip {
        target: sunsetIndicator
        hovered: sunsetMouse.containsMouse
        tooltipText: root.sunsetActive ? "Night Light: Active" : "Night Light: Inactive"
      }
    }

    // Do-Not-Disturb (DND) Indicator Button
    Item {
      id: dndIndicator
      visible: root.hovered || root.dndActive
      opacity: root.dndActive ? 1.0 : 0.55
      width: dndText.implicitWidth + 8
      height: parent.height

      Text {
        id: dndText
        anchors.centerIn: parent
        text: "󰂛"
        color: Color.muted
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall
      }

      MouseArea {
        id: dndMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
          Notifications.toggleDnd()
        }
      }

      StyledTooltip {
        target: dndIndicator
        hovered: dndMouse.containsMouse
        tooltipText: root.dndActive ? "Do Not Disturb: Active" : "Do Not Disturb: Inactive"
      }
    }

    // Screen Recording Indicator Button
    Item {
      id: screenRecordingIndicator
      visible: root.hovered || root.screenRecordingActive
      opacity: root.screenRecordingActive ? 1.0 : 0.55
      width: screenRecordingText.implicitWidth + 8
      height: parent.height

      Text {
        id: screenRecordingText
        anchors.centerIn: parent
        text: "󰻃"
        color: Color.urgent
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSmall

        // Highly visible pulsing alert effect when capturing video
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: root.screenRecordingActive
          NumberAnimation { to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
          NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
        }
      }

      MouseArea {
        id: screenRecordingMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
          screenRecordingToggle.running = true
        }
      }

      StyledTooltip {
        target: screenRecordingIndicator
        hovered: screenRecordingMouse.containsMouse
        tooltipText: root.screenRecordingActive ? "Screen Recording: Active" : "Screen Recording: Inactive"
      }
    }
  }
}
