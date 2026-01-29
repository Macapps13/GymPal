//
//  HistoryView.swift
//  GymPal
//
//  Created by Ben Alvaro on 28/1/2026.
//

import Foundation
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                if workouts.isEmpty {
                    ContentUnavailableView("No Workouts Yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Complete a session to see your progress here."))
                } else {
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutRow(workout: workout)
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
            .navigationTitle(Text("History"))
        }
    }
    
    func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(.headline)
            
            HStack {
                Text(workout.startTime.formatted(date: .abbreviated, time: .shortened))
                
                if let endTime = workout.endTime {
                    let duration = endTime.timeIntervalSince(workout.startTime) / 60
                    Text("• \(Int(duration)) min")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // 3. Muscle Groups / Exercises Summary
            Text(workout.exercises.map { $0.name }.joined(separator: ", "))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}
