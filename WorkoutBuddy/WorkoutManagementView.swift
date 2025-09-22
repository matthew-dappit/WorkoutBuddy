import SwiftUI
import SwiftData

struct WorkoutManagementView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\WorkoutTemplate.createdAt, order: .reverse)])
    private var workouts: [WorkoutTemplate]
    
    @State private var showingCreation = false
    @State private var editingWorkout: WorkoutTemplate?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    WorkoutManagementRow(workout: workout) {
                        editingWorkout = workout
                    }
                }
                .onDelete(perform: deleteWorkouts)
            }
            .navigationTitle("Manage Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreation = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreation) {
                WorkoutCreationView()
            }
            .sheet(item: $editingWorkout) { workout in
                WorkoutEditView(workout: workout)
            }
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        for index in offsets {
            context.delete(workouts[index])
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
}

struct WorkoutManagementRow: View {
    let workout: WorkoutTemplate
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                Spacer()
                Button("Edit", action: onEdit)
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            
            Text("\(workout.exercises.count) exercises")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if !workout.exercises.isEmpty {
                Text(workout.exercises.prefix(3).map(\.name).joined(separator: ", "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let workout: WorkoutTemplate
    
    @State private var workoutName: String
    @State private var exercises: [ExerciseCreationData]
    @State private var showingExerciseCreation = false
    @State private var editingExerciseIndex: Int?
    
    init(workout: WorkoutTemplate) {
        self.workout = workout
        _workoutName = State(initialValue: workout.name)
        _exercises = State(initialValue: workout.exercises.sorted { $0.order < $1.order }.map { template in
            var data = ExerciseCreationData()
            data.name = template.name
            data.restSeconds = template.restSeconds
            data.repsPerSet = template.repsPerSet
            data.weightIncrements = template.weightIncrements
            return data
        })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Workout Name Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Name")
                        .font(.headline)
                    TextField("Enter workout name", text: $workoutName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Exercises List
                if exercises.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "dumbbell")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No exercises added yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Tap 'Add Exercise' to get started")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                            ExerciseCreationRow(exercise: exercise) {
                                editingExerciseIndex = index
                                showingExerciseCreation = true
                            }
                        }
                        .onDelete(perform: deleteExercises)
                        .onMove(perform: moveExercises)
                    }
                }
                
                // Add Exercise Button
                Button {
                    editingExerciseIndex = nil
                    showingExerciseCreation = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(workoutName.isEmpty || exercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExerciseCreation) {
                ExerciseCreationView(
                    exercise: editingExerciseIndex.map { exercises[$0] },
                    onSave: { exerciseData in
                        if let index = editingExerciseIndex {
                            exercises[index] = exerciseData
                        } else {
                            exercises.append(exerciseData)
                        }
                    }
                )
            }
        }
    }
    
    private func deleteExercises(offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    private func moveExercises(from: IndexSet, to: Int) {
        exercises.move(fromOffsets: from, toOffset: to)
    }
    
    private func saveChanges() {
        // Update workout name
        workout.name = workoutName
        
        // Remove old exercises
        for exercise in workout.exercises {
            context.delete(exercise)
        }
        
        // Add new exercises
        let exerciseTemplates = exercises.enumerated().map { index, data in
            ExerciseTemplate(
                name: data.name,
                restSeconds: data.restSeconds,
                repsPerSet: data.repsPerSet,
                weightIncrements: data.weightIncrements,
                order: index
            )
        }
        
        workout.exercises = exerciseTemplates
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save workout changes: \(error)")
        }
    }
}

#Preview {
    WorkoutManagementView()
        .modelContainer(for: [WorkoutTemplate.self, ExerciseTemplate.self])
}