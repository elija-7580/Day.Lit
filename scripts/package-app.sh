#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

swift build -c release
BIN="$(swift build -c release --show-bin-path)/Daylit"
APP="$ROOT/.build/Day.Lit.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>Day.Lit</string>
  <key>CFBundleIdentifier</key>
  <string>app.daylit.mac</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>DayLit</string>
  <key>CFBundleDisplayName</key>
  <string>Day.Lit</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.3.1</string>
  <key>CFBundleVersion</key>
  <string>7</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.utilities</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSSupportsAutomaticTermination</key>
  <false/>
  <key>NSSupportsSuddenTermination</key>
  <false/>
</dict>
</plist>
PLIST

cp "$BIN" "$APP/Contents/MacOS/Day.Lit"
chmod +x "$APP/Contents/MacOS/Day.Lit"
cp "$ROOT/Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/Resources/MenuBarIcon.png" "$APP/Contents/Resources/MenuBarIcon.png"
cp "$ROOT/Resources/MenuBarIcon@2x.png" "$APP/Contents/Resources/MenuBarIcon@2x.png"

# Ad-hoc sign so Launch Services / Gatekeeper accept local open
codesign --force --deep --sign - "$APP"
# Install into Applications for a stable path
rm -rf "/Applications/Day.Lit.app"
cp -R "$APP" "/Applications/Day.Lit.app"
codesign --force --deep --sign - "/Applications/Day.Lit.app"
xattr -c "/Applications/Day.Lit.app" || true

# Refresh icon cache for this bundle
touch "/Applications/Day.Lit.app"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/Day.Lit.app" || true

echo "Built $APP"
echo "Installed /Applications/Day.Lit.app"
