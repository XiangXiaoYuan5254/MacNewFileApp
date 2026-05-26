import SwiftUI
import AppKit

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("访达右键新建文件")
                        .font(.title2.weight(.semibold))
                    Text("启用 Finder 扩展后，在访达目录中右键即可创建常见文件。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("可创建")
                    .font(.headline)
                Text("txt、md、rtf、csv、json、html、css、docx、pdf、pptx、xlsx、js、py、swift、sh")
                    .font(.callout.monospaced())
                    .textSelection(.enabled)
                    .foregroundStyle(.secondary)
                Text("支持新建空白文件夹、剪切/粘贴、拷贝路径、打开终端、移到废纸篓")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Button {
                    installOrRepair()
                } label: {
                    Label("一键安装/修复", systemImage: "wand.and.stars")
                }
                .keyboardShortcut(.defaultAction)

                Button {
                    registerExtension(showResult: true)
                } label: {
                    Label("注册扩展", systemImage: "plus.app")
                }

                Button {
                    openExtensionsSettings()
                } label: {
                    Label("打开扩展设置", systemImage: "switch.2")
                }

                Button {
                    relaunchFinder()
                } label: {
                    Label("重启访达", systemImage: "arrow.clockwise")
                }
            }
        }
        .padding(24)
        .frame(width: 600)
    }

    private func installOrRepair() {
        let registered = registerExtension(showResult: false)
        let enabled = enableExtension()
        registerURLScheme()
        relaunchFinder()

        if registered && enabled {
            showAlert("安装成功！\n\n现在可以在 Finder 文件夹空白处右键，选择“新建文件”。")
            closeInstallerWindow()
        } else {
            openExtensionsSettings()
            showAlert("已尝试安装/修复，但系统可能拦截了扩展启用。\n\n请在系统设置的扩展/访达扩展里手动启用“新建文件”。")
        }
    }

    @discardableResult
    private func registerExtension(showResult: Bool) -> Bool {
        guard let plugInsURL = Bundle.main.builtInPlugInsURL else {
            showAlert("没有找到内置扩展。")
            return false
        }

        let extensionURL = plugInsURL.appendingPathComponent("NewFileFinderExtension.appex")
        guard FileManager.default.fileExists(atPath: extensionURL.path) else {
            showAlert("没有找到 Finder 扩展：\(extensionURL.path)")
            return false
        }

        let status = run("/usr/bin/pluginkit", arguments: ["-a", extensionURL.path])
        let succeeded = status == 0

        if showResult {
            showAlert(succeeded ? "扩展已注册，请在系统设置里启用“新建文件”。" : "扩展注册失败，请确认 App 没有被系统隔离。")
        }

        return succeeded
    }

    private func enableExtension() -> Bool {
        run("/usr/bin/pluginkit", arguments: ["-e", "use", "-i", "com.local.NewFileApp.FinderExtension"]) == 0
    }

    private func registerURLScheme() {
        let lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
        _ = run(lsregister, arguments: ["-f", Bundle.main.bundlePath])
    }

    private func openExtensionsSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.ExtensionsPreferences",
            "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
        ]

        for rawValue in candidates {
            guard let url = URL(string: rawValue) else { continue }
            if NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    private func relaunchFinder() {
        _ = run("/usr/bin/killall", arguments: ["Finder"])
    }

    private func closeInstallerWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.keyWindow?.orderOut(nil)
            NSApp.hide(nil)
        }
    }

    private func run(_ executablePath: String, arguments: [String]) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        } catch {
            return -1
        }
    }

    private func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "访达右键新建文件"
        alert.informativeText = message
        alert.addButton(withTitle: "好")
        alert.runModal()
    }
}
