import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property string lastQuery: ""
  property string lastDisplayExpr: ""
  signal resultsReady(var results)

  function search(query, displayExpr) {
    root.lastQuery = query.trim()
    root.lastDisplayExpr = displayExpr
    if (root.lastQuery === "") {
      calcDebounce.stop()
      root.resultsReady([])
      return
    }
    calcDebounce.restart()
  }

  function activate(item) {
    Quickshell.clipboardText = item.result
  }

  function runCalc() {
    if (root.lastQuery === "") {
      root.resultsReady([])
      return
    }
    calcProc.running = false
    calcProc.command = ["qalc", "-t", root.lastQuery]
    calcProc.running = true
  }

  Timer {
    id: calcDebounce
    interval: 250
    onTriggered: root.runCalc()
  }

  Process {
    id: calcProc
    stdout: SplitParser {
      onRead: function (data) {
        root.resultsReady([{
          key: "calc",
          kind: "calc",
          expr: root.lastDisplayExpr,
          result: data.trim(),
        }])
      }
    }
  }
}
