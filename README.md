# BFlipper

BFlipper is a BLE-enabled build of the qFlipper desktop application. It installs separately and leaves the official qFlipper app in place.

## Quick install

1. Sign in to GitHub with an account that can read this repository.
2. Open the [BFlipper installers workflow](https://github.com/Relax0110/BFlipper/actions/workflows/release.yml).
3. Open the latest successful run on `main`, then download the artifact for your platform:
   - Debian: `BFlipper-Debian12-Installer`
   - macOS: `BFlipper-macOS-Installer`
   - Windows: `BFlipper-Windows11-Installer`
4. Extract the downloaded ZIP and follow the steps in the **[complete installation guide](INSTALL.md)**.

The installers build BFlipper on your computer from pinned qFlipper source. The first install downloads source code and build tools, so keep an internet connection available. The Windows installer is for Windows 11 x64 and requires App Installer (`winget`); it installs missing build tools and asks for administrator approval. The Debian installer supports amd64 and ARM64, including uConsole CM5/Kali. macOS requires Homebrew and Apple Command Line Tools.

## Downloads and access

This repository is private, so users need repository access to download Actions artifacts or GitHub Releases. A tagged version such as `v1.0.0` publishes direct installer downloads on the [Releases page](https://github.com/Relax0110/BFlipper/releases). The latest successful workflow run provides the newest installer artifacts before a versioned release is published.

## Connect

On the Flipper Zero, enable **Settings → Bluetooth**. Open BFlipper, choose **Connect over Bluetooth**, and select the Flipper from the scan list. No system-level Bluetooth pairing is required. DFU recovery remains USB-only.

## Build and license

GitHub Actions packages Debian installers for amd64 and ARM64, a macOS DMG, and a Windows setup EXE. The installer packages contain BFlipper patches and setup scripts, not prebuilt qFlipper application binaries.

The BLE patch is based on upstream qFlipper revision `1d26683ff5b751f219a4e40443b7c8355eb39469`. qFlipper is distributed under GPL-3.0; see the [upstream qFlipper repository](https://github.com/flipperdevices/qFlipper) and its license before redistributing builds.
