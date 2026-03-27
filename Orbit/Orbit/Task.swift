
import Foundation
import SwiftData

@Model
class Task: Identifiable {
    var id: UUID
    var name: String
    var recurrence: Recurrence
    var completedDates: [TimeInterval]
    var createdAt: Date
    var resetTime :Date
    var targetCount: Int
    var notificationTimes: [TimeInterval]
    var streak: Int
    
    init(name: String, recurrence: Recurrence, resetTime: Date = Calendar.current.startOfDay(for: Date()), targetCount: Int = 1, notificationTimes: [TimeInterval] = []) {
        self.id = UUID()
        self.name = name
        self.recurrence = recurrence
        self.completedDates = []
        self.createdAt = Date()
        self.resetTime = resetTime
        self.targetCount = targetCount
        self.notificationTimes = notificationTimes
        self.streak = 0
    }
    
    enum Recurrence: String, Codable {
        case daily
        case weekly
        case biWeekly = "bi-weekly"
        case monthly
    }
    
    var completionsToday: Int {
        let calendar = Calendar.current
        return completedDates.filter { interval in
            calendar.isDateInToday(Date(timeIntervalSince1970: interval))
        }.count
    }
    
    var isCompletedToday: Bool {
        completionsToday >= targetCount
    }
    
    var nextResetDate: Date {
        let calendar = Calendar.current
        let resetHour = calendar.component(.hour, from: resetTime)
        let resetMinute = calendar.component(.minute, from: resetTime)
        
        switch recurrence {
        case .daily:
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = resetHour
            components.minute = resetMinute
            let todayReset = calendar.date(from: components)!
            if Date() < todayReset {
                return todayReset
            } else {
                return calendar.date(byAdding: .day, value: 1, to: todayReset)!
            }
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: resetTime)!
        case .biWeekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: resetTime)!
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: resetTime)!
        }
    }
    
    var resetLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: nextResetDate)
        
        switch recurrence {
        case .daily:
            return "Resets at \(timeString) tomorrow"
        case .weekly:
            return "Resets \(nextResetDate.formatted(.dateTime.weekday(.wide))) at \(timeString)"
        case .biWeekly:
            return "Resets in 2 weeks at \(timeString)"
        case .monthly:
            return "Resets \(nextResetDate.formatted(.dateTime.month().day())) at \(timeString)"
        }
    }
    
    func resetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let lastCompletion = completedDates.max().map({Date(timeIntervalSince1970: $0) }) else { return }
        
        switch recurrence {
        case .daily:
            let resetHour = calendar.component(.hour, from: resetTime)
            let resetMinute = calendar.component(.minute, from: resetTime)
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = resetHour
            components.minute = resetMinute
            let todayReset = calendar.date(from: components)!
            if now >= todayReset && lastCompletion < todayReset {
                streak = isCompletedToday ? streak + 1 : 0
                completedDates.removeAll()
            }
        case .weekly:
            let nextReset = calendar.date(byAdding: .weekOfYear, value: 1, to: resetTime)!
            if now >= nextReset && lastCompletion < nextReset {
                streak = isCompletedToday ? streak + 1 : 0
                completedDates.removeAll()
            }
        case .biWeekly:
            let nextReset = calendar.date(byAdding: .weekOfYear, value: 2, to: resetTime)!
            if now >= nextReset && lastCompletion < nextReset {
                streak = isCompletedToday ? streak + 1 : 0
                completedDates.removeAll()
            }
        case .monthly:
            let nextReset = calendar.date(byAdding: .month, value: 1, to: resetTime)!
            if now >= nextReset && lastCompletion < nextReset {
                streak = isCompletedToday ? streak + 1 : 0
                completedDates.removeAll()
            }
        }
    }
}
