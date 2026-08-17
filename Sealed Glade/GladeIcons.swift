import SwiftUI

enum GIconKind {
    case glade, shelf, guide, journal
    case check, lock, chevronRight, chevronDown, star, close, plus, leafSprig, drop, wind, sponge, scissors, sunSpot, jarSmall, bug, clock, ribbon, book, sparkle, seal
}

struct GIcon: View {
    let kind: GIconKind
    var size: CGFloat = 24
    var color: Color = GladeTheme.ink

    var body: some View {
        Canvas { ctx, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: canvasSize.width * 0.08, dy: canvasSize.height * 0.08)
            draw(&ctx, rect: rect)
        }
        .frame(width: size, height: size)
    }

    private func stroke(_ ctx: inout GraphicsContext, _ p: Path, _ w: CGFloat) {
        ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
    }

    private func draw(_ ctx: inout GraphicsContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let lw = max(1.4, w * 0.09)
        switch kind {
        case .glade, .jarSmall:
            var jar = Path()
            jar.move(to: CGPoint(x: rect.minX + w * 0.3, y: rect.minY + h * 0.18))
            jar.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.12, y: rect.midY), control: CGPoint(x: rect.minX + w * 0.12, y: rect.minY + h * 0.24))
            jar.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.26, y: rect.maxY), control: CGPoint(x: rect.minX + w * 0.12, y: rect.maxY - h * 0.06))
            jar.addLine(to: CGPoint(x: rect.maxX - w * 0.26, y: rect.maxY))
            jar.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.midY), control: CGPoint(x: rect.maxX - w * 0.12, y: rect.maxY - h * 0.06))
            jar.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.3, y: rect.minY + h * 0.18), control: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY + h * 0.24))
            stroke(&ctx, jar, lw)
            var lid = Path()
            lid.addRoundedRect(in: CGRect(x: rect.minX + w * 0.26, y: rect.minY + h * 0.04, width: w * 0.48, height: h * 0.12), cornerSize: CGSize(width: 2, height: 2))
            stroke(&ctx, lid, lw * 0.9)
            var sprout = Path()
            sprout.move(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.12))
            sprout.addLine(to: CGPoint(x: rect.midX, y: rect.midY + h * 0.04))
            stroke(&ctx, sprout, lw * 0.8)
            for side in [-1.0, 1.0] {
                var leaf = Path()
                leaf.move(to: CGPoint(x: rect.midX, y: rect.midY + h * 0.12))
                leaf.addQuadCurve(to: CGPoint(x: rect.midX + CGFloat(side) * w * 0.14, y: rect.midY - h * 0.02), control: CGPoint(x: rect.midX + CGFloat(side) * w * 0.16, y: rect.midY + h * 0.12))
                leaf.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.midY + h * 0.12), control: CGPoint(x: rect.midX + CGFloat(side) * w * 0.05, y: rect.midY + h * 0.02))
                ctx.fill(leaf, with: .color(color))
            }
            var ground = Path()
            ground.move(to: CGPoint(x: rect.minX + w * 0.3, y: rect.maxY - h * 0.12))
            ground.addLine(to: CGPoint(x: rect.maxX - w * 0.3, y: rect.maxY - h * 0.12))
            stroke(&ctx, ground, lw * 0.7)
        case .shelf:
            for sy in [rect.minY + h * 0.34, rect.minY + h * 0.72] {
                var shelf = Path()
                shelf.move(to: CGPoint(x: rect.minX, y: sy))
                shelf.addLine(to: CGPoint(x: rect.maxX, y: sy))
                stroke(&ctx, shelf, lw)
            }
            for (jx, jy) in [(0.22, 0.34), (0.58, 0.34), (0.4, 0.72)] {
                var mini = Path()
                mini.addRoundedRect(in: CGRect(x: rect.minX + w * CGFloat(jx), y: rect.minY + h * CGFloat(jy) - h * 0.24, width: w * 0.2, height: h * 0.22), cornerSize: CGSize(width: 3, height: 3))
                stroke(&ctx, mini, lw * 0.8)
            }
        case .guide:
            var leaf = Path()
            leaf.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            leaf.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX - w * 0.08, y: rect.midY - h * 0.08))
            leaf.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX + w * 0.08, y: rect.midY + h * 0.08))
            stroke(&ctx, leaf, lw)
            var vein = Path()
            vein.move(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.06))
            vein.addLine(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.12))
            for t in [0.3, 0.5, 0.7] {
                let vy = rect.maxY - h * CGFloat(t)
                vein.move(to: CGPoint(x: rect.midX, y: vy))
                vein.addLine(to: CGPoint(x: rect.midX - w * 0.16, y: vy - h * 0.08))
                vein.move(to: CGPoint(x: rect.midX, y: vy))
                vein.addLine(to: CGPoint(x: rect.midX + w * 0.16, y: vy - h * 0.08))
            }
            stroke(&ctx, vein, lw * 0.7)
        case .journal:
            var medal = Path()
            medal.addEllipse(in: CGRect(x: rect.midX - w * 0.24, y: rect.minY, width: w * 0.48, height: w * 0.48))
            stroke(&ctx, medal, lw)
            var star = Path()
            let c = CGPoint(x: rect.midX, y: rect.minY + w * 0.24)
            for i in 0..<5 {
                let ang = CGFloat(i) * 2 * .pi / 5 - .pi / 2
                let pt = CGPoint(x: c.x + cos(ang) * w * 0.11, y: c.y + sin(ang) * w * 0.11)
                if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
                let ang2 = ang + .pi / 5
                star.addLine(to: CGPoint(x: c.x + cos(ang2) * w * 0.045, y: c.y + sin(ang2) * w * 0.045))
            }
            star.closeSubpath()
            ctx.fill(star, with: .color(color))
            var ribbons = Path()
            ribbons.move(to: CGPoint(x: rect.midX - w * 0.13, y: rect.minY + w * 0.44))
            ribbons.addLine(to: CGPoint(x: rect.midX - w * 0.20, y: rect.maxY))
            ribbons.move(to: CGPoint(x: rect.midX + w * 0.13, y: rect.minY + w * 0.44))
            ribbons.addLine(to: CGPoint(x: rect.midX + w * 0.20, y: rect.maxY))
            stroke(&ctx, ribbons, lw)
        case .check:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY + h * 0.06))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.34, y: rect.maxY - h * 0.12))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.10))
            stroke(&ctx, p, lw * 1.2)
        case .lock:
            let bodyR = CGRect(x: rect.minX + w * 0.14, y: rect.midY - h * 0.04, width: w * 0.72, height: h * 0.56)
            stroke(&ctx, Path(roundedRect: bodyR, cornerRadius: w * 0.1), lw)
            var shackle = Path()
            shackle.addArc(center: CGPoint(x: rect.midX, y: rect.midY - h * 0.04), radius: w * 0.22, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
            stroke(&ctx, shackle, lw)
            ctx.fill(Path(ellipseIn: CGRect(x: rect.midX - w * 0.05, y: rect.midY + h * 0.14, width: w * 0.1, height: w * 0.1)), with: .color(color))
        case .chevronRight:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.3, y: rect.minY + h * 0.12))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.26, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.3, y: rect.maxY - h * 0.12))
            stroke(&ctx, p, lw * 1.1)
        case .chevronDown:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.12, y: rect.minY + h * 0.3))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.26))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY + h * 0.3))
            stroke(&ctx, p, lw * 1.1)
        case .star:
            var star = Path()
            let c = CGPoint(x: rect.midX, y: rect.midY)
            for i in 0..<5 {
                let ang = CGFloat(i) * 2 * .pi / 5 - .pi / 2
                let pt = CGPoint(x: c.x + cos(ang) * w * 0.48, y: c.y + sin(ang) * w * 0.48)
                if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
                let ang2 = ang + .pi / 5
                star.addLine(to: CGPoint(x: c.x + cos(ang2) * w * 0.20, y: c.y + sin(ang2) * w * 0.20))
            }
            star.closeSubpath()
            ctx.fill(star, with: .color(color))
        case .close:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.14, y: rect.minY + h * 0.14))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.14, y: rect.maxY - h * 0.14))
            p.move(to: CGPoint(x: rect.maxX - w * 0.14, y: rect.minY + h * 0.14))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.14, y: rect.maxY - h * 0.14))
            stroke(&ctx, p, lw * 1.1)
        case .plus:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.1))
            p.move(to: CGPoint(x: rect.minX + w * 0.1, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.1, y: rect.midY))
            stroke(&ctx, p, lw * 1.1)
        case .leafSprig:
            var stem = Path()
            stem.move(to: CGPoint(x: rect.minX + w * 0.2, y: rect.maxY))
            stem.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.minY + h * 0.1), control: CGPoint(x: rect.midX - w * 0.05, y: rect.midY - h * 0.05))
            stroke(&ctx, stem, lw * 0.9)
            for t in [0.3, 0.55, 0.8] {
                let bx = rect.minX + w * 0.2 + (rect.width * 0.6) * CGFloat(t)
                let by = rect.maxY - rect.height * CGFloat(t) * 0.9
                var leaf = Path()
                leaf.addEllipse(in: CGRect(x: bx - w * 0.14, y: by - h * 0.07, width: w * 0.17, height: h * 0.1))
                ctx.fill(leaf, with: .color(color))
            }
        case .drop:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.18, y: rect.maxY - h * 0.3), control: CGPoint(x: rect.maxX - w * 0.08, y: rect.midY))
            p.addArc(center: CGPoint(x: rect.midX, y: rect.maxY - h * 0.3), radius: w * 0.32, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: false)
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX + w * 0.08, y: rect.midY))
            stroke(&ctx, p, lw)
        case .wind:
            for (t, len) in [(0.24, 0.7), (0.5, 0.85), (0.76, 0.6)] {
                var p = Path()
                let y = rect.minY + h * CGFloat(t)
                p.move(to: CGPoint(x: rect.minX, y: y))
                p.addLine(to: CGPoint(x: rect.minX + w * CGFloat(len), y: y))
                p.addArc(center: CGPoint(x: rect.minX + w * CGFloat(len), y: y - h * 0.07), radius: h * 0.07, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 300), clockwise: true)
                stroke(&ctx, p, lw * 0.9)
            }
        case .sponge:
            let body = Path(roundedRect: CGRect(x: rect.minX + w * 0.1, y: rect.midY - h * 0.2, width: w * 0.8, height: h * 0.44), cornerRadius: w * 0.1)
            stroke(&ctx, body, lw)
            for (px, py) in [(0.3, 0.5), (0.52, 0.42), (0.68, 0.56)] {
                ctx.fill(Path(ellipseIn: CGRect(x: rect.minX + w * CGFloat(px), y: rect.minY + h * CGFloat(py), width: w * 0.07, height: w * 0.07)), with: .color(color))
            }
            for t in [0.3, 0.55, 0.8] {
                var wave = Path()
                wave.move(to: CGPoint(x: rect.minX + w * CGFloat(t), y: rect.minY + h * 0.06))
                wave.addLine(to: CGPoint(x: rect.minX + w * CGFloat(t) + w * 0.06, y: rect.minY + h * 0.16))
                stroke(&ctx, wave, lw * 0.7)
            }
        case .scissors:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.16, y: rect.minY + h * 0.1))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.maxY - h * 0.24))
            p.move(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.minY + h * 0.1))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.16, y: rect.maxY - h * 0.24))
            stroke(&ctx, p, lw)
            for cx in [rect.minX + w * 0.14, rect.maxX - w * 0.42] {
                var ring = Path()
                ring.addEllipse(in: CGRect(x: cx, y: rect.maxY - h * 0.26, width: w * 0.26, height: h * 0.26))
                stroke(&ctx, ring, lw * 0.9)
            }
        case .sunSpot:
            var sun = Path()
            sun.addEllipse(in: CGRect(x: rect.midX - w * 0.2, y: rect.midY - h * 0.2, width: w * 0.4, height: h * 0.4))
            stroke(&ctx, sun, lw)
            for i in 0..<8 {
                let a = CGFloat(i) / 8 * 2 * .pi
                var ray = Path()
                ray.move(to: CGPoint(x: rect.midX + cos(a) * w * 0.3, y: rect.midY + sin(a) * h * 0.3))
                ray.addLine(to: CGPoint(x: rect.midX + cos(a) * w * 0.44, y: rect.midY + sin(a) * h * 0.44))
                stroke(&ctx, ray, lw * 0.8)
            }
        case .bug:
            var body = Path()
            body.addEllipse(in: CGRect(x: rect.midX - w * 0.22, y: rect.midY - h * 0.16, width: w * 0.44, height: h * 0.38))
            stroke(&ctx, body, lw)
            var line = Path()
            line.move(to: CGPoint(x: rect.midX, y: rect.midY - h * 0.16))
            line.addLine(to: CGPoint(x: rect.midX, y: rect.midY + h * 0.22))
            stroke(&ctx, line, lw * 0.7)
            for side in [-1.0, 1.0] {
                for dy in [-0.06, 0.06, 0.18] {
                    var leg = Path()
                    leg.move(to: CGPoint(x: rect.midX + CGFloat(side) * w * 0.2, y: rect.midY + h * CGFloat(dy)))
                    leg.addLine(to: CGPoint(x: rect.midX + CGFloat(side) * w * 0.36, y: rect.midY + h * CGFloat(dy) + h * 0.1))
                    stroke(&ctx, leg, lw * 0.7)
                }
                var feeler = Path()
                feeler.move(to: CGPoint(x: rect.midX + CGFloat(side) * w * 0.08, y: rect.midY - h * 0.15))
                feeler.addLine(to: CGPoint(x: rect.midX + CGFloat(side) * w * 0.2, y: rect.midY - h * 0.34))
                stroke(&ctx, feeler, lw * 0.7)
            }
        case .clock:
            stroke(&ctx, Path(ellipseIn: rect), lw)
            var hands = Path()
            hands.move(to: CGPoint(x: rect.midX, y: rect.midY))
            hands.addLine(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.22))
            hands.move(to: CGPoint(x: rect.midX, y: rect.midY))
            hands.addLine(to: CGPoint(x: rect.midX + w * 0.22, y: rect.midY + h * 0.1))
            stroke(&ctx, hands, lw)
        case .ribbon:
            var band = Path()
            band.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY + h * 0.2, width: w, height: h * 0.32), cornerSize: CGSize(width: w * 0.06, height: w * 0.06))
            stroke(&ctx, band, lw)
            var tails = Path()
            tails.move(to: CGPoint(x: rect.midX - w * 0.16, y: rect.minY + h * 0.52))
            tails.addLine(to: CGPoint(x: rect.midX - w * 0.24, y: rect.maxY))
            tails.move(to: CGPoint(x: rect.midX + w * 0.16, y: rect.minY + h * 0.52))
            tails.addLine(to: CGPoint(x: rect.midX + w * 0.24, y: rect.maxY))
            stroke(&ctx, tails, lw)
        case .book:
            var book = Path()
            book.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.16))
            book.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.10), control: CGPoint(x: rect.minX + w * 0.22, y: rect.minY))
            book.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - h * 0.12))
            book.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.minX + w * 0.24, y: rect.maxY - h * 0.06))
            book.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - h * 0.12), control: CGPoint(x: rect.maxX - w * 0.24, y: rect.maxY - h * 0.06))
            book.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.10))
            book.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.16), control: CGPoint(x: rect.maxX - w * 0.22, y: rect.minY))
            book.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.16))
            book.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            stroke(&ctx, book, lw)
        case .sparkle:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX + w * 0.1, y: rect.midY - h * 0.1))
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX + w * 0.1, y: rect.midY + h * 0.1))
            p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.midX - w * 0.1, y: rect.midY + h * 0.1))
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.midX - w * 0.1, y: rect.midY - h * 0.1))
            ctx.fill(p, with: .color(color))
        case .seal:
            var ring = Path()
            ring.addEllipse(in: rect.insetBy(dx: w * 0.08, dy: h * 0.08))
            stroke(&ctx, ring, lw)
            var inner = Path()
            inner.addEllipse(in: rect.insetBy(dx: w * 0.22, dy: h * 0.22))
            stroke(&ctx, inner, lw * 0.7)
            var wax = Path()
            wax.move(to: CGPoint(x: rect.midX - w * 0.12, y: rect.midY + h * 0.1))
            wax.addLine(to: CGPoint(x: rect.midX, y: rect.midY - h * 0.14))
            wax.addLine(to: CGPoint(x: rect.midX + w * 0.12, y: rect.midY + h * 0.1))
            stroke(&ctx, wax, lw * 0.9)
        }
    }
}
