//
//  WorkoutManager.swift
//  GymPal
//
//  Created by Ben Alvaro on 26/1/2026.
//

import Foundation
import Observation
import SwiftData
import UserNotifications

@Observable
class WorkoutManager {
    
    // Workout State
    var isWorkoutActive: Bool = false
    var elapsedSeconds: Int = 0
    
    // Reset Timer State
    var restTimerActive: Bool = false
    var restTimeRemaining: Int = 0
    private var restEndDate: Date?
    private var timer: Timer?
    
    var currentWorkout: Workout?
    
    func fetchActiveWorkout(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endTime == nil }
        )
        
        if let existingWorkout = try? context.fetch(descriptor).first {
            self.currentWorkout = existingWorkout
            self.isWorkoutActive = true
            self.startGlobalTimer()
        }
    }

    
    func startWorkout(context: ModelContext, templateExercise: [String] = []) {
        isWorkoutActive = true
        
        let newWorkout = Workout(startTime: Date())
        for name in templateExercise {
            let exercise = WorkoutExercise(name: name)
            exercise.sets.append(WorkoutSet(weight: 0, reps: 0))
            newWorkout.exercises.append(exercise)
        }
        
        currentWorkout = newWorkout
        context.insert(newWorkout)
        
        startGlobalTimer()
    }
        
    private func startGlobalTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func tick() {
        if let start = currentWorkout?.startTime {
            elapsedSeconds = Int(Date().timeIntervalSince(start))
        }
        
        if restTimerActive, let end = restEndDate {
            let remaining = Int(end.timeIntervalSinceNow)
            if remaining > 0 {
                restTimeRemaining = remaining
            } else {
                restTimeRemaining = 0
                restTimerActive = false
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
    
    func startRestTimer(seconds: Int = 60) {
            restEndDate = Date().addingTimeInterval(TimeInterval(seconds))
            restTimerActive = true
            
        scheduleRestNotification(at: restEndDate!)
            
            if timer == nil { startGlobalTimer() }
    }
    
    private func scheduleRestNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Over! 🏎️"
        content.body = "Time for your next set. Let's go!"
        content.sound = .default // Or use a custom "pit wall" sound
        
        let timeInterval = date.timeIntervalSinceNow
        if timeInterval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: "RestTimer", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
        
    func cancelRestTimer() {
        restTimerActive = false
        restEndDate = nil
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestTimer"])
    }
    
    func addExercise(_ template: ExerciseTemplate) {
        guard let workout = currentWorkout else {
            return
        }
        
        let newExercise = WorkoutExercise(name: template.name, equipment: template.equipment)
        newExercise.workout = workout

        let firstSet = WorkoutSet(weight: 0, reps: 0, isCompleted: false)
        firstSet.exercise = newExercise

        newExercise.sets.append(firstSet)
        workout.exercises.append(newExercise)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            }
        }
    }
}


