import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "./out"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    func cg(_ a: CGFloat = 1) -> CGColor { CGColor(red: r, green: g, blue: b, alpha: a) }
    func mix(_ o: RGB, _ t: CGFloat) -> RGB { RGB(r: r + (o.r - r) * t, g: g + (o.g - g) * t, b: b + (o.b - b) * t) }
    func darker(_ t: CGFloat) -> RGB { mix(RGB(r: 0.08, g: 0.06, b: 0.05), t) }
    func lighter(_ t: CGFloat) -> RGB { mix(RGB(r: 0.99, g: 0.97, b: 0.93), t) }
}

let paperTone = RGB(r: 0.952, g: 0.945, b: 0.895)
let paperEdge = RGB(r: 0.90, g: 0.85, b: 0.76)
let inkTone = RGB(r: 0.20, g: 0.16, b: 0.12)
let brassTone = RGB(r: 0.78, g: 0.63, b: 0.30)
let pineTone = RGB(r: 0.35, g: 0.48, b: 0.31)
let redTone = RGB(r: 0.73, g: 0.42, b: 0.25)
let steelTone = RGB(r: 0.45, g: 0.43, b: 0.40)
let grassTone = RGB(r: 0.55, g: 0.64, b: 0.40)
let skyTone = RGB(r: 0.80, g: 0.85, b: 0.82)

