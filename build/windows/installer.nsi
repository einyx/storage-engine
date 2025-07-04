; Foundation Storage Engine Windows Installer Script
; Generated by GoReleaser

!define APPNAME "Foundation Storage Engine"
!define COMPANYNAME "Foundation Storage Engine"
!define DESCRIPTION "High-performance S3-compatible proxy with encryption support"
!define VERSIONMAJOR "{{ .Major }}"
!define VERSIONMINOR "{{ .Minor }}"
!define VERSIONBUILD "{{ .Patch }}"
!define HELPURL "https://github.com/{{ .Env.GITHUB_REPOSITORY }}"
!define UPDATEURL "https://github.com/{{ .Env.GITHUB_REPOSITORY }}/releases"
!define ABOUTURL "https://github.com/{{ .Env.GITHUB_REPOSITORY }}"
!define INSTALLSIZE 20480  ; Estimate in KB

RequestExecutionLevel admin
InstallDir "$PROGRAMFILES64\${APPNAME}"
LicenseData "LICENSE"
Name "${APPNAME}"
Icon "icon.ico"
OutFile "{{ .ArtifactName }}"

!include LogicLib.nsh

Page license
Page directory
Page instfiles

!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin"
    messageBox mb_iconstop "Administrator rights required!"
    setErrorLevel 740
    quit
${EndIf}
!macroend

Function .onInit
    setShellVarContext all
    !insertmacro VerifyUserIsAdmin
FunctionEnd

Section "install"
    SetOutPath $INSTDIR

    ; Main executable
    File "foundation-storage-engine.exe"
    File "README.md"
    File "LICENSE"

    ; Example configuration
    SetOutPath "$INSTDIR\config"
    File /nonfatal "config-test.yaml"

    ; Create service wrapper script
    FileOpen $0 "$INSTDIR\install-service.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "echo Installing Foundation Storage Engine as Windows service...$\r$\n"
    FileWrite $0 "sc create "FoundationStorageEngine" binPath= `"$INSTDIR\foundation-storage-engine.exe -config $INSTDIR\config\config.yaml`" DisplayName= `"Foundation Storage Engine Service`" start= auto$\r$\n"
    FileWrite $0 "if %errorlevel% equ 0 ($\r$\n"
    FileWrite $0 "    echo Service installed successfully$\r$\n"
    FileWrite $0 "    echo Use 'sc start "FoundationStorageEngine"' to start the service$\r$\n"
    FileWrite $0 ") else ($\r$\n"
    FileWrite $0 "    echo Failed to install service$\r$\n"
    FileWrite $0 ")$\r$\n"
    FileWrite $0 "pause$\r$\n"
    FileClose $0

    FileOpen $0 "$INSTDIR\uninstall-service.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "echo Stopping and removing Foundation Storage Engine service...$\r$\n"
    FileWrite $0 "sc stop "FoundationStorageEngine"$\r$\n"
    FileWrite $0 "sc delete "FoundationStorageEngine"$\r$\n"
    FileWrite $0 "echo Service removed$\r$\n"
    FileWrite $0 "pause$\r$\n"
    FileClose $0

    ; Write uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Start Menu
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\foundation-storage-engine.exe" "" ""
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Install Service.lnk" "$INSTDIR\install-service.bat" "" ""
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall Service.lnk" "$INSTDIR\uninstall-service.bat" "" ""
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" ""

    ; Registry information for add/remove programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME} - ${DESCRIPTION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$\"$INSTDIR\foundation-storage-engine.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANYNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "HelpLink" "${HELPURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMinor" ${VERSIONMINOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "EstimatedSize" ${INSTALLSIZE}

    ; Add to PATH
    EnVar::SetHKLM
    EnVar::AddValue "PATH" "$INSTDIR"
SectionEnd

Function un.onInit
    SetShellVarContext all
    !insertmacro VerifyUserIsAdmin
FunctionEnd

Section "uninstall"
    ; Stop and remove service if it exists
    ExecWait 'sc stop "FoundationStorageEngine"'
    ExecWait 'sc delete "FoundationStorageEngine"'

    ; Remove from PATH
    EnVar::SetHKLM
    EnVar::DeleteValue "PATH" "$INSTDIR"

    ; Remove Start Menu launcher
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Install Service.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Uninstall Service.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Uninstall.lnk"
    RmDir "$SMPROGRAMS\${APPNAME}"

    ; Remove files
    Delete "$INSTDIR\foundation-storage-engine.exe"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\LICENSE"
    Delete "$INSTDIR\install-service.bat"
    Delete "$INSTDIR\uninstall-service.bat"
    Delete "$INSTDIR\config\config-test.yaml"
    RmDir "$INSTDIR\config"
    Delete "$INSTDIR\uninstall.exe"
    RmDir "$INSTDIR"

    ; Remove uninstaller information from the registry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd
