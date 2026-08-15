import Quickshell
import Quickshell.Io
import QtQuick

import qs.Plugins.Menu
import qs.Launcher
import qs.services

Scope {
  id: root

  AppLauncher {}
  MenuPanel {}

  // When PluginRegistry discovers plugins, sync bar-widget components
  // into BarWidgetRegistry so Bar.qml can load them dynamically.
  Connections {
    target: PluginRegistry

    function onPluginsChanged() {
      syncPluginWidgets()
    }
  }

  // IPC target for shell-level commands (plugin rescan, config reload, etc.)
  IpcHandler {
    target: "shell"

    function rescanPlugins(): void {
      // Clear existing registrations and re-sync from PluginRegistry
      var ids = BarWidgetRegistry.availableIds()
      for (var i = 0; i < ids.length; i++) {
        BarWidgetRegistry.unregister(ids[i])
      }
      PluginRegistry.rescan()
    }
  }

  // Run once on startup after PluginRegistry's initial scan
  Component.onCompleted: {
    // Defer to allow PluginRegistry's scan to complete
    Qt.callLater(syncPluginWidgets)
  }

  function syncPluginWidgets() {
    var ids = PluginRegistry.availableIds()
    for (var i = 0; i < ids.length; i++) {
      var id = ids[i]
      var manifest = PluginRegistry.installedPlugins[id]
      if (!manifest) continue

      // Only process bar-widget plugins
      var kinds = manifest.kinds || []
      if (kinds.indexOf("bar-widget") < 0) continue

      // Get the entry point URL
      var entryPointName = manifest.entryPoints && manifest.entryPoints.barWidget
      if (!entryPointName) continue

      var url = PluginRegistry.entryPointUrl(id, "barWidget")
      if (!url) {
        console.warn("[shell] Failed to resolve entry point for plugin:", id)
        continue
      }

      // Skip if already registered
      if (BarWidgetRegistry.has(id)) continue

      // Create the component
      var component = Qt.createComponent(url)
      if (component.status === Component.Error) {
        console.warn("[shell] Failed to load plugin component:", id, component.errorString())
        PluginRegistry.pluginLoadFailed(id, component.errorString())
        continue
      }

      // Build metadata from manifest
      var metadata = {
        displayName: manifest.barWidget ? manifest.barWidget.displayName : manifest.name,
        description: manifest.barWidget ? manifest.barWidget.description : manifest.description,
        category: manifest.barWidget ? manifest.barWidget.category : "",
        allowMultiple: manifest.barWidget ? manifest.barWidget.allowMultiple : false,
        defaults: manifest.barWidget ? manifest.barWidget.defaults || {} : {},
        schema: manifest.barWidget ? manifest.barWidget.schema || [] : []
      }

      // Register in the bar widget catalogue
      BarWidgetRegistry.register(id, component, metadata)
      console.log("[shell] Registered plugin widget:", id)
    }
  }

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
