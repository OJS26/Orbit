import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskName = ""
    @State private var recurrence = Task.Recurrence.daily
    @State private var resetTime = Calendar.current.startOfDay(for: Date())
    @State private var targetCount = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Task Name
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
                            }
                            .pickerStyle(.segmented)
                            .tint(Color("AccentPurple"))
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
                        
                        // Target Count
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
                        
                        // Add Button
                        Button {
                            addTask()
                        } label: {
                            Text("Add Task")
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
            .navigationTitle("New Task")
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
    
    func addTask() {
        let task = Task(name: taskName, recurrence: recurrence, resetTime: resetTime, targetCount: targetCount)
        modelContext.insert(task)
        dismiss()
    }
}
