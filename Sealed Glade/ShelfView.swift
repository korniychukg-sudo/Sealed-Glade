import SwiftUI

struct ShelfView: View {
    @EnvironmentObject var store: GladeStore
    @State private var phaseStart = Date()
    @State private var showBuilder = false
    @State private var renameIndex: Int?
    @State private var renameText = ""
    @State private var deleteIndex: Int?

    var body: some View {
        ZStack {
            MistBackdrop()
            ScrollView {
                VStack(spacing: 14) {
                    GladeSectionHeader(title: "The Shelf", subtitle: "Every world you keep, side by side")
                    ForEach(store.jars.indices, id: \.self) { idx in
                        jarCard(idx)
                    }
                    if store.jars.count < 3 {
                        Button {
                            showBuilder = true
                        } label: {
                            HStack(spacing: 8) {
                                GIcon(kind: .plus, size: 15, color: GladeTheme.mist)
                                Text("Build a new jar")
                            }
                        }
                        .buttonStyle(GladePrimaryButton())
                    } else {
                        Text("The shelf holds three worlds — every windowsill has its limits.")
                            .font(GladeTheme.body(12))
                            .foregroundColor(GladeTheme.inkFaint)
                    }
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
        .fullScreenCover(isPresented: $showBuilder) {
            BuilderView()
                .environmentObject(store)
        }
        .alert(item: Binding(
            get: { deleteIndex.map { IndexBox(value: $0) } },
            set: { deleteIndex = $0?.value })) { box in
            Alert(
                title: Text("Take \(store.jars[box.value].name) off the shelf?"),
                message: Text("The whole little world — its plants, its crew, its \(store.jars[box.value].dayCount) days — goes back into the cupboard forever."),
                primaryButton: .destructive(Text("Take it down")) {
                    store.removeJar(at: box.value)
                },
                secondaryButton: .cancel())
        }
    }

    private struct IndexBox: Identifiable {
        let value: Int
        var id: Int { value }
    }

    private func jarCard(_ idx: Int) -> some View {
        let jar = store.jars[idx]
        let isCurrent = idx == store.currentJar
        return VStack(spacing: 10) {
            HStack(spacing: 14) {
                TimelineView(.animation(minimumInterval: store.reduceMotion ? 0.6 : 1.0 / 20.0)) { timeline in
                    Canvas { ctx, size in
                        let rect = CGRect(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
                        var inner = ctx
                        JarArtist.drawJar(&inner, rect: rect, jar: jar, phase: timeline.date.timeIntervalSince(phaseStart), daylight: store.daylight)
                    }
                    .frame(width: 96, height: 120)
                }
                VStack(alignment: .leading, spacing: 4) {
                    if renameIndex == idx {
                        TextField("Jar name", text: $renameText, onCommit: {
                            let trimmed = renameText.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                store.jars[idx].name = String(trimmed.prefix(22))
                                store.scheduleSave()
                            }
                            renameIndex = nil
                        })
                        .font(GladeTheme.heading(15))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(jar.name)
                            .font(GladeTheme.heading(17))
                            .foregroundColor(GladeTheme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    Text("\(jar.shape.label) · \(jar.spot.label.lowercased())")
                        .font(GladeTheme.body(12))
                        .foregroundColor(GladeTheme.inkFaint)
                    Text("Day \(jar.dayCount) · sealed \(jar.sealedDays) · balance \(Int(jar.balance))")
                        .font(GladeTheme.body(12))
                        .foregroundColor(GladeTheme.inkFaint)
                    HStack(spacing: 8) {
                        if isCurrent {
                            Text("In your hands")
                                .font(GladeTheme.body(11))
                                .foregroundColor(GladeTheme.mossDeep)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(GladeTheme.moss.opacity(0.13)))
                        }
                        Button {
                            renameText = jar.name
                            renameIndex = idx
                        } label: {
                            Text("Rename")
                                .font(GladeTheme.body(11))
                                .foregroundColor(GladeTheme.amberDeep)
                        }
                        if store.jars.count > 1 {
                            Button {
                                deleteIndex = idx
                            } label: {
                                Text("Remove")
                                    .font(GladeTheme.body(11))
                                    .foregroundColor(GladeTheme.rust)
                            }
                        }
                    }
                }
                Spacer()
            }
            if !isCurrent {
                Button {
                    store.currentJar = idx
                    store.scheduleSave()
                    GladeHaptics.tap()
                } label: {
                    Text("Pick this jar up")
                }
                .buttonStyle(GladeSoftButton())
            }
        }
        .gladeCard(padding: 13)
    }
}
