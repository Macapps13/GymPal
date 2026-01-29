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
    var index: Int
    var onComplete: () -> Void
    
    // 1. Logic to handle "empty" instead of "0" for Weight
    private var weightProxy: Binding<String> {
        Binding(
            get: {
                // If weight is 0, show empty string (placeholder "0" appears)
                if set.weight == 0 { return "" }
                
                // This format removes unnecessary decimals (e.g., 60.0 becomes 60)
                // but keeps them if they exist (e.g., 22.5 stays 22.5)
                return set.weight.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", set.weight)
                : String(format: "%.2f", set.weight)
            },
            set: { newValue in
                // Filter out non-numeric characters except the decimal point
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if let value = Double(filtered) {
                    set.weight = value
                } else if newValue.isEmpty {
                    set.weight = 0
                }
            }
        )
    }
    // 2. Logic to handle "empty" instead of "0" for Reps
    private var repsProxy: Binding<String> {
        Binding(
            get: { set.reps == 0 ? "" : "\(set.reps)" },
            set: { newValue in
                if let value = Int(newValue) {
                    set.reps = value
                } else if newValue.isEmpty {
                    set.reps = 0
                }
            }
        )
    }
    
    var body: some View {
        HStack {
            GridRow {
                Group {
                    Text("\(index)")
                        .font(.caption.monospacedDigit())
                        .gridColumnAlignment(.leading)
                        .foregroundStyle(set.isCompleted ? .green : .primary)
                    
                    HStack(spacing: 8) {
                        TextField("0", text: weightProxy)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(set.isCompleted ? .green : .primary)
                        Text("kg")
                            .font(.caption)
                            .foregroundStyle(set.isCompleted ? .green : .secondary)
                            .frame(width: 25, alignment: .trailing)
                    }
                    
                    HStack(spacing: 8) {
                        TextField("0", text: repsProxy)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(set.isCompleted ? .green : .primary)
                        Text("reps")
                            .font(.caption)
                            .foregroundStyle(set.isCompleted ? .green : .secondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                    
                    Button(action: {
                        set.isCompleted.toggle()
                        if set.isCompleted { onComplete() }
                    }) {
                        Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(set.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(set.isCompleted ? Color.green.opacity(0.15) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(set.isCompleted ? Color.green.opacity(0.35) : Color.clear, lineWidth: 1)
                )
        )
    }
}
