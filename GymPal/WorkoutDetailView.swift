//
//  WorkoutDetailView.swift
//  GymPal
//
//  Created by Ben Alvaro on 29/1/2026.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.modelContext) var modelContext
    @State private var showSaveAlert = false
    @State private var templateName = ""
    
    @ViewBuilder
    private func exerciseHeader(for exercise: WorkoutExercise) -> some View {
        ExerciseLabel(name: exercise.name, equipment: exercise.equipment)
            .padding(.vertical, 4)
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(workout.startTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let endTime = workout.endTime {
                        let duration = endTime.timeIntervalSince(workout.startTime)
                        Label(durationFormatter.string(from: duration) ?? "", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            

            ForEach(workout.exercises) { exercise in
                Section(header: exerciseHeader(for: exercise)) {
                    if exercise.sets.isEmpty {
                        Text("No sets recorded")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        HStack {
                            Text("Set").frame(width: 30, alignment: .leading)
                            Spacer()
                            Text("Weight").frame(width: 60, alignment: .trailing)
                            Text("Reps").frame(width: 60, alignment: .trailing)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        
        
                        ForEach(Array(exercise.sets.enumerated()), id: \.element) { index, set in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.caption.monospacedDigit())
                                    .frame(width: 30, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Text("\(set.weight, format: .number) kg")
                                    .font(.system(.body, design: .rounded))
                                    .frame(width: 60, alignment: .trailing)
                                
                                Text("\(set.reps)")
                                    .font(.system(.body, design: .rounded))
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } 
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save as Routine") {
                    templateName = workout.name
                    showSaveAlert = true
                }
            }
        }
        .alert("Save Routine", isPresented: $showSaveAlert) {
            TextField("Routine Name", text: $templateName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                saveTemplate()
            }
        }
        .navigationTitle("Workout Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }
    
    func saveTemplate() {
        let names = workout.exercises.map { $0.name }
        print("Found \(names.count) exercises to save.")
        let newTemplate = WorkoutTemplate(name: templateName, exerciseNames: names)
        modelContext.insert(newTemplate)
        try? modelContext.save()
    }
}
