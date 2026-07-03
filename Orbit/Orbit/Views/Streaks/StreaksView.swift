import SwiftUI
import SwiftData

struct StreaksView: View {
    @Query private var tasks: [HabitTask]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                StarfieldView()
                    .ignoresSafeArea()
                
                if tasks.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "flame.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(Color("AccentPurple").opacity(0.6))
                        Text("No habits yet")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text("Add habits in the Habits tab to start tracking your streaks")
                            .font(.caption)
                            .foregroundStyle(Color("MutedLavender"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(tasks) { task in
                                StreakCardView(task: task)
                            }
                        }
                        .padding()
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
                        Text("Streaks")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    StreaksView()
        .modelContainer(for: HabitTask.self, inMemory: true)
}
