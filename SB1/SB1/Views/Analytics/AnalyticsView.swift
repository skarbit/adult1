import SwiftUI

struct AnalyticsView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedPeriod: AnalyticsPeriod = .week
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    periodSelector
                        .fadeInEffect(delay: 0.1)
                    
                    hbA1cSection
                        .bouncyCardEffect(delay: 0.2)
                    
                    glucoseStatisticsSection
                        .bouncyCardEffect(delay: 0.3)
                    
                    timeInRangeSection
                        .bouncyCardEffect(delay: 0.4)
                    
                    trendsSection
                        .bouncyCardEffect(delay: 0.5)
                    
                    achievementsSection
                        .bouncyCardEffect(delay: 0.6)
                }
                .padding()
            }
            .navigationTitle("Health Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportReportView(period: selectedPeriod)
        }
    }
    
    private var periodSelector: some View {
        VStack {
            Text("Time Period")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("Period", selection: $selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var hbA1cSection: some View {
        let estimatedHbA1c = dataManager.getHbA1cEstimate()
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("HbA1c Estimate")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Estimated HbA1c")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("\(String(format: "%.1f", estimatedHbA1c))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(hbA1cColor(estimatedHbA1c))
                            Text("%")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Target: < 7.0%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(hbA1cStatus(estimatedHbA1c))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(hbA1cColor(estimatedHbA1c).opacity(0.2))
                            )
                            .foregroundColor(hbA1cColor(estimatedHbA1c))
                    }
                }
                
                Text("Based on average glucose over the last 90 days. This is an estimate - consult your doctor for actual HbA1c testing.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var glucoseStatisticsSection: some View {
        let readings = getReadingsForPeriod()
        let averageGlucose = readings.isEmpty ? 0 : readings.reduce(0) { $0 + $1.value } / Double(readings.count)
        let highReadings = readings.filter { $0.status == .high }.count
        let lowReadings = readings.filter { $0.status == .low }.count
        let normalReadings = readings.filter { $0.status == .normal }.count
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Glucose Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatisticItem(
                    title: "Average",
                    value: "\(String(format: "%.1f", averageGlucose))",
                    unit: "mmol/L",
                    color: .blue
                )
                
                StatisticItem(
                    title: "Readings",
                    value: "\(readings.count)",
                    unit: "total",
                    color: .green
                )
            }
            
            HStack(spacing: 15) {
                StatusCount(
                    title: "Low",
                    count: lowReadings,
                    total: readings.count,
                    color: .red
                )
                
                StatusCount(
                    title: "Normal",
                    count: normalReadings,
                    total: readings.count,
                    color: .green
                )
                
                StatusCount(
                    title: "High",
                    count: highReadings,
                    total: readings.count,
                    color: .red
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var timeInRangeSection: some View {
        let readings = getReadingsForPeriod()
        let inRangeCount = readings.filter { $0.isInTargetRange }.count
        let timeInRangePercentage = readings.isEmpty ? 0 : Double(inRangeCount) / Double(readings.count) * 100
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Time in Range")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Time in Target Range")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("\(String(format: "%.0f", timeInRangePercentage))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(timeInRangeColor(timeInRangePercentage))
                            Text("%")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    CircularProgressView(
                        percentage: timeInRangePercentage,
                        color: timeInRangeColor(timeInRangePercentage)
                    )
                }
                
                ProgressView(value: timeInRangePercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: timeInRangeColor(timeInRangePercentage)))
                
                Text("Target: > 70% time in range for optimal glucose control")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Trends & Patterns")
                .font(.headline)
                .fontWeight(.semibold)
            
            TrendAnalysisView(period: selectedPeriod)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AchievementBadge(
                    title: "Consistent Logger",
                    description: "7 days of glucose tracking",
                    isEarned: hasConsistentLogging(),
                    icon: "calendar.badge.checkmark"
                )
                
                AchievementBadge(
                    title: "In Target",
                    description: "70% time in range this week",
                    isEarned: hasGoodTimeInRange(),
                    icon: "target"
                )
                
                AchievementBadge(
                    title: "Exercise Champion",
                    description: "5 workouts this week",
                    isEarned: hasRegularExercise(),
                    icon: "figure.run.circle"
                )
                
                AchievementBadge(
                    title: "Meal Planner",
                    description: "Logged all meals for 3 days",
                    isEarned: hasConsistentMealLogging(),
                    icon: "fork.knife.circle"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func getReadingsForPeriod() -> [BloodSugarReading] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return dataManager.bloodSugarReadings.filter { $0.date >= startDate }
    }
    
    private func hbA1cColor(_ value: Double) -> Color {
        if value <= 7.0 { return .green }
        else if value <= 8.0 { return .orange }
        else { return .red }
    }
    
    private func hbA1cStatus(_ value: Double) -> String {
        if value <= 7.0 { return "Excellent" }
        else if value <= 8.0 { return "Good" }
        else { return "Needs Attention" }
    }
    
    private func timeInRangeColor(_ percentage: Double) -> Color {
        if percentage >= 70 { return .green }
        else if percentage >= 50 { return .orange }
        else { return .red }
    }
    
    private func hasConsistentLogging() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        let readings = dataManager.bloodSugarReadings.filter { $0.date >= weekAgo }
        
        let daysWithReadings = Set(readings.map { calendar.startOfDay(for: $0.date) })
        return daysWithReadings.count >= 7
    }
    
    private func hasGoodTimeInRange() -> Bool {
        let readings = getReadingsForPeriod()
        guard !readings.isEmpty else { return false }
        
        let inRangeCount = readings.filter { $0.isInTargetRange }.count
        let percentage = Double(inRangeCount) / Double(readings.count) * 100
        return percentage >= 70
    }
    
    private func hasRegularExercise() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        let exercises = dataManager.exerciseEntries.filter { $0.date >= weekAgo }
        return exercises.count >= 5
    }
    
    private func hasConsistentMealLogging() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        let foodEntries = dataManager.foodEntries.filter { $0.date >= threeDaysAgo }
        
        let daysWithMeals = Set(foodEntries.map { calendar.startOfDay(for: $0.date) })
        return daysWithMeals.count >= 3
    }
}

enum AnalyticsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month" 
    case threeMonths = "3 Months"
    
    var displayName: String {
        return self.rawValue
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatusCount: View {
    let title: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        total == 0 ? 0 : Double(count) / Double(total) * 100
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text("(\(String(format: "%.0f", percentage))%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct CircularProgressView: View {
    let percentage: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: percentage / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: percentage)
        }
    }
}

struct AchievementBadge: View {
    let title: String
    let description: String
    let isEarned: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEarned ? .yellow : .gray)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isEarned ? Color.yellow.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEarned ? Color.yellow : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    AnalyticsView()
}
