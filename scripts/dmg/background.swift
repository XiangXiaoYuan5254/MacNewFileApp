import AppKit

// 生成 DMG 窗口的背景：浅灰底，中间一个虚线箭头，提示把左边的NewFileApp拖到右边的「应用程序」。
// 窗口 540×380，图标中心在 y = 220（见 scripts/dmg/settings.py），箭头放在两个图标之间。
// 同时输出 1 倍和 2 倍（Retina）两张，dmgbuild 会把 background@2x.png 合进同一个背景里。
//
//   swift scripts/dmg/background.swift <输出目录>

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1])
let width = 540.0
let height = 380.0

func render(scale: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(width) * scale,
        pixelsHigh: Int(height) * scale,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: width, height: height)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    NSColor(calibratedWhite: 0.925, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()

    // 以左上角为原点时箭头中心在 (270, 220)，这里的坐标原点在左下角。
    let cx = 270.0
    let cy = height - 220
    let arrow = NSBezierPath()
    arrow.move(to: NSPoint(x: cx - 27, y: cy + 11))
    arrow.line(to: NSPoint(x: cx - 5, y: cy + 11))
    arrow.line(to: NSPoint(x: cx - 5, y: cy + 29))
    arrow.line(to: NSPoint(x: cx + 24, y: cy))
    arrow.line(to: NSPoint(x: cx - 5, y: cy - 29))
    arrow.line(to: NSPoint(x: cx - 5, y: cy - 11))
    arrow.line(to: NSPoint(x: cx - 27, y: cy - 11))
    arrow.close()
    arrow.lineWidth = 1.5
    arrow.lineJoinStyle = .miter
    arrow.setLineDash([4, 3], count: 2, phase: 0)
    NSColor(calibratedWhite: 0.42, alpha: 1).setStroke()
    arrow.stroke()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
try render(scale: 1).write(to: outputDirectory.appendingPathComponent("background.png"))
try render(scale: 2).write(to: outputDirectory.appendingPathComponent("background@2x.png"))
