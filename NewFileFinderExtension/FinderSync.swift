import Cocoa
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let fileManager = FileManager.default

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [
            URL(fileURLWithPath: "/", isDirectory: true)
        ]
    }

    override var toolbarItemName: String {
        "新建文件"
    }

    override var toolbarItemToolTip: String {
        "在当前位置新建文件"
    }

    override var toolbarItemImage: NSImage {
        NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: "新建文件") ?? NSImage()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: "新建文件")
        let submenu = NSMenu(title: "新建文件")

        for template in FileTemplate.allCases {
            let item = NSMenuItem(
                title: template.menuTitle,
                action: selector(for: template),
                keyEquivalent: ""
            )
            item.target = self
            submenu.addItem(item)
        }

        let parent = NSMenuItem(title: "新建文件", action: nil, keyEquivalent: "")
        parent.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: nil)
        parent.submenu = submenu
        menu.addItem(parent)

        return menu
    }

    @objc private func createPlainText() { create(.plainText) }
    @objc private func createMarkdown() { create(.markdown) }
    @objc private func createRichText() { create(.richText) }
    @objc private func createCSV() { create(.csv) }
    @objc private func createJSON() { create(.json) }
    @objc private func createHTML() { create(.html) }
    @objc private func createWord() { create(.word) }
    @objc private func createPDF() { create(.pdf) }
    @objc private func createPowerPoint() { create(.powerpoint) }
    @objc private func createExcel() { create(.excel) }
    @objc private func createJavaScript() { create(.javascript) }
    @objc private func createPython() { create(.python) }
    @objc private func createSwift() { create(.swift) }
    @objc private func createShell() { create(.shell) }

    private func create(_ template: FileTemplate) {
        writeLog("create invoked for \(template.rawValue)")

        guard let directoryURL = targetDirectoryURL() else {
            writeLog("failed: no target directory")
            return
        }

        writeLog("target directory: \(directoryURL.path)")
        openMainAppCreateURL(template: template, directoryURL: directoryURL)
    }

    private func selector(for template: FileTemplate) -> Selector {
        switch template {
        case .plainText: return #selector(createPlainText)
        case .markdown: return #selector(createMarkdown)
        case .richText: return #selector(createRichText)
        case .csv: return #selector(createCSV)
        case .json: return #selector(createJSON)
        case .html: return #selector(createHTML)
        case .word: return #selector(createWord)
        case .pdf: return #selector(createPDF)
        case .powerpoint: return #selector(createPowerPoint)
        case .excel: return #selector(createExcel)
        case .javascript: return #selector(createJavaScript)
        case .python: return #selector(createPython)
        case .swift: return #selector(createSwift)
        case .shell: return #selector(createShell)
        }
    }

    private func openMainAppCreateURL(template: FileTemplate, directoryURL: URL) {
        var components = URLComponents()
        components.scheme = "newfileapp"
        components.host = "create"
        components.queryItems = [
            URLQueryItem(name: "type", value: template.rawValue),
            URLQueryItem(name: "path", value: directoryURL.path)
        ]

        guard let url = components.url else {
            writeLog("failed to build callback URL")
            return
        }

        writeLog("opening callback URL: \(url.absoluteString)")
        let appURL = URL(fileURLWithPath: "/Applications/NewFileApp.app", isDirectory: true)
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false

        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: configuration) { [weak self] _, error in
            if let error {
                self?.writeLog("failed to open main app: \(error.localizedDescription)")
            } else {
                self?.writeLog("main app open request sent")
            }
        }
    }

    private func targetDirectoryURL() -> URL? {
        let controller = FIFinderSyncController.default()
        writeLog("targetedURL=\(String(describing: controller.targetedURL()?.path)), selected=\(String(describing: controller.selectedItemURLs()?.map { $0.path }))")

        if let selectedURLs = controller.selectedItemURLs(), selectedURLs.count == 1 {
            let selectedURL = selectedURLs[0]
            if isDirectory(selectedURL) {
                return selectedURL
            }
        }

        if let targetedURL = controller.targetedURL() {
            if isDirectory(targetedURL) {
                return targetedURL
            }
            return targetedURL.deletingLastPathComponent()
        }

        if let selectedURL = controller.selectedItemURLs()?.first {
            return isDirectory(selectedURL) ? selectedURL : selectedURL.deletingLastPathComponent()
        }

        return frontFinderWindowURL()
    }

    private func uniqueURL(for template: FileTemplate, in directoryURL: URL) -> URL {
        let preferredURL = directoryURL.appendingPathComponent(template.baseName)
            .appendingPathExtension(template.fileExtension)

        guard fileManager.fileExists(atPath: preferredURL.path) else {
            return preferredURL
        }

        for index in 2...999 {
            let url = directoryURL.appendingPathComponent("\(template.baseName) \(index)")
                .appendingPathExtension(template.fileExtension)

            if !fileManager.fileExists(atPath: url.path) {
                return url
            }
        }

        return directoryURL.appendingPathComponent("\(template.baseName) \(UUID().uuidString)")
            .appendingPathExtension(template.fileExtension)
    }

    private func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private func frontFinderWindowURL() -> URL? {
        let source = """
        tell application "Finder"
            if (count of Finder windows) > 0 then
                return POSIX path of (target of front Finder window as alias)
            else
                return POSIX path of (path to desktop folder)
            end if
        end tell
        """

        var error: NSDictionary?
        guard let output = NSAppleScript(source: source)?.executeAndReturnError(&error).stringValue else {
            writeLog("Finder AppleScript failed: \(String(describing: error))")
            return nil
        }

        return URL(fileURLWithPath: output, isDirectory: true)
    }

    private func writeLog(_ message: String) {
        let line = "[\(Date())] \(message)\n"
        NSLog("[NewFileFinderExtension] \(message)")

        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/NewFileFinderExtension.log")

        if let data = line.data(using: .utf8) {
            if fileManager.fileExists(atPath: url.path),
               let handle = try? FileHandle(forWritingTo: url) {
                try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
                try? handle.close()
            } else {
                try? data.write(to: url)
            }
        }
    }
}
