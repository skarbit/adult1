import SwiftUI

struct LoadingScreen: View {
    @State private var opacity = 0.0
    @State private var scale = 0.7
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}

