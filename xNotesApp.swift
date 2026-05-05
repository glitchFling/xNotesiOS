import SwiftUI
import SwiftData

@main
struct xNotesApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var isSplashScreenActive = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .private("iCloud.com.example.xNotes"))

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isSplashScreenActive {
                    StartPageView {
                        isSplashScreenActive = false
                    }
                } else if !hasCompletedOnboarding {
                    WelcomeView()
                } else {
                    NoteListView()
                }
            }
            .modelContainer(sharedModelContainer)
        }
    }
}
