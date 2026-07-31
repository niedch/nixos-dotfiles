pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: colors

  readonly property string background: themeJson.background
  readonly property string foreground: themeJson.foreground
  readonly property string cursor: themeJson.cursor
  readonly property string accent: themeJson.accent
  readonly property string selectionBackground: themeJson.selectionBackground
  readonly property string selectionForeground: themeJson.selectionForeground
  readonly property string color0: themeJson.color0
  readonly property string color1: themeJson.color1
  readonly property string color2: themeJson.color2
  readonly property string color3: themeJson.color3
  readonly property string color4: themeJson.color4
  readonly property string color5: themeJson.color5
  readonly property string color6: themeJson.color6
  readonly property string color7: themeJson.color7
  readonly property string color8: themeJson.color8
  readonly property string color9: themeJson.color9
  readonly property string color10: themeJson.color10
  readonly property string color11: themeJson.color11
  readonly property string color12: themeJson.color12
  readonly property string color13: themeJson.color13
  readonly property string color14: themeJson.color14
  readonly property string color15: themeJson.color15

  FileView {
    id: colorsFile
    path: (Quickshell.env("HOME") ?? "") + "/.config/quickshell/colors.json"
    watchChanges: true
    onFileChanged: reload()

    JsonAdapter {
      id: themeJson
      property string background: "#090E13"
      property string foreground: "#C5C9C7"
      property string cursor: "#C5C9C7"
      property string accent: "#C5C9C7"
      property string selectionBackground: "#C5C9C7"
      property string selectionForeground: "#C5C9C7"
      property string color0: "#676C6D"
      property string color1: "#a55555"
      property string color2: "#C5C9C7"
      property string color3: "#C5C9C7"
      property string color4: "#C5C9C7"
      property string color5: "#C5C9C7"
      property string color6: "#C5C9C7"
      property string color7: "#C5C9C7"
      property string color8: "#9FA4A3"
      property string color9: "#C5C9C7"
      property string color10: "#C5C9C7"
      property string color11: "#C5C9C7"
      property string color12: "#C5C9C7"
      property string color13: "#C5C9C7"
      property string color14: "#C5C9C7"
      property string color15: "#C5C9C7"
    }
  }

  IpcHandler {
    target: "theme-reload"
    function reload(): void {
      colorsFile.reload()
    }
  }
}
