import AppKit
import Foundation

enum NewFileKind: String {
    case plainText
    case markdown
    case richText
    case csv
    case json
    case html
    case css
    case word
    case pdf
    case powerpoint
    case excel
    case javascript
    case python
    case swift
    case shell

    var baseName: String {
        switch self {
        case .plainText: return "新建文本文档"
        case .markdown: return "新建Markdown"
        case .richText: return "新建富文本"
        case .csv: return "新建CSV"
        case .json: return "新建JSON"
        case .html: return "新建HTML"
        case .css: return "新建CSS"
        case .word: return "新建Word文档"
        case .pdf: return "新建PDF"
        case .powerpoint: return "新建PowerPoint"
        case .excel: return "新建Excel表格"
        case .javascript: return "新建JavaScript"
        case .python: return "新建Python"
        case .swift: return "新建Swift"
        case .shell: return "新建Shell脚本"
        }
    }

    var fileExtension: String {
        switch self {
        case .plainText: return "txt"
        case .markdown: return "md"
        case .richText: return "rtf"
        case .csv: return "csv"
        case .json: return "json"
        case .html: return "html"
        case .css: return "css"
        case .word: return "docx"
        case .pdf: return "pdf"
        case .powerpoint: return "pptx"
        case .excel: return "xlsx"
        case .javascript: return "js"
        case .python: return "py"
        case .swift: return "swift"
        case .shell: return "sh"
        }
    }

    var contents: Data {
        let value: String

        switch self {
        case .plainText:
            value = ""
        case .markdown:
            value = "# Untitled\n"
        case .richText:
            value = "{\\rtf1\\ansi\\deff0\\n}"
        case .csv:
            value = "name,value\n"
        case .json:
            value = "{\n  \n}\n"
        case .html:
            value = """
            <!doctype html>
            <html lang="zh-CN">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>Untitled</title>
            </head>
            <body>
            </body>
            </html>
            """
        case .css:
            value = """
            :root {
              color-scheme: light dark;
            }

            body {
              margin: 0;
            }
            """
        case .word:
            return TemplateData.wordDocument
        case .pdf:
            return TemplateData.pdfDocument
        case .powerpoint:
            return TemplateData.powerPointPresentation
        case .excel:
            return TemplateData.excelWorkbook
        case .javascript:
            value = "console.log('Hello');\n"
        case .python:
            value = "#!/usr/bin/env python3\n\n"
        case .swift:
            value = "import Foundation\n\n"
        case .shell:
            value = "#!/bin/zsh\n\n"
        }

        return Data(value.utf8)
    }

    var isExecutable: Bool {
        self == .shell || self == .python
    }
}

private enum TemplateData {
    static let wordDocument = data(fromBase64: """
    UEsDBBQAAAAIAAAAIVzJTxqw6wAAAK4BAAATAAAAW0NvbnRlbnRfVHlwZXNdLnhtbH1QvU7DMBDeeQrLK4odGBBCSTrwMwJDeYCTfUks7LPlc0v79jht6YAK4933q69b7YIXW8zsIvXyRrVSIJloHU29/Fi/NPdScAGy4CNhL/fIcjVcdet9QhZVTNzLuZT0oDWbGQOwigmpImPMAUo986QTmE+YUN+27Z02kQpSacriIYfuCUfY+CKed/V9LJLRsxSPR+KS1UtIyTsDpeJ6S/ZXSnNKUFV54PDsEl9XgtQXExbk74CT7q0uk51F8Q65vEKoLP0Vs9U2mk2oSvW/zYWecRydwbN+cUs5GmSukwevzkgARz/99WHu4RtQSwMEFAAAAAgAAAAhXLmBRHGwAAAAKgEAAAsAAABfcmVscy8ucmVsc43POw7CMAwG4J1TRN5pWgaEUJMuCKkrKgeIEjeNaB5KwqO3JwMDIAZG278/y233sDO5YUzGOwZNVQNBJ70yTjM4D8f1DkjKwikxe4cMFkzQ8VV7wlnkspMmExIpiEsMppzDntIkJ7QiVT6gK5PRRytyKaOmQciL0Eg3db2l8d0A/mGSXjGIvWqADEvAf2w/jkbiwcurRZd/nPhKFFlEjZnB3UdF1atdFRYob+nHi/wJUEsDBBQAAAAIAAAAIVypO6lQzAAAACkBAAARAAAAd29yZC9kb2N1bWVudC54bWxFT8FOwzAMvfMVke8sKUxVqdbuthsSEvABWeK1lZo4SjzK+Hpc0NSL7fee9Z59OH6HWX1hLhPFDqqdAYXRkZ/i0MHnx+mxAVXYRm9nitjBDQsc+4fD0npy14CRlTjE0i4djMyp1bq4EYMtO0oYRbtQDpYF5kEvlH3K5LAUCQizfjKm1sFOEXqxPJO/rT3ptRZ0/Jb/8PD+o5Y1oqpeTA0yjzLXzXMD+n/h1WZhmZLw+71ZV/I0jLzBMzFT2PCMl7sqHnrL0/dD9PZk/wtQSwECFAMUAAAACAAAACFcyU8asOsAAACuAQAAEwAAAAAAAAAAAAAAgAEAAAAAW0NvbnRlbnRfVHlwZXNdLnhtbFBLAQIUAxQAAAAIAAAAIVy5gURxsAAAACoBAAALAAAAAAAAAAAAAACAARwBAABfcmVscy8ucmVsc1BLAQIUAxQAAAAIAAAAIVypO6lQzAAAACkBAAARAAAAAAAAAAAAAACAAfUBAAB3b3JkL2RvY3VtZW50LnhtbFBLBQYAAAAAAwADALkAAADwAgAAAAA=
    """)

