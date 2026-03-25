import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: Task
    @State private var showBurst = false
    @State private var particles: [(id: UUID, angle: Double, distance: Double)] = []
    
    var burstParticles: some View {
        ForEach(particles, id: \.id) { particle in
            Circle()
                .fill(LinearGradient(
                    colors: [Color("AccentPurple"), Color("NebulaBlue")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 12, height: 12)
                .offset(
                    x: showBurst ? cos(particle.angle) * particle.distance : 0,
                    y: showBurst ? sin(particle.angle) * particle.distance : 0
                )
                .opacity(showBurst ? 0 : 1)
                .animation(.easeOut(duration: 1.2), value: showBurst)
                .allowsHitTesting(false)
        }
    }
    
    var completionButton: some View {
        ZStack {
            Circle()
                .fill(task.isCompletedToday ? Color("CometGreen") : Color("CardBackground"))
                .frame(width: 36, height: 36)
            Circle()
                .strokeBorder(task.isCompletedToday ? Color("CometGreen") : Color("AccentPurple"), lineWidth: 1.5)
                .frame(width: 36, height: 36)
            if task.isCompletedToday {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .font(.caption.bold())
            } else if task.targetCount > 1 {
                Text("\(task.completionsToday)/\(task.targetCount)")
                    .foregroundStyle(Color("MutedLavender"))
                    .font(.caption.bold())
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(task.isCompletedToday ? task.resetLabel : task.recurrence.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Color("MutedLavender"))
                if task.streak > 0 {
                    Text("🔥 \(task.streak) day streak")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            ZStack {
                burstParticles
                Button {
                    toggleComplete()
                } label: {
                    completionButton
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: task.isCompletedToday ? Color("CometGreen").opacity(0.3) : Color("AccentPurple").opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func toggleComplete() {
        if task.isCompletedToday {
            task.completedDates.removeAll { interval in
                Calendar.current.isDateInToday(Date(timeIntervalSince1970: interval))
            }
        } else {
            task.completedDates.append(Date().timeIntervalSince1970)
            triggerBurst()
        }
    }
    
    func triggerBurst() {
        particles = (0..<12).map { i in
            (
                id: UUID(),
                angle: Double(i) * (.pi * 2 / 12),
                distance: Double.random(in: 60...120)
            )
        }
        showBurst = false
        withAnimation(.easeOut(duration: 1.2)) {
            showBurst = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            particles = []
            showBurst = false
        }
    }
}

#Preview {
    TaskRowView(task: Task(name: "Brush Teeth", recurrence: .daily))
        .modelContainer(for: Task.self, inMemory: true)
        .padding()
        .background(Color("SpaceBackground"))
}
