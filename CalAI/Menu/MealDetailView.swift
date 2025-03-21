//
//  MealDetailView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct MealDetailView: View {
    let category: String
    @ObservedObject var viewModel: CalorieViewModel
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
    }
    
    private var backgroundView: some View {
        Color.black
            .edgesIgnoringSafeArea(.all)
    }
    
    private var mainContent: some View {
        VStack {
            categoryTitle
            mealListOrEmptyState
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private var categoryTitle: some View {
        Text(category)
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .foregroundColor(.white)
    }
    
    private var mealListOrEmptyState: some View {
        Group {
            if viewModel.meals(for: category).isEmpty {
                EmptyStateView()
                    .frame(width: .infinity, height: 200)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.meals(for: category)) { meal in
                            mealCard(meal: meal)
                        }
                    }
                    .padding()
                    .background(Color(hex: "#FFFFFF").opacity(0.1))
                    .cornerRadius(32)
                }
            }
        }
    }
    
    // Option 1: Swipe-to-delete version
    private func mealCard(meal: Meal) -> some View {
        HStack(spacing: 16) {
            mealImage(meal: meal)
            mealDetails(meal: meal)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "#000000").opacity(0.4))
        .cornerRadius(28)
        .contextMenu() {
            Button(role: .destructive) {
                viewModel.removeMeal(meal, from: category)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
    
    private func mealImage(meal: Meal) -> some View {
            Group {
                if let imageName = meal.imageName, let uiImage = loadImageFromDisk(imageName: imageName) {
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
    
    private func mealDetails(meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(meal.name)
                .font(.headline)
                .foregroundColor(.white)
            Text("+ \(meal.calories)")
                .foregroundColor(.green)
            + Text(" kcal")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
