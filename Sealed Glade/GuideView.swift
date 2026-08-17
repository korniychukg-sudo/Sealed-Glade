import SwiftUI

struct GuideView: View {
    @EnvironmentObject var store: GladeStore

    private var plantColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: 12)]
    }

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    GladeSectionHeader(title: "The Field Guide", subtitle: "The living science behind the glass")
                    quizCard
                    GladeSectionHeader(title: "The Plants", subtitle: "Twelve tenants, from moss to palm")
                    LazyVGrid(columns: plantColumns, spacing: 12) {
                        ForEach(GladeSpecies.plants) { species in
                            NavigationLink(destination: PlantDetailView(species: species).environmentObject(store)) {
                                plantCard(species)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    GladeSectionHeader(title: "The Crew", subtitle: "The workforce nobody sees")
                    ForEach(GladeSpecies.faunas) { species in
                        NavigationLink(destination: FaunaDetailView(species: species).environmentObject(store)) {
                            faunaRow(species)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    GladeSectionHeader(title: "The Chapters", subtitle: "How a sealed world actually works")
                    ForEach(GladeGuides.all) { guide in
                        NavigationLink(destination: GladeGuideDetailView(guide: guide).environmentObject(store)) {
                            guideRow(guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    NavigationLink(destination: GladeGlossaryView().environmentObject(store)) {
                        glossaryCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
    }

    private var quizCard: some View {
        NavigationLink(destination: GladeQuizView().environmentObject(store)) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(GladeTheme.mossDeep).frame(width: 52, height: 52)
                    GIcon(kind: .ribbon, size: 26, color: GladeTheme.fernLight)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("The Naturalist's Quiz")
                        .font(GladeTheme.heading(16))
                        .foregroundColor(GladeTheme.ink)
                    Text(store.stats.quizBest > 0 ? "Best score \(store.stats.quizBest) of 10 · \(store.stats.quizRounds) sittings" : "Ten fresh questions every sitting")
                        .font(GladeTheme.body(12))
                        .foregroundColor(GladeTheme.inkFaint)
                }
                Spacer()
                GIcon(kind: .chevronRight, size: 14, color: GladeTheme.inkFaint)
            }
            .gladeCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func plantCard(_ species: PlantSpecies) -> some View {
        let unlocked = store.isPlantUnlocked(species)
        let grown = store.stats.speciesUsed.contains(species.id)
        return VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(GladeTheme.mist)
                GladeArtImage(name: species.plateArt)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .opacity(unlocked ? 1 : 0.35)
                if !unlocked {
                    GIcon(kind: .lock, size: 22, color: GladeTheme.inkSoft)
                }
            }
            .frame(height: 104)
            .clipped()
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(species.name)
                        .font(GladeTheme.heading(14))
                        .foregroundColor(GladeTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if grown {
                        Circle().fill(GladeTheme.fern).frame(width: 6, height: 6)
                    }
                }
                Text(species.latin)
                    .font(GladeTheme.serif(11))
                    .italic()
                    .foregroundColor(GladeTheme.inkFaint)
                    .lineLimit(1)
                if !unlocked {
                    GladeLockBadge(rankName: GladeStore.ranks[species.unlockRank].name)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(GladeTheme.paper)
                .shadow(color: GladeTheme.cardShadow, radius: 5, x: 0, y: 2)
        )
    }

    private func faunaRow(_ species: FaunaSpecies) -> some View {
        let unlocked = store.isFaunaUnlocked(species)
        return HStack(spacing: 12) {
            GladeArtImage(name: species.plateArt)
                .frame(width: 76, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .opacity(unlocked ? 1 : 0.4)
            VStack(alignment: .leading, spacing: 3) {
                Text(species.name)
                    .font(GladeTheme.heading(15))
                    .foregroundColor(GladeTheme.ink)
                Text("\(species.role) · \(species.latin)")
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.inkFaint)
                    .lineLimit(2)
                if !unlocked {
                    GladeLockBadge(rankName: GladeStore.ranks[species.unlockRank].name)
                }
            }
            Spacer()
            GIcon(kind: .chevronRight, size: 13, color: GladeTheme.inkFaint)
        }
        .gladeCard(padding: 12)
    }

    private func guideRow(_ guide: GladeGuide) -> some View {
        let read = store.stats.guidesRead.contains(guide.id)
        return HStack(spacing: 12) {
            GladeArtImage(name: guide.plateArt)
                .frame(width: 78, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title)
                    .font(GladeTheme.heading(15))
                    .foregroundColor(GladeTheme.ink)
                Text(guide.subtitle)
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.inkFaint)
                    .lineLimit(2)
                if read {
                    HStack(spacing: 4) {
                        GIcon(kind: .check, size: 10, color: GladeTheme.mossDeep)
                        Text("Read")
                            .font(GladeTheme.body(10))
                            .foregroundColor(GladeTheme.mossDeep)
                    }
                }
            }
            Spacer()
            GIcon(kind: .chevronRight, size: 13, color: GladeTheme.inkFaint)
        }
        .gladeCard(padding: 12)
    }

    private var glossaryCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(GladeTheme.amber.opacity(0.2)).frame(width: 52, height: 52)
                GIcon(kind: .book, size: 24, color: GladeTheme.amberDeep)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Glade Glossary")
                    .font(GladeTheme.heading(16))
                    .foregroundColor(GladeTheme.ink)
                Text("\(GladeGlossary.terms.count) terms from algae to water cycle")
                    .font(GladeTheme.body(12))
                    .foregroundColor(GladeTheme.inkFaint)
            }
            Spacer()
            GIcon(kind: .chevronRight, size: 14, color: GladeTheme.inkFaint)
        }
        .gladeCard()
    }
}