    static let pdfDocument = data(fromBase64: """
    JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCA1OTUgODQyXSAvQ29udGVudHMgNCAwIFIgPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCAwID4+CnN0cmVhbQoKZW5kc3RyZWFtCmVuZG9iagp4cmVmCjAgNQowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAwMDkgMDAwMDAgbiAKMDAwMDAwMDA1OCAwMDAwMCBuIAowMDAwMDAwMTE1IDAwMDAwIG4gCjAwMDAwMDAyMDIgMDAwMDAgbiAKdHJhaWxlcgo8PCAvU2l6ZSA1IC9Sb290IDEgMCBSID4+CnN0YXJ0eHJlZgoyNTEKJSVFT0YK
    """)

    static let powerPointPresentation = data(fromBase64: """
    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
    """)

    static let excelWorkbook = data(fromBase64: """
    UEsDBBQAAAAIAAAAIVzFLx19AAEAAC4CAAATAAAAW0NvbnRlbnRfVHlwZXNdLnhtbK2RzU7DMBCE7zyF5WsVO+WAEErSQ4EjcCgPsDibxIr/5HVL+vY4aeGAClw4reyZ2W9kV5vJGnbASNq7mq9FyRk65Vvt+pq/7h6LW84ogWvBeIc1PyLxTXNV7Y4BieWwo5oPKYU7KUkNaIGED+iy0vloIeVj7GUANUKP8rosb6TyLqFLRZp38Ka6xw72JrGHKV+fikQ0xNn2ZJxZNYcQjFaQsi4Prv1GKc4EkZOLhwYdaJUNXF4kzMrPgHPuOb9M1C2yF4jpCWx2ycnIdx/HN+9H8fuSCy1912mFrVd7myOCQkRoaUBM1ohlCgvarf7mL2aSy1j/c5Gv/Z895PLdzQdQSwMEFAAAAAgAAAAhXAZZx4KxAAAAKAEAAAsAAABfcmVscy8ucmVsc43PsQ6CMBAG4N2naG6XgoMxhsJiTFgNPkBtj0KAXtNWhbe3oxoHx8v99/25sl7miT3Qh4GsgCLLgaFVpAdrBFzb8/YALERptZzIooAVA9TVprzgJGO6Cf3gAkuIDQL6GN2R86B6nGXIyKFNm478LGMaveFOqlEa5Ls833P/bkD1YbJGC/CNLoC1q8N/bOq6QeGJ1H1GG39UfCWSLL3BKGCZ+JP8eCMas4QCr0r+8WD1AlBLAwQUAAAACAAAACFcd0D+xLwAAAAcAQAADwAAAHhsL3dvcmtib29rLnhtbI1Py47CMAy88xWR70vaPSBUteWCkDgvfEBoXBrR2JWd5fH3hNed04w1mvFMvbrG0ZxRNDA1UM4LMEgd+0DHBva7zc8SjCZH3o1M2MANFVbtrL6wnA7MJ5P9pA0MKU2VtdoNGJ3OeULKSs8SXcqnHK1Ogs7rgJjiaH+LYmGjCwSvhEq+yeC+Dx2uufuPSOkVIji6lNvrECaFtn5+0DcacjG3/nvwMi954NbnoWCkCpnI1pdg29p+bPazrL0DUEsDBBQAAAAIAAAAIVyabzx8tQAAACkBAAAaAAAAeGwvX3JlbHMvd29ya2Jvb2sueG1sLnJlbHONz80KwjAMB/C7T1Fyd9k8iMi6XUTYVeYDlC77YFtbmvqxt7d4EAcePIXkT34hefmcJ3Enz4M1ErIkBUFG22YwnYRrfd4eQHBQplGTNSRhIYay2OQXmlSIO9wPjkVEDEvoQ3BHRNY9zYoT68jEpLV+ViG2vkOn9Kg6wl2a7tF/G1CsTFE1EnzVZCDqxdE/tm3bQdPJ6ttMJvw4gQ/rR+6JQkSV7yhI+IwY3yVLogpY5Lj6sHgBUEsDBBQAAAAIAAAAIVwHmuiihAAAAJ0AAAAYAAAAeGwvd29ya3NoZWV0cy9zaGVldDEueG1sPYxLDsIwDAX3nCLynrqwQAgl6abiBHAAqzFNReNUccTn9lRdsJw3emO7T5rNi4tOWRwcmhYMy5DDJKOD++26P4PRShJozsIOvqzQ+Z195/LUyFzNGhB1EGtdLog6RE6kTV5YVvPIJVFdsYyoS2EK2ynNeGzbEyaaBLzdtp4qobf4L/sfUEsBAhQDFAAAAAgAAAAhXMUvHX0AAQAALgIAABMAAAAAAAAAAAAAAIABAAAAAFtDb250ZW50X1R5cGVzXS54bWxQSwECFAMUAAAACAAAACFcBlnHgrEAAAAoAQAACwAAAAAAAAAAAAAAgAExAQAAX3JlbHMvLnJlbHNQSwECFAMUAAAACAAAACFcd0D+xLwAAAAcAQAADwAAAAAAAAAAAAAAgAELAgAAeGwvd29ya2Jvb2sueG1sUEsBAhQDFAAAAAgAAAAhXJpvPHy1AAAAKQEAABoAAAAAAAAAAAAAAIAB9AIAAHhsL19yZWxzL3dvcmtib29rLnhtbC5yZWxzUEsBAhQDFAAAAAgAAAAhXAea6KKEAAAAnQAAABgAAAAAAAAAAAAAAIAB4QMAAHhsL3dvcmtzaGVldHMvc2hlZXQxLnhtbFBLBQYAAAAABQAFAEUBAACbBAAAAAA=
    """)

