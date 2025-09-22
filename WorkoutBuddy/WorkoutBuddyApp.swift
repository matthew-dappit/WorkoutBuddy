//
//  WorkoutBuddyApp.swift
//  WorkoutBuddy
//
//  Created by Matthew Strauss on 2025/09/20.
//

import SwiftUI
import SwiftData

@main
struct WorkoutBuddyApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [
            WorkoutTemplate.self,
            ExerciseTemplate.self,
            WorkoutLog.self,
            ExerciseLog.self,
            SetEntry.self
        ])
    }
}
