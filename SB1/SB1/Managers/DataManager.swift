import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var userProfile: UserProfile
    @Published var bloodSugarReadings: [BloodSugarReading] = []
    @Published var foodEntries: [FoodEntry] = []
    @Published var exerciseEntries: [ExerciseEntry] = []
    @Published var medications: [Medication] = []
    @Published var medicationEntries: [MedicationEntry] = []
    @Published var insulinEntries: [InsulinEntry] = []
    
    private let userProfileKey = "UserProfile"
    private let bloodSugarKey = "BloodSugarReadings"
    private let foodEntriesKey = "FoodEntries"
    private let exerciseEntriesKey = "ExerciseEntries"
    private let medicationsKey = "Medications"
    private let medicationEntriesKey = "MedicationEntries"
    private let insulinEntriesKey = "InsulinEntries"
    
    private init() {
        self.userProfile = Self.loadUserProfile()
        self.loadAllData()
    }
    
    func saveUserProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: userProfileKey)
        }
    }
    
    private static func loadUserProfile() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: "UserProfile"),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return UserProfile.shared
        }
        return profile
    }
    
    func saveBloodSugarReadings() {
        if let data = try? JSONEncoder().encode(bloodSugarReadings) {
            UserDefaults.standard.set(data, forKey: bloodSugarKey)
        }
    }
    
    func loadBloodSugarReadings() {
        guard let data = UserDefaults.standard.data(forKey: bloodSugarKey),
              let readings = try? JSONDecoder().decode([BloodSugarReading].self, from: data) else {
            bloodSugarReadings = []
            return
        }
        bloodSugarReadings = readings.sorted { $0.date > $1.date }
    }
    
    func saveFoodEntries() {
        if let data = try? JSONEncoder().encode(foodEntries) {
            UserDefaults.standard.set(data, forKey: foodEntriesKey)
        }
    }
    
    func loadFoodEntries() {
        guard let data = UserDefaults.standard.data(forKey: foodEntriesKey),
              let entries = try? JSONDecoder().decode([FoodEntry].self, from: data) else {
            foodEntries = []
            return
        }
        foodEntries = entries.sorted { $0.date > $1.date }
    }
    
    func saveExerciseEntries() {
        if let data = try? JSONEncoder().encode(exerciseEntries) {
            UserDefaults.standard.set(data, forKey: exerciseEntriesKey)
        }
    }
    
    func loadExerciseEntries() {
        guard let data = UserDefaults.standard.data(forKey: exerciseEntriesKey),
              let entries = try? JSONDecoder().decode([ExerciseEntry].self, from: data) else {
            exerciseEntries = []
            return
        }
        exerciseEntries = entries.sorted { $0.date > $1.date }
    }
    
    func saveMedications() {
        if let data = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(data, forKey: medicationsKey)
        }
    }
    
    func loadMedications() {
        guard let data = UserDefaults.standard.data(forKey: medicationsKey),
              let meds = try? JSONDecoder().decode([Medication].self, from: data) else {
            medications = []
            return
        }
        medications = meds
    }
    
    func saveMedicationEntries() {
        if let data = try? JSONEncoder().encode(medicationEntries) {
            UserDefaults.standard.set(data, forKey: medicationEntriesKey)
        }
    }
    
    func loadMedicationEntries() {
        guard let data = UserDefaults.standard.data(forKey: medicationEntriesKey),
              let entries = try? JSONDecoder().decode([MedicationEntry].self, from: data) else {
            medicationEntries = []
            return
        }
        medicationEntries = entries.sorted { $0.takenDate > $1.takenDate }
    }
    
    func saveInsulinEntries() {
        if let data = try? JSONEncoder().encode(insulinEntries) {
            UserDefaults.standard.set(data, forKey: insulinEntriesKey)
        }
    }
    
    func loadInsulinEntries() {
        guard let data = UserDefaults.standard.data(forKey: insulinEntriesKey),
              let entries = try? JSONDecoder().decode([InsulinEntry].self, from: data) else {
            insulinEntries = []
            return
        }
        insulinEntries = entries.sorted { $0.date > $1.date }
    }
    
    func loadAllData() {
        loadBloodSugarReadings()
        loadFoodEntries()
        loadExerciseEntries()
        loadMedications()
        loadMedicationEntries()
        loadInsulinEntries()
    }
    
    func saveAllData() {
        saveUserProfile()
        saveBloodSugarReadings()
        saveFoodEntries()
        saveExerciseEntries()
        saveMedications()
        saveMedicationEntries()
        saveInsulinEntries()
    }
    
    func clearAllData() {
        userProfile = UserProfile.shared
        bloodSugarReadings = []
        foodEntries = []
        exerciseEntries = []
        medications = []
        medicationEntries = []
        insulinEntries = []
        
        let keys = [userProfileKey, bloodSugarKey, foodEntriesKey, exerciseEntriesKey, medicationsKey, medicationEntriesKey, insulinEntriesKey]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
    
    func addBloodSugarReading(_ reading: BloodSugarReading) {
        bloodSugarReadings.insert(reading, at: 0)
        saveBloodSugarReadings()
    }
    
    func addFoodEntry(_ entry: FoodEntry) {
        foodEntries.insert(entry, at: 0)
        saveFoodEntries()
    }
    
    func addExerciseEntry(_ entry: ExerciseEntry) {
        exerciseEntries.insert(entry, at: 0)
        saveExerciseEntries()
    }
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        saveMedications()
    }
    
    func addMedicationEntry(_ entry: MedicationEntry) {
        medicationEntries.insert(entry, at: 0)
        saveMedicationEntries()
    }
    
    func addInsulinEntry(_ entry: InsulinEntry) {
        insulinEntries.insert(entry, at: 0)
        saveInsulinEntries()
    }
    
    func getTodaysBloodSugarReadings() -> [BloodSugarReading] {
        let calendar = Calendar.current
        let today = Date()
        return bloodSugarReadings.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    func getAverageGlucoseForPeriod(days: Int) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        
        let readings = bloodSugarReadings.filter { $0.date >= startDate && $0.date <= endDate }
        guard !readings.isEmpty else { return 0 }
        
        let sum = readings.reduce(0) { $0 + $1.value }
        return sum / Double(readings.count)
    }
    
    func getHbA1cEstimate() -> Double {
        let averageGlucose = getAverageGlucoseForPeriod(days: 90)
        return (averageGlucose + 2.59) / 1.59
    }
}
