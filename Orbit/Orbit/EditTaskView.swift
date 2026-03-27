

import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let task: Task
    
    @State private var taskName: String
    @State private var recurrence: Task.Recurrence
    @State private var resetTime: Date
    @State private var targetCount: Int
    @State private var notificationCount: Int
    @State private var notificationTimes: [Date]
    
    init(task: Task) {
        self.task = task
        _taskName = State(initialValue: task.name)
        _recurrence = State(initialValue: task.recurrence)
        _resetTime = State(initialValue: task.resetTime)
        _targetCount = State(initialValue: task.targetCount)
        _notificationCount = State(initialValue: task.notificationTimes.count)
        _notificationTimes = State(initialValue: task.notificationTimes.isEmpty ? [Date()] : task.notificationTimes.map { Date(timeIntervalSince1970: $0) })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Name")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            TextField("e.g. Brush Teeth", text: $taskName)
                                .padding()
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeats")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            Picker("Recurrence", selection: $recurrence) {
                                Text("Daily").tag(Task.Recurrence.daily)
                                Text("Weekly").tag(Task.Recurrence.weekly)
                                Text("Bi-Weekly").tag(Task.Recurrence.biWeekly)
                                Text("Monthly").tag(Task.Recurrence.monthly)
                            }
                            .pickerStyle(.segmented)
                            .tint(Color("AccentPurple"))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reset Time")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            DatePicker("Resets at", selection: $resetTime, displayedComponents: .hourAndMinute)
                                .padding()
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)
                                .tint(Color("AccentPurple"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Times Per Period")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            HStack {
                                Text("\(targetCount)x per \(recurrence.rawValue)")
                                    .foregroundStyle(.white)
                                Spacer()
                                HStack(spacing: 0) {
                                    Button {
                                        if targetCount > 1 { targetCount -= 1 }
                                    } label: {
                                        Image(systemName: "minus")
                                            .frame(width: 36, height: 36)
                                            .foregroundStyle(Color("AccentPurple"))
                                    }
                                    Text("\(targetCount)")
                                        .frame(width: 36)
                                        .foregroundStyle(.white)
                                    Button {
                                        if targetCount < 10 { targetCount += 1 }
                                    } label: {
                                        Image(systemName: "plus")
                                            .frame(width: 36, height: 36)
                                            .foregroundStyle(Color("AccentPurple"))
                                    }
                                }
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                            }
                            .padding()
                            .background(Color("CardBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Notification Times
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminders")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            
                            // How many reminders
                            HStack {
                                Text("\(notificationCount) reminder\(notificationCount > 1 ? "s" : "")")
                                    .foregroundStyle(.white)
                                Spacer()
                                HStack(spacing: 0) {
                                    Button {
                                        if notificationCount > 1 {
                                            notificationCount -= 1
                                            notificationTimes.removeLast()
                                        }
                                    } label: {
                                        Image(systemName: "minus")
                                            .frame(width: 36, height: 36)
                                            .foregroundStyle(Color("AccentPurple"))
                                    }
                                    Text("\(notificationCount)")
                                        .frame(width: 36)
                                        .foregroundStyle(.white)
                                    Button {
                                        if notificationCount < targetCount {
                                            notificationCount += 1
                                            notificationTimes.append(Date())
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .frame(width: 36, height: 36)
                                            .foregroundStyle(Color("AccentPurple"))
                                    }
                                }
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                            }
                            .padding()
                            .background(Color("CardBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                            )
                            
                            // Time pickers for each reminder
                            ForEach(0..<notificationCount, id: \.self) { index in
                                DatePicker(
                                    "Reminder \(index + 1)",
                                    selection: Binding(
                                        get: { notificationTimes[index] },
                                        set: { notificationTimes[index] = $0 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .padding()
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)
                                .tint(Color("AccentPurple"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                            }
                        }
                        
                        Button {
                            saveTask()
                        } label: {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(taskName.isEmpty ? Color("AccentPurple").opacity(0.3) : Color("AccentPurple"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(taskName.isEmpty)
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Task")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color("MutedLavender"))
                }
            }
        }
    }
    
    func saveTask() {
        let times = notificationTimes.prefix(notificationCount).map { $0.timeIntervalSince1970 }
        task.name = taskName
        task.recurrence = recurrence
        task.resetTime = notificationTimes.first ?? Date()
        task.targetCount = targetCount
        task.notificationTimes = Array(times)
        NotificationManager.shared.scheduleNotification(for: task)
        dismiss()
    }
}
