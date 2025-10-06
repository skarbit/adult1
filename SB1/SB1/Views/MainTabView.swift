import SwiftUI

struct MainTabView: View {
    @State private var selectedMainTab = 0
    
    var body: some View {
        TabView(selection: $selectedMainTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("My Sugar")
                }
                .tag(0)
            
            FoodDiaryView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Food Diary")
                }
                .tag(1)
            
            FitnessView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Fitness")
                }
                .tag(2)
            
            MedicationView()
                .tabItem {
                    Image(systemName: "pills.fill")
                    Text("Medications")
                }
                .tag(3)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(5)
        }
        .accentColor(.red)
    }
}

#Preview {
    MainTabView()
}
