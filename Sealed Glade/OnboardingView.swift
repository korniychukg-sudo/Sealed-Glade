import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: GladeStore
    @State private var page = 0

    private let pages: [(art: String, title: String, text: String)] = [
        ("onboard_1", "A world in a jar", "Layer pebbles, charcoal and soil, choose your plants and their glass, and seal the lid. From that moment the little world waters itself — condensation rises, beads on the glass, and falls as private rain."),
        ("onboard_2", "It lives while you're away", "The glade keeps its own time. Plants grow toward the light you chose, springtails patrol for mould, isopods work the litter, and real days pass on the sill whether you visit or not. Come back to find out what happened."),
        ("onboard_3", "The keeper's craft", "Read the glass, trust the crew, and open the lid only when you must — every opening resets the sealed-days count the shelf brags about. A field guide, a naturalist's quiz and a notebook of goals round out the craft. Everything stays on this device."),
    ]

    var body: some View {
        ZStack {
            MistBackdrop(tone: GladeTheme.cream)
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { idx in
                        VStack(spacing: 22) {
                            GladeArtImage(name: pages[idx].art)
                                .frame(maxWidth: 480)
                                .frame(height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(GladeTheme.mossDeep.opacity(0.3), lineWidth: 1.5)
                                )
                                .padding(.horizontal, 26)
                            VStack(spacing: 10) {
                                Text(pages[idx].title)
                                    .font(GladeTheme.title(26))
                                    .foregroundColor(GladeTheme.ink)
                                    .multilineTextAlignment(.center)
                                Text(pages[idx].text)
                                    .font(GladeTheme.serif(16))
                                    .foregroundColor(GladeTheme.inkSoft)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                                    .padding(.horizontal, 34)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.top, 30)
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                HStack(spacing: 7) {
                    ForEach(pages.indices, id: \.self) { idx in
                        Capsule()
                            .fill(idx == page ? GladeTheme.moss : GladeTheme.ink.opacity(0.15))
                            .frame(width: idx == page ? 22 : 7, height: 7)
                            .animation(.easeOut(duration: 0.2), value: page)
                    }
                }
                .padding(.bottom, 18)
                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        store.onboardingDone = true
                        store.scheduleSave()
                        GladeHaptics.success()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Next" : "To the windowsill")
                }
                .buttonStyle(GladePrimaryButton())
                .padding(.horizontal, 34)
                if page < pages.count - 1 {
                    Button {
                        store.onboardingDone = true
                        store.scheduleSave()
                    } label: {
                        Text("Skip")
                            .font(GladeTheme.body(14))
                            .foregroundColor(GladeTheme.inkFaint)
                    }
                    .padding(.top, 10)
                } else {
                    Color.clear.frame(height: 30)
                }
                Spacer(minLength: 20)
            }
        }
    }
}
