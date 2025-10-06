import SwiftUI

struct SettingsView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingEditProfile = false
    @State private var showingClearDataAlert = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            List {
                profileSection
                
                dataSection
                
                supportSection
                
                aboutSection
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All Data", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all your health data, including glucose readings, food entries, exercise logs, and medication records. This action cannot be undone.")
        }
    }
    
    private var profileSection: some View {
        Section(header: Text("Profile")) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Information")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if dataManager.userProfile.age > 0 {
                        Text("Age: \(dataManager.userProfile.age), \(dataManager.userProfile.diabetesType.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Edit") {
                    showingEditProfile = true
                }
                .foregroundColor(.blue)
            }
            
            HStack {
                Text("Target Glucose Ranges")
                    .font(.subheadline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Fasting: \(String(format: "%.1f", dataManager.userProfile.targetGlucoseFasting.lowerBound))-\(String(format: "%.1f", dataManager.userProfile.targetGlucoseFasting.upperBound))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("After meal: \(String(format: "%.1f", dataManager.userProfile.targetGlucoseAfterMeal.lowerBound))-\(String(format: "%.1f", dataManager.userProfile.targetGlucoseAfterMeal.upperBound))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var dataSection: some View {
        Section(header: Text("Data Management")) {
            NavigationLink(destination: DataOverviewView()) {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Data Overview")
                }
            }
            
            Button(action: { showingClearDataAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    Text("Clear All Data")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var supportSection: some View {
        Section(header: Text("Support")) {
            NavigationLink(destination: HealthTipsView()) {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                        .frame(width: 24)
                    Text("Health Tips")
                }
            }
            
            Button(action: {
                if let url = URL(string: "https://docs.proton.me/doc?mode=open-url&token=7AG3TAEQNM#Riadu4rvyVnK") {
                    openURL(url)
                }
            }) {
                HStack {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    Text("Privacy Policy")
                        .foregroundColor(.primary)
                }
            }
            
            Button(action: {
                if let url = URL(string: "https://drive.proton.me/urls/91VR255BX8#WoNBPnsTYBwG") {
                    openURL(url)
                }
            }) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    Text("Terms of Use")
                        .foregroundColor(.primary)
                }
            }
            
            Button(action: {
                if let url = URL(string: "https://form.jotform.com/252786104312048") {
                    openURL(url)
                }
            }) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Support")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("SugarBalance")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Your personal assistant for a balanced life. Track glucose levels, manage medications, log food intake, and maintain an active lifestyle.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Always consult with your healthcare provider for personalized medical advice.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func clearAllData() {
        dataManager.clearAllData()
    }
}

struct EditProfileView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var selectedDiabetesType: DiabetesType = .type1
    @State private var fastingMin: String = ""
    @State private var fastingMax: String = ""
    @State private var afterMealMin: String = ""
    @State private var afterMealMax: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    
                    Picker("Diabetes Type", selection: $selectedDiabetesType) {
                        ForEach(DiabetesType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Target Glucose Ranges (mmol/L)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fasting Glucose")
                            .font(.subheadline)
                        HStack {
                            TextField("Min", text: $fastingMin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            Text("to")
                            TextField("Max", text: $fastingMax)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("After Meal Glucose")
                            .font(.subheadline)
                        HStack {
                            TextField("Min", text: $afterMealMin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            Text("to")
                            TextField("Max", text: $afterMealMax)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private var isFormValid: Bool {
        !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
        !fastingMin.isEmpty && !fastingMax.isEmpty &&
        !afterMealMin.isEmpty && !afterMealMax.isEmpty &&
        Int(age) != nil && Double(height) != nil && Double(weight) != nil &&
        Double(fastingMin) != nil && Double(fastingMax) != nil &&
        Double(afterMealMin) != nil && Double(afterMealMax) != nil
    }
    
    private func loadCurrentProfile() {
        age = "\(dataManager.userProfile.age)"
        height = "\(dataManager.userProfile.height)"
        weight = "\(dataManager.userProfile.weight)"
        selectedDiabetesType = dataManager.userProfile.diabetesType
        fastingMin = "\(dataManager.userProfile.targetGlucoseFasting.lowerBound)"
        fastingMax = "\(dataManager.userProfile.targetGlucoseFasting.upperBound)"
        afterMealMin = "\(dataManager.userProfile.targetGlucoseAfterMeal.lowerBound)"
        afterMealMax = "\(dataManager.userProfile.targetGlucoseAfterMeal.upperBound)"
    }
    
    private func saveProfile() {
        guard let ageValue = Int(age),
              let heightValue = Double(height),
              let weightValue = Double(weight),
              let fMin = Double(fastingMin),
              let fMax = Double(fastingMax),
              let aMin = Double(afterMealMin),
              let aMax = Double(afterMealMax) else {
            return
        }
        
        dataManager.userProfile.age = ageValue
        dataManager.userProfile.height = heightValue
        dataManager.userProfile.weight = weightValue
        dataManager.userProfile.diabetesType = selectedDiabetesType
        dataManager.userProfile.targetGlucoseFasting = fMin...fMax
        dataManager.userProfile.targetGlucoseAfterMeal = aMin...aMax
        
        dataManager.saveUserProfile()
        dismiss()
    }
}

struct DataOverviewView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        List {
            Section(header: Text("Data Summary")) {
                DataRowView(
                    title: "Glucose Readings",
                    count: dataManager.bloodSugarReadings.count,
                    icon: "drop.fill",
                    color: .red
                )
                
                DataRowView(
                    title: "Food Entries",
                    count: dataManager.foodEntries.count,
                    icon: "fork.knife",
                    color: .orange
                )
                
                DataRowView(
                    title: "Exercise Sessions",
                    count: dataManager.exerciseEntries.count,
                    icon: "figure.run",
                    color: .blue
                )
                
                DataRowView(
                    title: "Medications",
                    count: dataManager.medications.count,
                    icon: "pills.fill",
                    color: .green
                )
                
                DataRowView(
                    title: "Insulin Entries",
                    count: dataManager.insulinEntries.count,
                    icon: "syringe.fill",
                    color: .purple
                )
            }
            
            Section(header: Text("Storage Information")) {
                Text("All your health data is stored locally on your device and is not shared with any third parties.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .navigationTitle("Data Overview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataRowView: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text("\(count)")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
}
