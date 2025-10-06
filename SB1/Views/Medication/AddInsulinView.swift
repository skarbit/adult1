import SwiftUI

struct AddInsulinView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedInsulinType: InsulinType = .rapid
    @State private var units = ""
    @State private var selectedInjectionSite: InjectionSite = .abdomen
    @State private var selectedDate = Date()
    @State private var notes = ""
    @State private var relatedFoodEntry: FoodEntry?
    @State private var showingFoodPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Insulin Details")) {
                    Picker("Insulin Type", selection: $selectedInsulinType) {
                        ForEach(InsulinType.allCases, id: \.self) { type in
                            VStack(alignment: .leading) {
                                Text(type.rawValue)
                                if let description = insulinDescription(for: type) {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Units")
                        Spacer()
                        TextField("0", text: $units)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("u")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Injection Site", selection: $selectedInjectionSite) {
                        ForEach(InjectionSite.allCases, id: \.self) { site in
                            HStack {
                                Text(site.rawValue)
                                Spacer()
                                Text(absorptionSpeed(for: site))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(site)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Related to Food (Optional)")) {
                    if let relatedFood = relatedFoodEntry {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(relatedFood.name)
                                    .font(.subheadline)
                                Text("\(String(format: "%.1f", relatedFood.carbohydrates))g carbs • \(String(format: "%.1f", relatedFood.breadUnits)) BU")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Remove") {
                                relatedFoodEntry = nil
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    } else {
                        Button("Link to Food Entry") {
                            showingFoodPicker = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Add any notes about this injection...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let unitsValue = Double(units), unitsValue > 0 {
                    Section(header: Text("Injection Guide")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Best practices for \(selectedInjectionSite.rawValue.lowercased()) injection:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ForEach(injectionTips(for: selectedInjectionSite), id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(tip)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Insulin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInsulinEntry()
                    }
                    .disabled(units.isEmpty || Double(units) == nil || Double(units) ?? 0 <= 0)
                }
            }
        }
        .sheet(isPresented: $showingFoodPicker) {
            FoodPickerView { foodEntry in
                relatedFoodEntry = foodEntry
            }
        }
    }
    
    private func saveInsulinEntry() {
        guard let unitsValue = Double(units), unitsValue > 0 else { return }
        
        let entry = InsulinEntry(
            insulinType: selectedInsulinType,
            units: unitsValue,
            injectionSite: selectedInjectionSite,
            date: selectedDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            relatedFoodId: relatedFoodEntry?.id
        )
        
        dataManager.addInsulinEntry(entry)
        dismiss()
    }
    
    private func insulinDescription(for type: InsulinType) -> String? {
        switch type {
        case .rapid: return "Works in 15 min, peaks in 1-2 hours"
        case .short: return "Works in 30 min, peaks in 2-3 hours"
        case .intermediate: return "Works in 2-4 hours, peaks in 4-12 hours"
        case .long: return "Works in several hours, no peak"
        case .mixed: return "Combination of fast and slow acting"
        }
    }
    
    private func absorptionSpeed(for site: InjectionSite) -> String {
        switch site {
        case .abdomen: return "Fastest"
        case .arm: return "Medium"
        case .thigh: return "Slow"
        case .buttocks: return "Slowest"
        }
    }
    
    private func injectionTips(for site: InjectionSite) -> [String] {
        switch site {
        case .abdomen:
            return [
                "Stay 2 inches away from your navel",
                "Use the entire abdomen area",
                "Fastest absorption site"
            ]
        case .arm:
            return [
                "Use outer area of upper arm",
                "Have someone help you inject",
                "Medium absorption speed"
            ]
        case .thigh:
            return [
                "Use front and outer areas of thigh",
                "Avoid inner thigh and area above knee",
                "Slower absorption than abdomen"
            ]
        case .buttocks:
            return [
                "Use upper outer area only",
                "Have someone help you inject",
                "Slowest absorption site"
            ]
        }
    }
}

struct FoodPickerView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    let onSelect: (FoodEntry) -> Void
    
    private var recentFoodEntries: [FoodEntry] {
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        return dataManager.foodEntries.filter { $0.date >= threeDaysAgo }
    }
    
    var body: some View {
        NavigationView {
            List {
                if recentFoodEntries.isEmpty {
                    Text("No recent food entries")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(recentFoodEntries) { entry in
                        Button {
                            onSelect(entry)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(String(format: "%.1f", entry.carbohydrates))g carbs • \(String(format: "%.1f", entry.breadUnits)) BU")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(entry.date, formatter: dateTimeFormatter)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Select Food Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    AddInsulinView()
}
