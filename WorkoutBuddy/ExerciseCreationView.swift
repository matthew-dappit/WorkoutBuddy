import SwiftUI

struct ExerciseCreationView: View {
    @Environment(\.dismiss) private var dismiss
    
    let exercise: ExerciseCreationData?
    let onSave: (ExerciseCreationData) -> Void
    
    @State private var exerciseName: String
    @State private var restSeconds: Int
    @State private var numberOfSets: Int
    @State private var repsMode: RepsMode
    @State private var sameRepsValue: Int
    @State private var customReps: [Int]
    @State private var weightMode: WeightMode
    @State private var sameWeightIncrement: Double
    @State private var customWeightIncrements: [Double]
    
    enum RepsMode: String, CaseIterable {
        case same = "Same for all sets"
        case custom = "Different per set"
    }
    
    enum WeightMode: String, CaseIterable {
        case same = "Same increment"
        case custom = "Custom increments"
    }
    
    init(exercise: ExerciseCreationData?, onSave: @escaping (ExerciseCreationData) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        
        if let exercise = exercise {
            _exerciseName = State(initialValue: exercise.name)
            _restSeconds = State(initialValue: exercise.restSeconds)
            _numberOfSets = State(initialValue: exercise.repsPerSet.count)
            
            // Determine reps mode
            if exercise.repsPerSet.allSatisfy({ $0 == exercise.repsPerSet.first }) {
                _repsMode = State(initialValue: .same)
                _sameRepsValue = State(initialValue: exercise.repsPerSet.first ?? 10)
                _customReps = State(initialValue: exercise.repsPerSet)
            } else {
                _repsMode = State(initialValue: .custom)
                _sameRepsValue = State(initialValue: 10)
                _customReps = State(initialValue: exercise.repsPerSet)
            }
            
            // Determine weight mode
            if exercise.weightIncrements.allSatisfy({ $0 == exercise.weightIncrements.first }) {
                _weightMode = State(initialValue: .same)
                _sameWeightIncrement = State(initialValue: exercise.weightIncrements.first ?? 5.0)
                _customWeightIncrements = State(initialValue: exercise.weightIncrements)
            } else {
                _weightMode = State(initialValue: .custom)
                _sameWeightIncrement = State(initialValue: 5.0)
                _customWeightIncrements = State(initialValue: exercise.weightIncrements)
            }
        } else {
            _exerciseName = State(initialValue: "")
            _restSeconds = State(initialValue: 60)
            _numberOfSets = State(initialValue: 3)
            _repsMode = State(initialValue: .same)
            _sameRepsValue = State(initialValue: 10)
            _customReps = State(initialValue: [10, 10, 10])
            _weightMode = State(initialValue: .same)
            _sameWeightIncrement = State(initialValue: 5.0)
            _customWeightIncrements = State(initialValue: [5.0, 5.0])
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise name", text: $exerciseName)
                    
                    HStack {
                        Text("Rest between sets")
                        Spacer()
                        TextField("60", value: $restSeconds, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectAll(nil)
                                }
                            }
                        Text("seconds")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Number of sets")
                        Spacer()
                        Picker("Sets", selection: $numberOfSets) {
                            ForEach(1...10, id: \.self) { num in
                                Text("\(num)").tag(num)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Reps Configuration") {
                    Picker("Reps Mode", selection: $repsMode) {
                        ForEach(RepsMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if repsMode == .same {
                        HStack {
                            Text("Reps per set")
                            Spacer()
                            TextField("10", value: $sameRepsValue, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                    if let textField = obj.object as? UITextField {
                                        textField.selectAll(nil)
                                    }
                                }
                        }
                    } else {
                        ForEach(0..<numberOfSets, id: \.self) { index in
                            HStack {
                                Text("Set \(index + 1)")
                                Spacer()
                                TextField("10", value: Binding(
                                    get: { customReps.indices.contains(index) ? customReps[index] : 10 },
                                    set: { newValue in
                                        while customReps.count <= index {
                                            customReps.append(10)
                                        }
                                        customReps[index] = newValue
                                    }
                                ), format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                    if let textField = obj.object as? UITextField {
                                        textField.selectAll(nil)
                                    }
                                }
                                Text("reps")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Section("Weight Progression") {
                    Picker("Weight Mode", selection: $weightMode) {
                        ForEach(WeightMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if weightMode == .same {
                        HStack {
                            Text("Weight increment")
                            Spacer()
                            TextField("5.0", value: $sameWeightIncrement, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                    if let textField = obj.object as? UITextField {
                                        textField.selectAll(nil)
                                    }
                                }
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Weight increase between sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ForEach(0..<max(1, numberOfSets - 1), id: \.self) { index in
                            HStack {
                                Text("Set \(index + 1) → \(index + 2)")
                                Spacer()
                                TextField("5.0", value: Binding(
                                    get: { customWeightIncrements.indices.contains(index) ? customWeightIncrements[index] : 5.0 },
                                    set: { newValue in
                                        while customWeightIncrements.count <= index {
                                            customWeightIncrements.append(5.0)
                                        }
                                        customWeightIncrements[index] = newValue
                                    }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                    if let textField = obj.object as? UITextField {
                                        textField.selectAll(nil)
                                    }
                                }
                                Text("kg")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(exercise == nil ? "Add Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(exerciseName.isEmpty)
                }
            }
        }
        .onChange(of: numberOfSets) { _, newValue in
            updateArraysForSetCount(newValue)
        }
        .onChange(of: repsMode) { _, _ in
            updateRepsArray()
        }
        .onChange(of: weightMode) { _, _ in
            updateWeightIncrementsArray()
        }
        .onChange(of: sameRepsValue) { _, _ in
            if repsMode == .same {
                updateRepsArray()
            }
        }
        .onChange(of: sameWeightIncrement) { _, _ in
            if weightMode == .same {
                updateWeightIncrementsArray()
            }
        }
    }
    
    private func updateArraysForSetCount(_ setCount: Int) {
        updateRepsArray()
        updateWeightIncrementsArray()
    }
    
    private func updateRepsArray() {
        if repsMode == .same {
            customReps = Array(repeating: sameRepsValue, count: numberOfSets)
        } else {
            // Adjust custom reps array to match set count
            while customReps.count < numberOfSets {
                customReps.append(10)
            }
            if customReps.count > numberOfSets {
                customReps = Array(customReps.prefix(numberOfSets))
            }
        }
    }
    
    private func updateWeightIncrementsArray() {
        let incrementCount = max(1, numberOfSets - 1)
        
        if weightMode == .same {
            customWeightIncrements = Array(repeating: sameWeightIncrement, count: incrementCount)
        } else {
            // Adjust custom increments array to match increment count
            while customWeightIncrements.count < incrementCount {
                customWeightIncrements.append(5.0)
            }
            if customWeightIncrements.count > incrementCount {
                customWeightIncrements = Array(customWeightIncrements.prefix(incrementCount))
            }
        }
    }
    
    private func saveExercise() {
        let finalReps = repsMode == .same ? Array(repeating: sameRepsValue, count: numberOfSets) : customReps
        let finalIncrements = weightMode == .same ? Array(repeating: sameWeightIncrement, count: max(1, numberOfSets - 1)) : customWeightIncrements
        
        var exerciseData = ExerciseCreationData()
        exerciseData.name = exerciseName
        exerciseData.restSeconds = restSeconds
        exerciseData.repsPerSet = finalReps
        exerciseData.weightIncrements = finalIncrements
        
        onSave(exerciseData)
        dismiss()
    }
}

#Preview {
    ExerciseCreationView(exercise: nil) { _ in }
}