//
//  ExerciseLibraryView.swift
//  GymPal
//
//  Created by Ben Alvaro on 29/1/2026.
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseLibraryView: View {
    @Query(sort: \ExerciseTemplate.name) var templates: [ExerciseTemplate]
    @Query var allWorkouts: [Workout]
    
    var groupedTemplates: [String: [ExerciseTemplate]] {
        Dictionary(grouping: templates, by: { $0.bodyPart })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedTemplates.keys.sorted(), id: \.self) { bodyPart in
                    Section(header: Text(bodyPart)) {
                        ForEach(groupedTemplates[bodyPart] ?? []) { template in
                            NavigationLink(destination: ExerciseDetailView(template: template)) {
                                HStack {
                                    Text(template.name)
                                    Spacer()
                                    if let pr = calculatePR(for: template.name) {
                                        Text("PR: \(Int(pr))kg")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Exercises"))
        }
    }
    
    func calculatePR(for name: String) -> Double? {
        let allSets = allWorkouts
            .flatMap { $0.exercises }
            .filter { $0.name == name}
            .flatMap { $0.sets }
        return allSets.map { $0.weight * Double($0.reps) }.max()
    }
}


struct ExerciseDetailView: View {
    let template: ExerciseTemplate
    @Query var allWorkouts: [Workout]
    
    var history: [(date: Date, volume: Double)] {
        allWorkouts.compactMap { workout -> (date: Date, volume: Double)? in
            let exerciseSets = workout.exercises
                .filter { $0.name == template.name }
                .flatMap { $0.sets }
            
            if exerciseSets.isEmpty { return nil }
            
            // Summing the volume safely
            let totalVolume = exerciseSets.reduce(0.0) { sum, set in
                sum + (set.weight * Double(set.reps))
            }
            
            return (date: workout.startTime, volume: totalVolume)
        }.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        List {
            Section("Progression") {
                if history.count < 2 {
                    Text("Need at least 2 session to show progress. ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    Chart {
                        ForEach(history, id: \.date) { entry in
                            AreaMark(
                                x: .value("Date", entry.date),
                                y: .value("Volume", entry.volume)
                            )
                            .foregroundStyle(LinearGradient(
                                colors: [.orange.opacity(0.4), .orange.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .interpolationMethod(.catmullRom)
                            
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Volume", entry.volume)
                            )
                            .foregroundStyle(.orange)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                        }
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                }
            }
            Section("All Time Best Volume") {
                if let pr = history.map({ $0.volume }).max() {
                    Text("\(Int(pr)) kg")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
            }
            
            Section("History") {
                ForEach(history, id: \.date) { entry in
                    HStack {
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        Spacer()
                        Text("\(Int(entry.volume)) kg total")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(template.name)
    }
}

