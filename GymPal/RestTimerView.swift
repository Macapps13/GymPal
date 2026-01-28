//
//  RestTimerView.swift
//  GymPal
//
//  Created by Ben Alvaro on 28/1/2026.
//

import SwiftUI

struct RestTimerView: View {
    let seconds: Int
    let onSkip: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.title2)
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading) {
                Text("RESTING")
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .foregroundStyle(.secondary)
                
                Text(formatTime(seconds))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button(action: onSkip) {
                Text("Skip")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.3))
                    .clipShape(Capsule())
            }
            .foregroundStyle(.orange)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding()
        .shadow(radius: 10)
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
