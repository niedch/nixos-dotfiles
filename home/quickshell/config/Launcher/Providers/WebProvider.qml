import Quickshell
import QtQuick

Scope {
  id: root

  property string webSearchUrl: ""
  signal resultsReady(var results)

  function search(query) {
    const q = query.trim()
    if (q === "") {
      root.resultsReady([])
      return
    }
    root.resultsReady([{
      key: "web",
      kind: "web",
      query: q,
      url: root.webSearchUrl + encodeURIComponent(q),
    }])
  }

  function activate(item) {
    Qt.openUrlExternally(item.url)
  }
}
