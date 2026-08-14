pragma Singleton
import Quickshell
import QtQuick

// Registry of loaded bar-widget components. Populated by shell.qml after
// PluginRegistry discovers plugins and their bar-widget components are loaded
// via Qt.createComponent(). Bar.qml queries this to instantiate widgets.
Singleton {
  id: registry

  // { widgetId: { component: Component, metadata: var } }
  property var widgets: ({})
  property int revision: 0

  signal changed()

  function register(id, component, metadata) {
    var copy = Object.assign({}, widgets)
    copy[id] = { component: component, metadata: metadata || {} }
    widgets = copy
    revision++
    changed()
  }

  function unregister(id) {
    if (!widgets[id]) return
    var copy = Object.assign({}, widgets)
    delete copy[id]
    widgets = copy
    revision++
    changed()
  }

  function metadataFor(id) {
    var entry = widgets[id]
    return entry ? entry.metadata : null
  }

  function componentFor(id) {
    var entry = widgets[id]
    return entry ? entry.component : null
  }

  function availableIds() {
    return Object.keys(widgets)
  }

  function has(id) {
    return widgets[id] !== undefined
  }
}
