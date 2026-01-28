//
//  ExerciseSelectionView.swift
//  GymPal
//
//  Created by Ben Alvaro on 27/1/2026.
//
import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(WorkoutManager.self) var manager
    
    @Query(sort: \ExerciseTemplate.name) var templates: [ExerciseTemplate]
    
    var body: some View {
        NavigationStack {
            List(templates) { template in
                Button {
                    manager.addExercise(template)
                    dismiss()
                } label: {
                    Text(template.name)
                        .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
