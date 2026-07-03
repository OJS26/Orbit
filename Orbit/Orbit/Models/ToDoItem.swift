import Foundation
import SwiftData

@Model
class ToDoItem: Identifiable {
    var id: UUID
    var title: String
    var tag: String?
    var section: Section
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var notes: String?
    
    init(title: String, tag: String? = nil, section: Section = .quick, notes: String? = nil) {
        self.id = UUID()
        self.title = title
        self.tag = tag
        self.section = section
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.notes = notes
    }
    
    enum Section: String, Codable {
        case projects
        case quick
    }
}
