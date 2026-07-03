import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
            
            StreaksView()
                .tabItem {
                    Label("Streaks", systemImage: "flame")
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
        .modelContainer(for: [HabitTask.self, ToDoItem.self], inMemory: true)
}
