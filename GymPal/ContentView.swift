//
//  ContentView.swift
//  GymPal
//
//  Created by Ben Alvaro on 25/1/2026.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(WorkoutManager.self) var manager
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        TabView {
            StartWorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            ExerciseLibraryView()
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet")
                }
        }
        
        .fullScreenCover(isPresented: Bindable(manager).isWorkoutActive) {
            ActiveWorkoutView()
        }
        .onAppear {
            DataSeeder.seedExercises(context: modelContext)
        }
    }
}

struct StartWorkoutView: View {
    @Environment(WorkoutManager.self) var manager
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Let's Lift!")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                Button(action: {
                    manager.startWorkout(context: modelContext)
                }) {
                    Text("Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                
                Spacer()
            }
        }
    }
}

struct ActiveWorkoutView: View {
    @Environment(WorkoutManager.self) var manager
    @State private var showExerciseSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    Section {
                        HStack {
                            Spacer()
                            Text(formatTime(manager.elapsedSeconds))
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .monospacedDigit()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    if let workout = manager.currentWorkout {
                        ForEach(workout.exercises) { exercise in
                            Section(header: Text(exercise.name).font(.headline)) {
                                Grid(verticalSpacing: 12) {
                                    GridRow {
                                        Text("SET").font(.caption).gridColumnAlignment(.leading)
                                        Text("WEIGHT").font(.caption).gridColumnAlignment(.trailing)
                                        Text("REPS").font(.caption).gridColumnAlignment(.trailing)
                                        Color.clear.frame(width: 30, height: 1) // Space for the checkmark
                                    }
                                    .foregroundStyle(.secondary)
                                    .fontWeight(.bold)
                                    
                                    Divider()
                                    ForEach(Array(exercise.sets.enumerated()), id: \.element) { index, set in
                                        SetRowView(set: set, index: index + 1) {
                                            manager.startRestTimer()
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                Button("Add Set") {
                                    addSet(to: exercise)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    
                    
                    Section {
                        Button("Add Exercise") {
                            showExerciseSheet = true
                        }
                    }
                }
                
                if manager.restTimerActive {
                    RestTimerView(seconds: manager.restTimeRemaining) {
                        manager.cancelRestTimer()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 100)
                }
            }
                .animation(.spring(), value: manager.restTimerActive)
                .navigationTitle("Current Session")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showExerciseSheet) {
                    ExerciseSelectionView()
                }
                .safeAreaInset(edge: .bottom) {
                    Button(role: .destructive) {
                        manager.finishWorkout()
                    } label: {
                        Text("Finish Workout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .background(.ultraThinMaterial)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func addSet(to exercise: WorkoutExercise) {
        let newSet = WorkoutSet(weight: 0, reps: 0)
        exercise.sets.append(newSet)
    }
    
    func deleteSet(at offsets: IndexSet, from exercise: WorkoutExercise) {
        exercise.sets.remove(atOffsets: offsets)
    }
}
#Preview {
    ContentView()
        .environment(WorkoutManager())
        .modelContainer(for: [Workout.self, ExerciseTemplate.self], inMemory: true)
}
