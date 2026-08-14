import QtQuick
import qs.Ui

PollingStatusWidget {
  moduleName: "quickshell.screen-recording"
  pollInterval: 5000
  checkCommand: ["bash", "-c", "pgrep -x wl-screenrec >/dev/null 2>&1 && echo 'recording' || true"]
  activeText: " REC"
  toggleCommand: ["cmd-screenrecord"]
  checkOnInit: false
}
