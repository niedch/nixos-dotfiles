import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
  id: idleService

  readonly property string stateFilePath: (Quickshell.env("HOME") ?? "") + "/.local/state/qs/indicators/stay-awake"

  property FileView stayAwakeFile: FileView {
    id: stayAwakeFile
    path: idleService.stateFilePath
    watchChanges: true
    printErrors: false

    onLoaded: {
      console.log("[IdleService] Loaded stay-awake state file")
      idleService.syncHypridle()
    }

    onLoadFailed: {
      console.log("[IdleService] Stay-awake state file not loaded or not found")
      idleService.syncHypridle()
    }

    onFileChanged: {
      console.log("[IdleService] Stay-awake state file changed on disk, reloading...")
      reload()
    }
  }

  readonly property bool stayAwakeActive: {
    if (!stayAwakeFile.loaded) return false
    var content = String(stayAwakeFile.text()).trim().toLowerCase()
    return content === "true" || content === "on" || content === "1" || content === ""
  }

  onStayAwakeActiveChanged: {
    idleService.syncHypridle()
  }

  function syncHypridle() {
    if (stayAwakeActive) {
      console.log("[IdleService] Stay Awake active: stopping hypridle.service")
      Quickshell.execDetached(["systemctl", "--user", "stop", "hypridle.service"])
    } else {
      console.log("[IdleService] Stay Awake inactive: starting hypridle.service")
      Quickshell.execDetached(["systemctl", "--user", "start", "hypridle.service"])
    }
  }
}
