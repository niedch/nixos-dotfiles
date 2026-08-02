import Quickshell
import QtQuick

import qs.Launcher

Scope {
  AppLauncher {}

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
