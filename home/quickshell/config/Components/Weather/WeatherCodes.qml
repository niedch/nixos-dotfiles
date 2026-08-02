pragma Singleton
import Quickshell
import QtQuick
import qs

Singleton {
  id: codes

  function isSun(code) {
    return code === "113"
  }

  function isCloudy(code) {
    return code === "116" || code === "119" || code === "122"
  }

  function isFog(code) {
    return code === "143" || code === "248" || code === "260"
  }

  function isRain(code) {
    switch (code) {
      case "176": case "182": case "185": case "263": case "266": case "281":
      case "284": case "293": case "296": case "299": case "302": case "305":
      case "308": case "311": case "314": case "317": case "320": case "350":
      case "353": case "356": case "359": case "362": case "365": case "374":
      case "377": return true
    }
    return false
  }

  function isSnow(code) {
    switch (code) {
      case "179": case "227": case "230": case "323": case "326": case "329":
      case "332": case "335": case "338": case "368": case "371": return true
    }
    return false
  }

  function isThunder(code) {
    return code === "200" || code === "386" || code === "389" || code === "392" || code === "395"
  }

  function mapIcon(code, night) {
    switch (code) {
      case "113": return night ? "" : ""
      case "116": return night ? "" : ""
      case "119": case "122": return ""
      case "143": case "248": case "260": return ""
      case "176": case "263": case "353": return night ? "" : ""
      case "179": case "227": case "230": case "323": case "326": case "368": return night ? "" : ""
      case "182": case "185": case "281": case "284": case "311": case "314":
      case "317": case "320": case "350": case "362": case "365": case "374":
      case "377": return ""
      case "200": case "386": case "389": case "392": case "395": return ""
      case "266": case "293": case "296": case "299": case "302": case "305":
      case "308": case "356": case "359": return ""
      case "329": case "332": case "335": case "338": case "371": return ""
      default: return ""
    }
  }

  function tempColor(v) {
    if (isNaN(v)) return Colors.foreground
    if (v < 0) return Colors.color4
    if (v < 10) return Colors.color6
    if (v < 18) return Colors.color2
    if (v < 26) return Colors.color3
    if (v < 32) return Colors.color11
    return Colors.color1
  }

  function nightTime(obj) {
    if (!obj.weather || !obj.weather[0] || !obj.weather[0].astronomy || !obj.weather[0].astronomy[0]) return false
    var astro = obj.weather[0].astronomy[0]
    var sr = parseClock(astro.sunrise)
    var ss = parseClock(astro.sunset)
    if (sr === -1 || ss === -1) return false
    var d = new Date()
    var now = d.getHours() * 60 + d.getMinutes()
    return now < sr || now >= ss
  }

  function parseClock(s) {
    var m = String(s).match(/^(\d{1,2}):(\d{2})\s*([AP]M)?$/)
    if (!m) return -1
    var h = parseInt(m[1])
    if (m[3] === "PM" && h < 12) h += 12
    if (m[3] === "AM" && h === 12) h = 0
    return h * 60 + parseInt(m[2])
  }
}
