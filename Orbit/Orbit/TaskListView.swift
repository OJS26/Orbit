
import SwiftUI
import SwiftData

struct TaskListView: View {
    @Query private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRowView(task: task)
            }
            .navigationTitle("Orbit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
