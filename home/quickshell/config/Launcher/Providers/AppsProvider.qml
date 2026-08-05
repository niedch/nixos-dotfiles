import Quickshell
import QtQuick

Scope {
  id: root

  property string webSearchUrl: ""
  signal resultsReady(var results)

  function search(query) {
    const rawQuery = query.trim()
    const q = rawQuery.toLowerCase()
    const all = DesktopEntries.applications.values
    const filtered = []

    for (let i = 0; i < all.length; i++) {
      const e = all[i]
      if (!e.name) continue

      const name = e.name.toLowerCase()
      const generic = e.genericName ? e.genericName.toLowerCase() : ""
      const keywords = e.keywords ? e.keywords.map(k => k.toLowerCase()) : []
      const categories = e.categories ? e.categories.map(c => c.toLowerCase()) : []

      const matches = q === "" ||
        name.startsWith(q) ||
        name.includes(q) ||
        generic.includes(q) ||
        keywords.some(k => k.includes(q)) ||
        categories.some(c => c.includes(q))

      if (matches) {
        filtered.push({
          key: e.id,
          kind: "app",
          entry: e,
          name: e.name,
          genericName: e.genericName,
          icon: e.icon,
          comment: e.comment,
        })
      }
    }

    filtered.sort(function (a, b) {
      const aPrefix = a.name.toLowerCase().startsWith(q) ? 0 : 1
      const bPrefix = b.name.toLowerCase().startsWith(q) ? 0 : 1
      if (aPrefix !== bPrefix) return aPrefix - bPrefix
      return a.name.localeCompare(b.name)
    })

    if (rawQuery !== "" && filtered.length === 0) {
      filtered.push({
        key: "websearch",
        kind: "web",
        query: rawQuery,
        url: root.webSearchUrl + encodeURIComponent(rawQuery),
      })
    }

    root.resultsReady(filtered)
  }

  function activate(item) {
    Quickshell.execDetached(item.entry.commandLine.filter(arg => !arg.startsWith("%")))
  }
}
