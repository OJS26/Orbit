
import Foundation
import SwiftData

@Model
class Task {
    var id: UUID
    var name: String
    var recurrence: Recurrence
    var completedDates: [TimeInterval]
    var createdAt: Data
    
    init(name: String, recurrence: Recurrence) {
        self.id = UUID()
        self.name = name
        self.recurrence = recurrence
        self.completedDates = []
        self.createdAt = Data()
    }
    
    enum Recurrence: String, Codable {
        case daily
        case weekly
        case biWeekly = "bi-weekly"
        case monthly
    }
    
    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completedDates.contains { interval in
            let date = Date(timeIntervalSince1970: interval)
            return calendar.isDateInToday(date)
        }
    }
}
