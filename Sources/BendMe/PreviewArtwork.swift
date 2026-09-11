import AppKit

enum PreviewArtwork {
    /// Original procedural landscape, rendered locally; no downloaded wallpaper.
    static func image(width: Int = 1200, height: Int = 780) -> CGImage? {
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.scaleBy(x: CGFloat(width) / 1200, y: CGFloat(height) / 780)
        let colors = [NSColor(red: 0.94, green: 0.67, blue: 0.42, alpha: 1).cgColor,
                      NSColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 1).cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
            ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 780), options: [])
        }
        ctx.setFillColor(NSColor(red: 1, green: 0.86, blue: 0.66, alpha: 1).cgColor)
        ctx.fillEllipse(in: CGRect(x: 890, y: 485, width: 78, height: 78))
        for layer in 0..<5 {
            let base = CGFloat(310 - layer * 64)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: base + 40))
            path.addCurve(to: CGPoint(x: 550, y: base + 90), control1: CGPoint(x: 210, y: base - 110), control2: CGPoint(x: 330, y: base + 200))
            path.addCurve(to: CGPoint(x: 1200, y: base + 35), control1: CGPoint(x: 790, y: base - 30), control2: CGPoint(x: 1000, y: base + 210))
            path.addLine(to: CGPoint(x: 1200, y: 0)); path.closeSubpath()
            let shades: [NSColor] = [
                .init(red: 0.63, green: 0.49, blue: 0.45, alpha: 1),
                .init(red: 0.48, green: 0.38, blue: 0.40, alpha: 1),
                .init(red: 0.31, green: 0.29, blue: 0.36, alpha: 1),
                .init(red: 0.20, green: 0.24, blue: 0.32, alpha: 1),
                .init(red: 0.12, green: 0.17, blue: 0.25, alpha: 1)]
            ctx.setFillColor(shades[layer].cgColor); ctx.addPath(path); ctx.fillPath()
        }
        let graphics = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = graphics
        let dateAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 20, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.8)]
        let timeAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 116, weight: .light), .foregroundColor: NSColor.white.withAlphaComponent(0.94)]
        let date = "A little perspective." as NSString
        date.draw(at: CGPoint(x: (1200 - date.size(withAttributes: dateAttributes).width) / 2, y: 613), withAttributes: dateAttributes)
        let time = "9:41" as NSString
        time.draw(at: CGPoint(x: (1200 - time.size(withAttributes: timeAttributes).width) / 2, y: 475), withAttributes: timeAttributes)
        NSGraphicsContext.restoreGraphicsState()
        return ctx.makeImage()
    }
}
