import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Ui
import qs.Commons

KeyboardPanel {
  id: popup

  // --- Interface Properties ---
  required property var notesModel
  required property var resultModel
  property int selectedNoteIndex: 0
  property alias text: editor.text
  property bool numrAvailable: true
  property string statusText: ""

  // --- Interface Signals ---
  signal newNoteClicked()
  signal newNoteRequested()
  signal switchNoteRequested(int index)
  signal resultClicked(int index)
  signal copyAllClicked()
  signal clearAllClicked()
  signal deleteNoteClicked()
  signal evaluateNowRequested()

  // --- Interface Functions ---
  function forceEditorFocus() {
    editor.forceActiveFocus()
  }

  focusTarget: editor
  contentWidth: popup.fittedContentWidth(Style.space(660))
  contentHeight: popup.fittedContentHeight(Style.space(420))

  // Catches keys that bubble up from the editor. QQC2 TextArea consumes
  // plain Enter (new paragraph) but not Escape or Ctrl+Return, so both
  // reach us here.
  Item {
    anchors.fill: parent
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) {
        popup.close()
        event.accepted = true
        return
      }
      if (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier)) {
        popup.newNoteRequested()
        event.accepted = true
        return
      }
      if (event.key === Qt.Key_Return && (event.modifiers & Qt.ControlModifier)) {
        popup.evaluateNowRequested()
        event.accepted = true
        return
      }
      if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ControlModifier)) {
        if (editor.activeFocus) sidebar.focusList()
        else editor.forceActiveFocus()
        event.accepted = true
        return
      }
    }

    ColumnLayout {
      anchors.fill: parent
      spacing: Style.spacing.md

      // Header: title left, live hint right.
      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "Numi"
          font.family: popup.bar.fontFamily
          font.pixelSize: Style.font.heading
          color: popup.bar.foreground
        }

        Item {
          Layout.fillWidth: true
        }

        Text {
          text: "live · Esc to close"
          font.family: popup.bar.fontFamily
          font.pixelSize: Style.font.caption
          color: Qt.darker(popup.bar.foreground, 1.4)
        }
      }

      // Body: notes column | divider | editor + results + footer.
      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Style.space(10)

        NumiSidebar {
          id: sidebar
          bar: popup.bar
          notesModel: popup.notesModel
          selectedNoteIndex: popup.selectedNoteIndex
          onNewNoteClicked: popup.newNoteClicked()
          onSwitchNoteRequested: function(index) { popup.switchNoteRequested(index) }
        }

        // ---- divider ----
        Rectangle {
          Layout.fillHeight: true
          width: Style.normalBorderWidth
          color: Util.alpha(popup.bar.foreground, 0.12)
        }

        // ---- right column: editor + results + footer ----
        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: Style.spacing.md

          // Scratch-pad editor inside a ScrollView (QQC2 TextArea is not a
          // Flickable, so it needs a ScrollView wrapper to scroll).
          ScrollView {
            id: editorScroll
            Layout.fillWidth: true
            Layout.preferredHeight: Style.space(120)
            clip: true
            background: BorderSurface {
              color: Style.controlFill(editor.activeFocus, editorHover.hovered, popup.bar.foreground, Color.accent)
              borderSpec: Border.controlSpec(editor.activeFocus ? "focus" : (editorHover.hovered ? "hover-cursor" : "normal"), popup.bar.foreground, Color.accent)
              radius: Style.cornerRadius
            }
            ScrollBar.vertical: NumiScrollBar {
              foregroundColor: popup.bar.foreground
            }

            TextArea {
              id: editor
              width: parent.width   // fill the ScrollView viewport
              wrapMode: TextEdit.Wrap
              selectByMouse: true
              font.family: popup.bar.fontFamily
              font.pixelSize: Style.font.body
              color: popup.bar.foreground
              placeholderTextColor: Qt.darker(popup.bar.foreground, 1.6)
              palette.text: popup.bar.foreground
              palette.placeholderText: Qt.darker(popup.bar.foreground, 1.6)
              palette.highlight: Style.selectionFillFor(popup.bar.foreground, Color.accent)
              palette.highlightedText: popup.bar.foreground
              leftPadding: Style.spacing.controlPaddingX
              rightPadding: Style.spacing.controlPaddingX + 14   // leave room for the scrollbar
              topPadding: Style.spacing.inputPaddingY
              bottomPadding: Style.spacing.inputPaddingY
              placeholderText: "20 inches in cm\nx = 5000\n5 * (1 + 2)"
              background: null  // themed background is on the ScrollView

              HoverHandler {
                id: editorHover
              }
            }
          }

          NumiResultList {
            id: resultsList
            bar: popup.bar
            numrAvailable: popup.numrAvailable
            statusText: popup.statusText
            resultModel: popup.resultModel
            onResultClicked: function(index) { popup.resultClicked(index) }
          }

          // Footer actions.
          RowLayout {
            Layout.fillWidth: true

            Button {
              text: "Copy all"
              enabled: popup.resultModel.count > 0
              foreground: popup.bar.foreground
              fontFamily: popup.bar.fontFamily
              fontSize: Style.font.bodySmall
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: popup.copyAllClicked()
            }

            Item {
              Layout.fillWidth: true
            }

            Button {
              text: "Clear"
              foreground: popup.bar.foreground
              fontFamily: popup.bar.fontFamily
              fontSize: Style.font.bodySmall
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: popup.clearAllClicked()
            }

            Button {
              text: "Delete"
              tooltipText: "Delete this note"
              enabled: popup.notesModel.count > 0
              foreground: popup.bar.foreground
              fontFamily: popup.bar.fontFamily
              fontSize: Style.font.bodySmall
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: popup.deleteNoteClicked()
            }
          }
        }
      }
    }
  }
}
