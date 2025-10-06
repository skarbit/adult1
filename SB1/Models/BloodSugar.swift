import Foundation

struct BloodSugarReading: Codable, Identifiable {
    var id = UUID()
    var value: Double
    var date: Date
    var mealTiming: MealTiming
    var notes: String
    
    var isInTargetRange: Bool {
        let profile = DataManager.shared.userProfile
        switch mealTiming {
        case .fasting:
            return profile.targetGlucoseFasting.contains(value)
        case .beforeMeal, .afterMeal:
            return profile.targetGlucoseAfterMeal.contains(value)
        }
    }
    
    var status: GlucoseStatus {
        let profile = DataManager.shared.userProfile
        let range = mealTiming == .fasting ? profile.targetGlucoseFasting : profile.targetGlucoseAfterMeal
        
        if value < range.lowerBound {
            return .low
        } else if value > range.upperBound {
            return .high
        } else {
            return .normal
        }
    }
}

enum MealTiming: String, CaseIterable, Codable {
    case fasting = "Fasting"
    case beforeMeal = "Before Meal"
    case afterMeal = "After Meal"
}

enum GlucoseStatus: String {
    case low = "Low"
    case normal = "Normal" 
    case high = "High"
    
    var color: String {
        switch self {
        case .low: return "red"
        case .normal: return "green"
        case .high: return "red"
        }
    }
}
