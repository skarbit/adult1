import SwiftUI

struct AddFoodView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let selectedMealType: MealType
    
    @State private var searchText = ""
    @State private var selectedProduct: FoodProduct?
    @State private var portionSize: String = "100"
    @State private var showingCustomFood = false
    
    private let foodDatabase = FoodDatabase.shared
    
    private var filteredProducts: [FoodProduct] {
        if searchText.isEmpty {
            return foodDatabase.products
        } else {
            return foodDatabase.products.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                searchBar
                
                if let product = selectedProduct {
                    selectedProductView(product)
                } else {
                    productsList
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Custom") {
                        showingCustomFood = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingCustomFood) {
            AddCustomFoodView(selectedMealType: selectedMealType)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search foods...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    private var productsList: some View {
        List(filteredProducts) { product in
            ProductRowView(product: product) {
                selectedProduct = product
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func selectedProductView(_ product: FoodProduct) -> some View {
        VStack(spacing: 20) {
            HStack {
                Button("← Back") {
                    selectedProduct = nil
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Portion Size")
                            .font(.headline)
                        
                        HStack {
                            TextField("100", text: $portionSize)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            
                            Text("grams")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    
                    if let portion = Double(portionSize), portion > 0 {
                        let multiplier = portion / 100.0
                        
                        NutritionInfoView(
                            product: product,
                            multiplier: multiplier,
                            portionSize: portion
                        )
                        
                        Button("Add to \(selectedMealType.rawValue)") {
                            addFoodEntry(product: product, portion: portion)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.top)
                    }
                }
                .padding()
            }
        }
    }
    
    private func addFoodEntry(product: FoodProduct, portion: Double) {
        let multiplier = portion / 100.0
        
        let entry = FoodEntry(
            name: product.name,
            carbohydrates: product.carbohydratesPer100g * multiplier,
            breadUnits: product.breadUnitsPer100g * multiplier,
            glycemicIndex: product.glycemicIndex,
            calories: product.caloriesPer100g * multiplier,
            protein: product.proteinPer100g * multiplier,
            fat: product.fatPer100g * multiplier,
            portion: portion,
            date: Date(),
            mealType: selectedMealType
        )
        
        dataManager.addFoodEntry(entry)
        dismiss()
    }
}

struct ProductRowView: View {
    let product: FoodProduct
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(product.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 10) {
                        Text("\(String(format: "%.0f", product.caloriesPer100g)) cal/100g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("GI: \(product.glycemicIndex)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NutritionInfoView: View {
    let product: FoodProduct
    let multiplier: Double
    let portionSize: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition Information")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                NutritionItemDetail(
                    title: "Calories",
                    value: "\(String(format: "%.0f", product.caloriesPer100g * multiplier))",
                    unit: "kcal"
                )
                
                NutritionItemDetail(
                    title: "Carbohydrates",
                    value: "\(String(format: "%.1f", product.carbohydratesPer100g * multiplier))",
                    unit: "g"
                )
                
                NutritionItemDetail(
                    title: "Protein",
                    value: "\(String(format: "%.1f", product.proteinPer100g * multiplier))",
                    unit: "g"
                )
                
                NutritionItemDetail(
                    title: "Fat",
                    value: "\(String(format: "%.1f", product.fatPer100g * multiplier))",
                    unit: "g"
                )
                
                NutritionItemDetail(
                    title: "Bread Units",
                    value: "\(String(format: "%.1f", product.breadUnitsPer100g * multiplier))",
                    unit: "BU"
                )
                
                NutritionItemDetail(
                    title: "Glycemic Index",
                    value: "\(product.glycemicIndex)",
                    unit: ""
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct NutritionItemDetail: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}

#Preview {
    AddFoodView(selectedMealType: .breakfast)
}
