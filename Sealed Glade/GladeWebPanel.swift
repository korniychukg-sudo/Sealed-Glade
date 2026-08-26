import SwiftUI
import WebKit

struct GladeWebPanel: UIViewRepresentable {
    let urlString: String
    var onPagePainted: (() -> Void)? = nil

    final class PaintWatcher: NSObject, WKNavigationDelegate {
        var onPagePainted: (() -> Void)?
        private var alreadyFired = false

        private func announce() {
            if alreadyFired { return }
            alreadyFired = true
            onPagePainted?()
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            announce()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            let failure = error as NSError
            if failure.domain == NSURLErrorDomain && failure.code == NSURLErrorCancelled { return }
            announce()
        }
    }

    func makeCoordinator() -> PaintWatcher { PaintWatcher() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.overrideUserInterfaceStyle = .light
        context.coordinator.onPagePainted = onPagePainted
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onPagePainted = onPagePainted
    }
}
