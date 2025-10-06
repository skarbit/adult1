import SwiftUI

struct MedicationView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddMedication = false
    @State private var showingAddInsulin = false
    @State private var selectedMedicationTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Type", selection: $selectedMedicationTab) {
                    Text("Medications").tag(0)
                    Text("Insulin").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedMedicationTab) {
                    medicationsTab
                        .tag(0)
                    
                    insulinTab
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if selectedMedicationTab == 0 {
                            showingAddMedication = true
                        } else {
                            showingAddInsulin = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView()
        }
        .sheet(isPresented: $showingAddInsulin) {
            AddInsulinView()
        }
    }
    
    private var medicationsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                todaysMedicationsSection
                    .bouncyCardEffect(delay: 0.1)
                
                allMedicationsSection
                    .bouncyCardEffect(delay: 0.2)
                
                medicationTipsSection
                    .bouncyCardEffect(delay: 0.3)
            }
            .padding()
        }
    }
    
    private var insulinTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                todaysInsulinSection
                    .bouncyCardEffect(delay: 0.1)
                
                recentInsulinEntriesSection
                    .bouncyCardEffect(delay: 0.2)
                
                insulinTipsSection
                    .bouncyCardEffect(delay: 0.3)
            }
            .padding()
        }
    }
    
    private var todaysMedicationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Schedule")
                .font(.headline)
                .fontWeight(.semibold)
            
            let todaysMedEntries = getTodaysMedicationEntries()
            let activeMedications = dataManager.medications.filter { $0.isActive }
            
            if activeMedications.isEmpty {
                Text("No active medications")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(activeMedications) { medication in
                    MedicationScheduleCard(
                        medication: medication,
                        todaysEntries: todaysMedEntries.filter { $0.medicationId == medication.id }
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
    
    private var allMedicationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("All Medications")
                .font(.headline)
                .fontWeight(.semibold)
            
            if dataManager.medications.isEmpty {
                Text("No medications added")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(dataManager.medications) { medication in
                    MedicationRowView(medication: medication)
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
    
    private var todaysInsulinSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Insulin")
                .font(.headline)
                .fontWeight(.semibold)
            
            let todaysInsulin = getTodaysInsulinEntries()
            let totalUnits = todaysInsulin.reduce(0) { $0 + $1.units }
            
            HStack(spacing: 20) {
                InsulinStatView(
                    title: "Injections",
                    value: "\(todaysInsulin.count)",
                    icon: "syringe.fill",
                    color: .blue
                )
                
                InsulinStatView(
                    title: "Total Units",
                    value: "\(Int(totalUnits))",
                    icon: "drop.fill",
                    color: .green
                )
            }
            .padding(.bottom, 10)
            
            if todaysInsulin.isEmpty {
                Text("No insulin injections recorded today")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
            } else {
                ForEach(Array(todaysInsulin.prefix(5))) { entry in
                    InsulinRowView(entry: entry)
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
    
    private var recentInsulinEntriesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Insulin Entries")
                .font(.headline)
                .fontWeight(.semibold)
            
            let recentEntries = Array(dataManager.insulinEntries.prefix(10))
            
            if recentEntries.isEmpty {
                Text("No insulin entries recorded")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(recentEntries) { entry in
                    InsulinRowView(entry: entry)
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
    
    private var medicationTipsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Medication Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                MedicationTipView(
                    icon: "thermometer",
                    tip: "Store medications at room temperature, away from direct sunlight",
                    color: .orange
                )
                
                MedicationTipView(
                    icon: "clock.fill",
                    tip: "Take medications at the same time each day for better effectiveness",
                    color: .blue
                )
                
                MedicationTipView(
                    icon: "exclamationmark.triangle.fill",
                    tip: "Never skip doses. If you miss one, take it as soon as you remember",
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
    
    private var insulinTipsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Insulin Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                MedicationTipView(
                    icon: "snowflake",
                    tip: "Store unused insulin in the refrigerator. Current pen can be kept at room temperature for 4-6 weeks",
                    color: .cyan
                )
                
                MedicationTipView(
                    icon: "location.fill",
                    tip: "Rotate injection sites to prevent lipodystrophy. Use different areas each time",
                    color: .green
                )
                
                MedicationTipView(
                    icon: "syringe.fill",
                    tip: "Inject insulin into the abdomen for fastest absorption, thigh for slowest",
                    color: .purple
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
    
    private func getTodaysMedicationEntries() -> [MedicationEntry] {
        let calendar = Calendar.current
        let today = Date()
        return dataManager.medicationEntries.filter { calendar.isDate($0.takenDate, inSameDayAs: today) }
    }
    
    private func getTodaysInsulinEntries() -> [InsulinEntry] {
        let calendar = Calendar.current
        let today = Date()
        return dataManager.insulinEntries.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
}

struct MedicationScheduleCard: View {
    let medication: Medication
    let todaysEntries: [MedicationEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if medication.remainingQuantity <= medication.lowStockThreshold {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            Text("\(medication.type.rawValue) • \(medication.dosage)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !medication.schedule.isEmpty {
                HStack {
                    Text("Today's doses:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(medication.schedule) { schedule in
                        let isTaken = todaysEntries.contains { entry in
                            let calendar = Calendar.current
                            let scheduleHour = calendar.component(.hour, from: schedule.timeOfDay)
                            let entryHour = calendar.component(.hour, from: entry.takenDate)
                            return abs(scheduleHour - entryHour) <= 1
                        }
                        
                        Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isTaken ? .green : .secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct MedicationRowView: View {
    let medication: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(medication.type.rawValue) • \(medication.dosage)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if medication.remainingQuantity <= medication.lowStockThreshold {
                    Text("Low stock: \(String(format: "%.0f", medication.remainingQuantity)) remaining")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Circle()
                    .fill(medication.isActive ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(medication.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct InsulinStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InsulinRowView: View {
    let entry: InsulinEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(format: "%.0f", entry.units)) units")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text(entry.insulinType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(entry.injectionSite.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.date, formatter: timeFormatter)
                    .font(.caption)
                
                Text(entry.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MedicationTipView: View {
    let icon: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
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
    MedicationView()
}
