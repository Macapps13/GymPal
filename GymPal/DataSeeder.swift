//
//  DataFeeder.swift
//  GymPal
//
//  Created by Ben Alvaro on 28/1/2026.
//

import Foundation
import SwiftData

struct ExerciseDTO: Decodable {
    let name: String
    let bodyPart: BodyPart
    let equipment: ExerciseEquipment
}

@MainActor
class DataSeeder {
    static func seed(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ExerciseTemplate>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            print("Data already exists (\(count) items). Skipping seed.")
            return
        }

        print("🔍 Attempting to find Exercises.json...")
        guard let url = Bundle.main.url(forResource: "Exercises", withExtension: "JSON") else {
            print("Error: Exercises.json NOT found in Bundle. Check Target Membership.")
            return
        }

        print("Reading file data...")
        guard let data = try? Data(contentsOf: url) else {
            print("Error: Data was unreadable at URL.")
            return
        }

        do {
            print("Attempting to decode JSON...")
            let dtos = try JSONDecoder().decode([ExerciseDTO].self, from: data)
            print("Decoded \(dtos.count) DTOs. Inserting into context...")
            
            for dto in dtos {
                let template = ExerciseTemplate(name: dto.name, bodyPart: dto.bodyPart, equipment: dto.equipment)
                modelContext.insert(template)
            }
            
            try modelContext.save()
            print("Successfully seeded 32 exercises.")
        } catch {
            print("Decoding Error: \(error)")
        }
    }
}
