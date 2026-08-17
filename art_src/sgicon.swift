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
    var state: UInt64 = 619
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

func grad(_ stops: [(CGFloat, CGColor)]) -> CGGradient {
    CGGradient(colorsSpace: cs, colors: stops.map { $0.1 } as CFArray, locations: stops.map { $0.0 })!
}

let bg = grad([
    (0.0, rgb(0.05, 0.10, 0.06)),
    (0.5, rgb(0.09, 0.17, 0.10)),
    (1.0, rgb(0.15, 0.26, 0.15)),
])
ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: S), options: [])

for k in 0..<3 {
    let beam = CGMutablePath()
    let bx = S * (0.55 + CGFloat(k) * 0.16)
    beam.move(to: CGPoint(x: bx, y: S))
    beam.addLine(to: CGPoint(x: bx + 130, y: S))
    beam.addLine(to: CGPoint(x: bx - 260, y: 0))
    beam.addLine(to: CGPoint(x: bx - 390, y: 0))
    beam.closeSubpath()
    ctx.addPath(beam)
    ctx.setFillColor(rgb(0.85, 0.95, 0.70, 0.05 + CGFloat(2 - k) * 0.02))
    ctx.fillPath()
}

let sillY = S * 0.15
let sill = grad([(0.0, rgb(0.28, 0.19, 0.11)), (0.3, rgb(0.38, 0.26, 0.15)), (1.0, rgb(0.14, 0.09, 0.05))])
ctx.saveGState()
ctx.clip(to: CGRect(x: 0, y: 0, width: S, height: sillY))
ctx.drawLinearGradient(sill, start: CGPoint(x: 0, y: sillY), end: CGPoint(x: 0, y: 0), options: [])
for _ in 0..<14 {
    let gy = rand.next() * sillY
    ctx.setStrokeColor(rgb(0.08, 0.05, 0.02, rand.range(0.15, 0.3)))
    ctx.setLineWidth(rand.range(1.5, 3))
    ctx.move(to: CGPoint(x: 0, y: gy))
    ctx.addLine(to: CGPoint(x: S, y: gy + rand.range(-5, 5)))
    ctx.strokePath()
}
ctx.restoreGState()

let jarRect = CGRect(x: S * 0.17, y: sillY - 4, width: S * 0.66, height: S * 0.74)
let w = jarRect.width
let h = jarRect.height
let jar = CGMutablePath()
jar.move(to: CGPoint(x: jarRect.minX + w * 0.30, y: jarRect.maxY - h * 0.045))
jar.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.025, y: jarRect.midY + h * 0.06), control: CGPoint(x: jarRect.minX + w * 0.015, y: jarRect.maxY - h * 0.20))
jar.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.15, y: jarRect.minY + h * 0.035), control: CGPoint(x: jarRect.minX + w * 0.035, y: jarRect.minY + h * 0.09))
jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.15, y: jarRect.minY + h * 0.035), control: CGPoint(x: jarRect.midX, y: jarRect.minY - h * 0.018))
jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.025, y: jarRect.midY + h * 0.06), control: CGPoint(x: jarRect.maxX - w * 0.035, y: jarRect.minY + h * 0.09))
jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.30, y: jarRect.maxY - h * 0.045), control: CGPoint(x: jarRect.maxX - w * 0.015, y: jarRect.maxY - h * 0.20))
jar.closeSubpath()

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -22), blur: 56, color: rgb(0, 0, 0, 0.6))
ctx.addPath(jar)
ctx.setFillColor(rgb(0.05, 0.09, 0.06))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(jar)
ctx.clip()

let innerAir = grad([
    (0.0, rgb(0.55, 0.72, 0.62, 0.30)),
    (0.5, rgb(0.72, 0.86, 0.74, 0.22)),
    (1.0, rgb(0.88, 0.96, 0.82, 0.30)),
])
ctx.drawLinearGradient(innerAir, start: CGPoint(x: 0, y: jarRect.minY), end: CGPoint(x: 0, y: jarRect.maxY), options: [])

