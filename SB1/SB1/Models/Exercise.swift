import Foundation

struct ExerciseEntry: Codable, Identifiable {
    var id = UUID()
    var type: ExerciseType
    var name: String
    var duration: TimeInterval
    var intensity: ExerciseIntensity
    var date: Date
    var caloriesBurned: Double
    var notes: String
    var glucoseEffectType: GlucoseEffect
}

enum ExerciseType: String, CaseIterable, Codable {
    case cardio = "Cardio"
    case strength = "Strength"
    case yoga = "Yoga"
    case walking = "Walking"
    case swimming = "Swimming"
    case cycling = "Cycling"
}

enum ExerciseIntensity: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

enum GlucoseEffect: String, CaseIterable, Codable {
    case lowers = "Lowers glucose"
    case neutral = "Neutral effect"
    case raises = "May raise glucose initially"
}

struct ExerciseTemplate: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: ExerciseType
    var defaultDuration: TimeInterval
    var description: String
    var glucoseEffect: GlucoseEffect
    var caloriesPerMinute: Double
}
