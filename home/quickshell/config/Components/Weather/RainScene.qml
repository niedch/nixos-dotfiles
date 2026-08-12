import QtQuick
import qs

Item {
  id: root
  property bool active: false
  property bool popupShown: false
  visible: root.active
  anchors.fill: parent

  property var drops: []
  property bool particlesInit: false

  function tint(c, a) {
    var col = Qt.color(String(c))
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  function initParticles() {
    drops = []
    for (var i = 0; i < 35; i++) {
      drops.push({
        x: Math.random() * root.width,
        y: Math.random() * root.height,
        len: 6 + Math.random() * 6,
        speed: 150 + Math.random() * 150
      })
    }
    particlesInit = true
  }

  function step() {
    if (!particlesInit) initParticles()
    for (var i = 0; i < drops.length; i++) {
      var d = drops[i]
      d.y += d.speed / 30
      if (d.y > root.height + d.len) {
        d.y = -d.len
        d.x = Math.random() * root.width
      }
    }
    canvas.requestPaint()
  }

  Timer {
    id: tick
    interval: 33
    running: root.active && root.popupShown
    repeat: true
    onTriggered: root.step()
  }

  Canvas {
    id: canvas
    anchors.fill: parent

    onPaint: {
      if (!root.particlesInit) root.initParticles()
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      ctx.strokeStyle = root.tint(Colors.color6, 0.8)
      ctx.lineWidth = 1
      for (var i = 0; i < root.drops.length; i++) {
        var d = root.drops[i]
        ctx.beginPath()
        ctx.moveTo(d.x, d.y)
        ctx.lineTo(d.x - 2, d.y - d.len)
        ctx.stroke()
      }
    }
  }
}