let beamIn = CGMutablePath()
beamIn.move(to: CGPoint(x: jarRect.midX + w * 0.05, y: jarRect.maxY))
beamIn.addLine(to: CGPoint(x: jarRect.maxX, y: jarRect.maxY))
beamIn.addLine(to: CGPoint(x: jarRect.midX - w * 0.1, y: jarRect.minY))
beamIn.addLine(to: CGPoint(x: jarRect.minX + w * 0.14, y: jarRect.minY))
beamIn.closeSubpath()
ctx.addPath(beamIn)
ctx.setFillColor(rgb(0.95, 1.0, 0.8, 0.10))
ctx.fillPath()

let pebbleTop = jarRect.minY + h * 0.085
let soilTop = jarRect.minY + h * 0.20
ctx.setFillColor(rgb(0.30, 0.30, 0.28))
ctx.fill(CGRect(x: jarRect.minX, y: jarRect.minY, width: w, height: pebbleTop - jarRect.minY))
for _ in 0..<22 {
    let px = jarRect.minX + rand.next() * w
    let py = jarRect.minY + rand.next() * (pebbleTop - jarRect.minY - 8)
    let d = rand.range(16, 34)
    let tone = rand.range(0.45, 0.72)
    let peb = grad([(0.0, rgb(tone + 0.15, tone + 0.14, tone + 0.10)), (1.0, rgb(tone - 0.14, tone - 0.14, tone - 0.12))])
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: px, y: py, width: d * 1.35, height: d))
    ctx.clip()
    ctx.drawLinearGradient(peb, start: CGPoint(x: px, y: py + d), end: CGPoint(x: px, y: py), options: [])
    ctx.restoreGState()
}
let soilGrad = grad([(0.0, rgb(0.16, 0.11, 0.07)), (0.6, rgb(0.24, 0.17, 0.11)), (1.0, rgb(0.30, 0.22, 0.14))])
ctx.saveGState()
ctx.clip(to: CGRect(x: jarRect.minX, y: pebbleTop, width: w, height: soilTop - pebbleTop))
ctx.drawLinearGradient(soilGrad, start: CGPoint(x: 0, y: pebbleTop), end: CGPoint(x: 0, y: soilTop), options: [])
ctx.restoreGState()
for _ in 0..<60 {
    let px = jarRect.minX + rand.next() * w
    let py = pebbleTop + rand.next() * (soilTop - pebbleTop)
    ctx.setFillColor(rgb(0.05, 0.03, 0.02, rand.range(0.2, 0.5)))
    ctx.fillEllipse(in: CGRect(x: px, y: py, width: rand.range(3, 7), height: rand.range(2, 5)))
}

func leaf(_ at: CGPoint, _ angle: CGFloat, _ len: CGFloat, _ wide: CGFloat, _ top: CGColor, _ bottom: CGColor, outline: CGColor) {
    ctx.saveGState()
    ctx.translateBy(x: at.x, y: at.y)
    ctx.rotate(by: angle)
    let p = CGMutablePath()
    p.move(to: .zero)
    p.addQuadCurve(to: CGPoint(x: 0, y: len), control: CGPoint(x: wide, y: len * 0.55))
    p.addQuadCurve(to: .zero, control: CGPoint(x: -wide, y: len * 0.45))
    ctx.addPath(p)
    ctx.clip()
    let g = grad([(0.0, bottom), (1.0, top)])
    ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: len), options: [])
    ctx.restoreGState()
    ctx.saveGState()
    ctx.translateBy(x: at.x, y: at.y)
    ctx.rotate(by: angle)
    let p2 = CGMutablePath()
    p2.move(to: .zero)
    p2.addQuadCurve(to: CGPoint(x: 0, y: len), control: CGPoint(x: wide, y: len * 0.55))
    p2.addQuadCurve(to: .zero, control: CGPoint(x: -wide, y: len * 0.45))
    ctx.addPath(p2)
    ctx.setStrokeColor(outline)
    ctx.setLineWidth(2.5)
    ctx.strokePath()
    ctx.setStrokeColor(rgb(0.9, 1.0, 0.8, 0.35))
    ctx.setLineWidth(2)
    ctx.move(to: CGPoint(x: 0, y: len * 0.08))
    ctx.addLine(to: CGPoint(x: 0, y: len * 0.9))
    ctx.strokePath()
    ctx.restoreGState()
}

