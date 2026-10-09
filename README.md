# NewFileApp

一个 macOS Finder 右键“新建文件”工具。安装后，在访达任意文件夹空白处右键，可以通过 **新建文件** 子菜单创建常见文件。

## 功能

- Finder 右键菜单中显示 **新建文件** 父项
- 支持 `txt`、`md`、`rtf`、`csv`、`json`、`html`、`css`、`docx`、`pdf`、`pptx`、`xlsx`、`js`、`py`、`swift`、`sh`
- Word、PDF、PowerPoint、Excel 使用可识别的空白模板，不是简单改后缀
- 支持右键 **新建空白文件夹**，右键文件夹时会在该文件夹内创建
- 自动处理重名文件，例如 `新建文本文档 2.txt`
- 创建后自动在 Finder 中选中新文件
- 支持右键 **剪切** 和 **粘贴到此处**，可以移动文件和文件夹
- 支持右键 **移到废纸篓**，不会永久删除
- 支持右键 **拷贝路径**，选中文件复制文件路径，选中文件夹复制文件夹路径
- 支持右键 **打开终端**，自动进入当前目录
- 右键创建时后台执行，不弹出主窗口
- 自动检查更新：有新版本时右键菜单会出现 **有新版本 vX 可用**，主窗口也可以手动 **检查更新**

## 用户安装

推荐从官网 <https://helloxxy.com/works/newfileapp/> 下载 `.dmg`（也可以在 GitHub Releases 下载）：

1. 打开 `.dmg`
2. 把 `NewFileApp.app` 拖到 `Applications`
3. 打开 `Applications/NewFileApp.app`
4. 点击 **一键安装/修复**
5. 如果系统设置打开了扩展页面，请启用 **新建文件**
6. 在 Finder 文件夹空白处右键，选择 **新建文件**

macOS 不允许第三方 App 完全静默启用 Finder 扩展，所以“系统设置里启用扩展”这一步可能需要手动点一次。

## 首次打开

Release 里的安装包使用 Apple Developer ID 签名，并已通过 Apple 公证，可以直接打开。第一次打开时 macOS 会确认一次“这是从互联网下载的 App”，点 **打开** 即可。

## 开发打包

本项目可以不用完整 Xcode，直接用 Swift 编译器打包：

```bash
scripts/build_app.sh
```

生成：

```text
dist/NewFileApp.app
```

本地安装测试：

```bash
rm -rf /Applications/NewFileApp.app
ditto dist/NewFileApp.app /Applications/NewFileApp.app
open /Applications/NewFileApp.app
```

## 生成 GitHub Release 文件

```bash
VERSION=1.0.0 scripts/package_release.sh
```

生成：

```text
dist/NewFileApp-1.0.0-mac-<arch>.zip
dist/NewFileApp-1.0.0-mac-<arch>.dmg
```

DMG 打开后是一个带箭头的窗口，提示把 App 拖进「应用程序」，和页间的安装包一样（布局见 `scripts/dmg/`）；它用 [dmgbuild](https://github.com/dmgbuild/dmgbuild) 生成，需要先 `brew install uv`。

把 `.dmg` 上传到 GitHub Releases，普通用户下载后按“用户安装”步骤操作即可。

Release 的 tag 要写成 `v<版本号>`，例如 `v1.0.14`，并且和打包时的 `VERSION` 一致。1.0.14 及更早的版本通过 GitHub 最新一个正式 Release（不含草稿和预发布）的 tag 判断是否有新版本，所以每次发版仍要发布 GitHub Release。同时要更新官网上的安装包和 `latest.json`，新版本从那里检查更新。

## 检查更新

App 读取官网上的 <https://helloxxy.com/works/newfileapp/downloads/latest.json>，只读取其中的版本号，不上传任何数据：

```json
{ "version": "1.0.15", "file": "NewFileApp-1.0.15-mac-arm64.dmg", "size": 2212982, "date": "2026-09-28" }
```

- Finder 扩展每天最多检查一次，失败后一小时再试；发现新版本时在右键菜单末尾显示 **有新版本 vX 可用**，点击打开官网下载
- 每次打开主窗口时检查一次，也可以点 **检查更新** 手动检查

检查逻辑在 `Shared/UpdateChecker.swift`，主 App 和 Finder 扩展共用。

## 签名

打包脚本默认用钥匙串里的 Developer ID 证书签名并开启 hardened runtime，`package_release.sh` 再把 App 和 DMG 交给 Apple 公证、贴上票据（几分钟，期间别让 Mac 锁屏）。公证用登录钥匙串里名为 `helloxxy-notary` 的凭据（`xcrun notarytool store-credentials` 保存，`NOTARY_PROFILE` 可换成别的）。

钥匙串里没有这张证书时自动改用 ad-hoc 签名、跳过公证，适合自己从源码构建和本地测试。也可以通过 `SIGN_IDENTITY` 指定证书，`NOTARIZE=0` 跳过公证：

```bash
SIGN_IDENTITY="Developer ID Application: Name (TEAMID)" VERSION=1.0.0 scripts/package_release.sh
SIGN_IDENTITY=- VERSION=1.0.0 scripts/package_release.sh
```

## 工作原理

Finder 右键菜单由 Finder Sync 扩展提供。扩展负责显示菜单和判断目标目录，真正创建文件的操作交给主 App 后台执行，这样可以绕开 Finder Sync 沙盒对任意目录写入的限制。
