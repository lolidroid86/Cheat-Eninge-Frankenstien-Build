# Building CE Frankenstein from Source

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Lazarus IDE | 2.2.2 | Include FPC 3.2.2 |
| FPC | 3.2.2 | Bundled with Lazarus |
| Inno Setup | 6.3+ | For building the installer |
| Windows SDK / WDK | Optional | Only if rebuilding DBK driver from source |

Download Lazarus 2.2.2 with FPC 3.2.2: https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2064%20bits/Lazarus%202.2.2/

---

## Step 1 — Clone CE 7.5 and apply the patch

```powershell
git clone https://github.com/cheat-engine/cheat-engine.git
cd cheat-engine
git apply patches\autoassembler.patch
```

Verify it applied cleanly:
```powershell
git diff --stat HEAD
# Should show: Cheat Engine/autoassembler.pas | ~394 lines changed
```

---

## Step 2 — Copy extension files

```powershell
# From the repo root:
Copy-Item extensions\autorun\extensions_loader.lua "cheat-engine\Cheat Engine\bin\autorun\" -Force
Copy-Item extensions\Extensions\AITools "cheat-engine\Cheat Engine\bin\Extensions\" -Recurse -Force
```

---

## Step 3 — Build the EXE

```powershell
$lazbuild = "C:\lazarus\lazbuild.exe"   # adjust to your Lazarus path
cd "cheat-engine"
& $lazbuild --build-mode="Release 64-Bit" "Cheat Engine\cheatengine.lpi"
```

Expected output: `420228 lines compiled, 0.0 sec, ... 0 error(s)`.  
Output binary: `Cheat Engine\bin\cheatengine-x86_64.exe`

---

## Step 4 — Gather supporting files

The following files are needed in `Cheat Engine\bin\` for the installer but are **not** in the public CE source. Get them from a CE 7.7 install (run `CheatEngine77P.exe /VERYSILENT /DIR=C:\temp\ce77`):

```powershell
$ce77 = "C:\temp\ce77"
$bin  = "cheat-engine\Cheat Engine\bin"

$files = @(
    'allochook-i386.dll', 'allochook-x86_64.dll',
    'vehdebug-i386.dll', 'vehdebug-x86_64.dll',
    'winhook-i386.dll', 'winhook-x86_64.dll',
    'luaclient-i386.dll', 'luaclient-x86_64.dll',
    'CSCompiler.dll',
    'tcc32-32.dll', 'tcc32-64.dll', 'tcc64-32.dll', 'tcc64-64.dll',
    'dbk64.cepack', 'dbk32.cepack',
    'standalonephase1.cepack', 'standalonephase2.cepack', 'tiny.cepack',
    'DotNetDataCollector32.exe', 'DotNetDataCollector64.exe',
    'Kernelmoduleunloader.exe',
    'Tutorial-i386.cepack', 'Tutorial-x86_64.exe'
)

foreach ($f in $files) {
    $src = Join-Path $ce77 $f
    if (Test-Path $src) { Copy-Item $src $bin -Force }
}
```

### Alternative: Build DBK driver from source

If you don't have a CE 7.7 install you can build `dbk64.sys` yourself:

1. Install Visual Studio 2022 + WDK (Windows Driver Kit)
2. Open `DBKKernel\DBKKernel.sln`
3. Build `Release x64` → produces `dbk64.sys`
4. Build `cepack` (see below), then run:
   ```powershell
   cepack\cepack.exe -c dbk64.sys "Cheat Engine\bin\dbk64.cepack"
   ```

Repeat for `dbk32.sys` (build `Release Win32`).

The other DLLs (allochook, vehdebug, winhook, luaclient, tcc) are built as part of the full CE Patreon source; they are not available from the public repo.

### Building cepack

`cepack` is a small Lazarus tool in the CE source that packs/unpacks `.cepack` files. You need it to produce `dbk64.cepack` from the compiled `dbk64.sys`. Build it once before packing the driver:

```powershell
$lazbuild = "C:\lazarus\lazbuild.exe"
& $lazbuild "Cheat Engine\cepack\cepack.lpr"
# Output: Cheat Engine\cepack\cepack.exe
```

Once built, `cepack -c infile outfile` compresses, `cepack -x infile outfile` extracts.

---

## Step 5 — Build the installer

```powershell
cd "cheat-engine"
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\CE_Frankenstein.iss"
```

Output: `C:\claude\installer_output\CheatEngine_Frankenstein_Setup.exe`

---

## Verifying the build

Open CE, attach to any process, and open the Auto-Assembler (Ctrl+Alt+A). Paste this test script:

```
{$ifdef CPU64}
// 64-bit target confirmed
{$endif}
```

It should assemble without errors. For `HOOK`/`UNHOOK`, use the template in [CHANGES.md](CHANGES.md#1-hookaddress-destination-origcodename).
