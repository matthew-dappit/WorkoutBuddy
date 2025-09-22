import SwiftUI
import SwiftData

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Workout Buddy")
                    .font(.largeTitle).bold()

                VStack(spacing: 16) {
                    NavigationLink("Log Workout") {
                        WorkoutSelectView()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title3)
                    
                    HStack(spacing: 16) {
                        NavigationLink("Create Workout") {
                            WorkoutCreationView()
                        }
                        .buttonStyle(.bordered)
                        .font(.callout)
                        
                        NavigationLink("Manage Workouts") {
                            WorkoutManagementView()
                        }
                        .buttonStyle(.bordered)
                        .font(.callout)
                    }
                    
                    NavigationLink("History") {
                        HistoryView()
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
