

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleNotification(for task: Task) {
        removeNotification(for: task)
        
        for (index, interval) in task.notificationTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Time for \(task.name)"
            content.body = task.targetCount > 1 ? "You have \(task.targetCount) completions to do today." : "Keep your orbit going — tap to complete your task."
            content.sound = .default
            
            let date = Date(timeIntervalSince1970: interval)
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.hour = calendar.component(.hour, from: date)
            dateComponents.minute = calendar.component(.minute, from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(task.id.uuidString)-\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }

    func removeNotification(for task: Task) {
        let identifiers = task.notificationTimes.enumerated().map { "\(task.id.uuidString)-\($0.offset)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
        
        func rescheduleAll(tasks: [Task]) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            tasks.forEach { scheduleNotification(for: $0) }
        }
    }
