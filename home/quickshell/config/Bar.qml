import Quickshell
import Quickshell.Io
import QtQuick

import qs.center
import qs.left
import qs.right

PanelWindow {
  id: bar

  property var modelData: null
  screen: modelData !== null ? modelData : Quickshell.primaryScreen

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: Constants.barHeight
  color: Colors.background

  Row {
    id: leftSection
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    OmarchyMenuWidget {}
    Workspaces {}
    SeparatorWidget {}
    MprisWidget {}
    CavaWidget {}
  }

  Row {
    id: centerSection
    anchors.centerIn: parent
    spacing: 0

    Clock {}
    WeatherWidget {}
    UpdateWidget {}
    VoxtypeWidget {}
    ScreenRecordingWidget {}
    IdleWidget {}
    NotificationSilencingWidget {}
  }

  Row {
    id: rightSection
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    TrayExpanderWidget {}
    BluetoothWidget {}
    NetworkWidget {}
    AudioWidget {}
    CpuWidget {}
    BatteryWidget {}
  }
}
