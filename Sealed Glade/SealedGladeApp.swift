import SwiftUI

@main
struct SealedGladeApp: App {
    @StateObject private var store = GladeStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                store.runCatchUp()
                store.touchPlayDay()
            }
            if phase == .background || phase == .inactive {
                store.saveNow()
            }
        }
    }
}
