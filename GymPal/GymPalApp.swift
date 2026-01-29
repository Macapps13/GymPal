//
//  GymPalApp.swift
//  GymPal
//
//  Created by Ben Alvaro on 25/1/2026.
//

import SwiftUI
import SwiftData

@main
struct GymPalApp: App {
    @State private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Workout.self, WorkoutTemplate.self, ExerciseTemplate.self])
        .environment(workoutManager)
    }
}
