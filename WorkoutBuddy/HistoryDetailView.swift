import SwiftUI
import SwiftData

struct HistoryDetailView: View {
    let log: WorkoutLog

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Workout")
                    Spacer()
                    Text(log.workoutName).foregroundStyle(.secondary)
                }
                HStack {
                    Text("Date")
                    Spacer()
                    Text(formatDate(log.date)).foregroundStyle(.secondary)
                }
            }

            ForEach(log.exerciseLogs) { ex in
                Section(ex.exerciseName) {
                    HStack {
                        Text("Rest")
                        Spacer()
                        Text("\(ex.restSeconds)s").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Sets")
                        Spacer()
                        Text("\(ex.repsPerSet.count)").foregroundStyle(.secondary)
                    }

                    if ex.entries.isEmpty {
                        Text("No sets logged yet")
                            .foregroundStyle(.tertiary)
                    } else {
                        ForEach(ex.entries.sorted(by: { $0.setIndex < $1.setIndex })) { entry in
                            HStack {
                                Text("Set \(entry.setIndex + 1)")
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(entry.performedReps) reps @ \(String(format: "%.1f", entry.weight)) kg")
                                    Text(timeOnly(entry.loggedAt))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)

                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Workout Details")
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
    private func timeOnly(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df.string(from: date)
    }
}
