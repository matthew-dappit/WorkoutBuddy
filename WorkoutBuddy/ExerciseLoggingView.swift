import SwiftUI
import SwiftData

struct ExerciseLoggingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let workoutLog: WorkoutLog
    let template: ExerciseTemplate

    @State private var exerciseLog: ExerciseLog?
    @State private var didSetup = false

    @State private var currentSetIndex: Int = 0
    @State private var targetReps: Int = 0
    @State private var reps: Int = 0
    @State private var weight: Double = 0

    @State private var isResting = false
    @State private var restRemaining: Int = 0
    @State private var restTimer: Timer? = nil

    @State private var showEndEarlyAlert = false
    @State private var showWeightNeededAlert = false

    var body: some View {
        VStack(spacing: 16) {
            header

            if currentSetIndex == 0, (exerciseLog?.startWeight ?? 0) <= 0 {
                Text("Enter your start weight:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            weightPicker
            repsPicker

            if isResting {
                restCountdown
            }

            logButton
            endEarlyButton

            Spacer()
            entriesList
        }
        .padding()
        .dismissKeyboardOnTap()
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupIfNeeded() }
        .onDisappear { restTimer?.invalidate() }
        .alert("Start weight required", isPresented: $showWeightNeededAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a non-zero start weight for your first set.")
        }
        .alert("End exercise early?", isPresented: $showEndEarlyAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Now", role: .destructive) { completeExercise(early: true) }
        } message: {
            Text("You can end without completing all sets. Progress so far will be saved.")
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 4) {
            Text("Set \(currentSetIndex + 1) of \(template.repsPerSet.count)")
                .font(.title2).bold()
            Text("Rest \(template.restSeconds)s between sets")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var weightPicker: some View {
        HStack {
            Text("Weight (kg)")
                .font(.headline)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    weight = max(0, weight - 2.5)
                } label: {
                    Image(systemName: "minus.circle.fill").font(.title2)
                }
                Text(String(format: "%.1f", weight))
                    .monospacedDigit()
                    .frame(minWidth: 64)
                    .font(.title3)
                Button {
                    weight += 2.5
                } label: {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var repsPicker: some View {
        HStack {
            Text("Reps")
                .font(.headline)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    reps = max(0, reps - 1)
                } label: {
                    Image(systemName: "minus.circle.fill").font(.title2)
                }
                VStack(spacing: 2) {
                    Text("\(reps)")
                        .monospacedDigit()
                        .font(.title3)
                    Text("target \(targetReps)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Button {
                    reps += 1
                } label: {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var restCountdown: some View {
        VStack(spacing: 6) {
            Text("Rest")
                .font(.headline)
            Text("\(restRemaining)s")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
            Button("Skip Rest") { stopRest() }
                .buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
    }

    private var logButton: some View {
        Button {
            logSet()
        } label: {
            Text(isLastSet ? "Log Final Set" : "Log Set")
                .font(.title3).bold()
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(isResting)
    }

    private var endEarlyButton: some View {
        Button(role: .destructive) {
            showEndEarlyAlert = true
        } label: {
            Text("End Exercise Early")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private var entriesList: some View {
        Group {
            if let log = exerciseLog, !log.entries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Logged Sets").font(.headline)
                    ForEach(log.entries.sorted(by: { $0.setIndex < $1.setIndex })) { entry in
                        HStack {
                            Text("Set \(entry.setIndex + 1)")
                            Spacer()
                            Text("\(entry.performedReps) reps @ \(String(format: "%.1f", entry.weight)) kg")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }

    // MARK: - Computed

    private var isLastSet: Bool {
        currentSetIndex == template.repsPerSet.count - 1
    }

    // MARK: - Setup

    private func setupIfNeeded() {
        guard !didSetup else { return }
        didSetup = true

        // 1) Find existing ExerciseLog or create it
        if let existing = workoutLog.exerciseLogs.first(where: { $0.exerciseName == template.name }) {
            exerciseLog = existing
        } else {
            let newLog = ExerciseLog(
                exerciseName: template.name,
                restSeconds: template.restSeconds,
                repsPerSet: template.repsPerSet,
                weightIncrements: template.weightIncrements
            )
            workoutLog.exerciseLogs.append(newLog)
            exerciseLog = newLog
            try? context.save()
        }

        // 2) Compute current set index & prefill controls
        let entries = exerciseLog?.entries ?? []
        currentSetIndex = entries.count
        prefillForCurrentSet(basedOn: entries.last)
    }

    private func prefillForCurrentSet(basedOn lastEntry: SetEntry?) {
        guard let log = exerciseLog else { return }

        targetReps = log.repsPerSet[safe: currentSetIndex] ?? 0
        reps = targetReps

        if currentSetIndex == 0 {
            // First set: use saved startWeight if already set; otherwise keep as-is (0)
            weight = log.startWeight > 0 ? log.startWeight : weight
        } else {
            // Next sets: auto from previous weight + increment
            let previousWeight = lastEntry?.weight ?? log.startWeight
            let incrementIndex = currentSetIndex - 1
            let inc = log.weightIncrements[safe: incrementIndex] ?? 0
            weight = max(0, previousWeight + inc)
        }
    }

    // MARK: - Actions

    private func logSet() {
        guard let log = exerciseLog else { return }

        // Enforce a start weight for the first set
        if currentSetIndex == 0 && weight <= 0 {
            showWeightNeededAlert = true
            return
        }

        // If first set: capture startWeight if not already set
        if currentSetIndex == 0 && log.startWeight <= 0 {
            log.startWeight = weight
        }

        let entry = SetEntry(
            setIndex: currentSetIndex,
            targetReps: targetReps,
            performedReps: reps,
            weight: weight
        )
        log.entries.append(entry)
        try? context.save()

        if isLastSet {
            completeExercise(early: false)
            return
        }

        // Prepare next set values immediately, then start the rest timer
        currentSetIndex += 1
        prefillForCurrentSet(basedOn: entry)

        startRest(seconds: log.restSeconds)
    }

    private func completeExercise(early: Bool) {
        exerciseLog?.isCompleted = true
        try? context.save()
        stopRest()
        dismiss()
    }

    private func startRest(seconds: Int) {
        restRemaining = seconds
        isResting = true
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if restRemaining > 0 {
                restRemaining -= 1
            } else {
                stopRest()
            }
        }
    }

    private func stopRest() {
        isResting = false
        restTimer?.invalidate()
        restTimer = nil
    }
}

// MARK: - Safe index helper
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
