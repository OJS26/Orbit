

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Query private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                StarfieldView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HeaderView(tasks: tasks)
                        
                    .padding(.top, 8)
                    
                    List {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Orbit")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color("AccentPurple"))
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
