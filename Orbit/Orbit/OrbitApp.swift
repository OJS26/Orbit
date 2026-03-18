

import SwiftUI
import SwiftData

@main
struct OrbitApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
        .modelContainer(for: Task.self)
    }
}
