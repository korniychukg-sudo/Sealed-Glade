import SwiftUI

enum JarArtist {
    static func glassPath(shape: JarShape, in rect: CGRect) -> Path {
        var p = Path()
        switch shape {
        case .belly:
            let w = rect.width
            let h = rect.height
            p.move(to: CGPoint(x: rect.minX + w * 0.30, y: rect.minY + h * 0.06))
            p.addCurve(to: CGPoint(x: rect.minX + w * 0.03, y: rect.minY + h * 0.52),
                       control1: CGPoint(x: rect.minX + w * 0.06, y: rect.minY + h * 0.10),
                       control2: CGPoint(x: rect.minX + w * 0.01, y: rect.minY + h * 0.30))
            p.addCurve(to: CGPoint(x: rect.minX + w * 0.16, y: rect.minY + h * 0.94),
                       control1: CGPoint(x: rect.minX + w * 0.05, y: rect.minY + h * 0.74),
                       control2: CGPoint(x: rect.minX + w * 0.07, y: rect.minY + h * 0.88))
            p.addCurve(to: CGPoint(x: rect.maxX - w * 0.16, y: rect.minY + h * 0.94),
                       control1: CGPoint(x: rect.minX + w * 0.36, y: rect.maxY + h * 0.015),
                       control2: CGPoint(x: rect.maxX - w * 0.36, y: rect.maxY + h * 0.015))
            p.addCurve(to: CGPoint(x: rect.maxX - w * 0.03, y: rect.minY + h * 0.52),
                       control1: CGPoint(x: rect.maxX - w * 0.07, y: rect.minY + h * 0.88),
                       control2: CGPoint(x: rect.maxX - w * 0.05, y: rect.minY + h * 0.74))
            p.addCurve(to: CGPoint(x: rect.maxX - w * 0.30, y: rect.minY + h * 0.06),
                       control1: CGPoint(x: rect.maxX - w * 0.01, y: rect.minY + h * 0.30),
                       control2: CGPoint(x: rect.maxX - w * 0.06, y: rect.minY + h * 0.10))
            p.closeSubpath()
        case .column:
            p.addRoundedRect(in: rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.02), cornerSize: CGSize(width: rect.width * 0.12, height: rect.width * 0.12))
        case .flask:
            let w = rect.width
            let h = rect.height
            p.move(to: CGPoint(x: rect.minX + w * 0.40, y: rect.minY + h * 0.04))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.40, y: rect.minY + h * 0.24))
            p.addCurve(to: CGPoint(x: rect.minX + w * 0.08, y: rect.minY + h * 0.78),
                       control1: CGPoint(x: rect.minX + w * 0.40, y: rect.minY + h * 0.44),
                       control2: CGPoint(x: rect.minX + w * 0.08, y: rect.minY + h * 0.52))
            p.addCurve(to: CGPoint(x: rect.minX + w * 0.22, y: rect.minY + h * 0.97),
                       control1: CGPoint(x: rect.minX + w * 0.08, y: rect.minY + h * 0.90),
                       control2: CGPoint(x: rect.minX + w * 0.10, y: rect.minY + h * 0.96))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.22, y: rect.minY + h * 0.97))
            p.addCurve(to: CGPoint(x: rect.maxX - w * 0.08, y: rect.minY + h * 0.78),
                       control1: CGPoint(x: rect.maxX - w * 0.10, y: rect.minY + h * 0.96),
                       control2: CGPoint(x: rect.maxX - w * 0.08, y: rect.minY + h * 0.90))
            p.addCurve(to: CGPoint(x: rect.maxX - w * 0.40, y: rect.minY + h * 0.24),
                       control1: CGPoint(x: rect.maxX - w * 0.08, y: rect.minY + h * 0.52),
                       control2: CGPoint(x: rect.maxX - w * 0.40, y: rect.minY + h * 0.44))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.40, y: rect.minY + h * 0.04))
            p.closeSubpath()
        }
        return p
    }

    static func soilSurfaceY(shape: JarShape, in rect: CGRect) -> CGFloat {
        switch shape {
        case .belly: return rect.minY + rect.height * 0.68
        case .column: return rect.minY + rect.height * 0.72
        case .flask: return rect.minY + rect.height * 0.74
        }
    }

    static func drawJar(_ ctx: inout GraphicsContext, rect: CGRect, jar: JarState, phase: Double, daylight: Double) {
        let glass = glassPath(shape: jar.shape, in: rect)
        let soilY = soilSurfaceY(shape: jar.shape, in: rect)

        ctx.fill(Path(ellipseIn: CGRect(x: rect.midX - rect.width * 0.42, y: rect.maxY - rect.height * 0.035, width: rect.width * 0.84, height: rect.height * 0.05)), with: .color(Color.black.opacity(0.16)))

        ctx.fill(glass, with: .linearGradient(
            Gradient(colors: [GladeTheme.glass.opacity(0.55), GladeTheme.mist.opacity(0.35)]),
            startPoint: CGPoint(x: rect.minX, y: rect.minY),
            endPoint: CGPoint(x: rect.maxX, y: rect.maxY)))

        var inner = ctx
        inner.clip(to: glass)

        if jar.spot == .sun {
            var beam = Path()
            beam.move(to: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.minY))
            beam.addLine(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY))
            beam.addLine(to: CGPoint(x: rect.minX + rect.width * 0.9, y: rect.maxY))
            beam.addLine(to: CGPoint(x: rect.minX + rect.width * 0.5, y: rect.maxY))
            beam.closeSubpath()
            inner.fill(beam, with: .color(GladeTheme.amber.opacity(0.10 + daylight * 0.08)))
        }

        drawSubstrate(&inner, rect: rect, soilY: soilY, jar: jar)
        drawMoldAndLitter(&inner, rect: rect, soilY: soilY, jar: jar, phase: phase)

        let sorted = jar.plants.sorted { $0.x < $1.x }
        for plant in sorted {
            drawPlant(&inner, plant: plant, rect: rect, soilY: soilY, phase: phase)
        }

        drawFauna(&inner, rect: rect, soilY: soilY, jar: jar, phase: phase)
        drawCondensation(&inner, rect: rect, glass: glass, jar: jar, phase: phase)

        if jar.algae > 0.06 {
            var algaeCtx = inner
            algaeCtx.clip(to: glass.strokedPath(StrokeStyle(lineWidth: rect.width * 0.10)))
            var rng = GladeSeededRandom(seed: 61)
            for _ in 0..<Int(jar.algae * 60) {
                let x = rect.minX + rng.next() * rect.width
                let y = rect.minY + rng.next() * rect.height
                let r = 2 + rng.next() * 5
                algaeCtx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)), with: .color(GladeTheme.fern.opacity(0.10 + Double(jar.algae) * 0.25)))
            }
        }

        var shine = Path()
        shine.move(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.14))
        shine.addQuadCurve(to: CGPoint(x: rect.minX + rect.width * 0.13, y: rect.minY + rect.height * 0.6),
                           control: CGPoint(x: rect.minX + rect.width * 0.07, y: rect.minY + rect.height * 0.36))
        ctx.stroke(shine, with: .color(Color.white.opacity(0.5)), style: StrokeStyle(lineWidth: rect.width * 0.035, lineCap: .round))
        var shine2 = Path()
        shine2.move(to: CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.minY + rect.height * 0.2))
        shine2.addQuadCurve(to: CGPoint(x: rect.maxX - rect.width * 0.15, y: rect.minY + rect.height * 0.42),
                            control: CGPoint(x: rect.maxX - rect.width * 0.11, y: rect.minY + rect.height * 0.3))
        ctx.stroke(shine2, with: .color(Color.white.opacity(0.3)), style: StrokeStyle(lineWidth: rect.width * 0.02, lineCap: .round))

        ctx.stroke(glass, with: .color(GladeTheme.glassEdge.opacity(0.9)), lineWidth: 2.4)
        drawLid(&ctx, rect: rect, shape: jar.shape)
    }

    private static func drawLid(_ ctx: inout GraphicsContext, rect: CGRect, shape: JarShape) {
        switch shape {
        case .belly:
            let lid = CGRect(x: rect.minX + rect.width * 0.27, y: rect.minY - rect.height * 0.015, width: rect.width * 0.46, height: rect.height * 0.075)
            ctx.fill(Path(roundedRect: lid, cornerRadius: 5), with: .linearGradient(Gradient(colors: [GladeTheme.amber, GladeTheme.amberDeep]), startPoint: CGPoint(x: lid.minX, y: lid.minY), endPoint: CGPoint(x: lid.minX, y: lid.maxY)))
            ctx.stroke(Path(roundedRect: lid, cornerRadius: 5), with: .color(GladeTheme.ink.opacity(0.5)), lineWidth: 1.6)
            for i in 1..<5 {
                var rib = Path()
                let rx = lid.minX + lid.width * CGFloat(i) / 5
                rib.move(to: CGPoint(x: rx, y: lid.minY + 2))
                rib.addLine(to: CGPoint(x: rx, y: lid.maxY - 2))
                ctx.stroke(rib, with: .color(GladeTheme.ink.opacity(0.18)), lineWidth: 1)
            }
        case .column:
            let lid = CGRect(x: rect.minX + rect.width * 0.10, y: rect.minY - rect.height * 0.012, width: rect.width * 0.8, height: rect.height * 0.06)
            ctx.fill(Path(roundedRect: lid, cornerRadius: 6), with: .linearGradient(Gradient(colors: [GladeTheme.pebble, GladeTheme.charcoal.opacity(0.8)]), startPoint: CGPoint(x: lid.minX, y: lid.minY), endPoint: CGPoint(x: lid.minX, y: lid.maxY)))
            ctx.stroke(Path(roundedRect: lid, cornerRadius: 6), with: .color(GladeTheme.ink.opacity(0.5)), lineWidth: 1.6)
        case .flask:
            let cork = CGRect(x: rect.minX + rect.width * 0.385, y: rect.minY - rect.height * 0.03, width: rect.width * 0.23, height: rect.height * 0.085)
            ctx.fill(Path(roundedRect: cork, cornerRadius: 4), with: .linearGradient(Gradient(colors: [GladeTheme.clay, GladeTheme.soilLight]), startPoint: CGPoint(x: cork.minX, y: cork.minY), endPoint: CGPoint(x: cork.minX, y: cork.maxY)))
            ctx.stroke(Path(roundedRect: cork, cornerRadius: 4), with: .color(GladeTheme.ink.opacity(0.5)), lineWidth: 1.6)
            var rng = GladeSeededRandom(seed: 17)
            for _ in 0..<7 {
                let px = cork.minX + rng.next() * cork.width
                let py = cork.minY + rng.next() * cork.height
                ctx.fill(Path(ellipseIn: CGRect(x: px, y: py, width: 2, height: 1.4)), with: .color(GladeTheme.ink.opacity(0.2)))
            }
        }
    }

    private static func drawSubstrate(_ ctx: inout GraphicsContext, rect: CGRect, soilY: CGFloat, jar: JarState) {
        let bottom = rect.maxY
        let pebbleTop = bottom - rect.height * 0.10
        let charcoalTop = pebbleTop - rect.height * 0.035
        ctx.fill(Path(CGRect(x: rect.minX, y: soilY, width: rect.width, height: charcoalTop - soilY)), with: .linearGradient(Gradient(colors: [GladeTheme.soil, GladeTheme.soilLight.opacity(0.9)]), startPoint: CGPoint(x: rect.minX, y: soilY), endPoint: CGPoint(x: rect.minX, y: charcoalTop)))
        var rng = GladeSeededRandom(seed: 5)
        for _ in 0..<40 {
            let x = rect.minX + rng.next() * rect.width
            let y = soilY + rng.next() * (charcoalTop - soilY)
            ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2.4, height: 1.8)), with: .color(GladeTheme.ink.opacity(0.15 + Double(rng.next()) * 0.15)))
        }
        ctx.fill(Path(CGRect(x: rect.minX, y: charcoalTop, width: rect.width, height: pebbleTop - charcoalTop)), with: .color(GladeTheme.charcoal))
        for _ in 0..<20 {
            let x = rect.minX + rng.next() * rect.width
            let y = charcoalTop + rng.next() * (pebbleTop - charcoalTop)
            ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 3, height: 2)), with: .color(Color.white.opacity(0.10)))
        }
        ctx.fill(Path(CGRect(x: rect.minX, y: pebbleTop, width: rect.width, height: bottom - pebbleTop)), with: .color(GladeTheme.pebble.opacity(0.8)))
        for i in 0..<16 {
            let x = rect.minX + (CGFloat(i) + rng.next() * 0.8) * rect.width / 16
            let y = pebbleTop + rng.next() * (bottom - pebbleTop - 8)
            let r = 5 + rng.next() * 7
            let pebble = Path(ellipseIn: CGRect(x: x, y: y, width: r * 1.5, height: r))
            ctx.fill(pebble, with: .color(GladeTheme.pebble.opacity(0.5 + Double(rng.next()) * 0.4)))
            ctx.stroke(pebble, with: .color(GladeTheme.ink.opacity(0.2)), lineWidth: 0.8)
        }
        var surface = Path()
        surface.move(to: CGPoint(x: rect.minX, y: soilY))
        var sx = rect.minX
        while sx < rect.maxX {
            sx += 14
            surface.addQuadCurve(to: CGPoint(x: sx, y: soilY + (rng.next() - 0.5) * 4), control: CGPoint(x: sx - 7, y: soilY - 3))
        }
        ctx.stroke(surface, with: .color(GladeTheme.soil.opacity(0.8)), lineWidth: 2)
    }

    private static func drawMoldAndLitter(_ ctx: inout GraphicsContext, rect: CGRect, soilY: CGFloat, jar: JarState, phase: Double) {
        var rng = GladeSeededRandom(seed: 43)
        let litterCount = Int(jar.deadMatter * 16)
        for _ in 0..<litterCount {
            let x = rect.minX + rect.width * (0.1 + rng.next() * 0.8)
            let y = soilY - 2 + rng.next() * 5
            var leaf = Path()
            leaf.addEllipse(in: CGRect(x: x, y: y, width: 6 + rng.next() * 5, height: 3 + rng.next() * 2))
            ctx.fill(leaf, with: .color(GladeTheme.soilLight.opacity(0.7)))
            ctx.stroke(leaf, with: .color(GladeTheme.rust.opacity(0.5)), lineWidth: 0.7)
        }
        if jar.mold > 0.08 {
            let patches = Int(jar.mold * 8) + 1
            for _ in 0..<patches {
                let x = rect.minX + rect.width * (0.12 + rng.next() * 0.76)
                let y = soilY - 3 + rng.next() * 6
                let r = 4 + rng.next() * 8 * CGFloat(jar.mold)
                for _ in 0..<6 {
                    let fx = x + (rng.next() - 0.5) * r * 2
                    let fy = y + (rng.next() - 0.5) * r
                    ctx.fill(Path(ellipseIn: CGRect(x: fx, y: fy, width: 2.6, height: 2.6)), with: .color(Color(red: 0.78, green: 0.78, blue: 0.74).opacity(0.5)))
                }
            }
        }
    }

    private static func plantColors(_ species: PlantSpecies, health: Double) -> (Color, Color, Color) {
        let hues: [(Color, Color, Color)] = [
            (GladeTheme.moss, GladeTheme.mossDeep, GladeTheme.fernLight),
            (GladeTheme.fern, GladeTheme.mossDeep, GladeTheme.fernLight),
            (Color(red: 0.32, green: 0.45, blue: 0.30), GladeTheme.mossDeep, Color(red: 0.88, green: 0.62, blue: 0.66)),
            (Color(red: 0.48, green: 0.62, blue: 0.36), GladeTheme.moss, GladeTheme.fernLight),
            (Color(red: 0.42, green: 0.53, blue: 0.36), GladeTheme.mossDeep, Color(red: 0.72, green: 0.78, blue: 0.58)),
            (Color(red: 0.36, green: 0.50, blue: 0.32), GladeTheme.mossDeep, Color(red: 0.85, green: 0.88, blue: 0.72)),
            (Color(red: 0.52, green: 0.64, blue: 0.38), GladeTheme.moss, Color(red: 0.82, green: 0.85, blue: 0.55)),
            (Color(red: 0.45, green: 0.48, blue: 0.32), GladeTheme.mossDeep, Color(red: 0.85, green: 0.55, blue: 0.58)),
            (Color(red: 0.40, green: 0.52, blue: 0.38), GladeTheme.mossDeep, Color(red: 0.62, green: 0.70, blue: 0.52)),
            (Color(red: 0.38, green: 0.55, blue: 0.33), GladeTheme.mossDeep, Color(red: 0.90, green: 0.85, blue: 0.50)),
            (Color(red: 0.44, green: 0.58, blue: 0.40), GladeTheme.mossDeep, GladeTheme.fernLight),
            (Color(red: 0.36, green: 0.55, blue: 0.36), GladeTheme.mossDeep, GladeTheme.fernLight),
        ]
        var (body, dark, accent) = hues[species.hue % hues.count]
        if health < 0.45 {
            let t = (0.45 - health) / 0.45
            body = blend(body, Color(red: 0.62, green: 0.55, blue: 0.35), t)
            accent = blend(accent, Color(red: 0.66, green: 0.58, blue: 0.4), t)
            dark = blend(dark, Color(red: 0.5, green: 0.44, blue: 0.3), t)
        }
        return (body, dark, accent)
    }

    private static func blend(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let ca = UIColor(a)
        let cb = UIColor(b)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        ca.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        cb.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let tt = CGFloat(t.gladeClamped(0, 1))
        return Color(red: ar + (br - ar) * tt, green: ag + (bg - ag) * tt, blue: ab + (bb - ab) * tt)
    }

    static func drawPlant(_ ctx: inout GraphicsContext, plant: PlantInstance, rect: CGRect, soilY: CGFloat, phase: Double) {
        let species = GladeSpecies.plant(plant.speciesID)
        let (body, dark, accent) = plantColors(species, health: plant.health)
        var rng = GladeSeededRandom(seed: plant.seed)
        let usable = rect.insetBy(dx: rect.width * 0.14, dy: 0)
        let baseX = usable.minX + usable.width * CGFloat(plant.x)
        let scale = CGFloat(0.25 + plant.growth * 0.75)
        let maxH = (soilY - rect.minY) * 0.72
        let sway = CGFloat(sin(phase * 0.7 + Double(plant.seed % 7))) * 1.5

        switch species.drawKind {
        case .mound:
            let w = rect.width * 0.24 * scale
            let h = w * 0.5
            for _ in 0..<Int(14 * scale + 4) {
                let a = rng.next() * .pi
                let rr = sqrt(rng.next())
                let cx = baseX + cos(a) * w * 0.5 * rr
                let cy = soilY - abs(sin(a)) * h * rr
                let r = 3 + rng.next() * 4 * scale
                ctx.fill(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)), with: .color(rng.next() > 0.5 ? body : dark))
            }
            for _ in 0..<Int(6 * scale) {
                let cx = baseX + (rng.next() - 0.5) * w
                let cy = soilY - rng.next() * h * 0.8
                ctx.fill(Path(ellipseIn: CGRect(x: cx, y: cy, width: 2, height: 2)), with: .color(accent.opacity(0.7)))
            }
        case .frond:
            let fronds = Int(3 + scale * 3)
            for f in 0..<fronds {
                let ang = -CGFloat.pi / 2 + (CGFloat(f) / CGFloat(max(1, fronds - 1)) - 0.5) * 1.5
                let len = maxH * scale * (0.5 + rng.next() * 0.4)
                let tip = CGPoint(x: baseX + cos(ang) * len + sway, y: soilY + sin(ang) * len)
                var stem = Path()
                stem.move(to: CGPoint(x: baseX, y: soilY))
                let ctrl = CGPoint(x: baseX + cos(ang) * len * 0.5, y: soilY + sin(ang) * len * 0.62)
                stem.addQuadCurve(to: tip, control: ctrl)
                ctx.stroke(stem, with: .color(dark), lineWidth: 1.6)
                let leaflets = Int(len / 7)
                for l in 1..<max(2, leaflets) {
                    let t = CGFloat(l) / CGFloat(leaflets)
                    let px = baseX + (ctrl.x - baseX) * 2 * t * (1 - t) + (tip.x - baseX) * t * t + baseX * 0
                    let bx = (1 - t) * (1 - t) * baseX + 2 * (1 - t) * t * ctrl.x + t * t * tip.x
                    let by = (1 - t) * (1 - t) * soilY + 2 * (1 - t) * t * ctrl.y + t * t * tip.y
                    _ = px
                    let leafR = (1 - t * 0.6) * 4.4 * scale
                    ctx.fill(Path(ellipseIn: CGRect(x: bx - leafR, y: by - leafR * 0.5, width: leafR * 2, height: leafR)), with: .color(body.opacity(0.92)))
                }
            }
        case .veined:
            let leaves = Int(2 + scale * 3)
            for _ in 0..<leaves {
                let ang = -CGFloat.pi / 2 + (rng.next() - 0.5) * 1.3
                let len = maxH * scale * (0.3 + rng.next() * 0.3)
                let cx = baseX + cos(ang) * len + sway
                let cy = soilY + sin(ang) * len
                let w = 12 * scale + rng.next() * 6
                let leaf = Path(ellipseIn: CGRect(x: cx - w / 2, y: cy - w * 0.65, width: w, height: w * 1.3))
                ctx.fill(leaf, with: .color(body))
                ctx.stroke(leaf, with: .color(dark.opacity(0.7)), lineWidth: 1)
                var vein = Path()
                vein.move(to: CGPoint(x: cx, y: cy + w * 0.6))
                vein.addLine(to: CGPoint(x: cx, y: cy - w * 0.6))
                for k in 0..<3 {
                    let vy = cy - w * 0.4 + CGFloat(k) * w * 0.35
                    vein.move(to: CGPoint(x: cx, y: vy))
                    vein.addLine(to: CGPoint(x: cx - w * 0.32, y: vy + w * 0.14))
                    vein.move(to: CGPoint(x: cx, y: vy))
                    vein.addLine(to: CGPoint(x: cx + w * 0.32, y: vy + w * 0.14))
                }
                ctx.stroke(vein, with: .color(accent), lineWidth: 1.1)
                var stem = Path()
                stem.move(to: CGPoint(x: baseX, y: soilY))
                stem.addLine(to: CGPoint(x: cx, y: cy + w * 0.6))
                ctx.stroke(stem, with: .color(dark), lineWidth: 1.4)
            }
        case .creeping:
            let spread = rect.width * 0.3 * scale
            for _ in 0..<Int(26 * scale + 8) {
                let cx = baseX + (rng.next() - 0.5) * spread * 2
                let cy = soilY - rng.next() * 14 * scale
                let r = 1.6 + rng.next() * 2
                ctx.fill(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)), with: .color(rng.next() > 0.3 ? body : accent.opacity(0.8)))
            }
        case .broad:
            let leaves = Int(3 + scale * 3)
            for _ in 0..<leaves {
                let ang = -CGFloat.pi / 2 + (rng.next() - 0.5) * 1.6
                let len = maxH * scale * (0.28 + rng.next() * 0.3)
                let cx = baseX + cos(ang) * len + sway
                let cy = soilY + sin(ang) * len
                let r = 7 * scale + rng.next() * 4
                var stem = Path()
                stem.move(to: CGPoint(x: baseX, y: soilY))
                stem.addQuadCurve(to: CGPoint(x: cx, y: cy), control: CGPoint(x: baseX, y: cy + 8))
                ctx.stroke(stem, with: .color(dark), lineWidth: 1.6)
                let leaf = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.fill(leaf, with: .color(body))
                ctx.stroke(leaf, with: .color(dark.opacity(0.6)), lineWidth: 1)
                ctx.fill(Path(ellipseIn: CGRect(x: cx - r * 0.4, y: cy - r * 0.55, width: r * 0.7, height: r * 0.45)), with: .color(accent.opacity(0.5)))
            }
        case .trailing:
            let vines = Int(2 + scale * 2)
            for v in 0..<vines {
                let dir: CGFloat = v % 2 == 0 ? -1 : 1
                let len = maxH * scale * (0.6 + rng.next() * 0.5)
                var vine = Path()
                vine.move(to: CGPoint(x: baseX, y: soilY))
                let mid = CGPoint(x: baseX + dir * len * 0.5, y: soilY - len * 0.5)
                let tip = CGPoint(x: baseX + dir * len * 0.72 + sway, y: soilY - len)
                vine.addQuadCurve(to: tip, control: mid)
                ctx.stroke(vine, with: .color(dark), lineWidth: 1.5)
                let leafCount = Int(len / 11)
                for l in 1...max(1, leafCount) {
                    let t = CGFloat(l) / CGFloat(max(1, leafCount))
                    let bx = (1 - t) * (1 - t) * baseX + 2 * (1 - t) * t * mid.x + t * t * tip.x
                    let by = (1 - t) * (1 - t) * soilY + 2 * (1 - t) * t * mid.y + t * t * tip.y
                    let r = 4.4 * scale
                    var heart = Path()
                    heart.move(to: CGPoint(x: bx, y: by + r))
                    heart.addQuadCurve(to: CGPoint(x: bx - r, y: by - r * 0.4), control: CGPoint(x: bx - r * 1.2, y: by + r * 0.4))
                    heart.addQuadCurve(to: CGPoint(x: bx, y: by - r * 0.2), control: CGPoint(x: bx - r * 0.4, y: by - r))
                    heart.addQuadCurve(to: CGPoint(x: bx + r, y: by - r * 0.4), control: CGPoint(x: bx + r * 0.4, y: by - r))
                    heart.addQuadCurve(to: CGPoint(x: bx, y: by + r), control: CGPoint(x: bx + r * 1.2, y: by + r * 0.4))
                    ctx.fill(heart, with: .color(l % 3 == 0 ? accent.opacity(0.85) : body))
                }
            }
        case .spikes:
            let sprays = Int(4 + scale * 4)
            for _ in 0..<sprays {
                let ang = -CGFloat.pi / 2 + (rng.next() - 0.5) * 1.7
                let len = maxH * scale * (0.35 + rng.next() * 0.4)
                let tip = CGPoint(x: baseX + cos(ang) * len + sway, y: soilY + sin(ang) * len)
                var spray = Path()
                spray.move(to: CGPoint(x: baseX, y: soilY))
                spray.addLine(to: tip)
                ctx.stroke(spray, with: .color(body), lineWidth: 2.2)
                for t in stride(from: 0.3, through: 0.95, by: 0.16) {
                    let bx = baseX + (tip.x - baseX) * CGFloat(t)
                    let by = soilY + (tip.y - soilY) * CGFloat(t)
                    var tuft = Path()
                    tuft.move(to: CGPoint(x: bx, y: by))
                    tuft.addLine(to: CGPoint(x: bx - 4 * scale, y: by - 3 * scale))
                    tuft.move(to: CGPoint(x: bx, y: by))
                    tuft.addLine(to: CGPoint(x: bx + 4 * scale, y: by - 3 * scale))
                    ctx.stroke(tuft, with: .color(accent.opacity(0.8)), lineWidth: 1.2)
                }
            }
        case .rosette:
            let leaves = Int(6 + scale * 4)
            for l in 0..<leaves {
                let ang = CGFloat(l) / CGFloat(leaves) * 2 * .pi
                let len = rect.width * 0.13 * scale * (0.7 + rng.next() * 0.5)
                let tip = CGPoint(x: baseX + cos(ang) * len, y: soilY - 3 + sin(ang) * len * 0.36)
                var leaf = Path()
                leaf.move(to: CGPoint(x: baseX, y: soilY - 2))
                leaf.addQuadCurve(to: tip, control: CGPoint(x: baseX + cos(ang) * len * 0.5, y: soilY - 7 + sin(ang) * len * 0.2))
                ctx.stroke(leaf, with: .color(l % 2 == 0 ? body : accent), style: StrokeStyle(lineWidth: 3.4 * scale, lineCap: .round))
            }
        case .buttons:
            let strings = Int(2 + scale * 2)
            for v in 0..<strings {
                let dir: CGFloat = v % 2 == 0 ? -1 : 1
                let len = maxH * scale * (0.45 + rng.next() * 0.4)
                var thread = Path()
                thread.move(to: CGPoint(x: baseX, y: soilY))
                let tip = CGPoint(x: baseX + dir * len * 0.5 + sway, y: soilY - len * 0.24)
                thread.addQuadCurve(to: tip, control: CGPoint(x: baseX + dir * len * 0.25, y: soilY - len * 0.34))
                ctx.stroke(thread, with: .color(dark), lineWidth: 1)
                for t in stride(from: 0.15, through: 1.0, by: 0.17) {
                    let bx = baseX + (tip.x - baseX) * CGFloat(t)
                    let by = soilY - (soilY - tip.y) * CGFloat(sin(t * .pi))
                    let r = 3.2 * scale
                    let button = Path(ellipseIn: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2))
                    ctx.fill(button, with: .color(body))
                    ctx.stroke(button, with: .color(accent.opacity(0.9)), lineWidth: 0.9)
                }
            }
        case .fan:
            let stems = Int(2 + scale * 2)
            for _ in 0..<stems {
                let ang = -CGFloat.pi / 2 + (rng.next() - 0.5) * 0.8
                let len = maxH * scale * (0.5 + rng.next() * 0.35)
                let top = CGPoint(x: baseX + cos(ang) * len * 0.3 + sway, y: soilY + sin(ang) * len)
                var stem = Path()
                stem.move(to: CGPoint(x: baseX, y: soilY))
                stem.addLine(to: top)
                ctx.stroke(stem, with: .color(dark), lineWidth: 1.8)
                for f in 0..<7 {
                    let fa = -CGFloat.pi / 2 + (CGFloat(f) / 6 - 0.5) * 1.9
                    let flen = len * 0.42
                    var frond = Path()
                    frond.move(to: top)
                    frond.addLine(to: CGPoint(x: top.x + cos(fa) * flen, y: top.y + sin(fa) * flen))
                    ctx.stroke(frond, with: .color(body), style: StrokeStyle(lineWidth: 2.4 * scale, lineCap: .round))
                }
            }
        }
    }

    private static func drawFauna(_ ctx: inout GraphicsContext, rect: CGRect, soilY: CGFloat, jar: JarState, phase: Double) {
        for group in jar.fauna {
            var rng = GladeSeededRandom(seed: UInt64(abs(group.speciesID.hashValue % 9999)) &+ 3)
            switch group.speciesID {
            case "springtails":
                let count = Int(group.population * 14)
                for i in 0..<count {
                    let ox = rng.next() * rect.width * 0.8 + rect.width * 0.1
                    let wander = CGFloat(sin(phase * (1.2 + Double(rng.next())) + Double(i))) * 9
                    let hop = abs(CGFloat(sin(phase * 2.6 + Double(i) * 1.7))) * 3
                    let x = rect.minX + ox + wander
                    let y = soilY - 2 - hop
                    ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(Color.white.opacity(0.85)))
                }
            case "snail":
                if group.population > 0.05 {
                    let t = CGFloat((phase * 0.02 + Double(rng.next())).truncatingRemainder(dividingBy: 1))
                    let x = rect.minX + rect.width * (0.2 + t * 0.6)
                    let y = rect.minY + rect.height * (0.30 + CGFloat(sin(t * .pi * 2)) * 0.12)
                    let shell = Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 9))
                    ctx.fill(shell, with: .color(GladeTheme.clay.opacity(0.85)))
                    ctx.stroke(shell, with: .color(GladeTheme.ink.opacity(0.5)), lineWidth: 0.9)
                    ctx.fill(Path(ellipseIn: CGRect(x: x + 3, y: y - 1, width: 7, height: 3.4)), with: .color(GladeTheme.soilLight.opacity(0.9)))
                    var trail = Path()
                    trail.move(to: CGPoint(x: x - 22, y: y + 3))
                    trail.addQuadCurve(to: CGPoint(x: x, y: y + 2), control: CGPoint(x: x - 11, y: y + 5))
                    ctx.stroke(trail, with: .color(Color.white.opacity(0.25)), lineWidth: 1.6)
                }
            default:
                let count = Int(group.population * 6)
                for i in 0..<count {
                    let ox = rng.next() * rect.width * 0.76 + rect.width * 0.12
                    let crawl = CGFloat(sin(phase * 0.5 + Double(i) * 2.2)) * 14
                    let x = rect.minX + ox + crawl
                    let y = soilY - 1 + rng.next() * 4
                    let bug = Path(ellipseIn: CGRect(x: x - 3, y: y - 1.8, width: 6, height: 3.6))
                    let isClown = group.speciesID == "clownisopods"
                    ctx.fill(bug, with: .color(isClown ? GladeTheme.rust.opacity(0.9) : Color(red: 0.82, green: 0.82, blue: 0.78)))
                    ctx.stroke(bug, with: .color(GladeTheme.ink.opacity(0.4)), lineWidth: 0.7)
                    if isClown {
                        ctx.fill(Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1, width: 1.4, height: 1.4)), with: .color(Color.white.opacity(0.9)))
                        ctx.fill(Path(ellipseIn: CGRect(x: x + 0.6, y: y - 0.6, width: 1.4, height: 1.4)), with: .color(Color.white.opacity(0.9)))
                    }
                }
            }
        }
    }

    private static func drawCondensation(_ ctx: inout GraphicsContext, rect: CGRect, glass: Path, jar: JarState, phase: Double) {
        let intensity = (jar.water * (0.4 + jar.spot.light)).gladeClamped(0, 1)
        guard intensity > 0.25 else { return }
        var rng = GladeSeededRandom(seed: 29)
        let count = Int(intensity * 26)
        for i in 0..<count {
            let side: CGFloat = rng.next() > 0.5 ? 1 : 0
            let x = rect.minX + rect.width * (0.06 + side * 0.82 + rng.next() * 0.06)
            let cycle = (phase * (0.014 + Double(rng.next()) * 0.02) + Double(rng.next())).truncatingRemainder(dividingBy: 1)
            let y = rect.minY + rect.height * (0.12 + CGFloat(cycle) * 0.5)
            let r = 1.4 + rng.next() * 2.2
            ctx.fill(Path(ellipseIn: CGRect(x: x - r / 2, y: y, width: r, height: r * 1.5)), with: .color(Color.white.opacity(0.35)))
            if i % 3 == 0 {
                var streak = Path()
                streak.move(to: CGPoint(x: x, y: y - 8))
                streak.addLine(to: CGPoint(x: x, y: y))
                ctx.stroke(streak, with: .color(Color.white.opacity(0.15)), lineWidth: 1)
            }
        }
        if intensity > 0.6 {
            var fog = Path()
            fog.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.06, width: rect.width * 0.7, height: rect.height * 0.2))
            ctx.fill(fog, with: .color(Color.white.opacity((intensity - 0.6) * 0.4)))
        }
    }
}
