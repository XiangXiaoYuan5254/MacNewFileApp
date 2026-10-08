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
# 公证凭据：xcrun notarytool store-credentials helloxxy-notary（存在登录钥匙串里）。NOTARIZE=0 跳过公证
NOTARY_PROFILE="${NOTARY_PROFILE:-helloxxy-notary}"
NOTARIZE="${NOTARIZE:-1}"

# notarize <要上传的文件> <贴票据的文件>：交给 Apple 公证（几分钟，期间别让 Mac 锁屏，否则读不到凭据）
notarize() {
    local result
    result="$(xcrun notarytool submit "$1" --keychain-profile "$NOTARY_PROFILE" --wait --output-format json)"
    if [[ "$(plutil -extract status raw -o - - <<<"$result")" != "Accepted" ]]; then
        echo "公证没有通过：$result" >&2
        echo "查看原因：xcrun notarytool log <id> --keychain-profile $NOTARY_PROFILE" >&2
        exit 1
    fi
    xcrun stapler staple -q "$2"
}

"$ROOT_DIR/scripts/build_app.sh" >/dev/null

APP_DIR="$DIST_DIR/$APP_NAME.app"
SIGNED_BY="$(/usr/bin/codesign -dvv "$APP_DIR" 2>&1 | /usr/bin/sed -n 's/^Authority=//p' | /usr/bin/head -n 1)"
if [[ "$SIGNED_BY" != "Developer ID Application:"* ]]; then
    NOTARIZE=0
    echo "提示：$APP_NAME.app 不是 Developer ID 签名，不公证，下载的用户首次打开会被 Gatekeeper 拦下。" >&2
fi
if [[ "$NOTARIZE" == "1" ]]; then
    NOTARY_ZIP="$DIST_DIR/.notarize-$APP_NAME.zip"
    rm -f "$NOTARY_ZIP"
    ditto -c -k --keepParent "$APP_DIR" "$NOTARY_ZIP"
    notarize "$NOTARY_ZIP" "$APP_DIR"
    rm -f "$NOTARY_ZIP"
    # 打包用的 Mac 可能关掉了 Gatekeeper，那样 spctl 什么都放行，所以只认来源是否为已公证的 Developer ID
    spctl -a -vv -t exec "$APP_DIR" 2>&1 | grep -q "source=Notarized Developer ID" || { echo "$APP_DIR 没有公证上" >&2; exit 1; }
fi

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
- 应用已通过 Apple 公证。第一次打开时 macOS 会确认一次“这是从互联网下载的 App”，点“打开”即可。
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

if [[ "$SIGNED_BY" == "Developer ID Application:"* ]]; then
    /usr/bin/codesign --force --sign "$SIGNED_BY" --timestamp "$DMG_PATH"
fi
if [[ "$NOTARIZE" == "1" ]]; then
    notarize "$DMG_PATH" "$DMG_PATH"
fi

echo "$ZIP_PATH"
echo "$DMG_PATH"
