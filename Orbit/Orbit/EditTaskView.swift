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
    @State private var emoji: String
    @State private var customInterval: Int
    @State private var customUnit: String
    @State private var customWeekdays: [Int]
    @State private var customDayOfMonth: Int
    
    init(task: Task) {
        self.task = task
        _taskName = State(initialValue: task.name)
        _recurrence = State(initialValue: task.recurrence)
        _resetTime = State(initialValue: task.resetTime)
        _targetCount = State(initialValue: task.targetCount)
        _notificationCount = State(initialValue: max(1, task.notificationTimes.count))
        _notificationTimes = State(initialValue: task.notificationTimes.isEmpty ? [Date()] : task.notificationTimes.map { Date(timeIntervalSince1970: $0) })
        _emoji = State(initialValue: task.emoji ?? "")
        _customInterval = State(initialValue: task.customInterval ?? 1)
        _customUnit = State(initialValue: task.customUnit ?? "days")
        _customWeekdays = State(initialValue: task.customWeekdays)
        _customDayOfMonth = State(initialValue: task.customDayOfMonth ?? 1)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Task Name + Emoji
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Name")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            HStack(spacing: 0) {
                                EmojiTextField(text: $emoji)
                                    .frame(width: 52, height: 52)
                                    .background(Color("SpaceBackground"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                    )
                                
                                TextField("e.g. Brush Teeth", text: $taskName)
                                    .padding()
                                    .frame(height: 52)
                                    .background(Color("CardBackground"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Recurrence
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeats")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            
                            Picker("Recurrence", selection: $recurrence) {
                                Text("Daily").tag(Task.Recurrence.daily)
                                Text("Weekly").tag(Task.Recurrence.weekly)
                                Text("Bi-Weekly").tag(Task.Recurrence.biWeekly)
                                Text("Monthly").tag(Task.Recurrence.monthly)
                                Text("Yearly").tag(Task.Recurrence.yearly)
                                Text("Custom").tag(Task.Recurrence.custom)
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AccentPurple"))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("CardBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                            )
                            
                            if recurrence == .custom {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Every")
                                            .foregroundStyle(.white)
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Button {
                                                if customInterval > 1 { customInterval -= 1 }
                                            } label: {
                                                Image(systemName: "minus")
                                                    .frame(width: 36, height: 36)
                                                    .foregroundStyle(Color("AccentPurple"))
                                            }
                                            Text("\(customInterval)")
                                                .frame(width: 36)
                                                .foregroundStyle(.white)
                                            Button {
                                                customInterval += 1
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
                                    
                                    Picker("Unit", selection: $customUnit) {
                                        Text("Days").tag("days")
                                        Text("Weeks").tag("weeks")
                                        Text("Months").tag("months")
                                        Text("Years").tag("years")
                                    }
                                    .pickerStyle(.segmented)
                                    .tint(Color("AccentPurple"))
                                    
                                    if customUnit == "weeks" {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("On these days")
                                                .font(.caption.bold())
                                                .foregroundStyle(Color("MutedLavender"))
                                            HStack(spacing: 8) {
                                                ForEach(1...7, id: \.self) { day in
                                                    let dayNames = ["M", "T", "W", "T", "F", "S", "S"]
                                                    Button {
                                                        if customWeekdays.contains(day) {
                                                            customWeekdays.removeAll { $0 == day }
                                                        } else {
                                                            customWeekdays.append(day)
                                                        }
                                                    } label: {
                                                        Text(dayNames[day - 1])
                                                            .font(.caption.bold())
                                                            .frame(width: 36, height: 36)
                                                            .background(customWeekdays.contains(day) ? Color("AccentPurple") : Color("CardBackground"))
                                                            .foregroundStyle(customWeekdays.contains(day) ? .white : Color("MutedLavender"))
                                                            .clipShape(Circle())
                                                            .overlay(
                                                                Circle()
                                                                    .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                                            )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    if customUnit == "months" || customUnit == "years" {
                                        HStack {
                                            Text("On day")
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Picker("Day", selection: $customDayOfMonth) {
                                                ForEach(1...31, id: \.self) { day in
                                                    Text("\(day)").tag(day)
                                                }
                                            }
                                            .pickerStyle(.menu)
                                            .tint(Color("AccentPurple"))
                                        }
                                        .padding()
                                        .background(Color("CardBackground"))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                        )
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(.easeInOut, value: recurrence)
                            }
                        }
                        
                        // Reset Time
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
                        
                        // Times Per Period
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
                        
                        // Reminders
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminders")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            
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
                        
                        // Save Button
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
        task.emoji = emoji.isEmpty ? nil : emoji
        task.customInterval = recurrence == .custom ? customInterval : nil
        task.customUnit = recurrence == .custom ? customUnit : nil
        task.customWeekdays = recurrence == .custom && customUnit == "weeks" ? customWeekdays : []
        task.customDayOfMonth = recurrence == .custom && (customUnit == "months" || customUnit == "years") ? customDayOfMonth : nil
        NotificationManager.shared.scheduleNotification(for: task)
        dismiss()
    }
}
