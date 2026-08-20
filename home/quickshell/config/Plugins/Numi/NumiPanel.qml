import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "NumiNotes.js" as NumiNotes

// Natural-language calculator powered by numr-cli. Each non-empty line of
// the scratch pad is evaluated live (debounced 300ms) over a persistent
// JSON-RPC session (`numr-cli --server`), so results stream in below the
// editor row by row. Because the session lives for the widget's lifetime,
// variables and history persist across edits natively; `#` comment lines
// are skipped and never sent to the server. Notes persist to disk as JSON
// and are switchable from the side column.
Panel {
  id: root
  moduleName: "nic.numi"
  ipcTarget: "nic.numi"

  // --- state ---
  property string text: "" // bound two-way to the editor
  onTextChanged: {
    if (popup && popup.text !== root.text) {
      popup.text = root.text
    }
  }
  property bool busy: false
  property bool numrAvailable: true
  property string statusText: ""
  property int activeGeneration: 0
  property int totalEvalCount: 0
  property int completedEvalCount: 0
  property bool isCliCheckComplete: false
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy"
  property string notesPath: root.stateDir + "/numi-notes.json"
  property var notes: []
  property string activeNoteId: ""
  property int selectedNoteIndex: 0

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Rows are keyed by `line` (index in the split scratchpad) so results can
  // be patched back in by position even if the queue is rebuilt.
  ListModel {
    id: resultModel
  }

  ListModel {
    id: notesModel
  }

  Timer {
    id: evalDebounce
    interval: 300
    onTriggered: root.evaluateAll()
  }

  Timer {
    id: saveTimer
    interval: 500
    onTriggered: root.saveCurrentNote()
  }

  // Availability check — numr-cli has no --version flag.
  Process {
    id: checkProc
    command: ["bash", "-c", "command -v numr-cli"]
    onExited: function(code) {
      root.isCliCheckComplete = true
      root.numrAvailable = code === 0
      if (root.numrAvailable) root.startServer()
      else root.statusText = "numr-cli not found"
    }
  }

  // Persistent JSON-RPC session. Keep it alive for the widget's lifetime.
  Process {
    id: serverProc
    command: ["numr-cli", "--server"]
    stdinEnabled: true
    stdout: SplitParser {
      onRead: function(data) { root.handleServerResponse(data) }
    }
    onExited: function(code) {
      // If the server died unexpectedly and we still expect it, restart it.
      if (root.numrAvailable) restartTimer.restart()
    }
  }

  Timer {
    id: restartTimer
    interval: 1000
    onTriggered: root.startServer()
  }

  // FileView does not create parent directories — ensure the state dir first.
  Process {
    id: mkdirProc
    command: ["mkdir", "-p", root.stateDir]
  }

  FileView {
    id: notesFile
    path: root.notesPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadNotes(text())
    onLoadFailed: root.loadNotes("")
    onFileChanged: reload()
  }

  Component.onCompleted: {
    mkdirProc.running = true
    checkProc.running = true
  }

  // Closing the popup stops the debounce and persists the current note; the
  // background queue keeps draining so results are preserved on reopen.
  onOpenedChanged: {
    if (opened) return
    evalDebounce.stop()
    saveTimer.stop()
    root.saveCurrentNote()
  }

  function startServer() {
    if (serverProc.running) return
    serverProc.running = true
  }

  function evaluateNow() {
    evalDebounce.stop()
    root.evaluateAll()
  }

  function evaluateAll() {
    if (!root.numrAvailable || !root.isCliCheckComplete) {
      if (!root.isCliCheckComplete) Qt.callLater(function() { if (root.isCliCheckComplete) root.evaluateAll() })
      return
    }
    if (!serverProc.running) {
      root.startServer()
      evalDebounce.start()  // retry once the server is up
      return
    }
    var gen = ++root.activeGeneration
    resultModel.clear()
    var lines = root.text.split("\n")
    var exprs = []
    for (var i = 0; i < lines.length; i++) {
      var expr = lines[i].trim()
      if (expr === "" || expr.charAt(0) === "#") continue
      exprs.push(expr)
      resultModel.append({line: i, expr: expr, result: "", error: false, pending: true})
    }
    if (exprs.length === 0) {
      root.busy = false
      root.statusText = ""
      return
    }
    root.totalEvalCount = exprs.length
    root.completedEvalCount = 0
    root.busy = true
    root.statusText = "evaluating…"
    var req = JSON.stringify({jsonrpc: "2.0", method: "eval_lines", params: {lines: exprs}, id: gen})
    serverProc.write(req + "\n")
  }

  function handleServerResponse(data) {
    var line = String(data || "").trim()
    if (line === "") return
    var parsed
    try { parsed = JSON.parse(line) } catch (e) { return }
    if (parsed.id === undefined || parsed.id === null) return       // notification
    if (parsed.id !== root.activeGeneration) return                        // stale response from a previous edit
    if (parsed.error) {                                             // JSON-RPC protocol error
      root.busy = false
      root.statusText = "numr error"
      return
    }
    var vals = parsed.result
    if (!Array.isArray(vals)) return
    var count = Math.min(resultModel.count, vals.length)
    for (var i = 0; i < count; i++) {
      var v = vals[i] || {}
      var isErr = v.type === "error"
      var display = v.display !== undefined ? String(v.display) : ""
      resultModel.set(i, {
        line: resultModel.get(i).line,
        expr: resultModel.get(i).expr,
        result: isErr ? (v.message !== undefined ? String(v.message) : "error") : display,
        error: isErr,
        pending: false
      })
    }
    root.completedEvalCount = count
    if (root.completedEvalCount >= root.totalEvalCount) {
      root.busy = false
      root.statusText = ""
    }
  }

  function copyResult(modelIndex) {
    var row = resultModel.get(modelIndex)
    if (!row || row.error || row.pending || row.result === "") return
    Quickshell.clipboardText = row.result
    root.statusText = "copied " + row.result
  }

  function copyAll() {
    var parts = []
    for (var i = 0; i < resultModel.count; i++) {
      var row = resultModel.get(i)
      if (row.error || row.pending) continue
      parts.push(row.expr + " = " + row.result)
    }
    if (parts.length === 0) return
    Quickshell.clipboardText = parts.join("\n")
    root.statusText = "copied " + parts.length + " result" + (parts.length > 1 ? "s" : "")
  }

  function resetSession() {
    if (serverProc.running) {
      serverProc.write(JSON.stringify({jsonrpc: "2.0", method: "clear", id: 0}) + "\n")
    }
    ++root.activeGeneration
    resultModel.clear()
    root.busy = false
    root.statusText = ""
  }

  function clearAll() {
    root.resetSession()
    root.text = ""
  }

  function loadNotes(raw) {
    var parsed = NumiNotes.parseNotes(raw)
    
    // Safeguard active typing buffer from being overwritten during asynchronous disk loads
    var isSameActive = (parsed.activeNoteId === root.activeNoteId)
    var activeIdx = NumiNotes.findIndex(parsed.notes, parsed.activeNoteId)
    var isSameText = activeIdx >= 0 && (parsed.notes[activeIdx].text === root.text)

    root.notes = parsed.notes
    root.activeNoteId = parsed.activeNoteId
    if (root.notes.length === 0) {
      root.notes = [NumiNotes.newNote()]
      root.activeNoteId = root.notes[0].id
    }
    root.selectedNoteIndex = Math.max(0, NumiNotes.findIndex(root.notes, root.activeNoteId))
    root.rebuildNotes()

    // Only update the active editor text if the note changed, or if there is genuine text differences on disk
    if (!isSameActive || !isSameText) {
      root.text = root.notes[root.selectedNoteIndex].text
    }
  }

  function saveNotes() {
    notesFile.setText(JSON.stringify({schemaVersion: 1, activeNoteId: root.activeNoteId, notes: root.notes}, null, 2) + "\n")
  }

  function currentNote() {
    if (root.notes.length === 0) return null
    return root.notes[Math.max(0, Math.min(root.selectedNoteIndex, root.notes.length - 1))]
  }

  function updateCurrentNoteMemory() {
    var n = root.currentNote()
    if (!n) return
    n.text = root.text
    n.updatedAt = new Date().toISOString()
    root.rebuildNotes()
  }

  function saveCurrentNote() {
    root.updateCurrentNoteMemory()
    root.saveNotes()
  }

  function rebuildNotes() {
    var rows = NumiNotes.displayRows(root.notes)
    if (notesModel.count === rows.length) {
      // In-place update to prevent clearing the model and losing current selection/focus
      for (var i = 0; i < rows.length; i++) {
        notesModel.set(i, {id: rows[i].id, title: rows[i].title, lineCount: rows[i].lineCount})
      }
    } else {
      // Only clear and rebuild if the size changes (e.g. note added or deleted)
      notesModel.clear()
      for (var j = 0; j < rows.length; j++) {
        notesModel.append({id: rows[j].id, title: rows[j].title, lineCount: rows[j].lineCount})
      }
    }
  }

  function newNote() {
    root.updateCurrentNoteMemory()
    root.notes = NumiNotes.addNote(root.notes, NumiNotes.newNote())
    root.activeNoteId = root.notes[root.notes.length - 1].id
    root.selectedNoteIndex = root.notes.length - 1
    root.resetSession()
    root.text = ""
    root.rebuildNotes()
    root.saveNotes()
    Qt.callLater(function() { popup.forceEditorFocus() })
  }

  function deleteNote() {
    if (root.notes.length === 0) return
    var idx = root.selectedNoteIndex
    root.notes = NumiNotes.removeNoteAt(root.notes, idx)
    if (root.notes.length === 0) {
      root.notes = [NumiNotes.newNote()]
    }
    root.selectedNoteIndex = Math.min(idx, root.notes.length - 1)
    root.activeNoteId = root.notes[root.selectedNoteIndex].id
    root.resetSession()
    root.text = root.notes[root.selectedNoteIndex].text
    root.rebuildNotes()
    root.saveNotes()
  }

  function switchNote(index, focusEditor = true) {
    if (index < 0 || index >= root.notes.length) return

    if (index === root.selectedNoteIndex) {
      if (focusEditor) {
        Qt.callLater(function() { popup.forceEditorFocus() })
      }
      return
    }

    root.updateCurrentNoteMemory()
    root.selectedNoteIndex = index
    root.activeNoteId = root.notes[index].id
    root.resetSession()
    root.text = root.notes[index].text
    root.rebuildNotes()
    root.saveNotes()
    root.evaluateNow()

    if (focusEditor) {
      Qt.callLater(function() { popup.forceEditorFocus() })
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf1ec"
    tooltipText: "Numi calculator"

    onPressed: function(b) {
      if (root.opened) root.close()
      else root.open()
    }
  }

  NumiPopup {
    id: popup
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened

    notesModel: notesModel
    resultModel: resultModel
    selectedNoteIndex: root.selectedNoteIndex
    numrAvailable: root.numrAvailable
    statusText: root.statusText

    onTextChanged: {
      if (root.text !== text) {
        root.text = text
        saveTimer.restart()
        evalDebounce.restart()
      }
    }

    onNewNoteClicked: root.newNote()
    onNewNoteRequested: root.newNote()
    onSwitchNoteRequested: function(index, focusEditor) { root.switchNote(index, focusEditor) }
    onResultClicked: function(index) { root.copyResult(index) }
    onCopyAllClicked: root.copyAll()
    onClearAllClicked: root.clearAll()
    onDeleteNoteClicked: root.deleteNote()
    onEvaluateNowRequested: root.evaluateNow()
  }
}
