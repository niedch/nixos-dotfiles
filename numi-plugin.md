# Plan: Port nvumi to a Quickshell Plugin

**Source:** [josephburgess/nvumi](https://github.com/josephburgess/nvumi)  
**Target:** Quickshell (QtQuick/QML desktop shell toolkit)

---

## Overview

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural-language calculator (`numi-cli`) with a scratch buffer. Users type expressions like `20 inches in cm` or `x = 5000` and see results evaluated inline.

This plan describes how to port that experience into a **Quickshell** plugin/widget: a floating calculator overlay driven by QML UI and external `numi-cli` processes.

### Core nvumi features to preserve

- Floating scratch-style buffer
- Natural-language evaluation via `numi-cli`
- Variables (`x = 20 inches in cm`)
- Custom unit conversions and functions
- Inline `{}` pre-evaluation
- Virtual-text style results (inline / newline)
- Debounced live evaluation
- Yank / reset / persist buffer

### Hard dependency

- `numi-cli` must be installed and on `PATH` (same as upstream nvumi)

---

## Architecture mapping

| nvumi (Lua / Neovim)              | Quickshell equivalent                                      |
|-----------------------------------|------------------------------------------------------------|
| Scratch floating window           | `PanelWindow` or `FloatingWindow` + multi-line editor      |
| `jobstart` / `system` → numi-cli  | `Process` + `StdioCollector` (`Quickshell.Io`)             |
| Debounce on text change           | QML `Timer`                                                |
| Virtual text (extmarks)           | Side-by-side results column or trailing labels per line    |
| State (vars, results)             | JS object / `QtObject` properties                          |
| Custom functions / conversions    | Port to JS, or lean on `numi-cli` for v1                   |
| Config (size, prefix, keys…)      | QML properties + optional settings / config file           |

### Suggested project layout

```
~/.config/quickshell/nvumi/          # or inside a shell’s plugins/ dir
├── shell.qml                        # entry (standalone config)
├── Nvumi.qml                        # main overlay / root component
├── CalculatorEngine.qml             # evaluation logic + Process
├── LineModel.qml / ResultsList.qml  # UI for lines + results
├── Config.qml                       # defaults + persistence
└── README.md
```

If targeting a shell with a formal plugin system (e.g. DankMaterialShell), use its `plugin.json` + widget pattern instead of a free-standing config.

---

## Goals and scope

### Target experience

- Toggleable floating calculator overlay (or bar/panel widget)
- Multi-line notepad: type natural-language math → results appear as you type or on Enter
- Support for variables, custom units/functions (port or approximate)
- Clipboard yank of results
- Optional persistence of buffer content across opens

### Out of scope for v1

- Full Neovim buffer integration / filetype / “eval any buffer”
- Perfect 1:1 parity of every Lua edge case
- Replacing `numi-cli` with a pure QML/JS parser (possible later)

---

## Phased implementation plan

### Phase 0 – Research and setup (½–1 day)

1. Confirm `numi-cli` and Quickshell are installed and working.
2. Review nvumi source, especially:
   - `runner.lua` – how `numi-cli` is invoked
   - `evaluator.lua` – custom functions
   - `converter.lua` / processor – custom units and `{}`
   - `scratch.lua` – window and buffer behavior
3. Review Quickshell docs:
   - `Process` / `StdioCollector`
   - `PanelWindow` / `FloatingWindow`
   - IPC (for compositor keybinds)
4. Decide delivery form:
   - **Standalone** Quickshell config (`qs -c nvumi`)
   - **Plugin** inside an existing shell (DankMaterialShell, Omarchy, etc.)

---

### Phase 1 – Minimal viable overlay (1–2 days)

**UI**

- Centered `PanelWindow` or `FloatingWindow`
- Multi-line `TextArea` (or `ListView` of editable lines)
- Simple themed background and border

**Evaluation**

- On Enter (or Run button), for each non-empty line run:

```qml
Process {
  command: ["numi-cli", expression]
  stdout: StdioCollector {
    onStreamFinished: result = this.text.trim()
  }
}
```

- Display the result next to or under the line

**Toggle**

- Compositor keybind → `qs -c nvumi` or IPC `toggle`
- Escape / close button hides the window

**Deliverable:** Open → type `20 inches in cm` → see result.

---

### Phase 2 – Live evaluation and polish (1–2 days)

1. **Debounced live eval**  
   `TextArea` `onTextChanged` → short `Timer` (150–300 ms) → re-evaluate all lines.

2. **Per-line results model**  
   Maintain an array of `{ input, result, error }` for reactive UI.

3. **Prefix / formatting**  
   Configurable result prefix (` = `, ` → `, etc.).

4. **Yank**  
   Copy current result or all results to clipboard (Quickshell clipboard API or `wl-copy` via Process).

5. **Reset**  
   Clear text and results.

6. **Persistence**  
   Save buffer to an XDG path (e.g. `~/.local/share/nvumi/scratch.txt`) on close; restore on open.

---

### Phase 3 – Feature parity with nvumi (2–4 days)

| Feature | Approach |
|---------|----------|
| **Variables** (`x = 20 inches in cm`) | Keep a JS map of variables. On assignment lines, store the result of `numi-cli`. Substitute known vars into later expressions before calling `numi-cli`. |
| **`{}` pre-eval** | Regex-replace `{...}` with evaluated results, then send the final string to `numi-cli`. |
| **Custom conversions** | Port ratio/base-unit logic to JS, or pre-process the expression (as nvumi does around `numi-cli`). |
| **Custom functions** | Small JS dispatcher for `fn(...)`; fall back to `numi-cli` for everything else. |
| **Date format** | Optional post-processing, or leave to `numi-cli`. |
| **Error handling** | Show stderr / empty results as “Error” or “??”. |

Prioritize variables and `{}` first; add custom units/functions only as needed.

---

### Phase 4 – Integration and packaging (1 day)

1. **Standalone config**
   - Place under `~/.config/quickshell/nvumi/shell.qml`
   - Document launch: `qs -c nvumi`
   - Example Hyprland bind:

     ```conf
     bind = $mainMod, N, exec, qs -c nvumi
     ```

2. **Shell plugin** (if applicable)
   - Add `plugin.json`, settings UI, optional bar pill that toggles the overlay.

3. **README**
   - Install `numi-cli`
   - Keybinds
   - Config options (size, prefix, debounce, theme colors)

4. **Optional IPC**
   - Expose `toggle`, `eval "expression"`, `clear` for external control.

---

### Phase 5 – Hardening (ongoing)

- Clear UI message when `numi-cli` is missing
- Ignore stale Process results when the user types quickly (generation counter, as in nvumi’s `eval_gen`)
- Limit concurrent processes or queue evaluations
- Theme integration with the host shell’s palette
- Keyboard-only / accessibility-friendly controls

---

## Component sketch

### CalculatorEngine.qml (core logic)

```qml
import QtQuick
import Quickshell.Io

QtObject {
  id: engine
  property var variables: ({})
  property var results: []          // [{input, result}]
  property int generation: 0

  function evaluateAll(text) {
    generation++
    const gen = generation
    const lines = text.split("\n")
    // For each line: handle assignment / {} / custom fn, then spawn Process
    // Update results only if gen === generation
  }

  function runNumi(expr, callback) {
    // Create Process dynamically or reuse a pool
  }
}
```

### Nvumi.qml (UI)

- `PanelWindow` / `FloatingWindow`
- `TextArea` bound to the engine
- `ListView` or overlay for results
- Footer: Run / Reset / Yank / Close

---

## Risks and decisions

| Risk | Mitigation |
|------|------------|
| `numi-cli` latency with many lines | Debounce + sequential or limited parallel Processes |
| No Neovim-style virtual text in QML | Dual-column UI or append results after each line |
| Custom Lua functions → JS | Port only needed functions; document the rest |
| Plugin vs standalone | Standalone is simpler to ship; plugin integrates better with full shells |
| Clipboard on Wayland | Prefer Quickshell clipboard API if available; else `wl-copy` |

---

## Recommended order of work

1. **Day 1:** Floating window + single-expression `numi-cli` eval  
2. **Day 2:** Multi-line + live debounce + result display  
3. **Day 3:** Variables + yank / reset / persist  
4. **Day 4:** Polish UI, keybinds, config, docs  
5. **Later:** Custom conversions/functions, bar widget, IPC  

---

## Immediate next steps

1. Create `~/.config/quickshell/nvumi/shell.qml` with a minimal `PanelWindow` + `TextArea`.
2. Add a `Process` that runs `numi-cli` on the current line when Enter is pressed.
3. Display the result beside the input.

---

## References

- [nvumi repository](https://github.com/josephburgess/nvumi)
- [numi / numi-cli](https://github.com/nikolaeu/numi)
- [Quickshell](https://quickshell.org/)
- [Quickshell intro / Process examples](https://quickshell.org/docs/guide/introduction)
- [Process type](https://quickshell.org/docs/v0.2.0/types/Quickshell.Io/Process/)
- [StdioCollector](https://quickshell.org/docs/v0.2.0/types/Quickshell.Io/StdioCollector)

---

*Plan generated for porting nvumi into a Quickshell plugin/widget.*

