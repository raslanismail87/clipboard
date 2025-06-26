import Foundation
import AppKit
import CoreGraphics

class IconGenerator {
    static func generateAppIcon() {
        let sizes = [
            (16, "icon_16x16.png"),
            (32, "icon_16x16@2x.png"),
            (32, "icon_32x32.png"),
            (64, "icon_32x32@2x.png"),
            (128, "icon_128x128.png"),
            (256, "icon_128x128@2x.png"),
            (256, "icon_256x256.png"),
            (512, "icon_256x256@2x.png"),
            (512, "icon_512x512.png"),
            (1024, "icon_512x512@2x.png")
        ]
        
        for (size, filename) in sizes {
            let icon = createClipboardIcon(size: size)
            saveIcon(icon, filename: filename, size: size)
        }
        
        createContentsJSON()
    }
    
    private static func createClipboardIcon(size: Int) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        
        image.lockFocus()
        
        let rect = NSRect(x: 0, y: 0, width: size, height: size)
        let cornerRadius = CGFloat(size) * 0.225
        
        // Background with rounded corners
        let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
        NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0).setFill()
        bgPath.fill()
        
        // Grid pattern
        drawGrid(in: rect, size: size)
        
        // Clipboard icon overlay
        drawClipboard(in: rect, size: size)
        
        image.unlockFocus()
        
        return image
    }
    
    private static func drawGrid(in rect: NSRect, size: Int) {
        let gridColor = NSColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 0.6)
        gridColor.setStroke()
        
        let lineWidth = max(1.0, CGFloat(size) / 256.0)
        let gridSpacing = CGFloat(size) / 8.0
        
        // Vertical lines
        for i in 1..<8 {
            let x = CGFloat(i) * gridSpacing
            let path = NSBezierPath()
            path.lineWidth = lineWidth
            path.move(to: NSPoint(x: x, y: rect.minY + gridSpacing))
            path.line(to: NSPoint(x: x, y: rect.maxY - gridSpacing))
            path.stroke()
        }
        
        // Horizontal lines
        for i in 1..<8 {
            let y = CGFloat(i) * gridSpacing
            let path = NSBezierPath()
            path.lineWidth = lineWidth
            path.move(to: NSPoint(x: rect.minX + gridSpacing, y: y))
            path.line(to: NSPoint(x: rect.maxX - gridSpacing, y: y))
            path.stroke()
        }
        
        // Diagonal lines
        let diagonalPath1 = NSBezierPath()
        diagonalPath1.lineWidth = lineWidth
        diagonalPath1.move(to: NSPoint(x: rect.minX + gridSpacing * 2, y: rect.minY + gridSpacing * 2))
        diagonalPath1.line(to: NSPoint(x: rect.maxX - gridSpacing * 2, y: rect.maxY - gridSpacing * 2))
        diagonalPath1.stroke()
        
        let diagonalPath2 = NSBezierPath()
        diagonalPath2.lineWidth = lineWidth
        diagonalPath2.move(to: NSPoint(x: rect.maxX - gridSpacing * 2, y: rect.minY + gridSpacing * 2))
        diagonalPath2.line(to: NSPoint(x: rect.minX + gridSpacing * 2, y: rect.maxY - gridSpacing * 2))
        diagonalPath2.stroke()
    }
    
    private static func drawClipboard(in rect: NSRect, size: Int) {
        let centerX = rect.midX
        let centerY = rect.midY
        let iconSize = CGFloat(size) * 0.4
        
        // Clipboard body
        let clipboardRect = NSRect(
            x: centerX - iconSize * 0.4,
            y: centerY - iconSize * 0.5,
            width: iconSize * 0.8,
            height: iconSize
        )
        
        let clipboardPath = NSBezierPath(roundedRect: clipboardRect, xRadius: iconSize * 0.1, yRadius: iconSize * 0.1)
        NSColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.8).setFill()
        clipboardPath.fill()
        
        // Clipboard clip
        let clipRect = NSRect(
            x: centerX - iconSize * 0.15,
            y: centerY + iconSize * 0.35,
            width: iconSize * 0.3,
            height: iconSize * 0.2
        )
        
        let clipPath = NSBezierPath(roundedRect: clipRect, xRadius: iconSize * 0.05, yRadius: iconSize * 0.05)
        NSColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0).setFill()
        clipPath.fill()
        
        // Content lines
        let lineColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        lineColor.setStroke()
        
        let lineWidth = max(1.0, CGFloat(size) / 128.0)
        
        for i in 0..<3 {
            let y = centerY + iconSize * 0.1 - CGFloat(i) * iconSize * 0.15
            let line = NSBezierPath()
            line.lineWidth = lineWidth
            line.move(to: NSPoint(x: centerX - iconSize * 0.25, y: y))
            line.line(to: NSPoint(x: centerX + iconSize * 0.25, y: y))
            line.stroke()
        }
    }
    
    private static func saveIcon(_ image: NSImage, filename: String, size: Int) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return
        }
        
        let iconSetPath = "build/Clipboard Manager.app/Contents/Resources/AppIcon.appiconset/"
        let url = URL(fileURLWithPath: iconSetPath + filename)
        
        try? pngData.write(to: url)
    }
    
    private static func createContentsJSON() {
        let contentsJSON = """
        {
          "images" : [
            {
              "filename" : "icon_16x16.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "16x16"
            },
            {
              "filename" : "icon_16x16@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "16x16"
            },
            {
              "filename" : "icon_32x32.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "32x32"
            },
            {
              "filename" : "icon_32x32@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "32x32"
            },
            {
              "filename" : "icon_128x128.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "128x128"
            },
            {
              "filename" : "icon_128x128@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "128x128"
            },
            {
              "filename" : "icon_256x256.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "256x256"
            },
            {
              "filename" : "icon_256x256@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "256x256"
            },
            {
              "filename" : "icon_512x512.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "512x512"
            },
            {
              "filename" : "icon_512x512@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "512x512"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        
        let url = URL(fileURLWithPath: "build/Clipboard Manager.app/Contents/Resources/AppIcon.appiconset/Contents.json")
        try? contentsJSON.write(to: url, atomically: true, encoding: .utf8)
    }
}