final class Rand {
    var state: UInt64
    init(_ seed: UInt64) { state = seed &* 2862933555777941757 &+ 3037000493 }
    func next() -> CGFloat {
        state = state &* 2862933555777941757 &+ 3037000493
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
    func range(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { lo + next() * (hi - lo) }
    func int(_ n: Int) -> Int { n <= 0 ? 0 : min(n - 1, Int(next() * CGFloat(n))) }
}

let renderScale: CGFloat = 1.7

func makeContext(_ w: Int, _ h: Int) -> CGContext {
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    let pw = Int(CGFloat(w) * renderScale)
    let ph = Int(CGFloat(h) * renderScale)
    let ctx = CGContext(data: nil, width: pw, height: ph, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setAllowsAntialiasing(true)
    ctx.interpolationQuality = .high
    ctx.scaleBy(x: renderScale, y: renderScale)
    return ctx
}

func saveJPEG(_ ctx: CGContext, _ name: String, quality: CGFloat = 0.90) {
    let img = ctx.makeImage()!
    let url = URL(fileURLWithPath: "\(outDir)/\(name).jpg") as CFURL
    let dest = CGImageDestinationCreateWithURL(url, UTType.jpeg.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
    CGImageDestinationFinalize(dest)
    print("wrote \(name).jpg \(ctx.width)x\(ctx.height)")
}

func savePNG(_ ctx: CGContext, _ path: String) {
    let img = ctx.makeImage()!
    let url = URL(fileURLWithPath: path) as CFURL
    let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
    print("wrote \(path)")
}

func drawText(_ ctx: CGContext, _ text: String, font: String, size: CGFloat, at p: CGPoint, color: CGColor, centered: Bool = true, tracking: CGFloat = 0) {
    let ctFont = CTFontCreateWithName(font as CFString, size, nil)
    let attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): ctFont,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        NSAttributedString.Key(kCTKernAttributeName as String): tracking,
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let line = CTLineCreateWithAttributedString(str)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: centered ? p.x - bounds.width / 2 : p.x, y: p.y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

func paperBase(_ ctx: CGContext, _ w: CGFloat, _ h: CGFloat, seed: UInt64, tone: RGB = paperTone) {
    let rand = Rand(seed)
    ctx.setFillColor(tone.cg())
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    let grad = CGGradient(colorsSpace: nil, colors: [tone.lighter(0.05).cg(), tone.cg(), paperEdge.cg()] as CFArray, locations: [0, 0.55, 1])!
    ctx.saveGState()
    ctx.drawRadialGradient(grad, startCenter: CGPoint(x: w * 0.5, y: h * 0.6), startRadius: 0, endCenter: CGPoint(x: w * 0.5, y: h * 0.5), endRadius: max(w, h) * 0.75, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    ctx.restoreGState()
    for _ in 0..<2200 {
        let x = rand.next() * w
        let y = rand.next() * h
        let len = rand.range(2, 9)
        let ang = rand.next() * .pi
        ctx.setStrokeColor(inkTone.cg(rand.range(0.015, 0.05)))
        ctx.setLineWidth(rand.range(0.5, 1.1))
        ctx.move(to: CGPoint(x: x, y: y))
        ctx.addLine(to: CGPoint(x: x + cos(ang) * len, y: y + sin(ang) * len))
        ctx.strokePath()
    }
    for _ in 0..<44 {
        let x = rand.next() * w
        let y = rand.next() * h
        let r = rand.range(6, 42)
        ctx.setFillColor(RGB(r: 0.72, g: 0.62, b: 0.45).cg(rand.range(0.02, 0.06)))
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4))
    }
    for _ in 0..<Int(w * h / 70) {
        let x = rand.next() * w
        let y = rand.next() * h
        let d = rand.range(0.5, 1.3)
        ctx.setFillColor(inkTone.cg(rand.range(0.015, 0.045)))
        ctx.fill(CGRect(x: x, y: y, width: d, height: d))
    }
}

func plateFrame(_ ctx: CGContext, _ w: CGFloat, _ h: CGFloat, inset: CGFloat) {
    let outer = CGRect(x: inset, y: inset, width: w - inset * 2, height: h - inset * 2)
    ctx.setStrokeColor(inkTone.cg(0.75))
    ctx.setLineWidth(3)
    ctx.stroke(outer)
    ctx.setLineWidth(1.2)
    ctx.stroke(outer.insetBy(dx: 9, dy: 9))
    let corners = [
        CGPoint(x: outer.minX, y: outer.minY), CGPoint(x: outer.maxX, y: outer.minY),
        CGPoint(x: outer.minX, y: outer.maxY), CGPoint(x: outer.maxX, y: outer.maxY),
    ]
    for c in corners {
        ctx.setFillColor(inkTone.cg(0.8))
        let d: CGFloat = 7
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y)
        ctx.rotate(by: .pi / 4)
        ctx.fill(CGRect(x: -d / 2, y: -d / 2, width: d, height: d))
        ctx.restoreGState()
    }
}

func wobblyLine(_ ctx: CGContext, from a: CGPoint, to b: CGPoint, rand: Rand, width: CGFloat, color: CGColor, wobble: CGFloat = 1.4) {
    let steps = max(3, Int(hypot(b.x - a.x, b.y - a.y) / 26))
    ctx.setStrokeColor(color)
    ctx.setLineWidth(width)
    ctx.setLineCap(.round)
    ctx.move(to: a)
    for i in 1...steps {
        let t = CGFloat(i) / CGFloat(steps)
        let px = a.x + (b.x - a.x) * t + rand.range(-wobble, wobble)
        let py = a.y + (b.y - a.y) * t + rand.range(-wobble, wobble)
        ctx.addLine(to: CGPoint(x: px, y: py))
    }
    ctx.strokePath()
}

func inkRect(_ ctx: CGContext, _ rect: CGRect, rand: Rand, width: CGFloat = 2.4, color: CGColor = inkTone.cg(0.85)) {
    wobblyLine(ctx, from: CGPoint(x: rect.minX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.minY), rand: rand, width: width, color: color)
    wobblyLine(ctx, from: CGPoint(x: rect.maxX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.maxY), rand: rand, width: width, color: color)
    wobblyLine(ctx, from: CGPoint(x: rect.maxX, y: rect.maxY), to: CGPoint(x: rect.minX, y: rect.maxY), rand: rand, width: width, color: color)
    wobblyLine(ctx, from: CGPoint(x: rect.minX, y: rect.maxY), to: CGPoint(x: rect.minX, y: rect.minY), rand: rand, width: width, color: color)
}

func hatchRect(_ ctx: CGContext, _ rect: CGRect, rand: Rand, angle: CGFloat = -0.7, gap: CGFloat = 7, alpha: CGFloat = 0.28, width: CGFloat = 1.1) {
    ctx.saveGState()
    ctx.clip(to: rect)
    let diag = hypot(rect.width, rect.height)
    let n = Int(diag / gap) + 2
    let cx = rect.midX
    let cy = rect.midY
    let dirX = cos(angle)
    let dirY = sin(angle)
    let perpX = -dirY
    let perpY = dirX
    for i in -n...n {
        let off = CGFloat(i) * gap + rand.range(-1, 1)
        let baseX = cx + perpX * off
        let baseY = cy + perpY * off
        ctx.setStrokeColor(inkTone.cg(alpha * rand.range(0.7, 1.0)))
        ctx.setLineWidth(width)
        ctx.move(to: CGPoint(x: baseX - dirX * diag, y: baseY - dirY * diag))
        ctx.addLine(to: CGPoint(x: baseX + dirX * diag, y: baseY + dirY * diag))
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func hatchPath(_ ctx: CGContext, _ path: CGPath, rand: Rand, angle: CGFloat = -0.7, gap: CGFloat = 7, alpha: CGFloat = 0.28, width: CGFloat = 1.1) {
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let rect = path.boundingBox
    let diag = hypot(rect.width, rect.height)
    let n = Int(diag / gap) + 2
    let dirX = cos(angle)
    let dirY = sin(angle)
    let perpX = -dirY
    let perpY = dirX
    for i in -n...n {
        let off = CGFloat(i) * gap + rand.range(-1, 1)
        let baseX = rect.midX + perpX * off
        let baseY = rect.midY + perpY * off
        ctx.setStrokeColor(inkTone.cg(alpha * rand.range(0.7, 1.0)))
        ctx.setLineWidth(width)
        ctx.move(to: CGPoint(x: baseX - dirX * diag, y: baseY - dirY * diag))
        ctx.addLine(to: CGPoint(x: baseX + dirX * diag, y: baseY + dirY * diag))
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func groundShadow(_ ctx: CGContext, cx: CGFloat, y: CGFloat, w: CGFloat, rand: Rand) {
    let rect = CGRect(x: cx - w / 2, y: y - 14, width: w, height: 24)
    hatchRect(ctx, rect, rand: rand, angle: 0.05, gap: 5, alpha: 0.20, width: 1.0)
}

struct Livery {
    var body: RGB
    var roof: RGB
    var accent: RGB
}

func washFill(_ ctx: CGContext, _ path: CGPath, _ color: RGB, rand: Rand, alpha: CGFloat = 0.85) {
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let box = path.boundingBox
    ctx.setFillColor(color.cg(alpha))
    ctx.fill(box)
    let grad = CGGradient(colorsSpace: nil, colors: [color.lighter(0.25).cg(0.55), color.cg(0.0), color.darker(0.3).cg(0.45)] as CFArray, locations: [0, 0.5, 1])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: box.minX, y: box.maxY), end: CGPoint(x: box.minX, y: box.minY), options: [])
    for _ in 0..<Int(box.width * box.height / 2400) {
        let x = box.minX + rand.next() * box.width
        let y = box.minY + rand.next() * box.height
        ctx.setFillColor(color.darker(0.35).cg(rand.range(0.03, 0.10)))
        ctx.fillEllipse(in: CGRect(x: x, y: y, width: rand.range(2, 7), height: rand.range(2, 5)))
    }
    ctx.restoreGState()
}

func rrect(_ r: CGRect, _ rad: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: min(rad, r.width / 2), cornerHeight: min(rad, r.height / 2), transform: nil)
}

let mossTone = RGB(r: 0.353, g: 0.478, b: 0.310)
let mossDeep = RGB(r: 0.243, g: 0.361, b: 0.216)
let fernTone = RGB(r: 0.478, g: 0.596, b: 0.373)
let fernLight = RGB(r: 0.639, g: 0.729, b: 0.510)
let soilTone = RGB(r: 0.353, g: 0.271, b: 0.196)
let glassTone = RGB(r: 0.573, g: 0.663, b: 0.647)
let clayTone = RGB(r: 0.718, g: 0.475, b: 0.337)
let pinkTone = RGB(r: 0.85, g: 0.55, b: 0.58)

func titleBlock(_ ctx: CGContext, w: CGFloat, name: String, sub: String, y: CGFloat = 92) {
    drawText(ctx, name.uppercased(), font: "Georgia-Bold", size: 52, at: CGPoint(x: w / 2, y: y + 34), color: inkTone.cg(0.92), tracking: 5)
    drawText(ctx, sub, font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: y - 14), color: inkTone.cg(0.62))
    let rand = Rand(9)
    wobblyLine(ctx, from: CGPoint(x: w / 2 - 260, y: y + 12), to: CGPoint(x: w / 2 - 190, y: y + 12), rand: rand, width: 1.6, color: inkTone.cg(0.5))
    wobblyLine(ctx, from: CGPoint(x: w / 2 + 190, y: y + 12), to: CGPoint(x: w / 2 + 260, y: y + 12), rand: rand, width: 1.6, color: inkTone.cg(0.5))
    ctx.setFillColor(mossTone.cg(0.9))
    ctx.fillEllipse(in: CGRect(x: w / 2 - 174, y: y + 8, width: 9, height: 9))
    ctx.fillEllipse(in: CGRect(x: w / 2 + 165, y: y + 8, width: 9, height: 9))
}

func inkLeaf(_ ctx: CGContext, at p: CGPoint, angle: CGFloat, len: CGFloat, wide: CGFloat, fill: RGB, rand: Rand, vein: Bool = true) {
    ctx.saveGState()
    ctx.translateBy(x: p.x, y: p.y)
    ctx.rotate(by: angle)
    let leaf = CGMutablePath()
    leaf.move(to: .zero)
    leaf.addQuadCurve(to: CGPoint(x: 0, y: len), control: CGPoint(x: wide, y: len * 0.5))
    leaf.addQuadCurve(to: .zero, control: CGPoint(x: -wide, y: len * 0.5))
    washFill(ctx, leaf, fill, rand: rand)
    ctx.addPath(leaf)
    ctx.setStrokeColor(inkTone.cg(0.75))
    ctx.setLineWidth(2)
    ctx.strokePath()
    if vein {
        ctx.setStrokeColor(inkTone.cg(0.45))
        ctx.setLineWidth(1.2)
        ctx.move(to: CGPoint(x: 0, y: len * 0.06))
        ctx.addLine(to: CGPoint(x: 0, y: len * 0.94))
        for t in stride(from: 0.25, through: 0.8, by: 0.18) {
            ctx.move(to: CGPoint(x: 0, y: len * CGFloat(t)))
            ctx.addLine(to: CGPoint(x: wide * 0.5, y: len * CGFloat(t) + len * 0.08))
            ctx.move(to: CGPoint(x: 0, y: len * CGFloat(t)))
            ctx.addLine(to: CGPoint(x: -wide * 0.5, y: len * CGFloat(t) + len * 0.08))
        }
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func rootTangle(_ ctx: CGContext, at base: CGPoint, rand: Rand, spread: CGFloat = 70) {
    for _ in 0..<6 {
        let root = CGMutablePath()
        root.move(to: base)
        let dx = rand.range(-spread, spread)
        root.addCurve(to: CGPoint(x: base.x + dx, y: base.y - rand.range(40, 90)),
                      control1: CGPoint(x: base.x + dx * 0.2, y: base.y - 20),
                      control2: CGPoint(x: base.x + dx * 0.7, y: base.y - 50))
        ctx.addPath(root)
        ctx.setStrokeColor(soilTone.cg(rand.range(0.4, 0.7)))
        ctx.setLineWidth(rand.range(1.4, 2.6))
        ctx.strokePath()
    }
}

func specimenGround(_ ctx: CGContext, cx: CGFloat, y: CGFloat, rand: Rand) {
    hatchRect(ctx, CGRect(x: cx - 240, y: y - 22, width: 480, height: 26), rand: rand, angle: 0.04, gap: 6, alpha: 0.18, width: 1)
    wobblyLine(ctx, from: CGPoint(x: cx - 280, y: y), to: CGPoint(x: cx + 280, y: y), rand: rand, width: 2.4, color: inkTone.cg(0.6))
}

func drawPlantPlate(_ speciesID: String, _ name: String, _ latin: String, _ seed: UInt64, draw: (CGContext, CGFloat, CGFloat, Rand) -> Void) {
    let W = 1400, H = 1000
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(seed)
    paperBase(ctx, w, h, seed: seed)
    plateFrame(ctx, w, h, inset: 44)
    draw(ctx, w, h, rand)
    titleBlock(ctx, w: w, name: name, sub: latin)
    saveJPEG(ctx, "plant_\(speciesID)")
}

drawPlantPlate("cushionmoss", "Cushion Moss", "Leucobryum glaucum · Plate I", 401) { ctx, w, h, rand in
    let cx = w / 2
    let baseY = h * 0.30
    specimenGround(ctx, cx: cx, y: baseY, rand: rand)
    for mound in 0..<3 {
        let mx = cx + CGFloat(mound - 1) * 250
        let mw: CGFloat = mound == 1 ? 320 : 210
        let mh = mw * 0.42
        for _ in 0..<Int(mw * 0.9) {
            let a = rand.next() * .pi
            let rr = sqrt(rand.next())
            let px = mx + cos(a) * mw * 0.5 * rr
            let py = baseY + abs(sin(a)) * mh * rr
            let r = rand.range(4, 10)
            let tone = [mossTone, mossDeep, fernTone][rand.int(3)]
            ctx.setFillColor(tone.cg(rand.range(0.5, 0.95)))
            ctx.fillEllipse(in: CGRect(x: px - r / 2, y: py - r / 2, width: r, height: r))
        }
        let outline = CGMutablePath()
        outline.move(to: CGPoint(x: mx - mw / 2, y: baseY))
        outline.addQuadCurve(to: CGPoint(x: mx + mw / 2, y: baseY), control: CGPoint(x: mx, y: baseY + mh * 2.2))
        ctx.addPath(outline)
        ctx.setStrokeColor(inkTone.cg(0.55))
        ctx.setLineWidth(2)
        ctx.strokePath()
    }
    let lens = CGPoint(x: w * 0.82, y: h * 0.62)
    ctx.setFillColor(paperTone.lighter(0.1).cg(0.95))
    ctx.fillEllipse(in: CGRect(x: lens.x - 120, y: lens.y - 120, width: 240, height: 240))
    ctx.setStrokeColor(inkTone.cg(0.8))
    ctx.setLineWidth(3.4)
    ctx.strokeEllipse(in: CGRect(x: lens.x - 120, y: lens.y - 120, width: 240, height: 240))
    for i in 0..<7 {
        let a = CGFloat(i) / 7 * 2 * .pi
        let bx = lens.x + cos(a) * 50
        let by = lens.y + sin(a) * 50
        let star = CGMutablePath()
        for k in 0..<6 {
            let sa = CGFloat(k) / 6 * 2 * .pi
            star.move(to: CGPoint(x: bx, y: by))
            star.addLine(to: CGPoint(x: bx + cos(sa) * 26, y: by + sin(sa) * 26))
        }
        ctx.addPath(star)
        ctx.setStrokeColor(mossDeep.cg(0.8))
        ctx.setLineWidth(2)
        ctx.strokePath()
    }
    drawText(ctx, "each leaf, magnified", font: "Georgia-Italic", size: 24, at: CGPoint(x: lens.x, y: lens.y - 150), color: inkTone.cg(0.6))
}

drawPlantPlate("fernsprout", "Fern Sprout", "Asplenium bulbiferum · Plate II", 402) { ctx, w, h, rand in
    let cx = w / 2
    let baseY = h * 0.26
    specimenGround(ctx, cx: cx, y: baseY, rand: rand)
    rootTangle(ctx, at: CGPoint(x: cx, y: baseY), rand: rand)
    for f in 0..<6 {
        let ang = CGFloat.pi / 2 + (CGFloat(f) / 5 - 0.5) * 1.5
        let len = rand.range(280, 420)
        let tip = CGPoint(x: cx + cos(ang) * len * 0.5, y: baseY + sin(ang) * len)
        let stem = CGMutablePath()
        stem.move(to: CGPoint(x: cx, y: baseY))
        let ctrl = CGPoint(x: cx + cos(ang) * len * 0.3, y: baseY + sin(ang) * len * 0.6)
        stem.addQuadCurve(to: tip, control: ctrl)
        ctx.addPath(stem)
        ctx.setStrokeColor(mossDeep.cg(0.9))
        ctx.setLineWidth(3.4)
        ctx.strokePath()
        for t in stride(from: 0.16, through: 0.94, by: 0.075) {
            let tt = CGFloat(t)
            let bx = (1 - tt) * (1 - tt) * cx + 2 * (1 - tt) * tt * ctrl.x + tt * tt * tip.x
            let by = (1 - tt) * (1 - tt) * baseY + 2 * (1 - tt) * tt * ctrl.y + tt * tt * tip.y
            let leafLen = (1 - tt * 0.75) * 56
            for side in [-1.0, 1.0] {
                inkLeaf(ctx, at: CGPoint(x: bx, y: by), angle: ang + CGFloat(side) * 1.25, len: leafLen, wide: leafLen * 0.3, fill: tt < 0.4 ? fernTone : fernLight, rand: rand, vein: false)
            }
        }
    }
    let fiddle = CGPoint(x: cx + 260, y: baseY + 60)
    var r: CGFloat = 6
    var a: CGFloat = .pi
    ctx.setStrokeColor(mossDeep.cg(0.9))
    ctx.setLineWidth(7)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: fiddle.x, y: baseY))
    ctx.addLine(to: CGPoint(x: fiddle.x, y: fiddle.y))
    ctx.strokePath()
    ctx.move(to: CGPoint(x: fiddle.x + cos(a) * r, y: fiddle.y + sin(a) * r))
    for _ in 0..<30 {
        a += 0.42
        r += 2.6
        ctx.addLine(to: CGPoint(x: fiddle.x + cos(a) * r, y: fiddle.y + 40 + sin(a) * r))
    }
    ctx.strokePath()
    drawText(ctx, "the fiddlehead, unrolling", font: "Georgia-Italic", size: 24, at: CGPoint(x: fiddle.x + 40, y: baseY - 40), color: inkTone.cg(0.6))
}

drawPlantPlate("nerveplant", "Nerve Plant", "Fittonia albivenis · Plate III", 403) { ctx, w, h, rand in
    let cx = w / 2
    let baseY = h * 0.28
    specimenGround(ctx, cx: cx, y: baseY, rand: rand)
    rootTangle(ctx, at: CGPoint(x: cx, y: baseY), rand: rand)
    for i in 0..<7 {
        let ang = CGFloat.pi / 2 + (CGFloat(i) / 6 - 0.5) * 1.7
        let len = rand.range(160, 300)
        let p = CGPoint(x: cx + cos(ang) * len * 0.55, y: baseY + sin(ang) * len)
        let stem = CGMutablePath()
        stem.move(to: CGPoint(x: cx, y: baseY))
        stem.addQuadCurve(to: p, control: CGPoint(x: cx + cos(ang) * len * 0.3, y: baseY + sin(ang) * len * 0.5))
        ctx.addPath(stem)
        ctx.setStrokeColor(mossDeep.cg(0.85))
        ctx.setLineWidth(3)
        ctx.strokePath()
        let leafLen = rand.range(120, 190)
        ctx.saveGState()
        ctx.translateBy(x: p.x, y: p.y)
        ctx.rotate(by: ang - .pi / 2)
        let leaf = CGMutablePath()
        leaf.addEllipse(in: CGRect(x: -leafLen * 0.33, y: 0, width: leafLen * 0.66, height: leafLen))
        washFill(ctx, leaf, mossTone, rand: rand)
        ctx.addPath(leaf)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.4)
        ctx.strokePath()
        ctx.setStrokeColor(pinkTone.cg(0.95))
        ctx.setLineWidth(2.6)
        ctx.move(to: CGPoint(x: 0, y: leafLen * 0.06))
        ctx.addLine(to: CGPoint(x: 0, y: leafLen * 0.94))
        for t in stride(from: 0.18, through: 0.8, by: 0.14) {
            let vy = leafLen * CGFloat(t)
            ctx.move(to: CGPoint(x: 0, y: vy))
            ctx.addQuadCurve(to: CGPoint(x: leafLen * 0.26, y: vy + leafLen * 0.12), control: CGPoint(x: leafLen * 0.14, y: vy))
            ctx.move(to: CGPoint(x: 0, y: vy))
            ctx.addQuadCurve(to: CGPoint(x: -leafLen * 0.26, y: vy + leafLen * 0.12), control: CGPoint(x: -leafLen * 0.14, y: vy))
        }
        ctx.strokePath()
        ctx.restoreGState()
    }
    drawText(ctx, "veins like drawn silver", font: "Georgia-Italic", size: 24, at: CGPoint(x: w * 0.82, y: h * 0.7), color: inkTone.cg(0.6))
}
print("PLANTS A DONE")

func genericSpecimen(_ ctx: CGContext, kind: String, cx: CGFloat, baseY: CGFloat, scale: CGFloat, body: RGB, accent: RGB, rand: Rand) {
    switch kind {
    case "creeping":
        for _ in 0..<Int(300 * scale) {
            let px = cx + rand.range(-260, 260) * scale
            let py = baseY + rand.range(0, 70) * scale * abs(1 - abs(px - cx) / (280 * scale))
            let r = rand.range(4, 9) * scale
            ctx.setFillColor((rand.next() > 0.3 ? body : accent).cg(rand.range(0.55, 0.95)))
            ctx.fillEllipse(in: CGRect(x: px - r / 2, y: py - r / 2, width: r, height: r))
        }
        for _ in 0..<10 {
            let sx = cx + rand.range(-220, 220) * scale
            let runner = CGMutablePath()
            runner.move(to: CGPoint(x: sx, y: baseY + 4))
            runner.addQuadCurve(to: CGPoint(x: sx + rand.range(-80, 80), y: baseY + rand.range(30, 60)), control: CGPoint(x: sx + rand.range(-40, 40), y: baseY + 20))
            ctx.addPath(runner)
            ctx.setStrokeColor(mossDeep.cg(0.5))
            ctx.setLineWidth(1.6)
            ctx.strokePath()
        }
    case "broad":
        rootTangle(ctx, at: CGPoint(x: cx, y: baseY), rand: rand, spread: 60 * scale)
        for i in 0..<7 {
            let ang = CGFloat.pi / 2 + (CGFloat(i) / 6 - 0.5) * 1.8
            let len = rand.range(130, 260) * scale
            let p = CGPoint(x: cx + cos(ang) * len * 0.6, y: baseY + sin(ang) * len)
            let stem = CGMutablePath()
            stem.move(to: CGPoint(x: cx, y: baseY))
            stem.addQuadCurve(to: p, control: CGPoint(x: cx + cos(ang) * len * 0.3, y: baseY + sin(ang) * len * 0.55))
            ctx.addPath(stem)
            ctx.setStrokeColor(mossDeep.cg(0.85))
            ctx.setLineWidth(3 * scale)
            ctx.strokePath()
            let r = rand.range(46, 74) * scale
            let leaf = CGMutablePath()
            leaf.addEllipse(in: CGRect(x: p.x - r, y: p.y - r * 0.4, width: r * 2, height: r * 1.8))
            washFill(ctx, leaf, body, rand: rand)
            ctx.addPath(leaf)
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2.2)
            ctx.strokePath()
            ctx.setFillColor(accent.cg(0.4))
            ctx.fillEllipse(in: CGRect(x: p.x - r * 0.4, y: p.y - r * 0.1, width: r * 0.8, height: r * 0.5))
        }
    case "trailing":
        for v in 0..<4 {
            let dir: CGFloat = v % 2 == 0 ? -1 : 1
            let len = rand.range(280, 420) * scale
            let mid = CGPoint(x: cx + dir * len * 0.4, y: baseY + len * 0.4)
            let tip = CGPoint(x: cx + dir * len * 0.75, y: baseY + len * 0.72)
            let vine = CGMutablePath()
            vine.move(to: CGPoint(x: cx, y: baseY))
            vine.addQuadCurve(to: tip, control: mid)
            ctx.addPath(vine)
            ctx.setStrokeColor(mossDeep.cg(0.85))
            ctx.setLineWidth(3 * scale)
            ctx.strokePath()
            for t in stride(from: 0.12, through: 0.98, by: 0.11) {
                let tt = CGFloat(t)
                let bx = (1 - tt) * (1 - tt) * cx + 2 * (1 - tt) * tt * mid.x + tt * tt * tip.x
                let by = (1 - tt) * (1 - tt) * baseY + 2 * (1 - tt) * tt * mid.y + tt * tt * tip.y
                inkLeaf(ctx, at: CGPoint(x: bx, y: by), angle: dir * 0.7 + rand.range(-0.3, 0.3) + .pi, len: rand.range(46, 68) * scale, wide: 22 * scale, fill: Int(tt * 10) % 3 == 0 ? accent : body, rand: rand)
            }
        }
    case "spikes":
        rootTangle(ctx, at: CGPoint(x: cx, y: baseY), rand: rand, spread: 50 * scale)
        for _ in 0..<12 {
            let ang = CGFloat.pi / 2 + rand.range(-0.9, 0.9)
            let len = rand.range(180, 320) * scale
            let tip = CGPoint(x: cx + cos(ang) * len * 0.6, y: baseY + sin(ang) * len)
            let spray = CGMutablePath()
            spray.move(to: CGPoint(x: cx, y: baseY))
            spray.addLine(to: tip)
            ctx.addPath(spray)
            ctx.setStrokeColor(body.cg(0.9))
            ctx.setLineWidth(4 * scale)
            ctx.strokePath()
            for t in stride(from: 0.2, through: 0.95, by: 0.09) {
                let bx = cx + (tip.x - cx) * CGFloat(t)
                let by = baseY + (tip.y - baseY) * CGFloat(t)
                let tuft = CGMutablePath()
                tuft.move(to: CGPoint(x: bx, y: by))
                tuft.addLine(to: CGPoint(x: bx - 14 * scale, y: by + 10 * scale))
                tuft.move(to: CGPoint(x: bx, y: by))
                tuft.addLine(to: CGPoint(x: bx + 14 * scale, y: by + 10 * scale))
                ctx.addPath(tuft)
                ctx.setStrokeColor(accent.cg(0.85))
                ctx.setLineWidth(2.2 * scale)
                ctx.strokePath()
            }
        }
    case "rosette":
        for i in 0..<11 {
            let ang = CGFloat(i) / 11 * 2 * .pi
            let len = rand.range(150, 230) * scale
            ctx.saveGState()
            ctx.translateBy(x: cx, y: baseY + 60 * scale)
            ctx.rotate(by: ang)
            let leaf = CGMutablePath()
            leaf.move(to: .zero)
            leaf.addQuadCurve(to: CGPoint(x: len, y: 0), control: CGPoint(x: len * 0.5, y: 26 * scale))
            leaf.addQuadCurve(to: .zero, control: CGPoint(x: len * 0.5, y: -26 * scale))
            washFill(ctx, leaf, i % 2 == 0 ? body : accent, rand: rand)
            ctx.addPath(leaf)
            ctx.setStrokeColor(inkTone.cg(0.75))
            ctx.setLineWidth(2)
            ctx.strokePath()
            ctx.setStrokeColor(inkTone.cg(0.4))
            ctx.setLineWidth(1.2)
            ctx.move(to: .zero)
            ctx.addLine(to: CGPoint(x: len * 0.94, y: 0))
            ctx.strokePath()
            ctx.restoreGState()
        }
    case "buttons":
        let bar = CGMutablePath()
        bar.move(to: CGPoint(x: cx - 240 * scale, y: baseY))
        bar.addLine(to: CGPoint(x: cx + 240 * scale, y: baseY))
        ctx.addPath(bar)
        ctx.setStrokeColor(soilTone.cg(0.8))
        ctx.setLineWidth(6 * scale)
        ctx.strokePath()
        for v in 0..<5 {
            let sx = cx + CGFloat(v - 2) * 100 * scale
            let len = rand.range(220, 360) * scale
            let thread = CGMutablePath()
            thread.move(to: CGPoint(x: sx, y: baseY))
            let tip = CGPoint(x: sx + rand.range(-40, 40), y: baseY + len)
            thread.addQuadCurve(to: tip, control: CGPoint(x: sx + rand.range(-30, 30), y: baseY + len * 0.5))
            ctx.addPath(thread)
            ctx.setStrokeColor(mossDeep.cg(0.7))
            ctx.setLineWidth(1.8)
            ctx.strokePath()
            for t in stride(from: 0.12, through: 1.0, by: 0.13) {
                let by = baseY + len * CGFloat(t)
                let bx = sx + (tip.x - sx) * CGFloat(t) + rand.range(-6, 6)
                let r = rand.range(13, 19) * scale
                let button = CGMutablePath()
                button.addEllipse(in: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2))
                washFill(ctx, button, body, rand: rand)
                ctx.addPath(button)
                ctx.setStrokeColor(inkTone.cg(0.75))
                ctx.setLineWidth(1.8)
                ctx.strokePath()
                ctx.setStrokeColor(accent.cg(0.9))
                ctx.setLineWidth(1.4)
                ctx.strokeEllipse(in: CGRect(x: bx - r * 0.55, y: by - r * 0.55, width: r * 1.1, height: r * 1.1))
                ctx.move(to: CGPoint(x: bx - r * 0.5, y: by))
                ctx.addLine(to: CGPoint(x: bx + r * 0.5, y: by))
                ctx.strokePath()
            }
        }
    case "fan":
        rootTangle(ctx, at: CGPoint(x: cx, y: baseY), rand: rand, spread: 60 * scale)
        for s in 0..<3 {
            let sx = cx + CGFloat(s - 1) * 60 * scale
            let top = CGPoint(x: sx + rand.range(-20, 20), y: baseY + rand.range(180, 260) * scale)
            let stem = CGMutablePath()
            stem.move(to: CGPoint(x: cx, y: baseY))
            stem.addQuadCurve(to: top, control: CGPoint(x: sx, y: baseY + 100 * scale))
            ctx.addPath(stem)
            ctx.setStrokeColor(mossDeep.cg(0.9))
            ctx.setLineWidth(4 * scale)
            ctx.strokePath()
            for f in 0..<9 {
                let fa = CGFloat.pi / 2 + (CGFloat(f) / 8 - 0.5) * 2.2
                let flen = rand.range(90, 150) * scale
                inkLeaf(ctx, at: top, angle: fa - .pi / 2 + .pi, len: flen, wide: 13 * scale, fill: f % 2 == 0 ? body : accent, rand: rand, vein: false)
            }
        }
    default:
        break
    }
}

