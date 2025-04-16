//
//  APIClient.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import Foundation
import SwiftUI
import UIKit

class APIClient {
    private let baseURL = "https://backend.innovateapps.shop/api"
    private let apiToken = "a027e435-8633-4a62-9092-6bd242c60bc7"
    
    func createUserTask(text: String, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/task/text/meal")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiToken, forHTTPHeaderField: "api-token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": text, "language": "english"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("🔵 [POST] \(url)")
        print("📤 Отправляем данные: \(body)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("🔵 [POST] Статус-код: \(httpResponse.statusCode)")

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
                print("✅ [POST] Ответ: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

//    func createImageTask(image: UIImage, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
//        let url = URL(string: "\(baseURL)/task/image")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue(apiToken, forHTTPHeaderField: "api-token")
//        request.addValue("english", forHTTPHeaderField: "language")
//        let boundary = UUID().uuidString
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var body = Data()
//        
//        func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
//            let size = image.size
//            let widthRatio = targetSize.width / size.width
//            let heightRatio = targetSize.height / size.height
//            let newSize = widthRatio < heightRatio ?
//                CGSize(width: size.width * widthRatio, height: size.height * widthRatio) :
//                CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//            
//            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//            image.draw(in: rect)
//            let newImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            return newImage
//        }
//
//        let targetSize = CGSize(width: 800, height: 800)
//        guard let resizedImage = resizeImage(image, targetSize: targetSize) else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка изменения размера изображения"])))
//            return
//        }
//
//        var compressionQuality: CGFloat = 0.5
//        guard var imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка преобразования изображения в данные"])))
//            return
//        }
//
//        let maxSize = 1_000_000
//        while imageData.count > maxSize && compressionQuality > 0.1 {
//            compressionQuality -= 0.1
//            if let newImageData = resizedImage.jpegData(compressionQuality: compressionQuality) {
//                imageData = newImageData
//            } else {
//                break
//            }
//        }
//
//        if imageData.count > maxSize {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Размер изображения слишком большой даже после сжатия"])))
//            return
//        }
//
//        if let boundaryData = "--\(boundary)\r\n".data(using: .utf8) {
//            body.append(boundaryData)
//        }
//        if let dispositionData = "Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8) {
//            body.append(dispositionData)
//        }
//        if let contentTypeData = "Content-Type: image/jpeg\r\n\r\n".data(using: .utf8) {
//            body.append(contentTypeData)
//        }
//        body.append(imageData)
//        if let closingBoundaryData = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
//            body.append(closingBoundaryData)
//        }
//
//        request.httpBody = body
//
//        print("🔵 [POST] \(url)")
//        print("📤 Отправляем изображение, размер тела: \(body.count) байт")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Ошибка: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ Нет HTTP-ответа")
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет HTTP-ответа"])))
//                return
//            }
//            print("🔵 [POST] Статус-код: \(httpResponse.statusCode)")
//
//            guard let data = data else {
//                print("❌ Нет данных в ответе")
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])))
//                return
//            }
//
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("📜 Сырой ответ сервера: \(responseString)")
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
//                print("✅ [POST] Ответ: \(decodedResponse)")
//                completion(.success(decodedResponse))
//            } catch {
//                print("❌ Ошибка декодирования: \(error.localizedDescription)")
//                let decoder = JSONDecoder()
//                if let errorResponse = try? decoder.decode(HTTPErrorResponse.self, from: data) {
//                    print("❌ Ошибка сервера: \(errorResponse.detail ?? "Нет деталей")")
//                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.detail ?? "Неизвестная ошибка"])))
//                } else {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
    
    func createImageTask(image: UIImage, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
        // Базовый URL
        let baseURLString = "\(baseURL)/task/image"
        
        // Создаем URLComponents для добавления query-параметра
        var urlComponents = URLComponents(string: baseURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "language", value: "english")
        ]
        
        // Формируем окончательный URL с query-параметром
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiToken, forHTTPHeaderField: "api-token")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
            let size = image.size
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            let newSize = widthRatio < heightRatio ?
                CGSize(width: size.width * widthRatio, height: size.height * widthRatio) :
                CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }

        let targetSize = CGSize(width: 800, height: 800)
        guard let resizedImage = resizeImage(image, targetSize: targetSize) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка изменения размера изображения"])))
            return
        }

        var compressionQuality: CGFloat = 0.5
        guard var imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка преобразования изображения в данные"])))
            return
        }

        let maxSize = 1_000_000
        while imageData.count > maxSize && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            if let newImageData = resizedImage.jpegData(compressionQuality: compressionQuality) {
                imageData = newImageData
            } else {
                break
            }
        }

        if imageData.count > maxSize {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Размер изображения слишком большой даже после сжатия"])))
            return
        }

        if let boundaryData = "--\(boundary)\r\n".data(using: .utf8) {
            body.append(boundaryData)
        }
        if let dispositionData = "Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8) {
            body.append(dispositionData)
        }
        if let contentTypeData = "Content-Type: image/jpeg\r\n\r\n".data(using: .utf8) {
            body.append(contentTypeData)
        }
        body.append(imageData)
        if let closingBoundaryData = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
            body.append(closingBoundaryData)
        }

        request.httpBody = body

        print("🔵 [POST] \(url)")
        print("📤 Отправляем изображение, размер тела: \(body.count) байт")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Нет HTTP-ответа")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет HTTP-ответа"])))
                return
            }
            print("🔵 [POST] Статус-код: \(httpResponse.statusCode)")

            guard let data = data else {
                print("❌ Нет данных в ответе")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📜 Сырой ответ сервера: \(responseString)")
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
                print("✅ [POST] Ответ: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                let decoder = JSONDecoder()
                if let errorResponse = try? decoder.decode(HTTPErrorResponse.self, from: data) {
                    print("❌ Ошибка сервера: \(errorResponse.detail ?? "Нет деталей")")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.detail ?? "Неизвестная ошибка"])))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    struct HTTPErrorResponse: Codable {
        let detail: String?
    }
    
    func getImageTask(taskId: UUID, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/task/image/\(taskId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiToken, forHTTPHeaderField: "api-token")

        print("🔵 [GET] \(url)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("🔵 [GET] Статус-код: \(httpResponse.statusCode)")

            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Сырой ответ сервера: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
                print("✅ [GET] Ответ: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    func getTask(taskId: UUID, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/task/text/meal/\(taskId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiToken, forHTTPHeaderField: "api-token")

        print("🔵 [GET] \(url)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("🔵 [GET] Статус-код: \(httpResponse.statusCode)")

            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Сырой ответ сервера: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
                print("✅ [GET] Ответ: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createSportTask(text: String, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/task/text/sport")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiToken, forHTTPHeaderField: "api-token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": text, "language": "english"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("🔵 [POST] \(url)")
        print("📤 Отправляем данные: \(body)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("🔵 [POST] Статус-код: \(httpResponse.statusCode)")

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
                print("✅ [POST] Ответ: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getSportTask(taskId: UUID, completion: @escaping (Result<TaskResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/task/text/sport/\(taskId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiToken, forHTTPHeaderField: "api-token")

        print("🔵 [GET] \(url)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("🔵 [GET] Статус-код: \(httpResponse.statusCode)")

            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Сырой ответ сервера: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(TaskResponse.self, from: data)
                print("✅ [GET] Ответ: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}

struct HomeView: View {
    @State private var selectedTab: String = "Home"
    @StateObject private var calorieViewModel = CalorieViewModel()
    @StateObject private var recipeViewModel = RecipeViewModel()
    @Binding var showSubscriptionSheet: Bool
    
    var body: some View {
        ZStack {
            switch selectedTab {
            case "Home":
                CalorieTrackerView(viewModel: calorieViewModel, selectedTab: $selectedTab)
                    .transition(.opacity)
                    .tint(.green)
            case "Recipes":
                ContentView3(selectedTab: $selectedTab)
                    .transition(.opacity)
                    .tint(.green)
            default:
                Text("Default Screen")
                    .font(.largeTitle)
                    .transition(.opacity)
            }
        }
        .environmentObject(calorieViewModel)
        .environmentObject(recipeViewModel)
        .fullScreenCover(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet(viewModel: SubscriptionViewModel(), showCloseButton: false)
                }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: String
    @Binding var showAddEntry: Bool
    
    var body: some View {
        HStack {
            TabBarButton(title: "Home", icon: "heart.fill", selectedTab: $selectedTab)
            Spacer()
            Button(action: {
                showAddEntry = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            Spacer()
            TabBarButton(title: "Recipes", icon: "doc.text.fill", selectedTab: $selectedTab)
        }
        .padding(.horizontal, 10)
        .frame(height: 70)
        .background(.black)
        .cornerRadius(24)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            selectedTab = title
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == title ? .white : .gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(selectedTab == title ? .white : .gray)
            }
            .padding()
            .padding(.horizontal, 18)
            .background(selectedTab == title ? Color.gray.opacity(0.3) : Color.clear)
            .cornerRadius(24)
        }
    }
}

import SwiftUI
import ApphudSDK
import Network

struct AddEntryView: View {
    @Binding var isPresented: Bool
    @State private var showText = false
    @State private var showImagePicker = false
    @State private var showGalleryPicker = false
    @State private var selectedImage: UIImage?
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showSubscriptionSheet = false
    @State private var showLoadingView = false
    @State private var showNetworkAlert = false // Added for network alert
    @State private var isConnected = true // Added to track connection status
    let category: String
    
    // Network monitoring
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text("Select an action")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        impactFeedback.impactOccurred()
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Text("To add an entry, select one of the options")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                
                HStack(spacing: 8) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        checkConnectionAndProceed {
                            if subscriptionManager.hasSubscription {
                                showText = true
                            } else {
                                showSubscriptionSheet = true
                            }
                        }
                    }) {
                        VStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                            Text("Text")
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0FB423").opacity(0.12))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showText) {
                        textPromt(category: category)
                    }
                    
                    Button(action: {
                        impactFeedback.impactOccurred()
                        checkConnectionAndProceed {
                            if subscriptionManager.hasSubscription {
                                showImagePicker = true
                            } else {
                                showSubscriptionSheet = true
                            }
                        }
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                            Text("Photo")
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0FB423").opacity(0.12))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                    }
                    
                    Button(action: {
                        impactFeedback.impactOccurred()
                        checkConnectionAndProceed {
                            if subscriptionManager.hasSubscription {
                                showGalleryPicker = true
                            } else {
                                showSubscriptionSheet = true
                            }
                        }
                    }) {
                        VStack {
                            Image(systemName: "photo.tv")
                                .foregroundColor(.white)
                            Text("Image")
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0FB423").opacity(0.12))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showGalleryPicker) {
                        ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Text("The activity can only be added using text.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            .frame(maxWidth: 300)
            .background(Color.black.opacity(0.9))
            .cornerRadius(15)
            .padding(.horizontal)
            .fullScreenCover(isPresented: $showLoadingView) {
                LoadingView(taskViewModel: taskViewModel, category: category)
            }
            .fullScreenCover(isPresented: $showSubscriptionSheet) {
                SubscriptionSheet(viewModel: SubscriptionViewModel(), showCloseButton: true)
            }
            .alert(isPresented: $showNetworkAlert) {
                Alert(
                    title: Text("No Internet Connection"),
                    message: Text("Please check your internet connection and try again."),
                    primaryButton: .default(Text("Retry")) {
                        checkConnectionAndProceed {}
                    },
                    secondaryButton: .cancel()
                )
            }
            .onChange(of: selectedImage) { _ in
                if let image = selectedImage {
                    taskViewModel.createImageTask(image: image, destination: .resultView)
                    showLoadingView = true
                }
            }
            .task {
                setupNetworkMonitoring()
                await subscriptionManager.checkSubscriptionStatus()
            }
        }
    }
    
    // Function to check connection and proceed or show alert
    private func checkConnectionAndProceed(_ action: @escaping () -> Void) {
        if isConnected {
            action()
        } else {
            showNetworkAlert = true
        }
    }
    
    // Setup network monitoring
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isConnected = path.status == .satisfied
                if !isConnected {
                    showNetworkAlert = true
                }
            }
        }
        monitor.start(queue: queue)
    }
}

// Make sure to cancel monitoring when view disappears
extension AddEntryView {
    func onDisappear() {
        monitor.cancel()
    }
}

#Preview {
    // Создаём обёрточную структуру для предпросмотра
    struct AddEntryViewPreview: View {
        @State private var isPresented = true // Создаём состояние для Binding<Bool>

        var body: some View {
            AddEntryView(isPresented: $isPresented, category: "Breakfast")
        }
    }
    
    return AddEntryViewPreview()
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

