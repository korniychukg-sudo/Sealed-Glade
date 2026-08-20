import SwiftUI

struct GladeOpeningScreen: View {
    @State private var sweep = false
    @State private var dropPhase: CGFloat = 0

    var body: some View {
        ZStack {
            MistBackdrop(tone: GladeTheme.cream)
            VStack(spacing: 24) {
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let jarRect = CGRect(x: rect.midX - rect.width * 0.20, y: rect.minY + 14, width: rect.width * 0.40, height: rect.height * 0.76)
                    var jar = Path()
                    let w = jarRect.width
                    let h = jarRect.height
                    jar.move(to: CGPoint(x: jarRect.minX + w * 0.28, y: jarRect.minY + h * 0.06))
                    jar.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.03, y: jarRect.midY), control: CGPoint(x: jarRect.minX + w * 0.02, y: jarRect.minY + h * 0.24))
                    jar.addQuadCurve(to: CGPoint(x: jarRect.minX + w * 0.18, y: jarRect.maxY - h * 0.03), control: CGPoint(x: jarRect.minX + w * 0.04, y: jarRect.maxY - h * 0.1))
                    jar.addLine(to: CGPoint(x: jarRect.maxX - w * 0.18, y: jarRect.maxY - h * 0.03))
                    jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.03, y: jarRect.midY), control: CGPoint(x: jarRect.maxX - w * 0.04, y: jarRect.maxY - h * 0.1))
                    jar.addQuadCurve(to: CGPoint(x: jarRect.maxX - w * 0.28, y: jarRect.minY + h * 0.06), control: CGPoint(x: jarRect.maxX - w * 0.02, y: jarRect.minY + h * 0.24))
                    jar.closeSubpath()
                    ctx.fill(jar, with: .color(GladeTheme.glass.opacity(0.45)))
                    var jarInner = ctx
                    jarInner.clip(to: jar)
                    jarInner.fill(Path(CGRect(x: jarRect.minX, y: jarRect.maxY - h * 0.26, width: w, height: h * 0.26)), with: .color(GladeTheme.soil))
                    jarInner.fill(Path(CGRect(x: jarRect.minX, y: jarRect.maxY - h * 0.09, width: w, height: h * 0.09)), with: .color(GladeTheme.pebble.opacity(0.85)))
                    for i in 0..<3 {
                        let bx = jarRect.midX + CGFloat(i - 1) * w * 0.2
                        let by = jarRect.maxY - h * 0.26
                        var stem = Path()
                        stem.move(to: CGPoint(x: bx, y: by))
                        stem.addQuadCurve(to: CGPoint(x: bx + CGFloat(i - 1) * 10, y: by - h * (0.20 + CGFloat(i % 2) * 0.08)), control: CGPoint(x: bx + 6, y: by - h * 0.12))
                        ctx.stroke(stem, with: .color(GladeTheme.mossDeep), lineWidth: 2.4)
                        let leafR = w * 0.09
                        ctx.fill(Path(ellipseIn: CGRect(x: bx + CGFloat(i - 1) * 10 - leafR / 2, y: by - h * (0.24 + CGFloat(i % 2) * 0.08), width: leafR, height: leafR * 1.5)), with: .color(i % 2 == 0 ? GladeTheme.moss : GladeTheme.fern))
                    }
                    for i in 0..<4 {
                        let t = (dropPhase + CGFloat(i) * 0.25).truncatingRemainder(dividingBy: 1)
                        let side: CGFloat = i % 2 == 0 ? jarRect.minX + w * 0.10 : jarRect.maxX - w * 0.12
                        let dy = jarRect.minY + h * 0.18 + t * h * 0.5
                        ctx.fill(Path(ellipseIn: CGRect(x: side, y: dy, width: 5, height: 8)), with: .color(Color.white.opacity(Double(0.5 * (1 - t * 0.5)))))
                    }
                    let lid = CGRect(x: jarRect.minX + w * 0.24, y: jarRect.minY - 4, width: w * 0.52, height: 16)
                    ctx.fill(Path(roundedRect: lid, cornerRadius: 4), with: .color(GladeTheme.amber))
                    ctx.stroke(Path(roundedRect: lid, cornerRadius: 4), with: .color(GladeTheme.ink.opacity(0.5)), lineWidth: 1.2)
                }
                .frame(width: 230, height: 190)
                Text("Sealed Glade")
                    .font(GladeTheme.title(24))
                    .foregroundColor(GladeTheme.ink)
                ZStack {
                    Capsule().fill(GladeTheme.ink.opacity(0.10)).frame(width: 132, height: 6)
                    Capsule()
                        .fill(GladeTheme.moss)
                        .frame(width: 46, height: 6)
                        .offset(x: sweep ? 43 : -43)
                        .animation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: sweep)
                }
            }
        }
        .onAppear {
            sweep = true
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                dropPhase = 1
            }
        }
    }
}
