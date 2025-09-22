import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.modelContext) private var context
    @State var workoutLog: WorkoutLog

    private var exercises: [ExerciseTemplate] {
        if let t = workoutLog.template {
            return t.exercises.sorted { $0.order < $1.order }
        } else {
            // Fallback: show names from exerciseLogs (view-only list)
            return []
        }
    }

    var body: some View {
        List {
            ForEach(exercises) { ex in
                let (statusText, statusIcon) = status(for: ex)
                NavigationLink {
                    ExerciseLoggingView(workoutLog: workoutLog, template: ex)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ex.name).font(.headline)
                            Text("\(ex.repsPerSet.count) sets • Rest \(ex.restSeconds)s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Label(statusText, systemImage: statusIcon)
                            .labelStyle(.titleAndIcon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(workoutLog.workoutName)
    }

    private func status(for ex: ExerciseTemplate) -> (String, String) {
        if let log = workoutLog.exerciseLogs.first(where: { $0.exerciseName == ex.name }) {
            if log.isCompleted || log.entries.count >= log.repsPerSet.count {
                return ("Done", "checkmark.circle.fill")
            } else {
                return ("\(log.entries.count)/\(log.repsPerSet.count)", "pause.circle")
            }
        } else {
            return ("Not started", "circle")
        }
    }
}
