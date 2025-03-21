//
//  TaskViewModel.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var task: TaskResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var newTaskText: String = ""
    @Published var navigationDestination: NavigationDestination?
    @Published var isDataLoaded: Bool = false
    @Published var selectedImage: UIImage?
    var taskId: UUID?
    private let apiClient = APIClient()

    func createUserTask(destination: NavigationDestination) {
        guard !newTaskText.isEmpty else {
            errorMessage = "Текст задачи не может быть пустым"
            return
        }

        isLoading = true
        isDataLoaded = false
        navigationDestination = nil
        apiClient.createUserTask(text: newTaskText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskResponse):
                    self.task = taskResponse
                    self.taskId = taskResponse.id
                    print("📥 Задача создана: \(taskResponse)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        self.fetchTaskWithRetries(taskId: taskResponse.id, destination: destination, retries: 5)
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                }
            }
        }
    }

    func createImageTask(image: UIImage, destination: NavigationDestination) {
        isLoading = true
        isDataLoaded = false
        navigationDestination = nil
        selectedImage = image
        apiClient.createImageTask(image: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskResponse):
                    self.task = taskResponse
                    self.taskId = taskResponse.id
                    print("📥 Задача создана из изображения: \(taskResponse)")
                    if let taskId = self.taskId {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            self.fetchImageTaskWithRetries(taskId: taskId, destination: destination, retries: 5)
                        }
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchTaskWithRetries(taskId: UUID, destination: NavigationDestination, retries: Int, delay: Double = 5.0) {
        apiClient.getTask(taskId: taskId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskResponse):
                    self.task = taskResponse
                    print("📥 Полученные items: \(taskResponse.items ?? [])")
                    if (taskResponse.items?.isEmpty ?? true) && retries > 0 {
                        print("Items пустой, повторяем запрос через \(delay) сек, осталось попыток: \(retries)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.fetchTaskWithRetries(taskId: taskId, destination: destination, retries: retries - 1)
                        }
                    } else {
                        self.isDataLoaded = true
                        self.navigationDestination = destination
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Ошибка получения задачи: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchImageTaskWithRetries(taskId: UUID, destination: NavigationDestination, retries: Int, delay: Double = 5.0) {
        apiClient.getImageTask(taskId: taskId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskResponse):
                    self.task = taskResponse
                    print("📥 Полученные items: \(taskResponse.items ?? [])")
                    if (taskResponse.items?.isEmpty ?? true) && retries > 0 {
                        print("Items пустой, повторяем запрос через \(delay) сек, осталось попыток: \(retries)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.fetchImageTaskWithRetries(taskId: taskId, destination: destination, retries: retries - 1)
                        }
                    } else {
                        self.isDataLoaded = true
                        self.navigationDestination = destination
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Ошибка получения задачи: \(error.localizedDescription)"
                }
            }
        }
    }
}

