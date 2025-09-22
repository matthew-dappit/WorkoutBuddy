import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\WorkoutLog.date, order: .reverse)])
    private var logs: [WorkoutLog]

    @State private var selectedForView: WorkoutLog?
    @State private var selectedForResume: WorkoutLog?
    @State private var confirmDelete: WorkoutLog?

    var body: some View {
        List {
            if logs.isEmpty {
                VStack(spacing: 8) {
                    Text("No history yet").font(.title3).bold()
                    Text("When you log workouts, they’ll appear here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else {
                ForEach(logs) { log in
                    HStack(spacing: 12) {
                        Button {
                            selectedForView = log            // View
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log.workoutName)
                                    .font(.headline)
                                Text("\(formatDate(log.date)) • \(statusText(for: log))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if canResume(log) {
                            Button("Resume") {
                                selectedForResume = log       // Resume
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.caption)
                        } else {
                            Text("Done")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            confirmDelete = log
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .alert("Delete this workout?", isPresented: .init(
            get: { confirmDelete != nil },
            set: { if !$0 { confirmDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { confirmDelete = nil }
            Button("Delete", role: .destructive) {
                if let log = confirmDelete {
                    context.delete(log)         // cascades to ExerciseLogs & SetEntry
                    try? context.save()
                }
                confirmDelete = nil
            }
        } message: {
            if let log = confirmDelete {
                Text("“\(log.workoutName)” on \(formatDate(log.date)) will be removed permanently.")
            }
        }
        // View (read-only details)
        .navigationDestination(item: $selectedForView) { log in
            HistoryDetailView(log: log)
        }
        // Resume (continue logging in the same flow)
        .navigationDestination(item: $selectedForResume) { log in
            // Jump straight into the existing log
            ExercisePickerView(workoutLog: log)
        }
    }

    private func canResume(_ log: WorkoutLog) -> Bool {
        // Resume if any exercise is not completed or has remaining sets
        for ex in log.exerciseLogs {
            if !ex.isCompleted && ex.entries.count < ex.repsPerSet.count { return true }
        }
        // Or if there are zero exerciseLogs (edge case) let the user start
        return log.exerciseLogs.isEmpty
    }

    private func statusText(for log: WorkoutLog) -> String {
        let totalSets = log.exerciseLogs.reduce(0) { $0 + $1.repsPerSet.count }
        let doneSets = log.exerciseLogs.reduce(0) { $0 + $1.entries.count }
        if doneSets >= totalSets && totalSets > 0 { return "Completed" }
        if totalSets == 0 { return "Not started" }
        return "\(doneSets)/\(totalSets) sets"
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}
