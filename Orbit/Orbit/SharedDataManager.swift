

import Foundation

struct TaskWidgetData: Codable {
    let name: String
    let isCompleted: Bool
}

class SharedDataManager {
    static let shared = SharedDataManager()
    let appGroupID = "group.com.northstarunltd.orbit"
    
    func saveTasks(_ widgetTasks: [TaskWidgetData]) {
        if let data = try? JSONEncoder().encode(widgetTasks) {
            UserDefaults(suiteName: appGroupID)?.set(data, forKey: "widgetTasks")
        }
    }
    
    func loadTasks() -> [TaskWidgetData] {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: "widgetTasks"),
              let tasks = try? JSONDecoder().decode([TaskWidgetData].self, from: data) else {
            return []
        }
        return tasks
    }
}
