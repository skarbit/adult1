
import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
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
        .environmentObject(dataManager)
    }
}

#Preview {
    ContentView()
}
