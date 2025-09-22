import SwiftUI
import SwiftData

struct WorkoutCreationView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String = ""
    @State private var exercises: [ExerciseCreationData] = []
    @State private var showingExerciseCreation = false
    @State private var editingExerciseIndex: Int?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Workout Name Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Name")
                        .font(.headline)
                    TextField("Enter workout name", text: $workoutName)
                        .textFieldStyle(.roundedBorder)
                        .autoSelectText()
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
            .dismissKeyboardOnTap()
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
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
    
    private func saveWorkout() {
        let exerciseTemplates = exercises.enumerated().map { index, data in
            ExerciseTemplate(
                name: data.name,
                restSeconds: data.restSeconds,
                repsPerSet: data.repsPerSet,
                weightIncrements: data.weightIncrements,
                order: index
            )
        }
        
        let workout = WorkoutTemplate(
            name: workoutName,
            createdAt: .now,
            exercises: exerciseTemplates
        )
        
        context.insert(workout)
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
}

struct ExerciseCreationRow: View {
    let exercise: ExerciseCreationData
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Button("Edit", action: onEdit)
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            
            HStack(spacing: 16) {
                Label("\(exercise.repsPerSet.count) sets", systemImage: "repeat")
                Label("\(exercise.restSeconds)s rest", systemImage: "timer")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            if exercise.repsPerSet.allSatisfy({ $0 == exercise.repsPerSet.first }) {
                Text("Reps: \(exercise.repsPerSet.first ?? 0) per set")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                Text("Reps: \(exercise.repsPerSet.map(String.init).joined(separator: "-"))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Data structure for exercise creation
struct ExerciseCreationData: Identifiable {
    let id = UUID()
    var name: String = ""
    var restSeconds: Int = 60
    var repsPerSet: [Int] = [10]
    var weightIncrements: [Double] = [5.0]
}

#Preview {
    WorkoutCreationView()
        .modelContainer(for: [WorkoutTemplate.self, ExerciseTemplate.self])
}