import QtQuick
import qs

PollingStatusWidget {
  pollInterval: Constants.pollFast
  checkCommand: ["bash", "-c", "pgrep -x wf-recorder >/dev/null 2>&1 && echo 'recording' || true"]
  activeText: " REC"
  toggleCommand: ["capture-screenrecord"]
  checkOnInit: false
}
