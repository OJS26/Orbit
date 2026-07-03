import SwiftUI
import SwiftData

struct ToDoRowView: View {
    @Environment(\.modelContext) private var modelContext
    let item: ToDoItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(item.isCompleted ? Color("MutedLavender") : .white)
                    .strikethrough(item.isCompleted)
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(Color("MutedLavender"))
                }
            }
            
            Spacer()
            
            Button {
                toggleComplete()
            } label: {
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? Color("CometGreen") : Color("CardBackground"))
                        .frame(width: 36, height: 36)
                    Circle()
                        .strokeBorder(item.isCompleted ? Color("CometGreen") : Color("AccentPurple"), lineWidth: 1.5)
                        .frame(width: 36, height: 36)
                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .font(.caption.bold())
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: item.isCompleted ? Color("CometGreen").opacity(0.3) : Color("AccentPurple").opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func toggleComplete() {
        withAnimation {
            item.isCompleted.toggle()
            item.completedAt = item.isCompleted ? Date() : nil
            if item.isCompleted && item.section == .quick {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    modelContext.delete(item)
                }
            }
        }
    }
}
