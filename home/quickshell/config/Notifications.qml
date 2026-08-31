pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
  id: notifs

  property var notifications: []
  property int unread: 0
  property bool dnd: false
  property bool centerOpen: false

  property var toasts: []
  property int toastTimeout: 5000
  property int maxToasts: 4

  NotificationServer {
    id: server
    keepOnReload: true
    bodySupported: true
    bodyMarkupSupported: false
    bodyImagesSupported: false
    bodyHyperlinksSupported: false
    imageSupported: true
    actionsSupported: true
    actionIconsSupported: false
    inlineReplySupported: false
    persistenceSupported: true

    onNotification: function(n) {
      console.log("qs.notif: received from", n.appName, "|", n.summary)
      if (notifs.dnd) {
        console.log("qs.notif: dnd active, discarding id", n.id)
        n.tracked = false
        return
      }
      n.tracked = true
      console.log("qs.notif: tracked id", n.id)
      notifs.snapshot(n)
    }
  }

  function snapshot(n) {
    for (var i = 0; i < notifs.notifications.length; i++) {
      if (notifs.notifications[i].id === n.id) return
    }

    var actions = []
    var acts = n.actions
    for (var a = 0; a < acts.length; a++) {
      actions.push({id: acts[a].identifier, label: acts[a].text})
    }

    var resolvedIcon = n.appIcon || ""
    if (resolvedIcon !== "" && resolvedIcon.indexOf("://") === -1 && resolvedIcon[0] !== "/" && resolvedIcon[0] !== ".") {
      var path = Quickshell.iconPath(resolvedIcon, true)
      if (path !== "") resolvedIcon = path
    }

    var snap = {
      id: n.id,
      appName: n.appName,
      appIcon: resolvedIcon,
      summary: n.summary,
      body: n.body,
      urgency: n.urgency,
      expireTimeout: n.expireTimeout,
      image: n.image,
      time: Date.now(),
      actions: actions,
      seen: notifs.centerOpen
    }

    notifs.notifications = [snap].concat(notifs.notifications)
    notifs.recountUnread()
    notifs.pushToast(snap)
    console.log("qs.notif: snapshot total=", notifs.notifications.length)
    n.closed.connect(function() { notifs.onClosed(n.id) })
  }

  function onClosed(id) {
    var filtered = []
    for (var i = 0; i < notifs.notifications.length; i++) {
      if (notifs.notifications[i].id !== id) filtered.push(notifs.notifications[i])
    }
    notifs.notifications = filtered
    notifs.recountUnread()
    notifs.dismissToast(id)
  }

  function recountUnread() {
    var count = 0
    for (var i = 0; i < notifs.notifications.length; i++) {
      if (!notifs.notifications[i].seen) count++
    }
    notifs.unread = count
  }

  function markSeen() {
    var updated = notifs.notifications.slice()
    for (var i = 0; i < updated.length; i++) {
      updated[i].seen = true
    }
    notifs.notifications = updated
    notifs.recountUnread()
  }

  function dismiss(id) {
    var values = server.trackedNotifications.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) {
        values[i].dismiss()
        return
      }
    }
    notifs.onClosed(id)
  }

  function invokeAction(id, actionId) {
    var values = server.trackedNotifications.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) {
        var acts = values[i].actions
        for (var a = 0; a < acts.length; a++) {
          if (acts[a].identifier === actionId) {
            acts[a].invoke()
            var url = actionId
            if (url.indexOf("http://") !== 0 && url.indexOf("https://") !== 0) {
              url = acts[a].text
            }
            notifs.maybeOpenUrl(url)
            return
          }
        }
      }
    }
  }

  function maybeOpenUrl(actionId) {
    if (actionId.indexOf("http://") === 0 || actionId.indexOf("https://") === 0) {
      Quickshell.execDetached(["xdg-open", actionId])
    }
  }

  function defaultAction(id) {
    var values = server.trackedNotifications.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) {
        var acts = values[i].actions
        if (acts.length > 0) {
          var actionId = acts[0].identifier
          acts[0].invoke()
          var url = actionId
          if (url.indexOf("http://") !== 0 && url.indexOf("https://") !== 0) {
            url = acts[0].text
          }
          notifs.maybeOpenUrl(url)
        }
        return
      }
    }
  }

  function clear() {
    var values = server.trackedNotifications.values
    for (var i = values.length - 1; i >= 0; i--) {
      values[i].dismiss()
    }
    notifs.notifications = []
    notifs.toasts = []
    notifs.unread = 0
  }

  function toggleCenter() {
    notifs.centerOpen = !notifs.centerOpen
    if (notifs.centerOpen) notifs.markSeen()
  }

  function closeCenter() {
    notifs.centerOpen = false
  }

  function toggleDnd() {
    notifs.dnd = !notifs.dnd
  }

  function pushToast(snap) {
    if (notifs.dnd) {
      console.log("qs.notif: toast suppressed (dnd)")
      return
    }
    notifs.toasts = [snap].concat(notifs.toasts).slice(0, notifs.maxToasts)
    console.log("qs.notif: toast pushed, toasts=", notifs.toasts.length)
  }

  function dismissToast(id) {
    var filtered = []
    for (var i = 0; i < notifs.toasts.length; i++) {
      if (notifs.toasts[i].id !== id) filtered.push(notifs.toasts[i])
    }
    notifs.toasts = filtered
  }

  Timer {
    id: toastSweeper
    interval: 500
    repeat: true
    running: notifs.toasts.length > 0
    onTriggered: {
      var fresh = []
      for (var i = 0; i < notifs.toasts.length; i++) {
        var toast = notifs.toasts[i]
        var expiry = toast.time + (toast.expireTimeout > 0 ? toast.expireTimeout : notifs.toastTimeout)
        if (Date.now() >= expiry) {
          var values = server.trackedNotifications.values
          for (var j = 0; j < values.length; j++) {
            if (values[j].id === notifs.toasts[i].id) {
              values[j].dismiss()
            }
          }
        } else {
          fresh.push(toast)
        }
      }
      notifs.toasts = fresh
    }
  }

  IpcHandler {
    target: "notifications"
    function toggle() { notifs.toggleCenter() }
    function clear() { notifs.clear() }
    function toggleDnd(): void { notifs.toggleDnd() }
    function setDnd(enabled: bool): void { notifs.dnd = enabled }
    function getDnd(): bool { return notifs.dnd }
  }
}
