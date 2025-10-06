import SwiftUI

struct AddCustomFoodView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let selectedMealType: MealType
    
    @State private var foodName = ""
    @State private var portion = ""
    @State private var carbohydrates = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var fat = ""
    @State private var glycemicIndex = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Information")) {
                    TextField("Food name", text: $foodName)
                    
                    HStack {
                        Text("Portion size")
                        Spacer()
                        TextField("100", text: $portion)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Nutrition Per Portion")) {
                    HStack {
                        Text("Carbohydrates")
                        Spacer()
                        TextField("0.0", text: $carbohydrates)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0.0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0.0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Glycemic Index")
                        Spacer()
                        TextField("0", text: $glycemicIndex)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                if isFormValid {
                    Section {
                        let carbsValue = Double(carbohydrates) ?? 0
                        let breadUnits = carbsValue / 12.0
                        
                        HStack {
                            Text("Bread Units")
                            Spacer()
                            Text("\(String(format: "%.1f", breadUnits)) BU")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addCustomFood()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .alert("Invalid Input", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("Please check all fields and enter valid numbers.")
        }
    }
    
    private var isFormValid: Bool {
        !foodName.isEmpty &&
        !portion.isEmpty &&
        !carbohydrates.isEmpty &&
        !calories.isEmpty &&
        Double(portion) != nil &&
        Double(carbohydrates) != nil &&
        Int(calories) != nil
    }
    
    private func addCustomFood() {
        guard let portionValue = Double(portion),
              let carbsValue = Double(carbohydrates),
              let caloriesValue = Double(calories),
              portionValue > 0 else {
            showingAlert = true
            return
        }
        
        let proteinValue = Double(protein) ?? 0
        let fatValue = Double(fat) ?? 0
        let giValue = Int(glycemicIndex) ?? 50
        let breadUnits = carbsValue / 12.0
        
        let entry = FoodEntry(
            name: foodName.trimmingCharacters(in: .whitespacesAndNewlines),
            carbohydrates: carbsValue,
            breadUnits: breadUnits,
            glycemicIndex: giValue,
            calories: caloriesValue,
            protein: proteinValue,
            fat: fatValue,
            portion: portionValue,
            date: Date(),
            mealType: selectedMealType
        )
        
        dataManager.addFoodEntry(entry)
        dismiss()
    }
}

#Preview {
    AddCustomFoodView(selectedMealType: .breakfast)
}
