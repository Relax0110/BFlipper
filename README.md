# BFlipper

BFlipper is a BLE-enabled build of the qFlipper desktop application. Install the official qFlipper app first. Then run the BFlipper installer for your system to build a separate BFlipper app beside it. The installer leaves the official qFlipper app in place.

The installer package contains only the BFlipper patches and setup scripts. It does not contain qFlipper source code or application binaries. During installation it downloads the pinned public qFlipper source revision, applies the patches, and builds BFlipper on the computer.

## Install

Download the installer from the repository's latest successful **BFlipper installers** workflow run. Expand its artifact ZIP, then:

- **Debian 12 or newer, amd64:** install `bflipper-installer_*_all.deb`, then run `bflipper-install` as your normal user.
- **Debian 12 or newer, ARM64 (including uConsole CM5/Kali):** install `bflipper-installer_*_arm64.deb`, then run `bflipper-install` as your normal user. It builds natively under `~/.local/opt/BFlipper`, selects Qt's software scene graph to avoid llvmpipe CPU saturation, keeps the original frameless style while allowing resizing and half-screen snapping, configures BlueZ for short BLE intervals, and installs a service that requests a 7.5 ms interval for connected Flipper Serial devices.
- **macOS:** install the official qFlipper app, Homebrew, and Apple Command Line Tools first. Open the downloaded DMG and run `Install-BFlipper.command` from Terminal. It installs Homebrew build dependencies and places BFlipper in `~/Applications/BFlipper.app`.
- **Windows 11, x64:** install the official qFlipper app, then run `BFlipper-Setup.exe`. It requests administrator access to install Git, Python, Visual Studio C++ Build Tools, and Qt when needed. It builds BFlipper under `%LOCALAPPDATA%\Programs\BFlipper`.

The first installation downloads qFlipper source and build tools and may take several minutes. An internet connection is required. The ARM64 installer restarts Bluetooth when it applies the BlueZ configuration. The installers are unsigned community tools, so macOS or Windows may show an operating-system warning before running them.

## Connect

On the Flipper Zero, enable **Settings → Bluetooth**. Open BFlipper and choose **Connect over Bluetooth**. Select the Flipper from the scan list. No system-level Bluetooth pairing is needed. DFU recovery remains USB-only.

## Build the installer packages

GitHub Actions packages Debian `.deb` installers for amd64 and ARM64, a macOS `.dmg`, and a Windows `.exe`. These packages contain the patches and bootstrap scripts only. A version tag such as `v1.0.0` publishes the installers as a private GitHub Release.

The BLE patch is based on upstream qFlipper revision `1d26683ff5b751f219a4e40443b7c8355eb39469`. qFlipper is distributed under GPL-3.0; see its upstream source and license before redistributing builds.
