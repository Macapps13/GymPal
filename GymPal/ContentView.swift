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
    
    // Fetch saved templates
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) var templates: [WorkoutTemplate]
    
    var body: some View {
        NavigationStack {
            if templates.isEmpty {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        manager.startWorkout(context: modelContext)
                    }) {
                        VStack(spacing: 15) {
                            Image(systemName: "plus")
                                .font(.system(size: 40, weight: .bold))
                            Text("Start Empty\nWorkout")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 200, height: 200)
                        .background(Circle().fill(.orange.gradient)) // F1-style orange gradient
                        .foregroundStyle(.white)
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    
                    Text("You don't have any routines yet.\nStart a workout to save one!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                .navigationTitle("Workout")
            } else {
                List {
                    Section {
                        Button(action: {
                            manager.startWorkout(context: modelContext)
                        }) {
                            HStack {
                                Spacer()
                                Text("Start Empty Workout")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .listRowInsets(EdgeInsets())
                    }
                    
                    Section("My Routines") {
                        ForEach(templates) { template in
                            Button(action: {
                                manager.startWorkout(context: modelContext, templateExercise: template.exerciseNames)
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(template.name)
                                            .font(.headline)
                                        Text(template.exerciseNames.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteTemplate)
                    }
                }
                .navigationTitle("Workout")
            }
        }
    }
    
    func deleteTemplate(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(templates[index])
        }
    }
}

struct ActiveWorkoutView: View {
    @Environment(WorkoutManager.self) var manager
    @Environment(\.modelContext) var modelContext
    @State private var showExerciseSheet = false
    
    var body: some View {
        
        let nameBinding = Binding(
                get: { manager.currentWorkout?.name ?? "New Workout" },
                set: { manager.currentWorkout?.name = $0 }
            )
        
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    Section {
                            TextField("Workout Name (e.g. Pull Day)", text: nameBinding)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                    }
                    
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
                            Section {
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
                            } header: {
                                ExerciseLabel(name: exercise.name, equipment: exercise.equipment)
                                    .padding(.vertical, 4)
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
        .modelContainer(for: [Workout.self, WorkoutTemplate.self, ExerciseTemplate.self])
}
