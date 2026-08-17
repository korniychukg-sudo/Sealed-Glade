import SwiftUI

struct GladeView: View {
    @EnvironmentObject var store: GladeStore
    @State private var phaseStart = Date()
    @State private var showOpenSheet = false
    @State private var confirmAction: TendAction?

    enum TendAction: Identifiable {
        case vent, mist, wipe, prune
        var id: Int {
            switch self {
            case .vent: return 0
            case .mist: return 1
            case .wipe: return 2
            case .prune: return 3
            }
        }
        var title: String {
            switch self {
            case .vent: return "Lift the lid to vent?"
            case .mist: return "Open up and mist?"
            case .wipe: return "Open up and wipe the glass?"
            case .prune: return "Open up and prune?"
            }
        }
        var message: String {
            switch self {
            case .vent: return "Fresh air rushes in and a little moisture escapes. The sealed-days count starts over."
            case .mist: return "A few sprays of water for a thirsty world. The sealed-days count starts over."
            case .wipe: return "The algae comes off and the view returns. The sealed-days count starts over."
            case .prune: return "Dead growth comes out and ailing plants get a fresh start. The sealed-days count starts over."
            }
        }
    }

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    jarScene
                    BalanceDial(balance: store.jar.balance, weakest: store.jar.weakestLink)
                    JarGauges(jar: store.jar)
                    spotPicker
                    tendRow
                    EventFeed(events: store.jar.eventLog)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
            if let report = store.catchUpReport {
                VStack {
                    HStack(spacing: 10) {
                        GIcon(kind: .clock, size: 18, color: GladeTheme.fernLight)
                        Text(report)
                            .font(GladeTheme.heading(13))
                            .foregroundColor(GladeTheme.mist)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(GladeTheme.mossDeep)
                            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                        withAnimation { store.catchUpReport = nil }
                    }
                }
                .zIndex(3)
            }
            if let text = store.celebration {
                GladeCelebrationBanner(text: text) {
                    withAnimation { store.celebration = nil }
                }
                .zIndex(4)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showOpenSheet) {
            OpenJarSheet()
                .environmentObject(store)
        }
        .alert(item: $confirmAction) { action in
            Alert(
                title: Text(action.title),
                message: Text(action.message),
                primaryButton: .default(Text("Do it")) {
                    switch action {
                    case .vent: store.tend { JarSim.vent(&$0) }
                    case .mist: store.tend { JarSim.mist(&$0) }
                    case .wipe: store.tend { JarSim.wipeGlass(&$0) }
                    case .prune: store.tend { JarSim.pruneDead(&$0) }
                    }
                },
                secondaryButton: .cancel())
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.jar.name)
                    .font(GladeTheme.title(24))
                    .foregroundColor(GladeTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Day \(store.jar.dayCount) · sealed \(store.jar.sealedDays) \(store.jar.sealedDays == 1 ? "day" : "days") · best \(store.jar.bestSealedDays)")
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.inkFaint)
            }
            Spacer()
            ZStack {
                GladeProgressRing(progress: store.rankProgress, size: 44, lineWidth: 5, color: GladeTheme.moss)
                GIcon(kind: .leafSprig, size: 17, color: GladeTheme.mossDeep)
            }
        }
    }

    private var jarScene: some View {
        TimelineView(.animation(minimumInterval: store.reduceMotion ? 0.5 : 1.0 / 24.0)) { timeline in
            let phase = timeline.date.timeIntervalSince(phaseStart)
            Canvas { ctx, size in
                let daylight = store.daylight
                let sillY = size.height * 0.9
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                fmt.locale = Locale(identifier: "en_US_POSIX")
                let daySeed = UInt64(abs(fmt.string(from: Date()).hashValue % 100000))
                var weatherRng = GladeSeededRandom(seed: daySeed)
                let rainy = weatherRng.next() < 0.3
                let sky = Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 20)
                let dayTop = rainy ? Color(red: 0.58, green: 0.64, blue: 0.66) : GladeTheme.skyDay
                let nightTop = GladeTheme.skyNight
                let top = blendColor(nightTop, dayTop, daylight)
                ctx.fill(sky, with: .linearGradient(Gradient(colors: [top, GladeTheme.cream.opacity(0.9)]), startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
                if daylight < 0.35 && !rainy {
                    var rng = GladeSeededRandom(seed: 9)
                    for _ in 0..<24 {
                        let x = rng.next() * size.width
                        let y = rng.next() * size.height * 0.4
                        let tw = 0.5 + 0.5 * sin(phase * (1 + Double(rng.next())) + Double(rng.next()) * 6)
                        ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(Color.white.opacity((0.25 + Double(rng.next()) * 0.4) * (1 - daylight) * tw)))
                    }
                    let moonC = CGPoint(x: size.width * 0.82, y: size.height * 0.16)
                    let moonR: CGFloat = size.width * 0.045
                    ctx.fill(Path(ellipseIn: CGRect(x: moonC.x - moonR * 2.2, y: moonC.y - moonR * 2.2, width: moonR * 4.4, height: moonR * 4.4)), with: .radialGradient(Gradient(colors: [Color(red: 0.95, green: 0.94, blue: 0.82).opacity(0.25 * (1 - daylight)), .clear]), center: moonC, startRadius: 0, endRadius: moonR * 2.2))
                    ctx.fill(Path(ellipseIn: CGRect(x: moonC.x - moonR, y: moonC.y - moonR, width: moonR * 2, height: moonR * 2)), with: .color(Color(red: 0.95, green: 0.94, blue: 0.84).opacity(0.9 * (1 - daylight))))
                    ctx.fill(Path(ellipseIn: CGRect(x: moonC.x - moonR * 1.45, y: moonC.y - moonR * 0.75, width: moonR * 1.9, height: moonR * 1.9)), with: .color(top.opacity(0.92 * (1 - daylight))))
                }
                if rainy {
                    var rainRng = GladeSeededRandom(seed: daySeed &+ 4)
                    for i in 0..<22 {
                        let x0 = rainRng.next() * size.width
                        let speed = 0.05 + Double(rainRng.next()) * 0.05
                        let t = CGFloat((phase * speed + Double(rainRng.next())).truncatingRemainder(dividingBy: 1))
                        let y = t * sillY
                        var drop = Path()
                        drop.move(to: CGPoint(x: x0 + CGFloat(i % 3), y: y - 14))
                        drop.addLine(to: CGPoint(x: x0, y: y))
                        ctx.stroke(drop, with: .color(Color.white.opacity(0.30)), lineWidth: 1.4)
                        ctx.fill(Path(ellipseIn: CGRect(x: x0 - 1.6, y: y - 2, width: 3.2, height: 4.4)), with: .color(Color.white.opacity(0.38)))
                    }
                    for k in 0..<3 {
                        var trickle = Path()
                        let tx = size.width * (0.2 + CGFloat(k) * 0.3) + CGFloat(sin(phase * 0.1 + Double(k))) * 8
                        trickle.move(to: CGPoint(x: tx, y: 0))
                        trickle.addQuadCurve(to: CGPoint(x: tx + 6, y: sillY * 0.7), control: CGPoint(x: tx - 8, y: sillY * 0.35))
                        ctx.stroke(trickle, with: .color(Color.white.opacity(0.13)), lineWidth: 2)
                    }
                }
                let frameW = size.width * 0.045
                let mullionW = size.width * 0.018
                let frameColor = GladeTheme.soil
                let frameLight = GladeTheme.soilLight
                var mullions = Path()
                mullions.addRect(CGRect(x: size.width * 0.47, y: 0, width: mullionW, height: sillY))
                mullions.addRect(CGRect(x: 0, y: sillY * 0.44, width: size.width, height: mullionW))
                ctx.fill(mullions, with: .color(frameColor.opacity(0.9)))
                var mullionHi = Path()
                mullionHi.addRect(CGRect(x: size.width * 0.47 + mullionW - 2.5, y: 0, width: 2.5, height: sillY))
                mullionHi.addRect(CGRect(x: 0, y: sillY * 0.44 + mullionW - 2.5, width: size.width, height: 2.5))
                ctx.fill(mullionHi, with: .color(frameLight.opacity(0.5)))
                var frame = Path()
                frame.addRect(CGRect(x: 0, y: 0, width: frameW, height: sillY))
                frame.addRect(CGRect(x: size.width - frameW, y: 0, width: frameW, height: sillY))
                frame.addRect(CGRect(x: 0, y: 0, width: size.width, height: frameW * 0.7))
                ctx.fill(frame, with: .color(frameColor))
                ctx.fill(Path(CGRect(x: frameW - 3, y: 0, width: 3, height: sillY)), with: .color(frameLight.opacity(0.5)))
                ctx.fill(Path(CGRect(x: size.width - frameW, y: 0, width: 3, height: sillY)), with: .color(GladeTheme.ink.opacity(0.25)))
                let curtainW = size.width * 0.13
                var curtain = Path()
                curtain.move(to: CGPoint(x: 0, y: 0))
                curtain.addLine(to: CGPoint(x: curtainW, y: 0))
                curtain.addQuadCurve(to: CGPoint(x: curtainW * 0.55, y: sillY * 0.55), control: CGPoint(x: curtainW * 1.1, y: sillY * 0.3))
                curtain.addQuadCurve(to: CGPoint(x: curtainW * 0.8, y: sillY), control: CGPoint(x: curtainW * 0.3, y: sillY * 0.82))
                curtain.addLine(to: CGPoint(x: 0, y: sillY))
                curtain.closeSubpath()
                ctx.fill(curtain, with: .linearGradient(Gradient(colors: [Color(red: 0.91, green: 0.88, blue: 0.79), Color(red: 0.80, green: 0.76, blue: 0.66)]), startPoint: .zero, endPoint: CGPoint(x: curtainW, y: 0)))
                for f in 0..<3 {
                    var fold = Path()
                    let fx = curtainW * (0.25 + CGFloat(f) * 0.24)
                    fold.move(to: CGPoint(x: fx, y: 0))
                    fold.addQuadCurve(to: CGPoint(x: fx * 0.75, y: sillY * 0.72), control: CGPoint(x: fx * 1.12, y: sillY * 0.4))
                    ctx.stroke(fold, with: .color(GladeTheme.ink.opacity(0.10)), lineWidth: 3)
                }
                ctx.fill(Path(CGRect(x: 0, y: sillY, width: size.width, height: size.height - sillY)), with: .color(GladeTheme.soilLight))
                ctx.fill(Path(CGRect(x: 0, y: sillY, width: size.width, height: 4)), with: .color(GladeTheme.soil.opacity(0.6)))
                let jarRect = CGRect(x: size.width * 0.18, y: size.height * 0.06, width: size.width * 0.64, height: sillY - size.height * 0.08)
                var inner = ctx
                JarArtist.drawJar(&inner, rect: jarRect, jar: store.jar, phase: phase, daylight: daylight)
                if daylight < 0.3 && !rainy {
                    var flyRng = GladeSeededRandom(seed: 33)
                    for f in 0..<5 {
                        let ox = 0.12 + flyRng.next() * 0.76
                        let oy = 0.2 + flyRng.next() * 0.55
                        let sp = 0.3 + Double(flyRng.next()) * 0.4
                        let fx = size.width * ox + CGFloat(sin(phase * sp + Double(f) * 1.7)) * size.width * 0.08
                        let fy = size.height * oy + CGFloat(sin(phase * sp * 1.6 + Double(f) * 2.3)) * size.height * 0.06
                        let pulse = 0.4 + 0.6 * abs(sin(phase * (0.8 + sp) + Double(f)))
                        let glowColor = Color(red: 0.85, green: 0.95, blue: 0.45)
                        ctx.fill(Path(ellipseIn: CGRect(x: fx - 7, y: fy - 7, width: 14, height: 14)), with: .radialGradient(Gradient(colors: [glowColor.opacity(0.35 * pulse * (1 - daylight)), .clear]), center: CGPoint(x: fx, y: fy), startRadius: 0, endRadius: 8))
                        ctx.fill(Path(ellipseIn: CGRect(x: fx - 1.6, y: fy - 1.6, width: 3.2, height: 3.2)), with: .color(glowColor.opacity(0.9 * pulse * (1 - daylight))))
                    }
                }
            }
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: GladeTheme.cardShadow, radius: 8, x: 0, y: 4)
        }
    }

    private func blendColor(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let ca = UIColor(a)
        let cb = UIColor(b)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        ca.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        cb.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let tt = CGFloat(t.gladeClamped(0, 1))
        return Color(red: ar + (br - ar) * tt, green: ag + (bg - ag) * tt, blue: ab + (bb - ab) * tt)
    }

    private var spotPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where the jar stands")
                .font(GladeTheme.heading(14))
                .foregroundColor(GladeTheme.ink)
            Picker("", selection: Binding(
                get: { store.jar.spot },
                set: { newSpot in
                    var j = store.jar
                    j.spot = newSpot
                    store.jar = j
                    store.addXP(2)
                    GladeHaptics.tap()
                })) {
                Text("Shade").tag(JarSpot.shade)
                Text("Bright").tag(JarSpot.bright)
                Text("Sun").tag(JarSpot.sun)
            }
            .pickerStyle(SegmentedPickerStyle())
            Text(store.jar.spot.caution)
                .font(GladeTheme.body(12))
                .foregroundColor(GladeTheme.inkFaint)
        }
        .gladeCard(padding: 14)
    }

    private var tendRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                tendButton(icon: .wind, label: "Vent") { confirmAction = .vent }
                tendButton(icon: .drop, label: "Mist") { confirmAction = .mist }
                tendButton(icon: .sponge, label: "Wipe") { confirmAction = .wipe }
                tendButton(icon: .scissors, label: "Prune") { confirmAction = .prune }
            }
            Button {
                showOpenSheet = true
            } label: {
                HStack(spacing: 8) {
                    GIcon(kind: .plus, size: 15, color: GladeTheme.mossDeep)
                    Text("Open the jar — plant and stock")
                }
            }
            .buttonStyle(GladeSoftButton())
            Text("Every opening resets the sealed-days count. The bravest keepers barely touch the lid.")
                .font(GladeTheme.body(11))
                .foregroundColor(GladeTheme.inkFaint)
                .multilineTextAlignment(.center)
        }
    }

    private func tendButton(icon: GIconKind, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                GIcon(kind: icon, size: 21, color: GladeTheme.mossDeep)
                Text(label)
                    .font(GladeTheme.body(11))
                    .foregroundColor(GladeTheme.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(GladeTheme.paper).shadow(color: GladeTheme.cardShadow, radius: 4, x: 0, y: 2))
        }
    }
}

