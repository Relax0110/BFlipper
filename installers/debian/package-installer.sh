#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
VERSION="${1:?usage: package-installer.sh VERSION OUTPUT_DIR}"
OUTPUT_DIR="${2:?missing output directory}"
ARCH="${3:-all}"
STAGE="$OUTPUT_DIR/stage"

rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/bflipper-installer/patches"
install -m 0755 "$ROOT/installers/debian/install-bflipper" "$STAGE/usr/bin/bflipper-install"
install -m 0644 "$ROOT/bflipper-ble-interval" "$STAGE/usr/share/bflipper-installer/bflipper-ble-interval"
install -m 0644 "$ROOT/bflipper-ble-interval.service" "$STAGE/usr/share/bflipper-installer/bflipper-ble-interval.service"
for patch in "$ROOT"/patches/installer-*.patch; do
  install -m 0644 "$patch" "$STAGE/usr/share/bflipper-installer/patches/"
done
cat > "$STAGE/DEBIAN/control" <<EOF
Package: bflipper-installer
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: BFlipper contributors
Depends: bash, ca-certificates, dpkg, sudo
Description: Installer for the BLE-enabled BFlipper qFlipper build
 Installs a source patch and bootstrap command. The command downloads the
 upstream qFlipper source at install time and builds BFlipper separately.
EOF

mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$STAGE" "$OUTPUT_DIR/bflipper-installer_${VERSION}_${ARCH}.deb"
