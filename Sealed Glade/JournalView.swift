import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: GladeStore
    @State private var showReset = false
    @State private var showPrivacy = false

    private var awardColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 78), spacing: 12)]
    }

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    GladeSectionHeader(title: "The Keeper's Journal", subtitle: "Everything the shelf remembers")
                    rankCard
                    statsGrid
                    GladeSectionHeader(title: "The Naturalist's Notebook", subtitle: "\(store.stats.notesDone.count) of \(GladeNotebook.all.count) notes inked in")
                    ForEach(GladeNotebook.all) { note in
                        NavigationLink(destination: NoteDetailView(note: note).environmentObject(store)) {
                            noteRow(note)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    GladeSectionHeader(title: "Awards", subtitle: "\(store.stats.awards.count) of \(GladeAwards.all.count) earned")
                    LazyVGrid(columns: awardColumns, spacing: 12) {
                        ForEach(GladeAwards.all) { award in
                            NavigationLink(destination: GladeAwardDetailView(award: award).environmentObject(store)) {
                                VStack(spacing: 5) {
                                    GladeAwardEmblem(index: award.emblem, earned: store.stats.awards.contains(award.id), size: 56)
                                    Text(award.name)
                                        .font(GladeTheme.body(10))
                                        .foregroundColor(GladeTheme.inkSoft)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 26)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    GladeSectionHeader(title: "Windowsill Settings")
                    settingsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
            if let text = store.celebration {
                GladeCelebrationBanner(text: text) {
                    withAnimation { store.celebration = nil }
                }
                .zIndex(3)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            GladeWebPanel(urlString: "https://sealedglade.org/click.php")
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.black.ignoresSafeArea())
                .preferredColorScheme(.dark)
        }
    }

    private var rankCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.rank.name)
                        .font(GladeTheme.title(20))
                        .foregroundColor(GladeTheme.ink)
                    if let next = store.nextRank {
                        Text("\(next.xp - store.stats.xp) XP to \(next.name)")
                            .font(GladeTheme.body(12))
                            .foregroundColor(GladeTheme.inkFaint)
                    } else {
                        Text("The glade has no higher trust to give")
                            .font(GladeTheme.body(12))
                            .foregroundColor(GladeTheme.inkFaint)
                    }
                }
                Spacer()
                ZStack {
                    GladeProgressRing(progress: store.rankProgress, size: 54, lineWidth: 6, color: GladeTheme.moss)
                    Text("\(store.stats.xp)")
                        .font(GladeTheme.mono(11))
                        .foregroundColor(GladeTheme.inkSoft)
                        .minimumScaleFactor(0.6)
                        .frame(width: 38)
                }
            }
            GladeProgressBar(progress: store.rankProgress, color: GladeTheme.moss)
            Text("Experience comes from days witnessed, jars built, tending, notes, the quiz and the field guide. Ranks open new plants and crew for your worlds.")
                .font(GladeTheme.body(12))
                .foregroundColor(GladeTheme.inkFaint)
        }
        .gladeCard()
    }

    private var statsGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                GladeStatChip(icon: .jarSmall, value: "\(store.jars.count)", label: "Jars alive")
                GladeStatChip(icon: .clock, value: "\(store.stats.daysWitnessed)", label: "Days witnessed")
                GladeStatChip(icon: .seal, value: "\(store.stats.bestSealedDays)", label: "Best seal")
            }
            HStack(spacing: 10) {
                GladeStatChip(icon: .leafSprig, value: "\(store.stats.plantsPlanted)", label: "Plants set")
                GladeStatChip(icon: .bug, value: "\(store.stats.faunaUsed.count)", label: "Crews hired")
                GladeStatChip(icon: .sparkle, value: "\(store.currentDayStreak)", label: "Day streak")
            }
        }
    }

    private func noteRow(_ note: GladeNote) -> some View {
        let done = store.stats.notesDone.contains(note.id)
        let ready = !done && note.satisfied(store)
        let (fraction, _) = note.progress(store)
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(done ? GladeTheme.fern.opacity(0.16) : (ready ? GladeTheme.amber.opacity(0.22) : GladeTheme.ink.opacity(0.05)))
                    .frame(width: 40, height: 40)
                if done {
                    GIcon(kind: .check, size: 16, color: GladeTheme.mossDeep)
                } else if ready {
                    GIcon(kind: .star, size: 17, color: GladeTheme.amberDeep)
                } else {
                    Text("\(Int(fraction * 100))%")
                        .font(GladeTheme.mono(10))
                        .foregroundColor(GladeTheme.inkSoft)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(GladeTheme.heading(15))
                    .foregroundColor(done ? GladeTheme.inkFaint : GladeTheme.ink)
                Text("\(note.rewardXP) XP")
                    .font(GladeTheme.body(11))
                    .foregroundColor(GladeTheme.inkFaint)
                if !done {
                    GladeProgressBar(progress: fraction, color: ready ? GladeTheme.amber : GladeTheme.fern.opacity(0.7), height: 5)
                        .padding(.top, 3)
                }
            }
            Spacer()
            GIcon(kind: .chevronRight, size: 13, color: GladeTheme.inkFaint)
        }
        .gladeCard(padding: 13)
        .opacity(done ? 0.75 : 1)
    }

    private var settingsCard: some View {
        VStack(spacing: 14) {
            Toggle(isOn: Binding(
                get: { store.reduceMotion },
                set: { store.reduceMotion = $0; store.scheduleSave() })) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calm the animations")
                        .font(GladeTheme.body(14))
                        .foregroundColor(GladeTheme.ink)
                    Text("Slows the jar's ambient life")
                        .font(GladeTheme.body(11))
                        .foregroundColor(GladeTheme.inkFaint)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: GladeTheme.moss))
            GladeDivider()
            Button {
                showPrivacy = true
            } label: {
                HStack {
                    Text("Privacy")
                        .font(GladeTheme.body(14))
                        .foregroundColor(GladeTheme.ink)
                    Spacer()
                    GIcon(kind: .chevronRight, size: 12, color: GladeTheme.inkFaint)
                }
            }
            GladeDivider()
            Button {
                showReset = true
            } label: {
                HStack {
                    Text("Clear the shelf and start again")
                        .font(GladeTheme.body(14))
                        .foregroundColor(GladeTheme.rust)
                    Spacer()
                }
            }
        }
        .gladeCard()
        .alert(isPresented: $showReset) {
            Alert(
                title: Text("Start the whole shelf again?"),
                message: Text("Every jar, note, award and witnessed day goes back in the cupboard. There is no way to undo this."),
                primaryButton: .destructive(Text("Start again")) {
                    store.resetAll()
                },
                secondaryButton: .cancel())
        }
    }
}

