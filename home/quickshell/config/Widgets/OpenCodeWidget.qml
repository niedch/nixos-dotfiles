import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  id: root

  // State properties
  property string statusState: "none" // none, working, idle, permission, error
  property string workingCount: ""
  property string tooltipContent: ""

  // Idle debounce: delays showing "idle" to avoid flicker between tool executions.
  // When true, the next process exit should apply its result directly (no re-debounce).
  property bool idleDebounceActive: false

  // Icons per state (Nerd Font glyphs, same as old waybar plugin)
  readonly property var icons: ({
    "working": "󰒋",
    "idle": "󰄬",
    "permission": "󰀪",
    "error": "󰅙"
  })

  // Colors per state using Colors singleton
  readonly property var stateColors: ({
    "working": Colors.color4, // blue-ish
    "idle": Colors.color2, // green-ish
    "permission": Colors.color3, // yellow-ish
    "error": Colors.color1 // red-ish
  })

  // Widget appearance
  widthPadding: 10
  pixelSize: Constants.fontSizeSmall

  // Dynamic text: icon + optional count. Empty when state is "none" (widget auto-hides via Widget base)
  text: statusState !== "none" ? (icons[statusState] || "") + (workingCount !== "" ? " " + workingCount : "") : ""
  textColor: stateColors[statusState] || Colors.foreground

  // Poll timer: check every 2 seconds
  Timer {
    id: pollTimer
    interval: Constants.pollNormal
    running: true
    repeat: true
    onTriggered: statusCheck.running = true
  }

  // Debounce timer: when it fires, re-check the status instead of applying stale state
  Timer {
    id: idleDebounce
    interval: 1500
    repeat: false
    onTriggered: {
      // Re-run the check process to get fresh state from the file.
      // idleDebounceActive stays true; onExited will apply the fresh result directly.
      statusCheck.running = true
    }
  }

  // Process that runs the aggregation script
  Process {
    id: statusCheck
    command: ["bash", (Quickshell.env("QS_CONFIG_PATH") ?? "") + "/scripts/opencode-status.sh"]
    stdout: StdioCollector {
      id: output
    }
    onExited: {
      try {
        var result = JSON.parse(output.text.trim())
        var newState = result.state || "none"
        var newCount = result.count || ""
        var newTooltip = result.tooltip || ""

        if (root.idleDebounceActive) {
          // This poll was triggered by the debounce timer firing.
          // Apply the fresh result directly — no more debouncing.
          root.idleDebounceActive = false
          root.statusState = newState
          root.workingCount = newCount
          root.tooltipContent = newTooltip
        } else if (newState === "idle") {
          // Normal idle detection from the 2s poll timer.
          if (root.statusState === "idle") {
            // Already showing idle: refresh tooltip/count immediately.
            root.workingCount = newCount
            root.tooltipContent = newTooltip
          } else {
            // Transitioning to idle from non-idle: debounce it.
            root.idleDebounceActive = true
            idleDebounce.restart()
          }
        } else {
          // Non-idle or none: apply immediately, cancel any pending debounce.
          idleDebounce.stop()
          root.idleDebounceActive = false
          root.statusState = newState
          root.workingCount = newCount
          root.tooltipContent = newTooltip
        }
      } catch (e) {
        // Parse error: hide immediately, cancel any pending debounce.
        idleDebounce.stop()
        root.idleDebounceActive = false
        root.statusState = "none"
        root.workingCount = ""
        root.tooltipContent = ""
      }
    }
  }

  // MouseArea for hover tooltip
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.tooltipContent !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
  }

  // Tooltip showing per-project details
  StyledTooltip {
    target: root
    hovered: mouseArea.containsMouse
    tooltipText: root.tooltipContent
  }

  IpcHandler {
    target: "opencode-refresh"
    function refresh(): void {
      idleDebounce.stop()
      root.idleDebounceActive = false
      statusCheck.running = true
    }
  }

  Component.onCompleted: statusCheck.running = true
}
