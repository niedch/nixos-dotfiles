import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.Components.Weather

Item {
  id: widget
  property int widthPadding: 15

  property string weatherIcon: ""
  property color weatherColor: Colors.foreground
  property string tempC: ""
  property string feelsLikeC: ""
  property string description: ""
  property string humidity: ""
  property string windSpeed: ""
  property string weatherCode: ""
  property bool isNight: false
  property var forecast: []

  implicitHeight: Constants.barHeight
  width: weatherIcon !== "" ? iconText.implicitWidth + widthPadding : 0

  Text {
    id: iconText
    anchors.centerIn: parent
    text: widget.weatherIcon
    color: widget.weatherColor
    font.family: Constants.fontFamily
    font.pixelSize: Constants.fontSize
    scale: 1.0

    Behavior on color {
      ColorAnimation { duration: 800 }
    }
  }

  SequentialAnimation {
    id: pulseAnim
    running: widget.weatherIcon !== ""
    loops: Animation.Infinite
    NumberAnimation {
      target: iconText
      property: "scale"
      from: 1.0
      to: 1.12
      duration: 1000
      easing.type: Easing.InOutSine
    }
    NumberAnimation {
      target: iconText
      property: "scale"
      from: 1.12
      to: 1.0
      duration: 1000
      easing.type: Easing.InOutSine
    }
  }

  Timer {
    id: weatherTimer
    interval: Constants.pollWeather
    running: true
    repeat: true
    onTriggered: fetchWeather.running = true
  }

  Process {
    id: fetchWeather
    command: ["curl", "-fsS", "--max-time", "3", "https://wttr.in?format=j1"]
    stdout: StdioCollector { id: weatherCollector }
    onExited: {
      var data = weatherCollector.text.trim()
      try {
        var obj = JSON.parse(data)
        widget.parseWeather(obj)
      } catch (e) {
        weatherIcon = ""
        forecast = []
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: weatherPopup.toggle()
  }

  WeatherPopup {
    id: weatherPopup
    target: widget
  }

  Component.onCompleted: fetchWeather.running = true

  // ---- helpers ----

  function parseWeather(obj) {
    if (!obj || !obj.current_condition || !obj.current_condition[0]) {
      weatherIcon = ""
      forecast = []
      return
    }
    var cc = obj.current_condition[0]
    weatherCode = String(cc.weatherCode || "")
    tempC = String(cc.temp_C || "")
    feelsLikeC = String(cc.FeelsLikeC || "")
    description = cc.weatherDesc && cc.weatherDesc[0] ? cc.weatherDesc[0].value : ""
    humidity = String(cc.humidity || "")
    windSpeed = String(cc.windspeedKmph || "")
    isNight = WeatherCodes.nightTime(obj)

    weatherIcon = WeatherCodes.mapIcon(weatherCode, isNight)

    var days = []
    var weather = obj.weather || []
    for (var i = 0; i < weather.length; i++) {
      var w = weather[i]
      days.push({
        date: String(w.date || ""),
        maxC: String(w.maxtempC || ""),
        minC: String(w.mintempC || ""),
        icon: WeatherCodes.mapIcon(String(w.weatherCode || ""), false),
        desc: w.weatherDesc && w.weatherDesc[0] ? w.weatherDesc[0].value : ""
      })
    }
    forecast = days
  }
}
