import SwiftUI
import SwiftData

struct AddToDoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [ToDoItem]
    
    let selectedSection: ToDoItem.Section
    
    @State private var title = ""
    @State private var tag = ""
    @State private var notes = ""
    
    var existingTags: [String] {
        let tags = allItems.compactMap { $0.tag }.filter { !$0.isEmpty }
        return Array(Set(tags)).sorted()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            TextField("e.g. Take bins out", text: $title)
                                .padding()
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // Tag
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tag (optional)")
                                .font(.caption.bold())
                                .foregroundStyle(Color("MutedLavender"))
                            TextField("e.g. Home, Farming Sim, Music", text: $tag)
                                .padding()
                                .background(Color("CardBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                )
                            
                            if !existingTags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(existingTags, id: \.self) { existingTag in
                                            Button {
                                                tag = existingTag
                                            } label: {
                                                Text(existingTag)
                                                    .font(.caption.bold())
                                                    .foregroundStyle(tag == existingTag ? .white : Color("MutedLavender"))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(tag == existingTag ? Color("AccentPurple") : Color("CardBackground"))
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        Capsule()
                                                            .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Notes (projects only)
                        if selectedSection == .projects {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes (optional)")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color("MutedLavender"))
                                TextField("Add any extra details...", text: $notes, axis: .vertical)
                                    .lineLimit(4...6)
                                    .padding()
                                    .background(Color("CardBackground"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color("AccentPurple").opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Add Button
                        Button {
                            addItem()
                        } label: {
                            Text("Add to \(selectedSection == .quick ? "Quick" : "Projects")")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(title.isEmpty ? Color("AccentPurple").opacity(0.3) : Color("AccentPurple"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding()
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            .navigationTitle(selectedSection == .quick ? "Quick Reminder" : "New Project Task")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color("MutedLavender"))
                }
            }
        }
    }
    
    func addItem() {
        let item = ToDoItem(
            title: title,
            tag: tag.isEmpty ? nil : tag,
            section: selectedSection,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(item)
        dismiss()
    }
}
