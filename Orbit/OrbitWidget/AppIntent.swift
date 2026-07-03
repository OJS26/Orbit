import AppIntents
import SwiftData

struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    
    @Parameter(title: "Task ID")
    var taskID: String
    
    init() {}
    
    init(taskID: String) {
        self.taskID = taskID
    }
    
    func perform() async throws -> some IntentResult {
        let config = ModelConfiguration(groupContainer: .identifier("group.com.northstarunltd.orbit"))
        let container = try ModelContainer(for: HabitTask.self, ToDoItem.self, configurations: config)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<HabitTask>()
        let tasks = try context.fetch(descriptor)
        
        if let task = tasks.first(where: { $0.id.uuidString == taskID }) {
            if task.completionsToday < task.targetCount {
                task.completedDates.append(Date().timeIntervalSince1970)
                try context.save()
                let widgetData = tasks.map { TaskWidgetData(id: $0.id.uuidString, name: $0.name, isCompleted: $0.isCompletedToday, emoji: $0.emoji ?? "") }
                SharedDataManager.shared.saveTasks(widgetData)
            }
        }
        return .result()
    }
}

struct CompleteToDoIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete To Do"
    
    @Parameter(title: "Item ID")
    var itemID: String
    
    init() {}
    
    init(itemID: String) {
        self.itemID = itemID
    }
    
    func perform() async throws -> some IntentResult {
        let config = ModelConfiguration(groupContainer: .identifier("group.com.northstarunltd.orbit"))
        let container = try ModelContainer(for: HabitTask.self, ToDoItem.self, configurations: config)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ToDoItem>()
        let items = try context.fetch(descriptor)
        
        if let item = items.first(where: { $0.id.uuidString == itemID }) {
            item.isCompleted = true
            item.completedAt = Date()
            try context.save()
            let widgetData = items.filter { !$0.isCompleted }.map { ToDoWidgetData(id: $0.id.uuidString, title: $0.title, isCompleted: $0.isCompleted, tag: $0.tag) }
            SharedDataManager.shared.saveToDoItems(widgetData)
        }
        return .result()
    }
}
