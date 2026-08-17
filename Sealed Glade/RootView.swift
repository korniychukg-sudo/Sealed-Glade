import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: GladeStore
    @State private var selectedTab = 0

    var body: some View {
        if !store.onboardingDone {
            OnboardingView()
                .environmentObject(store)
        } else {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { GladeView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { ShelfView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { GuideView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { JournalView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                tabBar
            }
            .ignoresSafeArea(.keyboard)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, icon: .glade, label: "Glade")
            tabButton(1, icon: .shelf, label: "Shelf")
            tabButton(2, icon: .guide, label: "Field Guide")
            tabButton(3, icon: .journal, label: "Journal")
        }
        .padding(.top, 9)
        .padding(.bottom, 3)
        .background(
            GladeTheme.paper
                .overlay(Rectangle().fill(GladeTheme.ink.opacity(0.08)).frame(height: 1), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(_ index: Int, icon: GIconKind, label: String) -> some View {
        Button {
            if selectedTab != index {
                selectedTab = index
                GladeHaptics.tap()
            }
        } label: {
            VStack(spacing: 3) {
                GIcon(kind: icon, size: 23, color: selectedTab == index ? GladeTheme.mossDeep : GladeTheme.inkFaint.opacity(0.75))
                Text(label)
                    .font(GladeTheme.body(10))
                    .foregroundColor(selectedTab == index ? GladeTheme.mossDeep : GladeTheme.inkFaint.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
