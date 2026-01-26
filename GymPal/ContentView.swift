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

struct ActiveWorkoutView: View {
    @Environment(WorkoutManager.self) var manager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTime(manager.elapsedSeconds))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Placeholder for Exercise List
                Text("Exercises will go here")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // End Workout Button
                Button(role: .destructive) {
                    manager.finishWorkout()
                } label: {
                    Text("Finish Workout")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
            .navigationTitle("Current Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
        .environment(WorkoutManager())
}
