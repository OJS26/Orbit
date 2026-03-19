import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(task.isCompletedToday ? task.resetLabel : task.recurrence.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Color("MutedLavender"))
                if task.streak > 0 {
                    Text("🔥 \(task.streak) day streak")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Button {
                toggleComplete()
            } label: {
                if task.targetCount > 1 {
                    ZStack {
                        Circle()
                            .fill(task.isCompletedToday ? Color("CometGreen") : Color("CardBackground"))
                            .frame(width: 36, height: 36)
                        Circle()
                            .strokeBorder(task.isCompletedToday ? Color("CometGreen") : Color("AccentPurple"), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                        if task.isCompletedToday {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.caption.bold())
                        } else {
                            Text("\(task.completionsToday)/\(task.targetCount)")
                                .foregroundStyle(Color("MutedLavender"))
                                .font(.caption.bold())
                        }
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(task.isCompletedToday ? Color("CometGreen") : Color("CardBackground"))
                            .frame(width: 36, height: 36)
                        Circle()
                            .strokeBorder(task.isCompletedToday ? Color("CometGreen") : Color("AccentPurple"), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                        if task.isCompletedToday {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.caption.bold())
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: task.isCompletedToday ? Color("CometGreen").opacity(0.3) : Color("AccentPurple").opacity(0.3), radius: 8, x: 0, y: 4)
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
        .padding()
        .background(Color("SpaceBackground"))
}
