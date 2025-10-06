import SwiftUI

struct AddBloodSugarView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var glucoseValue: String = ""
    @State private var selectedMealTiming: MealTiming = .fasting
    @State private var selectedDate = Date()
    @State private var notes: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Glucose Reading")) {
                    HStack {
                        Text("Value")
                        Spacer()
                        TextField("0.0", text: $glucoseValue)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("mmol/L")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Timing", selection: $selectedMealTiming) {
                        ForEach(MealTiming.allCases, id: \.self) { timing in
                            Text(timing.rawValue).tag(timing)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Add any notes about this reading...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let value = Double(glucoseValue), value > 0 {
                    Section {
                        let reading = BloodSugarReading(
                            value: value,
                            date: selectedDate,
                            mealTiming: selectedMealTiming,
                            notes: notes
                        )
                        
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(reading.status.rawValue)
                                .foregroundColor(glucoseColor(for: reading.status))
                                .fontWeight(.medium)
                        }
                        
                        if !reading.isInTargetRange {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Outside target range")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReading()
                    }
                    .disabled(glucoseValue.isEmpty || Double(glucoseValue) == nil)
                }
            }
        }
        .alert("Invalid Value", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("Please enter a valid glucose value.")
        }
    }
    
    private func saveReading() {
        guard let value = Double(glucoseValue), value > 0 else {
            showingAlert = true
            return
        }
        
        let reading = BloodSugarReading(
            value: value,
            date: selectedDate,
            mealTiming: selectedMealTiming,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addBloodSugarReading(reading)
        
        dismiss()
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

#Preview {
    AddBloodSugarView()
}
