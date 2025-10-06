import SwiftUI

struct TrendAnalysisView: View {
    @ObservedObject private var dataManager = DataManager.shared
    let period: AnalyticsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            let analysis = getTrendAnalysis()
            
            if analysis.isEmpty {
                Text("Not enough data for trend analysis")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(analysis, id: \.title) { trend in
                    TrendItemView(trend: trend)
                }
            }
        }
    }
    
    private func getTrendAnalysis() -> [TrendItem] {
        let readings = getReadingsForPeriod()
        guard readings.count > 7 else { return [] }
        
        var trends: [TrendItem] = []
        
        trends.append(contentsOf: getGlucoseTrends(readings))
        trends.append(contentsOf: getMealTimingTrends(readings))
        trends.append(contentsOf: getExerciseCorrelations())
        
        return trends
    }
    
    private func getReadingsForPeriod() -> [BloodSugarReading] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return dataManager.bloodSugarReadings.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }
    
    private func getGlucoseTrends(_ readings: [BloodSugarReading]) -> [TrendItem] {
        var trends: [TrendItem] = []
        
        let fastingReadings = readings.filter { $0.mealTiming == .fasting }
        let afterMealReadings = readings.filter { $0.mealTiming == .afterMeal }
        
        if fastingReadings.count >= 5 {
            let recentFasting = Array(fastingReadings.suffix(5))
            let earlierFasting = Array(fastingReadings.prefix(5))
            
            let recentAverage = recentFasting.reduce(0) { $0 + $1.value } / Double(recentFasting.count)
            let earlierAverage = earlierFasting.reduce(0) { $0 + $1.value } / Double(earlierFasting.count)
            
            let change = recentAverage - earlierAverage
            let percentChange = (change / earlierAverage) * 100
            
            if abs(percentChange) > 5 {
                trends.append(TrendItem(
                    title: "Fasting Glucose Trend",
                    description: change > 0 ? 
                        "Your fasting glucose has increased by \(String(format: "%.1f", abs(percentChange)))% recently" :
                        "Your fasting glucose has improved by \(String(format: "%.1f", abs(percentChange)))% recently",
                    type: change > 0 ? .warning : .positive,
                    icon: change > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                ))
            }
        }
        
        if afterMealReadings.count >= 10 {
            let highAfterMealCount = afterMealReadings.filter { $0.status == .high }.count
            let highPercentage = Double(highAfterMealCount) / Double(afterMealReadings.count) * 100
            
            if highPercentage > 30 {
                trends.append(TrendItem(
                    title: "Post-Meal Spikes",
                    description: "\(String(format: "%.0f", highPercentage))% of your post-meal readings are high. Consider reviewing your meal choices.",
                    type: .warning,
                    icon: "exclamationmark.triangle.fill"
                ))
            }
        }
        
        return trends
    }
    
    private func getMealTimingTrends(_ readings: [BloodSugarReading]) -> [TrendItem] {
        var trends: [TrendItem] = []
        
        let calendar = Calendar.current
        let morningReadings = readings.filter { 
            let hour = calendar.component(.hour, from: $0.date)
            return hour >= 6 && hour < 12
        }
        
        let eveningReadings = readings.filter {
            let hour = calendar.component(.hour, from: $0.date)
            return hour >= 18 && hour <= 23
        }
        
        if morningReadings.count >= 5 && eveningReadings.count >= 5 {
            let morningAverage = morningReadings.reduce(0) { $0 + $1.value } / Double(morningReadings.count)
            let eveningAverage = eveningReadings.reduce(0) { $0 + $1.value } / Double(eveningReadings.count)
            
            if eveningAverage > morningAverage * 1.2 {
                trends.append(TrendItem(
                    title: "Evening Pattern",
                    description: "Your glucose tends to be higher in the evening. Consider lighter dinners or post-dinner walks.",
                    type: .info,
                    icon: "moon.stars.fill"
                ))
            }
        }
        
        return trends
    }
    
    private func getExerciseCorrelations() -> [TrendItem] {
        var trends: [TrendItem] = []
        
        let calendar = Calendar.current
        let exerciseDays = Set(dataManager.exerciseEntries.map { calendar.startOfDay(for: $0.date) })
        let readingDays = Dictionary(grouping: dataManager.bloodSugarReadings) { calendar.startOfDay(for: $0.date) }
        
        var exerciseDayAverages: [Double] = []
        var nonExerciseDayAverages: [Double] = []
        
        for (day, readings) in readingDays {
            let dayAverage = readings.reduce(0) { $0 + $1.value } / Double(readings.count)
            
            if exerciseDays.contains(day) {
                exerciseDayAverages.append(dayAverage)
            } else {
                nonExerciseDayAverages.append(dayAverage)
            }
        }
        
        if exerciseDayAverages.count >= 3 && nonExerciseDayAverages.count >= 3 {
            let exerciseAverage = exerciseDayAverages.reduce(0, +) / Double(exerciseDayAverages.count)
            let nonExerciseAverage = nonExerciseDayAverages.reduce(0, +) / Double(nonExerciseDayAverages.count)
            
            if nonExerciseAverage > exerciseAverage * 1.1 {
                trends.append(TrendItem(
                    title: "Exercise Impact",
                    description: "Your glucose levels are typically \(String(format: "%.0f", ((nonExerciseAverage - exerciseAverage) / exerciseAverage * 100)))% lower on days with exercise.",
                    type: .positive,
                    icon: "figure.run.circle.fill"
                ))
            }
        }
        
        return trends
    }
}

struct TrendItem {
    let title: String
    let description: String
    let type: TrendType
    let icon: String
}

enum TrendType {
    case positive
    case warning
    case info
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

struct TrendItemView: View {
    let trend: TrendItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: trend.icon)
                .font(.title3)
                .foregroundColor(trend.type.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trend.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(trend.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(trend.type.color.opacity(0.1))
        )
    }
}

#Preview {
    TrendAnalysisView(period: .week)
}
