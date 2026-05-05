import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Note> { !$0.isDeleted }, sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        NoteRow(note: note)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("xNotes")
            .searchable(text: $searchText, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addNote) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if filteredNotes.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Notes" : "No Results",
                        systemImage: searchText.isEmpty ? "note.text" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Tap + to create a new note." : "Try searching for something else.")
                    )
                }
            }
        }
    }
    
    private func addNote() {
        withAnimation {
            let newNote = Note(title: "New Note", content: "")
            modelContext.insert(newNote)
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                notes[index].isDeleted = true
            }
        }
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if note.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(note.content.prefix(100))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(note.updatedAt, style: .date)
                .font(.caption2)
                .foregroundColor(.tertiaryLabel)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    NoteListView()
        .modelContainer(for: Note.self, inMemory: true)
}
