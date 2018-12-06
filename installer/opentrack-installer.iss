; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#include "../build-clion-msvc-dev/opentrack-version.h"
#define MyAppName "opentrack"
#define MyAppVersion OPENTRACK_VERSION
#define MyAppPublisher "opentrack"
#define MyAppURL "http://github.com/opentrack/opentrack"
#define MyAppExeName "opentrack.exe"

#include "non-ui-blocking-exec.iss"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{63F53541-A29E-4B53-825A-9B6F876A2BD6}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputBaseFilename={#MyAppVersion}-win32-setup
SetupIconFile=..\variant\default\opentrack.ico
Compression=lzma2/ultra64
SolidCompression=yes
DisableWelcomePage=True
DisableReadyPage=True
DisableReadyMemo=True
RestartIfNeededByRun=False
InternalCompressLevel=ultra
CompressionThreads=4
LZMANumFastBytes=273
MinVersion=0,5.01sp2

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build-clion-msvc-dev\install\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "timeout.exe"; Parameters: "/t 0"; Flags: runhidden; StatusMsg: Installing RealSense Runtime. This may take several minutes.; Check: RSCameraDriverDetectedAndEulaAccepted
Filename: "{app}\{#MyAppExeName}"; Flags: nowait postinstall skipifsilent; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; 

[Code]
var
  EulaAccepted:Boolean;
  RSCameraDriverDetected:Boolean;
  EULAPage: TOutputMsgMemoWizardPage;
  EULAAcceptRadioButton: TNewRadioButton;
  EULARefuseRadioButton: TNewRadioButton;

function IsRSCameraDriverPresent():Boolean;
var
    Version:String;
begin
      result := RegQueryStringValue(HKEY_LOCAL_MACHINE, 'Software\Intel\RSSDK\Components\ivcam',
     'Version', Version) or RegQueryStringValue(HKEY_LOCAL_MACHINE, 'Software\Wow6432Node\Intel\RSDCM\SR300',
     'Version', Version)
end;

procedure EULAAcceptRefuseButtonStateUpdated(Sender: TObject);
begin
  EulaAccepted := EULAAcceptRadioButton.Checked
end;


function RSCameraDriverDetectedAndEulaAccepted():Boolean;
begin
result := RSCameraDriverDetected and EulaAccepted;
end;

procedure DoPostInstall();
var
  Version: String;               
  ExecInfo: TShellExecuteInfo;
begin
if RSCameraDriverDetectedAndEulaAccepted then
  begin
    NonUiBlockingExec(ExpandConstant('{app}\doc\contrib\intel_rs_sdk_runtime_websetup_10.0.26.0396.exe'), 
    '--silent --no-progress --acceptlicense=yes --front --finstall=core,face3d --fnone=all');
  end
end;

procedure CurStepChanged(CurStep: TSetupStep);
 begin
 if CurStep = ssPostInstall then
 begin
   DoPostInstall()
 end
end;

procedure InitializeWizard();
var
  EULAText: AnsiString;
begin

EulaAccepted := false
RSCameraDriverDetected := IsRSCameraDriverPresent()

if RSCameraDriverDetected then
  begin
  ExtractTemporaryFile('RS_EULA.rtf');
    if LoadStringFromFile(ExpandConstant('{tmp}\RS_EULA.rtf'), EULAText) then
    begin
    EULAPage := CreateOutputMsgMemoPage(wpLicense,
      'Information', 'Intel RealSense End-User License agreement',
      'Opentrack may use the Intel RealSense SDK Runtime on your compatible system. To get it installed, please accept its EULA:',
      EULAText); 
      EULAPage.RichEditViewer.Height := ScaleY(148);
      EULAAcceptRadioButton := TNewRadioButton.Create(EULAPage);
      EULAAcceptRadioButton.Left := EULAPage.RichEditViewer.Left;
      EULAAcceptRadioButton.Top := EULAPage.Surface.ClientHeight - ScaleY(41);
      EULAAcceptRadioButton.Width := EULAPage.RichEditViewer.Width;
      EULAAcceptRadioButton.Parent := EULAPage.Surface;
      EULAAcceptRadioButton.Caption := SetupMessage(msgLicenseAccepted);
      EULARefuseRadioButton := TNewRadioButton.Create(EULAPage);
      EULARefuseRadioButton.Left := EULAPage.RichEditViewer.Left;
      EULARefuseRadioButton.Top := EULAPage.Surface.ClientHeight - ScaleY(21);
      EULARefuseRadioButton.Width := EULAPage.RichEditViewer.Width;
      EULARefuseRadioButton.Parent := EULAPage.Surface;
      EULARefuseRadioButton.Caption := SetupMessage(msgLicenseNotAccepted);

      // Set the states and event handlers
      EULAAcceptRadioButton.OnClick := @EULAAcceptRefuseButtonStateUpdated;
      EULARefuseRadioButton.OnClick := @EULAAcceptRefuseButtonStateUpdated;
      EULARefuseRadioButton.Checked := true;
      EulaAccepted := EULAAcceptRadioButton.Checked
    //TODO: if camera is detected, activate RS EULA page and RSSDK install, save if it was accepted or not. 
    end
  end
end;
