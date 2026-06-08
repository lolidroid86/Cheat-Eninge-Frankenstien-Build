# Changes from CE 7.5 Public Source

All changes are in a single file: `Cheat Engine/autoassembler.pas`.  
Patch: `patches/autoassembler.patch` (394 lines, applies cleanly against CE 7.5 HEAD `ec45d5f4`).

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

**Implementation**  
`processAAIfdefBlocks(code, is64bit)` runs as a pre-pass before AOB scans. It blanks out excluded lines in-place (sets them to `''`) so the rest of the assembler sees a clean linear script.

---

## 4. `AOBSCANFUNCTION(name, functionname, aob)`

**Syntax**
```
AOBSCANFUNCTION(name, functionname, aob)
```

Scans for `aob` within a ±64 KB window around the address of `functionname` (resolved via the symbol handler). Equivalent to:
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
| `Cheat Engine/autoassembler.pas` | All new AA commands |

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
