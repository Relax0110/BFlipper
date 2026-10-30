param(
  [Parameter(Mandatory = $true)][string]$PatchDir
)

$ErrorActionPreference = 'Stop'
$UpstreamRef = '1d26683ff5b751f219a4e40443b7c8355eb39469'
$Root = Join-Path $env:LOCALAPPDATA 'BFlipper-Setup'
$Source = Join-Path $Root 'source'
$QtRoot = Join-Path $Root 'Qt'
$InstallDir = Join-Path $env:LOCALAPPDATA 'Programs\BFlipper'

function Find-OfficialQFlipper {
  $candidates = @(
    (Join-Path $env:ProgramFiles 'qFlipper\qFlipper.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'qFlipper\qFlipper.exe'),
    (Join-Path $env:LOCALAPPDATA 'Programs\qFlipper\qFlipper.exe'),
    (Join-Path $env:LOCALAPPDATA 'qFlipper\qFlipper.exe')
  )
  return $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not (Find-OfficialQFlipper)) {
  throw 'Install the official qFlipper app first, then run this installer again.'
}

$Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if (-not $Winget) {
  throw 'Windows Package Manager (winget) is required to install the build tools. Install App Installer from the Microsoft Store, then rerun BFlipper Setup.'
}

function Install-WingetPackage([string]$Id, [string]$Override = '') {
  $args = @('install', '--id', $Id, '--exact', '--source', 'winget', '--silent', '--accept-package-agreements', '--accept-source-agreements')
  if ($Override) { $args += @('--override', $Override) }
  & $Winget.Source @args
  if ($LASTEXITCODE -ne 0) { throw "Could not install prerequisite $Id using winget." }
}

$Git = Get-Command git.exe -ErrorAction SilentlyContinue
if (-not $Git) {
  Install-WingetPackage 'Git.Git'
  $Git = Get-Command git.exe -ErrorAction SilentlyContinue
  if (-not $Git -and (Test-Path "$env:ProgramFiles\Git\cmd\git.exe")) { $Git = Get-Item "$env:ProgramFiles\Git\cmd\git.exe" }
}
if (-not $Git) { throw 'Git installation did not complete. Restart Windows and run this installer again.' }

$VsWhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$VsPath = if (Test-Path $VsWhere) { & $VsWhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath } else { '' }
if (-not $VsPath) {
  Install-WingetPackage 'Microsoft.VisualStudio.2022.BuildTools' '--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'
  $VsPath = if (Test-Path $VsWhere) { & $VsWhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath } else { '' }
}
if (-not $VsPath) { throw 'Visual Studio C++ Build Tools were not found after installation.' }

$Python = Get-Command py.exe -ErrorAction SilentlyContinue
if (-not $Python) {
  Install-WingetPackage 'Python.Python.3.12'
  $Python = Get-Command py.exe -ErrorAction SilentlyContinue
  if (-not $Python -and (Test-Path "$env:LOCALAPPDATA\Programs\Python\Launcher\py.exe")) { $Python = Get-Item "$env:LOCALAPPDATA\Programs\Python\Launcher\py.exe" }
}
if (-not $Python) { throw 'Python 3.12 launcher was not found after installation.' }

$QtKit = Join-Path $QtRoot '6.8.3\msvc2022_64'
$QMake = Join-Path $QtKit 'bin\qmake.exe'
if (-not (Test-Path $QMake)) {
  & $Python.Source -3.12 -m pip install --user aqtinstall
  if ($LASTEXITCODE -ne 0) { throw 'Could not install the Qt download helper.' }
  & $Python.Source -3.12 -m aqt install-qt windows desktop 6.8.3 win64_msvc2022_64 --modules qtconnectivity qt5compat qtserialport --outputdir $QtRoot
  if ($LASTEXITCODE -ne 0) { throw 'Could not download the Qt modules required by BFlipper.' }
}

$VcVars = Join-Path $VsPath 'VC\Auxiliary\Build\vcvars64.bat'
if (-not (Test-Path $VcVars)) { throw 'Visual Studio x64 build environment was not found.' }
New-Item -ItemType Directory -Force $Root | Out-Null
$EnvBatch = Join-Path $Root 'load-vs-env.cmd'
@("@echo off", "call `"$VcVars`"", 'set') | Set-Content -Encoding ASCII $EnvBatch
$VsEnvironment = & cmd.exe /q /c ('"{0}"' -f $EnvBatch)
foreach ($Line in $VsEnvironment) {
  if ($Line -match '^([^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process') }
}
$env:PATH = "$(Join-Path $QtKit 'bin');$env:PATH"

Remove-Item $Source -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Root | Out-Null
& $Git.Source clone --recurse-submodules https://github.com/flipperdevices/qFlipper.git $Source
if ($LASTEXITCODE -ne 0) { throw 'Could not download qFlipper source.' }
& $Git.Source -C $Source checkout $UpstreamRef
if ($LASTEXITCODE -ne 0) { throw 'Could not select the supported qFlipper source revision.' }
& $Git.Source -C $Source submodule update --init --recursive
if ($LASTEXITCODE -ne 0) { throw 'Could not download qFlipper source dependencies.' }
Get-ChildItem (Join-Path $PatchDir '*.patch') | Sort-Object Name | ForEach-Object {
  & $Git.Source -C $Source apply --whitespace=nowarn $_.FullName
  if ($LASTEXITCODE -ne 0) { throw "Could not apply BLE patch $($_.Name)." }
}

$Build = Join-Path $Source 'build'
New-Item -ItemType Directory -Force $Build | Out-Null
Push-Location $Build
try {
  & $QMake ../qFlipper.pro -spec win32-msvc 'CONFIG+=release qtquickcompiler' 'DEFINES+=DISABLE_APPLICATION_UPDATES'
  if ($LASTEXITCODE -ne 0) { throw 'qmake configuration failed.' }
  & nmake qmake_all
  if ($LASTEXITCODE -ne 0) { throw 'qmake_all failed.' }
  & nmake
  if ($LASTEXITCODE -ne 0) { throw 'qFlipper build failed.' }
  & nmake install
  if ($LASTEXITCODE -ne 0) { throw 'qFlipper install step failed.' }
} finally { Pop-Location }

$BuiltApp = Join-Path $Build 'qFlipper'
$WinDeploy = Join-Path $QtKit 'bin\windeployqt.exe'
& $WinDeploy --release --compiler-runtime --qmldir (Join-Path $Source 'application') (Join-Path $BuiltApp 'qFlipper.exe')
if ($LASTEXITCODE -ne 0) { throw 'Qt runtime deployment failed.' }
$ProtoPlugin = Join-Path $Build 'plugins\flipperproto0.dll'
if (Test-Path $ProtoPlugin) {
  $PluginDir = Join-Path $BuiltApp 'plugins\flipperproto0'
  New-Item -ItemType Directory -Force $PluginDir | Out-Null
  Copy-Item $ProtoPlugin $PluginDir
  & $WinDeploy --release --compiler-runtime --dir $BuiltApp $ProtoPlugin
  if ($LASTEXITCODE -ne 0) { throw 'Protocol plugin runtime deployment failed.' }
}

Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force (Split-Path $InstallDir) | Out-Null
Copy-Item $BuiltApp $InstallDir -Recurse
$Shortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\BFlipper.lnk'
$Shell = New-Object -ComObject WScript.Shell
$Link = $Shell.CreateShortcut($Shortcut)
$Link.TargetPath = Join-Path $InstallDir 'qFlipper.exe'
$Link.WorkingDirectory = $InstallDir
$Link.Save()

Write-Host "BFlipper is installed at $InstallDir. The original qFlipper app remains unchanged."