struct PlantDetailView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    let species: PlantSpecies

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        GladeArtImage(name: species.plateArt)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(GladeTheme.mossDeep.opacity(0.3), lineWidth: 1.5)
                            )
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            GIcon(kind: .chevronRight, size: 15, color: GladeTheme.mist)
                                .rotationEffect(.degrees(180))
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.4)))
                        }
                        .padding(12)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(species.name)
                            .font(GladeTheme.title(26))
                            .foregroundColor(GladeTheme.ink)
                        Text(species.latin)
                            .font(GladeTheme.serif(15))
                            .italic()
                            .foregroundColor(GladeTheme.inkFaint)
                    }
                    HStack(spacing: 10) {
                        prefChip(label: "Light", value: species.lightPref > 0.6 ? "Bright" : (species.lightPref < 0.45 ? "Shade" : "Soft"))
                        prefChip(label: "Moisture", value: species.moisturePref > 0.7 ? "Damp" : (species.moisturePref < 0.5 ? "Drier" : "Even"))
                        prefChip(label: "Temper", value: species.hardiness > 0.75 ? "Forgiving" : (species.hardiness < 0.5 ? "Fussy" : "Steady"))
                    }
                    if !store.isPlantUnlocked(species) {
                        HStack(spacing: 8) {
                            GIcon(kind: .lock, size: 15, color: GladeTheme.amberDeep)
                            Text("Joins your nursery at the rank of \(GladeStore.ranks[species.unlockRank].name).")
                                .font(GladeTheme.body(13))
                                .foregroundColor(GladeTheme.inkSoft)
                        }
                        .gladeCard(padding: 12)
                    }
                    GladeDivider()
                    Text(species.note)
                        .font(GladeTheme.serif(16))
                        .foregroundColor(GladeTheme.ink)
                        .lineSpacing(5)
                    GladeArtImage(name: "vignette_\(species.id)")
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(GladeTheme.mossDeep.opacity(0.3), lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
    }

    private func prefChip(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(GladeTheme.heading(13))
                .foregroundColor(GladeTheme.ink)
            Text(label)
                .font(GladeTheme.body(10))
                .foregroundColor(GladeTheme.inkFaint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 11).fill(GladeTheme.cream))
    }
}

struct FaunaDetailView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    let species: FaunaSpecies

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        GladeArtImage(name: species.plateArt)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(GladeTheme.mossDeep.opacity(0.3), lineWidth: 1.5)
                            )
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            GIcon(kind: .chevronRight, size: 15, color: GladeTheme.mist)
                                .rotationEffect(.degrees(180))
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.4)))
                        }
                        .padding(12)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(species.name)
                            .font(GladeTheme.title(26))
                            .foregroundColor(GladeTheme.ink)
                        Text("\(species.role) · \(species.latin)")
                            .font(GladeTheme.serif(15))
                            .italic()
                            .foregroundColor(GladeTheme.inkFaint)
                    }
                    if !store.isFaunaUnlocked(species) {
                        HStack(spacing: 8) {
                            GIcon(kind: .lock, size: 15, color: GladeTheme.amberDeep)
                            Text("Available for hire at the rank of \(GladeStore.ranks[species.unlockRank].name).")
                                .font(GladeTheme.body(13))
                                .foregroundColor(GladeTheme.inkSoft)
                        }
                        .gladeCard(padding: 12)
                    }
                    GladeDivider()
                    Text(species.note)
                        .font(GladeTheme.serif(16))
                        .foregroundColor(GladeTheme.ink)
                        .lineSpacing(5)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
    }
}
