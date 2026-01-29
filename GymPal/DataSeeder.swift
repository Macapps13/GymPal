//
//  DataFeeder.swift
//  GymPal
//
//  Created by Ben Alvaro on 28/1/2026.
//

import Foundation
import SwiftData

class DataSeeder {
    static func seedExercises(context: ModelContext) {
        let descriptor = FetchDescriptor<ExerciseTemplate>()
        
        do {
            let count = try context.fetchCount(descriptor)
            if count > 0 {
                return
            }
        } catch {
            print("Failed to check database: \(error)")
            return
        }
        
        let defaults = [
            ExerciseTemplate (name: "Bench Press (Dumbbell)", bodyPart: BodyPart.chest),
            ExerciseTemplate (name: "Preacher Curl (Machine)", bodyPart: BodyPart.biceps)
        ]
        
        for exercise in defaults {
            context.insert(exercise)
        }
        
        do {
            try context.save()
            print("Database seeded successfully")
        } catch {
            print("Failed to save seed data: \(error)")
        }
    }
}
