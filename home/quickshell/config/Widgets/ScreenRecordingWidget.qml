import QtQuick
import qs

PollingStatusWidget {
  pollInterval: Constants.pollFast
  checkCommand: ["bash", "-c", "pgrep -x wl-screenrec >/dev/null 2>&1 && echo 'recording' || true"]
  activeText: " REC"
  toggleCommand: ["cmd-screenrecord"]
  checkOnInit: false
}
