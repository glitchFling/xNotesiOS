import SwiftUI
import SwiftData
import LocalAuthentication

// Note: In a real project, you would add the MarkdownUI package via SPM.
// import MarkdownUI 

struct NoteDetailView: View {
    @Bindable var note: Note
    @State private var isEditing = true
    @State private var isUnlocked = false
    @State private var showingAuthError = false
    
    var body: some View {
        VStack {
            if note.isLocked && !isUnlocked {
                LockedNoteView(unlockAction: authenticate)
            } else {
                VStack(spacing: 0) {
                    TextField("Title", text: $note.title)
                        .font(.title)
                        .bold()
                        .padding()
                    
                    Divider()
                    
                    if isEditing {
                        TextEditor(text: $note.content)
                            .font(.body)
                            .padding()
                    } else {
                        ScrollView {
                            // Fallback to SwiftUI native markdown support if MarkdownUI isn't available
                            Text(LocalizedStringKey(note.content))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: { isEditing.toggle() }) {
                                Label(isEditing ? "Preview" : "Edit", systemImage: isEditing ? "eye" : "pencil")
                            }
                            
                            Menu {
                                Button(action: toggleLock) {
                                    Label(note.isLocked ? "Unlock Note" : "Lock Note", systemImage: note.isLocked ? "lock.open" : "lock")
                                }
                                
                                Button(role: .destructive, action: { note.isDeleted = true }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if !note.isLocked {
                isUnlocked = true
            }
        }
        .onChange(of: note.content) {
            note.updatedAt = Date()
        }
        .onChange(of: note.title) {
            note.updatedAt = Date()
        }
    }
    
    private func toggleLock() {
        if note.isLocked {
            // If already locked, we need to authenticate to unlock it permanently (toggle off)
            authenticate { success in
                if success {
                    note.isLocked = false
                }
            }
        } else {
            // Lock it
            note.isLocked = true
            isUnlocked = false
        }
    }
    
    private func authenticate(completion: ((Bool) -> Void)? = nil) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your note"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        completion?(true)
                    } else {
                        showingAuthError = true
                        completion?(false)
                    }
                }
            }
        } else {
            // No biometrics, fallback or just allow (for demo)
            isUnlocked = true
            completion?(true)
        }
    }
}

struct LockedNoteView: View {
    var unlockAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("This note is locked")
                .font(.title2)
                .bold()
            
            Button("Unlock Note", action: unlockAction)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NoteDetailView(note: Note(title: "Sample Note", content: "Hello *Markdown*"))
}
