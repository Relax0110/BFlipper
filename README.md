# BFlipper

BFlipper is a BLE-enabled build of the qFlipper desktop application. It installs separately and leaves the official qFlipper app in place.

## Download and install

For the latest build, open the [BFlipper installers workflow](https://github.com/Relax0110/BFlipper/actions/workflows/release.yml). Choose the latest successful run on `main`, open **Artifacts**, and download the ZIP for your platform:

- **Debian 12 or newer:** `BFlipper-Debian12-Installer`
- **macOS:** `BFlipper-macOS-Installer`
- **Windows 11, x64:** `BFlipper-Windows11-Installer`

Extract the ZIP, then follow the **[complete installation guide](INSTALL.md)**. The Windows ZIP contains `BFlipper-Setup.exe`.

For a versioned release, use the direct downloads on the [Releases page](https://github.com/Relax0110/BFlipper/releases). Each tagged release includes the Debian amd64 and ARM64 packages, the macOS DMG, and the Windows setup EXE.

The installers build BFlipper on your computer from pinned qFlipper source. The first install downloads source code and build tools, so keep an internet connection available. Windows requires App Installer (`winget`) and administrator approval. Debian supports amd64 and ARM64, including uConsole CM5/Kali. macOS requires Homebrew and Apple Command Line Tools.

## Connect

On the Flipper Zero, enable **Settings → Bluetooth**. Open BFlipper, choose **Connect over Bluetooth**, and select the Flipper from the scan list. No system-level Bluetooth pairing is required. DFU recovery remains USB-only.

## Build and license

The installer packages contain BFlipper patches and setup scripts, not prebuilt qFlipper application binaries.

BFlipper patches and installer scripts are distributed under GPL-3.0; see [LICENSE](LICENSE). The BLE patch is based on upstream qFlipper revision `1d26683ff5b751f219a4e40443b7c8355eb39469`. qFlipper is also distributed under GPL-3.0; see the [upstream qFlipper repository](https://github.com/flipperdevices/qFlipper).
