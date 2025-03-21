//
//  Task.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import Foundation

struct TaskItem: Codable, Identifiable {
    var id: UUID { UUID() }
    let product: String?
    let weight: Double?
    let kilocaloriesPer100g: Double?
    let fatsPer100g: Double?
    let carbohydratesPer100g: Double?
    let proteinsPer100g: Double?
    let ingredients: [Ingredient]?
    let action: String?
    let sport: String?
    let time: Double?
    let totalKilocalories: Double?

    enum CodingKeys: String, CodingKey {
        case product
        case weight
        case kilocaloriesPer100g = "kilocalories_per100g"
        case fatsPer100g = "fats_per100g"
        case carbohydratesPer100g = "carbohydrates_per100g"
        case proteinsPer100g = "fiber_per100g"
        case ingredients
        case action
        case sport
        case time 
        case totalKilocalories = "total_kilocalories"
    }
}

struct TaskResponse: Codable {
    let id: UUID
    let error: String?
    let comment: String?
    let text: String?
    let items: [TaskItem]?
    let totalKilocalories: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case error
        case comment
        case text
        case items
        case totalKilocalories = "total_kilocalories"
    }
}

extension TaskItem {
    static func mock(product: String, weight: Double, proteins: Double, carbs: Double, fats: Double, calories: Double) -> TaskItem {
        TaskItem(
            product: product,
            weight: weight,
            kilocaloriesPer100g: calories / (weight / 100.0),
            fatsPer100g: fats,
            carbohydratesPer100g: carbs,
            proteinsPer100g: proteins,
            ingredients: [
                Ingredient(ingredient: "Egg", weight: 50),
                Ingredient(ingredient: "Cheese", weight: 20)
            ],
            action: nil,
            sport: nil,
            time: nil,
            totalKilocalories: calories
        )
    }
}

extension TaskResponse {
    static func mock() -> TaskResponse {
        TaskResponse(
            id: UUID(),
            error: nil,
            comment: "A delicious omelette with cheese and veggies.",
            text: nil,
            items: [
                TaskItem.mock(product: "Omelette", weight: 150, proteins: 12, carbs: 5, fats: 10, calories: 200),
                TaskItem.mock(product: "Coffee", weight: 200, proteins: 0, carbs: 2, fats: 0, calories: 10)
            ],
            totalKilocalories: 210
        )
    }
}
