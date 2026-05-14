#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/manual"
APP_DIR="$ROOT_DIR/dist/NewFileApp.app"
EXT_DIR="$APP_DIR/Contents/PlugIns/NewFileFinderExtension.appex"
VERSION="${VERSION:-1.0.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

rm -rf "$BUILD_DIR" "$APP_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/PlugIns"
mkdir -p "$EXT_DIR/Contents/MacOS"

swiftc \
  -target arm64-apple-macosx13.0 \
  -O \
  -module-name NewFileApp \
  "$ROOT_DIR/NewFileApp/NewFileAppApp.swift" \
  "$ROOT_DIR/NewFileApp/AppDelegate.swift" \
  "$ROOT_DIR/NewFileApp/ContentView.swift" \
  "$ROOT_DIR/NewFileApp/FileCreator.swift" \
  -o "$APP_DIR/Contents/MacOS/NewFileApp"

swiftc \
  -target arm64-apple-macosx13.0 \
  -O \
  -module-name NewFileFinderExtension \
  -emit-executable \
  "$ROOT_DIR/NewFileFinderExtension/FileTemplate.swift" \
  "$ROOT_DIR/NewFileFinderExtension/FinderSync.swift" \
  -Xlinker -e \
  -Xlinker _NSExtensionMain \
  -o "$EXT_DIR/Contents/MacOS/NewFileFinderExtension"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleExecutable</key>
	<string>NewFileApp</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.NewFileApp</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>NewFileApp</string>
	<key>CFBundleDisplayName</key>
	<string>访达右键新建文件</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>__VERSION__</string>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>com.local.NewFileApp</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>newfileapp</string>
			</array>
		</dict>
	</array>
	<key>CFBundleVersion</key>
	<string>__BUILD_NUMBER__</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2026 xxy. All rights reserved.</string>
	<key>NSSupportsAutomaticTermination</key>
	<true/>
	<key>NSSupportsSuddenTermination</key>
	<true/>
</dict>
</plist>
PLIST

cat > "$EXT_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleDisplayName</key>
	<string>新建文件</string>
	<key>CFBundleExecutable</key>
	<string>NewFileFinderExtension</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.NewFileApp.FinderExtension</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>NewFileFinderExtension</string>
	<key>CFBundlePackageType</key>
	<string>XPC!</string>
	<key>CFBundleShortVersionString</key>
	<string>__VERSION__</string>
	<key>CFBundleVersion</key>
	<string>__BUILD_NUMBER__</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>LSUIElement</key>
	<true/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionAttributes</key>
		<dict/>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.FinderSync</string>
		<key>NSExtensionPrincipalClass</key>
		<string>FinderSync</string>
	</dict>
</dict>
</plist>
PLIST

/usr/bin/sed -i '' \
  -e "s/__VERSION__/$VERSION/g" \
  -e "s/__BUILD_NUMBER__/$BUILD_NUMBER/g" \
  "$APP_DIR/Contents/Info.plist" \
  "$EXT_DIR/Contents/Info.plist"

if [[ "$SIGN_IDENTITY" == "-" ]]; then
  /usr/bin/codesign --force --sign "$SIGN_IDENTITY" --timestamp=none --entitlements "$ROOT_DIR/NewFileFinderExtension/NewFileFinderExtension.entitlements" "$EXT_DIR"
  /usr/bin/codesign --force --sign "$SIGN_IDENTITY" --timestamp=none --entitlements "$ROOT_DIR/NewFileApp/NewFileApp.entitlements" "$APP_DIR"
else
  /usr/bin/codesign --force --sign "$SIGN_IDENTITY" --options runtime --timestamp --entitlements "$ROOT_DIR/NewFileFinderExtension/NewFileFinderExtension.entitlements" "$EXT_DIR"
  /usr/bin/codesign --force --sign "$SIGN_IDENTITY" --options runtime --timestamp --entitlements "$ROOT_DIR/NewFileApp/NewFileApp.entitlements" "$APP_DIR"
fi

echo "$APP_DIR"
