//
//  LoadingView.swift
//  CalAI
//
//  Created by Денис Николаев on 15.03.2025.

import SwiftUI
import Lottie

struct LoadingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var taskViewModel: TaskViewModel
    let category: String
    
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    if !taskViewModel.isDataLoaded {
                        LottieView(animation: .named("CalAI.json"))
                            .playing(loopMode: .autoReverse)
                            .frame(width: 250, height: 250)
                            .padding()
                        Text("A scan is underway")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("Wait a bit, the report will be ready soon.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else if let task = taskViewModel.task {
                        if let error = task.error {
                            Text("Scan Completed!")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        } else {
                            EmptyView()
                        }
                    } else if let error = taskViewModel.errorMessage {
                        Text("Error")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                if taskViewModel.isDataLoaded && taskViewModel.task != nil && taskViewModel.task?.error == nil {
                    NavigationLink(
                        destination: ResultView(
                            task: taskViewModel.task!,
                            viewModel: RecipeViewModel(),
                            category: category,
                            image: taskViewModel.selectedImage
                        ),
                        isActive: $shouldNavigate
                    ) {
                        EmptyView()
                    }
                }
            }
            .overlay(
                HStack {
                    Spacer()
                    Button(action: {
                        impactFeedback.impactOccurred()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.green)
                            .font(.title)
                            .padding()
                    }
                }
                .padding(.top, 10),
                alignment: .topTrailing
            )
            .onChange(of: taskViewModel.isDataLoaded) { newValue in
                if newValue && taskViewModel.task != nil && taskViewModel.task?.error == nil {
                    shouldNavigate = true
                }
            }
            .onChange(of: taskViewModel.isLoading) { newValue in
                if !newValue {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    LoadingView(taskViewModel: TaskViewModel(), category: "")
}
