import SwiftUI

struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.easeInOut, value: message)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isShowing {
                ToastView(message: message)
                    .padding(.top, 30)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, duration: TimeInterval = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, duration: duration))
    }
}
