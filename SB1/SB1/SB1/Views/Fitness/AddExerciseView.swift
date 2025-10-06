import SwiftUI

struct AddExerciseView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: ExerciseType = .walking
    @State private var exerciseName = ""
    @State private var duration = ""
    @State private var selectedIntensity: ExerciseIntensity = .moderate
    @State private var selectedDate = Date()
    @State private var notes = ""
    @State private var selectedGlucoseEffect: GlucoseEffect = .lowers
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    Picker("Exercise Type", selection: $selectedType) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: iconForExerciseType(type))
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    TextField("Exercise name", text: $exerciseName)
                        .onAppear {
                            if exerciseName.isEmpty {
                                exerciseName = selectedType.rawValue
                            }
                        }
                        .onChange(of: selectedType) { _, newType in
                            if exerciseName == selectedType.rawValue || exerciseName.isEmpty {
                                exerciseName = newType.rawValue
                            }
                        }
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        TextField("30", text: $duration)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("minutes")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Intensity", selection: $selectedIntensity) {
                        ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Glucose Effect")) {
                    Picker("Effect on Blood Sugar", selection: $selectedGlucoseEffect) {
                        ForEach(GlucoseEffect.allCases, id: \.self) { effect in
                            Text(effect.rawValue).tag(effect)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Add any notes about this exercise...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let durationMinutes = Int(duration), durationMinutes > 0 {
                    Section(header: Text("Estimated Results")) {
                        let estimatedCalories = calculateEstimatedCalories(
                            type: selectedType,
                            duration: durationMinutes,
                            intensity: selectedIntensity
                        )
                        
                        HStack {
                            Text("Estimated Calories Burned")
                            Spacer()
                            Text("\(Int(estimatedCalories)) cal")
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("Expected Glucose Effect")
                            Spacer()
                            Text(selectedGlucoseEffect.rawValue)
                                .fontWeight(.medium)
                                .foregroundColor(colorForGlucoseEffect(selectedGlucoseEffect))
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !exerciseName.isEmpty &&
        !duration.isEmpty &&
        Int(duration) != nil &&
        Int(duration) ?? 0 > 0
    }
    
    private func saveExercise() {
        guard let durationMinutes = Int(duration), durationMinutes > 0 else { return }
        
        let durationSeconds = TimeInterval(durationMinutes * 60)
        let estimatedCalories = calculateEstimatedCalories(
            type: selectedType,
            duration: durationMinutes,
            intensity: selectedIntensity
        )
        
        let exercise = ExerciseEntry(
            type: selectedType,
            name: exerciseName.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: durationSeconds,
            intensity: selectedIntensity,
            date: selectedDate,
            caloriesBurned: estimatedCalories,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            glucoseEffectType: selectedGlucoseEffect
        )
        
        dataManager.addExerciseEntry(exercise)
        dismiss()
    }
    
    private func calculateEstimatedCalories(type: ExerciseType, duration: Int, intensity: ExerciseIntensity) -> Double {
        let baseCaloriesPerMinute: Double
        
        switch type {
        case .walking: baseCaloriesPerMinute = 4.0
        case .cardio: baseCaloriesPerMinute = 10.0
        case .strength: baseCaloriesPerMinute = 6.0
        case .yoga: baseCaloriesPerMinute = 3.0
        case .swimming: baseCaloriesPerMinute = 8.0
        case .cycling: baseCaloriesPerMinute = 7.0
        }
        
        let intensityMultiplier: Double
        switch intensity {
        case .low: intensityMultiplier = 0.8
        case .moderate: intensityMultiplier = 1.0
        case .high: intensityMultiplier = 1.3
        }
        
        return baseCaloriesPerMinute * intensityMultiplier * Double(duration)
    }
    
    private func iconForExerciseType(_ type: ExerciseType) -> String {
        switch type {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.mind.and.body"
        case .walking: return "figure.walk"
        case .swimming: return "figure.pool.swim"
        case .cycling: return "bicycle"
        }
    }
    
    private func colorForGlucoseEffect(_ effect: GlucoseEffect) -> Color {
        switch effect {
        case .lowers: return .green
        case .neutral: return .blue
        case .raises: return .orange
        }
    }
}

#Preview {
    AddExerciseView()
}
