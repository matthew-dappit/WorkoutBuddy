import SwiftUI
import SwiftData

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Workout Buddy")
                    .font(.largeTitle).bold()

                NavigationLink("Log Workout") {
                    WorkoutSelectView()
                }
                .buttonStyle(.borderedProminent)
                .font(.title3)
                
                NavigationLink("History") {
                    HistoryView()
                }
                .buttonStyle(.bordered)
                .font(.title3)

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
