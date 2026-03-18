
import SwiftUI
import SwiftData

struct TaskListView: View {
    @Query private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRowView(task: task)
                    }
                    .navigationTitle("Orbit")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showingAddTask = true
                                
                            } label: {
                                Image(systemName: "plus")
                        }
                    }
                }
                    .sheet(isPresented: $showingAddTask) {
                        AddTaskView()
                    }
                    .onAppear {
                        tasks.forEach { $0.resetIfNeeded() }
                    }
        }
    }
}
#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
