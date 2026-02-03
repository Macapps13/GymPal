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
    var onDelete: () -> Void
    
    // 1. FIX: Changed type from Bool? to Field? so it can track WHICH box is focused
    @FocusState private var isFocused: Field?
 
    enum Field {
        case weight
        case reps
    }
    
    // Weight Binding Logic
    private var weightProxy: Binding<String> {
        Binding(
            get: {
                if set.weight == 0 { return "" }
                return set.weight.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", set.weight)
                : String(format: "%.2f", set.weight)
            },
            set: { newValue in
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if let value = Double(filtered) {
                    set.weight = value
                } else if newValue.isEmpty {
                    set.weight = 0
                }
            }
        )
    }

    // Reps Binding Logic
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
                    // Index
                    Text("\(index)")
                        .font(.caption.monospacedDigit())
                        .gridColumnAlignment(.leading)
                        .foregroundStyle(set.isCompleted ? .green : .primary)
                    
                    // Weight Input
                    HStack(spacing: 8) {
                        TextField("0", text: weightProxy)
                            .keyboardType(.decimalPad)
                            .focused($isFocused, equals: .weight) // 2. FIX: Explicitly link to .weight
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(set.isCompleted ? .green : .primary)
                            .onTapGesture { set.weight = 0 }
                        Text("kg")
                            .font(.caption)
                            .foregroundStyle(set.isCompleted ? .green : .secondary)
                            .frame(width: 25, alignment: .trailing)
                    }
                    
                    // Reps Input
                    HStack(spacing: 8) {
                        TextField("0", text: repsProxy)
                            .keyboardType(.decimalPad)
                            .focused($isFocused, equals: .reps) // 3. FIX: Explicitly link to .reps
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(set.isCompleted ? .green : .primary)
                            .onTapGesture { set.reps = 0 }
                        Text("reps")
                            .font(.caption)
                            .foregroundStyle(set.isCompleted ? .green : .secondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                    
                    // Checkbox
                    Button(action: toggleSet) {
                        Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(set.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .onChange(of: isFocused) { oldValue, newValue in
                    if newValue == .weight {
                        set.weight = 0
                    } else if newValue == .reps {
                        set.reps = 0
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(rowBackground)
    }

    @ViewBuilder
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(set.isCompleted ? Color.green.opacity(0.15) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(set.isCompleted ? Color.green.opacity(0.35) : Color.clear, lineWidth: 1)
            )
    }
    
    private func toggleSet() {
        set.isCompleted.toggle()
        if set.isCompleted {
            isFocused = nil // dismiss keyboard
            onComplete()
        }
    }
}
