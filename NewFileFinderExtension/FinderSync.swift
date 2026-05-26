import Cocoa
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let fileManager = FileManager.default
    private static let cutPathsPasteboardType = NSPasteboard.PasteboardType("com.local.NewFileApp.cutPaths")
    private static let fileGroups: [(title: String, templates: [FileTemplate])] = [
        ("文本文档", [.plainText, .richText, .markdown]),
        ("办公文档", [.word, .pdf, .powerpoint, .excel]),
        ("数据文件", [.csv, .json]),
        ("编程开发", [.html, .css, .javascript, .python, .swift, .shell])
    ]
    private static var fileIconCache: [FileTemplate: NSImage] = [:]
    private static var symbolIconCache: [String: NSImage] = [:]

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
        Self.symbolIcon(named: "doc.badge.plus", accessibilityDescription: "新建文件")
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: "新建文件")
        let submenu = NSMenu(title: "新建文件")
        let hasSelection = !selectedItemURLs().isEmpty

        for (groupIndex, group) in Self.fileGroups.enumerated() {
            if groupIndex > 0 {
                submenu.addItem(.separator())
            }

            submenu.addItem(groupHeaderItem(title: group.title))

            for template in group.templates {
                submenu.addItem(menuItem(for: template))
            }
        }

        menu.addItem(actionItem(
            title: "新建空白文件夹",
            symbolName: "folder.badge.plus",
            action: #selector(createFolder)
        ))

        let parent = NSMenuItem(title: "新建文件", action: nil, keyEquivalent: "")
        parent.image = Self.symbolIcon(named: "doc.badge.plus", accessibilityDescription: nil)
        parent.submenu = submenu
        menu.addItem(parent)
        let cutItem = actionItem(
            title: "剪切",
            symbolName: "scissors",
            action: #selector(cutItems)
        )
        cutItem.isEnabled = hasSelection
        menu.addItem(cutItem)
        let pasteItem = actionItem(
            title: "粘贴到此处",
            symbolName: "doc.on.clipboard",
            action: #selector(pasteCutItems)
        )
        pasteItem.isEnabled = NSPasteboard.general.string(forType: Self.cutPathsPasteboardType) != nil
        menu.addItem(pasteItem)
        let trashItem = actionItem(
            title: "移到废纸篓",
            symbolName: "trash",
            action: #selector(trashItems)
        )
        trashItem.isEnabled = hasSelection
        menu.addItem(trashItem)
        menu.addItem(actionItem(
            title: "拷贝路径",
            symbolName: "link",
            action: #selector(copyPath)
        ))
        menu.addItem(actionItem(
            title: "打开终端",
            symbolName: "terminal",
            action: #selector(openTerminal)
        ))

        return menu
    }

    @objc private func createPlainText() { create(.plainText) }
    @objc private func createMarkdown() { create(.markdown) }
    @objc private func createRichText() { create(.richText) }
    @objc private func createCSV() { create(.csv) }
    @objc private func createJSON() { create(.json) }
    @objc private func createHTML() { create(.html) }
    @objc private func createCSS() { create(.css) }
    @objc private func createWord() { create(.word) }
    @objc private func createPDF() { create(.pdf) }
    @objc private func createPowerPoint() { create(.powerpoint) }
    @objc private func createExcel() { create(.excel) }
    @objc private func createJavaScript() { create(.javascript) }
    @objc private func createPython() { create(.python) }
    @objc private func createSwift() { create(.swift) }
    @objc private func createShell() { create(.shell) }

    @objc private func createFolder() {
        guard let directoryURL = targetDirectoryURL() else {
            writeLog("create folder failed: no target directory")
            return
        }

        writeLog("create folder target directory: \(directoryURL.path)")
        openMainAppFolderURL(directoryURL: directoryURL)
    }

    @objc private func cutItems() {
        let urls = selectedItemURLs()
        let paths = urls.map { $0.path }

        guard !paths.isEmpty else {
            writeLog("cut failed: no selected paths")
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(paths.joined(separator: "\n"), forType: Self.cutPathsPasteboardType)
        pasteboard.setString(paths.joined(separator: "\n"), forType: .string)
        writeLog("cut paths: \(paths)")
    }

    @objc private func pasteCutItems() {
        guard let directoryURL = targetDirectoryURL() else {
            writeLog("paste cut failed: no target directory")
            return
        }

        writeLog("paste cut target directory: \(directoryURL.path)")
        openMainAppPasteCutURL(directoryURL: directoryURL)
    }

    @objc private func trashItems() {
        let urls = selectedItemURLs()

        guard !urls.isEmpty else {
            writeLog("trash failed: no selected paths")
            return
        }

        writeLog("trash paths: \(urls.map { $0.path })")
        openMainAppTrashURL(itemURLs: urls)
    }

    @objc private func copyPath() {
        let urls = pathTargetURLs()
        let paths = urls.map { $0.path }

        guard !paths.isEmpty else {
            writeLog("copy path failed: no target paths")
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(paths.joined(separator: "\n"), forType: .string)
        writeLog("copied paths: \(paths)")
    }

    @objc private func openTerminal() {
        guard let directoryURL = targetDirectoryURL() else {
            writeLog("open terminal failed: no target directory")
            return
        }

        writeLog("open terminal target directory: \(directoryURL.path)")
        openMainAppTerminalURL(directoryURL: directoryURL)
    }

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
        case .css: return #selector(createCSS)
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

    private func groupHeaderItem(title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func menuItem(for template: FileTemplate) -> NSMenuItem {
        let item = NSMenuItem(
            title: template.menuTitle,
            action: selector(for: template),
            keyEquivalent: ""
        )
        item.target = self
        item.image = icon(for: template)
        return item
    }

    private func actionItem(title: String, symbolName: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.image = Self.symbolIcon(named: symbolName, accessibilityDescription: title)
        return item
    }

    private func icon(for template: FileTemplate) -> NSImage {
        if let cached = Self.fileIconCache[template] {
            return cached
        }

        let image = NSWorkspace.shared.icon(forFileType: template.fileExtension)
        image.size = NSSize(width: 16, height: 16)
        Self.fileIconCache[template] = image
        return image
    }

    private static func symbolIcon(named name: String, accessibilityDescription: String?) -> NSImage {
        if let cached = symbolIconCache[name] {
            return cached
        }

        let image = NSImage(systemSymbolName: name, accessibilityDescription: accessibilityDescription) ?? NSImage()
        image.size = NSSize(width: 16, height: 16)
        symbolIconCache[name] = image
        return image
    }

    private func openMainAppCreateURL(template: FileTemplate, directoryURL: URL) {
        openMainAppURL(host: "create", queryItems: [
            URLQueryItem(name: "type", value: template.rawValue),
            URLQueryItem(name: "path", value: directoryURL.path)
        ])
    }

    private func openMainAppTerminalURL(directoryURL: URL) {
        openMainAppURL(host: "terminal", queryItems: [
            URLQueryItem(name: "path", value: directoryURL.path)
        ])
    }

    private func openMainAppFolderURL(directoryURL: URL) {
        openMainAppURL(host: "folder", queryItems: [
            URLQueryItem(name: "path", value: directoryURL.path)
        ])
    }

    private func openMainAppPasteCutURL(directoryURL: URL) {
        openMainAppURL(host: "pasteCut", queryItems: [
            URLQueryItem(name: "path", value: directoryURL.path)
        ])
    }

    private func openMainAppTrashURL(itemURLs: [URL]) {
        openMainAppURL(host: "trash", queryItems: itemURLs.map {
            URLQueryItem(name: "path", value: $0.path)
        })
    }

    private func openMainAppURL(host: String, queryItems: [URLQueryItem]) {
        var components = URLComponents()
        components.scheme = "newfileapp"
        components.host = host
        components.queryItems = queryItems

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

    private func selectedItemURLs() -> [URL] {
        let controller = FIFinderSyncController.default()

        if let selectedURLs = controller.selectedItemURLs(), !selectedURLs.isEmpty {
            return selectedURLs
        }

        return []
    }

    private func pathTargetURLs() -> [URL] {
        let controller = FIFinderSyncController.default()

        if let selectedURLs = controller.selectedItemURLs(), !selectedURLs.isEmpty {
            return selectedURLs
        }

        if let targetedURL = controller.targetedURL() {
            return [targetedURL]
        }

        if let windowURL = frontFinderWindowURL() {
            return [windowURL]
        }

        return []
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
