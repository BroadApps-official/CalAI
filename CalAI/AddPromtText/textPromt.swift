//
//  textPromt.swift
//  CalAI
//
//  Created by Денис Николаев on 17.03.2025.
//

import SwiftUI

struct textPromt: View {
    @StateObject private var viewModel = EntryViewModel()
    @StateObject private var taskViewModel = TaskViewModel()
    @EnvironmentObject var calorieViewModel: CalorieViewModel
    let category: String
    @Environment(\.dismiss) var dismiss
    
    private var isButtonEnabled: Bool {
        !taskViewModel.newTaskText.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Entry Type", selection: $viewModel.selectedType) {
                    ForEach(EntryType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorMultiply(.green)
                .tint(.green)
                .padding()
                .cornerRadius(24)
                
                TextField("", text: $taskViewModel.newTaskText, prompt: Text("Describe your \(viewModel.selectedType.rawValue.lowercased()) in order to make an analysis."))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    if viewModel.selectedType == .activity {
                        createSportTask()
                    } else {
                        taskViewModel.createUserTask(destination: .resultView)
                    }
                }) {
                    Text("\(Image(systemName: "sparkles")) To create")
                        .foregroundColor(isButtonEnabled ? .white : .gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isButtonEnabled ? Color.green : Color.gray.opacity(0.5))
                        .cornerRadius(32)
                        .padding(.horizontal, 16)
                }
                .disabled(!isButtonEnabled)
            }
            .navigationTitle("Add an entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        impactFeedback.impactOccurred()
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
            .fullScreenCover(isPresented: $taskViewModel.isLoading) {
                LoadingView(taskViewModel: taskViewModel, category: category)
            }
            .onChange(of: taskViewModel.isDataLoaded) { newValue in
                if newValue && viewModel.selectedType == .activity {
                    addActivityFromResponse()
                }
            }
        }
    }
    
    private func createSportTask() {
        guard !taskViewModel.newTaskText.isEmpty else {
            taskViewModel.errorMessage = "Текст задачи не может быть пустым"
            return
        }
        
        taskViewModel.isLoading = true
        taskViewModel.isDataLoaded = false
        
        APIClient().createSportTask(text: taskViewModel.newTaskText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskResponse):
                    self.taskViewModel.task = taskResponse
                    self.taskViewModel.taskId = taskResponse.id
                    print("📥 Задача для спорта создана: \(taskResponse)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        self.fetchSportTaskWithRetries(taskId: taskResponse.id, retries: 5)
                    }
                case .failure(let error):
                    self.taskViewModel.isLoading = false
                    self.taskViewModel.errorMessage = "Ошибка: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func fetchSportTaskWithRetries(taskId: UUID, retries: Int, delay: Double = 5.0) {
        APIClient().getSportTask(taskId: taskId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskResponse):
                    self.taskViewModel.task = taskResponse
                    print("📥 Полученные данные для спорта: \(taskResponse)")
                    if (taskResponse.items?.isEmpty ?? true) && retries > 0 {
                        print("Items пустой, повторяем запрос через \(delay) сек, осталось попыток: \(retries)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.fetchSportTaskWithRetries(taskId: taskId, retries: retries - 1)
                        }
                    } else {
                        self.taskViewModel.isDataLoaded = true
                    }
                case .failure(let error):
                    self.taskViewModel.isLoading = false
                    self.taskViewModel.errorMessage = "Ошибка получения задачи: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func addActivityFromResponse() {
        guard let task = taskViewModel.task,
              let items = task.items,
              !items.isEmpty else {
            print("❌ Нет данных для добавления активности: task=\(String(describing: taskViewModel.task))")
            taskViewModel.isLoading = false
            dismiss()
            return
        }
        
        for item in items {
            if let sport = item.sport,
               let calories = item.totalKilocalories {
                let duration: String
                if let timeInSeconds = item.time {
                    let minutes = Int(timeInSeconds / 60)
                    let seconds = Int(timeInSeconds.truncatingRemainder(dividingBy: 60))
                    duration = String(format: "%02d:%02d", minutes, seconds)
                } else {
                    duration = "Unknown"
                }
                let activity = Activity(
                    name: sport,
                    calories: -Int(calories),
                    duration: duration
                )
                calorieViewModel.addActivity(activity)
                print("✅ Добавлена активность: \(activity)")
            } else {
                print("⚠️ Пропущен item: sport=\(item.sport ?? "nil"), totalKilocalories=\(item.totalKilocalories ?? 0)")
            }
        }
        
        taskViewModel.isLoading = false
        dismiss()
    }
}

#Preview {
    textPromt(category: "")
}