struct GenericPlantSpec {
    var id: String
    var name: String
    var latin: String
    var kind: String
    var body: RGB
    var accent: RGB
    var caption: String
    var seed: UInt64
}

let genericPlants: [GenericPlantSpec] = [
    GenericPlantSpec(id: "babytears", name: "Baby Tears", latin: "Soleirolia soleirolii · Plate IV", kind: "creeping", body: fernTone, accent: fernLight, caption: "a thousand leaves, none larger than rice", seed: 404),
    GenericPlantSpec(id: "peperomia", name: "Dwarf Peperomia", latin: "Peperomia prostrata · Plate V", kind: "broad", body: mossTone, accent: fernLight, caption: "coin-round leaves that bank their own water", seed: 405),
    GenericPlantSpec(id: "ivysprig", name: "Ivy Sprig", latin: "Hedera helix minima · Plate VI", kind: "trailing", body: mossTone, accent: RGB(r: 0.85, g: 0.88, b: 0.72), caption: "already plotting a route up the glass", seed: 406),
    GenericPlantSpec(id: "clubmoss", name: "Club Moss", latin: "Selaginella kraussiana · Plate VII", kind: "spikes", body: fernTone, accent: RGB(r: 0.82, g: 0.85, b: 0.55), caption: "gold-green scales, older than the ferns", seed: 407),
    GenericPlantSpec(id: "earthstar", name: "Earth Star", latin: "Cryptanthus bivittatus · Plate VIII", kind: "rosette", body: RGB(r: 0.45, g: 0.48, b: 0.32), accent: pinkTone, caption: "the jar's only lawful stripes", seed: 408),
    GenericPlantSpec(id: "turtlestring", name: "String of Turtles", latin: "Peperomia prostrata · Plate IX", kind: "buttons", body: RGB(r: 0.40, g: 0.52, b: 0.38), accent: RGB(r: 0.62, g: 0.70, b: 0.52), caption: "tiny shells on a thread of green", seed: 409),
    GenericPlantSpec(id: "pothos", name: "Pothos Cutting", latin: "Epipremnum aureum · Plate X", kind: "trailing", body: RGB(r: 0.38, g: 0.55, b: 0.33), accent: RGB(r: 0.90, g: 0.85, b: 0.50), caption: "the most forgiving plant in cultivation", seed: 410),
    GenericPlantSpec(id: "maidenhair", name: "Maidenhair Fern", latin: "Adiantum raddianum · Plate XI", kind: "fan", body: fernLight, accent: fernTone, caption: "fronds that tremble at a footstep", seed: 411),
    GenericPlantSpec(id: "dwarfpalm", name: "Dwarf Palm Seedling", latin: "Chamaedorea elegans · Plate XII", kind: "fan", body: mossTone, accent: fernTone, caption: "a jungle clearing, one teaspoon wide", seed: 412),
]

