//
//  CreateExerciseView.swift
//  GymPal
//
//  Created by Ben Alvaro on 29/1/2026.
//

import SwiftData
import SwiftUI
import Foundation

struct CreateExerciseView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedBodyPart: BodyPart = .chest
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise Name", text: $name)
                
                Picker("Body Part", selection: $selectedBodyPart) {
                    ForEach(BodyPart.allCases) { part in
                        Text(part.rawValue).tag(part)
                    }
                }
            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let newTemplate = ExerciseTemplate(name: name, bodyPart: selectedBodyPart)
                        modelContext.insert(newTemplate)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
