// ExercisePickerHost.swift
import SwiftUI
import SwiftData

struct ExercisePickerHost: View {
    @Environment(\.modelContext) private var context
    let template: WorkoutTemplate

    @State private var log: WorkoutLog?
    @State private var didStart = false
    @State private var error: String?

    var body: some View {
        Group {
            if let log {
                ExercisePickerView(workoutLog: log)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Preparing workout…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let error {
                        Text(error).foregroundStyle(.red).font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(template.name)
        .task {
            guard !didStart else { return }
            didStart = true
            await prepareLog()
        }
    }

    @MainActor
    private func prepareLog() async {
        do {
            // Optional: try to reuse an existing *incomplete* log for this template today
            if let reuse = try findReusableLog(for: template) {
                log = reuse
                return
            }
            let newLog = WorkoutLog(workoutName: template.name, template: template)
            context.insert(newLog)
            try context.save()            // happens *after* navigation, so tap stays snappy
            log = newLog
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func findReusableLog(for template: WorkoutTemplate) throws -> WorkoutLog? {
        let name = template.name                      // capture as constant
        let startOfDay = Calendar.current.startOfDay(for: Date())

        let pred = #Predicate<WorkoutLog> { log in
            log.workoutName == name && log.date >= startOfDay
        }
        var fd = FetchDescriptor<WorkoutLog>(predicate: pred)
        fd.fetchLimit = 1
        fd.sortBy = [SortDescriptor(\.date, order: .reverse)]   // optional: newest first

        return try context.fetch(fd).first
    }
}
