//
//  MealSection.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct MealSection: View {
    @ObservedObject var viewModel: CalorieViewModel
    
    let mealCategories = ["Breakfast", "Lunch", "Dinner", "Snack", "Other"]
    private let categoryImages: [String: String] = [
        "Breakfast": "breakfast",
        "Lunch": "lunch",
        "Dinner": "dinner",
        "Snack": "snack",
        "Other": "other"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Meal")
                .font(.headline)
            VStack {
                ForEach(mealCategories, id: \.self) { category in
                    NavigationLink(destination: MealDetailView(category: category, viewModel: viewModel)) {
                        HStack {
                            Image(categoryImages[category] ?? "defaultIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                            Text(category)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(viewModel.meals(for: category).count)")
                                .foregroundColor(.white)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(28)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(32)
        }
    }
}

