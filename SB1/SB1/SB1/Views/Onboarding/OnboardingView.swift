import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var currentStep = 0
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var selectedDiabetesType: DiabetesType = .type1
    @State private var fastingMin: String = "4.0"
    @State private var fastingMax: String = "7.0"
    @State private var afterMealMin: String = "5.0"
    @State private var afterMealMax: String = "10.0"
    
    private let totalSteps = 4
    
    var body: some View {
        NavigationView {
            VStack {
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemRed)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding()
                
                TabView(selection: $currentStep) {
                    WelcomeStepView()
                        .tag(0)
                    
                    PersonalInfoStepView(
                        age: $age,
                        height: $height,
                        weight: $weight,
                        diabetesType: $selectedDiabetesType
                    )
                    .tag(1)
                    
                    TargetRangesStepView(
                        fastingMin: $fastingMin,
                        fastingMax: $fastingMax,
                        afterMealMin: $afterMealMin,
                        afterMealMax: $afterMealMax
                    )
                    .tag(2)
                    
                    CompletionStepView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut) {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "Complete Setup" : "Next") {
                        if currentStep == totalSteps - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation(.easeInOut) {
                                currentStep += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(.systemRed))
                    .cornerRadius(10)
                    .disabled(!isCurrentStepValid())
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func isCurrentStepValid() -> Bool {
        switch currentStep {
        case 0, 3: return true
        case 1: 
            return !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
                   Int(age) != nil && Double(height) != nil && Double(weight) != nil
        case 2:
            return Double(fastingMin) != nil && Double(fastingMax) != nil &&
                   Double(afterMealMin) != nil && Double(afterMealMax) != nil
        default: return false
        }
    }
    
    private func completeOnboarding() {
        guard let ageValue = Int(age),
              let heightValue = Double(height),
              let weightValue = Double(weight),
              let fMin = Double(fastingMin),
              let fMax = Double(fastingMax),
              let aMin = Double(afterMealMin),
              let aMax = Double(afterMealMax) else {
            return
        }
        
        dataManager.userProfile.age = ageValue
        dataManager.userProfile.height = heightValue
        dataManager.userProfile.weight = weightValue
        dataManager.userProfile.diabetesType = selectedDiabetesType
        dataManager.userProfile.targetGlucoseFasting = fMin...fMax
        dataManager.userProfile.targetGlucoseAfterMeal = aMin...aMax
        dataManager.userProfile.isOnboardingComplete = true
        
        dataManager.saveUserProfile()
    }
}

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .padding()
                .bouncyCardEffect(delay: 0.1)
            
                Text("Welcome to SugarBalance")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fadeInEffect(delay: 0.3)
            
            Text("Your personal assistant for a balanced life")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .slideInEffect(delay: 0.4)
            
            Text("Let's set up your profile to provide you with personalized glucose management and health insights.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct PersonalInfoStepView: View {
    @Binding var age: String
    @Binding var height: String
    @Binding var weight: String
    @Binding var diabetesType: DiabetesType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Personal Information")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This information helps us provide personalized recommendations.")
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Age")
                        .font(.headline)
                    TextField("Enter your age", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Height (cm)")
                        .font(.headline)
                    TextField("Enter your height", text: $height)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Weight (kg)")
                        .font(.headline)
                    TextField("Enter your weight", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Diabetes Type")
                        .font(.headline)
                    Picker("Diabetes Type", selection: $diabetesType) {
                        ForEach(DiabetesType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct TargetRangesStepView: View {
    @Binding var fastingMin: String
    @Binding var fastingMax: String
    @Binding var afterMealMin: String
    @Binding var afterMealMax: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Target Glucose Ranges")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Set your target glucose ranges. These will help track your progress and provide personalized insights.")
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Fasting Glucose (mmol/L)")
                        .font(.headline)
                    HStack {
                        TextField("Min", text: $fastingMin)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Text("to")
                        TextField("Max", text: $fastingMax)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("After Meal Glucose (mmol/L)")
                        .font(.headline)
                    HStack {
                        TextField("Min", text: $afterMealMin)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Text("to")
                        TextField("Max", text: $afterMealMax)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CompletionStepView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your profile is ready. You can now start tracking your glucose levels and managing your health.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Remember to consult with your healthcare provider for personalized medical advice.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    OnboardingView()
}
