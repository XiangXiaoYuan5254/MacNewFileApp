import Foundation

enum FileTemplate: String, CaseIterable {
    case plainText
    case markdown
    case richText
    case csv
    case json
    case html
    case word
    case pdf
    case powerpoint
    case excel
    case javascript
    case python
    case swift
    case shell

    var menuTitle: String {
        switch self {
        case .plainText: return "文本文档 (.txt)"
        case .markdown: return "Markdown (.md)"
        case .richText: return "富文本 (.rtf)"
        case .csv: return "CSV 表格 (.csv)"
        case .json: return "JSON (.json)"
        case .html: return "HTML (.html)"
        case .word: return "Word 文档 (.docx)"
        case .pdf: return "PDF 文档 (.pdf)"
        case .powerpoint: return "PowerPoint 演示文稿 (.pptx)"
        case .excel: return "Excel 表格 (.xlsx)"
        case .javascript: return "JavaScript (.js)"
        case .python: return "Python (.py)"
        case .swift: return "Swift (.swift)"
        case .shell: return "Shell 脚本 (.sh)"
        }
    }

    var baseName: String {
        switch self {
        case .plainText: return "新建文本文档"
        case .markdown: return "新建Markdown"
        case .richText: return "新建富文本"
        case .csv: return "新建CSV"
        case .json: return "新建JSON"
        case .html: return "新建HTML"
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
        case .word, .pdf, .powerpoint, .excel:
            value = ""
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
        switch self {
        case .shell, .python:
            return true
        default:
            return false
        }
    }
}
