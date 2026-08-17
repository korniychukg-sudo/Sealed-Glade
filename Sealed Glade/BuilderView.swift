import SwiftUI

struct BuilderView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    @State private var step = 0
    @State private var name = ""
    @State private var shape: JarShape = .belly
    @State private var spot: JarSpot = .bright
    @State private var chosenPlants: [String] = []
    @State private var chosenFauna: [String] = ["springtails"]
    @State private var sealed = false
    @State private var phaseStart = Date()

    private var previewJar: JarState {
        var jar = JarState(name: name.isEmpty ? "The New Glade" : name, shape: shape, spot: spot)
        var rng = GladeSeededRandom(seed: 77)
        jar.plants = chosenPlants.map { PlantInstance(speciesID: $0, x: 0.12 + Double(rng.next()) * 0.76, growth: 0.22) }
        jar.fauna = chosenFauna.map { FaunaInstance(speciesID: $0, population: 0.35) }
        return jar
    }

    var body: some View {
        ZStack {
            MistBackdrop()
            VStack(spacing: 0) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        GIcon(kind: .close, size: 14, color: GladeTheme.inkSoft)
                            .padding(9)
                            .background(Circle().fill(GladeTheme.ink.opacity(0.07)))
                    }
                    Spacer()
                    Text(stepTitle)
                        .font(GladeTheme.heading(16))
                        .foregroundColor(GladeTheme.ink)
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                HStack(spacing: 5) {
                    ForEach(0..<4, id: \.self) { idx in
                        Capsule()
                            .fill(idx <= step ? GladeTheme.moss : GladeTheme.ink.opacity(0.12))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                ScrollView {
                    VStack(spacing: 14) {
                        switch step {
                        case 0: vesselStep
                        case 1: plantStep
                        case 2: crewStep
                        default: sealStep
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            if sealed {
                GladeConfetti(seed: 91)
            }
        }
    }

    private var stepTitle: String {
        switch step {
        case 0: return "The Vessel"
        case 1: return "The Tenants"
        case 2: return "The Crew"
        default: return "The Sealing"
        }
    }

    private var vesselStep: some View {
        VStack(spacing: 14) {
            jarPreview(height: 240)
            VStack(alignment: .leading, spacing: 8) {
                Text("Name the world")
                    .font(GladeTheme.heading(14))
                    .foregroundColor(GladeTheme.ink)
                TextField("The Mossy Hollow, The Green Bottle…", text: $name)
                    .font(GladeTheme.body(15))
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 12).fill(GladeTheme.paper))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(GladeTheme.ink.opacity(0.1), lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose the glass")
                    .font(GladeTheme.heading(14))
                    .foregroundColor(GladeTheme.ink)
                Picker("", selection: $shape) {
                    Text("Belly").tag(JarShape.belly)
                    Text("Column").tag(JarShape.column)
                    Text("Flask").tag(JarShape.flask)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .gladeCard(padding: 14)
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose its place")
                    .font(GladeTheme.heading(14))
                    .foregroundColor(GladeTheme.ink)
                Picker("", selection: $spot) {
                    Text("Shade").tag(JarSpot.shade)
                    Text("Bright").tag(JarSpot.bright)
                    Text("Sun").tag(JarSpot.sun)
                }
                .pickerStyle(SegmentedPickerStyle())
                Text(spot.caution)
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.inkFaint)
            }
            .gladeCard(padding: 14)
            Button {
                step = 1
            } label: {
                Text("Lay the layers — onward")
            }
            .buttonStyle(GladePrimaryButton())
        }
    }

    private var plantStep: some View {
        VStack(spacing: 12) {
            jarPreview(height: 200)
            Text("Choose up to four founding plants. Check their tastes against the spot you picked — tenants who agree make peaceful worlds.")
                .font(GladeTheme.body(13))
                .foregroundColor(GladeTheme.inkFaint)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(GladeSpecies.plants) { species in
                builderPlantRow(species)
            }
            Button {
                step = 2
            } label: {
                Text(chosenPlants.isEmpty ? "A bare jar is allowed — onward" : "Onward to the crew")
            }
            .buttonStyle(GladePrimaryButton())
        }
    }

    private func builderPlantRow(_ species: PlantSpecies) -> some View {
        let unlocked = store.isPlantUnlocked(species)
        let chosen = chosenPlants.contains(species.id)
        let fit = 1 - abs(spot.light - species.lightPref) * 1.6
        return Button {
            guard unlocked else {
                GladeHaptics.warning()
                return
            }
            if chosen {
                chosenPlants.removeAll { $0 == species.id }
            } else if chosenPlants.count < 4 {
                chosenPlants.append(species.id)
                GladeHaptics.tap()
            } else {
                GladeHaptics.warning()
            }
        } label: {
            HStack(spacing: 12) {
                GladeArtImage(name: species.plateArt)
                    .frame(width: 54, height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .opacity(unlocked ? 1 : 0.4)
                VStack(alignment: .leading, spacing: 2) {
                    Text(species.name)
                        .font(GladeTheme.heading(14))
                        .foregroundColor(GladeTheme.ink)
                    Text(fitLine(fit))
                        .font(GladeTheme.body(11))
                        .foregroundColor(fit > 0.55 ? GladeTheme.fern : (fit > 0.25 ? GladeTheme.amberDeep : GladeTheme.rust))
                }
                Spacer()
                if !unlocked {
                    GladeLockBadge(rankName: GladeStore.ranks[species.unlockRank].name)
                } else if chosen {
                    GIcon(kind: .check, size: 16, color: GladeTheme.mossDeep)
                } else {
                    Circle().stroke(GladeTheme.inkFaint, lineWidth: 1.4).frame(width: 16, height: 16)
                }
            }
            .gladeCard(padding: 11)
        }
    }

    private func fitLine(_ fit: Double) -> String {
        if fit > 0.55 { return "Will love this spot" }
        if fit > 0.25 { return "Would cope, grumbling a little" }
        return "Wrong light for this spot"
    }

    private var crewStep: some View {
        VStack(spacing: 12) {
            jarPreview(height: 200)
            Text("Hire the invisible workforce. Springtails alone will keep most jars honest; the rest are specialists.")
                .font(GladeTheme.body(13))
                .foregroundColor(GladeTheme.inkFaint)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(GladeSpecies.faunas) { species in
                let unlocked = store.isFaunaUnlocked(species)
                let chosen = chosenFauna.contains(species.id)
                Button {
                    guard unlocked else {
                        GladeHaptics.warning()
                        return
                    }
                    if chosen {
                        chosenFauna.removeAll { $0 == species.id }
                    } else {
                        chosenFauna.append(species.id)
                        GladeHaptics.tap()
                    }
                } label: {
                    HStack(spacing: 12) {
                        GladeArtImage(name: species.plateArt)
                            .frame(width: 54, height: 46)
                            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                            .opacity(unlocked ? 1 : 0.4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(species.name)
                                .font(GladeTheme.heading(14))
                                .foregroundColor(GladeTheme.ink)
                            Text(species.role)
                                .font(GladeTheme.body(11))
                                .foregroundColor(GladeTheme.inkFaint)
                        }
                        Spacer()
                        if !unlocked {
                            GladeLockBadge(rankName: GladeStore.ranks[species.unlockRank].name)
                        } else if chosen {
                            GIcon(kind: .check, size: 16, color: GladeTheme.mossDeep)
                        } else {
                            Circle().stroke(GladeTheme.inkFaint, lineWidth: 1.4).frame(width: 16, height: 16)
                        }
                    }
                    .gladeCard(padding: 11)
                }
            }
            Button {
                step = 3
            } label: {
                Text("To the sealing")
            }
            .buttonStyle(GladePrimaryButton())
        }
    }

    private var sealStep: some View {
        VStack(spacing: 16) {
            jarPreview(height: 280)
            VStack(alignment: .leading, spacing: 8) {
                summaryRow(icon: .jarSmall, text: "\(shape.label), standing in \(spot.label.lowercased())")
                summaryRow(icon: .leafSprig, text: chosenPlants.isEmpty ? "No plants yet — a waiting world" : GladeSpecies.plants.filter { chosenPlants.contains($0.id) }.map { $0.name }.joined(separator: ", "))
                summaryRow(icon: .bug, text: chosenFauna.isEmpty ? "No crew — the litter is on its own" : GladeSpecies.faunas.filter { chosenFauna.contains($0.id) }.map { $0.name }.joined(separator: ", "))
            }
            .gladeCard()
            if sealed {
                Text("Sealed. From this breath on, the world inside waters itself.")
                    .font(GladeTheme.serif(15))
                    .foregroundColor(GladeTheme.mossDeep)
                    .multilineTextAlignment(.center)
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Set it on the shelf")
                }
                .buttonStyle(GladePrimaryButton())
            } else {
                Button {
                    var jar = previewJar
                    jar.eventLog = [JarEvent(day: 0, text: "The lid closed for the first time. From now on, this world waters itself.", kind: "milestone")]
                    store.addJar(jar)
                    sealed = true
                    GladeHaptics.success()
                } label: {
                    HStack(spacing: 8) {
                        GIcon(kind: .seal, size: 16, color: GladeTheme.mist)
                        Text("Close the lid")
                    }
                }
                .buttonStyle(GladePrimaryButton(color: GladeTheme.amberDeep))
            }
        }
    }

    private func summaryRow(icon: GIconKind, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            GIcon(kind: icon, size: 16, color: GladeTheme.mossDeep)
                .padding(.top, 1)
            Text(text)
                .font(GladeTheme.body(13))
                .foregroundColor(GladeTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func jarPreview(height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: store.reduceMotion ? 0.6 : 1.0 / 24.0)) { timeline in
            Canvas { ctx, size in
                let rect = CGRect(x: size.width * 0.28, y: 8, width: size.width * 0.44, height: size.height - 16)
                var inner = ctx
                JarArtist.drawJar(&inner, rect: rect, jar: previewJar, phase: timeline.date.timeIntervalSince(phaseStart), daylight: store.daylight)
            }
            .frame(height: height)
            .background(RoundedRectangle(cornerRadius: 18).fill(GladeTheme.paper).shadow(color: GladeTheme.cardShadow, radius: 6, x: 0, y: 3))
        }
    }
}
