import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Habits Widget

struct HabitsEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskSnapshot]
}

struct TaskSnapshot {
    let id: String
    let name: String
    let isCompleted: Bool
    let emoji: String
}

struct HabitsProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitsEntry {
        HabitsEntry(date: Date(), tasks: [
            TaskSnapshot(id: "1", name: "Brush Teeth", isCompleted: true, emoji: "🪥"),
            TaskSnapshot(id: "2", name: "Make Bed", isCompleted: false, emoji: "🛏️"),
            TaskSnapshot(id: "3", name: "Stretch", isCompleted: false, emoji: "🧘")
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitsEntry) -> Void) {
        completion(HabitsEntry(date: Date(), tasks: loadTasks()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitsEntry>) -> Void) {
        let entry = HabitsEntry(date: Date(), tasks: loadTasks())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    func loadTasks() -> [TaskSnapshot] {
        SharedDataManager.shared.loadTasks().map {
            TaskSnapshot(id: $0.id, name: $0.name, isCompleted: $0.isCompleted, emoji: $0.emoji)
        }
    }
}

struct HabitsWidgetView: View {
    var entry: HabitsEntry
    
    var displayTasks: [TaskSnapshot] {
        Array(entry.tasks.prefix(8))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Habits")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(entry.tasks.filter { $0.isCompleted }.count)/\(entry.tasks.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if entry.tasks.isEmpty {
                Text("No habits yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayTasks, id: \.id) { task in
                    HStack(spacing: 6) {
                        Button(intent: CompleteHabitIntent(taskID: task.id)) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isCompleted ? .green : .gray)
                                .font(.body)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        
                        Text("\(task.emoji.isEmpty ? "" : task.emoji + " ")\(task.name)")
                            .font(.caption)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .strikethrough(task.isCompleted)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct HabitsWidget: Widget {
    let kind: String = "HabitsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitsProvider()) { entry in
            HabitsWidgetView(entry: entry)
        }
        .configurationDisplayName("Orbit Habits")
        .description("Track and complete your daily habits")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - To Do Widget (Quick)

struct ToDoEntry: TimelineEntry {
    let date: Date
    let items: [ToDoSnapshot]
}

struct ToDoSnapshot {
    let id: String
    let title: String
    let isCompleted: Bool
    let tag: String?
}

struct ToDoProvider: TimelineProvider {
    func placeholder(in context: Context) -> ToDoEntry {
        ToDoEntry(date: Date(), items: [
            ToDoSnapshot(id: "1", title: "Take bins out", isCompleted: false, tag: "Home"),
            ToDoSnapshot(id: "2", title: "How to farm corn", isCompleted: false, tag: "Farming Sim"),
            ToDoSnapshot(id: "3", title: "Buy milk", isCompleted: true, tag: nil)
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ToDoEntry) -> Void) {
        completion(ToDoEntry(date: Date(), items: loadItems()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ToDoEntry>) -> Void) {
        let entry = ToDoEntry(date: Date(), items: loadItems())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    func loadItems() -> [ToDoSnapshot] {
        SharedDataManager.shared.loadToDoItems().map {
            ToDoSnapshot(id: $0.id, title: $0.title, isCompleted: $0.isCompleted, tag: $0.tag)
        }
    }
}

struct ToDoWidgetView: View {
    var entry: ToDoEntry
    
    var displayItems: [ToDoSnapshot] {
        Array(entry.items.prefix(8))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Quick")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            if entry.items.isEmpty {
                Text("No items yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayItems, id: \.id) { item in
                    HStack(spacing: 6) {
                        Button(intent: CompleteToDoIntent(itemID: item.id)) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isCompleted ? .green : .gray)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.title)
                                .font(.caption)
                                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                                .strikethrough(item.isCompleted)
                            if let tag = item.tag {
                                Text(tag)
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ToDoWidget: Widget {
    let kind: String = "ToDoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ToDoProvider()) { entry in
            ToDoWidgetView(entry: entry)
        }
        .configurationDisplayName("Orbit Quick")
        .description("See and complete your quick reminders")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemMedium) {
    HabitsWidget()
} timeline: {
    HabitsEntry(date: .now, tasks: [
        TaskSnapshot(id: "1", name: "Brush Teeth", isCompleted: true, emoji: "🪥"),
        TaskSnapshot(id: "2", name: "Make Bed", isCompleted: false, emoji: "🛏️"),
        TaskSnapshot(id: "3", name: "Stretch", isCompleted: false, emoji: "🧘")
    ])
}
