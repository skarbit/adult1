import Foundation

struct ExerciseTemplateData {
    static let templates: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Brisk Walking",
            type: .walking,
            defaultDuration: 900, // 15 minutes
            description: "A moderate-paced walk that helps lower blood glucose",
            glucoseEffect: .lowers,
            caloriesPerMinute: 4.5
        ),
        
        ExerciseTemplate(
            name: "Light Yoga",
            type: .yoga,
            defaultDuration: 1200, // 20 minutes
            description: "Gentle stretches and poses to improve flexibility",
            glucoseEffect: .lowers,
            caloriesPerMinute: 3.0
        ),
        
        ExerciseTemplate(
            name: "Strength Training",
            type: .strength,
            defaultDuration: 1800, // 30 minutes
            description: "Basic bodyweight or light weight exercises",
            glucoseEffect: .raises,
            caloriesPerMinute: 6.0
        ),
        
        ExerciseTemplate(
            name: "Swimming",
            type: .swimming,
            defaultDuration: 1800, // 30 minutes
            description: "Low-impact full-body cardio exercise",
            glucoseEffect: .lowers,
            caloriesPerMinute: 8.0
        ),
        
        ExerciseTemplate(
            name: "Cycling",
            type: .cycling,
            defaultDuration: 1200, // 20 minutes
            description: "Moderate cycling for cardio fitness",
            glucoseEffect: .lowers,
            caloriesPerMinute: 7.5
        ),
        
        ExerciseTemplate(
            name: "HIIT Cardio",
            type: .cardio,
            defaultDuration: 900, // 15 minutes
            description: "High-intensity interval training",
            glucoseEffect: .raises,
            caloriesPerMinute: 12.0
        ),
        
        ExerciseTemplate(
            name: "Post-Meal Walk",
            type: .walking,
            defaultDuration: 600, // 10 minutes
            description: "Short walk after eating to help with glucose control",
            glucoseEffect: .lowers,
            caloriesPerMinute: 3.5
        ),
        
        ExerciseTemplate(
            name: "Stretching",
            type: .yoga,
            defaultDuration: 600, // 10 minutes
            description: "Simple stretches to improve circulation",
            glucoseEffect: .neutral,
            caloriesPerMinute: 2.0
        )
    ]
}
