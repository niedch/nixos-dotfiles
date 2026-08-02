import QtQuick
import qs

Item {
  id: scene
  width: 110
  height: 75
  clip: true

  property string weatherCode: ""
  property bool isNight: false
  property bool debugCycle: false

  property var debugCodes: [
    { code: "113", night: false },
    { code: "113", night: true },
    { code: "116", night: false },
    { code: "119", night: false },
    { code: "143", night: false },
    { code: "176", night: false },
    { code: "179", night: false },
    { code: "200", night: false },
    { code: "266", night: false },
    { code: "329", night: false }
  ]
  property int debugIndex: 0
  readonly property string effectiveCode: debugCycle ? String(debugCodes[debugIndex].code) : weatherCode
  readonly property bool effectiveNight: debugCycle ? debugCodes[debugIndex].night : isNight

  // ---- debug cycle ----

  Timer {
    id: debugTimer
    interval: 2000
    running: scene.debugCycle
    repeat: true
    onTriggered: scene.debugIndex = (scene.debugIndex + 1) % scene.debugCodes.length
  }

  // ---- scenes ----

  SunScene {
    active: WeatherCodes.isSun(scene.effectiveCode) && !scene.effectiveNight
  }

  MoonScene {
    active: WeatherCodes.isSun(scene.effectiveCode) && scene.effectiveNight
  }

  CloudScene {
    active: WeatherCodes.isCloudy(scene.effectiveCode) || WeatherCodes.isFog(scene.effectiveCode) || WeatherCodes.isThunder(scene.effectiveCode)
  }

  RainScene {
    active: WeatherCodes.isRain(scene.effectiveCode)
  }

  SnowScene {
    active: WeatherCodes.isSnow(scene.effectiveCode)
  }

  ThunderScene {
    active: WeatherCodes.isThunder(scene.effectiveCode)
  }

  FogScene {
    active: WeatherCodes.isFog(scene.effectiveCode)
  }

  // ---- debug label ----

  Text {
    visible: scene.debugCycle
    text: "debug: " + scene.effectiveCode + (scene.effectiveNight ? " n" : "")
    color: Colors.color1
    font.family: Constants.fontFamily
    font.pixelSize: 8
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: 2
    z: 10
  }
}
