import SwiftUI

extension Animation {
    static let smoothSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let gentleSpring = Animation.spring(response: 0.8, dampingFraction: 0.9)
}

struct AnimatedScaleEffect: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.quickSpring, value: isPressed)
            .onTapGesture {
                withAnimation(.quickSpring) {
                    isPressed.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.quickSpring) {
                        isPressed.toggle()
                    }
                }
            }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct SlideInEffect: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : 50)
            .opacity(isVisible ? 1 : 0)
            .animation(.smoothSpring.delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

struct FadeInEffect: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.8).delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

struct BouncyCardEffect: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    func animatedScaleEffect() -> some View {
        modifier(AnimatedScaleEffect())
    }
    
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
    
    func slideInEffect(delay: Double = 0) -> some View {
        modifier(SlideInEffect(delay: delay))
    }
    
    func fadeInEffect(delay: Double = 0) -> some View {
        modifier(FadeInEffect(delay: delay))
    }
    
    func bouncyCardEffect(delay: Double = 0) -> some View {
        modifier(BouncyCardEffect(delay: delay))
    }
}
