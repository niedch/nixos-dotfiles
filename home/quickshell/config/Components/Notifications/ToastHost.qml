import Quickshell
import QtQuick
import qs
import qs.Components.Notifications

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

  property int toastHeight: 56
  property int gap: 6
  implicitHeight: Notifications.toasts.length * (root.toastHeight + root.gap) - (Notifications.toasts.length > 0 ? root.gap : 0)

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 200
      easing.type: Easing.OutCubic
    }
  }

  Column {
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
