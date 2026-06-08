# Changes from CE 7.5 Public Source

Changes span two files: `Cheat Engine/autoassembler.pas` and `Cheat Engine/SynHighlighterAA.pas`.  
Patch: `patches/autoassembler.patch` (499 lines, applies cleanly against CE 7.5 HEAD `ec45d5f4`).

---

## 1. `HOOK(address, destination, origcodename)`

**Syntax**
```
HOOK(address, destination, origcodename)
```

**What it does**

1. Reads enough bytes at `address` to cover one full instruction (at least 14 bytes on 64-bit, 5 bytes on 32-bit — a full far/near JMP).
2. Allocates a code cave named `origcodename` large enough for the saved bytes + a JMP back.
3. Writes the original bytes + a return JMP into the cave.
4. Writes a JMP (far on 64-bit, near on 32-bit) from `address` → `destination`.
5. Pads any leftover bytes with `NOP`.

**Generated code** (conceptual)
```asm
; at origcodename:
  db <original bytes here>
  jmp address+codesize         ; return to code after the hook

; at address:
  jmp far destination          ; 64-bit: 14-byte FF25 trampoline
  nop                          ; padding if instruction was longer than 14
```

**Example**
```
[ENABLE]
aobscan(myFunc, 48 89 5C 24 ?? 57 48 83 EC 20)
alloc(myHook, 256)
label(origBytes)

myHook:
  ; your code here
  mov [myFlag], 1
  jmp origBytes

HOOK(myFunc, myHook, origBytes)

[DISABLE]
UNHOOK(myFunc)
dealloc(myHook)
```

**Persistence**  
Hook metadata (original bytes, cave address) is stored in a unit-level `hookInfoList` that persists across [ENABLE]/[DISABLE] calls within the same CE session, so `UNHOOK` can find the data without re-scanning.

---

## 2. `UNHOOK(address)`

**Syntax**
```
UNHOOK(address)
```

Restores the original bytes that `HOOK()` saved. Looks up `address` in `hookInfoList`, writes the original byte sequence back, and queues the origcode allocation for deallocation.

Must be called with the same `address` as the matching `HOOK()`.

---

## 3. `{$ifdef}` / `{$ifndef}` / `{$endif}`

**Syntax**
```
{$ifdef SYMBOL}
  ... lines included when SYMBOL is defined ...
{$endif}

{$ifndef SYMBOL}
  ... lines included when SYMBOL is NOT defined ...
{$endif}
```

**Built-in symbols** (always defined automatically)

| Symbol | When true |
|---|---|
| `WINDOWS` | Always (CE on Windows) |
| `CPU64` | Target process is 64-bit |
| `WIN64` | Same as CPU64 |
| `CPU32` | Target process is 32-bit |
| `WIN32` | Same as CPU32 |

**User-defined symbols** are picked up from any `DEFINE(name, value)` line present in the same script.

**Nesting** is supported up to 64 levels deep.

**Example**
```
{$ifdef CPU64}
  jmp far myHook64
{$else}
  jmp myHook32
{$endif}
```

**Also supported:** `{$else}` — flips the active/skip state at the current nesting level, with a correct outer-skip guard so nested blocks don't interfere.

```
{$ifdef CPU64}
  jmp far myHook64
{$else}
  jmp myHook32
{$endif}
```

**Implementation**  
`processAAIfdefBlocks(code, is64bit)` runs as a pre-pass before AOB scans. It blanks out excluded lines in-place (sets them to `''`) so the rest of the assembler sees a clean linear script. `{$else}` is handled by checking `nskip - ord(skipStack[skipDepth]) = 0` before flipping, ensuring outer skips are not disturbed.

---

## 4. `AOBSCANFUNCTION(name, functionname, aob)`

**Syntax**
```
AOBSCANFUNCTION(name, functionname, aob)
```

Scans for `aob` within a window starting 256 bytes before `functionname` and ending 65 KB after it (resolved via the symbol handler). Equivalent to:
```
aobscanmodule(name, <module containing functionname>, aob)
```
...but constrained to the function's local region instead of the entire module. Useful when a byte pattern occurs in multiple places across a binary but you know which function it belongs to.

**Example**
```
AOBSCANFUNCTION(myPattern, MyGameFunction, 48 8B 05 ?? ?? ?? ??)
```

---

## Implementation Details

### Files changed

| File | Change |
|---|---|
| `Cheat Engine/autoassembler.pas` | All new AA commands + `{$else}` + AOBSCANFUNCTION scan bounds |
| `Cheat Engine/SynHighlighterAA.pas` | Syntax highlighting for HOOK, UNHOOK, AOBSCANFUNCTION |

### New types / globals added (unit level)

```pascal
type
  THookInfoRec = record
    hookaddr:     ptrUint;
    origcodename: string;
    codesize:     integer;
    origbyteshex: string;  // hex string of saved bytes for UNHOOK
  end;
var
  hookInfoList: array of THookInfoRec;
```

### New procedures added

- `processAAIfdefBlocks(code: TStrings; is64bit: boolean)` — ifdef pre-pass
- Inline handlers for `HOOK(`, `UNHOOK(`, `AOBSCANFUNCTION(` in `autoassemble2`'s first-pass loop

### Bug fixed during implementation

`ReadProcessMemory`'s 5th parameter (`lpNumberOfBytesRead`) must be `ptruint` (8 bytes on 64-bit), not `dword`. The original call used a local `bw: dword` variable; replaced with the already-declared `x: ptruint`.

### Varsize reuse issue

Inside `HOOK()`, `varsize` is first set to jmpsize (14 or 5), then overwritten with `length(origcodename)` for alloc-list sort ordering. The saved jmpsize is captured into `diff: ptruint` immediately after assignment and used for NOP-padding logic.

---

## Post-release fixes (v2)

### Fix 1 — `{$else}` support

`{$else}` was missing from `processAAIfdefBlocks` entirely. Scripts using the common `{$ifdef CPU64} … {$else} … {$endif}` pattern would silently execute both branches.

**Fix:** Added `{$else}` handling with an outer-skip guard:
```pascal
if nskip - ord(skipStack[skipDepth]) = 0 then
  // flip skipStack[skipDepth] and adjust nskip
```
This ensures `{$else}` only flips the current level's skip state when no outer block is already causing a skip.

### Fix 2 — AOBSCANFUNCTION scan lower bound

The original window was `startaddress` to `startaddress + 65536`, starting exactly at the symbol address. Patterns in function prologues (which compilers often emit a few bytes before the nominal symbol entry) would be missed.

**Fix:** Window is now `startaddress - 256` (guarded against underflow) to `startaddress + 65792`, giving a small back-margin while keeping the forward range identical.

### Fix 3 — Syntax highlighting for new keywords

`HOOK`, `UNHOOK`, and `AOBSCANFUNCTION` displayed as plain identifiers in the AA editor. Added to `SynHighlighterAA.pas` using the existing hash-dispatch table:

| Keyword | Hash | Slot |
|---|---|---|
| `hook` | 49 | New `Func49` |
| `unhook` | 84 | Added to existing `Func84` (shared with `aobscanex`) |
| `aobscanfunction` | 157 | New `Func157` |

`{$ifdef}` / `{$else}` / `{$endif}` directives are already rendered as block comments by the highlighter (CE uses `{…}` Pascal comment syntax), which visually distinguishes them from code without additional changes.
