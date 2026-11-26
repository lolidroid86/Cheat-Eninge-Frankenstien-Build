; Cheat Engine Frankenstein - rebuilt 2026-11-26 on the CE 7.7.3 (Patreon, build 10970) support files.
; Main exe = our custom 7.5 source build (HOOK/UNHOOK, {$ifdef}/{$else}/{$endif}, AOBSCANFUNCTION backports).
; Everything else comes from the staging folder "stage\" next to this script:
;   7.7.3 install tree (minus its own main exes/launcher/uninstaller) + AITools from git + ceserver773 + lua_extra.
; The stage folder and the resulting installer contain CE 7.7.x binaries: build them yourself, do not redistribute them.

[Setup]
AppName=Cheat Engine Frankenstein
AppVersion=7.5-FK (7.7.3 support files)
AppPublisher=dark_byte (custom build)
DefaultDirName={autopf}\Cheat Engine - Frankenstein
DefaultGroupName=Cheat Engine - Frankenstein
UninstallDisplayName=Cheat Engine Frankenstein
UninstallDisplayIcon={app}\cheatengine-x86_64.exe
OutputDir={#SourcePath}\installer_output
OutputBaseFilename=CheatEngine_Frankenstein_773_Setup
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
Source: "stage\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

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
Filename: "{app}\cheatengine-x86_64.exe"; Description: "Launch Cheat Engine Frankenstein"; Flags: nowait postinstall skipifsilent
