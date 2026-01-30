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
    @Environment(\.modelContext) var modelContext
    
    @State private var showCreateSheet = false
    @State private var selectedBodyPart: BodyPart? = nil
    @State private var selectedEquipment: ExerciseEquipment? = nil
    
    @Query(sort: \ExerciseTemplate.name) var templates: [ExerciseTemplate]
    
    var filteredTemplates: [ExerciseTemplate] {
        templates.filter { template in
            let bodyPartMatch = selectedBodyPart == nil || template.bodyPart == selectedBodyPart
            let equipmentMatch = selectedEquipment == nil || template.equipment == selectedEquipment
            return bodyPartMatch && equipmentMatch
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    showCreateSheet = true
                } label: {
                    Label("Create Custom Exercise", systemImage: "plus.circle.fill")
                        .foregroundStyle(.orange)
                }
                
                ForEach(filteredTemplates) { template in
                    Button {
                        manager.addExercise(template)
                        dismiss()
                    } label: {
                        ExerciseLabel(name: template.name, equipment: template.equipment)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateExerciseView()
        }
    }
    
    var filterMenu: some View {
            Menu {
                // Equipment Submenu
                Menu("Equipment") {
                    Button("All Equipment") { selectedEquipment = nil }
                    ForEach(ExerciseEquipment.allCases) { equipment in
                        Button(equipment.rawValue) { selectedEquipment = equipment }
                    }
                }
                
                // Body Part Submenu
                Menu("Body Part") {
                    Button("All Body Parts") { selectedBodyPart = nil }
                    ForEach(BodyPart.allCases) { part in
                        Button(part.rawValue) { selectedBodyPart = part }
                    }
                }
                
                if selectedBodyPart != nil || selectedEquipment != nil {
                    Button("Clear Filters", role: .destructive) {
                        selectedBodyPart = nil
                        selectedEquipment = nil
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant((selectedBodyPart == nil && selectedEquipment == nil) ? .none : .fill)
        }
    }
}