for spec in genericPlants {
    drawPlantPlate(spec.id, spec.name, spec.latin, spec.seed) { ctx, w, h, rand in
        let cx = w / 2
        let baseY = h * 0.30
        specimenGround(ctx, cx: cx, y: baseY, rand: rand)
        genericSpecimen(ctx, kind: spec.kind, cx: cx, baseY: spec.kind == "buttons" ? h * 0.55 : baseY, scale: 1.0, body: spec.body, accent: spec.accent, rand: rand)
        drawText(ctx, spec.caption, font: "Georgia-Italic", size: 26, at: CGPoint(x: cx, y: h * 0.86), color: inkTone.cg(0.6))
    }
}
print("PLANTS B DONE")

func jarOutlinePath(_ rect: CGRect) -> CGMutablePath {
    let p = CGMutablePath()
    let w = rect.width
    let h = rect.height
    p.move(to: CGPoint(x: rect.minX + w * 0.3, y: rect.maxY - h * 0.06))
    p.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.04, y: rect.maxY - h * 0.5), control: CGPoint(x: rect.minX + w * 0.03, y: rect.maxY - h * 0.22))
    p.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.17, y: rect.minY + h * 0.05), control: CGPoint(x: rect.minX + w * 0.05, y: rect.minY + h * 0.12))
    p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.17, y: rect.minY + h * 0.05), control: CGPoint(x: rect.midX, y: rect.minY - h * 0.02))
    p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.04, y: rect.maxY - h * 0.5), control: CGPoint(x: rect.maxX - w * 0.05, y: rect.minY + h * 0.12))
    p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.3, y: rect.maxY - h * 0.06), control: CGPoint(x: rect.maxX - w * 0.03, y: rect.maxY - h * 0.22))
    p.closeSubpath()
    return p
}

let allVignettes: [(String, String, RGB, RGB, UInt64)] = [
    ("cushionmoss", "creeping", mossTone, mossDeep, 501),
    ("fernsprout", "spikes", fernTone, fernLight, 502),
    ("nerveplant", "broad", mossTone, pinkTone, 503),
    ("babytears", "creeping", fernTone, fernLight, 504),
    ("peperomia", "broad", mossTone, fernLight, 505),
    ("ivysprig", "trailing", mossTone, RGB(r: 0.85, g: 0.88, b: 0.72), 506),
    ("clubmoss", "spikes", fernTone, RGB(r: 0.82, g: 0.85, b: 0.55), 507),
    ("earthstar", "rosette", RGB(r: 0.45, g: 0.48, b: 0.32), pinkTone, 508),
    ("turtlestring", "buttons", RGB(r: 0.40, g: 0.52, b: 0.38), RGB(r: 0.62, g: 0.70, b: 0.52), 509),
    ("pothos", "trailing", RGB(r: 0.38, g: 0.55, b: 0.33), RGB(r: 0.90, g: 0.85, b: 0.50), 510),
    ("maidenhair", "fan", fernLight, fernTone, 511),
    ("dwarfpalm", "fan", mossTone, fernTone, 512),
]

for (id, kind, body, accent, seed) in allVignettes {
    let W = 1100, H = 1100
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(seed)
    paperBase(ctx, w, h, seed: seed &+ 7)
    plateFrame(ctx, w, h, inset: 36)
    let jarRect = CGRect(x: w * 0.22, y: h * 0.16, width: w * 0.56, height: h * 0.66)
    let jar = jarOutlinePath(jarRect)
    ctx.saveGState()
    ctx.addPath(jar)
    ctx.clip()
    ctx.setFillColor(glassTone.cg(0.12))
    ctx.fill(jarRect.insetBy(dx: -20, dy: -20))
    let soilY = jarRect.minY + jarRect.height * 0.26
    ctx.setFillColor(soilTone.cg(0.9))
    ctx.fill(CGRect(x: jarRect.minX, y: jarRect.minY, width: jarRect.width, height: soilY - jarRect.minY))
    for _ in 0..<26 {
        let px = jarRect.minX + rand.next() * jarRect.width
        let py = jarRect.minY + rand.next() * (soilY - jarRect.minY)
        ctx.setFillColor(inkTone.cg(rand.range(0.1, 0.3)))
        ctx.fillEllipse(in: CGRect(x: px, y: py, width: 4, height: 3))
    }
    ctx.saveGState()
    ctx.translateBy(x: 0, y: soilY)
    ctx.scaleBy(x: 1, y: 1)
    ctx.restoreGState()
    genericSpecimen(ctx, kind: kind, cx: jarRect.midX, baseY: kind == "buttons" ? jarRect.maxY - jarRect.height * 0.3 : soilY, scale: 0.55, body: body, accent: accent, rand: rand)
    for _ in 0..<14 {
        let side: CGFloat = rand.next() > 0.5 ? jarRect.minX + 24 : jarRect.maxX - 24
        let py = jarRect.minY + rand.next() * jarRect.height * 0.8
        ctx.setFillColor(RGB(r: 1, g: 1, b: 1).cg(rand.range(0.25, 0.5)))
        ctx.fillEllipse(in: CGRect(x: side + rand.range(-10, 10), y: py, width: 5, height: 8))
    }
    ctx.restoreGState()
    ctx.addPath(jar)
    ctx.setStrokeColor(glassTone.darker(0.15).cg(0.95))
    ctx.setLineWidth(5)
    ctx.strokePath()
    let lid = CGRect(x: jarRect.minX + jarRect.width * 0.28, y: jarRect.maxY - 14, width: jarRect.width * 0.44, height: 42)
    washFill(ctx, rrect(lid, 8), RGB(r: 0.851, g: 0.667, b: 0.302), rand: rand)
    ctx.addPath(rrect(lid, 8))
    ctx.setStrokeColor(inkTone.cg(0.6))
    ctx.setLineWidth(2.4)
    ctx.strokePath()
    let shine = CGMutablePath()
    shine.move(to: CGPoint(x: jarRect.minX + jarRect.width * 0.16, y: jarRect.maxY - jarRect.height * 0.2))
    shine.addQuadCurve(to: CGPoint(x: jarRect.minX + jarRect.width * 0.12, y: jarRect.minY + jarRect.height * 0.3), control: CGPoint(x: jarRect.minX + jarRect.width * 0.05, y: jarRect.midY))
    ctx.addPath(shine)
    ctx.setStrokeColor(RGB(r: 1, g: 1, b: 1).cg(0.5))
    ctx.setLineWidth(10)
    ctx.setLineCap(.round)
    ctx.strokePath()
    drawText(ctx, "AS IT LIVES IN THE JAR", font: "Georgia-Bold", size: 30, at: CGPoint(x: w / 2, y: h * 0.075), color: inkTone.cg(0.75), tracking: 4)
    saveJPEG(ctx, "vignette_\(id)")
}
print("VIGNETTES DONE")

func drawFaunaPlate(_ id: String, _ name: String, _ latin: String, _ seed: UInt64, draw: (CGContext, CGPoint, CGFloat, Rand) -> Void, caption: String) {
    let W = 1400, H = 1000
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(seed)
    paperBase(ctx, w, h, seed: seed)
    plateFrame(ctx, w, h, inset: 44)
    let lens = CGPoint(x: w / 2, y: h * 0.52)
    let lensR: CGFloat = 260
    ctx.setFillColor(paperTone.lighter(0.08).cg(0.97))
    ctx.fillEllipse(in: CGRect(x: lens.x - lensR, y: lens.y - lensR, width: lensR * 2, height: lensR * 2))
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: lens.x - lensR, y: lens.y - lensR, width: lensR * 2, height: lensR * 2))
    ctx.clip()
    draw(ctx, lens, lensR, rand)
    ctx.restoreGState()
    ctx.setStrokeColor(inkTone.cg(0.9))
    ctx.setLineWidth(6)
    ctx.strokeEllipse(in: CGRect(x: lens.x - lensR, y: lens.y - lensR, width: lensR * 2, height: lensR * 2))
    ctx.setStrokeColor(brassTone.cg(0.9))
    ctx.setLineWidth(14)
    ctx.strokeEllipse(in: CGRect(x: lens.x - lensR - 11, y: lens.y - lensR - 11, width: (lensR + 11) * 2, height: (lensR + 11) * 2))
    ctx.setStrokeColor(brassTone.darker(0.2).cg())
    ctx.setLineWidth(16)
    ctx.move(to: CGPoint(x: lens.x + lensR * 0.74, y: lens.y + lensR * 0.74))
    ctx.addLine(to: CGPoint(x: lens.x + lensR * 1.35, y: lens.y + lensR * 1.35))
    ctx.strokePath()
    ctx.setFillColor(inkTone.cg(0.9))
    ctx.fillEllipse(in: CGRect(x: w * 0.16 - 3, y: h * 0.68, width: 6, height: 6))
    drawText(ctx, "actual size", font: "Georgia-Italic", size: 22, at: CGPoint(x: w * 0.16, y: h * 0.68 - 34), color: inkTone.cg(0.55))
    drawText(ctx, caption, font: "Georgia-Italic", size: 26, at: CGPoint(x: w / 2, y: h * 0.87), color: inkTone.cg(0.6))
    titleBlock(ctx, w: w, name: name, sub: latin)
    saveJPEG(ctx, "fauna_\(id)")
}

