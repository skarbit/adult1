import SwiftUI

struct FitnessView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddExercise = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    dateSelector
                        .fadeInEffect(delay: 0.1)
                    
                    todaysActivitySummary
                        .bouncyCardEffect(delay: 0.2)
                    
                    exerciseTemplatesSection
                        .bouncyCardEffect(delay: 0.3)
                    
                    todaysExercisesSection
                        .bouncyCardEffect(delay: 0.4)
                    
                    healthTipsSection
                        .bouncyCardEffect(delay: 0.5)
                }
                .padding()
            }
            .navigationTitle("Fitness Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }
    
    private var dateSelector: some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
    }
    
    private var todaysActivitySummary: some View {
        let todaysExercises = getTodaysExercises()
        let totalDuration = todaysExercises.reduce(0) { $0 + $1.duration }
        let totalCalories = todaysExercises.reduce(0) { $0 + $1.caloriesBurned }
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Today's Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                ActivityStatView(
                    title: "Exercises",
                    value: "\(todaysExercises.count)",
                    icon: "figure.run.circle.fill",
                    color: .blue
                )
                
                ActivityStatView(
                    title: "Duration",
                    value: formatDuration(totalDuration),
                    icon: "clock.fill",
                    color: .green
                )
                
                ActivityStatView(
                    title: "Calories",
                    value: "\(Int(totalCalories))",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var exerciseTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Start Exercises")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(ExerciseTemplateData.templates) { template in
                    ExerciseTemplateCard(template: template) {
                        addExerciseFromTemplate(template)
                    }
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
    
    private var todaysExercisesSection: some View {
        let todaysExercises = getTodaysExercises()
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Today's Exercises")
                .font(.headline)
                .fontWeight(.semibold)
            
            if todaysExercises.isEmpty {
                Text("No exercises recorded today")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(todaysExercises) { exercise in
                    ExerciseRowView(exercise: exercise)
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
    
    private var healthTipsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Health Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                HealthTipView(
                    icon: "heart.fill",
                    tip: "Light exercise after meals can help lower blood sugar levels",
                    color: .red
                )
                
                HealthTipView(
                    icon: "figure.walk",
                    tip: "A 15-minute walk can be as effective as intensive exercise for glucose control",
                    color: .blue
                )
                
                HealthTipView(
                    icon: "moon.stars.fill",
                    tip: "Regular exercise improves sleep quality and insulin sensitivity",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func getTodaysExercises() -> [ExerciseEntry] {
        let calendar = Calendar.current
        return dataManager.exerciseEntries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let exercise = ExerciseEntry(
            type: template.type,
            name: template.name,
            duration: template.defaultDuration,
            intensity: .moderate,
            date: Date(),
            caloriesBurned: template.caloriesPerMinute * (template.defaultDuration / 60),
            notes: "",
            glucoseEffectType: template.glucoseEffect
        )
        
        dataManager.addExerciseEntry(exercise)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

struct ActivityStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseTemplateCard: View {
    let template: ExerciseTemplate
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var showSuccessAnimation = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Success animation
            withAnimation(.easeInOut(duration: 0.2).delay(0.1)) {
                showSuccessAnimation = true
            }
            
            // Execute action with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onTap()
            }
            
            // Reset animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showSuccessAnimation = false
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconForExerciseType(template.type))
                        .font(.title2)
                        .foregroundColor(showSuccessAnimation ? .white : colorForExerciseType(template.type))
                        .scaleEffect(isPressed ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        .animation(.easeInOut(duration: 0.2), value: showSuccessAnimation)
                    
                    Spacer()
                    
                    Text("\(Int(template.defaultDuration / 60))min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(showSuccessAnimation ? 0.8 : 1.0)
                }
                
                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showSuccessAnimation ? .white : .primary)
                    .multilineTextAlignment(.leading)
                
                Text(template.glucoseEffect.rawValue)
                    .font(.caption)
                    .foregroundColor(showSuccessAnimation ? .white.opacity(0.8) : .secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(showSuccessAnimation ? 
                          colorForExerciseType(template.type).opacity(0.9) : 
                          Color(.systemGray6))
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(
                        color: showSuccessAnimation ? 
                        colorForExerciseType(template.type).opacity(0.3) : .clear,
                        radius: showSuccessAnimation ? 10 : 0,
                        x: 0,
                        y: showSuccessAnimation ? 5 : 0
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: showSuccessAnimation)
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private func colorForExerciseType(_ type: ExerciseType) -> Color {
        switch type {
        case .cardio: return .red
        case .strength: return .blue
        case .yoga: return .purple
        case .walking: return .green
        case .swimming: return .cyan
        case .cycling: return .orange
        }
    }
}

struct ExerciseRowView: View {
    let exercise: ExerciseEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 10) {
                    Text(exercise.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(exercise.duration / 60)) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(exercise.intensity.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(exercise.caloriesBurned)) cal")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(exercise.date, formatter: timeFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct HealthTipView: View {
    let icon: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    FitnessView()
}
