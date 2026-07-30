import Quickshell
import QtQuick

Scope {
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
