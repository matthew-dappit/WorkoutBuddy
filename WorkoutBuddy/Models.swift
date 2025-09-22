import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade)
    var exercises: [ExerciseTemplate]

    init(name: String, createdAt: Date, exercises: [ExerciseTemplate] = []) {
        self.name = name
        self.createdAt = createdAt
        self.exercises = exercises
    }
}

@Model
final class ExerciseTemplate {
    var name: String
    var restSeconds: Int
    /// Example: [12,10,8,6,4,1]
    var repsPerSet: [Int]
    /// Increments BETWEEN sets. For 6 sets you have 5 increments.
    /// Example (Back Squat): [20,10,10,10,10]
    var weightIncrements: [Double]
    /// For display ordering
    var order: Int

    init(name: String,
         restSeconds: Int,
         repsPerSet: [Int],
         weightIncrements: [Double],
         order: Int)
    {
        self.name = name
        self.restSeconds = restSeconds
        self.repsPerSet = repsPerSet
        self.weightIncrements = weightIncrements
        self.order = order
    }
}

@Model
final class WorkoutLog {
    var date: Date
    var workoutName: String
    var template: WorkoutTemplate?
    @Relationship(deleteRule: .cascade)
    var exerciseLogs: [ExerciseLog]

    init(date: Date = .now,
         workoutName: String,
         template: WorkoutTemplate? = nil,
         exerciseLogs: [ExerciseLog] = [])
    {
        self.date = date
        self.workoutName = workoutName
        self.template = template
        self.exerciseLogs = exerciseLogs
    }
}

@Model
final class ExerciseLog {
    var exerciseName: String
    var restSeconds: Int
    /// Snapshot of template at logging time
    var repsPerSet: [Int]
    /// Snapshot increments between sets
    var weightIncrements: [Double]
    var startWeight: Double
    var isCompleted: Bool
    @Relationship(deleteRule: .cascade)
    var entries: [SetEntry]

    init(exerciseName: String,
         restSeconds: Int,
         repsPerSet: [Int],
         weightIncrements: [Double],
         startWeight: Double = 0,
         isCompleted: Bool = false,
         entries: [SetEntry] = [])
    {
        self.exerciseName = exerciseName
        self.restSeconds = restSeconds
        self.repsPerSet = repsPerSet
        self.weightIncrements = weightIncrements
        self.startWeight = startWeight
        self.isCompleted = isCompleted
        self.entries = entries
    }
}

@Model
final class SetEntry {
    var setIndex: Int
    var targetReps: Int
    var performedReps: Int
    var weight: Double
    var loggedAt: Date

    init(setIndex: Int,
         targetReps: Int,
         performedReps: Int,
         weight: Double,
         loggedAt: Date = .now)
    {
        self.setIndex = setIndex
        self.targetReps = targetReps
        self.performedReps = performedReps
        self.weight = weight
        self.loggedAt = loggedAt
    }
}
