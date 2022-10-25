import SwiftUI
import WebKit

struct ContentView: View {
    @State var currentUrl: String
    
    @StateObject var webViewModel = WebViewModel()
    @State var presentAlert: Bool = false
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "CurrentUrl") {
            if let decoded = try? JSONDecoder().decode(String.self, from: data) {
                currentUrl = decoded
                return
            }
        }
        
        currentUrl = ""
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(currentUrl) {
            UserDefaults.standard.set(encoded, forKey: "CurrentUrl")
        }
    }
    
    var body: some View {
        
            WebView(webView: webViewModel.webView)
                .alert("URL", isPresented: $presentAlert, actions: {
                    TextField("URL", text: $currentUrl)
                    
                    Button("Go", action: {
                        webViewModel.load(urlString: currentUrl)
                        save();
                    })
                    Button("Cancel", role: .cancel, action: {})
                })
                .simultaneousGesture(MagnificationGesture()
                    .onEnded { _ in
                        presentAlert = true
                    })
    }
}

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

class WebViewModel: ObservableObject {
    let webView: WKWebView
    
    init() {
        var currentUrl: String = "https://apple.com"
        if let data = UserDefaults.standard.data(forKey: "CurrentUrl") {
            if let decoded = try? JSONDecoder().decode(String.self, from: data) {
                if (currentUrl != "") {
                    currentUrl = decoded
                }
            }
        }
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true;
        webViewConfiguration.allowsAirPlayForMediaPlayback = true;
        webViewConfiguration.allowsPictureInPictureMediaPlayback = true;
        
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webViewConfiguration.userContentController.addUserScript(script)
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 16_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1"
        webView.allowsBackForwardNavigationGestures = true
        
        load(urlString: currentUrl);
    }
    
    func load(urlString: String) {
        if let url = URL(string: urlString) {
            do {
                webView.load(URLRequest(url: url))
            } catch {
            }
        }
    }
}
