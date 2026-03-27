import SwiftUI
import SwiftData

struct TaskListView: View {
    @Query private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    
    var sortedTasks: [Task] {
        tasks.sorted { first, second in
            if first.isCompletedToday == second.isCompletedToday {
                return first.createdAt < second.createdAt
            }
            return !first.isCompletedToday && second.isCompletedToday
        }
    }
    
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
                    
                    if tasks.isEmpty {
                        EmptyStateView()
                    } else {
                        List {
                            ForEach(sortedTasks) { task in
                                TaskRowView(task: task)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                            .onDelete(perform: deleteTasks)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .animation(.easeInOut(duration: 0.4), value: sortedTasks.map { $0.isCompletedToday })
                        .onAppear {
                            tasks.forEach { $0.resetIfNeeded() }
                            let widgetData = tasks.map { TaskWidgetData(name: $0.name, isCompleted: $0.isCompletedToday) }
                            SharedDataManager.shared.saveTasks(widgetData)
                        }
                        .onChange(of: tasks.map { $0.isCompletedToday }) {
                            let widgetData = tasks.map { TaskWidgetData(name: $0.name, isCompleted: $0.isCompletedToday) }
                            SharedDataManager.shared.saveTasks(widgetData)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .animation(.easeInOut(duration: 0.4), value: sortedTasks.map { $0.isCompletedToday })
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image("NSUStar")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                        Text("Orbit")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
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
            NotificationManager.shared.removeNotification(for: sortedTasks[index])
            modelContext.delete(sortedTasks[index])
        }
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
