pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: constants

  readonly property string fontFamily: "JetBrainsMono Nerd Font"
  readonly property int barHeight: 26
  readonly property int fontSize: 12
  readonly property int fontSizeSmall: 10
  readonly property int fontSizeLarge: 14
  readonly property int defaultPadding: 16

  readonly property int pollFast: 1000
  readonly property int pollNormal: 5000
  readonly property int pollSlow: 30000
  readonly property int pollWeather: 60000
  readonly property int pollUpdates: 21600000

  readonly property string separatorText: "|"
}
