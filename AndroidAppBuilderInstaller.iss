#define MyAppName "Android App Builder"
#define MyAppVersion "1.0"
#define MyAppPublisher "Craig Doughty"
#define MyAppExeName "AndroidAppBuilder.exe"

[Setup]
AppId={{8F1B0C6B-6C0D-4B5E-9C5F-6B3A1A4B91A1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName=Android App Builder 1.0
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\Android App Builder
DefaultGroupName=Android App Builder

OutputDir=Output
OutputBaseFilename=AndroidAppBuilderSetup-v{#MyAppVersion}

Compression=lzma
SolidCompression=yes
WizardStyle=modern

PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible

UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile="D:\Users\Craig\Visual Studio\Android-App-Builder\appicon.ico"
WizardImageFile="D:\Users\Craig\Visual Studio\Android-App-Builder\installer-large.bmp"
LicenseFile="D:\Users\Craig\Visual Studio\Android-App-Builder\license.txt"
DisableProgramGroupPage=yes

VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=Android App Builder Installer
VersionInfoTextVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "*"; DestDir: "{app}"; Excludes: "*.iss,Output\*"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Android App Builder"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Android App Builder"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\Uninstall Android App Builder"; Filename: "{uninstallexe}"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"

[Run]
Filename: "{app}\{#MyAppExeName}"; Flags: nowait

[Messages]
english.SetupWindowTitle=Setup - Android App Builder 1.0

[Code]
function GetUninstallString(): String;
var
  S: String;
begin
  if RegQueryStringValue(HKLM,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\{8F1B0C6B-6C0D-4B5E-9C5F-6B3A1A4B91A1}_is1',
    'UninstallString', S) then
    Result := S
  else
    Result := '';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  UninstallString: String;
  ResultCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    UninstallString := GetUninstallString();
    if UninstallString <> '' then
    begin
      Exec(RemoveQuotes(UninstallString), '/SILENT', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
  end;
end;