func fern(_ base: CGPoint, _ scale: CGFloat, _ deep: Bool) {
    let stemTop = rgb(0.10, 0.22, 0.10)
    for i in 0..<6 {
        let ang = CGFloat.pi / 2 + (CGFloat(i) / 5 - 0.5) * 1.6
        let len = (240 + rand.range(0, 120)) * scale
        let tip = CGPoint(x: base.x + cos(ang) * len * 0.55, y: base.y + sin(ang) * len)
        let ctrl = CGPoint(x: base.x + cos(ang) * len * 0.28, y: base.y + sin(ang) * len * 0.6)
        ctx.setStrokeColor(stemTop)
        ctx.setLineWidth(7 * scale)
        ctx.setLineCap(.round)
        ctx.move(to: base)
        ctx.addQuadCurve(to: tip, control: ctrl)
        ctx.strokePath()
        var t: CGFloat = 0.2
        while t < 0.98 {
            let bx = (1 - t) * (1 - t) * base.x + 2 * (1 - t) * t * ctrl.x + t * t * tip.x
            let by = (1 - t) * (1 - t) * base.y + 2 * (1 - t) * t * ctrl.y + t * t * tip.y
            let leafLen = (1 - t * 0.7) * 60 * scale
            let g1 = deep ? rgb(0.16, 0.34, 0.16) : rgb(0.34, 0.58, 0.28)
            let g2 = deep ? rgb(0.08, 0.20, 0.09) : rgb(0.18, 0.38, 0.16)
            for side in [-1.0, 1.0] {
                leaf(CGPoint(x: bx, y: by), ang + CGFloat(side) * 1.2, leafLen, leafLen * 0.32, g1, g2, outline: rgb(0.05, 0.12, 0.05, 0.6))
            }
            t += 0.13
        }
    }
}

fern(CGPoint(x: jarRect.midX - w * 0.20, y: soilTop - 6), 1.06, true)
fern(CGPoint(x: jarRect.midX + w * 0.24, y: soilTop - 6), 0.8, true)

for _ in 0..<130 {
    let a = rand.next() * .pi
    let rr = rand.next()
    let mx = jarRect.midX - w * 0.16 + cos(a) * w * 0.17 * rr
    let my = soilTop - 4 + abs(sin(a)) * 60 * rr
    let d = rand.range(9, 20)
    let bright = rand.next()
    ctx.setFillColor(rgb(0.18 + bright * 0.22, 0.34 + bright * 0.26, 0.14 + bright * 0.16))
    ctx.fillEllipse(in: CGRect(x: mx - d / 2, y: my - d / 2, width: d, height: d))
}

