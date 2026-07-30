import Quickshell
import Quickshell.Io
import QtQuick

Item {
  implicitHeight: 26
  width: weatherText.implicitWidth + 15

  Text {
    id: weatherText
    anchors.centerIn: parent
    color: "#C5C9C7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    text: _icon
  }

  property string _icon: ""

  Timer {
    id: weatherTimer
    interval: 60000
    running: true
    repeat: true
    onTriggered: fetchWeather.running = true
  }

  Process {
    id: fetchWeather
    command: ["bash", "-c", "$HOME/.config/waybar/weather.sh"]
    stdout: StdioCollector { id: weatherCollector }
    onExited: {
      var data = weatherCollector.text.trim()
      try {
        var obj = JSON.parse(data)
        if (obj.class === "unavailable") {
          _icon = ""
        } else {
          _icon = obj.text
        }
      } catch (e) {
        _icon = ""
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      weathrProc.command = ["ghostty", "--class=org.omarchy.Weathr", "-e", "weathr"]
      weathrProc.running = true
    }
  }

  Process { id: weathrProc }

  Component.onCompleted: fetchWeather.running = true
}
