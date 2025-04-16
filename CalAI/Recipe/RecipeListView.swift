//
//  RecipeListView.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("Empty")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.white)
            Text("There is not a single recipe here.")
                .foregroundColor(.gray)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#FFFFFF").opacity(0.1))
        .cornerRadius(28)
        .padding(.horizontal)
    }
}

struct EmptyActivityView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("Empty")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.white)
            Text("Nothing has been added today.")
                .foregroundColor(.gray)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#FFFFFF").opacity(0.1))
        .cornerRadius(32)
       
    }
}

struct RecipeListView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var isSubscriptionSheetPresented = false
    let category: String
    @State private var showAddEntry = false
    @EnvironmentObject var calorieViewModel: CalorieViewModel

    var body: some View {
        ZStack {
            backgroundView
            mainContent
            addEntryOverlay
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                    if !subscriptionManager.hasSubscription {
                        Button(action: {
                            impactFeedback.impactOccurred()
                            isSubscriptionSheetPresented = true
                        }) {
                            HStack(spacing: 4) {
                                Text("GET PRO")
                                    .font(.system(size: 15, weight: .bold))
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#0FB423"), Color(hex: "#0EC1E9")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(32)
                            .foregroundColor(.white)
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $isSubscriptionSheetPresented) {
            SubscriptionSheet(viewModel: SubscriptionViewModel(), showCloseButton: true)
        }
        .task {
            await subscriptionManager.checkSubscriptionStatus()
        }
    }

    private var backgroundView: some View {
        Color.black
            .edgesIgnoringSafeArea(.all)
    }

    private var mainContent: some View {
        VStack {
            categoryTitle
            recipeListOrEmptyState
            addButton
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.selectedCategory = category
        }
    }

    private var categoryTitle: some View {
        Text(category)
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .foregroundColor(.white)
    }

    private var recipeListOrEmptyState: some View {
        Group {
            if viewModel.recipesForSelectedCategory().isEmpty {
                EmptyStateView()
                    .frame(width: .infinity, height: 200)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.recipesForSelectedCategory()) { recipe in
                            recipeCard(recipe: recipe)
                        }
                    }
                    .padding()
                    .background(Color(hex: "#FFFFFF").opacity(0.1))
                    .cornerRadius(32)
                }
            }
        }
    }

    private func recipeCard(recipe: Recipe) -> some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel, calorieViewModel: calorieViewModel).navigationBarBackButtonHidden(true)) {
            HStack(spacing: 16) {
                recipeImage(imageName: recipe.imageName)
                recipeDetails(recipe: recipe)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#000000").opacity(0.4))
            .cornerRadius(28)
        }
        .contextMenu {
            Button(role: .destructive) {
                deleteRecipe(recipe)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func deleteRecipe(_ recipe: Recipe) {
        withAnimation {
            viewModel.deleteRecipe(recipe)
        }
    }

    private func recipeImage(imageName: String?) -> some View {
        Group {
            if let imageName = imageName, let uiImage = loadImageFromDisk(imageName: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func recipeDetails(recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.white)
            HStack(spacing: 15) {
                nutritionalInfo(icon: "1", value: "\(recipe.protein)", color: .green)
                nutritionalInfo(icon: "2", value: "\(recipe.carbs)", color: .green)
                nutritionalInfo(icon: "3", value: "\(recipe.fats)", color: .red)
            }
            Text("+ \(recipe.calories)")
                .foregroundColor(.green)
            + Text(" kcal")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func nutritionalInfo(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(icon)
            Text(value)
                .foregroundColor(.white)
        }
    }

    private var addButton: some View {
        Button(action: {
            showAddEntry = true
        }) {
            HStack {
                Image(systemName: "plus")
                Text("Add")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#0FB423"))
            .cornerRadius(32)
            .padding(.horizontal)
        }
    }

    private var addEntryOverlay: some View {
        Group {
            if showAddEntry {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAddEntry = false
                    }
                AddEntryView(isPresented: $showAddEntry, category: category)
                    .frame(maxWidth: 300, maxHeight: 200)
                    .background(Color.black)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showAddEntry)
            }
        }
    }

    private func loadImageFromDisk(imageName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
}
