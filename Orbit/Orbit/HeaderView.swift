
import SwiftUI

struct HeaderView: View {
    let totalTasks: Int
    let completedTasks: Int
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("\(completedTasks) of \(totalTasks) tasks complete")
                    .font(.caption)
                    .foregroundStyle(Color("MutedLavender"))
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color("CardBackground"), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color("AccentPurple"), Color("NebulaBlue")],
                            startPoint: .leading,
                            endPoint: .bottomTrailing
                    ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeIn, value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
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
    HeaderView(totalTasks: 5, completedTasks: 3)
        .padding()
        .background(Color("SpaceBackground"))
}
