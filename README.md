# Workout Buddy 🏋️‍♂️

A SwiftUI iOS app for **quick, offline-first workout logging**.  
The goal: replace messy spreadsheets with a streamlined, templated logger that makes tracking progress fast and intuitive.

---

## 🚀 Current Status

- **Tech stack**
  - SwiftUI (iOS 17+)
  - SwiftData for local offline persistence (Core Data under the hood)

- **Data model**
  - `WorkoutTemplate` → collection of exercises
  - `ExerciseTemplate` → reps, weight increments, rest
  - `WorkoutLog` → instance of a workout on a date
  - `ExerciseLog` → tracks sets performed in a log
  - `SetEntry` → per-set data: reps, weight, timestamp

- **Features implemented**
  - Home screen with navigation to:
    - **Log Workout** (pick template → pick exercise → logging UI)
    - **History** (view, delete, resume past logs)
  - Dummy workout seeded with:
    - Back Squats: 6 sets (12–10–8–6–4–1 reps), +20/+10/+10/+10/+10 kg increments, 120s rest
    - Calf Raises: 4 sets × 12 reps, +10 kg increments, 90s rest
  - Logging UI:
    - Pre-filled reps & weight based on template
    - Plus/minus buttons to adjust
    - Big “Log Set” button
    - Rest timer starts automatically after each set
    - Auto-calculated next set’s reps & weight
    - End exercise early option
  - History:
    - View details of past workouts
    - Swipe-to-delete
    - Resume unfinished logs
  - Duplicate log creation fixed (reuse in-progress log for same workout/day)

---

## 📋 Roadmap / Desired Features

### ✅ MVP (in progress)
- [x] Workout creation (templated exercises)
- [x] Workout logging with rest timer
- [x] History with view, delete, resume

### 🔜 Next Features
- **Workout Templates Management**
  - Create, edit, delete custom workouts/exercises
  - Copy/edit existing templates
- **Resume logic improvements**
  - If a log is marked **completed**, starting again should create a new log (even same day)
  - If a log is **incomplete**, resume instead of creating duplicates
- **Units**
  - Switch between kg / lb
- **Workout completion summary**
  - At the end of a workout, show sets/reps/weights completed
- **History enhancements**
  - Filter/sort (by workout type, date range, completed vs incomplete)
  - Graphs of progress per exercise
- **UX improvements**
  - Visual rest timer countdown (circle or bar)
  - Auto-focus on reps/weight fields for faster input
  - Smart suggestions (e.g., start weight based on last workout)
- **Persistence / Backup**
  - iCloud sync or export/import logs
  - Potential integration with HealthKit (log strength workouts)

---

## 🛠 Development Notes

- SwiftData migrations can fail if new required fields are added to models without defaults.  
  - For development, delete the app to reset the store.  
  - For production, implement proper `SchemaMigrationPlan`.

- Navigation performance: avoid heavy Core Data writes inside `NavigationLink`.  
  - Use programmatic navigation and defer inserts/saves to `.task` on the destination.

- Test strategy: start with simulator, but validate logging + history flow on device for storage and performance.

---

## 📦 Getting Started

1. Clone repo / open in Xcode 15+
2. Run on iOS 17+ device or simulator
3. From **Home**:
   - Tap **Log Workout** → select **Dummy Workout** → start logging
   - Tap **History** to view/resume/delete past workouts
