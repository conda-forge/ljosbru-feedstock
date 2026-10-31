#!/usr/bin/env bash
set -euxo pipefail

# Mirrors upstream's scripts/macos/bundle-app.sh: the GUI has to run from an
# app bundle so that macOS attributes the Screen Recording and Accessibility
# permissions to ljosbru instead of the terminal it was started from.
cargo auditable install --locked --no-track --bin ljosbru-gui --features gui --root "${SRC_DIR}/gui-install" --path .
cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml

app="${PREFIX}/Applications/ljosbru.app"
mkdir -p "${app}/Contents/MacOS"
cp "${SRC_DIR}/gui-install/bin/ljosbru-gui" "${app}/Contents/MacOS/ljosbru-gui"

cat > "${app}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>ljosbru-gui</string>
  <key>CFBundleIdentifier</key>
  <string>io.github.pavelzw.ljosbru</string>
  <key>CFBundleName</key>
  <string>ljosbru</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${PKG_VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${PKG_VERSION}</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

/usr/bin/codesign --force --sign - --identifier io.github.pavelzw.ljosbru "${app}"
/usr/bin/codesign --verify --strict "${app}"

mkdir -p "${PREFIX}/Menu"
cp "${RECIPE_DIR}/Menu/ljosbru.json" "${PREFIX}/Menu/ljosbru.json"
