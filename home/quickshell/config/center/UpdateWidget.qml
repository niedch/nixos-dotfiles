import QtQuick
import qs

PollingStatusWidget {
  pollInterval: Constants.pollUpdates
  checkCommand: ["bash", "-c", "omarchy-update-available"]
  activeText: ""
  toggleCommand: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"]
  widthPadding: 15
}
