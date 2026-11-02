# BFlipper installation guide

BFlipper is a BLE-enabled build of qFlipper. It is built on your computer from a pinned qFlipper source revision, so the installer downloads source code and build tools the first time it runs. You need an internet connection. BFlipper installs separately and leaves the official qFlipper app in place.

## 1. Download an installer

Open the [BFlipper installers workflow](https://github.com/Relax0110/BFlipper/actions/workflows/release.yml). If the repository is private, sign in to an account that has read access. Once the repository is public, no GitHub sign-in is needed.

1. Open the latest successful run for the `main` branch.
2. Scroll to **Artifacts**.
3. Download the artifact for your system:
   - **Debian:** `BFlipper-Debian12-Installer`
   - **macOS:** `BFlipper-macOS-Installer`
   - **Windows:** `BFlipper-Windows11-Installer`
4. Extract the downloaded ZIP. The installer file is inside it.

While the repository is private, Actions artifacts and releases are limited to people with repository access. Once public, anyone can download them. For a tagged version, the same installers are attached as direct downloads on the [Releases page](https://github.com/Relax0110/BFlipper/releases).

## 2. Install

### Debian 12 or newer: amd64 or ARM64

Supported architectures are x86_64 (amd64) and aarch64 (ARM64). The ARM64 package is intended for devices such as the uConsole CM5.

1. Install the official qFlipper app first.
2. Extract the Debian artifact ZIP.
3. Open a terminal in the extracted folder and install the package:
   - amd64: `sudo apt install ./bflipper-installer_*_all.deb`
   - ARM64: `sudo apt install ./bflipper-installer_*_arm64.deb`
4. Run `bflipper-install` as your normal user. It will ask for sudo when it installs system build dependencies. Do not run the command with `sudo`, so the app is installed into your own home directory.
5. When it finishes, launch BFlipper from the app menu or run `~/.local/bin/bflipper`.

The first build installs required Debian packages, downloads qFlipper source, and compiles BFlipper. It can take several minutes. The app is installed under `~/.local/opt/BFlipper`.

### Windows 11: x64

1. Install the official qFlipper app.
2. Make sure **App Installer** (which provides `winget`) is installed and up to date. It is available from the Microsoft Store.
3. Extract the Windows artifact ZIP.
4. Run `BFlipper-Setup.exe` and approve the administrator prompt.
5. Leave the installer running while it installs any missing build tools and builds BFlipper. This can take a while; keep the computer connected to the internet.
6. Start BFlipper from the Start menu.

Setup uses `winget` to install missing Git, Visual Studio C++ Build Tools, and Python 3.12, then downloads Qt and builds the app. BFlipper is installed under `%LOCALAPPDATA%\\Programs\\BFlipper`; its build files are under `%LOCALAPPDATA%\\BFlipper-Setup`. The official qFlipper app remains installed separately.

### macOS

1. Install the official qFlipper app.
2. Install [Homebrew](https://brew.sh) and Apple Command Line Tools. If the command line tools are not installed, open Terminal and run `xcode-select --install`, then finish the dialog.
3. Download and open the macOS artifact ZIP, then open the included `BFlipper-Installer-macOS.dmg`.
4. In the mounted installer window, run `Install-BFlipper.command` from Terminal. The script installs the Homebrew build dependencies and builds the app; keep the Mac connected to the internet.
5. Launch BFlipper from `~/Applications/BFlipper.app`.

The first build takes several minutes and may take longer on older Macs. If macOS asks whether to open the community installer, confirm that you downloaded it from this repository before allowing it to run.

## 3. Connect to a Flipper

1. On the Flipper Zero, turn on **Settings → Bluetooth**.
2. Open BFlipper and choose **Connect over Bluetooth**.
3. Select the Flipper from the scan list.

No system-level Bluetooth pairing is required. Screen control and normal RPC features work over BLE. DFU recovery and firmware recovery still require USB.

## Troubleshooting

- **The installer artifact is missing:** Open the workflow run and check that it completed successfully. A failed or still-running run does not publish its installer artifacts.
- **GitHub says you do not have access:** This repository is private. Sign in with an account that has repository access. For a tagged release, use the Releases page with the same account.
- **Windows says `winget` is not found:** Install or update **App Installer** from the Microsoft Store, restart Windows, and run setup again.
- **Windows setup says qFlipper is missing:** Install the official qFlipper app, then run `BFlipper-Setup.exe` again.
- **A source download or build fails:** Check the internet connection and free disk space, then rerun the installer. On Debian, run `bflipper-install` again. On Windows, rerun `BFlipper-Setup.exe`. On macOS, rerun `Install-BFlipper.command`.
- **Bluetooth scanning finds no device:** Turn on Bluetooth in the Flipper's settings, keep it near the computer, and start a new scan in BFlipper.

## Build and release details

The installers contain setup scripts and BFlipper patches, not prebuilt application binaries. The workflow builds the installers for Debian amd64 and ARM64, macOS, and Windows x64. The Windows and macOS installers are unsigned community tools, so those operating systems may show a security warning; only run files downloaded from the official BFlipper repository. Pushing a version tag such as `v1.0.0` creates a GitHub Release with direct installer downloads.

BFlipper patches and installer scripts are distributed under GPL-3.0; see [LICENSE](LICENSE). The BLE patch is based on qFlipper revision `1d26683ff5b751f219a4e40443b7c8355eb39469`. qFlipper is also distributed under GPL-3.0; see the [upstream qFlipper repository](https://github.com/flipperdevices/qFlipper).
