import Quickshell
import QtQuick
import qs

PanelWindow {
  id: root

  required property Item target

  visible: Notifications.toasts.length > 0
  color: "transparent"

  anchors {
    top: true
    right: true
  }

  margins {
    top: Constants.barHeight + 8
    right: 16
  }

  exclusionMode: ExclusionMode.Ignore
  focusable: false

  implicitWidth: 360

  property int gap: 6
  implicitHeight: toastColumn.childrenRect.height

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 200
      easing.type: Easing.OutCubic
    }
  }

  Column {
    id: toastColumn
    anchors.fill: parent
    spacing: root.gap

    Repeater {
      model: Notifications.toasts

      delegate: NotificationToast {
        toastWidth: 360
      }
    }
  }
}
