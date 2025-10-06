import SwiftUI

struct ExportReportView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    let period: AnalyticsPeriod
    
    @State private var includeGlucoseData = true
    @State private var includeFoodData = true
    @State private var includeExerciseData = true
    @State private var includeMedicationData = true
    @State private var reportFormat: ReportFormat = .pdf
    @State private var showingShareSheet = false
    @State private var reportURL: URL?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Report Period")) {
                    HStack {
                        Text("Period")
                        Spacer()
                        Text(period.displayName)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Include Data")) {
                    Toggle("Glucose Readings", isOn: $includeGlucoseData)
                    Toggle("Food Diary", isOn: $includeFoodData)
                    Toggle("Exercise Log", isOn: $includeExerciseData)
                    Toggle("Medication Records", isOn: $includeMedicationData)
                }
                
                Section(header: Text("Format")) {
                    Picker("Format", selection: $reportFormat) {
                        Text("PDF Report").tag(ReportFormat.pdf)
                        Text("CSV Data").tag(ReportFormat.csv)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Report Summary")) {
                    let summary = getReportSummary()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if includeGlucoseData {
                            HStack {
                                Text("Glucose readings:")
                                Spacer()
                                Text("\(summary.glucoseCount)")
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if includeFoodData {
                            HStack {
                                Text("Food entries:")
                                Spacer()
                                Text("\(summary.foodCount)")
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if includeExerciseData {
                            HStack {
                                Text("Exercise sessions:")
                                Spacer()
                                Text("\(summary.exerciseCount)")
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if includeMedicationData {
                            HStack {
                                Text("Medication entries:")
                                Spacer()
                                Text("\(summary.medicationCount)")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Generate Report") {
                        generateReport()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!hasSelectedData)
                }
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = reportURL {
                ActivityView(activityItems: [url])
            }
        }
    }
    
    private var hasSelectedData: Bool {
        includeGlucoseData || includeFoodData || includeExerciseData || includeMedicationData
    }
    
    private func getReportSummary() -> ReportSummary {
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
        
        let glucoseCount = dataManager.bloodSugarReadings.filter { $0.date >= startDate }.count
        let foodCount = dataManager.foodEntries.filter { $0.date >= startDate }.count
        let exerciseCount = dataManager.exerciseEntries.filter { $0.date >= startDate }.count
        let medicationCount = dataManager.medicationEntries.filter { $0.takenDate >= startDate }.count
        
        return ReportSummary(
            glucoseCount: glucoseCount,
            foodCount: foodCount,
            exerciseCount: exerciseCount,
            medicationCount: medicationCount
        )
    }
    
    private func generateReport() {
        let reportGenerator = ReportGenerator(dataManager: dataManager)
        
        let reportData = ReportData(
            period: period,
            includeGlucose: includeGlucoseData,
            includeFood: includeFoodData,
            includeExercise: includeExerciseData,
            includeMedication: includeMedicationData,
            format: reportFormat
        )
        
        Task {
            do {
                let url = try await reportGenerator.generateReport(reportData)
                DispatchQueue.main.async {
                    self.reportURL = url
                    self.showingShareSheet = true
                }
            } catch {
                print("Failed to generate report: \(error)")
            }
        }
    }
}

struct ReportSummary {
    let glucoseCount: Int
    let foodCount: Int
    let exerciseCount: Int
    let medicationCount: Int
}

struct ReportData {
    let period: AnalyticsPeriod
    let includeGlucose: Bool
    let includeFood: Bool
    let includeExercise: Bool
    let includeMedication: Bool
    let format: ReportFormat
}

enum ReportFormat {
    case pdf
    case csv
}

class ReportGenerator {
    let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func generateReport(_ reportData: ReportData) async throws -> URL {
        switch reportData.format {
        case .pdf:
            return try generatePDFReport(reportData)
        case .csv:
            return try generateCSVReport(reportData)
        }
    }
    
    private func generatePDFReport(_ reportData: ReportData) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "SugarBalance_Report_\(Date().formatted(.iso8601.year().month().day())).pdf"
        let url = documentsPath.appendingPathComponent(fileName)
        
        var content = "SugarBalance Health Report\n"
        content += "Generated: \(Date().formatted())\n"
        content += "Period: \(reportData.period.displayName)\n\n"
        
        if reportData.includeGlucose {
            content += generateGlucoseSection()
        }
        
        if reportData.includeFood {
            content += generateFoodSection()
        }
        
        if reportData.includeExercise {
            content += generateExerciseSection()
        }
        
        if reportData.includeMedication {
            content += generateMedicationSection()
        }
        
        try content.write(to: url, atomically: true, encoding: .utf8)
        
        return url
    }
    
    private func generateCSVReport(_ reportData: ReportData) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "SugarBalance_Data_\(Date().formatted(.iso8601.year().month().day())).csv"
        let url = documentsPath.appendingPathComponent(fileName)
        
        var csvContent = ""
        
        if reportData.includeGlucose {
            csvContent += "Date,Time,Glucose (mmol/L),Timing,Notes\n"
            for reading in dataManager.bloodSugarReadings {
                let dateString = reading.date.formatted(.iso8601.year().month().day())
                let timeString = reading.date.formatted(.dateTime.hour().minute())
                csvContent += "\(dateString),\(timeString),\(reading.value),\(reading.mealTiming.rawValue),\"\(reading.notes)\"\n"
            }
            csvContent += "\n"
        }
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
        
        return url
    }
    
    private func generateGlucoseSection() -> String {
        var section = "GLUCOSE READINGS\n"
        section += "================\n\n"
        
        let readings = dataManager.bloodSugarReadings
        if readings.isEmpty {
            section += "No glucose readings recorded.\n\n"
        } else {
            let average = readings.reduce(0) { $0 + $1.value } / Double(readings.count)
            let inRange = readings.filter { $0.isInTargetRange }.count
            let percentage = Double(inRange) / Double(readings.count) * 100
            
            section += "Total Readings: \(readings.count)\n"
            section += "Average Glucose: \(String(format: "%.1f", average)) mmol/L\n"
            section += "Time in Range: \(String(format: "%.0f", percentage))%\n"
            section += "HbA1c Estimate: \(String(format: "%.1f", dataManager.getHbA1cEstimate()))%\n\n"
        }
        
        return section
    }
    
    private func generateFoodSection() -> String {
        var section = "FOOD DIARY\n"
        section += "==========\n\n"
        
        let foods = dataManager.foodEntries
        if foods.isEmpty {
            section += "No food entries recorded.\n\n"
        } else {
            let totalCarbs = foods.reduce(0) { $0 + $1.carbohydrates }
            let totalCalories = foods.reduce(0) { $0 + $1.calories }
            let averageCarbs = totalCarbs / Double(foods.count)
            
            section += "Total Entries: \(foods.count)\n"
            section += "Average Carbs per Entry: \(String(format: "%.1f", averageCarbs))g\n"
            section += "Total Calories: \(String(format: "%.0f", totalCalories))\n\n"
        }
        
        return section
    }
    
    private func generateExerciseSection() -> String {
        var section = "EXERCISE LOG\n"
        section += "============\n\n"
        
        let exercises = dataManager.exerciseEntries
        if exercises.isEmpty {
            section += "No exercise entries recorded.\n\n"
        } else {
            let totalDuration = exercises.reduce(0) { $0 + $1.duration }
            let totalCalories = exercises.reduce(0) { $0 + $1.caloriesBurned }
            let hours = totalDuration / 3600
            
            section += "Total Sessions: \(exercises.count)\n"
            section += "Total Duration: \(String(format: "%.1f", hours)) hours\n"
            section += "Calories Burned: \(String(format: "%.0f", totalCalories))\n\n"
        }
        
        return section
    }
    
    private func generateMedicationSection() -> String {
        var section = "MEDICATION RECORDS\n"
        section += "==================\n\n"
        
        let medications = dataManager.medications.filter { $0.isActive }
        if medications.isEmpty {
            section += "No active medications recorded.\n\n"
        } else {
            section += "Active Medications: \(medications.count)\n"
            for med in medications {
                section += "- \(med.name) (\(med.type.rawValue)) - \(med.dosage)\n"
            }
            section += "\n"
        }
        
        return section
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportReportView(period: .week)
}
