
import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.name)
                    .font(.headline)
                Text(task.isCompletedToday ? task.resetLabel : task.recurrence.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                toggleComplete()
            } label: {
                Image(systemName: task.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompletedToday ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
    
    func toggleComplete() {
        if task.isCompletedToday {
            task.completedDates.removeAll { interval in
                Calendar.current.isDateInToday(Date(timeIntervalSince1970: interval))
            }
        } else {
            task.completedDates.append(Date().timeIntervalSince1970)
        }
    }
}
#Preview {
    TaskRowView(task: Task(name: "Brush Teeth", recurrence: .daily))
        .modelContainer(for: Task.self, inMemory: true)
}
