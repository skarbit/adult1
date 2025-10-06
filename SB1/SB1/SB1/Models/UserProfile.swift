import Foundation

struct UserProfile: Codable {
    var age: Int
    var height: Double
    var weight: Double
    var diabetesType: DiabetesType
    var targetGlucoseFasting: ClosedRange<Double>
    var targetGlucoseAfterMeal: ClosedRange<Double>
    var isOnboardingComplete: Bool
    
    static let shared = UserProfile(
        age: 0,
        height: 0,
        weight: 0,
        diabetesType: .type1,
        targetGlucoseFasting: 4.0...7.0,
        targetGlucoseAfterMeal: 5.0...10.0,
        isOnboardingComplete: false
    )
}

enum DiabetesType: String, CaseIterable, Codable {
    case type1 = "Type 1"
    case type2 = "Type 2"
    case gestational = "Gestational"
    case prediabetes = "Prediabetes"
}
