#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REF="1d26683ff5b751f219a4e40443b7c8355eb39469"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PATCH_DIR="$SCRIPT_DIR/patches"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bflipper.XXXXXX")"
DEST="$HOME/Applications/BFlipper.app"
BREW="$(command -v brew || true)"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

if [[ ! -d /Applications/qFlipper.app && ! -d "$HOME/Applications/qFlipper.app" ]]; then
  echo "Install the official qFlipper app first, then run this installer again." >&2
  exit 1
fi
if [[ -z "$BREW" ]]; then
  echo "Homebrew is required to build BFlipper. Install it from https://brew.sh, then rerun this installer." >&2
  exit 1
fi
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Apple Command Line Tools are required. Run 'xcode-select --install', finish its prompt, then rerun this installer." >&2
  exit 1
fi

eval "$($BREW shellenv)"
brew install qt libusb pkgconf

git clone --recurse-submodules https://github.com/flipperdevices/qFlipper.git "$WORK_DIR/source"
git -C "$WORK_DIR/source" checkout "$UPSTREAM_REF"
git -C "$WORK_DIR/source" submodule update --init --recursive
for patch in "$PATCH_DIR"/*.patch; do
  git -C "$WORK_DIR/source" apply --whitespace=nowarn "$patch"
done

python3 -m venv "$WORK_DIR/venv"
"$WORK_DIR/venv/bin/python" -m pip install --upgrade pip dmgbuild
export PATH="$WORK_DIR/venv/bin:$PATH"
cd "$WORK_DIR/source"
./build_mac.sh

mkdir -p "$HOME/Applications"
rm -rf "$DEST"
ditto "$WORK_DIR/source/build_mac/qFlipper.app" "$DEST"
/usr/libexec/PlistBuddy -c 'Set :CFBundleName BFlipper' "$DEST/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName BFlipper' "$DEST/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.bflipper.desktop' "$DEST/Contents/Info.plist"

echo "BFlipper is installed at $DEST. The original qFlipper app remains unchanged."
