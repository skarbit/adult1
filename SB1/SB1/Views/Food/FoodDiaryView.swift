import SwiftUI

struct FoodDiaryView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedDate = Date()
    @State private var showingAddFood = false
    @State private var selectedMealType: MealType = .breakfast
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(Array(MealType.allCases.enumerated()), id: \.element) { index, mealType in
                            MealSectionView(
                                mealType: mealType,
                                entries: foodEntriesForMeal(mealType),
                                onAddFood: {
                                    selectedMealType = mealType
                                    showingAddFood = true
                                }
                            )
                            .bouncyCardEffect(delay: Double(index) * 0.1)
                        }
                        
                        DailyNutritionSummaryView(entries: todaysFoodEntries)
                            .bouncyCardEffect(delay: 0.4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Food Diary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(selectedMealType: selectedMealType)
        }
    }
    
    private var todaysFoodEntries: [FoodEntry] {
        let calendar = Calendar.current
        return dataManager.foodEntries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private func foodEntriesForMeal(_ mealType: MealType) -> [FoodEntry] {
        todaysFoodEntries.filter { $0.mealType == mealType }
    }
}

struct MealSectionView: View {
    let mealType: MealType
    let entries: [FoodEntry]
    let onAddFood: () -> Void
    
    private var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbohydrates }
    }
    
    private var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealType.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !entries.isEmpty {
                        HStack(spacing: 15) {
                            Text("\(String(format: "%.1f", totalCarbs))g carbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(String(format: "%.0f", totalCalories)) cal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onAddFood) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            
            if entries.isEmpty {
                Text("No foods logged")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(entries) { entry in
                    FoodEntryRowView(entry: entry)
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
}

struct FoodEntryRowView: View {
    let entry: FoodEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 10) {
                    Text("\(String(format: "%.0f", entry.portion))g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", entry.carbohydrates))g carbs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", entry.breadUnits)) BU")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(String(format: "%.0f", entry.calories)) cal")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("GI: \(entry.glycemicIndex)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DailyNutritionSummaryView: View {
    let entries: [FoodEntry]
    
    private var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    private var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbohydrates }
    }
    
    private var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }
    
    private var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }
    
    private var totalBreadUnits: Double {
        entries.reduce(0) { $0 + $1.breadUnits }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                NutritionItem(
                    title: "Calories",
                    value: "\(String(format: "%.0f", totalCalories))",
                    color: .blue
                )
                
                NutritionItem(
                    title: "Carbs",
                    value: "\(String(format: "%.1f", totalCarbs))g",
                    color: .orange
                )
                
                NutritionItem(
                    title: "Protein", 
                    value: "\(String(format: "%.1f", totalProtein))g",
                    color: .green
                )
                
                NutritionItem(
                    title: "Fat",
                    value: "\(String(format: "%.1f", totalFat))g",
                    color: .purple
                )
            }
            
            HStack {
                Text("Bread Units:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(String(format: "%.1f", totalBreadUnits)) BU")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct NutritionItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FoodDiaryView()
}
