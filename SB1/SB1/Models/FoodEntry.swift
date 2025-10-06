import Foundation

struct FoodEntry: Codable, Identifiable {
    var id = UUID()
    var name: String
    var carbohydrates: Double
    var breadUnits: Double
    var glycemicIndex: Int
    var calories: Double
    var protein: Double
    var fat: Double
    var portion: Double
    var date: Date
    var mealType: MealType
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

struct FoodProduct: Codable, Identifiable {
    var id = UUID()
    var name: String
    var carbohydratesPer100g: Double
    var breadUnitsPer100g: Double
    var glycemicIndex: Int
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var fatPer100g: Double
    var category: FoodCategory
}

enum FoodCategory: String, CaseIterable, Codable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case grains = "Grains"
    case proteins = "Proteins"
    case dairy = "Dairy"
    case snacks = "Snacks"
    case beverages = "Beverages"
}