drawFaunaPlate("springtails", "Springtails", "Folsomia candida · Plate XIII", 601, draw: { ctx, lens, lensR, rand in
    let body = CGMutablePath()
    body.addEllipse(in: CGRect(x: lens.x - 120, y: lens.y - 60, width: 240, height: 120))
    washFill(ctx, body, RGB(r: 0.93, g: 0.93, b: 0.89), rand: rand)
    ctx.addPath(body)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    for i in 1..<5 {
        let sx = lens.x - 120 + CGFloat(i) * 48
        ctx.setStrokeColor(inkTone.cg(0.4))
        ctx.setLineWidth(2)
        ctx.move(to: CGPoint(x: sx, y: lens.y - 56))
        ctx.addLine(to: CGPoint(x: sx, y: lens.y + 56))
        ctx.strokePath()
    }
    let head = CGMutablePath()
    head.addEllipse(in: CGRect(x: lens.x + 100, y: lens.y - 40, width: 84, height: 80))
    washFill(ctx, head, RGB(r: 0.90, g: 0.90, b: 0.85), rand: rand)
    ctx.addPath(head)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    ctx.setFillColor(inkTone.cg(0.9))
    ctx.fillEllipse(in: CGRect(x: lens.x + 150, y: lens.y - 20, width: 10, height: 10))
    for side in [-1.0, 1.0] {
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(3)
        ctx.move(to: CGPoint(x: lens.x + 170, y: lens.y - CGFloat(side) * 10))
        ctx.addQuadCurve(to: CGPoint(x: lens.x + 230, y: lens.y - CGFloat(side) * 60), control: CGPoint(x: lens.x + 210, y: lens.y - CGFloat(side) * 20))
        ctx.strokePath()
    }
    for i in 0..<3 {
        let lx = lens.x - 70 + CGFloat(i) * 70
        for side in [1.0] {
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(3)
            ctx.move(to: CGPoint(x: lx, y: lens.y + 55 * CGFloat(side)))
            ctx.addLine(to: CGPoint(x: lx - 16, y: lens.y + 95 * CGFloat(side)))
            ctx.addLine(to: CGPoint(x: lx + 4, y: lens.y + 120 * CGFloat(side)))
            ctx.strokePath()
        }
    }
    let tail = CGMutablePath()
    tail.move(to: CGPoint(x: lens.x - 110, y: lens.y + 30))
    tail.addQuadCurve(to: CGPoint(x: lens.x - 210, y: lens.y - 40), control: CGPoint(x: lens.x - 210, y: lens.y + 40))
    ctx.addPath(tail)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(5)
    ctx.strokePath()
    drawText(ctx, "the spring, latched", font: "Georgia-Italic", size: 20, at: CGPoint(x: lens.x - 190, y: lens.y - 70), color: inkTone.cg(0.6))
}, caption: "the janitor, four hundred times life size")

drawFaunaPlate("dwarfisopods", "Dwarf White Isopods", "Trichorhina tomentosa · Plate XIV", 602, draw: { ctx, lens, lensR, rand in
    for k in 0..<2 {
        let ox = lens.x - 60 + CGFloat(k) * 130
        let oy = lens.y - 20 + CGFloat(k) * 60
        let s: CGFloat = k == 0 ? 1.0 : 0.6
        for i in 0..<7 {
            let segW = 36 * s
            let sx = ox - 120 * s + CGFloat(i) * segW * 0.8
            let seg = CGMutablePath()
            seg.addEllipse(in: CGRect(x: sx, y: oy - 50 * s + CGFloat(abs(3 - i)) * 6 * s, width: segW, height: 100 * s - CGFloat(abs(3 - i)) * 12 * s))
            washFill(ctx, seg, RGB(r: 0.90, g: 0.90, b: 0.86), rand: rand)
            ctx.addPath(seg)
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2.6)
            ctx.strokePath()
        }
        for i in 0..<6 {
            let lx = ox - 100 * s + CGFloat(i) * 34 * s
            ctx.setStrokeColor(inkTone.cg(0.75))
            ctx.setLineWidth(2.4)
            ctx.move(to: CGPoint(x: lx, y: oy - 44 * s))
            ctx.addLine(to: CGPoint(x: lx - 10 * s, y: oy - 80 * s))
            ctx.strokePath()
        }
        for side in [-1.0, 1.0] {
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2.6)
            ctx.move(to: CGPoint(x: ox + 100 * s, y: oy))
            ctx.addQuadCurve(to: CGPoint(x: ox + 160 * s, y: oy + CGFloat(side) * 40 * s), control: CGPoint(x: ox + 140 * s, y: oy))
            ctx.strokePath()
        }
    }
}, caption: "the night shift, shredding litter into soil")

drawFaunaPlate("clownisopods", "Clown Isopods", "Armadillidium klugii · Plate XV", 603, draw: { ctx, lens, lensR, rand in
    let oy = lens.y
    for i in 0..<7 {
        let segW: CGFloat = 40
        let sx = lens.x - 140 + CGFloat(i) * segW * 0.82
        let seg = CGMutablePath()
        seg.addEllipse(in: CGRect(x: sx, y: oy - 62 + CGFloat(abs(3 - i)) * 8, width: segW, height: 124 - CGFloat(abs(3 - i)) * 16))
        washFill(ctx, seg, RGB(r: 0.30, g: 0.28, b: 0.30), rand: rand)
        ctx.addPath(seg)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(2.6)
        ctx.strokePath()
        if i > 0 && i < 6 {
            for _ in 0..<2 {
                let dx = sx + rand.range(8, 26)
                let dy = oy + rand.range(-40, 30)
                ctx.setFillColor(RGB(r: 0.95, g: 0.93, b: 0.88).cg())
                ctx.fillEllipse(in: CGRect(x: dx, y: dy, width: 13, height: 13))
                ctx.setStrokeColor(inkTone.cg(0.5))
                ctx.setLineWidth(1.4)
                ctx.strokeEllipse(in: CGRect(x: dx, y: dy, width: 13, height: 13))
            }
        }
        if i > 0 && i < 6 {
            let rx = sx + 14
            ctx.setFillColor(clayTone.cg(0.9))
            ctx.fillEllipse(in: CGRect(x: rx, y: oy + 44, width: 10, height: 10))
        }
    }
    let ball = CGMutablePath()
    ball.addEllipse(in: CGRect(x: lens.x + 90, y: oy + 90, width: 90, height: 90))
    washFill(ctx, ball, RGB(r: 0.30, g: 0.28, b: 0.30), rand: rand)
    ctx.addPath(ball)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(2.6)
    ctx.strokePath()
    for a in stride(from: 0.4, to: 2.8, by: 0.5) {
        ctx.setStrokeColor(RGB(r: 0.9, g: 0.88, b: 0.84).cg(0.7))
        ctx.setLineWidth(2)
        let cxx = lens.x + 135
        let cyy = oy + 135
        ctx.move(to: CGPoint(x: cxx + cos(a) * 20, y: cyy + sin(a) * 20))
        ctx.addLine(to: CGPoint(x: cxx + cos(a) * 42, y: cyy + sin(a) * 42))
        ctx.strokePath()
    }
    drawText(ctx, "alarmed (and spherical)", font: "Georgia-Italic", size: 20, at: CGPoint(x: lens.x + 135, y: oy + 60), color: inkTone.cg(0.6))
}, caption: "polka-dot armour on the litter patrol")

drawFaunaPlate("snail", "Glass Snail", "Oxychilus alliarius · Plate XVI", 604, draw: { ctx, lens, lensR, rand in
    let c = CGPoint(x: lens.x - 20, y: lens.y + 10)
    var r: CGFloat = 12
    var a: CGFloat = 0
    ctx.setStrokeColor(clayTone.darker(0.1).cg(0.95))
    ctx.setLineWidth(26)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: c.x + r, y: c.y))
    for _ in 0..<44 {
        a += 0.28
        r += 3.1
        ctx.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r * 0.86))
    }
    ctx.strokePath()
    ctx.setStrokeColor(inkTone.cg(0.6))
    ctx.setLineWidth(2.4)
    ctx.move(to: CGPoint(x: c.x + 12, y: c.y))
    r = 12
    a = 0
    for _ in 0..<44 {
        a += 0.28
        r += 3.1
        ctx.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r * 0.86))
    }
    ctx.strokePath()
    let foot = CGMutablePath()
    foot.move(to: CGPoint(x: c.x - 160, y: c.y + 120))
    foot.addQuadCurve(to: CGPoint(x: c.x + 190, y: c.y + 110), control: CGPoint(x: c.x, y: c.y + 160))
    foot.addQuadCurve(to: CGPoint(x: c.x + 120, y: c.y + 60), control: CGPoint(x: c.x + 190, y: c.y + 70))
    foot.addQuadCurve(to: CGPoint(x: c.x - 160, y: c.y + 120), control: CGPoint(x: c.x - 40, y: c.y + 80))
    washFill(ctx, foot, RGB(r: 0.80, g: 0.74, b: 0.62), rand: rand)
    ctx.addPath(foot)
    ctx.setStrokeColor(inkTone.cg(0.8))
    ctx.setLineWidth(3)
    ctx.strokePath()
    for side in [-1.0, 1.0] {
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(3.4)
        ctx.move(to: CGPoint(x: c.x + 150, y: c.y + 80))
        ctx.addQuadCurve(to: CGPoint(x: c.x + 210 + CGFloat(side) * 16, y: c.y + 10 - CGFloat(side) * 8), control: CGPoint(x: c.x + 190, y: c.y + 40))
        ctx.strokePath()
        ctx.setFillColor(inkTone.cg(0.9))
        ctx.fillEllipse(in: CGRect(x: c.x + 205 + CGFloat(side) * 16, y: c.y + 4 - CGFloat(side) * 8, width: 9, height: 9))
    }
    let ribbon = CGMutablePath()
    ribbon.move(to: CGPoint(x: c.x - 230, y: c.y + 130))
    ribbon.addQuadCurve(to: CGPoint(x: c.x - 150, y: c.y + 124), control: CGPoint(x: c.x - 190, y: c.y + 140))
    ctx.addPath(ribbon)
    ctx.setStrokeColor(RGB(r: 1, g: 1, b: 1).cg(0.5))
    ctx.setLineWidth(8)
    ctx.strokePath()
}, caption: "the window cleaner, paid in algae")
print("FAUNA DONE")

func drawGuidePlate(_ id: String, _ title: String, _ sub: String, draw: (CGContext, CGFloat, CGFloat, Rand) -> Void) {
    let W = 1400, H = 1000
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(UInt64(abs(id.hashValue % 100000)) &+ 17)
    paperBase(ctx, w, h, seed: UInt64(abs(id.hashValue % 100000)) &+ 3)
    plateFrame(ctx, w, h, inset: 44)
    draw(ctx, w, h, rand)
    titleBlock(ctx, w: w, name: title, sub: sub)
    saveJPEG(ctx, id)
}

