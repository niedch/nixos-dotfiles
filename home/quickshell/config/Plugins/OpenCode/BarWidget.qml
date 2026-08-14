import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "quickshell.opencode"

  property string statusState: "none"
  property string workingCount: ""
  property string tooltipContent: ""
  property bool idleDebounceActive: false

  readonly property var icons: ({
    "working": "󰒋",
    "idle": "󰄬",
    "permission": "󰀪",
    "error": "󰅙"
  })

  readonly property var stateColors: ({
    "working": Color.color4,
    "idle": Color.color2,
    "permission": Color.color3,
    "error": Color.urgent
  })

  // Text rendering
  property int widthPadding: 10
  property int pixelSize: Constants.fontSizeSmall
  property string text: statusState !== "none" ? (icons[statusState] || "") + (workingCount !== "" ? " " + workingCount : "") : ""
  property color textColor: stateColors[statusState] || Color.foreground
  property bool textVisible: statusState !== "none"

  implicitHeight: Constants.barHeight
  implicitWidth: textVisible ? contentText.implicitWidth + widthPadding : 0

  Text {
    id: contentText
    anchors.centerIn: parent
    color: root.textColor
    font.family: Constants.fontFamily
    font.pixelSize: root.pixelSize
    text: root.text
    visible: root.textVisible
  }

  Timer {
    id: pollTimer
    interval: Constants.pollNormal
    running: true
    repeat: true
    onTriggered: statusCheck.running = true
  }

  Timer {
    id: idleDebounce
    interval: 1500
    repeat: false
    onTriggered: {
      statusCheck.running = true
    }
  }

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
          root.idleDebounceActive = false
          root.statusState = newState
          root.workingCount = newCount
          root.tooltipContent = newTooltip
        } else if (newState === "idle") {
          if (root.statusState === "idle") {
            root.workingCount = newCount
            root.tooltipContent = newTooltip
          } else {
            root.idleDebounceActive = true
            idleDebounce.restart()
          }
        } else {
          idleDebounce.stop()
          root.idleDebounceActive = false
          root.statusState = newState
          root.workingCount = newCount
          root.tooltipContent = newTooltip
        }
      } catch (e) {
        idleDebounce.stop()
        root.idleDebounceActive = false
        root.statusState = "none"
        root.workingCount = ""
        root.tooltipContent = ""
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.tooltipContent !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
  }

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
