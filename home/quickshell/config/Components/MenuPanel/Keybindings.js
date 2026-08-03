function parseKeymap(text) {
  var codeByName = {}
  var symByName = {}
  var sec = ""
  var lines = text.split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    if (line.indexOf("xkb_keycodes") !== -1) { sec = "codes"; continue }
    if (line.indexOf("xkb_symbols") !== -1) { sec = "syms"; continue }
    if (sec === "codes") {
      var m = line.match(/<([A-Za-z0-9_]+)>\s*=\s*([0-9]+)\s*;/)
      if (m) codeByName[m[1]] = m[2]
    } else if (sec === "syms") {
      var m2 = line.match(/key\s*<([A-Za-z0-9_]+)>\s*\{\s*\[\s*([^, \]]+)/)
      if (m2) symByName[m2[1]] = m2[2]
    }
  }
  var map = {}
  for (var k in codeByName) {
    var c = codeByName[k]
    var s = symByName[k]
    if (c && s && s !== "NoSymbol") map[c] = s
  }
  return map
}

function modsFor(mask) {
  switch (mask) {
    case 0: return ""
    case 1: return "SHIFT"
    case 4: return "CTRL"
    case 5: return "SHIFT CTRL"
    case 8: return "ALT"
    case 9: return "SHIFT ALT"
    case 12: return "CTRL ALT"
    case 13: return "SHIFT CTRL ALT"
    case 64: return "SUPER"
    case 65: return "SUPER SHIFT"
    case 68: return "SUPER CTRL"
    case 69: return "SUPER SHIFT CTRL"
    case 72: return "SUPER ALT"
    case 73: return "SUPER SHIFT ALT"
    case 76: return "SUPER CTRL ALT"
    case 77: return "SUPER SHIFT CTRL ALT"
    default: return ""
  }
}

function resolveKey(root, b) {
  var key = b.key || ""
  var keycode = b.keycode || 0
  if (b.mouse) {
    var mm = key.match(/mouse:([0-9]+)/)
    if (mm) {
      switch (mm[1]) {
        case "272": return "LEFT MOUSE BUTTON"
        case "273": return "RIGHT MOUSE BUTTON"
        case "274": return "MIDDLE MOUSE BUTTON"
        default: return "mouse:" + mm[1]
      }
    }
    return key
  }
  if (key.indexOf("code:") === 0) {
    var c = key.slice(5)
    return root.keymap[c] || key
  }
  if (key === "" && keycode) {
    return root.keymap[String(keycode)] || "code:" + keycode
  }
  return key
}

function parseBinds(root, text) {
  var out = []
  var arr = []
  try {
    arr = JSON.parse(text)
  } catch (e) {
    return out
  }
  for (var i = 0; i < arr.length; i++) {
    var b = arr[i]
    var combo = modsFor(b.modmask)
    var k = resolveKey(root, b)
    if (k && combo) combo += " + "
    combo += k

    var action = b.description || ""
    if (!action) {
      action = (b.dispatcher || "") + (b.arg ? " " + b.arg : "")
      action = action.replace(/^exec\s*[,]?\s*/, "")
    }
    if (!action) continue

    out.push({
      combo: combo,
      action: action,
      hay: (combo + " " + action).toLowerCase()
    })
  }
  out.sort(function (a, b) { return a.combo.localeCompare(b.combo) })
  return out
}

function filterKeybindings(root) {
  var q = root.searchText.trim().toLowerCase()
  var out = []
  for (var i = 0; i < root.keybindings.length; i++) {
    var k = root.keybindings[i]
    if (q === "" || k.hay.indexOf(q) !== -1) out.push(k)
  }
  return out
}
