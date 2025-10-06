import Foundation

struct Medication: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: MedicationType
    var dosage: String
    var schedule: [MedicationSchedule]
    var remainingQuantity: Double
    var lowStockThreshold: Double
    var isActive: Bool
}

enum MedicationType: String, CaseIterable, Codable {
    case insulin = "Insulin"
    case metformin = "Metformin"
    case sulfonylurea = "Sulfonylurea"
    case other = "Other"
}

struct MedicationSchedule: Codable, Identifiable {
    var id = UUID()
    var timeOfDay: Date
    var dosage: String
    var isEnabled: Bool
}

struct MedicationEntry: Codable, Identifiable {
    var id = UUID()
    var medicationId: UUID
    var takenDate: Date
    var dosageTaken: String
    var notes: String
    var wasOnTime: Bool
}

struct InsulinEntry: Codable, Identifiable {
    var id = UUID()
    var insulinType: InsulinType
    var units: Double
    var injectionSite: InjectionSite
    var date: Date
    var notes: String
    var relatedFoodId: UUID?
}

enum InsulinType: String, CaseIterable, Codable {
    case rapid = "Rapid-acting"
    case short = "Short-acting"
    case intermediate = "Intermediate-acting"
    case long = "Long-acting"
    case mixed = "Mixed"
}

enum InjectionSite: String, CaseIterable, Codable {
    case abdomen = "Abdomen"
    case thigh = "Thigh"
    case arm = "Arm"
    case buttocks = "Buttocks"
}
