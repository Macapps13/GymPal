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
    
    @State private var showCreateSheet = false
    
    @Query(sort: \ExerciseTemplate.name) var templates: [ExerciseTemplate]
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    showCreateSheet = true
                } label: {
                    Label("Create Custom Exercise", systemImage: "plus.circle.fill")
                        .foregroundStyle(.orange)
                }
                
                ForEach(templates) { template in
                    Button {
                        manager.addExercise(template)
                        dismiss()
                    } label: {
                        ExerciseLabel(name: template.name, equipment: template.equipment)
                    }
                }
                .navigationTitle("Add Exercise")
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateExerciseView()
        }
    }
}