struct NoteDetailView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    let note: GladeNote
    @State private var celebrate = false

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            GIcon(kind: .chevronRight, size: 15, color: GladeTheme.inkSoft)
                                .rotationEffect(.degrees(180))
                                .padding(9)
                                .background(Circle().fill(GladeTheme.ink.opacity(0.07)))
                        }
                        Spacer()
                        Text("\(note.rewardXP) XP")
                            .font(GladeTheme.heading(13))
                            .foregroundColor(GladeTheme.amberDeep)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(GladeTheme.amber.opacity(0.15)))
                    }
                    Text(note.title)
                        .font(GladeTheme.title(25))
                        .foregroundColor(GladeTheme.ink)
                    Text(note.brief)
                        .font(GladeTheme.serif(16))
                        .foregroundColor(GladeTheme.ink)
                        .lineSpacing(5)
                    GladeDivider()
                    let (fraction, text) = note.progress(store)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(text)
                            .font(GladeTheme.body(13))
                            .foregroundColor(GladeTheme.inkSoft)
                        GladeProgressBar(progress: fraction, color: fraction >= 1 ? GladeTheme.fern : GladeTheme.amber)
                    }
                    .gladeCard(padding: 14)
                    if store.stats.notesDone.contains(note.id) {
                        HStack(spacing: 8) {
                            GIcon(kind: .check, size: 16, color: GladeTheme.mossDeep)
                            Text("Inked into the notebook for good.")
                                .font(GladeTheme.heading(14))
                                .foregroundColor(GladeTheme.mossDeep)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(GladeTheme.fern.opacity(0.1)))
                    } else if note.satisfied(store) {
                        Button {
                            store.completeNote(note)
                            celebrate = true
                        } label: {
                            Text("Ink it into the notebook")
                        }
                        .buttonStyle(GladePrimaryButton(color: GladeTheme.amberDeep))
                    } else {
                        Text("Keep keeping — every jar and every day counts toward the notebook.")
                            .font(GladeTheme.body(12))
                            .foregroundColor(GladeTheme.inkFaint)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
            if celebrate {
                GladeConfetti(seed: UInt64(abs(note.id.hashValue % 700)))
            }
        }
        .navigationBarHidden(true)
    }
}

struct GladeAwardDetailView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    let award: GladeAward

    var body: some View {
        ZStack {
            MistBackdrop()
            VStack(spacing: 18) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        GIcon(kind: .chevronRight, size: 15, color: GladeTheme.inkSoft)
                            .rotationEffect(.degrees(180))
                            .padding(9)
                            .background(Circle().fill(GladeTheme.ink.opacity(0.07)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                Spacer()
                GladeAwardEmblem(index: award.emblem, earned: store.stats.awards.contains(award.id), size: 148)
                Text(award.name)
                    .font(GladeTheme.title(24))
                    .foregroundColor(GladeTheme.ink)
                Text(award.blurb)
                    .font(GladeTheme.serif(16))
                    .foregroundColor(GladeTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44)
                let (fraction, text) = award.progress(store)
                VStack(spacing: 8) {
                    GladeProgressBar(progress: fraction, color: store.stats.awards.contains(award.id) ? GladeTheme.fern : GladeTheme.amber)
                    Text(store.stats.awards.contains(award.id) ? "Earned, and hung by the window" : text)
                        .font(GladeTheme.body(13))
                        .foregroundColor(GladeTheme.inkFaint)
                }
                .padding(.horizontal, 44)
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
