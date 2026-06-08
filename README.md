# Cheat Engine Frankenstein

A custom build of **Cheat Engine 7.5** (public source) with four Auto-Assembler commands backported from CE 7.6.3/7.7, plus the AITools extension pre-wired.

---

## What's Different

### Backported Auto-Assembler Commands

| Command | Purpose |
|---|---|
| `HOOK(address, destination, origcodename)` | Write a code hook and stash the original bytes/stub |
| `UNHOOK(address)` | Restore original bytes written by a prior `HOOK()` |
| `{$ifdef SYMBOL}` / `{$ifndef SYMBOL}` / `{$endif}` | Conditional compilation in AA scripts |
| `AOBSCANFUNCTION(name, functionname, aob)` | AOB scan within ±64 KB of a named symbol |

See [CHANGES.md](CHANGES.md) for full syntax, examples, and implementation notes.

### AITools Extension

`autorun/extensions_loader.lua` + `Extensions/AITools/` are pre-included. AITools adds an AI-assisted scripting panel inside CE. Configure your endpoint in `Extensions/AITools/aibase.lua`.

---

## Quick Start (pre-built installer)

1. Download `CheatEngine_Frankenstein_Setup.exe` from [Releases](../../releases)
2. Run as Administrator
3. Optionally tick "Create desktop shortcut" and "Associate .CT files"
4. Launch **Cheat Engine Frankenstein** from the Start Menu or desktop

> The installer bundles `dbk64.cepack` / `dbk32.cepack` (the kernel driver). CE unpacks these to `dbk64.sys` / `dbk32.sys` on first run — requires Administrator.

---

## Building from Source

See [BUILDING.md](BUILDING.md) for the full walkthrough. Short version:

```
git clone https://github.com/cheat-engine/cheat-engine.git
cd cheat-engine
git apply patches/autoassembler.patch
lazbuild.exe --build-mode="Release 64-Bit" "Cheat Engine\cheatengine.lpi"
```

---

## Repo Layout

```
patches/
  autoassembler.patch      ← the only source change (394-line diff against CE 7.5 HEAD)

installer/
  CE_Frankenstein.iss      ← Inno Setup 6 script; produces the setup EXE

extensions/
  autorun/
    extensions_loader.lua  ← loads plugins from Extensions\ on startup
  Extensions/
    AITools/               ← AI scripting panel (configure endpoint in aibase.lua)
```

---

## Supporting Files (not in this repo)

The installer script expects these files in `Cheat Engine\bin\` at build time.  
They are **not** included here because they are either (a) built from the [DBKKernel](https://github.com/cheat-engine/cheat-engine/tree/master/DBKKernel) source or (b) extracted from a CE 7.7 install.

| File | Source |
|---|---|
| `dbk64.cepack`, `dbk32.cepack` | Build DBKKernel with WDK, then `cepack -c dbk64.sys dbk64.cepack` |
| `allochook-*.dll`, `vehdebug-*.dll`, `winhook-*.dll` | CE 7.7 install |
| `tcc32-*.dll`, `tcc64-*.dll` | CE 7.7 install |
| `luaclient-*.dll`, `CSCompiler.dll` | CE 7.7 install |
| `standalonephase*.cepack`, `tiny.cepack` | CE 7.7 install |
| `DotNetDataCollector*.exe` | CE 7.7 install |

---

## License

Source patches are released under the same terms as Cheat Engine (open source, non-commercial).  
`dbk64.cepack` / `dbk32.cepack` are the original CE kernel driver; they remain © dark_byte.
