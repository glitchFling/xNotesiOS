import SwiftUI

struct StartPageView: View {
    @State private var isAnimating = false
    @State private var textAlpha = 0.0
    @State private var scale = 0.8
    
    var onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("xNotes")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(textAlpha)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                textAlpha = 1.0
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    textAlpha = 0.0
                    scale = 1.1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onCompletion()
                }
            }
        }
    }
}

#Preview {
    StartPageView(onCompletion: {})
}
