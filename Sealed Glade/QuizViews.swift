import SwiftUI

struct GladeGuideDetailView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    let guide: GladeGuide

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        GladeArtImage(name: guide.plateArt)
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(GladeTheme.mossDeep.opacity(0.35), lineWidth: 1.5)
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
                        Text(guide.title)
                            .font(GladeTheme.title(25))
                            .foregroundColor(GladeTheme.ink)
                        Text(guide.subtitle)
                            .font(GladeTheme.body(14))
                            .foregroundColor(GladeTheme.inkFaint)
                    }
                    ForEach(guide.paragraphs.indices, id: \.self) { idx in
                        Text(guide.paragraphs[idx])
                            .font(GladeTheme.serif(16))
                            .foregroundColor(GladeTheme.ink)
                            .lineSpacing(5)
                    }
                    GladeDivider()
                    Text("Worth remembering")
                        .font(GladeTheme.heading(16))
                        .foregroundColor(GladeTheme.ink)
                    VStack(spacing: 8) {
                        ForEach(guide.facts.indices, id: \.self) { idx in
                            HStack(alignment: .top, spacing: 10) {
                                Circle().fill(GladeTheme.amber).frame(width: 6, height: 6).padding(.top, 6)
                                Text(guide.facts[idx])
                                    .font(GladeTheme.body(14))
                                    .foregroundColor(GladeTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .gladeCard(padding: 12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.recordGuideRead(guide.id)
        }
    }
}

struct GladeGlossaryView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    @State private var search = ""

    var filtered: [GladeTerm] {
        let trimmed = search.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty { return GladeGlossary.terms }
        return GladeGlossary.terms.filter { $0.term.lowercased().contains(trimmed) || $0.definition.lowercased().contains(trimmed) }
    }

    var body: some View {
        ZStack {
            MistBackdrop()
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        GIcon(kind: .chevronRight, size: 15, color: GladeTheme.inkSoft)
                            .rotationEffect(.degrees(180))
                            .padding(9)
                            .background(Circle().fill(GladeTheme.ink.opacity(0.07)))
                    }
                    Text("Glade Glossary")
                        .font(GladeTheme.title(20))
                        .foregroundColor(GladeTheme.ink)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                TextField("Search terms", text: $search)
                    .font(GladeTheme.body(15))
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 12).fill(GladeTheme.paper))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(GladeTheme.ink.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                ScrollView {
                    VStack(spacing: 9) {
                        ForEach(filtered) { term in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(term.term)
                                    .font(GladeTheme.heading(15))
                                    .foregroundColor(GladeTheme.ink)
                                Text(term.definition)
                                    .font(GladeTheme.body(13))
                                    .foregroundColor(GladeTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .gladeCard(padding: 13)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct GladeQuizView: View {
    @EnvironmentObject var store: GladeStore
    @Environment(\.presentationMode) var presentationMode
    @State private var questions: [GladeQuizQuestion] = []
    @State private var index = 0
    @State private var score = 0
    @State private var picked: Int?
    @State private var finished = false

    var body: some View {
        ZStack {
            MistBackdrop()
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        GIcon(kind: .close, size: 14, color: GladeTheme.inkSoft)
                            .padding(9)
                            .background(Circle().fill(GladeTheme.ink.opacity(0.07)))
                    }
                    Text("The Naturalist's Quiz")
                        .font(GladeTheme.title(19))
                        .foregroundColor(GladeTheme.ink)
                    Spacer()
                    if !finished && !questions.isEmpty {
                        Text("\(index + 1)/\(questions.count)")
                            .font(GladeTheme.mono(13))
                            .foregroundColor(GladeTheme.inkSoft)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                if finished {
                    resultView
                } else if questions.isEmpty {
                    Spacer()
                    Button {
                        startRound()
                    } label: {
                        Text("Take the quiz")
                    }
                    .buttonStyle(GladePrimaryButton())
                    .padding(.horizontal, 40)
                    Text("Ten questions drawn fresh from the field guide, the glossary and the species pages.")
                        .font(GladeTheme.body(13))
                        .foregroundColor(GladeTheme.inkFaint)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 12)
                    Spacer()
                } else {
                    questionView
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func startRound() {
        questions = GladeQuiz.makeRound()
        index = 0
        score = 0
        picked = nil
        finished = false
    }

    private var questionView: some View {
        let q = questions[index]
        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                GladeProgressBar(progress: Double(index) / Double(questions.count), color: GladeTheme.moss, height: 6)
                Text(q.prompt)
                    .font(GladeTheme.heading(17))
                    .foregroundColor(GladeTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                ForEach(q.options.indices, id: \.self) { idx in
                    Button {
                        guard picked == nil else { return }
                        picked = idx
                        if idx == q.correctIndex {
                            score += 1
                            GladeHaptics.success()
                        } else {
                            GladeHaptics.warning()
                        }
                    } label: {
                        HStack {
                            Text(q.options[idx])
                                .font(GladeTheme.body(14))
                                .foregroundColor(optionColor(idx, q: q))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            if let picked = picked {
                                if idx == q.correctIndex {
                                    GIcon(kind: .check, size: 14, color: GladeTheme.mossDeep)
                                } else if idx == picked {
                                    GIcon(kind: .close, size: 12, color: GladeTheme.rust)
                                }
                            }
                        }
                        .padding(13)
                        .background(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(optionBackground(idx, q: q))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(optionBorder(idx, q: q), lineWidth: 1.4)
                        )
                    }
                    .disabled(picked != nil)
                }
                if picked != nil {
                    Text(q.explanation)
                        .font(GladeTheme.serif(14))
                        .foregroundColor(GladeTheme.inkSoft)
                        .lineSpacing(4)
                        .padding(13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 13).fill(GladeTheme.amber.opacity(0.10)))
                    Button {
                        if index + 1 < questions.count {
                            index += 1
                            picked = nil
                        } else {
                            store.recordQuiz(score: score)
                            finished = true
                        }
                    } label: {
                        Text(index + 1 < questions.count ? "Next question" : "See the result")
                    }
                    .buttonStyle(GladePrimaryButton())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 60)
        }
    }

    private func optionColor(_ idx: Int, q: GladeQuizQuestion) -> Color {
        guard picked != nil else { return GladeTheme.ink }
        if idx == q.correctIndex { return GladeTheme.mossDeep }
        return GladeTheme.inkFaint
    }

    private func optionBackground(_ idx: Int, q: GladeQuizQuestion) -> Color {
        guard let picked = picked else { return GladeTheme.paper }
        if idx == q.correctIndex { return GladeTheme.fern.opacity(0.10) }
        if idx == picked { return GladeTheme.rust.opacity(0.08) }
        return GladeTheme.paper
    }

    private func optionBorder(_ idx: Int, q: GladeQuizQuestion) -> Color {
        guard let picked = picked else { return GladeTheme.ink.opacity(0.08) }
        if idx == q.correctIndex { return GladeTheme.fern.opacity(0.5) }
        if idx == picked { return GladeTheme.rust.opacity(0.4) }
        return GladeTheme.ink.opacity(0.05)
    }

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                GladeProgressRing(progress: Double(score) / 10.0, size: 110, lineWidth: 11, color: score >= 7 ? GladeTheme.fern : GladeTheme.amber)
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(GladeTheme.title(36))
                        .foregroundColor(GladeTheme.ink)
                    Text("of 10")
                        .font(GladeTheme.body(12))
                        .foregroundColor(GladeTheme.inkFaint)
                }
            }
            Text(verdict)
                .font(GladeTheme.serif(16))
                .foregroundColor(GladeTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if score >= store.stats.quizBest && score > 0 {
                Text("A new personal best")
                    .font(GladeTheme.heading(13))
                    .foregroundColor(GladeTheme.amberDeep)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(GladeTheme.amber.opacity(0.15)))
            }
            Button {
                startRound()
            } label: {
                Text("Sit it again")
            }
            .buttonStyle(GladePrimaryButton())
            .padding(.horizontal, 60)
            Spacer()
        }
    }

    private var verdict: String {
        switch score {
        case 10: return "A perfect sheet. Somewhere, Dr Ward nods approvingly at his moth jar."
        case 8...9: return "A fine showing. The glade would trust you with its lid."
        case 6...7: return "Solid work, with a chapter or two worth rereading by the window."
        case 4...5: return "The examiner smiles kindly and presses a fern frond into your notebook."
        default: return "Every great keeper started by overwatering something. The guide is on the shelf."
        }
    }
}