func miniJar(_ ctx: CGContext, rect: CGRect, rand: Rand, planted: Bool = true) {
    let jar = jarOutlinePath(rect)
    ctx.saveGState()
    ctx.addPath(jar)
    ctx.clip()
    ctx.setFillColor(glassTone.cg(0.10))
    ctx.fill(rect.insetBy(dx: -10, dy: -10))
    let soilY = rect.minY + rect.height * 0.24
    ctx.setFillColor(soilTone.cg(0.9))
    ctx.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: soilY - rect.minY))
    ctx.setFillColor(RGB(r: 0.67, g: 0.66, b: 0.63).cg(0.9))
    ctx.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.08))
    if planted {
        genericSpecimen(ctx, kind: "spikes", cx: rect.midX - rect.width * 0.15, baseY: soilY, scale: 0.3, body: fernTone, accent: fernLight, rand: rand)
        genericSpecimen(ctx, kind: "broad", cx: rect.midX + rect.width * 0.2, baseY: soilY, scale: 0.26, body: mossTone, accent: fernLight, rand: rand)
    }
    ctx.restoreGState()
    ctx.addPath(jar)
    ctx.setStrokeColor(glassTone.darker(0.15).cg(0.95))
    ctx.setLineWidth(4)
    ctx.strokePath()
    let lid = CGRect(x: rect.minX + rect.width * 0.3, y: rect.maxY - 8, width: rect.width * 0.4, height: 24)
    washFill(ctx, rrect(lid, 6), RGB(r: 0.851, g: 0.667, b: 0.302), rand: rand)
    ctx.addPath(rrect(lid, 6))
    ctx.setStrokeColor(inkTone.cg(0.6))
    ctx.setLineWidth(2)
    ctx.strokePath()
}

drawGuidePlate("guide_watercycle", "The Rain Indoors", "Fig. I — the loop that waters itself") { ctx, w, h, rand in
    let jarRect = CGRect(x: w * 0.36, y: h * 0.22, width: w * 0.28, height: h * 0.5)
    miniJar(ctx, rect: jarRect, rand: rand)
    for (a0, a1, label) in [(CGFloat(2.1), CGFloat(1.05), "vapour rises"), (CGFloat(-1.05), CGFloat(-2.1), "rain returns")] {
        let arrow = CGMutablePath()
        let c = CGPoint(x: jarRect.midX, y: jarRect.midY)
        let r = jarRect.width * 0.85
        arrow.addArc(center: c, radius: r, startAngle: a0, endAngle: a1, clockwise: a0 > a1)
        ctx.addPath(arrow)
        ctx.setStrokeColor(glassTone.darker(0.2).cg(0.85))
        ctx.setLineWidth(7)
        ctx.strokePath()
        let tip = CGPoint(x: c.x + cos(a1) * r, y: c.y + sin(a1) * r)
        let tangent = a1 + (a0 > a1 ? -1 : 1) * .pi / 2
        let head = CGMutablePath()
        head.move(to: CGPoint(x: tip.x + cos(tangent + 2.6) * 26, y: tip.y + sin(tangent + 2.6) * 26))
        head.addLine(to: tip)
        head.addLine(to: CGPoint(x: tip.x + cos(tangent - 2.6) * 26, y: tip.y + sin(tangent - 2.6) * 26))
        ctx.addPath(head)
        ctx.setStrokeColor(glassTone.darker(0.2).cg(0.85))
        ctx.setLineWidth(7)
        ctx.strokePath()
        _ = label
    }
    drawText(ctx, "vapour up the warm side", font: "Georgia-Italic", size: 26, at: CGPoint(x: w * 0.80, y: h * 0.62), color: inkTone.cg(0.6))
    drawText(ctx, "rain down the cool glass", font: "Georgia-Italic", size: 26, at: CGPoint(x: w * 0.19, y: h * 0.62), color: inkTone.cg(0.6))
    for i in 0..<8 {
        let dx = jarRect.minX + 14 + rand.next() * 20
        let dy = jarRect.minY + jarRect.height * (0.3 + rand.next() * 0.5)
        ctx.setFillColor(RGB(r: 1, g: 1, b: 1).cg(0.6))
        ctx.fillEllipse(in: CGRect(x: dx, y: dy, width: 6, height: 9))
        _ = i
    }
}

drawGuidePlate("guide_light", "Light, the Only Import", "Fig. II — the engine through the window") { ctx, w, h, rand in
    let winRect = CGRect(x: w * 0.10, y: h * 0.24, width: w * 0.3, height: h * 0.52)
    washFill(ctx, rrect(winRect, 10), RGB(r: 0.78, g: 0.85, b: 0.87), rand: rand, alpha: 0.5)
    inkRect(ctx, winRect, rand: rand, width: 3)
    wobblyLine(ctx, from: CGPoint(x: winRect.midX, y: winRect.minY), to: CGPoint(x: winRect.midX, y: winRect.maxY), rand: rand, width: 5, color: inkTone.cg(0.6))
    wobblyLine(ctx, from: CGPoint(x: winRect.minX, y: winRect.midY), to: CGPoint(x: winRect.maxX, y: winRect.midY), rand: rand, width: 5, color: inkTone.cg(0.6))
    let sun = CGPoint(x: winRect.minX + winRect.width * 0.28, y: winRect.maxY - winRect.height * 0.24)
    ctx.setFillColor(RGB(r: 0.9, g: 0.78, b: 0.4).cg(0.9))
    ctx.fillEllipse(in: CGRect(x: sun.x - 30, y: sun.y - 30, width: 60, height: 60))
    let jarRect = CGRect(x: w * 0.58, y: h * 0.24, width: w * 0.22, height: h * 0.42)
    miniJar(ctx, rect: jarRect, rand: rand)
    for i in 0..<4 {
        let t = CGFloat(i) / 3
        let from = CGPoint(x: winRect.maxX + 8, y: winRect.midY - 40 + t * 90)
        let to = CGPoint(x: jarRect.minX - 10, y: jarRect.midY - 30 + t * 60)
        wobblyLine(ctx, from: from, to: to, rand: rand, width: 3, color: RGB(r: 0.85, g: 0.7, b: 0.35).cg(0.7))
        let ang = atan2(to.y - from.y, to.x - from.x)
        let head = CGMutablePath()
        head.move(to: CGPoint(x: to.x + cos(ang + 2.7) * 16, y: to.y + sin(ang + 2.7) * 16))
        head.addLine(to: to)
        head.addLine(to: CGPoint(x: to.x + cos(ang - 2.7) * 16, y: to.y + sin(ang - 2.7) * 16))
        ctx.addPath(head)
        ctx.setStrokeColor(RGB(r: 0.85, g: 0.7, b: 0.35).cg(0.8))
        ctx.setLineWidth(3)
        ctx.strokePath()
    }
    drawText(ctx, "bright, but never in the beam", font: "Georgia-Italic", size: 28, at: CGPoint(x: w * 0.63, y: h * 0.76), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_layers", "Reading the Layers", "Fig. III — the jar's small geology") { ctx, w, h, rand in
    let cx = w / 2
    let rect = CGRect(x: cx - 220, y: h * 0.2, width: 440, height: h * 0.52)
    let layers: [(RGB, CGFloat, String)] = [
        (RGB(r: 0.67, g: 0.66, b: 0.63), 0.16, "pebbles — the false bottom"),
        (RGB(r: 0.267, g: 0.267, b: 0.267), 0.08, "charcoal — the quiet filter"),
        (soilTone, 0.3, "soil — where the living happens"),
    ]
    var y = rect.minY
    for (tone, frac, label) in layers {
        let lh = rect.height * frac
        washFill(ctx, rrect(CGRect(x: rect.minX, y: y, width: rect.width, height: lh), 4), tone, rand: rand)
        inkRect(ctx, CGRect(x: rect.minX, y: y, width: rect.width, height: lh), rand: rand, width: 2)
        wobblyLine(ctx, from: CGPoint(x: rect.maxX + 12, y: y + lh / 2), to: CGPoint(x: rect.maxX + 60, y: y + lh / 2), rand: rand, width: 2, color: inkTone.cg(0.5))
        drawText(ctx, label, font: "Georgia-Italic", size: 25, at: CGPoint(x: rect.maxX + 78, y: y + lh / 2 - 8), color: inkTone.cg(0.65), centered: false)
        y += lh
    }
    if true {
        let rand2 = Rand(11)
        for _ in 0..<20 {
            let px = rect.minX + rand2.next() * rect.width
            let py = rect.minY + rand2.next() * rect.height * 0.16
            let r = rand2.range(10, 22)
            ctx.setFillColor(RGB(r: 0.6, g: 0.59, b: 0.56).cg(0.8))
            ctx.fillEllipse(in: CGRect(x: px, y: py, width: r * 1.4, height: r))
            ctx.setStrokeColor(inkTone.cg(0.4))
            ctx.setLineWidth(1.4)
            ctx.strokeEllipse(in: CGRect(x: px, y: py, width: r * 1.4, height: r))
        }
    }
    genericSpecimen(ctx, kind: "spikes", cx: cx - 80, baseY: y, scale: 0.5, body: fernTone, accent: fernLight, rand: rand)
    genericSpecimen(ctx, kind: "broad", cx: cx + 110, baseY: y, scale: 0.42, body: mossTone, accent: fernLight, rand: rand)
    specimenGround(ctx, cx: cx, y: y, rand: rand)
}

drawGuidePlate("guide_crew", "The Cleanup Crew", "Fig. IV — hiring the janitors") { ctx, w, h, rand in
    let soilY = h * 0.3
    hatchRect(ctx, CGRect(x: 100, y: h * 0.16, width: w - 200, height: soilY - h * 0.16), rand: rand, angle: 0.05, gap: 6, alpha: 0.2)
    wobblyLine(ctx, from: CGPoint(x: 90, y: soilY), to: CGPoint(x: w - 90, y: soilY), rand: rand, width: 3, color: inkTone.cg(0.6))
    for _ in 0..<7 {
        let lx = 160 + rand.next() * (w - 340)
        let leaf = CGMutablePath()
        leaf.addEllipse(in: CGRect(x: lx, y: soilY + rand.range(0, 16), width: rand.range(40, 76), height: rand.range(18, 30)))
        washFill(ctx, leaf, RGB(r: 0.62, g: 0.5, b: 0.32), rand: rand)
        ctx.addPath(leaf)
        ctx.setStrokeColor(inkTone.cg(0.6))
        ctx.setLineWidth(2)
        ctx.strokePath()
    }
    for i in 0..<9 {
        let bx = 200 + rand.next() * (w - 400)
        let by = soilY + rand.range(14, 60)
        ctx.setFillColor(RGB(r: 0.95, g: 0.95, b: 0.92).cg())
        ctx.fillEllipse(in: CGRect(x: bx, y: by, width: 9, height: 9))
        ctx.setStrokeColor(inkTone.cg(0.5))
        ctx.setLineWidth(1)
        ctx.strokeEllipse(in: CGRect(x: bx, y: by, width: 9, height: 9))
        _ = i
    }
    for k in 0..<3 {
        let ox = w * 0.3 + CGFloat(k) * w * 0.18
        let oy = soilY + 90 + CGFloat(k % 2) * 40
        for i in 0..<5 {
            let seg = CGMutablePath()
            seg.addEllipse(in: CGRect(x: ox + CGFloat(i) * 12, y: oy - 12 + CGFloat(abs(2 - i)) * 2, width: 15, height: 24 - CGFloat(abs(2 - i)) * 4))
            washFill(ctx, seg, RGB(r: 0.88, g: 0.88, b: 0.84), rand: rand)
            ctx.addPath(seg)
            ctx.setStrokeColor(inkTone.cg(0.7))
            ctx.setLineWidth(1.6)
            ctx.strokePath()
        }
    }
    let cycle = CGPoint(x: w / 2, y: h * 0.62)
    let labels = ["plants shed litter", "the crew eats it", "soil feeds the plants"]
    for (i, label) in labels.enumerated() {
        let a0 = -CGFloat.pi / 2 + CGFloat(i) * 2 * .pi / 3
        let a1 = a0 + 2 * .pi / 3 - 0.35
        let arc = CGMutablePath()
        arc.addArc(center: cycle, radius: 150, startAngle: a0, endAngle: a1, clockwise: false)
        ctx.addPath(arc)
        ctx.setStrokeColor(mossTone.cg(0.8))
        ctx.setLineWidth(6)
        ctx.strokePath()
        let tip = CGPoint(x: cycle.x + cos(a1) * 150, y: cycle.y + sin(a1) * 150)
        let tangent = a1 + .pi / 2
        let head = CGMutablePath()
        head.move(to: CGPoint(x: tip.x + cos(tangent + 2.6) * 20, y: tip.y + sin(tangent + 2.6) * 20))
        head.addLine(to: tip)
        head.addLine(to: CGPoint(x: tip.x + cos(tangent - 2.6) * 20, y: tip.y + sin(tangent - 2.6) * 20))
        ctx.addPath(head)
        ctx.setStrokeColor(mossTone.cg(0.8))
        ctx.setLineWidth(6)
        ctx.strokePath()
        let mid = a0 + (a1 - a0) / 2
        drawText(ctx, label, font: "Georgia-Italic", size: 24, at: CGPoint(x: cycle.x + cos(mid) * 225, y: cycle.y + sin(mid) * 215 - 8), color: inkTone.cg(0.65))
    }
}

drawGuidePlate("guide_mold", "When the Grey Fuzz Comes", "Fig. V — a backlog, not a catastrophe") { ctx, w, h, rand in
    let soilY = h * 0.32
    wobblyLine(ctx, from: CGPoint(x: 100, y: soilY), to: CGPoint(x: w - 100, y: soilY), rand: rand, width: 3, color: inkTone.cg(0.6))
    let leaf = CGMutablePath()
    leaf.addEllipse(in: CGRect(x: w * 0.38, y: soilY + 4, width: 180, height: 60))
    washFill(ctx, leaf, RGB(r: 0.6, g: 0.48, b: 0.3), rand: rand)
    ctx.addPath(leaf)
    ctx.setStrokeColor(inkTone.cg(0.7))
    ctx.setLineWidth(2.4)
    ctx.strokePath()
    for _ in 0..<60 {
        let fx = w * 0.40 + rand.next() * 150
        let fy = soilY + 8 + rand.next() * 60
        let r = rand.range(4, 12)
        ctx.setFillColor(RGB(r: 0.80, g: 0.80, b: 0.76).cg(rand.range(0.4, 0.7)))
        ctx.fillEllipse(in: CGRect(x: fx, y: fy, width: r, height: r))
    }
    for _ in 0..<14 {
        let fx = w * 0.42 + rand.next() * 130
        let fy = soilY + 30 + rand.next() * 50
        ctx.setStrokeColor(inkTone.cg(0.35))
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: fx, y: fy))
        ctx.addLine(to: CGPoint(x: fx + rand.range(-4, 4), y: fy + rand.range(8, 18)))
        ctx.strokePath()
        ctx.setFillColor(inkTone.cg(0.5))
        ctx.fillEllipse(in: CGRect(x: fx + rand.range(-5, 3), y: fy + rand.range(16, 20), width: 4, height: 4))
    }
    for side in [-1.0, 1.0] {
        for i in 0..<5 {
            let bx = w * 0.5 + CGFloat(side) * (240 + CGFloat(i) * 60) + rand.range(-20, 20)
            let by = soilY + rand.range(10, 50)
            ctx.setFillColor(RGB(r: 0.95, g: 0.95, b: 0.92).cg())
            ctx.fillEllipse(in: CGRect(x: bx, y: by, width: 10, height: 10))
            ctx.setStrokeColor(inkTone.cg(0.5))
            ctx.setLineWidth(1.2)
            ctx.strokeEllipse(in: CGRect(x: bx, y: by, width: 10, height: 10))
            let ang = side < 0 ? 0.2 : CGFloat.pi - 0.2
            ctx.setStrokeColor(inkTone.cg(0.4))
            ctx.move(to: CGPoint(x: bx + 5, y: by + 5))
            ctx.addLine(to: CGPoint(x: bx + 5 + cos(ang) * 22, y: by + 5 + sin(ang) * 8))
            ctx.strokePath()
        }
    }
    drawText(ctx, "the crew, closing in from both sides", font: "Georgia-Italic", size: 28, at: CGPoint(x: w / 2, y: h * 0.62), color: inkTone.cg(0.65))
    let ladder = ["wait and watch", "strengthen the crew", "shorten the water", "only then, the lid"]
    for (i, rung) in ladder.enumerated() {
        let y = h * 0.78 - CGFloat(i) * 44
        ctx.setFillColor(mossTone.cg(0.85))
        ctx.fillEllipse(in: CGRect(x: w * 0.30 - 6, y: y - 6, width: 12, height: 12))
        drawText(ctx, rung, font: "Georgia", size: 26, at: CGPoint(x: w * 0.33, y: y - 10), color: inkTone.cg(0.7), centered: false)
    }
}
print("GUIDES A DONE")

