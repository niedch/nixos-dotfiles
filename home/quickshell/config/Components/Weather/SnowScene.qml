import QtQuick
import qs

Item {
  id: root
  property bool active: false
  visible: root.active
  anchors.fill: parent

  property var flakes: []
  property bool particlesInit: false

  function tint(c, a) {
    var col = Qt.color(String(c))
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  function initParticles() {
    flakes = []
    for (var i = 0; i < 35; i++) {
      flakes.push({
        x: Math.random() * root.width,
        y: Math.random() * root.height,
        r: 1.5 + Math.random() * 2,
        speed: 30 + Math.random() * 40,
        phase: Math.random() * Math.PI * 2,
        driftAmp: 4 + Math.random() * 6
      })
    }
    particlesInit = true
  }

  function step() {
    if (!particlesInit) initParticles()
    for (var i = 0; i < flakes.length; i++) {
      var s = flakes[i]
      s.y += s.speed / 30
      s.phase += 0.05
      s.x += Math.sin(s.phase) * 0.3
      if (s.y > root.height + s.r) {
        s.y = -s.r
        s.x = Math.random() * root.width
      }
    }
    canvas.requestPaint()
  }

  Timer {
    id: tick
    interval: 33
    running: root.active
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
      ctx.fillStyle = root.tint(Colors.color7, 0.9)
      for (var i = 0; i < root.flakes.length; i++) {
        var s = root.flakes[i]
        ctx.beginPath()
        ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2)
        ctx.fill()
      }
    }
  }
}
