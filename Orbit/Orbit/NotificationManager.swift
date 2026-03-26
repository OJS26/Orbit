

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(task.name)"
        content.body = "Keep your orbit going - tap to complete your task."
        content.sound = .default
        
        let calendar = Calendar.current
        let resetHour = calendar.component(.hour, from: task.resetTime)
        let resetMinute = calendar.component(.minute, from: task.resetTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = resetHour
        dateComponents.minute = resetMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
        
        func removeNotification(for task: Task) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        }
        
        func rescheduleAll(tasks: [Task]) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            tasks.forEach { scheduleNotification(for: $0) }
        }
    }
