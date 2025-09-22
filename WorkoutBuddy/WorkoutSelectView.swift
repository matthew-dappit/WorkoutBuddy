// WorkoutSelectView.swift
import SwiftUI
import SwiftData

struct WorkoutSelectView: View {
    @Query(sort: [SortDescriptor(\WorkoutTemplate.createdAt, order: .reverse)])
    private var workouts: [WorkoutTemplate]

    @State private var selectedTemplate: WorkoutTemplate?

    var body: some View {
        List {
            ForEach(workouts) { workout in
                Button {
                    // Do NOT create or save here
                    selectedTemplate = workout
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name).font(.headline)
                            Text("\(workout.exercises.count) exercises")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .navigationTitle("Select Workout")
        .navigationDestination(item: $selectedTemplate) { template in
            ExercisePickerHost(template: template)   // new lightweight host view
        }
    }
}
