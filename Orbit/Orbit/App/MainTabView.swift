import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
            
            ToDoView()
                .tabItem {
                    Label("To Do", systemImage: "list.bullet")
                }
        }
        .tint(Color("AccentPurple"))
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Task.self, ToDoItem.self], inMemory: true)
}
