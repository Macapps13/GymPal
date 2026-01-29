//
//  WorkoutManager.swift
//  GymPal
//
//  Created by Ben Alvaro on 26/1/2026.
//

import Foundation
import Observation
import SwiftData

@Observable
class WorkoutManager {
    // Workout State
    var isWorkoutActive: Bool = false
    var elapsedSeconds: Int = 0
    
    // Reset Timer State
    var restTimerActive: Bool = false
    var restTimeRemaining: Int = 0
    var selectedRestDuration: Int = 90 // Default rest timer is 1:30
    
    private var timer: Timer?
    
    var currentWorkout: Workout?
    
    func startWorkout(context: ModelContext) {
        isWorkoutActive = true
        elapsedSeconds = 0
        
        let newWorkout = Workout(startTime: Date())
        currentWorkout = newWorkout
        context.insert(newWorkout)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()
        }
    }
    
    func tick() {
        elapsedSeconds += 1
        
        if restTimerActive {
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                restTimerActive = false
                // TODO: Trigger an alert here
            }
        }
    }
    
    func finishWorkout() {
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        isWorkoutActive = false
        restTimerActive = false
        
        // Update with final end time
        currentWorkout?.endTime = Date()
        
        currentWorkout = nil
        elapsedSeconds = 0
    }
    
    func startRestTimer() {
        restTimerActive = true
        restTimeRemaining = selectedRestDuration
    }
    
    func cancelRestTimer() {
        restTimerActive = false
        restTimeRemaining = 0
    }
    
    func addExercise(_ template: ExerciseTemplate) {
        guard let workout = currentWorkout else {
            return
        }
        
        let newExercise = WorkoutExercise(name: template.name)
        newExercise.workout = workout

        let firstSet = WorkoutSet(weight: 0, reps: 0, isCompleted: false)
        firstSet.exercise = newExercise

        newExercise.sets.append(firstSet)
        workout.exercises.append(newExercise)
    }
}

