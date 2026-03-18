
import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskName = ""
    @State private var recurrence = Task.Recurrence.daily
    
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
        let task = Task(name: taskName, recurrence: recurrence)
        modelContext.insert(task)
        dismiss()
    }
}
