#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
ARCH="$(uname -m)"
APP_NAME="NewFileApp"
DISPLAY_NAME="访达右键新建文件app"
DIST_DIR="$ROOT_DIR/dist"
RELEASE_DIR="$ROOT_DIR/build/release/$APP_NAME-$VERSION-mac-$ARCH"
ZIP_PATH="$DIST_DIR/$APP_NAME-$VERSION-mac-$ARCH.zip"
DMG_PATH="$DIST_DIR/$APP_NAME-$VERSION-mac-$ARCH.dmg"

"$ROOT_DIR/scripts/build_app.sh" >/dev/null

rm -rf "$RELEASE_DIR" "$ZIP_PATH" "$DMG_PATH"
mkdir -p "$RELEASE_DIR"

ditto "$DIST_DIR/$APP_NAME.app" "$RELEASE_DIR/$APP_NAME.app"
ln -s /Applications "$RELEASE_DIR/Applications"

cat > "$RELEASE_DIR/安装说明.txt" <<TEXT
$DISPLAY_NAME

安装：
1. 把 NewFileApp.app 拖到 Applications 文件夹。
2. 打开 Applications 里的 NewFileApp.app。
3. 点击“一键安装/修复”。
4. 在访达文件夹空白处右键，选择“新建文件”。

注意：
- 如果系统设置打开了扩展页面，请启用“新建文件”。
- 如果想让新建文件后自动进入重命名，请在“系统设置 > 隐私与安全性 > 辅助功能”里允许 NewFileApp。
- 如果系统提示无法验证开发者，请在“系统设置 > 隐私与安全性”里允许打开。
TEXT

(
    cd "$DIST_DIR"
    ditto -c -k --sequesterRsrc --keepParent "$RELEASE_DIR" "$ZIP_PATH"
)

hdiutil create \
    -volname "$DISPLAY_NAME" \
    -srcfolder "$RELEASE_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null

echo "$ZIP_PATH"
echo "$DMG_PATH"
