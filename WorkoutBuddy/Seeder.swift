// Seeder.swift
import Foundation
import SwiftData

@MainActor
func seedDummyWorkout(context: ModelContext) async throws {
    // Avoid duplicates if already seeded
    let existing = try context.fetch(FetchDescriptor<WorkoutTemplate>())
    guard existing.isEmpty else { return }

    // 1) Back Squats
    let squats = ExerciseTemplate(
        name: "Back Squats",
        restSeconds: 120,
        repsPerSet: [12, 10, 8, 6, 4, 1],
        // increments between sets: for 6 sets -> 5 increments
        weightIncrements: [20, 10, 10, 10, 10],
        order: 0
    )

    // 2) Calf Raises
    let calfRaises = ExerciseTemplate(
        name: "Calf Raises",
        restSeconds: 90,
        repsPerSet: [12, 12, 12, 12],
        weightIncrements: [10, 10, 10],
        order: 1
    )

    let workout = WorkoutTemplate(
        name: "Dummy Workout",
        createdAt: .now,
        exercises: [squats, calfRaises]
    )

    context.insert(workout)
    try context.save()
}
