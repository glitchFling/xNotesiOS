import AppIntents
import SwiftData
import Foundation

struct AddNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Add xNote"
    static var description = IntentDescription("Creates a new note in xNotes.")

    @Parameter(title: "Title")
    var title: String?

    @Parameter(title: "Content")
    var content: String?

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let context = try ModelContext(ModelContainer(for: Note.self))
        let newNote = Note(title: title ?? "New Note", content: content ?? "")
        context.insert(newNote)
        try context.save()
        return .result(value: "Note created: \(newNote.title)")
    }
}

struct ToggleLockIntent: AppIntent {
    static var title: LocalizedStringResource = "Lock/Unlock xNote"
    
    @Parameter(title: "Note Title")
    var noteTitle: String

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(for: Note.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.title == noteTitle })
        let notes = try context.fetch(descriptor)
        
        if let note = notes.first {
            note.isLocked.toggle()
            try context.save()
            return .result(dialog: "Toggled lock for \(noteTitle)")
        } else {
            return .result(dialog: "Note not found.")
        }
    }
}

struct DeleteNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete xNote"
    
    @Parameter(title: "Note Title")
    var noteTitle: String

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(for: Note.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.title == noteTitle })
        let notes = try context.fetch(descriptor)
        
        if let note = notes.first {
            note.isDeleted = true
            try context.save()
            return .result(dialog: "Deleted \(noteTitle)")
        } else {
            return .result(dialog: "Note not found.")
        }
    }
}

struct xNotesShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddNoteIntent(),
            phrases: ["Add a note to xNotes", "New xNote"],
            shortTitle: "Add Note",
            systemImageName: "plus.rectangle.on.folder"
        )
    }
}
