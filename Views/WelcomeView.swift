import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    TutorialSlide(
                        title: "Markdown Magic",
                        description: "Write in plain text and see it transform into beautiful rich text instantly.",
                        animation: .markdown
                    )
                    .tag(0)
                    
                    TutorialSlide(
                        title: "Secure Your Thoughts",
                        description: "Keep sensitive notes private with biometric locking and encryption.",
                        animation: .lock
                    )
                    .tag(1)
                    
                    TutorialSlide(
                        title: "Shortcuts Ready",
                        description: "Add, delete, and lock notes using iOS Shortcuts for ultimate productivity.",
                        animation: .shortcuts
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Button(action: {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
        }
    }
}

enum TutorialAnimationType {
    case markdown, lock, shortcuts
}

struct TutorialSlide: View {
    let title: String
    let description: String
    let animation: TutorialAnimationType
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            tutorialAnimation
                .frame(height: 200)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.title)
                    .bold()
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var tutorialAnimation: some View {
        switch animation {
        case .markdown:
            MarkdownAnimation()
        case .lock:
            LockAnimation()
        case .shortcuts:
            ShortcutsAnimation()
        }
    }
}

struct MarkdownAnimation: View {
    @State private var isShowingRichText = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(radius: 5)
            
            if isShowingRichText {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Markdown Title")
                        .font(.title2)
                        .bold()
                    Text("This is **bold** and *italic*.")
                        .italic()
                }
                .transition(.opacity)
            } else {
                Text("# Markdown Title\nThis is **bold** and *italic*.")
                    .font(.system(.body, design: .monospaced))
                    .transition(.opacity)
            }
        }
        .frame(width: 250, height: 150)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isShowingRichText.toggle()
            }
        }
    }
}

struct LockAnimation: View {
    @State private var isLocked = true
    
    var body: some View {
        VStack {
            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                .font(.system(size: 80))
                .foregroundColor(isLocked ? .red : .green)
                .scaleEffect(isLocked ? 1.0 : 1.2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isLocked.toggle()
            }
        }
    }
}

struct ShortcutsAnimation: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 100, height: 100)
            
            Image(systemName: "bolt.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .offset(y: offset)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                offset = -10
            }
        }
    }
}

#Preview {
    WelcomeView()
}
