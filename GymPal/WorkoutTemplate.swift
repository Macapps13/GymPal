//
//  WorkoutTemplate.swift
//  GymPal
//
//  Created by Ben Alvaro on 29/1/2026.
//

import SwiftData
import Foundation

@Model
class WorkoutTemplate {
    var name: String
    var exerciseNames: [String] // Storing the list of exercise names
    var createdAt: Date
    
    init(name: String, exerciseNames: [String]) {
        self.name = name
        self.exerciseNames = exerciseNames
        self.createdAt = Date()
    }
}
