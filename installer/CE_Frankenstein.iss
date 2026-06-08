[Setup]
AppName=Cheat Engine Frankenstein
AppVersion=7.5-FK
AppPublisher=dark_byte (custom build)
DefaultDirName={autopf}\Cheat Engine - Frankenstein
DefaultGroupName=Cheat Engine - Frankenstein
UninstallDisplayName=Cheat Engine Frankenstein
UninstallDisplayIcon={app}\cheatengine-x86_64.exe
OutputDir={#SourcePath}\installer_output
OutputBaseFilename=CheatEngine_Frankenstein_Setup
Compression=lzma2/ultra64
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern
DisableProgramGroupPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"
Name: "fileassoc"; Description: "Associate .CT files with Cheat Engine"; GroupDescription: "File associations:"

[Files]
; Main executable (our custom Frankenstein build)
Source: "Cheat Engine\bin\cheatengine-x86_64.exe"; DestDir: "{app}"; Flags: ignoreversion

; Core DLLs
Source: "Cheat Engine\bin\CED3D10Hook.dll";        DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\CED3D10Hook64.dll";      DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\CED3D11Hook.dll";        DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\CED3D11Hook64.dll";      DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\ced3d9hook.dll";         DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\ced3d9hook64.dll";       DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\d3dhook.dll";            DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\d3dhook64.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\lua53-32.dll";           DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\lua53-64.dll";           DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\libipt-32.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\libipt-64.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\libmikmod32.dll";        DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\libmikmod64.dll";        DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\allochook-i386.dll";     DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\allochook-x86_64.dll";   DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\vehdebug-i386.dll";      DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\vehdebug-x86_64.dll";    DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\winhook-i386.dll";       DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\winhook-x86_64.dll";     DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\luaclient-i386.dll";     DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\luaclient-x86_64.dll";   DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\CSCompiler.dll";         DestDir: "{app}"; Flags: ignoreversion

; TCC compiler DLLs (C code compilation in CE)
Source: "Cheat Engine\bin\tcc32-32.dll";           DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\tcc32-64.dll";           DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\tcc64-32.dll";           DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\tcc64-64.dll";           DestDir: "{app}"; Flags: ignoreversion

; DBK driver files (packed; CE unpacks to .sys on first use)
Source: "Cheat Engine\bin\dbk64.cepack";           DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\dbk32.cepack";           DestDir: "{app}"; Flags: ignoreversion

; Standalone trainer builder
Source: "Cheat Engine\bin\standalonephase1.dat";    DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "Cheat Engine\bin\standalonephase1.cepack"; DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\standalonephase2.cepack"; DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\tiny.dat";               DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "Cheat Engine\bin\tiny.cepack";            DestDir: "{app}"; Flags: ignoreversion

; .NET data collectors
Source: "Cheat Engine\bin\DotNetDataCollector32.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\DotNetDataCollector64.exe"; DestDir: "{app}"; Flags: ignoreversion

; Utilities
Source: "Cheat Engine\bin\Kernelmoduleunloader.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\Tutorial-i386.cepack";   DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\Tutorial-x86_64.exe";    DestDir: "{app}"; Flags: ignoreversion

; Lua and misc
Source: "Cheat Engine\bin\celua.txt";              DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\class.lua";              DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\classwrapper.lua";       DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\defines.lua";            DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\main.lua";               DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\overlay.fx";             DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\commonmodulelist.txt";   DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\donottrace.txt";         DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\vmdisk.img";             DestDir: "{app}"; Flags: ignoreversion
Source: "Cheat Engine\bin\vmdisk.img.sig";         DestDir: "{app}"; Flags: ignoreversion

; clibs
Source: "Cheat Engine\bin\clibs32\lfs.dll"; DestDir: "{app}\clibs32"; Flags: ignoreversion
Source: "Cheat Engine\bin\clibs64\lfs.dll"; DestDir: "{app}\clibs64"; Flags: ignoreversion

; lua_extra
Source: "Cheat Engine\bin\lua_extra\*"; DestDir: "{app}\lua_extra"; Flags: ignoreversion recursesubdirs

; win32/win64 debug helpers
Source: "Cheat Engine\bin\win32\*"; DestDir: "{app}\win32"; Flags: ignoreversion recursesubdirs
Source: "Cheat Engine\bin\win64\*"; DestDir: "{app}\win64"; Flags: ignoreversion recursesubdirs

; C include headers
Source: "Cheat Engine\bin\include\*"; DestDir: "{app}\include"; Flags: ignoreversion recursesubdirs

; autorun scripts
Source: "Cheat Engine\bin\autorun\*"; DestDir: "{app}\autorun"; Flags: ignoreversion recursesubdirs

; Extensions (AITools and others)
Source: "Cheat Engine\bin\Extensions\*"; DestDir: "{app}\Extensions"; Flags: ignoreversion recursesubdirs

; Languages
Source: "Cheat Engine\bin\languages\*"; DestDir: "{app}\languages"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Cheat Engine Frankenstein"; Filename: "{app}\cheatengine-x86_64.exe"
Name: "{group}\Uninstall Cheat Engine Frankenstein"; Filename: "{uninstallexe}"
Name: "{commondesktop}\Cheat Engine Frankenstein"; Filename: "{app}\cheatengine-x86_64.exe"; Tasks: desktopicon

[Registry]
; .CT file association
Root: HKCR; Subkey: ".CT"; ValueType: string; ValueName: ""; ValueData: "CETableFile"; Flags: uninsdeletevalue; Tasks: fileassoc
Root: HKCR; Subkey: "CETableFile"; ValueType: string; ValueName: ""; ValueData: "Cheat Engine Table"; Flags: uninsdeletekey; Tasks: fileassoc
Root: HKCR; Subkey: "CETableFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\cheatengine-x86_64.exe,0"; Tasks: fileassoc
Root: HKCR; Subkey: "CETableFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\cheatengine-x86_64.exe"" ""%1"""; Tasks: fileassoc

[Run]
; Launch CE after install
Filename: "{app}\cheatengine-x86_64.exe"; Description: "Launch Cheat Engine Frankenstein"; Flags: nowait postinstall skipifsilent
