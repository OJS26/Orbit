import SwiftUI
import SwiftData

struct StreakCardView: View {
    let task: Task
    
    var allCompletionDates: [Date] {
        let historical = task.completionHistory.map { Date(timeIntervalSince1970: $0) }
        let current = task.completedDates.map { Date(timeIntervalSince1970: $0) }
        return historical + current
    }
    
    var totalCompletions: Int {
        allCompletionDates.count
    }
    
    var completionRate: Double {
        let calendar = Calendar.current
        let daysSinceCreated = calendar.dateComponents([.day], from: task.createdAt, to: Date()).day ?? 1
        guard daysSinceCreated > 0 else { return 0 }
        let uniqueDays = Set(allCompletionDates.map { calendar.startOfDay(for: $0) }).count
        return Double(uniqueDays) / Double(daysSinceCreated) * 100
    }
    
    var bestStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(allCompletionDates.map { calendar.startOfDay(for: $0) })
            .sorted()
        var best = 0
        var current = 0
        var previousDay: Date?
        for day in uniqueDays {
            if let prev = previousDay,
               calendar.dateComponents([.day], from: prev, to: day).day == 1 {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
            previousDay = day
        }
        return best
    }
    
    var weeks: [[Date?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let earliest = calendar.date(byAdding: .day, value: -29, to: today)!
        let weekday = calendar.component(.weekday, from: earliest)
        let daysToMonday = (weekday + 5) % 7
        let gridStart = calendar.date(byAdding: .day, value: -daysToMonday, to: earliest)!
        
        var allDays: [Date?] = []
        var current = gridStart
        while current <= today {
            allDays.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        while allDays.count % 7 != 0 {
            allDays.append(nil)
        }
        var result: [[Date?]] = []
        stride(from: 0, to: allDays.count, by: 7).forEach { i in
            result.append(Array(allDays[i..<min(i+7, allDays.count)]))
        }
        return result
    }
    
    func completionLevel(for day: Date) -> Int {
        let calendar = Calendar.current
        let completionsOnDay = allCompletionDates.filter {
            calendar.isDate($0, inSameDayAs: day)
        }.count
        if completionsOnDay == 0 { return 0 }
        if completionsOnDay >= task.targetCount { return 2 }
        return 1
    }
    
    func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 1: return Color("NebulaBlue")
        case 2: return Color("CometGreen")
        default: return Color("CardBackground")
        }
    }
    
    var monthLabels: some View {
        HStack(alignment: .top, spacing: 3) {
            Text("").frame(width: 14)
            ForEach(weeks.indices, id: \.self) { weekIndex in
                let week = weeks[weekIndex]
                let firstDay = week.compactMap { $0 }.first
                let isFirstWeekOfMonth = firstDay.map {
                    Calendar.current.component(.day, from: $0) <= 7
                } ?? false
                let monthName = firstDay.map {
                    Calendar.current.shortMonthSymbols[Calendar.current.component(.month, from: $0) - 1]
                } ?? ""
                Text(isFirstWeekOfMonth ? monthName : "")
                    .font(.system(size: 8))
                    .foregroundStyle(Color("MutedLavender"))
                    .frame(width: 10)
            }
        }
    }
    
    var grid: some View {
        HStack(alignment: .top, spacing: 3) {
            VStack(spacing: 3) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8))
                        .foregroundStyle(Color("MutedLavender"))
                        .frame(width: 14, height: 10)
                }
            }
            ForEach(weeks.indices, id: \.self) { weekIndex in
                VStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = weeks[weekIndex][dayIndex] {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorForLevel(completionLevel(for: day)))
                                .frame(width: 10, height: 10)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.clear)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
        }
    }
    
    var legend: some View {
        HStack(spacing: 6) {
            Text("Less")
                .font(.system(size: 8))
                .foregroundStyle(Color("MutedLavender"))
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("CardBackground").opacity(0.5))
                .frame(width: 10, height: 10)
                .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(Color("MutedLavender").opacity(0.3), lineWidth: 0.5))
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("NebulaBlue"))
                .frame(width: 10, height: 10)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("CometGreen"))
                .frame(width: 10, height: 10)
            Text("More")
                .font(.system(size: 8))
                .foregroundStyle(Color("MutedLavender"))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                HStack(spacing: 6) {
                    if let emoji = task.emoji, !emoji.isEmpty {
                        Text(emoji)
                            .font(.headline)
                    }
                    Text(task.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                Spacer()
                Text("🔥 \(task.streak)")
                    .font(.headline)
                    .foregroundStyle(.orange)
            }
            
            // Stats row
            HStack(spacing: 0) {
                statView(value: "\(totalCompletions)", label: "Total")
                Divider()
                    .background(Color("MutedLavender").opacity(0.3))
                    .frame(height: 30)
                statView(value: "\(bestStreak)", label: "Best")
                Divider()
                    .background(Color("MutedLavender").opacity(0.3))
                    .frame(height: 30)
                statView(value: "\(Int(completionRate))%", label: "Rate")
            }
            .padding(.vertical, 8)
            .background(Color("SpaceBackground").opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Grid section
            VStack(alignment: .leading, spacing: 4) {
                monthLabels
                grid
                legend
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("AccentPurple").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color("AccentPurple").opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    func statView(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("MutedLavender"))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StreakCardView(task: Task(name: "Brush Teeth", recurrence: .daily))
        .padding()
        .background(Color("SpaceBackground"))
        .modelContainer(for: Task.self, inMemory: true)
}
