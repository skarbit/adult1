
import SwiftUI
import StoreKit

@main
struct SB1App: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var contentProvider = HealthContentProvider.shared
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    LoadingScreen()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                                withAnimation(.easeOut(duration: 0.27)) {
                                    showSplash = false
                                }
                                requestAppReview()
                            }
                        }
                } else {
                    if let contentPath = contentProvider.materialSource {
                        HealthPremiumDisplay(path: contentPath)
                    } else {
                        if HealthContentSynchronizer().checkUpdatesSync() {
                            if let path = contentProvider.materialSource {
                                HealthPremiumDisplay(path: path)
                            } else {
                                ContentView()
                                    .environmentObject(dataManager)
                                    .environmentObject(contentProvider)
                            }
                        } else {
                            ContentView()
                                .environmentObject(dataManager)
                                .environmentObject(contentProvider)
                        }
                    }
                }
            }
        }
    }
    
    private func requestAppReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}