let fitBase = CGPoint(x: jarRect.midX + w * 0.17, y: soilTop - 4)
for i in 0..<7 {
    let ang = CGFloat.pi / 2 + (CGFloat(i) / 6 - 0.5) * 1.7
    let len = rand.range(120, 210)
    let tip = CGPoint(x: fitBase.x + cos(ang) * len * 0.6, y: fitBase.y + sin(ang) * len)
    ctx.setStrokeColor(rgb(0.12, 0.24, 0.12))
    ctx.setLineWidth(6)
    ctx.move(to: fitBase)
    ctx.addQuadCurve(to: tip, control: CGPoint(x: fitBase.x + cos(ang) * len * 0.3, y: fitBase.y + sin(ang) * len * 0.55))
    ctx.strokePath()
    ctx.saveGState()
    ctx.translateBy(x: tip.x, y: tip.y)
    ctx.rotate(by: ang - .pi / 2)
    let lw: CGFloat = rand.range(38, 54)
    let ll = lw * 1.5
    let lp = CGPath(ellipseIn: CGRect(x: -lw / 2, y: -ll * 0.2, width: lw, height: ll), transform: nil)
    ctx.addPath(lp)
    ctx.clip()
    let lg = grad([(0.0, rgb(0.14, 0.30, 0.14)), (1.0, rgb(0.30, 0.50, 0.24))])
    ctx.drawLinearGradient(lg, start: CGPoint(x: 0, y: -ll * 0.2), end: CGPoint(x: 0, y: ll * 0.8), options: [])
    ctx.setStrokeColor(rgb(0.94, 0.66, 0.70, 0.9))
    ctx.setLineWidth(2.4)
    ctx.move(to: CGPoint(x: 0, y: -ll * 0.12))
    ctx.addLine(to: CGPoint(x: 0, y: ll * 0.72))
    for tt in stride(from: 0.05, through: 0.6, by: 0.14) {
        let vy = ll * CGFloat(tt)
        ctx.move(to: CGPoint(x: 0, y: vy))
        ctx.addQuadCurve(to: CGPoint(x: lw * 0.34, y: vy + ll * 0.1), control: CGPoint(x: lw * 0.18, y: vy))
        ctx.move(to: CGPoint(x: 0, y: vy))
        ctx.addQuadCurve(to: CGPoint(x: -lw * 0.34, y: vy + ll * 0.1), control: CGPoint(x: -lw * 0.18, y: vy))
    }
    ctx.strokePath()
    ctx.restoreGState()
}

for _ in 0..<26 {
    let side: CGFloat = rand.next() > 0.5 ? 1 : 0
    let px = jarRect.minX + w * (0.05 + side * 0.84) + rand.range(0, w * 0.06)
    let py = jarRect.minY + h * rand.range(0.25, 0.9)
    let d = rand.range(5, 11)
    let dropG = grad([(0.0, rgb(1, 1, 1, 0.75)), (1.0, rgb(1, 1, 1, 0.08))])
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: px, y: py, width: d, height: d * 1.5))
    ctx.clip()
    ctx.drawRadialGradient(dropG, startCenter: CGPoint(x: px + d * 0.3, y: py + d * 1.0), startRadius: 0, endCenter: CGPoint(x: px + d * 0.5, y: py + d * 0.75), endRadius: d, options: [])
    ctx.restoreGState()
    if rand.next() > 0.6 {
        ctx.setStrokeColor(rgb(1, 1, 1, 0.14))
        ctx.setLineWidth(d * 0.5)
        ctx.move(to: CGPoint(x: px + d * 0.5, y: py))
        ctx.addLine(to: CGPoint(x: px + d * 0.5, y: py - rand.range(14, 40)))
        ctx.strokePath()
    }
}

let mist = grad([(0.0, rgb(0.9, 1.0, 0.9, 0.22)), (1.0, rgb(0.9, 1.0, 0.9, 0.0))])
ctx.drawLinearGradient(mist, start: CGPoint(x: 0, y: jarRect.minY + h * 0.86), end: CGPoint(x: 0, y: jarRect.minY + h * 0.62), options: [])
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(jar)
ctx.clip()
let glassSheen = CGMutablePath()
glassSheen.move(to: CGPoint(x: jarRect.minX + w * 0.13, y: jarRect.maxY - h * 0.13))
glassSheen.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.085, y: jarRect.minY + h * 0.24),
                        control: CGPoint(x: jarRect.minX + w * 0.005, y: jarRect.midY))
