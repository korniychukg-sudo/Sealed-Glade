import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"
let S: CGFloat = 1024
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.setAllowsAntialiasing(true)

final class R {
    var state: UInt64 = 553
    func next() -> CGFloat {
        state = state &* 2862933555777941757 &+ 3037000493
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
    func range(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { lo + next() * (hi - lo) }
}
let rand = R()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

let bgGrad = CGGradient(colorsSpace: cs, colors: [rgb(0.93, 0.94, 0.87), rgb(0.84, 0.88, 0.78), rgb(0.62, 0.72, 0.56)] as CFArray, locations: [0, 0.5, 1])!
ctx.drawRadialGradient(bgGrad, startCenter: CGPoint(x: S * 0.5, y: S * 0.6), startRadius: 0, endCenter: CGPoint(x: S * 0.5, y: S * 0.5), endRadius: S * 0.8, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
for _ in 0..<500 {
    let x = rand.next() * S
    let y = rand.next() * S
    ctx.setFillColor(rgb(0.2, 0.28, 0.16, rand.range(0.015, 0.05)))
    ctx.fill(CGRect(x: x, y: y, width: rand.range(1.5, 3.5), height: rand.range(1.5, 3.5)))
}

let sillY = S * 0.16
ctx.setFillColor(rgb(0.52, 0.40, 0.28))
ctx.fill(CGRect(x: 0, y: sillY - 70, width: S, height: 76))
for _ in 0..<8 {
    let gy = sillY - 66 + rand.next() * 60
    ctx.setStrokeColor(rgb(0.36, 0.26, 0.16, rand.range(0.2, 0.35)))
    ctx.setLineWidth(3)
    ctx.move(to: CGPoint(x: 0, y: gy))
    ctx.addLine(to: CGPoint(x: S, y: gy + rand.range(-6, 6)))
    ctx.strokePath()
}

let jarRect = CGRect(x: S * 0.24, y: sillY, width: S * 0.52, height: S * 0.62)
let jar = CGMutablePath()
let w = jarRect.width
let h = jarRect.height
jar.move(to: CGPoint(x: jarRect.minX + w * 0.3, y: jarRect.maxY - h * 0.05))
jar.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.03, y: jarRect.midY), control: CGPoint(x: jarRect.minX + w * 0.02, y: jarRect.maxY - h * 0.22))
jar.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.16, y: jarRect.minY + h * 0.04), control: CGPoint(x: jarRect.minX + w * 0.04, y: jarRect.minY + h * 0.1))
jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.16, y: jarRect.minY + h * 0.04), control: CGPoint(x: jarRect.midX, y: jarRect.minY - h * 0.02))
jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.03, y: jarRect.midY), control: CGPoint(x: jarRect.maxX - w * 0.04, y: jarRect.minY + h * 0.1))
jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.3, y: jarRect.maxY - h * 0.05), control: CGPoint(x: jarRect.maxX - w * 0.02, y: jarRect.maxY - h * 0.22))
jar.closeSubpath()

ctx.setFillColor(rgb(0, 0, 0, 0.20))
ctx.fillEllipse(in: CGRect(x: jarRect.minX - 30, y: sillY - 30, width: jarRect.width + 60, height: 54))

ctx.saveGState()
ctx.addPath(jar)
ctx.clip()
ctx.setFillColor(rgb(0.86, 0.92, 0.90, 0.5))
ctx.fill(jarRect.insetBy(dx: -20, dy: -20))
let soilY = jarRect.minY + h * 0.22
ctx.setFillColor(rgb(0.42, 0.41, 0.38))
ctx.fill(CGRect(x: jarRect.minX, y: jarRect.minY, width: w, height: h * 0.07))
ctx.setFillColor(rgb(0.30, 0.23, 0.16))
ctx.fill(CGRect(x: jarRect.minX, y: jarRect.minY + h * 0.07, width: w, height: soilY - jarRect.minY - h * 0.07))
for _ in 0..<16 {
    let px = jarRect.minX + rand.next() * w
    let py = jarRect.minY + rand.next() * h * 0.07
    ctx.setFillColor(rgb(0.62, 0.61, 0.58))
    ctx.fillEllipse(in: CGRect(x: px, y: py, width: rand.range(14, 26), height: rand.range(9, 15)))
}