struct OpenJarSheet: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    @State private var opened = false

    var body: some View {
        ZStack {
            MistBackdrop()
            VStack(spacing: 0) {
                HStack {
                    Text("The Lid Is Off")
                        .font(GladeTheme.title(20))
                        .foregroundColor(GladeTheme.ink)
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        GIcon(kind: .close, size: 15, color: GladeTheme.inkSoft)
                            .padding(8)
                            .background(Circle().fill(GladeTheme.ink.opacity(0.07)))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 4)
                Text(opened ? "The seal count has reset. Plant and stock as you like, then close it up." : "Adding tenants means opening the jar — the sealed-days count will reset once you change anything.")
                    .font(GladeTheme.body(13))
                    .foregroundColor(GladeTheme.inkFaint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 8)
                ScrollView {
                    VStack(spacing: 12) {
                        GladeSectionHeader(title: "Plants in the jar (\(store.jar.plants.count)/6)")
                        ForEach(store.jar.plants) { plant in
                            plantRow(plant)
                        }
                        GladeSectionHeader(title: "Add a plant")
                        ForEach(GladeSpecies.plants) { species in
                            addPlantRow(species)
                        }
                        GladeSectionHeader(title: "The crew")
                        ForEach(GladeSpecies.faunas) { species in
                            faunaRow(species)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    private func markOpenedOnce() {
        guard !opened else { return }
        opened = true
        var j = store.jar
        JarSim.markOpened(&j)
        store.jar = j
        store.stats.tendActions += 1
    }

    private func plantRow(_ plant: PlantInstance) -> some View {
        let species = GladeSpecies.plant(plant.speciesID)
        return HStack(spacing: 12) {
            GladeArtImage(name: species.plateArt)
                .frame(width: 52, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(species.name)
                    .font(GladeTheme.heading(14))
                    .foregroundColor(GladeTheme.ink)
                Text("Grown \(Int(plant.growth * 100))% · health \(Int(plant.health * 100))%")
                    .font(GladeTheme.body(11))
                    .foregroundColor(GladeTheme.inkFaint)
            }
            Spacer()
            Button {
                markOpenedOnce()
                var j = store.jar
                j.plants.removeAll { $0.id == plant.id }
                store.jar = j
                GladeHaptics.tap()
            } label: {
                Text("Lift out")
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.rust)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(GladeTheme.rust.opacity(0.12)))
            }
        }
        .gladeCard(padding: 11)
    }

    private func addPlantRow(_ species: PlantSpecies) -> some View {
        let unlocked = store.isPlantUnlocked(species)
        let full = store.jar.plants.count >= 6
        return HStack(spacing: 12) {
            GladeArtImage(name: species.plateArt)
                .frame(width: 52, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .opacity(unlocked ? 1 : 0.4)
            VStack(alignment: .leading, spacing: 2) {
                Text(species.name)
                    .font(GladeTheme.heading(14))
                    .foregroundColor(GladeTheme.ink)
                Text(prefLine(species))
                    .font(GladeTheme.body(11))
                    .foregroundColor(GladeTheme.inkFaint)
            }
            Spacer()
            if !unlocked {
                GladeLockBadge(rankName: GladeStore.ranks[species.unlockRank].name)
            } else if full {
                Text("Full")
                    .font(GladeTheme.body(11))
                    .foregroundColor(GladeTheme.inkFaint)
            } else {
                Button {
                    markOpenedOnce()
                    var j = store.jar
                    var rng = GladeSeededRandom(seed: UInt64(Date().timeIntervalSince1970 * 100))
                    j.plants.append(PlantInstance(speciesID: species.id, x: 0.12 + Double(rng.next()) * 0.76))
                    store.jar = j
                    store.stats.plantsPlanted += 1
                    store.recordReplant(j)
                    store.addXP(8)
                    GladeHaptics.thump()
                } label: {
                    Text("Plant")
                        .font(GladeTheme.body(12))
                        .foregroundColor(GladeTheme.mossDeep)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(GladeTheme.moss.opacity(0.14)))
                }
            }
        }
        .gladeCard(padding: 11)
    }

    private func faunaRow(_ species: FaunaSpecies) -> some View {
        let unlocked = store.isFaunaUnlocked(species)
        let present = store.jar.population(species.id) > 0
        return HStack(spacing: 12) {
            GladeArtImage(name: species.plateArt)
                .frame(width: 52, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .opacity(unlocked ? 1 : 0.4)
            VStack(alignment: .leading, spacing: 2) {
                Text(species.name)
                    .font(GladeTheme.heading(14))
                    .foregroundColor(GladeTheme.ink)
                Text(present ? "\(species.role) · colony at \(Int(store.jar.population(species.id) * 100))%" : species.role)
                    .font(GladeTheme.body(11))
                    .foregroundColor(GladeTheme.inkFaint)
            }
            Spacer()
            if !unlocked {
                GladeLockBadge(rankName: GladeStore.ranks[species.unlockRank].name)
            } else if present {
                GIcon(kind: .check, size: 15, color: GladeTheme.fern)
            } else {
                Button {
                    markOpenedOnce()
                    var j = store.jar
                    j.fauna.append(FaunaInstance(speciesID: species.id, population: 0.3))
                    store.jar = j
                    store.recordReplant(j)
                    store.addXP(10)
                    GladeHaptics.thump()
                } label: {
                    Text("Introduce")
                        .font(GladeTheme.body(12))
                        .foregroundColor(GladeTheme.mossDeep)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(GladeTheme.moss.opacity(0.14)))
                }
            }
        }
        .gladeCard(padding: 11)
    }

    private func prefLine(_ species: PlantSpecies) -> String {
        let light = species.lightPref > 0.6 ? "bright light" : (species.lightPref < 0.45 ? "shade" : "soft light")
        let water = species.moisturePref > 0.7 ? "loves damp" : (species.moisturePref < 0.5 ? "keeps dry" : "even moisture")
        return "\(light) · \(water)"
    }
}
