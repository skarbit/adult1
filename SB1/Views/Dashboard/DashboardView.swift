import SwiftUI

struct DashboardView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddReading = false
    @State private var selectedTimeRange: TimeRange = .today
    @State private var showingAddFood = false
    @State private var showingAddExercise = false
    @State private var showingAddMedication = false
    @State private var showingAnalytics = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    currentGlucoseCard
                        .bouncyCardEffect(delay: 0.1)
                    
                    quickStatsCard
                        .bouncyCardEffect(delay: 0.2)
                    
                    chartSection
                        .bouncyCardEffect(delay: 0.3)
                    
                    todaysReadingsSection
                        .bouncyCardEffect(delay: 0.4)
                    
                    quickActionsSection
                        .bouncyCardEffect(delay: 0.5)
                    
                    medicalResourcesSection
                        .bouncyCardEffect(delay: 0.6)
                }
                .padding()
            }
            .navigationTitle("My Sugar Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReading = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReading) {
            AddBloodSugarView()
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(selectedMealType: .breakfast)
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView()
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
        }
    }
    
    private var currentGlucoseCard: some View {
        VStack {
            if let latestReading = dataManager.bloodSugarReadings.first {
                VStack(spacing: 10) {
                    Text("Current Level")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("\(String(format: "%.1f", latestReading.value))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(glucoseColor(for: latestReading.status))
                        Text("mmol/L")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(latestReading.status.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(glucoseColor(for: latestReading.status).opacity(0.2))
                        )
                        .foregroundColor(glucoseColor(for: latestReading.status))
                    
                    Text("\(latestReading.mealTiming.rawValue) • \(latestReading.date, formatter: timeFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red.opacity(0.5))
                    Text("No readings yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + to add your first glucose reading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var quickStatsCard: some View {
        let todaysReadings = dataManager.getTodaysBloodSugarReadings()
        let inTargetCount = todaysReadings.filter { $0.isInTargetRange }.count
        let totalCount = todaysReadings.count
        let averageToday = totalCount > 0 ? todaysReadings.reduce(0) { $0 + $1.value } / Double(totalCount) : 0
        let targetPercentage = totalCount > 0 ? Double(inTargetCount) / Double(totalCount) : 0
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Today's Overview")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Readings",
                    value: "\(totalCount)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                StatItem(
                    title: "In Target",
                    value: "\(Int(targetPercentage * 100))%",
                    icon: "target",
                    color: .green
                )
                
                if averageToday > 0 {
                    StatItem(
                        title: "Average",
                        value: "\(String(format: "%.1f", averageToday))",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Glucose Trend")
                    .font(.headline)
                
                Spacer()
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    Text("Today").tag(TimeRange.today)
                    Text("Week").tag(TimeRange.week)
                    Text("Month").tag(TimeRange.month)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            GlucoseChartView(timeRange: selectedTimeRange)
                .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var todaysReadingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Readings")
                .font(.headline)
            
            let recentReadings = Array(dataManager.bloodSugarReadings.prefix(5))
            
            if recentReadings.isEmpty {
                Text("No readings recorded yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(recentReadings.enumerated()), id: \.element.id) { index, reading in
                    ReadingRowView(reading: reading)
                        .slideInEffect(delay: Double(index) * 0.1)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                QuickActionButton(
                    title: "Log Food",
                    icon: "fork.knife",
                    color: .orange
                ) {
                    showingAddFood = true
                }
                
                QuickActionButton(
                    title: "Add Exercise",
                    icon: "figure.run",
                    color: .blue
                ) {
                    showingAddExercise = true
                }
                
                QuickActionButton(
                    title: "Take Medication",
                    icon: "pills.fill",
                    color: .green
                ) {
                    showingAddMedication = true
                }
                
                QuickActionButton(
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    color: .purple
                ) {
                    showingAnalytics = true
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var medicalResourcesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "books.vertical.fill")
                    .foregroundColor(.blue)
                Text("Medical Resources")
                    .font(.headline)
            }
            
            VStack(spacing: 10) {
                Button(action: {
                    if let url = URL(string: "https://pmc.ncbi.nlm.nih.gov/articles/PMC4738200/") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("National Library of Medicine")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Research and medical information")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square.fill")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    if let url = URL(string: "https://www.health.harvard.edu/diseases-and-conditions/hemoglobin-a1c-hba1c-what-to-know-if-you-have-diabetes-or-prediabetes-or-are-at-risk-for-these-conditions") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Harvard Health Library")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("HbA1c and diabetes information")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square.fill")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func glucoseColor(for status: GlucoseStatus) -> Color {
        switch status {
        case .low, .high:
            return .red
        case .normal:
            return .green
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReadingRowView: View {
    let reading: BloodSugarReading
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(String(format: "%.1f", reading.value)) mmol/L")
                    .font(.headline)
                    .foregroundColor(glucoseColor(for: reading.status))
                
                Text(reading.mealTiming.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !reading.notes.isEmpty {
                    Text(reading.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(reading.date, formatter: timeFormatter)
                    .font(.subheadline)
                
                Text(reading.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func glucoseColor(for status: GlucoseStatus) -> Color {
        switch status {
        case .low, .high: return .red
        case .normal: return .green
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.quickSpring) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.quickSpring) {
                    isPressed = false
                }
            }
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isPressed ? 0.2 : 0.1))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.quickSpring, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum TimeRange: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

#Preview {
    DashboardView()
}