ctx.addPath(glassSheen)
ctx.setStrokeColor(rgb(1, 1, 1, 0.5))
ctx.setLineWidth(w * 0.05)
ctx.setLineCap(.round)
ctx.strokePath()
let glassSheen2 = CGMutablePath()
glassSheen2.move(to: CGPoint(x: jarRect.maxX - w * 0.12, y: jarRect.maxY - h * 0.16))
glassSheen2.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.10, y: jarRect.midY),
                         control: CGPoint(x: jarRect.maxX - w * 0.035, y: jarRect.maxY - h * 0.34))
ctx.addPath(glassSheen2)
ctx.setStrokeColor(rgb(1, 1, 1, 0.25))
ctx.setLineWidth(w * 0.022)
ctx.setLineCap(.round)
ctx.strokePath()
let topGlow = grad([(0.0, rgb(1, 1, 0.95, 0.20)), (1.0, rgb(1, 1, 0.95, 0.0))])
ctx.drawLinearGradient(topGlow, start: CGPoint(x: 0, y: jarRect.maxY), end: CGPoint(x: 0, y: jarRect.maxY - h * 0.2), options: [])
ctx.restoreGState()

ctx.addPath(jar)
ctx.setStrokeColor(rgb(0.55, 0.72, 0.64, 0.9))
ctx.setLineWidth(7)
ctx.strokePath()
ctx.addPath(jar)
ctx.setStrokeColor(rgb(0.12, 0.22, 0.16, 0.8))
ctx.setLineWidth(2.5)
ctx.strokePath()

let lid = CGRect(x: jarRect.minX + w * 0.235, y: jarRect.maxY - 20, width: w * 0.53, height: 78)
let lidPath = CGPath(roundedRect: lid, cornerWidth: 14, cornerHeight: 14, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 16, color: rgb(0, 0, 0, 0.4))
ctx.addPath(lidPath)
ctx.setFillColor(rgb(0.3, 0.2, 0.08))
ctx.fillPath()
ctx.restoreGState()
let lidGrad = grad([(0.0, rgb(0.52, 0.36, 0.13)), (0.35, rgb(0.85, 0.66, 0.30)), (0.55, rgb(0.96, 0.82, 0.48)), (0.75, rgb(0.78, 0.58, 0.24)), (1.0, rgb(0.45, 0.30, 0.10))])
ctx.saveGState()
ctx.addPath(lidPath)
ctx.clip()
ctx.drawLinearGradient(lidGrad, start: CGPoint(x: lid.minX, y: 0), end: CGPoint(x: lid.maxX, y: 0), options: [])
for i in 1..<7 {
    let rx = lid.minX + lid.width * CGFloat(i) / 7
    ctx.setStrokeColor(rgb(0.3, 0.2, 0.06, 0.35))
    ctx.setLineWidth(3)
    ctx.move(to: CGPoint(x: rx, y: lid.minY + 6))
    ctx.addLine(to: CGPoint(x: rx, y: lid.maxY - 6))
    ctx.strokePath()
}
ctx.restoreGState()
ctx.addPath(lidPath)
ctx.setStrokeColor(rgb(0.25, 0.16, 0.05, 0.8))
ctx.setLineWidth(3)
ctx.strokePath()

for _ in 0..<30 {
    let x = rand.next() * S
    let y = S * 0.3 + rand.next() * S * 0.68
    let d = rand.range(2, 4.5)
    ctx.setFillColor(rgb(0.92, 1.0, 0.75, rand.range(0.06, 0.22)))
    ctx.fillEllipse(in: CGRect(x: x, y: y, width: d, height: d))
}

let vin = grad([(0.0, rgb(0, 0, 0, 0)), (1.0, rgb(0.01, 0.05, 0.02, 0.45))])
ctx.drawRadialGradient(vin, startCenter: CGPoint(x: S / 2, y: S / 2), startRadius: S * 0.42, endCenter: CGPoint(x: S / 2, y: S / 2), endRadius: S * 0.76, options: [.drawsAfterEndLocation])

let img = ctx.makeImage()!
let url = URL(fileURLWithPath: outPath) as CFURL
let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("icon written")