drawGuidePlate("guide_algae", "The Green Window", "Fig. VI — light times water") { ctx, w, h, rand in
    for (i, algaeLevel) in [0.1, 0.45, 0.85].enumerated() {
        let jarRect = CGRect(x: w * (0.14 + CGFloat(i) * 0.26), y: h * 0.3, width: w * 0.18, height: h * 0.38)
        miniJar(ctx, rect: jarRect, rand: rand)
        let rand2 = Rand(UInt64(70 + i))
        for _ in 0..<Int(algaeLevel * 90) {
            let px = jarRect.minX + 8 + rand2.next() * (jarRect.width - 16)
            let py = jarRect.minY + rand2.next() * jarRect.height * 0.9
            let r = rand2.range(3, 9)
            ctx.setFillColor(fernTone.cg(rand2.range(0.15, 0.4)))
            ctx.fillEllipse(in: CGRect(x: px, y: py, width: r, height: r))
        }
        let labels = ["soft light — clear glass", "bright and damp — a film", "sun and swamp — green fog"]
        drawText(ctx, labels[i], font: "Georgia-Italic", size: 23, at: CGPoint(x: jarRect.midX, y: h * 0.24), color: inkTone.cg(0.6))
    }
    let sc = CGPoint(x: w * 0.84, y: h * 0.5)
    var r: CGFloat = 8
    var a: CGFloat = 0
    ctx.setStrokeColor(clayTone.darker(0.1).cg(0.95))
    ctx.setLineWidth(13)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: sc.x + r, y: sc.y))
    for _ in 0..<36 {
        a += 0.3
        r += 1.5
        ctx.addLine(to: CGPoint(x: sc.x + cos(a) * r, y: sc.y + sin(a) * r * 0.86))
    }
    ctx.strokePath()
    let foot = CGMutablePath()
    foot.move(to: CGPoint(x: sc.x - 70, y: sc.y + 62))
    foot.addQuadCurve(to: CGPoint(x: sc.x + 90, y: sc.y + 56), control: CGPoint(x: sc.x, y: sc.y + 84))
    ctx.addPath(foot)
    ctx.setStrokeColor(RGB(r: 0.80, g: 0.74, b: 0.62).cg())
    ctx.setLineWidth(16)
    ctx.strokePath()
    drawText(ctx, "or hire the cleaner", font: "Georgia-Italic", size: 24, at: CGPoint(x: sc.x, y: sc.y - 80), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_balance", "The Art of Balance", "Fig. VII — reading a world at a glance") { ctx, w, h, rand in
    let jarRect = CGRect(x: w * 0.4, y: h * 0.26, width: w * 0.2, height: h * 0.42)
    miniJar(ctx, rect: jarRect, rand: rand)
    let checks: [(CGFloat, CGFloat, String)] = [
        (0.24, 0.62, "leaves the right colour"),
        (0.24, 0.44, "glass fogs, then clears"),
        (0.76, 0.62, "litter vanishing on time"),
        (0.76, 0.44, "crew on their rounds"),
    ]
    for (fx, fy, label) in checks {
        let p = CGPoint(x: w * fx, y: h * fy)
        ctx.setStrokeColor(mossTone.cg(0.9))
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: p.x - 14, y: p.y))
        ctx.addLine(to: CGPoint(x: p.x - 4, y: p.y + 12))
        ctx.addLine(to: CGPoint(x: p.x + 16, y: p.y - 12))
        ctx.strokePath()
        drawText(ctx, label, font: "Georgia-Italic", size: 24, at: CGPoint(x: p.x, y: p.y - 44), color: inkTone.cg(0.65))
        wobblyLine(ctx, from: CGPoint(x: p.x + (fx < 0.5 ? 60 : -60), y: p.y), to: CGPoint(x: fx < 0.5 ? jarRect.minX - 8 : jarRect.maxX + 8, y: p.y), rand: rand, width: 1.6, color: inkTone.cg(0.35))
    }
    drawText(ctx, "the deepest skill is sitting on your hands", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.79), color: inkTone.cg(0.65))
}