    private static func data(fromBase64 base64: String) -> Data {
        let compact = base64.components(separatedBy: .whitespacesAndNewlines).joined()
        return Data(base64Encoded: compact) ?? Data()
    }
}

enum NewFileCreator {
    static func handle(_ url: URL) {
        writeLog("handle url: \(url.absoluteString)")

        guard
            url.scheme == "newfileapp",
            url.host == "create",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let type = components.queryItems?.first(where: { $0.name == "type" })?.value,
            let path = components.queryItems?.first(where: { $0.name == "path" })?.value,
            let kind = NewFileKind(rawValue: type)
        else {
            showAlert("新建文件请求无效。")
            return
        }

        create(kind, in: URL(fileURLWithPath: path, isDirectory: true))
    }

    static func create(_ kind: NewFileKind, in directoryURL: URL) {
        writeLog("create \(kind.rawValue) in \(directoryURL.path)")

        do {
            let destinationURL = uniqueURL(for: kind, in: directoryURL)
            try kind.contents.write(to: destinationURL, options: .withoutOverwriting)
            writeLog("created \(destinationURL.path)")

            if kind.isExecutable {
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destinationURL.path)
            }

            NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
        } catch {
            writeLog("failed \(error.localizedDescription)")
            showAlert("创建文件失败：\(error.localizedDescription)\n\n目录：\(directoryURL.path)")
        }
    }

    private static func uniqueURL(for kind: NewFileKind, in directoryURL: URL) -> URL {
        let fileManager = FileManager.default
        let preferredURL = directoryURL.appendingPathComponent(kind.baseName)
            .appendingPathExtension(kind.fileExtension)

        guard fileManager.fileExists(atPath: preferredURL.path) else {
            return preferredURL
        }

        for index in 2...999 {
            let url = directoryURL.appendingPathComponent("\(kind.baseName) \(index)")
                .appendingPathExtension(kind.fileExtension)

            if !fileManager.fileExists(atPath: url.path) {
                return url
            }
        }

        return directoryURL.appendingPathComponent("\(kind.baseName) \(UUID().uuidString)")
            .appendingPathExtension(kind.fileExtension)
    }

    private static func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "访达右键新建文件"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "好")
        alert.runModal()
    }

    private static func writeLog(_ message: String) {
        let line = "[\(Date())] \(message)\n"
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/NewFileApp.log")

        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: url.path),
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
