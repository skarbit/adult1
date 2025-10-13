
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var contentProvider: HealthContentProvider
    
    var body: some View {
        Group {
            if !dataManager.userProfile.disclaimerAccepted {
                DisclaimerView()
            } else if dataManager.userProfile.isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            if contentProvider.shouldShowPremiumContent() {
                contentProvider.checkContentAvailability { _ in }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
        .environmentObject(HealthContentProvider.shared)
}
