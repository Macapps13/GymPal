//
//  ContentView.swift
//  GymPal
//
//  Created by Ben Alvaro on 25/1/2026.
//
import SwiftUI

struct ContentView: View {
    @Environment(WorkoutManager.self) var manager
    
    var body: some View {
        TabView {
            StartWorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
            
            Text("History View") // Placeholder
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            Text("Exercises") // Placeholder
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet")
                }
        }
        
        .fullScreenCover(isPresented: Bindable(manager).isWorkoutActive) {
            ActiveWorkoutView()
        }
    }
}

struct StartWorkoutView: View {
    @Environment(WorkoutManager.self) var manager
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Button(action: {
                    manager.startWorkout()
                }) {
                    Text("Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Let's Lift!")
        }
    }
}
