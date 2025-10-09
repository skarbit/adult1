import SwiftUI

struct DisclaimerView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                
                Text("DISCLAIMER")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("This app is not a medical device and does not provide medical advice, diagnosis, or treatment. All data and recommendations are for informational purposes only and should not replace professional healthcare guidance.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Always consult your doctor or qualified healthcare provider before making any decisions related to your health.")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: {
                    acceptDisclaimer()
                }) {
                    Text("I Understand")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red)
                        )
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func acceptDisclaimer() {
        dataManager.userProfile.disclaimerAccepted = true
        dataManager.saveUserProfile()
    }
}

#Preview {
    DisclaimerView()
}

