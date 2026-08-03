import Quickshell
import QtQuick

import qs.Components.MenuPanel
import qs.Launcher

Scope {
  AppLauncher {}
  MenuPanel {}

  Variants {
    model: Quickshell.screens

    delegate: Component {
      Bar {
        property var modelData
        screen: modelData
      }
    }
  }
}
