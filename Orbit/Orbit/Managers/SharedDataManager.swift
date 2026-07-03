import Foundation

struct TaskWidgetData: Codable {
    let id: String
    let name: String
    let isCompleted: Bool
    let emoji: String
}

struct ToDoWidgetData: Codable {
    let id: String
    let title: String
    let isCompleted: Bool
    let tag: String?
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
    
    func saveToDoItems(_ items: [ToDoWidgetData]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults(suiteName: appGroupID)?.set(data, forKey: "widgetToDoItems")
        }
    }
    
    func loadToDoItems() -> [ToDoWidgetData] {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: "widgetToDoItems"),
              let items = try? JSONDecoder().decode([ToDoWidgetData].self, from: data) else {
            return []
        }
        return items
    }
}
