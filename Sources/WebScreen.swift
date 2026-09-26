import SwiftUI
import WebKit

struct WebScreen: View {
    let url: URL
    let onChangeAddress: () -> Void

    @State private var reloadID = UUID()

    var body: some View {
        WebView(url: url, reloadID: reloadID)
            .ignoresSafeArea(edges: .bottom)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { onChangeAddress() } label: {
                        Label("地址", systemImage: "globe")
                    }
                    Spacer()
                    Button { reloadID = UUID() } label: {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                }
            }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let reloadID: UUID

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // 持久化存储：保留 DSH 的登录态，免得每次重开都要重新登录
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.allowsBackForwardNavigationGestures = true
        web.load(URLRequest(url: url))
        context.coordinator.lastLoaded = url
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        if context.coordinator.lastReload != reloadID {
            context.coordinator.lastReload = reloadID
            web.load(URLRequest(url: url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var lastLoaded: URL?
        var lastReload: UUID?

        /// 局域网常见自签证书（DSH 局域网模式 / *.ts.net）：只对私有地址放行，
        /// 公网域名仍走系统正常校验，避免把安全性整体放掉。
        func webView(_ webView: WKWebView,
                     didReceive challenge: URLAuthenticationChallenge,
                     completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let trust = challenge.protectionSpace.serverTrust,
                  let host = webView.url?.host,
                  Self.isPrivateHost(host) else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            completionHandler(.useCredential, URLCredential(trust: trust))
        }

        static func isPrivateHost(_ host: String) -> Bool {
            if host.hasSuffix(".local") || host.hasSuffix(".ts.net") { return true }
            let parts = host.split(separator: ".").compactMap { Int($0) }
            guard parts.count == 4 else { return false }
            if parts[0] == 10 { return true }
            if parts[0] == 192 && parts[1] == 168 { return true }
            if parts[0] == 172 && (16...31).contains(parts[1]) { return true }
            if parts[0] == 127 { return true }
            return false
        }
    }
}
