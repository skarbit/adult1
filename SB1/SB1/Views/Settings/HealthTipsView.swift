import SwiftUI

struct HealthTipsView: View {
    @State private var selectedCategory: TipCategory = .general
    
    var body: some View {
        VStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(TipCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(tips(for: selectedCategory), id: \.title) { tip in
                        HealthTipCardView(tip: tip)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Health Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func tips(for category: TipCategory) -> [HealthTip] {
        switch category {
        case .general:
            return generalTips
        case .nutrition:
            return nutritionTips
        case .exercise:
            return exerciseTips
        case .medication:
            return medicationTips
        }
    }
}

enum TipCategory: CaseIterable {
    case general
    case nutrition
    case exercise
    case medication
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .nutrition: return "Nutrition"
        case .exercise: return "Exercise"
        case .medication: return "Medication"
        }
    }
}

struct HealthTip {
    let title: String
    let content: String
    let icon: String
    let color: Color
}

struct HealthTipCardView: View {
    let tip: HealthTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.icon)
                    .font(.title2)
                    .foregroundColor(tip.color)
                
                Text(tip.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(tip.content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

private let generalTips: [HealthTip] = [
    HealthTip(
        title: "Monitor Regularly",
        content: "Check your blood glucose levels at the times recommended by your healthcare provider. Regular monitoring helps you understand how food, exercise, and medications affect your levels.",
        icon: "chart.line.uptrend.xyaxis",
        color: .blue
    ),
    HealthTip(
        title: "Stay Hydrated",
        content: "Drink plenty of water throughout the day. Dehydration can affect blood sugar levels and make them harder to control.",
        icon: "drop.fill",
        color: .cyan
    ),
    HealthTip(
        title: "Get Quality Sleep",
        content: "Aim for 7-9 hours of quality sleep each night. Poor sleep can affect insulin sensitivity and blood sugar control.",
        icon: "moon.stars.fill",
        color: .purple
    ),
    HealthTip(
        title: "Manage Stress",
        content: "Chronic stress can raise blood sugar levels. Practice stress-reduction techniques like deep breathing, meditation, or yoga.",
        icon: "heart.fill",
        color: .red
    )
]

private let nutritionTips: [HealthTip] = [
    HealthTip(
        title: "Use the Plate Method",
        content: "Fill half your plate with non-starchy vegetables, one quarter with lean protein, and one quarter with complex carbohydrates. This simple method helps control portions and balance nutrients.",
        icon: "circle.hexagongrid.fill",
        color: .green
    ),
    HealthTip(
        title: "Count Carbohydrates",
        content: "Learn to count carbohydrates in your meals. One bread unit (BU) equals 10-12 grams of carbohydrates. This helps you manage your blood sugar better.",
        icon: "number.square.fill",
        color: .orange
    ),
    HealthTip(
        title: "Avoid Hidden Sugars",
        content: "Read food labels carefully. Sugar can be hidden in sauces, dressings, and processed foods under names like high fructose corn syrup, maltose, or dextrose.",
        icon: "eye.fill",
        color: .red
    ),
    HealthTip(
        title: "Choose Low GI Foods",
        content: "Foods with a low glycemic index (GI) cause a slower rise in blood sugar. Examples include oats, quinoa, sweet potatoes, and most vegetables.",
        icon: "arrow.down.circle.fill",
        color: .blue
    )
]

private let exerciseTips: [HealthTip] = [
    HealthTip(
        title: "Post-Meal Walks",
        content: "A 10-15 minute walk after eating can help lower blood sugar spikes. Even light activity makes a difference in glucose control.",
        icon: "figure.walk",
        color: .green
    ),
    HealthTip(
        title: "Mix Cardio and Strength",
        content: "Combine cardiovascular exercise with strength training. Both types of exercise improve insulin sensitivity in different ways.",
        icon: "figure.strengthtraining.traditional",
        color: .blue
    ),
    HealthTip(
        title: "Start Slowly",
        content: "If you're new to exercise, start with 5-10 minutes of activity and gradually increase. Consistency is more important than intensity.",
        icon: "tortoise.fill",
        color: .orange
    ),
    HealthTip(
        title: "Monitor During Exercise",
        content: "Check your blood sugar before, during (for long sessions), and after exercise. This helps you understand how different activities affect your levels.",
        icon: "stopwatch.fill",
        color: .red
    )
]

private let medicationTips: [HealthTip] = [
    HealthTip(
        title: "Take at Same Time",
        content: "Take your medications at the same time each day. This helps maintain consistent levels in your body and improves effectiveness.",
        icon: "clock.fill",
        color: .blue
    ),
    HealthTip(
        title: "Proper Storage",
        content: "Store medications as directed. Most should be kept at room temperature, away from heat and moisture. Insulin should be refrigerated when not in use.",
        icon: "thermometer",
        color: .orange
    ),
    HealthTip(
        title: "Rotate Injection Sites",
        content: "If you use insulin, rotate injection sites to prevent lipodystrophy (lumpy or thickened skin). Use different areas of the same site each time.",
        icon: "arrow.triangle.2.circlepath",
        color: .green
    ),
    HealthTip(
        title: "Never Skip Doses",
        content: "Don't skip medication doses, even if you feel fine. If you miss a dose, follow your healthcare provider's instructions for what to do.",
        icon: "exclamationmark.triangle.fill",
        color: .red
    )
]

#Preview {
    NavigationView {
        HealthTipsView()
    }
}
