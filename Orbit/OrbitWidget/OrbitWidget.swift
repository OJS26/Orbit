import WidgetKit
import SwiftUI
import SwiftData

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskSnapshot]
}

struct TaskSnapshot {
    let name: String
    let isCompleted: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), tasks: [
            TaskSnapshot(name: "Brush Teeth", isCompleted: true),
            TaskSnapshot(name: "Make Bed", isCompleted: false),
            TaskSnapshot(name: "Stretch", isCompleted: false)
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = TaskEntry(date: Date(), tasks: loadTasks())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let entry = TaskEntry(date: Date(), tasks: loadTasks())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    func loadTasks() -> [TaskSnapshot] {
        
        return []
    }
}

struct OrbitWidgetEntryView: View {
    var entry: TaskEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Orbit")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            if entry.tasks.isEmpty {
                Text("No tasks yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entry.tasks.prefix(entry.tasks.count > 5 ? 10 : 5), id: \.name) { task in
                    HStack(spacing: 6) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(task.isCompleted ? .green : .gray)
                            .font(.caption)
                        Text(task.name)
                            .font(.caption)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct OrbitWidget: Widget {
    let kind: String = "OrbitWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OrbitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Orbit Tasks")
        .description("See your daily tasks at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
#Preview(as: .systemSmall) {
    OrbitWidget()
} timeline: {
    TaskEntry(date: .now, tasks: [
        TaskSnapshot(name: "Brush Teeth", isCompleted: true),
        TaskSnapshot(name: "Make Bed", isCompleted: false),
        TaskSnapshot(name: "Stretch", isCompleted: false)
    ])
}
