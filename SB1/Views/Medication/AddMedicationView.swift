import SwiftUI

struct AddMedicationView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var medicationName = ""
    @State private var selectedType: MedicationType = .metformin
    @State private var dosage = ""
    @State private var remainingQuantity = ""
    @State private var lowStockThreshold = ""
    @State private var schedules: [MedicationSchedule] = []
    @State private var showingAddSchedule = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication name", text: $medicationName)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(MedicationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Dosage (e.g., 500mg, 10ml)", text: $dosage)
                }
                
                Section(header: Text("Inventory")) {
                    HStack {
                        Text("Remaining Quantity")
                        Spacer()
                        TextField("30", text: $remainingQuantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("pills/ml")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Low Stock Alert")
                        Spacer()
                        TextField("5", text: $lowStockThreshold)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("pills/ml")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Schedule")) {
                    ForEach(schedules) { schedule in
                        ScheduleRowView(schedule: schedule) {
                            schedules.removeAll { $0.id == schedule.id }
                        }
                    }
                    
                    Button("Add Schedule") {
                        showingAddSchedule = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showingAddSchedule) {
            AddScheduleView { schedule in
                schedules.append(schedule)
            }
        }
    }
    
    private var isFormValid: Bool {
        !medicationName.isEmpty &&
        !dosage.isEmpty &&
        !remainingQuantity.isEmpty &&
        !lowStockThreshold.isEmpty &&
        Double(remainingQuantity) != nil &&
        Double(lowStockThreshold) != nil
    }
    
    private func saveMedication() {
        guard let remaining = Double(remainingQuantity),
              let threshold = Double(lowStockThreshold) else {
            return
        }
        
        let medication = Medication(
            name: medicationName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType,
            dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines),
            schedule: schedules,
            remainingQuantity: remaining,
            lowStockThreshold: threshold,
            isActive: true
        )
        
        dataManager.addMedication(medication)
        dismiss()
    }
}

struct AddScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (MedicationSchedule) -> Void
    
    @State private var selectedTime = Date()
    @State private var scheduleDosage = ""
    @State private var isEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Schedule Details")) {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    TextField("Dosage for this time", text: $scheduleDosage)
                    
                    Toggle("Enabled", isOn: $isEnabled)
                }
            }
            .navigationTitle("Add Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let schedule = MedicationSchedule(
                            timeOfDay: selectedTime,
                            dosage: scheduleDosage.trimmingCharacters(in: .whitespacesAndNewlines),
                            isEnabled: isEnabled
                        )
                        onSave(schedule)
                        dismiss()
                    }
                    .disabled(scheduleDosage.isEmpty)
                }
            }
        }
    }
}

struct ScheduleRowView: View {
    let schedule: MedicationSchedule
    let onDelete: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeFormatter.string(from: schedule.timeOfDay))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(schedule.dosage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if schedule.isEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.orange)
            }
            
            Button("Delete") {
                onDelete()
            }
            .foregroundColor(.red)
            .font(.caption)
        }
    }
}

#Preview {
    AddMedicationView()
}
