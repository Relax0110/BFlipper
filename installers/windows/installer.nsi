Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"

!ifndef SCRIPTDIR
  !error "SCRIPTDIR is required"
!endif
!ifndef PATCHDIR
  !error "PATCHDIR is required"
!endif
!ifndef OUTFILE
  !define OUTFILE "BFlipper-Setup.exe"
!endif

Name "BFlipper Setup"
OutFile "${OUTFILE}"
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_TEXT "BFlipper setup has finished. If successful, launch BFlipper from the Start menu."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Section "Build and install BFlipper"
  SetOutPath "$PLUGINSDIR\BFlipperSetup"
  File "${SCRIPTDIR}\install.ps1"
  SetOutPath "$PLUGINSDIR\BFlipperSetup\patches"
  File /r "${PATCHDIR}\*.patch"
  DetailPrint "Checking qFlipper and preparing the build environment..."
  nsExec::ExecToLog 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PLUGINSDIR\BFlipperSetup\install.ps1" -PatchDir "$PLUGINSDIR\BFlipperSetup\patches"'
  Pop $0
  ${If} $0 != 0
    MessageBox MB_ICONSTOP "BFlipper setup failed (exit code $0). See the installer details for the error."
    Abort
  ${EndIf}
SectionEnd
