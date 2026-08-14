import Quickshell
import Quickshell.Io
import QtQuick

import qs.services
import qs.Commons

PanelWindow {
  id: bar

  property var modelData: null
  screen: modelData !== null ? modelData : Quickshell.primaryScreen

  anchors {
    top: true
    left: true
    right: true
  }

  property color themeBackground: Colors.background

  implicitHeight: Constants.barHeight
  color: Qt.rgba(themeBackground.r, themeBackground.g, themeBackground.b, 0.5)

  // --- shell.json layout config ---
  FileView {
    id: shellConfigFile
    path: Quickshell.shellPath("shell.json")
    watchChanges: true
    blockLoading: true
    onFileChanged: reload()
  }

  // Parse shell.json content directly
  readonly property var shellConfig: {
    try {
      var content = shellConfigFile.text()
      if (!content) return ({})
      return JSON.parse(content)
    } catch (e) {
      console.warn("[Bar] Failed to parse shell.json:", e)
      return ({})
    }
  }

  // Parse the layout from shell.json
  readonly property var layout: {
    var raw = shellConfig.bar ? shellConfig.bar.layout || {} : {}
    var result = Util.normalizeLayout(raw)
    return result
  }

  // --- barFacade (host interface for widgets) ---
  QtObject {
    id: barFacade

    readonly property string position: "top"
    readonly property bool vertical: false
    readonly property int barSize: Constants.barHeight
    readonly property color foreground: Colors.foreground
    readonly property color barForeground: Colors.foreground
    readonly property string fontFamily: Constants.fontFamily
    readonly property color urgent: Colors.color1
    readonly property bool foregroundAnimationEnabled: true
    readonly property var clickTargets: []
    property var activePopout: null

    // Registry of loaded widget instances by moduleName (for broadcast())
    property var _widgetInstances: ({})

    function moduleWidgets(moduleName) {
      return _widgetInstances[moduleName] || []
    }

    function _registerWidgetInstance(moduleName, instance) {
      var arr = _widgetInstances[moduleName] || []
      arr.push(instance)
      _widgetInstances[moduleName] = arr
    }

    function _unregisterWidgetInstance(moduleName, instance) {
      var arr = _widgetInstances[moduleName] || []
      var idx = arr.indexOf(instance)
      if (idx >= 0) {
        arr.splice(idx, 1)
        _widgetInstances[moduleName] = arr
      }
    }

    function requestPopout(key) {
      if (activePopout && activePopout !== key && typeof activePopout.closeForPopoutSwitch === "function")
        activePopout.closeForPopoutSwitch()
      activePopout = key
    }

    function releasePopout(key) {
      if (activePopout === key) activePopout = null
    }

    function switchPanelFrom(item, direction) { return false }
    function targetBelongsToWindow(target, win) { return false }
    function showTooltip() {}
    function hideTooltip() {}
    function registerClickTarget() {}
    function unregisterClickTarget() {}
    function setIndicatorItemHovered() {}
  }

  // --- Left section (dynamic, from shell.json layout.left) ---
  Row {
    id: leftSection
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    Repeater {
      model: layout.left

      Item {
        id: leftSlotItem
        property string widgetId: modelData.id
        property var widgetSettings: modelData

        readonly property var pluginComponent: {
          var rev = BarWidgetRegistry.revision
          var entry = BarWidgetRegistry.widgets[widgetId]
          return entry ? entry.component : null
        }

        implicitWidth: loader.item ? loader.item.implicitWidth : 0
        implicitHeight: loader.item ? loader.item.implicitHeight : Constants.barHeight

        Loader {
          id: loader
          active: leftSlotItem.pluginComponent !== null
          sourceComponent: leftSlotItem.pluginComponent

          onItemChanged: {
            if (item) {
              if ("bar" in item) item.bar = barFacade
              if ("moduleName" in item) item.moduleName = leftSlotItem.widgetId
              if ("settings" in item) item.settings = leftSlotItem.widgetSettings
              if (leftSlotItem.widgetId && item) {
                barFacade._registerWidgetInstance(leftSlotItem.widgetId, item)
              }
            }
          }
        }

        Component.onDestruction: {
          if (loader.item && leftSlotItem.widgetId) {
            barFacade._unregisterWidgetInstance(leftSlotItem.widgetId, loader.item)
          }
        }
      }
    }
  }

  // --- Center section (dynamic, from shell.json layout.center) ---
  Row {
    id: centerSection
    anchors.centerIn: parent
    spacing: 0

    Repeater {
      model: layout.center

      Item {
        id: centerSlotItem
        property string widgetId: modelData.id
        property var widgetSettings: modelData

        readonly property var pluginComponent: {
          var rev = BarWidgetRegistry.revision
          var entry = BarWidgetRegistry.widgets[widgetId]
          return entry ? entry.component : null
        }

        implicitWidth: loader.item ? loader.item.implicitWidth : 0
        implicitHeight: loader.item ? loader.item.implicitHeight : Constants.barHeight

        Loader {
          id: loader
          active: centerSlotItem.pluginComponent !== null
          sourceComponent: centerSlotItem.pluginComponent

          onItemChanged: {
            if (item) {
              if ("bar" in item) item.bar = barFacade
              if ("moduleName" in item) item.moduleName = centerSlotItem.widgetId
              if ("settings" in item) item.settings = centerSlotItem.widgetSettings
              if (centerSlotItem.widgetId && item) {
                barFacade._registerWidgetInstance(centerSlotItem.widgetId, item)
              }
            }
          }
        }

        Component.onDestruction: {
          if (loader.item && centerSlotItem.widgetId) {
            barFacade._unregisterWidgetInstance(centerSlotItem.widgetId, loader.item)
          }
        }
      }
    }
  }

  // --- Right section (dynamic, from shell.json layout.right) ---
  Row {
    id: rightSection
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    Repeater {
      model: layout.right

      Item {
        id: slotItem
        property string widgetId: modelData.id
        property var widgetSettings: modelData

        readonly property var pluginComponent: {
          var rev = BarWidgetRegistry.revision
          var entry = BarWidgetRegistry.widgets[widgetId]
          return entry ? entry.component : null
        }

        implicitWidth: loader.item ? loader.item.implicitWidth : 0
        implicitHeight: loader.item ? loader.item.implicitHeight : Constants.barHeight

        Loader {
          id: loader
          active: slotItem.pluginComponent !== null
          sourceComponent: slotItem.pluginComponent

          onItemChanged: {
            if (item) {
              if ("bar" in item) item.bar = barFacade
              if ("moduleName" in item) item.moduleName = slotItem.widgetId
              if ("settings" in item) item.settings = slotItem.widgetSettings
              if (slotItem.widgetId && item) {
                barFacade._registerWidgetInstance(slotItem.widgetId, item)
              }
            }
          }
        }

        Component.onDestruction: {
          if (loader.item && slotItem.widgetId) {
            barFacade._unregisterWidgetInstance(slotItem.widgetId, loader.item)
          }
        }
      }
    }
  }
}
