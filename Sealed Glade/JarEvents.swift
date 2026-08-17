import SwiftUI

struct BalanceDial: View {
    let balance: Double
    let weakest: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                GladeProgressRing(progress: balance / 100, size: 66, lineWidth: 8, color: dialColor)
                VStack(spacing: 0) {
                    Text("\(Int(balance))")
                        .font(GladeTheme.title(20))
                        .foregroundColor(GladeTheme.ink)
                    Text("balance")
                        .font(GladeTheme.body(8))
                        .foregroundColor(GladeTheme.inkFaint)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(headline)
                    .font(GladeTheme.heading(15))
                    .foregroundColor(GladeTheme.ink)
                Text("Weakest link: \(weakest).")
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .gladeCard()
    }

    private var dialColor: Color {
        if balance >= 75 { return GladeTheme.fern }
        if balance >= 50 { return GladeTheme.amber }
        return GladeTheme.rust
    }

    private var headline: String {
        if balance >= 85 { return "The glade is thriving" }
        if balance >= 70 { return "Holding its own, and then some" }
        if balance >= 50 { return "Steady, with room to improve" }
        if balance >= 30 { return "The little world is struggling" }
        return "The glade needs a keeper's hand"
    }
}

struct JarGauges: View {
    let jar: JarState

    var body: some View {
        VStack(spacing: 10) {
            gauge(icon: .drop, label: "Water", value: jar.water, ideal: 0.45...0.75, note: waterNote)
            gauge(icon: .wind, label: "Air", value: jar.air, ideal: 0.55...1.0, note: jar.air < 0.5 ? "growing stale" : "fresh enough")
            gauge(icon: .sponge, label: "Mould", value: jar.mold, ideal: 0...0.25, inverted: true, note: jar.mold > 0.4 ? "spreading" : "in check")
            gauge(icon: .sunSpot, label: "Algae", value: jar.algae, ideal: 0...0.3, inverted: true, note: jar.algae > 0.5 ? "fogging the glass" : "faint")
        }
        .gladeCard(padding: 14)
    }

    private var waterNote: String {
        if jar.water > 0.8 { return "swampy" }
        if jar.water > 0.75 { return "on the wet side" }
        if jar.water < 0.35 { return "running dry" }
        return "about right"
    }

    private func gauge(icon: GIconKind, label: String, value: Double, ideal: ClosedRange<Double>, inverted: Bool = false, note: String) -> some View {
        HStack(spacing: 10) {
            GIcon(kind: icon, size: 17, color: GladeTheme.inkSoft)
                .frame(width: 22)
            Text(label)
                .font(GladeTheme.body(13))
                .foregroundColor(GladeTheme.inkSoft)
                .frame(width: 48, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(GladeTheme.ink.opacity(0.08))
                    Capsule()
                        .fill(GladeTheme.fern.opacity(0.22))
                        .frame(width: geo.size.width * CGFloat(ideal.upperBound - ideal.lowerBound))
                        .offset(x: geo.size.width * CGFloat(ideal.lowerBound))
                    Capsule()
                        .fill(barColor(value: value, ideal: ideal, inverted: inverted))
                        .frame(width: max(5, geo.size.width * CGFloat(value)))
                }
            }
            .frame(height: 8)
            Text(note)
                .font(GladeTheme.body(10))
                .foregroundColor(GladeTheme.inkFaint)
                .frame(width: 76, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func barColor(value: Double, ideal: ClosedRange<Double>, inverted: Bool) -> Color {
        if ideal.contains(value) { return GladeTheme.fern }
        if inverted {
            return value > ideal.upperBound + 0.25 ? GladeTheme.rust : GladeTheme.amber
        }
        return abs(value - (ideal.lowerBound + ideal.upperBound) / 2) > 0.35 ? GladeTheme.rust : GladeTheme.amber
    }
}

struct EventFeed: View {
    let events: [JarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GladeSectionHeader(title: "The Jar Journal", subtitle: "What the glade has been up to")
            if events.isEmpty {
                Text("Nothing written yet — sealed worlds keep their diaries slowly.")
                    .font(GladeTheme.body(13))
                    .foregroundColor(GladeTheme.inkFaint)
                    .gladeCard(padding: 13)
            }
            ForEach(events.prefix(14)) { event in
                HStack(alignment: .top, spacing: 10) {
                    GIcon(kind: iconFor(event.kind), size: 15, color: colorFor(event.kind))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Day \(event.day)")
                            .font(GladeTheme.mono(10))
                            .foregroundColor(GladeTheme.inkFaint)
                        Text(event.text)
                            .font(GladeTheme.serif(14))
                            .foregroundColor(GladeTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .gladeCard(padding: 12)
            }
        }
    }

    private func iconFor(_ kind: String) -> GIconKind {
        switch kind {
        case "milestone": return .seal
        case "warning": return .sponge
        case "good": return .check
        case "opened": return .wind
        case "growth": return .leafSprig
        default: return .sparkle
        }
    }

    private func colorFor(_ kind: String) -> Color {
        switch kind {
        case "milestone": return GladeTheme.amberDeep
        case "warning": return GladeTheme.rust
        case "good", "growth": return GladeTheme.fern
        default: return GladeTheme.inkFaint
        }
    }
}