drawGuidePlate("guide_ward", "The Accidental Invention", "Fig. VIII — Dr Ward's moth jar, 1829") { ctx, w, h, rand in
    let caseRect = CGRect(x: w * 0.32, y: h * 0.24, width: w * 0.36, height: h * 0.46)
    washFill(ctx, rrect(CGRect(x: caseRect.minX - 20, y: caseRect.minY - 24, width: caseRect.width + 40, height: 24), 4), soilTone, rand: rand)
    inkRect(ctx, CGRect(x: caseRect.minX - 20, y: caseRect.minY - 24, width: caseRect.width + 40, height: 24), rand: rand, width: 2.4)
    ctx.setFillColor(glassTone.cg(0.12))
    ctx.fill(caseRect)
    let roofPeak = CGPoint(x: caseRect.midX, y: caseRect.maxY + h * 0.12)
    let roof = CGMutablePath()
    roof.move(to: CGPoint(x: caseRect.minX, y: caseRect.maxY))
    roof.addLine(to: roofPeak)
    roof.addLine(to: CGPoint(x: caseRect.maxX, y: caseRect.maxY))
    ctx.addPath(roof)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(4)
    ctx.strokePath()
    inkRect(ctx, caseRect, rand: rand, width: 3.4)
    for fx in [0.25, 0.5, 0.75] {
        wobblyLine(ctx, from: CGPoint(x: caseRect.minX + caseRect.width * CGFloat(fx), y: caseRect.minY), to: CGPoint(x: caseRect.minX + caseRect.width * CGFloat(fx), y: caseRect.maxY), rand: rand, width: 2, color: inkTone.cg(0.5))
    }
    wobblyLine(ctx, from: CGPoint(x: caseRect.minX, y: caseRect.midY), to: CGPoint(x: caseRect.maxX, y: caseRect.midY), rand: rand, width: 2, color: inkTone.cg(0.5))
    let soilY = caseRect.minY + caseRect.height * 0.16
    ctx.setFillColor(soilTone.cg(0.85))
    ctx.fill(CGRect(x: caseRect.minX + 4, y: caseRect.minY + 2, width: caseRect.width - 8, height: soilY - caseRect.minY))
    genericSpecimen(ctx, kind: "spikes", cx: caseRect.midX, baseY: soilY, scale: 0.6, body: fernTone, accent: fernLight, rand: rand)
    let moth = CGPoint(x: caseRect.midX + caseRect.width * 0.28, y: caseRect.maxY - caseRect.height * 0.2)
    for side in [-1.0, 1.0] {
        let wing = CGMutablePath()
        wing.addEllipse(in: CGRect(x: moth.x + CGFloat(side) * 6 - (side < 0 ? 30 : 0), y: moth.y - 12, width: 30, height: 24))
        washFill(ctx, wing, RGB(r: 0.75, g: 0.68, b: 0.55), rand: rand)
        ctx.addPath(wing)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(1.8)
        ctx.strokePath()
    }
    ctx.setFillColor(inkTone.cg(0.8))
    ctx.fillEllipse(in: CGRect(x: moth.x - 4, y: moth.y - 10, width: 8, height: 22))
    drawText(ctx, "he was watching the moth", font: "Georgia-Italic", size: 26, at: CGPoint(x: w * 0.80, y: h * 0.6), color: inkTone.cg(0.6))
    drawText(ctx, "the fern was the accident", font: "Georgia-Italic", size: 26, at: CGPoint(x: w * 0.19, y: h * 0.42), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_bottle", "The Fifty-Year Bottle", "Fig. IX — last watered in 1972") { ctx, w, h, rand in
    let cx = w / 2
    let carboy = CGMutablePath()
    let bw: CGFloat = 340
    let baseY = h * 0.22
    carboy.move(to: CGPoint(x: cx - 30, y: baseY + 470))
    carboy.addLine(to: CGPoint(x: cx - 30, y: baseY + 420))
    carboy.addCurve(to: CGPoint(x: cx - bw / 2, y: baseY + 220), control1: CGPoint(x: cx - 40, y: baseY + 390), control2: CGPoint(x: cx - bw / 2, y: baseY + 330))
    carboy.addCurve(to: CGPoint(x: cx - bw * 0.4, y: baseY + 20), control1: CGPoint(x: cx - bw / 2, y: baseY + 120), control2: CGPoint(x: cx - bw * 0.46, y: baseY + 50))
    carboy.addQuadCurve(to: CGPoint(x: cx + bw * 0.4, y: baseY + 20), control: CGPoint(x: cx, y: baseY - 10))
    carboy.addCurve(to: CGPoint(x: cx + bw / 2, y: baseY + 220), control1: CGPoint(x: cx + bw * 0.46, y: baseY + 50), control2: CGPoint(x: cx + bw / 2, y: baseY + 120))
    carboy.addCurve(to: CGPoint(x: cx + 30, y: baseY + 420), control1: CGPoint(x: cx + bw / 2, y: baseY + 330), control2: CGPoint(x: cx + 40, y: baseY + 390))
    carboy.addLine(to: CGPoint(x: cx + 30, y: baseY + 470))
    ctx.saveGState()
    ctx.addPath(carboy)
    ctx.clip()
    ctx.setFillColor(glassTone.cg(0.14))
    ctx.fill(CGRect(x: cx - bw, y: baseY - 20, width: bw * 2, height: 520))
    ctx.setFillColor(soilTone.cg(0.9))
    ctx.fill(CGRect(x: cx - bw, y: baseY, width: bw * 2, height: 70))
    genericSpecimen(ctx, kind: "trailing", cx: cx, baseY: baseY + 66, scale: 0.85, body: RGB(r: 0.38, g: 0.55, b: 0.33), accent: fernLight, rand: rand)
    genericSpecimen(ctx, kind: "broad", cx: cx - 70, baseY: baseY + 66, scale: 0.5, body: mossTone, accent: fernLight, rand: rand)
    ctx.restoreGState()
    ctx.addPath(carboy)
    ctx.setStrokeColor(glassTone.darker(0.15).cg(0.95))
    ctx.setLineWidth(5)
    ctx.strokePath()
    let cork = CGRect(x: cx - 26, y: baseY + 466, width: 52, height: 34)
    washFill(ctx, rrect(cork, 6), clayTone, rand: rand)
    ctx.addPath(rrect(cork, 6))
    ctx.setStrokeColor(inkTone.cg(0.7))
    ctx.setLineWidth(2.4)
    ctx.strokePath()
    drawText(ctx, "planted 1960 · watered 1972 · thriving still", font: "Georgia-Italic", size: 28, at: CGPoint(x: cx, y: h * 0.115), color: inkTone.cg(0.65))
    specimenGround(ctx, cx: cx, y: baseY, rand: rand)
}

drawGuidePlate("guide_build", "Building One for Real", "Fig. X — an afternoon's work, a lifetime's reward") { ctx, w, h, rand in
    let items: [(CGFloat, CGFloat, String)] = [
        (0.16, 0.5, "a jar that closes"),
        (0.38, 0.5, "pebbles, charcoal, soil"),
        (0.62, 0.5, "small plants, planted few"),
        (0.85, 0.5, "patience, applied daily"),
    ]
    let jarRect = CGRect(x: w * items[0].0 - 70, y: h * 0.3, width: 140, height: 240)
    miniJar(ctx, rect: jarRect, rand: rand, planted: false)
    let bowls = CGPoint(x: w * items[1].0, y: h * 0.42)
    for (i, tone) in [(0, RGB(r: 0.67, g: 0.66, b: 0.63)), (1, RGB(r: 0.267, g: 0.267, b: 0.267)), (2, soilTone)] {
        let bowlY = bowls.y + CGFloat(i) * 64
        let bowl = CGMutablePath()
        bowl.move(to: CGPoint(x: bowls.x - 70, y: bowlY))
        bowl.addQuadCurve(to: CGPoint(x: bowls.x + 70, y: bowlY), control: CGPoint(x: bowls.x, y: bowlY - 50))
        bowl.closeSubpath()
        washFill(ctx, bowl, tone, rand: rand)
        ctx.addPath(bowl)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(2.2)
        ctx.strokePath()
    }
    let pot = CGPoint(x: w * items[2].0, y: h * 0.4)
    for k in 0..<3 {
        let px = pot.x + CGFloat(k - 1) * 80
        let potRect = CGRect(x: px - 30, y: pot.y, width: 60, height: 50)
        washFill(ctx, rrect(potRect, 5), clayTone, rand: rand)
        inkRect(ctx, potRect, rand: rand, width: 2)
        genericSpecimen(ctx, kind: k == 1 ? "spikes" : "broad", cx: px, baseY: potRect.maxY, scale: 0.26, body: k == 0 ? mossTone : fernTone, accent: fernLight, rand: rand)
    }
    let clock = CGPoint(x: w * items[3].0, y: h * 0.46)
    ctx.setFillColor(paperTone.lighter(0.06).cg())
    ctx.fillEllipse(in: CGRect(x: clock.x - 60, y: clock.y - 60, width: 120, height: 120))
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3.4)
    ctx.strokeEllipse(in: CGRect(x: clock.x - 60, y: clock.y - 60, width: 120, height: 120))
    ctx.move(to: clock)
    ctx.addLine(to: CGPoint(x: clock.x + 30, y: clock.y + 24))
    ctx.move(to: clock)
    ctx.addLine(to: CGPoint(x: clock.x - 8, y: clock.y + 44))
    ctx.strokePath()
    for (fx, _, label) in items {
        drawText(ctx, label, font: "Georgia-Italic", size: 24, at: CGPoint(x: w * fx, y: h * 0.24), color: inkTone.cg(0.65))
    }
    drawText(ctx, "then do the hardest thing in the hobby: nothing", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.76), color: inkTone.cg(0.7))
}
print("GUIDES B DONE")

func drawOnboarding(_ id: String, _ index: Int) {
    let W = 1200, H = 1600
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(UInt64(730 + index))
    paperBase(ctx, w, h, seed: UInt64(61 + index))
    plateFrame(ctx, w, h, inset: 40)
    switch index {
    case 0:
        let jarRect = CGRect(x: w * 0.26, y: h * 0.26, width: w * 0.48, height: h * 0.5)
        miniJar(ctx, rect: jarRect, rand: rand)
        specimenGround(ctx, cx: w / 2, y: jarRect.minY - 8, rand: rand)
        wheatSprigNo(ctx)
        drawText(ctx, "PLATE THE FIRST", font: "Georgia-Bold", size: 34, at: CGPoint(x: w / 2, y: h * 0.14), color: inkTone.cg(0.8), tracking: 6)
        drawText(ctx, "a world, waiting for its lid", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.10), color: inkTone.cg(0.6))
    case 1:
        let jarRect = CGRect(x: w * 0.3, y: h * 0.3, width: w * 0.4, height: h * 0.42)
        miniJar(ctx, rect: jarRect, rand: rand)
        let moonC = CGPoint(x: w * 0.78, y: h * 0.78)
        ctx.setFillColor(RGB(r: 0.94, g: 0.93, b: 0.84).cg(0.95))
        ctx.fillEllipse(in: CGRect(x: moonC.x - 50, y: moonC.y - 50, width: 100, height: 100))
        ctx.setFillColor(paperTone.cg())
        ctx.fillEllipse(in: CGRect(x: moonC.x - 70, y: moonC.y - 34, width: 84, height: 84))
        ctx.setStrokeColor(inkTone.cg(0.6))
        ctx.setLineWidth(2.4)
        ctx.strokeEllipse(in: CGRect(x: moonC.x - 50, y: moonC.y - 50, width: 100, height: 100))
        for _ in 0..<20 {
            let sx = w * 0.14 + rand.next() * w * 0.72
            let sy = h * 0.74 + rand.next() * h * 0.14
            ctx.setFillColor(inkTone.cg(rand.range(0.3, 0.6)))
            ctx.fillEllipse(in: CGRect(x: sx, y: sy, width: 3.4, height: 3.4))
        }
        specimenGround(ctx, cx: w / 2, y: jarRect.minY - 8, rand: rand)
        drawText(ctx, "PLATE THE SECOND", font: "Georgia-Bold", size: 34, at: CGPoint(x: w / 2, y: h * 0.14), color: inkTone.cg(0.8), tracking: 6)
        drawText(ctx, "it lives while you sleep", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.10), color: inkTone.cg(0.6))
    default:
        for (i, fx) in [0.22, 0.5, 0.78].enumerated() {
            let jw = w * (i == 1 ? 0.24 : 0.18)
            let jh = h * (i == 1 ? 0.30 : 0.24)
            let jarRect = CGRect(x: w * CGFloat(fx) - jw / 2, y: h * 0.42, width: jw, height: jh)
            miniJar(ctx, rect: jarRect, rand: rand)
        }
        let shelfRect = CGRect(x: w * 0.08, y: h * 0.40, width: w * 0.84, height: 22)
        washFill(ctx, rrect(shelfRect, 6), soilTone.lighter(0.2), rand: rand)
        inkRect(ctx, shelfRect, rand: rand, width: 2.6)
        let book = CGRect(x: w * 0.2, y: h * 0.2, width: w * 0.2, height: h * 0.12)
        washFill(ctx, rrect(book, 8), mossDeep, rand: rand)
        inkRect(ctx, book, rand: rand, width: 2.4)
        drawText(ctx, "FIELD GUIDE", font: "Georgia-Bold", size: 22, at: CGPoint(x: book.midX, y: book.midY - 8), color: RGB(r: 0.9, g: 0.9, b: 0.85).cg(0.9), tracking: 2)
        let medal = CGPoint(x: w * 0.7, y: h * 0.26)
        ctx.setFillColor(brassTone.cg())
        ctx.fillEllipse(in: CGRect(x: medal.x - 40, y: medal.y - 40, width: 80, height: 80))
        ctx.setStrokeColor(inkTone.cg(0.75))
        ctx.setLineWidth(2.6)
        ctx.strokeEllipse(in: CGRect(x: medal.x - 40, y: medal.y - 40, width: 80, height: 80))
        drawText(ctx, "PLATE THE THIRD", font: "Georgia-Bold", size: 34, at: CGPoint(x: w / 2, y: h * 0.14), color: inkTone.cg(0.8), tracking: 6)
        drawText(ctx, "a shelf of weather, all yours", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.10), color: inkTone.cg(0.6))
    }
    saveJPEG(ctx, id)
}

func wheatSprigNo(_ ctx: CGContext) {
}

drawOnboarding("onboard_1", 0)
drawOnboarding("onboard_2", 1)
drawOnboarding("onboard_3", 2)
print("ALL ART DONE")
