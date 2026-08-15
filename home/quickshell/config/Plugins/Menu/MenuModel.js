function findGroup(nodes, label) {
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i]
    if (n.kind === "group") {
      if (n.label === label) return n
      var found = findGroup(n.children, label)
      if (found) return found
    }
  }
  return null
}

function collectLeaves(nodes, trail, out, themes) {
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i]
    if (n.kind === "themes") {
      var themePath = trail.concat([n.label])
      for (var t = 0; t < themes.length; t++) {
        out.push({
          node: { label: themes[t], icon: "󰉼", kind: "action", action: "theme", theme: themes[t] },
          path: themePath.concat([themes[t]])
        })
      }
    } else if (n.kind === "group") {
      collectLeaves(n.children, trail.concat([n.label]), out, themes)
    } else {
      out.push({ node: n, path: trail.concat([n.label]) })
    }
  }
}

function buildDisplayItems(root) {
  if (root.searchText.trim() !== "") {
    return searchTree(root)
  }

  var prefix = []
  for (var i = 0; i < root.browseStack.length; i++) {
    prefix.push(root.browseStack[i].label)
  }

  // when we've navigated into the themes group, list the loaded themes
  if (root.browseStack.length > 0 && root.browseStack[root.browseStack.length - 1].kind === "themes") {
    var out = []
    for (var t = 0; t < root.themes.length; t++) {
      out.push({
        node: { label: root.themes[t], icon: "󰉼", kind: "action", action: "theme", theme: root.themes[t] },
        path: prefix.concat([root.themes[t]])
      })
    }
    return out
  }

  // browse current level (menuTree top level or group children)
  var level = root.browseStack.length === 0 ? root.menuTree : root.browseStack[root.browseStack.length - 1].children
  var out2 = []
  for (var j = 0; j < level.length; j++) {
    out2.push({ node: level[j], path: prefix.concat([level[j].label]) })
  }
  return out2
}

function searchTree(root) {
  var q = root.searchText.trim().toLowerCase()
  var leaves = []
  collectLeaves(root.menuTree, [], leaves, root.themes)
  var out = []
  for (var i = 0; i < leaves.length; i++) {
    var item = leaves[i]
    var hay = (item.node.label + " " + item.path.join(" ")).toLowerCase()
    if (hay.indexOf(q) !== -1) {
      out.push({ node: item.node, path: item.path })
    }
  }
  return out
}

function itemLabel(root, item) {
  if (item.node.dynamic) {
    var isOn = root.dynamicStates[item.node.dynamic] || false
    return (isOn ? "✓ " : "") + item.node.label
  }
  return item.node.label
}

function itemSubtitle(item) {
  var path = item.path
  if (path.length <= 1) return ""
  return path.slice(0, path.length - 1).join(" / ")
}
