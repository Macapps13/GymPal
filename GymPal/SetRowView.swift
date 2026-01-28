//
//  SetRowView.swift
//  GymPal
//
//  Created by Ben Alvaro on 27/1/2026.
//

import SwiftUI
import SwiftData

struct SetRowView: View {
    @Bindable var set: WorkoutSet
    
    let index: Int
    
    var onComplete: () -> Void
    
    var body: some View {
        HStack {
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            Divider()
            
            TextField("kg", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(set.isCompleted ? 0.5 : 1.0)
            
            Text("kg")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            TextField("Reps", value: $set.reps, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(set.isCompleted ? 0.5 : 1.0)
            Text("reps")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button(action: {
                toggleCompletion()
            }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
        .listRowBackground(set.isCompleted ? Color.green.opacity(0.1) : Color.clear)
    }
    
    func toggleCompletion() {
        withAnimation {
            set.isCompleted.toggle()
        }
        
        if set.isCompleted {
            onComplete()
        }
    }
}
