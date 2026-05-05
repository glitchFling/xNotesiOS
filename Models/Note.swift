import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isLocked: Bool
    var isDeleted: Bool
    
    init(title: String = "", content: String = "", isLocked: Bool = false) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isLocked = isLocked
        self.isDeleted = false
    }
}
