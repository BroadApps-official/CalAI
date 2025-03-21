//
//  ItemDetailView.swift
//  CalAI
//
//  Created by Денис Николаев on 17.03.2025.
//

import SwiftUI

struct ItemRow: View {
    let item: TaskItem
    let image: UIImage?

    var body: some View {
        HStack(spacing: 16) {
            itemImage(product: item.product)
            
            itemDetails(item: item)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "#000000").opacity(0.4))
        .cornerRadius(28)
    }

    private func itemImage(product: String?) -> some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: imageName(for: product))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.gray)
            }
        }
    }

    private func itemDetails(item: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.product ?? "Unknown Item")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                nutritionalInfo(icon: "1", value: "\(Int(calculateProteins(for: item).rounded()))g", color: .yellow)
                nutritionalInfo(icon: "2", value: "\(Int(calculateCarbs(for: item).rounded()))g", color: .green)
                nutritionalInfo(icon: "3", value: "\(Int(calculateFats(for: item).rounded()))g", color: .red)
            }
            
            if let calories = item.totalKilocalories {
                Text("+ \(Int(calories.rounded()))")
                    .foregroundColor(.green)
                + Text(" kcal")
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func nutritionalInfo(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(icon)
                .foregroundColor(color)
                .frame(width: 16, height: 16)
            Text(value)
                .foregroundColor(.white)
                .font(.subheadline)
        }
    }

    private func imageName(for product: String?) -> String {
        switch product {
        case "Омлет", "Протеиновый коктейль":
            return "fork.knife"
        default:
            return "photo"
        }
    }

    private func calculateProteins(for item: TaskItem) -> Double {
        guard let weight = item.weight, let proteinsPer100g = item.proteinsPer100g else { return 0.0 }
        return (weight / 100.0) * proteinsPer100g
    }

    private func calculateCarbs(for item: TaskItem) -> Double {
        guard let weight = item.weight, let carbsPer100g = item.carbohydratesPer100g else { return 0.0 }
        return (weight / 100.0) * carbsPer100g
    }

    private func calculateFats(for item: TaskItem) -> Double {
        guard let weight = item.weight, let fatsPer100g = item.fatsPer100g else { return 0.0 }
        return (weight / 100.0) * fatsPer100g
    }
}

struct ItemDetailView: View {
    let item: TaskItem
    let comment: String?
    let image: UIImage?
    @State private var selectedTab: String = "Ingredients"
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(item.product ?? "Unknown Item")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    if let calories = item.totalKilocalories {
                        Text("+ \(Int(calories.rounded()))")
                            .foregroundColor(.green)
                            .font(.title)
                            .fontWeight(.bold)
                        + Text(" kcal")
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal)
                
                ZStack(alignment: .bottom) {
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                    } else {
                        Image(systemName: imageName(for: item.product))
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                    }
                    
                    let totalProteins = (item.weight ?? 0.0) / 100.0 * (item.proteinsPer100g ?? 0.0)
                    let totalCarbs = (item.weight ?? 0.0) / 100.0 * (item.carbohydratesPer100g ?? 0.0)
                    let totalFats = (item.weight ?? 0.0) / 100.0 * (item.fatsPer100g ?? 0.0)
                    
                    HStack {
                        NutritionView(value: Int(totalProteins.rounded()), label: "protein")
                        NutritionView(value: Int(totalCarbs.rounded()), label: "carbs")
                        NutritionView(value: Int(totalFats.rounded()), label: "fats")
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }
                
                if let descriptionText = comment {
                    Text("Description")
                        .font(.system(size: 20))
                        .padding(.horizontal)
                    Text(descriptionText)
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                Picker("Select Section", selection: $selectedTab) {
                    Text("Ingredients").tag("Ingredients")
                    Text("Recipe").tag("Recipe")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == "Ingredients" {
                    if let ingredients = item.ingredients, !ingredients.isEmpty {
                        ForEach(ingredients) { ingredient in
                            HStack {
                                Text(ingredient.ingredient.capitalized)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(ingredient.weight.rounded()))g")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No ingredients available")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    Text("Recipe content goes here")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Breakfast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    private func imageName(for product: String?) -> String {
        switch product {
        case "Омлет", "Протеиновый коктейль":
            return "fork.knife"
        default:
            return "photo"
        }
    }
}


