

import SwiftUI
import SwiftData
import UserNotifications

@main
struct OrbitApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasSeenOnboarding {
                    TaskListView()
                } else {
                    OnboardingView()
                }
            }
            .ignoresSafeArea()
        }
        .modelContainer(for: Task.self)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications granted")
            }
        }
    }
}
