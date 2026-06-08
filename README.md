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

## Quick Start (build your own installer)

No pre-built installer is distributed here — see [BUILDING.md](BUILDING.md) for the full walkthrough. Once built:

1. Run `CheatEngine_Frankenstein_Setup.exe` as Administrator
2. Optionally tick "Create desktop shortcut" and "Associate .CT files"
3. Launch **Cheat Engine Frankenstein** from the Start Menu or desktop

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
  autoassembler.patch      ← 499-line diff across autoassembler.pas + SynHighlighterAA.pas

installer/
  CE_Frankenstein.iss      ← Inno Setup 6 script; produces the setup EXE

extensions/
  autorun/
    extensions_loader.lua  ← loads plugins from Extensions\ on startup
  Extensions/
    AITools/               ← AI scripting panel (configure endpoint in aibase.lua)

examples/
  frankenstein_example.CEA ← complete AA script demonstrating all four new commands
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

## Example Script

See [`examples/frankenstein_example.CEA`](examples/frankenstein_example.CEA) for a complete working script demonstrating all four new commands together — AOBSCANFUNCTION, HOOK/UNHOOK, and `{$ifdef CPU64}/{$else}/{$endif}` — in a realistic invincibility hook pattern.

---

## Troubleshooting

**CE crashes or fails to load on startup**
- Run as Administrator. The DBK kernel driver requires elevation — without it CE exits silently or crashes before the main window appears.

**`dbk64.sys` failed to load / driver error on first run**
- Secure Boot or driver signature enforcement may be blocking the driver. Either disable Secure Boot in BIOS or enable test signing: `bcdedit /set testsigning on` (requires reboot). Note: test signing is not needed if you use the signed driver from a CE 7.7 install.

**`lazbuild` not found when building from source**
- Add Lazarus to your PATH: `$env:PATH += ";C:\lazarus"` — or use the full path `C:\lazarus\lazbuild.exe` as shown in BUILDING.md.

**Patch fails to apply (`git apply` error)**
- Make sure you're applying against CE 7.5 HEAD (`ec45d5f4`). Later commits may have context drift. Use `git apply --3way patches/autoassembler.patch` for a best-effort merge.

**HOOK() throws "no module found for address"**
- `HOOK` requires the target address to be in an already-loaded module. Make sure the process is attached and the module is loaded before running the script.

**`{$ifdef}` / `{$else}` blocks not behaving correctly**
- Directives are case-insensitive but must be on their own line with no leading spaces before the `{`. Inline use (e.g., `mov eax, 1 {$ifdef CPU64}`) is not supported.

---

## Contributors

| Contributor | Role |
|---|---|
| [lolidroid86](https://github.com/lolidroid86) | Project lead — concept, testing, CE 7.7 driver sourcing, build verification |
| [Claude Sonnet 4.6](https://claude.ai) (Anthropic) | Implementation — AA command backports, installer script, documentation |

---

## License

Source patches are released under the same terms as Cheat Engine (open source, non-commercial).  
`dbk64.cepack` / `dbk32.cepack` are the original CE kernel driver; they remain © dark_byte.
