
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
            Form {
                Section("Task Name") {
                    TextField("e.g. Brush Teeth", text: $taskName)
                }
                
                Section("Repeats") {
                    Picker("Recurrnce", selection: $recurrence) {
                        Text("Daily").tag(Task.Recurrence.daily)
                        Text("Weekly").tag(Task.Recurrence.weekly)
                        Text("Bi-Weekly").tag(Task.Recurrence.biWeekly)
                        Text("Monthly").tag(Task.Recurrence.monthly)
                    
                    }
                    
                    Section("Reset Time") {
                        DatePicker("Resets at", selection: $resetTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Section("Times per day") {
                        Stepper("\(targetCount)x per \(recurrence.rawValue)", value: $targetCount, in: 1...10)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(taskName.isEmpty)
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
