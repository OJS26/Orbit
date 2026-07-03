import SwiftUI
import SwiftData

struct HeaderView: View {
    let tasks: [Task]
    
    var totalProgress: Double {
        tasks.reduce(0.0) { $0 + min(Double($1.completionsToday) / Double($1.targetCount), 1.0) }
    }
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return totalProgress / Double(tasks.count)
    }
    
    var progressText: String {
        let completed = totalProgress
        let total = Double(tasks.count)
        if completed == total {
            return "All tasks complete 🎉"
        }
        return String(format: "%.1f of %d tasks complete", completed, tasks.count)
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color("CardBackground"), lineWidth: 6)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color("AccentPurple"), Color("NebulaBlue")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(progressText)
                    .font(.caption)
                    .foregroundStyle(Color("MutedLavender"))
            }
            
            Spacer()
            
            progressRing
            
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("AccentPurple").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    HeaderView(tasks: [])
        .padding()
        .background(Color("SpaceBackground"))
}
