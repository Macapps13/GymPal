//
//  Models.swift
//  GymPal
//
//  Created by Ben Alvaro on 25/1/2026.
//

import SwiftData
import Foundation

@Model
class WorkoutSet {
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    
    var exercise: WorkoutExercise?
    
    init(weight: Double, reps: Int, isCompleted: Bool = false) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}

@Model
class WorkoutExercise {
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet] = []
    
    var workout: Workout?
    
    init(name: String) {
        self.name = name
    }
}

@Model
class Workout {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise] = []
    
    init(startTime: Date = Date()) {
        self.id = UUID()
        self.startTime = startTime
    }
    
    var duration: TimeInterval {
        guard let end = endTime else { return 0 }
        return end.timeIntervalSince(startTime)
    }
}