func leafCluster(_ cx: CGFloat, _ baseY: CGFloat, _ scale: CGFloat, _ deep: Bool) {
    let body = deep ? rgb(0.20, 0.33, 0.18) : rgb(0.30, 0.45, 0.25)
    for i in 0..<7 {
        let ang = CGFloat.pi / 2 + (CGFloat(i) / 6 - 0.5) * 1.7
        let len = (150 + rand.range(0, 90)) * scale
        let tip = CGPoint(x: cx + cos(ang) * len * 0.6, y: baseY + sin(ang) * len)
        ctx.setStrokeColor(rgb(0.16, 0.26, 0.13))
        ctx.setLineWidth(9 * scale)
        ctx.move(to: CGPoint(x: cx, y: baseY))
        ctx.addQuadCurve(to: tip, control: CGPoint(x: cx + cos(ang) * len * 0.3, y: baseY + sin(ang) * len * 0.55))
        ctx.strokePath()
        ctx.saveGState()
        ctx.translateBy(x: tip.x, y: tip.y)
        ctx.rotate(by: ang - .pi / 2)
        let leaf = CGMutablePath()
        let lw: CGFloat = 44 * scale
        let ll: CGFloat = 110 * scale
        leaf.move(to: .zero)
        leaf.addQuadCurve(to: CGPoint(x: 0, y: ll), control: CGPoint(x: lw, y: ll * 0.5))
        leaf.addQuadCurve(to: .zero, control: CGPoint(x: -lw, y: ll * 0.5))
        ctx.addPath(leaf)
        ctx.setFillColor(body)
        ctx.fillPath()
        ctx.addPath(leaf)
        ctx.setStrokeColor(rgb(0.13, 0.2, 0.1))
        ctx.setLineWidth(4 * scale)
        ctx.strokePath()
        ctx.setStrokeColor(rgb(0.55, 0.68, 0.45, 0.9))
        ctx.setLineWidth(3 * scale)
        ctx.move(to: CGPoint(x: 0, y: ll * 0.08))
        ctx.addLine(to: CGPoint(x: 0, y: ll * 0.9))
        ctx.strokePath()
        ctx.restoreGState()
    }
}
leafCluster(jarRect.midX - w * 0.16, soilY, 1.1, false)
leafCluster(jarRect.midX + w * 0.2, soilY, 0.85, true)
for _ in 0..<90 {
    let a = rand.next() * .pi
    let rr = CGFloat(rand.next()).squareRoot()
    let mx = jarRect.midX + w * 0.02 + cos(a) * w * 0.16 * rr
    let my = soilY + abs(sin(a)) * 40 * rr
    let r = rand.range(8, 16)
    ctx.setFillColor([rgb(0.30, 0.45, 0.25), rgb(0.24, 0.38, 0.20), rgb(0.42, 0.55, 0.33)][Int(rand.next() * 3) % 3])
    ctx.fillEllipse(in: CGRect(x: mx - r / 2, y: my - r / 2, width: r, height: r))
}
for _ in 0..<10 {
    let side: CGFloat = rand.next() > 0.5 ? jarRect.minX + 40 : jarRect.maxX - 52
    let py = jarRect.minY + h * (0.3 + rand.next() * 0.5)
    ctx.setFillColor(rgb(1, 1, 1, rand.range(0.35, 0.6)))
    ctx.fillEllipse(in: CGRect(x: side + rand.range(-14, 14), y: py, width: 11, height: 17))
}
ctx.restoreGState()

ctx.addPath(jar)
ctx.setStrokeColor(rgb(0.30, 0.40, 0.36))
ctx.setLineWidth(14)
ctx.strokePath()

let lid = CGRect(x: jarRect.minX + w * 0.27, y: jarRect.maxY - 16, width: w * 0.46, height: 74)
let lidPath = CGPath(roundedRect: lid, cornerWidth: 12, cornerHeight: 12, transform: nil)
let lidGrad = CGGradient(colorsSpace: cs, colors: [rgb(0.90, 0.76, 0.42), rgb(0.72, 0.55, 0.24)] as CFArray, locations: [0, 1])!
ctx.saveGState()
ctx.addPath(lidPath)
ctx.clip()
ctx.drawLinearGradient(lidGrad, start: CGPoint(x: lid.minX, y: lid.maxY), end: CGPoint(x: lid.minX, y: lid.minY), options: [])
ctx.restoreGState()
ctx.addPath(lidPath)
ctx.setStrokeColor(rgb(0.35, 0.26, 0.12))
ctx.setLineWidth(6)
ctx.strokePath()

let shine = CGMutablePath()
shine.move(to: CGPoint(x: jarRect.minX + w * 0.14, y: jarRect.maxY - h * 0.22))
shine.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.10, y: jarRect.minY + h * 0.32), control: CGPoint(x: jarRect.minX + w * 0.02, y: jarRect.midY))
ctx.addPath(shine)
ctx.setStrokeColor(rgb(1, 1, 1, 0.55))
ctx.setLineWidth(26)
ctx.setLineCap(.round)
ctx.strokePath()

let vGrad = CGGradient(colorsSpace: cs, colors: [rgb(0, 0, 0, 0), rgb(0.1, 0.16, 0.08, 0.22)] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(vGrad, startCenter: CGPoint(x: S / 2, y: S / 2), startRadius: S * 0.4, endCenter: CGPoint(x: S / 2, y: S / 2), endRadius: S * 0.74, options: [.drawsAfterEndLocation])

let img = ctx.makeImage()!
let url = URL(fileURLWithPath: outPath) as CFURL
let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("icon written")
