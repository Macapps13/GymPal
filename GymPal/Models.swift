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
    var equipment: ExerciseEquipment
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise) 
    var sets: [WorkoutSet] = []
    
    var workout: Workout?
    
    init(name: String, equipment: ExerciseEquipment = .bodyWeight) {
        self.name = name
        self.equipment = equipment
    }
}

@Model
class Workout {
    var id: UUID
    var name: String
    var startTime: Date
    var endTime: Date? // ? mark means it doesn't have to exist
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise] = []
    
    init(startTime: Date = Date(), name: String = "New Workout") {
        self.id = UUID()
        self.name = name
        self.startTime = startTime
    }
    
    var duration: TimeInterval {
        guard let end = endTime else { return 0 }
        return end.timeIntervalSince(startTime)
    }
}

enum BodyPart: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case core = "Core"
    case legs = "Legs"
    case biceps = "Biceps"
    case triceps = "Triceps"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rower"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.curling"
        case .triceps: return "figure.arms.open"
        case .legs: return "figure.run"
        case .core: return "figure.core.training"
        }
    }
}

enum ExerciseEquipment: String, Codable, CaseIterable, Identifiable {
    case machine = "Machine"
    case bodyWeight = "Body Weight"
    case dumbbells = "Dumbbells"
    case barbell = "Barbell"
    case cable = "Cables"
    
    var id: String { self.rawValue }
}

@Model
class ExerciseTemplate {
    var name: String
    var bodyPart: BodyPart
    var equipment: ExerciseEquipment
    
    init(name: String, bodyPart: BodyPart, equipment: ExerciseEquipment) {
        self.name = name
        self.bodyPart = bodyPart
        self.equipment = equipment
    }
}
