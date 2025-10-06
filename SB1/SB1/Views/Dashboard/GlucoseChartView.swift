import SwiftUI
import Charts

struct GlucoseChartView: View {
    @ObservedObject private var dataManager = DataManager.shared
    let timeRange: TimeRange
    
    private var filteredReadings: [BloodSugarReading] {
        let calendar = Calendar.current
        let now = Date()
        let readings = dataManager.bloodSugarReadings
        
        switch timeRange {
        case .today:
            return readings.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return readings.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return readings.filter { $0.date >= monthAgo }
        }
    }
    
    var body: some View {
        if filteredReadings.isEmpty {
            VStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                Text("No data for this period")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(filteredReadings.sorted { $0.date < $1.date }) { reading in
                LineMark(
                    x: .value("Time", reading.date),
                    y: .value("Glucose", reading.value)
                )
                .foregroundStyle(colorForReading(reading))
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("Time", reading.date),
                    y: .value("Glucose", reading.value)
                )
                .foregroundStyle(colorForReading(reading))
                .symbolSize(30)
            }
            .chartYScale(domain: 0...25)
            .chartXAxis {
                AxisMarks(values: .stride(by: xAxisStride)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: xAxisFormat)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
    }
    
    private func colorForReading(_ reading: BloodSugarReading) -> Color {
        switch reading.status {
        case .low, .high: return .red
        case .normal: return .green
        }
    }
    
    private var xAxisStride: Calendar.Component {
        switch timeRange {
        case .today: return .hour
        case .week: return .day
        case .month: return .weekOfYear
        }
    }
    
    private var xAxisFormat: Date.FormatStyle {
        switch timeRange {
        case .today:
            return .dateTime.hour()
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        }
    }
}

#Preview {
    GlucoseChartView(timeRange: .week)
        .frame(height: 200)
        .padding()
}
