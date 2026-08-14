pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Registry of available quickshell plugins. First-party plugins live in
// <configPath>/Plugins, third-party plugins in ~/.config/quickshell/plugins.
// Each plugin is a directory containing a manifest.json, which is validated
// before it is published through installedPlugins.
//
// Simplified relative to omarchy's PluginRegistry: there is no
// shell.json-based enable/disable state — every plugin that passes
// validation is considered enabled, and the shell.json layout decides which
// widgets actually get placed. Consumers treat this as a read-only catalog
// of what is loadable.
Singleton {
  id: registry

  // ------------------------------------------------------------------ state

  // { pluginId: manifest } — each manifest has __sourceDir (absolute path of
  // the plugin directory) and __isFirstParty (bool) stamped in.
  property var installedPlugins: ({})
  // Monotonic counter bumped on every completed scan so consumers can
  // cheaply detect "the catalog changed".
  property int revision: 0
  // True while a scan subprocess is in flight; rescan() is a no-op during it.
  property bool scanning: false

  // Directory of the shell.qml entry point. Quickshell sets QS_CONFIG_PATH
  // itself when loading a config, so the env var is authoritative in
  // practice; Quickshell.shellPath("") resolves to the same config root as
  // a fallback for unusual launch setups.
  property string configPath: {
    var fromEnv = Quickshell.env("QS_CONFIG_PATH")
    if (fromEnv) return String(fromEnv)
    return String(Quickshell.shellPath("")).replace(/\/$/, "")
  }
  // Third-party plugin install directory.
  property string userPluginPath: (Quickshell.env("HOME") ?? "") + "/.config/quickshell/plugins"

  signal pluginsChanged()
  signal scanFinished()
  // Emitted for every manifest that fails parsing or validation. `id` is the
  // plugin id when the manifest declared one, otherwise a label for the
  // manifest file that failed.
  signal pluginLoadFailed(string id, string error)

  // ---------------------------------------------------------------- helpers

  function isPlainObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value)
  }

  // file:// URL with each path segment percent-encoded so spaces and
  // special characters in user paths don't break Image.source etc.
  function fileUrl(path) {
    if (!path) return ""
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
  }

  // A manifest entry point must be a relative path that stays inside the
  // plugin's own directory: no absolute paths, no ".." traversal.
  function isSafeEntryPoint(value) {
    if (typeof value !== "string" || value.length === 0) return false
    if (value.charAt(0) === "/") return false
    if (value.indexOf("..") !== -1) return false
    return true
  }

  function manifestLabel(manifest, sourcePath) {
    if (manifest && typeof manifest.id === "string" && manifest.id) return manifest.id
    return sourcePath
  }

  // Reject a manifest unless every required field is present and sane.
  // Returns the manifest on success (so callers can chain), null otherwise.
  // The __sourceDir / __isFirstParty stamps are expected to already be set.
  function validateManifest(manifest, sourcePath) {
    if (!isPlainObject(manifest)) {
      console.warn("PluginRegistry: manifest is not an object at " + sourcePath)
      pluginLoadFailed(manifestLabel(manifest, sourcePath), "manifest is not a JSON object")
      return null
    }
    if (manifest.schemaVersion !== 1) {
      console.warn("PluginRegistry: unsupported schemaVersion at " + sourcePath)
      pluginLoadFailed(manifestLabel(manifest, sourcePath),
        "unsupported schemaVersion: " + manifest.schemaVersion)
      return null
    }

    var id = manifest.id
    if (typeof id !== "string" || id.length === 0) {
      console.warn("PluginRegistry: missing 'id' at " + sourcePath)
      pluginLoadFailed(manifestLabel(manifest, sourcePath), "missing or empty 'id'")
      return null
    }
    // Ids double as registry keys and path fragments; reject anything that
    // could traverse or collide.
    if (id.indexOf("/") !== -1 || id.indexOf("..") !== -1 || id.charAt(0) === "/") {
      console.warn("PluginRegistry: invalid plugin id '" + id + "' at " + sourcePath)
      pluginLoadFailed(id, "invalid plugin id '" + id + "'")
      return null
    }

    if (typeof manifest.name !== "string" || manifest.name.length === 0) {
      console.warn("PluginRegistry: missing 'name' at " + sourcePath)
      pluginLoadFailed(id, "missing or empty 'name'")
      return null
    }
    if (typeof manifest.version !== "string") {
      console.warn("PluginRegistry: missing 'version' at " + sourcePath)
      pluginLoadFailed(id, "missing or invalid 'version'")
      return null
    }

    if (!Array.isArray(manifest.kinds) || manifest.kinds.length === 0) {
      console.warn("PluginRegistry: 'kinds' must be a non-empty array at " + sourcePath)
      pluginLoadFailed(id, "'kinds' must be a non-empty array")
      return null
    }
    var allowedKinds = ["bar-widget", "panel", "overlay", "menu", "service"]
    for (var k = 0; k < manifest.kinds.length; k++) {
      if (allowedKinds.indexOf(manifest.kinds[k]) === -1) {
        console.warn("PluginRegistry: unknown kind '" + manifest.kinds[k] + "' at " + sourcePath)
        pluginLoadFailed(id, "unknown kind '" + manifest.kinds[k] + "'")
        return null
      }
    }

    if (!isPlainObject(manifest.entryPoints) || Object.keys(manifest.entryPoints).length === 0) {
      console.warn("PluginRegistry: 'entryPoints' must be a non-empty object at " + sourcePath)
      pluginLoadFailed(id, "'entryPoints' must be a non-empty object")
      return null
    }
    for (var key in manifest.entryPoints) {
      if (!isSafeEntryPoint(manifest.entryPoints[key])) {
        console.warn("PluginRegistry: unsafe entryPoint '" + key + "' at " + sourcePath)
        pluginLoadFailed(id, "unsafe entry point '" + key + "'")
        return null
      }
    }
    return manifest
  }

  // ----------------------------------------------------------------- lookup

  // Simplified semantics: every discovered plugin is enabled; the shell.json
  // layout decides placement, not availability.
  function isEnabled(key) {
    return has(key)
  }

  // Resolve an entry point to a file:// URL, verifying the resolved path
  // stays inside the plugin's own source directory.
  function entryPointUrl(key, entryPointName) {
    var manifest = installedPlugins[String(key)]
    if (!isPlainObject(manifest) || !isPlainObject(manifest.entryPoints)) return ""
    var entryPoint = manifest.entryPoints[String(entryPointName)]
    if (!isSafeEntryPoint(entryPoint)) return ""
    var dir = String(manifest.__sourceDir || "").replace(/\/$/, "")
    if (!dir) return ""
    // Defense in depth: even after validateManifest, re-verify the resolved
    // path does not escape the plugin's source directory.
    var resolved = dir + "/" + entryPoint
    if (resolved.indexOf(dir + "/") !== 0) {
      console.warn("PluginRegistry: entry point escapes sourceDir: " + resolved)
      return ""
    }
    return fileUrl(resolved)
  }

  function metadataFor(key) {
    return installedPlugins[String(key)] || null
  }

  function availableIds() {
    return Object.keys(installedPlugins).sort()
  }

  function has(key) {
    return Object.prototype.hasOwnProperty.call(installedPlugins, String(key))
  }

  // ---------------------------------------------------------------- scanning

  // Output format produced by the scan subprocess:
  //   ===firstparty::<absolute-source-dir>===
  //   ... raw manifest.json content ...
  //   === EOM ===
  // (repeated per manifest; third-party manifests use ===thirdparty::...===)
  function parseScanOutput(text) {
    var lines = String(text || "").split("\n")
    var firstParty = {}
    var thirdParty = {}
    var currentSource = null
    var currentKind = null
    var currentJson = []

    function flush() {
      if (!currentSource) return
      var raw = currentJson.join("\n").trim()
      var manifest = null
      try {
        manifest = JSON.parse(raw)
      } catch (e) {
        console.warn("PluginRegistry: bad manifest at " + currentSource + ": " + e)
        pluginLoadFailed(currentSource.replace(/.*\//, ""), "malformed manifest JSON")
        currentSource = null
        currentKind = null
        currentJson = []
        return
      }
      manifest.__sourceDir = currentSource
      manifest.__isFirstParty = currentKind === "firstparty"
      var validated = validateManifest(manifest, currentSource + "/manifest.json")
      if (validated) {
        if (currentKind === "firstparty") firstParty[validated.id] = validated
        else thirdParty[validated.id] = validated
      }
      currentSource = null
      currentKind = null
      currentJson = []
    }

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      var startMatch = line.match(/^===([a-z]+)::(.+)===$/)
      if (startMatch) {
        flush()
        currentKind = startMatch[1]
        currentSource = startMatch[2].replace(/\/$/, "")
        currentJson = []
        continue
      }
      if (line === "=== EOM ===") {
        flush()
        continue
      }
      if (currentSource) currentJson.push(line)
    }
    flush()

    // First-party manifests always win; a third-party plugin may never
    // shadow a built-in id or squat on the reserved quickshell.* namespace.
    var merged = {}
    for (var fk in firstParty) merged[fk] = firstParty[fk]
    for (var tk in thirdParty) {
      if (firstParty[tk] || String(tk).indexOf("quickshell.") === 0) {
        console.warn("PluginRegistry: plugin " + tk
          + " rejected: id is reserved for first-party plugins")
        pluginLoadFailed(tk, "id is reserved for first-party plugins")
        continue
      }
      merged[tk] = thirdParty[tk]
    }

    installedPlugins = merged
    revision++
    scanning = false
    pluginsChanged()
    scanFinished()
  }

  property Process scanProcess: Process {
    stdout: StdioCollector {
      id: scanStdout
      waitForEnd: true
    }
    onExited: function(exitCode) {
      registry.parseScanOutput(scanStdout.text || "")
    }
  }

  // Re-run the scan. The subprocess emits one
  // `===<kind>::<dir>=== ... === EOM ===` block per manifest.
  function rescan() {
    if (registry.scanning) return
    registry.scanning = true
    // $0 = first-party plugins root, $1 = third-party plugins root. Each
    // scan guards its own root: empty or missing directories are skipped.
    // `find` depth is counted from the root, so a manifest directly inside
    // a plugin directory is at depth 2.
    var script = ""
      + "scan() { local kind=\"$1\"; local root=\"$2\"; "
      + "  [[ -d \"$root\" ]] || return 0; "
      + "  while IFS= read -r manifest; do "
      + "    local sub=\"${manifest%/manifest.json}\"; "
      + "    printf '===%s::%s===\\n' \"$kind\" \"$sub\"; "
      + "    cat \"$manifest\"; "
      + "    printf '\\n=== EOM ===\\n'; "
      + "  done < <(find -L \"$root\" -mindepth 2 -maxdepth 2 -type f -name manifest.json | sort); "
      + "}; "
      + "[[ -n \"$0\" ]] && scan firstparty \"$0\"; "
      + "[[ -n \"$1\" ]] && scan thirdparty \"$1\""
    scanProcess.command = [
      "bash",
      "-c",
      script,
      registry.configPath ? registry.configPath + "/Plugins" : "",
      registry.userPluginPath || ""
    ]
    scanProcess.running = true
  }

  // Run the scan once on startup; rescan() retriggers it any time.
  Component.onCompleted: rescan()
}
