//
//  ExerciseLabel.swift
//  GymPal
//
//  Created by Ben Alvaro on 29/1/2026.
//
import SwiftUI
import SwiftData


struct ExerciseLabel: View {
    let name: String
    let equipment: ExerciseEquipment
    
    var body: some View {
        HStack {
            Text(name)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(equipment.rawValue)
            }
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)
            .foregroundStyle(.secondary)
        }
    }
}
