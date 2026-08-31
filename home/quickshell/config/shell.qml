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
  IdleService {}

  // When PluginRegistry discovers plugins, sync bar-widget components
  // into BarWidgetRegistry so Bar.qml can load them dynamically.
  Connections {
    target: PluginRegistry

    function onPluginsChanged() {
      syncPluginWidgets()
      panelEntries = computePanelEntries()
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

    function summon(id: string, payloadJson: string): string {
      return root.summon(id, payloadJson) ? "ok" : "unknown"
    }
    function hide(id: string): void { root.hide(id) }
    function toggle(id: string, payloadJson: string): void { root.toggle(id, payloadJson) }
    function call(id: string, method: string, arg: string): string { return root.callIfLoaded(id, method, arg) }
  }

  // Run once on startup after PluginRegistry's initial scan
  Component.onCompleted: {
    // Defer to allow PluginRegistry's scan to complete
    Qt.callLater(syncPluginWidgets)
    panelEntries = computePanelEntries()
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

  // --------------------------------------------------------- on-demand panels
  //
  // Generic loader for overlay/panel/menu plugin kinds. Each such plugin gets
  // a Loader, active when the manifest declares keepLoaded or while summoned.
  // summon/hide/toggle/call are exposed on the "shell" IPC target above.

  property var openPanelIds: ({})
  property var pendingPayloads: ({})
  property var panelLoaders: ({})
  property var panelEntries: []

  function computePanelEntries() {
    var out = []
    var plugins = PluginRegistry.installedPlugins
    var panelKinds = ["panel", "overlay", "menu"]
    for (var id in plugins) {
      var m = plugins[id]
      if (!m || !Array.isArray(m.kinds)) continue
      var matched = false
      for (var i = 0; i < panelKinds.length; i++) {
        if (m.kinds.indexOf(panelKinds[i]) !== -1) { matched = true; break }
      }
      if (!matched) continue
      var kind = m.kinds.indexOf("panel") !== -1 ? "panel"
        : (m.kinds.indexOf("overlay") !== -1 ? "overlay" : "menu")
      out.push({ id: id, manifest: m, kind: kind, keepLoaded: m.keepLoaded === true })
    }
    return out
  }

  function registerPanelLoader(pluginId, loader) {
    var next = {}
    for (var k in panelLoaders) next[k] = panelLoaders[k]
    next[String(pluginId)] = loader
    panelLoaders = next
  }

  function unregisterPanelLoader(pluginId) {
    var next = {}
    for (var k in panelLoaders) if (k !== String(pluginId)) next[k] = panelLoaders[k]
    panelLoaders = next
  }

  function deliverIfLoaded(pluginId) {
    var loader = panelLoaders[String(pluginId)]
    if (!loader || !loader.item) return
    var queue = pendingPayloads[String(pluginId)]
    if (!Array.isArray(queue) || queue.length === 0) return
    if (typeof loader.item.open === "function") {
      for (var i = 0; i < queue.length; i++) {
        try { loader.item.open(queue[i]) } catch (e) { console.warn("[shell] open failed for", pluginId, e) }
      }
    }
    pendingPayloads[String(pluginId)] = []
  }

  function invokeIfLoaded(pluginId, method, arg) {
    var loader = panelLoaders[String(pluginId)]
    if (!loader || !loader.item) return false
    if (typeof loader.item[method] === "function") {
      try { loader.item[method](arg); return true } catch (e) { return false }
    }
    return false
  }

  function callIfLoaded(pluginId, method, arg) {
    return invokeIfLoaded(pluginId, method, arg) ? "ok" : "unknown"
  }

  function summon(pluginId, payloadJson) {
    var key = String(pluginId)
    var manifest = PluginRegistry.installedPlugins[key]
    if (!manifest || !Array.isArray(manifest.kinds)) return false
    var isPanelKind = manifest.kinds.indexOf("panel") !== -1
      || manifest.kinds.indexOf("overlay") !== -1
      || manifest.kinds.indexOf("menu") !== -1
    if (!isPanelKind) return false

    openPanelIds[key] = true
    var queue = pendingPayloads[key] || []
    queue.push(payloadJson !== undefined ? payloadJson : "{}")
    pendingPayloads[key] = queue
    deliverIfLoaded(key)
    return true
  }

  function hide(pluginId) {
    var key = String(pluginId)
    invokeIfLoaded(key, "close", null)
    delete openPanelIds[key]
    delete pendingPayloads[key]
  }

  function isPluginOpen(pluginId) {
    var loader = panelLoaders[String(pluginId)]
    return !!(loader && loader.item && loader.item.opened === true)
  }

  function toggle(pluginId, payloadJson) {
    if (isPluginOpen(pluginId)) hide(pluginId)
    else summon(pluginId, payloadJson)
  }

  Instantiator {
    model: root.panelEntries
    active: true

    delegate: QtObject {
      id: panelEntry
      required property var modelData
      readonly property string pluginId: modelData.id
      readonly property var manifest: modelData.manifest
      readonly property string entryKind: modelData.kind
      readonly property bool keepLoaded: modelData.keepLoaded === true
      readonly property string sourceUrl: PluginRegistry.entryPointUrl(panelEntry.pluginId, panelEntry.entryKind)

      property Loader panelLoader: Loader {
        source: panelEntry.sourceUrl
        active: panelEntry.sourceUrl !== "" && (panelEntry.keepLoaded || root.openPanelIds[panelEntry.pluginId] === true)
        asynchronous: true
        onLoaded: {
          if (!item) return
          if ("shell" in item) item.shell = root
          if ("manifest" in item) item.manifest = panelEntry.manifest
          root.registerPanelLoader(panelEntry.pluginId, this)
        }
        onStatusChanged: {
          if (status === Loader.Error) {
            console.warn("[shell] failed to load panel plugin:", panelEntry.pluginId)
            root.hide(panelEntry.pluginId)
          }
        }
        Component.onDestruction: root.unregisterPanelLoader(panelEntry.pluginId)
      }
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
