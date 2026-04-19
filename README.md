# JoyCon Codex Helper

Standalone helper for a right-hand `Joy-Con (R)` driven Codex workflow on macOS.

## Scope

- Direct `Joy-Con (R)` input routing through Apple's `GameController` framework.
- System key injection for arrows, `Return`, `Backspace`, and held `Control + M`.
- `R3` attempts Codex `Plan mode` toggle through the current desktop shortcut path `Shift + Tab`.
- Menu bar status for connection and battery, plus a low-battery beep.
- Optional `F18` fallback remains available if you later want an external mapper.

## Default Layout

- `X/B/Y/A` -> Up / Down / Left / Right
- `R` -> `Return`
- `+` -> `Backspace`
- `ZR` hold -> `Control + M`
- `R3` -> `Plan mode` toggle attempt
- `Home` -> Bluetooth/controller recovery scan
- Right stick movement is ignored
- `SL/SR` are ignored

## Run

```bash
cd /Users/chenyuanjie/developer/joycon-codex-helper
swift run JoyConCodexHelper
```

## First Run Checklist

1. Pair the right-hand `Joy-Con (R)` with macOS Bluetooth first.
2. Start the helper from this project directory with `swift run JoyConCodexHelper`.
3. Grant macOS Accessibility permission to `Terminal` when running with `swift run`.
4. If you later run the built helper binary directly, grant Accessibility to that helper instead of `Terminal`.
5. Keep the Codex composer focused when testing `ZR` dictation hold and `R3` plan toggle.

## Important Note

- The helper needs macOS Accessibility permission before it can inject keys into Codex.
- After the helper starts, use the menu bar item `Open Accessibility Settings`.
- `R3` uses the current Codex desktop shortcut assumption `Shift + Tab`; if a future Codex build changes that shortcut, this is the first mapping to re-check.
- `F18` is only the external-mapper fallback path. Direct Joy-Con mode does not require `F18`.
- Editing keys are guarded by the Codex app being frontmost, not by deep composer focus detection. Before using `+`, `R`, or arrows for text editing, keep the composer or Plan selection area focused.
- Held shortcuts are force-released when the controller changes, recovery starts, or the helper exits, so a dropped `ZR` hold should not leave `Control + M` logically stuck.

## Maintenance Rules

- Action names and config files are the stable API.
- Layout changes should require config edits first, not helper rewrites.
- Runtime alias resolution lives in `config/runtime/input-aliases.json`.
