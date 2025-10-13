import SwiftUI
@preconcurrency import WebKit
import UIKit
import UniformTypeIdentifiers

struct HealthPremiumDisplay: View {
    @State private var contentTitle: String = ""
    @State private var isLoading: Bool = true
    @State private var loadProgress: Double = 0.0
    let path: URL
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HealthContentWrapper(path: path, title: $contentTitle, isLoading: $isLoading, progress: $loadProgress)
                
                if isLoading {
                    VStack(spacing: 0) {
                        SwiftUI.ProgressView(value: loadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 2)
                            .padding(.horizontal, 0)
                            .tint(.red)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: isLoading)
                }
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: [.bottom, .horizontal])
    }
}

struct HealthNavigationBar: View {
    let title: String
    let goBack: () -> Void
    let refresh: () -> Void
    
    @ObservedObject private var contentProvider = HealthContentProvider.shared
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: refresh) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.white)
        .frame(height: 44)
    }
}

class HealthContentCoordinator: NSObject {
    static let shared = HealthContentCoordinator()
    
    weak var display: WKWebView?
    
    private override init() {
        super.init()
    }
    
    func goBack() {
        if let displayInstance = display, displayInstance.canGoBack {
            displayInstance.goBack()
        }
    }
    
    func refresh() {
        display?.reload()
    }
}

struct HealthContentWrapper: UIViewRepresentable {
    let path: URL
    @Binding var title: String
    @Binding var isLoading: Bool
    @Binding var progress: Double
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let dataStore = WKWebsiteDataStore.default()
        configuration.websiteDataStore = dataStore
        
        let processPool = WKProcessPool()
        configuration.processPool = processPool
        
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        if #available(iOS 14.0, *) {
            let pagePreferences = WKWebpagePreferences()
            pagePreferences.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = pagePreferences
        } else {
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            configuration.preferences = preferences
        }
        
        let displayInstance = WKWebView(frame: .zero, configuration: configuration)
        
        displayInstance.backgroundColor = UIColor.systemBackground
        displayInstance.isOpaque = true
        
        displayInstance.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(UIDevice.current.systemVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        
        if #available(iOS 14.0, *) {
            displayInstance.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        displayInstance.allowsBackForwardNavigationGestures = true
        displayInstance.allowsLinkPreview = false
        
        displayInstance.navigationDelegate = context.coordinator
        displayInstance.uiDelegate = context.coordinator
        
        HealthContentCoordinator.shared.display = displayInstance
        
        return displayInstance
    }
    
    func updateUIView(_ displayInstance: WKWebView, context: Context) {
        let service = HealthContentProvider.shared
        if service.refreshContent {
            displayInstance.reload()
            DispatchQueue.main.async {
                service.refreshContent = false
            }
            return
        }
        
        if context.coordinator.shouldLoadPath {
            let request = URLRequest(url: path)
            displayInstance.load(request)
            context.coordinator.shouldLoadPath = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: HealthContentWrapper
        var shouldLoadPath = true
        
        init(_ parent: HealthContentWrapper) {
            self.parent = parent
            super.init()
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            
            observeProgress(webView: webView)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.title") { (result, error) in
                if let title = result as? String {
                    DispatchQueue.main.async {
                        self.parent.title = title
                        self.parent.isLoading = false
                    }
                }
            }
            
            improveAuthentication(webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        private func observeProgress(webView: WKWebView) {
            let progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.progress = webView.estimatedProgress
                }
            }
            
            RunLoop.current.perform {
                objc_setAssociatedObject(webView, &AssociatedKeys.progressObservation, progressObservation, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        
        private func improveAuthentication(_ webView: WKWebView) {
            let windowOpenScript = """
            var originalOpen = window.open;
            window.open = function(url, name, features) {
                if (url && (url.indexOf('accounts.google.com') !== -1 || url.indexOf('accounts.youtube.com') !== -1)) {
                    window.location.href = url;
                    return null;
                }
                return originalOpen(url, name, features);
            };
            """
            
            let formFixScript = """
            document.addEventListener('click', function(e) {
                var target = e.target;
                if (target.tagName === 'BUTTON' || 
                    (target.tagName === 'INPUT' && (target.type === 'submit' || target.type === 'button'))) {
                    return true;
                }
            }, true);
            """
            
            webView.evaluateJavaScript(windowOpenScript, completionHandler: nil)
            webView.evaluateJavaScript(formFixScript, completionHandler: nil)
        }
        
        private struct AssociatedKeys {
            static var progressObservation = "progressObservation"
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler()
            }))
            
            presentController(alertController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if alertController.presentingViewController == nil {
                    completionHandler()
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(true)
            }))
            
            presentController(alertController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if alertController.presentingViewController == nil {
                    completionHandler(false)
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.text = defaultText
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(alertController.textFields?.first?.text)
            }))
            
            presentController(alertController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if alertController.presentingViewController == nil {
                    completionHandler(nil)
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let resourcePath = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let pathString = resourcePath.absoluteString
            
            if pathString.contains("accounts.google.com") || 
               pathString.contains("gstatic.com") || 
               pathString.contains("google.com") {
                
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    print("Health cookies count: \(cookies.count)")
                }
                
                decisionHandler(.allow)
                return
            }
            
            if navigationAction.navigationType == .other && 
               (pathString.contains("oauth") || pathString.contains("signin") || pathString.contains("accounts")) {
                decisionHandler(.allow)
                return
            }
            
            if navigationAction.navigationType == .linkActivated || 
               navigationAction.navigationType == .formSubmitted {
                decisionHandler(.allow)
                return
            }
            
            decisionHandler(.allow)
        }
        
        private func presentController(_ viewController: UIViewController) {
            if #available(iOS 15.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    if let alertController = viewController as? UIAlertController,
                       let popoverController = alertController.popoverPresentationController {
                        popoverController.sourceView = rootViewController.view
                        popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX, 
                                                              y: rootViewController.view.bounds.midY, 
                                                              width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    
                    rootViewController.present(viewController, animated: true)
                }
            } else {
                if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    if let alertController = viewController as? UIAlertController,
                       let popoverController = alertController.popoverPresentationController {
                        popoverController.sourceView = rootViewController.view
                        popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX, 
                                                              y: rootViewController.view.bounds.midY, 
                                                              width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    
                    rootViewController.present(viewController, animated: true)
                }
            }
        }
    }
}

