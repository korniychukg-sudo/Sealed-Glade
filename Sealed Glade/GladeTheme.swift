import SwiftUI

enum GladeTheme {
    static let cream = Color(red: 0.949, green: 0.949, blue: 0.910)
    static let paper = Color(red: 0.973, green: 0.969, blue: 0.937)
    static let mist = Color(red: 0.898, green: 0.918, blue: 0.882)
    static let moss = Color(red: 0.353, green: 0.478, blue: 0.310)
    static let mossDeep = Color(red: 0.243, green: 0.361, blue: 0.216)
    static let fern = Color(red: 0.478, green: 0.596, blue: 0.373)
    static let fernLight = Color(red: 0.639, green: 0.729, blue: 0.510)
    static let soil = Color(red: 0.353, green: 0.271, blue: 0.196)
    static let soilLight = Color(red: 0.494, green: 0.396, blue: 0.290)
    static let pebble = Color(red: 0.671, green: 0.663, blue: 0.627)
    static let charcoal = Color(red: 0.267, green: 0.267, blue: 0.267)
    static let glass = Color(red: 0.831, green: 0.878, blue: 0.867)
    static let glassEdge = Color(red: 0.573, green: 0.663, blue: 0.647)
    static let water = Color(red: 0.502, green: 0.663, blue: 0.690)
    static let ink = Color(red: 0.161, green: 0.180, blue: 0.137)
    static let inkSoft = Color(red: 0.318, green: 0.345, blue: 0.282)
    static let inkFaint = Color(red: 0.494, green: 0.522, blue: 0.451)
    static let amber = Color(red: 0.851, green: 0.667, blue: 0.302)
    static let amberDeep = Color(red: 0.702, green: 0.518, blue: 0.196)
    static let clay = Color(red: 0.718, green: 0.475, blue: 0.337)
    static let rust = Color(red: 0.639, green: 0.333, blue: 0.243)
    static let skyDay = Color(red: 0.780, green: 0.851, blue: 0.867)
    static let skyNight = Color(red: 0.180, green: 0.220, blue: 0.322)
    static let cardShadow = Color.black.opacity(0.10)

    static func title(_ size: CGFloat) -> Font { Font.system(size: size, weight: .bold, design: .rounded) }
    static func heading(_ size: CGFloat) -> Font { Font.system(size: size, weight: .semibold, design: .rounded) }
    static func body(_ size: CGFloat) -> Font { Font.system(size: size, weight: .regular, design: .rounded) }
    static func serif(_ size: CGFloat) -> Font { Font.custom("Georgia", size: size) }
    static func serifBold(_ size: CGFloat) -> Font { Font.custom("Georgia-Bold", size: size) }
    static func mono(_ size: CGFloat) -> Font { Font.system(size: size, weight: .medium, design: .monospaced) }
}

struct GladeSeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed &* 6364136223846793005 &+ 1442695040888963407 }
    mutating func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
    mutating func nextInt(_ upper: Int) -> Int {
        guard upper > 0 else { return 0 }
        return min(upper - 1, Int(next() * CGFloat(upper)))
    }
}

extension Double {
    func gladeClamped(_ lo: Double, _ hi: Double) -> Double { Swift.max(lo, Swift.min(hi, self)) }
}

extension CGFloat {
    func gladeClamped(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { Swift.max(lo, Swift.min(hi, self)) }
}

struct MistBackdrop: View {
    var tone: Color = GladeTheme.cream
    var body: some View {
        ZStack {
            tone
            GeometryReader { geo in
                Canvas { ctx, size in
                    var rng = GladeSeededRandom(seed: 31)
                    for _ in 0..<12 {
                        let x = rng.next() * size.width
                        let y = rng.next() * size.height
                        let r = 30 + rng.next() * 90
                        ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * 0.6, width: r * 2, height: r * 1.2)), with: .color(GladeTheme.fernLight.opacity(0.03 + Double(rng.next()) * 0.04)))
                    }
                    for _ in 0..<240 {
                        let x = rng.next() * size.width
                        let y = rng.next() * size.height
                        let r = 0.6 + rng.next() * 1.5
                        ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)), with: .color(GladeTheme.ink.opacity(0.015 + Double(rng.next()) * 0.03)))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct GladeHaptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func thump() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
