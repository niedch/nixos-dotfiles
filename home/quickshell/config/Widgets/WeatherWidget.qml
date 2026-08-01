import Quickshell
import Quickshell.Io
import QtQuick
import qs

Widget {
  widthPadding: 15

  property string weatherIcon: ""

  text: weatherIcon

  Timer {
    id: weatherTimer
    interval: Constants.pollWeather
    running: true
    repeat: true
    onTriggered: fetchWeather.running = true
  }

  Process {
    id: fetchWeather
    command: ["bash", "-c", (Quickshell.env("QS_CONFIG_PATH") ?? "") + "/scripts/weather.sh"]
    stdout: StdioCollector { id: weatherCollector }
    onExited: {
      var data = weatherCollector.text.trim()
      try {
        var obj = JSON.parse(data)
        if (obj.class === "unavailable") {
          weatherIcon = ""
        } else {
          weatherIcon = obj.text
        }
      } catch (e) {
        weatherIcon = ""
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      weatherProc.command = ["ghostty", "--class=org.omarchy.Weathr", "-e", "weathr"]
      weatherProc.running = true
    }
  }

  Process { id: weatherProc }

  Component.onCompleted: fetchWeather.running = true
}
