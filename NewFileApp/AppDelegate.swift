import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindow: NSWindow?
    private var handledURLDuringLaunch = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self, !self.handledURLDuringLaunch else {
                return
            }

            self.showMainWindow(activate: true)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        handledURLDuringLaunch = true

        for url in urls {
            NewFileCreator.handle(url)
        }

        mainWindow?.orderOut(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow(activate: true)
        return true
    }

    private func showMainWindow(activate: Bool) {
        if mainWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 292),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "访达右键新建文件"
            window.contentView = NSHostingView(rootView: ContentView())
            window.center()
            window.isReleasedWhenClosed = false
            mainWindow = window
        }

        mainWindow?.makeKeyAndOrderFront(nil)

        if activate {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
