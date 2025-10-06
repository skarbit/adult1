import Foundation

class FoodDatabase: ObservableObject {
    static let shared = FoodDatabase()
    
    @Published var products: [FoodProduct] = []
    
    private init() {
        loadProducts()
    }
    
    private func loadProducts() {
        products = [
            FoodProduct(name: "Apple", carbohydratesPer100g: 14.0, breadUnitsPer100g: 1.2, glycemicIndex: 35, caloriesPer100g: 52, proteinPer100g: 0.3, fatPer100g: 0.2, category: .fruits),
            FoodProduct(name: "Banana", carbohydratesPer100g: 23.0, breadUnitsPer100g: 1.9, glycemicIndex: 50, caloriesPer100g: 89, proteinPer100g: 1.1, fatPer100g: 0.3, category: .fruits),
            FoodProduct(name: "Orange", carbohydratesPer100g: 12.0, breadUnitsPer100g: 1.0, glycemicIndex: 40, caloriesPer100g: 47, proteinPer100g: 0.9, fatPer100g: 0.1, category: .fruits),
            FoodProduct(name: "Grapes", carbohydratesPer100g: 16.0, breadUnitsPer100g: 1.3, glycemicIndex: 45, caloriesPer100g: 62, proteinPer100g: 0.6, fatPer100g: 0.2, category: .fruits),
            FoodProduct(name: "Strawberries", carbohydratesPer100g: 8.0, breadUnitsPer100g: 0.7, glycemicIndex: 25, caloriesPer100g: 32, proteinPer100g: 0.7, fatPer100g: 0.3, category: .fruits),
            
            FoodProduct(name: "Broccoli", carbohydratesPer100g: 7.0, breadUnitsPer100g: 0.6, glycemicIndex: 15, caloriesPer100g: 34, proteinPer100g: 2.8, fatPer100g: 0.4, category: .vegetables),
            FoodProduct(name: "Spinach", carbohydratesPer100g: 3.6, breadUnitsPer100g: 0.3, glycemicIndex: 15, caloriesPer100g: 23, proteinPer100g: 2.9, fatPer100g: 0.4, category: .vegetables),
            FoodProduct(name: "Carrots", carbohydratesPer100g: 10.0, breadUnitsPer100g: 0.8, glycemicIndex: 35, caloriesPer100g: 41, proteinPer100g: 0.9, fatPer100g: 0.2, category: .vegetables),
            FoodProduct(name: "Bell Pepper", carbohydratesPer100g: 6.0, breadUnitsPer100g: 0.5, glycemicIndex: 15, caloriesPer100g: 31, proteinPer100g: 1.0, fatPer100g: 0.3, category: .vegetables),
            FoodProduct(name: "Cucumber", carbohydratesPer100g: 3.6, breadUnitsPer100g: 0.3, glycemicIndex: 10, caloriesPer100g: 16, proteinPer100g: 0.7, fatPer100g: 0.1, category: .vegetables),
            
            FoodProduct(name: "Buckwheat", carbohydratesPer100g: 72.0, breadUnitsPer100g: 6.0, glycemicIndex: 50, caloriesPer100g: 343, proteinPer100g: 13.3, fatPer100g: 3.4, category: .grains),
            FoodProduct(name: "Quinoa", carbohydratesPer100g: 64.0, breadUnitsPer100g: 5.3, glycemicIndex: 35, caloriesPer100g: 368, proteinPer100g: 14.1, fatPer100g: 6.1, category: .grains),
            FoodProduct(name: "Brown Rice", carbohydratesPer100g: 73.0, breadUnitsPer100g: 6.1, glycemicIndex: 50, caloriesPer100g: 370, proteinPer100g: 7.9, fatPer100g: 2.9, category: .grains),
            FoodProduct(name: "Oats", carbohydratesPer100g: 66.0, breadUnitsPer100g: 5.5, glycemicIndex: 40, caloriesPer100g: 389, proteinPer100g: 16.9, fatPer100g: 6.9, category: .grains),
            FoodProduct(name: "White Bread", carbohydratesPer100g: 49.0, breadUnitsPer100g: 4.1, glycemicIndex: 70, caloriesPer100g: 265, proteinPer100g: 9.0, fatPer100g: 3.2, category: .grains),
            
            FoodProduct(name: "Chicken Breast", carbohydratesPer100g: 0.0, breadUnitsPer100g: 0.0, glycemicIndex: 0, caloriesPer100g: 165, proteinPer100g: 31.0, fatPer100g: 3.6, category: .proteins),
            FoodProduct(name: "Salmon", carbohydratesPer100g: 0.0, breadUnitsPer100g: 0.0, glycemicIndex: 0, caloriesPer100g: 208, proteinPer100g: 22.1, fatPer100g: 12.4, category: .proteins),
            FoodProduct(name: "Eggs", carbohydratesPer100g: 1.1, breadUnitsPer100g: 0.1, glycemicIndex: 0, caloriesPer100g: 155, proteinPer100g: 13.0, fatPer100g: 11.0, category: .proteins),
            FoodProduct(name: "Tofu", carbohydratesPer100g: 3.0, breadUnitsPer100g: 0.3, glycemicIndex: 15, caloriesPer100g: 144, proteinPer100g: 15.8, fatPer100g: 8.7, category: .proteins),
            FoodProduct(name: "Lentils", carbohydratesPer100g: 60.0, breadUnitsPer100g: 5.0, glycemicIndex: 30, caloriesPer100g: 353, proteinPer100g: 25.8, fatPer100g: 1.1, category: .proteins),
            
            FoodProduct(name: "Milk (2%)", carbohydratesPer100g: 4.8, breadUnitsPer100g: 0.4, glycemicIndex: 30, caloriesPer100g: 50, proteinPer100g: 3.4, fatPer100g: 2.0, category: .dairy),
            FoodProduct(name: "Greek Yogurt", carbohydratesPer100g: 4.0, breadUnitsPer100g: 0.3, glycemicIndex: 11, caloriesPer100g: 59, proteinPer100g: 10.0, fatPer100g: 0.4, category: .dairy),
            FoodProduct(name: "Cottage Cheese", carbohydratesPer100g: 3.4, breadUnitsPer100g: 0.3, glycemicIndex: 10, caloriesPer100g: 98, proteinPer100g: 11.1, fatPer100g: 4.3, category: .dairy),
            FoodProduct(name: "Cheddar Cheese", carbohydratesPer100g: 1.3, breadUnitsPer100g: 0.1, glycemicIndex: 0, caloriesPer100g: 403, proteinPer100g: 25.0, fatPer100g: 33.0, category: .dairy),
            
            FoodProduct(name: "Almonds", carbohydratesPer100g: 22.0, breadUnitsPer100g: 1.8, glycemicIndex: 15, caloriesPer100g: 579, proteinPer100g: 21.2, fatPer100g: 49.9, category: .snacks),
            FoodProduct(name: "Walnuts", carbohydratesPer100g: 14.0, breadUnitsPer100g: 1.2, glycemicIndex: 15, caloriesPer100g: 654, proteinPer100g: 15.2, fatPer100g: 65.2, category: .snacks),
            FoodProduct(name: "Dark Chocolate", carbohydratesPer100g: 46.0, breadUnitsPer100g: 3.8, glycemicIndex: 25, caloriesPer100g: 546, proteinPer100g: 7.8, fatPer100g: 31.3, category: .snacks),
            
            FoodProduct(name: "Green Tea", carbohydratesPer100g: 0.0, breadUnitsPer100g: 0.0, glycemicIndex: 0, caloriesPer100g: 1, proteinPer100g: 0.2, fatPer100g: 0.0, category: .beverages),
            FoodProduct(name: "Coffee (black)", carbohydratesPer100g: 0.0, breadUnitsPer100g: 0.0, glycemicIndex: 0, caloriesPer100g: 2, proteinPer100g: 0.3, fatPer100g: 0.0, category: .beverages),
            FoodProduct(name: "Orange Juice", carbohydratesPer100g: 10.4, breadUnitsPer100g: 0.9, glycemicIndex: 50, caloriesPer100g: 45, proteinPer100g: 0.7, fatPer100g: 0.2, category: .beverages)
        ]
    }
    
    func searchProducts(query: String) -> [FoodProduct] {
        if query.isEmpty {
            return products
        }
        return products.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func productsByCategory(_ category: FoodCategory) -> [FoodProduct] {
        return products.filter { $0.category == category }
    }
}
