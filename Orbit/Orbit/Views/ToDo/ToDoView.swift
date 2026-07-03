import SwiftUI
import SwiftData
import WidgetKit

struct ToDoView: View {
    @Query private var items: [ToDoItem]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSection: ToDoItem.Section = .quick
    @State private var showingAddItem = false
    
    var filteredItems: [ToDoItem] {
        items.filter { $0.section == selectedSection && !$0.isCompleted }
    }
    
    var completedItems: [ToDoItem] {
        items.filter { $0.section == .projects && $0.isCompleted }
    }
    
    var groupedItems: [String: [ToDoItem]] {
        Dictionary(grouping: filteredItems) { $0.tag ?? "Other" }
    }
    
    var sortedTags: [String] {
        let tags = groupedItems.keys.sorted()
        if tags.contains("Other") {
            return tags.filter { $0 != "Other" } + ["Other"]
        }
        return tags
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SpaceBackground")
                    .ignoresSafeArea()
                
                StarfieldView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Section Toggle
                    Picker("Section", selection: $selectedSection) {
                        Text("Quick").tag(ToDoItem.Section.quick)
                        Text("Projects").tag(ToDoItem.Section.projects)
                    }
                    .pickerStyle(.segmented)
                    .tint(Color("AccentPurple"))
                    .padding()
                    
                    if filteredItems.isEmpty && completedItems.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: selectedSection == .quick ? "bolt.circle" : "folder.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(Color("AccentPurple").opacity(0.6))
                            Text(selectedSection == .quick ? "No quick reminders" : "No projects yet")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            Text(selectedSection == .quick ? "Add things you need to remember today" : "Add ongoing work, ideas and projects")
                                .font(.caption)
                                .foregroundStyle(Color("MutedLavender"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(sortedTags, id: \.self) { tag in
                                if let tagItems = groupedItems[tag] {
                                    Section {
                                        ForEach(tagItems) { item in
                                            ToDoRowView(item: item)
                                                .listRowBackground(Color.clear)
                                                .listRowSeparator(.hidden)
                                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        }
                                        .onDelete { offsets in
                                            deleteItems(offsets: offsets, from: tagItems)
                                        }
                                    } header: {
                                        Text(tag)
                                            .font(.caption.bold())
                                            .foregroundStyle(Color("AccentPurple"))
                                            .textCase(nil)
                                    }
                                }
                            }
                            
                            if selectedSection == .projects && !completedItems.isEmpty {
                                Section {
                                    ForEach(completedItems) { item in
                                        ToDoRowView(item: item)
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    }
                                } header: {
                                    Text("Completed")
                                        .font(.caption.bold())
                                        .foregroundStyle(Color("CometGreen"))
                                        .textCase(nil)
                                }
                            }
                        }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                    let toDoData = items.filter { !$0.isCompleted }.map { ToDoWidgetData(id: $0.id.uuidString, title: $0.title, isCompleted: $0.isCompleted, tag: $0.tag) }
                    SharedDataManager.shared.saveToDoItems(toDoData)
                    WidgetCenter.shared.reloadAllTimelines()
                    }
                    .onChange(of: items.map { $0.isCompleted }) {
                    let toDoData = items.filter { !$0.isCompleted }.map { ToDoWidgetData(id: $0.id.uuidString, title: $0.title, isCompleted: $0.isCompleted, tag: $0.tag) }
                    SharedDataManager.shared.saveToDoItems(toDoData)
                    WidgetCenter.shared.reloadAllTimelines()
                        }
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
                        Text("To Do")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color("AccentPurple"))
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddToDoView(selectedSection: selectedSection)
            }
        }
    }
    
    func deleteItems(offsets: IndexSet, from tagItems: [ToDoItem]) {
        for index in offsets {
            modelContext.delete(tagItems[index])
        }
    }
}

#Preview {
    ToDoView()
        .modelContainer(for: ToDoItem.self, inMemory: true)
}
