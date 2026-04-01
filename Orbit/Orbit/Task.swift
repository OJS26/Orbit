
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
    var emoji: String?
    var customInterval: Int?
    var customUnit: String?
    var customWeekdays: [Int]
    var customDayOfMonth: Int?
    
    init(name: String, recurrence: Recurrence = .daily, resetTime: Date = Calendar.current.startOfDay(for: Date()), targetCount: Int = 1, notificationTimes: [TimeInterval] = [], emoji: String? = nil, customInterval: Int? = nil, customUnit: String? = nil, customWeekdays: [Int] = [], customDayOfMonth: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.recurrence = recurrence
        self.completedDates = []
        self.createdAt = Date()
        self.resetTime = resetTime
        self.targetCount = targetCount
        self.notificationTimes = notificationTimes
        self.streak = 0
        self.emoji = emoji
        self.customInterval = customInterval
        self.customUnit = customUnit
        self.customWeekdays = customWeekdays
        self.customDayOfMonth = customDayOfMonth
    }
    
    enum Recurrence: String, Codable {
        case daily
        case weekly
        case biWeekly = "bi-weekly"
        case monthly
        case yearly
        case custom
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
    
    var isScheduledToday: Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        
        switch recurrence {
        case .daily:
            return true
        case .weekly:
            let createdWeekday = calendar.component(.weekday, from: createdAt)
            let adjustedCreated = createdWeekday == 1 ? 7 : createdWeekday - 1
            return adjustedWeekday == adjustedCreated
        case .biWeekly:
            let daysSinceCreated = calendar.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
            let createdWeekday = calendar.component(.weekday, from: createdAt)
            let adjustedCreated = createdWeekday == 1 ? 7 : createdWeekday - 1
            return adjustedWeekday == adjustedCreated && (daysSinceCreated / 7) % 2 == 0
        case .monthly:
            let createdDay = calendar.component(.day, from: createdAt)
            let todayDay = calendar.component(.day, from: Date())
            return todayDay == createdDay
        case .yearly:
            let createdMonth = calendar.component(.month, from: createdAt)
            let createdDay = calendar.component(.day, from: createdAt)
            let todayMonth = calendar.component(.month, from: Date())
            let todayDay = calendar.component(.day, from: Date())
            return todayMonth == createdMonth && todayDay == createdDay
        case .custom:
            guard let unit = customUnit, let _ = customInterval else { return true }
            switch unit {
            case "weeks":
                if !customWeekdays.isEmpty {
                    return customWeekdays.contains(adjustedWeekday)
                }
                return true
            case "months", "years":
                if let day = customDayOfMonth {
                    let todayDay = calendar.component(.day, from: Date())
                    return todayDay == day
                }
                return true
            default:
                return true
            }
        }
    }

    var recurrenceLabel: String {
        switch recurrence {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biWeekly: return "Bi-Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .custom:
            guard let unit = customUnit, let interval = customInterval else { return "Custom" }
            if unit == "weeks" && !customWeekdays.isEmpty {
                let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                let selectedDays = customWeekdays.sorted().map { days[$0 - 1] }.joined(separator: ", ")
                return "Every \(selectedDays)"
            }
            if let day = customDayOfMonth, (unit == "months" || unit == "years") {
                return "Every \(interval) \(unit) on the \(day)"
            }
            return "Every \(interval) \(unit)"
        }
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
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: resetTime)!
        case .custom:
            guard let unit = customUnit, let interval = customInterval else { return Date() }
            let component: Calendar.Component
            switch unit {
            case "days": component = .day
            case "weeks": component = .weekOfYear
            case "months": component = .month
            case "years": component = .year
            default: return Date()
            }
            return calendar.date(byAdding: component, value: interval, to: resetTime)!
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
        case .yearly:
            return "Resets \(nextResetDate.formatted(.dateTime.month().day())) at \(formatter.string(from: nextResetDate))"
        case .custom:
            return "Resets \(nextResetDate.formatted(.dateTime.month(.abbreviated).day()))"
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
        case .yearly:
            let nextReset = calendar.date(byAdding: .year, value: 1, to: resetTime)!
            if now >= nextReset && lastCompletion < nextReset {
                streak = isCompletedToday ? streak + 1 : 0
                completedDates.removeAll()
            }
        case .custom:
            guard let unit = customUnit, let interval = customInterval else { return }
            let component: Calendar.Component
            switch unit {
            case "days": component = .day
            case "weeks": component = .weekOfYear
            case "months": component = .month
            case "years": component = .year
            default: return
            }
            let nextReset = calendar.date(byAdding: component, value: interval, to: resetTime)!
            if now >= nextReset && lastCompletion < nextReset {
                streak = isCompletedToday ? streak + 1 : 0
                completedDates.removeAll()
            }
        }
    }
}
