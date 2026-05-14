# NewFileApp

一个 macOS Finder 右键“新建文件”工具。安装后，在访达任意文件夹空白处右键，可以通过 **新建文件** 子菜单创建常见文件。

## 功能

- Finder 右键菜单中显示 **新建文件** 父项
- 支持 `txt`、`md`、`rtf`、`csv`、`json`、`html`、`docx`、`pdf`、`pptx`、`xlsx`、`js`、`py`、`swift`、`sh`
- Word、PDF、PowerPoint、Excel 使用可识别的空白模板，不是简单改后缀
- 自动处理重名文件，例如 `新建文本文档 2.txt`
- 创建后自动在 Finder 中选中新文件
- 右键创建时后台执行，不弹出主窗口

## 用户安装

推荐从 GitHub Releases 下载 `.dmg`：

1. 打开 `.dmg`
2. 把 `NewFileApp.app` 拖到 `Applications`
3. 打开 `Applications/NewFileApp.app`
4. 点击 **一键安装/修复**
5. 如果系统设置打开了扩展页面，请启用 **新建文件**
6. 在 Finder 文件夹空白处右键，选择 **新建文件**

macOS 不允许第三方 App 完全静默启用 Finder 扩展，所以“系统设置里启用扩展”这一步可能需要手动点一次。

## 无法打开时

当前 Release 未经过 Apple 公证。首次打开时，macOS 可能提示“无法验证开发者”。

可以这样打开：

1. 在 Finder 中右键点击 `NewFileApp.app`
2. 选择 **打开**
3. 在弹窗中再次选择 **打开**

也可以在 **系统设置 > 隐私与安全性** 中允许打开。

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

把 `.dmg` 上传到 GitHub Releases，普通用户下载后按“用户安装”步骤操作即可。

## 签名

打包脚本默认使用 ad-hoc 签名，适合开源分发和本地测试。也可以通过 `SIGN_IDENTITY` 指定证书：

```bash
SIGN_IDENTITY="Developer ID Application: Name (TEAMID)" VERSION=1.0.0 scripts/package_release.sh
```

## 工作原理

Finder 右键菜单由 Finder Sync 扩展提供。扩展负责显示菜单和判断目标目录，真正创建文件的操作交给主 App 后台执行，这样可以绕开 Finder Sync 沙盒对任意目录写入的限制。
